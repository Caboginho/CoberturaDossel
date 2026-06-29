import 'dart:io';

import 'package:image/image.dart' as img;

import '../../domain/domain.dart';
import '../../infrastructure/storage/arquivo_service.dart';
import 'resultado_processamento_imagem.dart';

/// Serviço de aplicação para gerar a máscara automática inicial.
///
/// A imagem original é apenas lida. A saída do processamento é sempre uma
/// máscara PNG separada, permitindo que a imagem original permaneça preservada.
/// Esta fase não usa inteligência artificial nem mede LAI diretamente.
class ProcessamentoImagemService {
  ProcessamentoImagemService({
    ClassificadorCeuNaoCeuService? classificador,
    CalculoDosselService? calculoDosselService,
    ArquivoService? arquivoService,
  }) : _classificador = classificador ?? const ClassificadorCeuNaoCeuService(),
       _calculoDosselService =
           calculoDosselService ?? const CalculoDosselService(),
       _arquivoService = arquivoService ?? ArquivoService();

  final ClassificadorCeuNaoCeuService _classificador;
  final CalculoDosselService _calculoDosselService;
  final ArquivoService _arquivoService;

  /// Gera máscara automática céu/não céu e resultado preliminar.
  ///
  /// Pixels classificados como céu são pintados de azul na máscara. Pixels
  /// classificados como não céu são pintados de verde. O arquivo original não é
  /// alterado em nenhum ponto do processamento.
  Future<ResultadoProcessamentoImagem> gerarMascaraAutomatica({
    required Imagem imagem,
    String? mascaraId,
    String? resultadoId,
    DateTime? dataHora,
  }) async {
    final arquivoOriginal = File(imagem.caminhoArquivo);
    final bytesOriginaisAntes = await arquivoOriginal.readAsBytes();
    final imagemDecodificada = img.decodeImage(bytesOriginaisAntes);

    if (imagemDecodificada == null) {
      throw const FormatException('Não foi possível decodificar a imagem.');
    }

    final mascaraImagem = img.Image(
      width: imagemDecodificada.width,
      height: imagemDecodificada.height,
      numChannels: 4,
    );
    var pixelsCeu = 0;
    var pixelsNaoCeu = 0;

    for (var y = 0; y < imagemDecodificada.height; y++) {
      for (var x = 0; x < imagemDecodificada.width; x++) {
        final pixel = imagemDecodificada.getPixel(x, y);
        final classe = _classificador.classificarRgb(
          vermelho: pixel.r.toInt(),
          verde: pixel.g.toInt(),
          azul: pixel.b.toInt(),
        );

        if (classe == ClassePixel.ceu) {
          pixelsCeu++;
          mascaraImagem.setPixelRgba(x, y, 0, 102, 255, 255);
        } else {
          pixelsNaoCeu++;
          mascaraImagem.setPixelRgba(x, y, 34, 139, 34, 255);
        }
      }
    }

    final agora = dataHora ?? DateTime.now();
    final idMascara = mascaraId ?? 'mascara_${agora.microsecondsSinceEpoch}';
    final caminhoMascara = await _arquivoService
        .gerarCaminhoSeguroMascaraAutomatica(
          imagemId: imagem.id,
          id: idMascara,
          dataHora: agora,
        );
    await File(caminhoMascara).writeAsBytes(img.encodePng(mascaraImagem));

    final bytesOriginaisDepois = await arquivoOriginal.readAsBytes();
    if (!_listasIguais(bytesOriginaisAntes, bytesOriginaisDepois)) {
      throw StateError(
        'A imagem original foi alterada durante o processamento.',
      );
    }

    final pixelsValidos = _calculoDosselService.calcularPixelsValidos(
      pixelsCeu: pixelsCeu,
      pixelsNaoCeu: pixelsNaoCeu,
    );
    final percentualCeu = _calculoDosselService.calcularPercentualCeu(
      pixelsCeu: pixelsCeu,
      pixelsValidos: pixelsValidos,
    );
    final percentualDossel = _calculoDosselService.calcularPercentualDossel(
      percentualCeu: percentualCeu,
      pixelsValidos: pixelsValidos,
    );

    final mascara = Mascara(
      id: idMascara,
      analiseId: imagem.analiseId,
      tipo: TipoMascara.automatica,
      caminhoArquivo: caminhoMascara,
      largura: imagemDecodificada.width,
      altura: imagemDecodificada.height,
      pixelsCeu: pixelsCeu,
      pixelsNaoCeu: pixelsNaoCeu,
      pixelsInvalidos: 0,
      origemMascara: 'segmentacao_regras_fase_5',
      dataCriacao: agora,
    );

    final resultado = ResultadoAnalise(
      id: resultadoId ?? 'resultado_${agora.microsecondsSinceEpoch}',
      analiseId: imagem.analiseId,
      mascaraId: mascara.id,
      tipoMascara: TipoMascara.automatica,
      pixelsValidos: pixelsValidos,
      pixelsCeu: pixelsCeu,
      pixelsNaoCeu: pixelsNaoCeu,
      percentualCeu: percentualCeu,
      percentualDossel: percentualDossel,
      dataCalculo: agora,
    );

    return ResultadoProcessamentoImagem(
      imagem: imagem,
      mascaraAutomatica: mascara,
      resultadoAutomatico: resultado,
    );
  }

  bool _listasIguais(List<int> primeira, List<int> segunda) {
    if (primeira.length != segunda.length) {
      return false;
    }

    for (var indice = 0; indice < primeira.length; indice++) {
      if (primeira[indice] != segunda[indice]) {
        return false;
      }
    }

    return true;
  }
}
