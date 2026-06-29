import 'dart:io';

import 'package:image/image.dart' as img;

import '../../domain/domain.dart';
import '../../infrastructure/storage/arquivo_service.dart';
import '../models/acao_edicao_mascara.dart';
import 'resultado_processamento_imagem.dart';
import 'resultado_validacao_mascara.dart';

/// Serviço de aplicação responsável pela edição manual mínima da máscara.
///
/// O serviço trabalha apenas com arquivos e imagens de máscara. A imagem
/// original não é recebida nos métodos de edição e, portanto, não pode ser
/// alterada por esta regra de negócio.
class FerramentaEdicaoService {
  FerramentaEdicaoService({
    ArquivoService? arquivoService,
    CalculoDosselService? calculoDosselService,
  }) : _arquivoService = arquivoService ?? ArquivoService(),
       _calculoDosselService =
           calculoDosselService ?? const CalculoDosselService();

  static const (int, int, int) corCeu = (0, 102, 255);
  static const (int, int, int) corNaoCeu = (34, 139, 34);

  final ArquivoService _arquivoService;
  final CalculoDosselService _calculoDosselService;

  /// Carrega a máscara automática a partir do caminho salvo na entidade.
  ///
  /// A leitura não modifica a máscara automática. As edições posteriores devem
  /// ocorrer sobre cópias em memória e ser salvas em novo arquivo final.
  Future<img.Image> carregarMascaraAutomatica(String caminhoMascara) async {
    final bytes = await File(caminhoMascara).readAsBytes();
    final mascara = img.decodeImage(bytes);

    if (mascara == null) {
      throw const FormatException('Não foi possível decodificar a máscara.');
    }

    return mascara;
  }

  /// Cria uma cópia independente da máscara em memória.
  img.Image copiarMascara(img.Image mascara) {
    return mascara.clone(noAnimation: true);
  }

  /// Aplica uma ação de edição sobre uma cópia da máscara recebida.
  ///
  /// Pixels fora dos limites são ignorados. A ferramenta borracha, neste modelo
  /// binário céu/não céu, remove a marcação de céu aplicando a classe não céu.
  img.Image aplicarAcao({
    required img.Image mascara,
    required AcaoEdicaoMascara acao,
  }) {
    final editada = copiarMascara(mascara);
    final classeDestino = acao.ferramenta == TipoFerramenta.borracha
        ? ClassePixel.naoCeu
        : acao.classeAplicada;
    final tamanho = acao.tamanhoPincel < 1 ? 1 : acao.tamanhoPincel;
    final inicioX = acao.x - tamanho ~/ 2;
    final inicioY = acao.y - tamanho ~/ 2;

    for (var deslocamentoY = 0; deslocamentoY < tamanho; deslocamentoY++) {
      for (var deslocamentoX = 0; deslocamentoX < tamanho; deslocamentoX++) {
        final x = inicioX + deslocamentoX;
        final y = inicioY + deslocamentoY;
        if (x < 0 || y < 0 || x >= editada.width || y >= editada.height) {
          continue;
        }
        _pintarPixel(editada, x, y, classeDestino);
      }
    }

    return editada;
  }

  /// Conta pixels de céu, não céu e inválidos presentes na máscara.
  ///
  /// A contagem interpreta as cores padronizadas do projeto: azul para céu e
  /// verde para não céu. Cores desconhecidas ficam como inválidas para não
  /// contaminar o cálculo final.
  ContagemPixelsMascara contarPixels(img.Image mascara) {
    var pixelsCeu = 0;
    var pixelsNaoCeu = 0;
    var pixelsInvalidos = 0;

    for (var y = 0; y < mascara.height; y++) {
      for (var x = 0; x < mascara.width; x++) {
        final classe = classificarPixelMascara(mascara, x, y);
        switch (classe) {
          case ClassePixel.ceu:
            pixelsCeu++;
          case ClassePixel.naoCeu:
            pixelsNaoCeu++;
          case ClassePixel.invalido:
            pixelsInvalidos++;
        }
      }
    }

    return ContagemPixelsMascara(
      pixelsCeu: pixelsCeu,
      pixelsNaoCeu: pixelsNaoCeu,
      pixelsInvalidos: pixelsInvalidos,
    );
  }

  /// Classifica um pixel da máscara a partir das cores padronizadas.
  ClassePixel classificarPixelMascara(img.Image mascara, int x, int y) {
    if (x < 0 || y < 0 || x >= mascara.width || y >= mascara.height) {
      return ClassePixel.invalido;
    }

    final pixel = mascara.getPixel(x, y);
    final vermelho = pixel.r.toInt();
    final verde = pixel.g.toInt();
    final azul = pixel.b.toInt();

    if (_corProxima(vermelho, verde, azul, corCeu)) {
      return ClassePixel.ceu;
    }

    if (_corProxima(vermelho, verde, azul, corNaoCeu)) {
      return ClassePixel.naoCeu;
    }

    return ClassePixel.invalido;
  }

  /// Salva a máscara editada como arquivo PNG final e calcula o resultado final.
  ///
  /// A máscara automática não é sobrescrita. O caminho final é gerado pelo
  /// `ArquivoService` para manter a separação entre máscara automática e máscara
  /// validada pelo pesquisador.
  Future<ResultadoValidacaoMascara> validarMascaraEditada({
    required ResultadoProcessamentoImagem processamento,
    required img.Image mascaraEditada,
    String? mascaraId,
    String? resultadoId,
    DateTime? dataHora,
  }) async {
    final agora = dataHora ?? DateTime.now();
    final idMascara =
        mascaraId ?? 'mascara_final_${agora.microsecondsSinceEpoch}';
    final caminhoMascaraFinal = await _arquivoService
        .gerarCaminhoSeguroMascaraFinal(
          imagemId: processamento.imagem.id,
          id: idMascara,
          dataHora: agora,
        );

    await File(caminhoMascaraFinal).writeAsBytes(img.encodePng(mascaraEditada));

    final contagem = contarPixels(mascaraEditada);
    final pixelsValidos = _calculoDosselService.calcularPixelsValidos(
      pixelsCeu: contagem.pixelsCeu,
      pixelsNaoCeu: contagem.pixelsNaoCeu,
    );
    final percentualCeu = _calculoDosselService.calcularPercentualCeu(
      pixelsCeu: contagem.pixelsCeu,
      pixelsValidos: pixelsValidos,
    );
    final percentualDossel = _calculoDosselService.calcularPercentualDossel(
      percentualCeu: percentualCeu,
      pixelsValidos: pixelsValidos,
    );
    final diferencaPercentual = _calculoDosselService
        .calcularDiferencaPercentual(
          percentualAutomatico:
              processamento.resultadoAutomatico.percentualDossel,
          percentualFinal: percentualDossel,
        );

    final mascaraFinal = Mascara(
      id: idMascara,
      analiseId: processamento.imagem.analiseId,
      tipo: TipoMascara.finalValidada,
      caminhoArquivo: caminhoMascaraFinal,
      largura: mascaraEditada.width,
      altura: mascaraEditada.height,
      pixelsCeu: contagem.pixelsCeu,
      pixelsNaoCeu: contagem.pixelsNaoCeu,
      pixelsInvalidos: contagem.pixelsInvalidos,
      origemMascara: 'edicao_manual_fase_7',
      dataCriacao: agora,
    );

    final resultadoFinal = ResultadoAnalise(
      id: resultadoId ?? 'resultado_final_${agora.microsecondsSinceEpoch}',
      analiseId: processamento.imagem.analiseId,
      mascaraId: mascaraFinal.id,
      tipoMascara: TipoMascara.finalValidada,
      pixelsValidos: pixelsValidos,
      pixelsCeu: contagem.pixelsCeu,
      pixelsNaoCeu: contagem.pixelsNaoCeu,
      percentualCeu: percentualCeu,
      percentualDossel: percentualDossel,
      diferencaPercentual: diferencaPercentual,
      dataCalculo: agora,
    );

    return ResultadoValidacaoMascara(
      processamento: processamento,
      mascaraFinal: mascaraFinal,
      resultadoFinal: resultadoFinal,
    );
  }

  void _pintarPixel(img.Image mascara, int x, int y, ClassePixel classePixel) {
    switch (classePixel) {
      case ClassePixel.ceu:
        final (vermelho, verde, azul) = corCeu;
        mascara.setPixelRgba(x, y, vermelho, verde, azul, 255);
      case ClassePixel.naoCeu:
        final (vermelho, verde, azul) = corNaoCeu;
        mascara.setPixelRgba(x, y, vermelho, verde, azul, 255);
      case ClassePixel.invalido:
        mascara.setPixelRgba(x, y, 0, 0, 0, 0);
    }
  }

  bool _corProxima(
    int vermelho,
    int verde,
    int azul,
    (int, int, int) corReferencia,
  ) {
    final (refVermelho, refVerde, refAzul) = corReferencia;
    return (vermelho - refVermelho).abs() <= 8 &&
        (verde - refVerde).abs() <= 8 &&
        (azul - refAzul).abs() <= 8;
  }
}

/// Contagem resumida dos pixels reconhecidos na máscara.
class ContagemPixelsMascara {
  const ContagemPixelsMascara({
    required this.pixelsCeu,
    required this.pixelsNaoCeu,
    required this.pixelsInvalidos,
  });

  final int pixelsCeu;
  final int pixelsNaoCeu;
  final int pixelsInvalidos;

  int get pixelsValidos => pixelsCeu + pixelsNaoCeu;
}
