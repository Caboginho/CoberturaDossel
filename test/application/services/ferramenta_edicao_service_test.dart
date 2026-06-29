import 'dart:io';

import 'package:cobertura_dossel/application/application.dart';
import 'package:cobertura_dossel/domain/domain.dart';
import 'package:cobertura_dossel/infrastructure/infrastructure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  late Directory diretorioTemporario;
  late FerramentaEdicaoService ferramentaEdicaoService;

  setUp(() async {
    diretorioTemporario = await Directory.systemTemp.createTemp(
      'cobertura_dossel_edicao_',
    );
    ferramentaEdicaoService = FerramentaEdicaoService(
      arquivoService: ArquivoService(diretorioBase: diretorioTemporario),
    );
  });

  tearDown(() async {
    if (await diretorioTemporario.exists()) {
      await diretorioTemporario.delete(recursive: true);
    }
  });

  test('pinta um pixel da máscara como CEU', () {
    final mascara = _criarMascara(3, 3, ClassePixel.naoCeu);
    final editada = ferramentaEdicaoService.aplicarAcao(
      mascara: mascara,
      acao: AcaoEdicaoMascara(
        x: 1,
        y: 1,
        tamanhoPincel: 1,
        classeAplicada: ClassePixel.ceu,
        ferramenta: TipoFerramenta.pincel,
        dataHora: DateTime(2026, 6, 29, 10),
      ),
    );

    expect(
      ferramentaEdicaoService.classificarPixelMascara(editada, 1, 1),
      ClassePixel.ceu,
    );
    expect(
      ferramentaEdicaoService.classificarPixelMascara(mascara, 1, 1),
      ClassePixel.naoCeu,
    );
  });

  test('pinta um pixel da máscara como NAO_CEU', () {
    final mascara = _criarMascara(3, 3, ClassePixel.ceu);
    final editada = ferramentaEdicaoService.aplicarAcao(
      mascara: mascara,
      acao: AcaoEdicaoMascara(
        x: 1,
        y: 1,
        tamanhoPincel: 1,
        classeAplicada: ClassePixel.naoCeu,
        ferramenta: TipoFerramenta.pincel,
        dataHora: DateTime(2026, 6, 29, 10),
      ),
    );

    expect(
      ferramentaEdicaoService.classificarPixelMascara(editada, 1, 1),
      ClassePixel.naoCeu,
    );
  });

  test('aplica pincel com tamanho maior que 1', () {
    final mascara = _criarMascara(5, 5, ClassePixel.naoCeu);
    final editada = ferramentaEdicaoService.aplicarAcao(
      mascara: mascara,
      acao: AcaoEdicaoMascara(
        x: 2,
        y: 2,
        tamanhoPincel: 3,
        classeAplicada: ClassePixel.ceu,
        ferramenta: TipoFerramenta.pincel,
        dataHora: DateTime(2026, 6, 29, 10),
      ),
    );
    final contagem = ferramentaEdicaoService.contarPixels(editada);

    expect(contagem.pixelsCeu, 9);
    expect(contagem.pixelsNaoCeu, 16);
  });

  test('ignora pixels fora dos limites sem gerar erro', () {
    final mascara = _criarMascara(2, 2, ClassePixel.naoCeu);

    final editada = ferramentaEdicaoService.aplicarAcao(
      mascara: mascara,
      acao: AcaoEdicaoMascara(
        x: -10,
        y: -10,
        tamanhoPincel: 5,
        classeAplicada: ClassePixel.ceu,
        ferramenta: TipoFerramenta.pincel,
        dataHora: DateTime(2026, 6, 29, 10),
      ),
    );
    final contagem = ferramentaEdicaoService.contarPixels(editada);

    expect(contagem.pixelsCeu, 0);
    expect(contagem.pixelsNaoCeu, 4);
  });

  test(
    'não recebe nem altera a imagem original ao validar máscara editada',
    () async {
      final arquivoOriginal = File(
        '${diretorioTemporario.path}${Platform.pathSeparator}original.txt',
      );
      await arquivoOriginal.writeAsString('imagem original preservada');
      final bytesOriginaisAntes = await arquivoOriginal.readAsBytes();
      final mascaraAutomatica = _criarMascara(2, 2, ClassePixel.naoCeu);
      final arquivoMascaraAutomatica = File(
        '${diretorioTemporario.path}${Platform.pathSeparator}mascara_automatica.png',
      );
      await arquivoMascaraAutomatica.writeAsBytes(
        img.encodePng(mascaraAutomatica),
      );
      final processamento = _criarResultadoProcessamento(
        caminhoImagemOriginal: arquivoOriginal.path,
        caminhoMascaraAutomatica: arquivoMascaraAutomatica.path,
      );

      final resultado = await ferramentaEdicaoService.validarMascaraEditada(
        processamento: processamento,
        mascaraEditada: mascaraAutomatica,
        dataHora: DateTime(2026, 6, 29, 10),
      );
      final bytesOriginaisDepois = await arquivoOriginal.readAsBytes();

      expect(bytesOriginaisDepois, bytesOriginaisAntes);
      expect(
        resultado.mascaraFinal.caminhoArquivo,
        isNot(arquivoOriginal.path),
      );
      expect(
        resultado.mascaraFinal.caminhoArquivo,
        isNot(arquivoMascaraAutomatica.path),
      );
      expect(File(resultado.mascaraFinal.caminhoArquivo).existsSync(), isTrue);
    },
  );

  test('recalcula contagem e percentuais após edição da máscara', () async {
    final mascara = _criarMascara(2, 2, ClassePixel.naoCeu);
    final editada = ferramentaEdicaoService.aplicarAcao(
      mascara: mascara,
      acao: AcaoEdicaoMascara(
        x: 0,
        y: 0,
        tamanhoPincel: 1,
        classeAplicada: ClassePixel.ceu,
        ferramenta: TipoFerramenta.pincel,
        dataHora: DateTime(2026, 6, 29, 10),
      ),
    );
    final processamento = _criarResultadoProcessamento(
      caminhoImagemOriginal: 'imagem_original.png',
      caminhoMascaraAutomatica: 'mascara_automatica.png',
    );

    final resultado = await ferramentaEdicaoService.validarMascaraEditada(
      processamento: processamento,
      mascaraEditada: editada,
      dataHora: DateTime(2026, 6, 29, 10),
    );

    expect(resultado.mascaraFinal.pixelsCeu, 1);
    expect(resultado.mascaraFinal.pixelsNaoCeu, 3);
    expect(resultado.resultadoFinal.pixelsValidos, 4);
    expect(resultado.resultadoFinal.percentualCeu, 25);
    expect(resultado.resultadoFinal.percentualDossel, 75);
  });
}

img.Image _criarMascara(int largura, int altura, ClassePixel classePixel) {
  final mascara = img.Image(width: largura, height: altura, numChannels: 4);
  final (vermelho, verde, azul) = switch (classePixel) {
    ClassePixel.ceu => FerramentaEdicaoService.corCeu,
    ClassePixel.naoCeu => FerramentaEdicaoService.corNaoCeu,
    ClassePixel.invalido => (0, 0, 0),
  };

  for (var y = 0; y < altura; y++) {
    for (var x = 0; x < largura; x++) {
      mascara.setPixelRgba(x, y, vermelho, verde, azul, 255);
    }
  }

  return mascara;
}

ResultadoProcessamentoImagem _criarResultadoProcessamento({
  required String caminhoImagemOriginal,
  required String caminhoMascaraAutomatica,
}) {
  final dataHora = DateTime(2026, 6, 29, 10);
  final imagem = Imagem(
    id: 'imagem-teste',
    analiseId: 'analise-teste',
    caminhoArquivo: caminhoImagemOriginal,
    largura: 2,
    altura: 2,
    formato: 'png',
    origem: OrigemImagem.galeria,
    dataImportacao: dataHora,
  );
  final mascara = Mascara(
    id: 'mascara-automatica',
    analiseId: imagem.analiseId,
    tipo: TipoMascara.automatica,
    caminhoArquivo: caminhoMascaraAutomatica,
    largura: 2,
    altura: 2,
    pixelsCeu: 0,
    pixelsNaoCeu: 4,
    dataCriacao: dataHora,
  );
  final resultado = ResultadoAnalise(
    id: 'resultado-automatico',
    analiseId: imagem.analiseId,
    mascaraId: mascara.id,
    tipoMascara: TipoMascara.automatica,
    pixelsValidos: 4,
    pixelsCeu: 0,
    pixelsNaoCeu: 4,
    percentualCeu: 0,
    percentualDossel: 100,
    dataCalculo: dataHora,
  );

  return ResultadoProcessamentoImagem(
    imagem: imagem,
    mascaraAutomatica: mascara,
    resultadoAutomatico: resultado,
  );
}
