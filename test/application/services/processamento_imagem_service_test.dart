import 'dart:io';

import 'package:cobertura_dossel/application/application.dart';
import 'package:cobertura_dossel/domain/domain.dart';
import 'package:cobertura_dossel/infrastructure/infrastructure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  late Directory diretorioTemporario;
  late ProcessamentoImagemService processamentoImagemService;

  setUp(() async {
    diretorioTemporario = await Directory.systemTemp.createTemp(
      'cobertura_dossel_processamento_',
    );
    processamentoImagemService = ProcessamentoImagemService(
      arquivoService: ArquivoService(diretorioBase: diretorioTemporario),
    );
  });

  tearDown(() async {
    if (await diretorioTemporario.exists()) {
      await diretorioTemporario.delete(recursive: true);
    }
  });

  test(
    'gera máscara automática para imagem 2x2 sem alterar a imagem original',
    () async {
      final arquivoOriginal = await _criarImagemSintetica2x2(
        diretorioTemporario,
      );
      final bytesAntes = await arquivoOriginal.readAsBytes();
      final imagem = Imagem(
        id: 'imagem-teste',
        analiseId: 'analise-teste',
        caminhoArquivo: arquivoOriginal.path,
        largura: 2,
        altura: 2,
        formato: 'png',
        origem: OrigemImagem.galeria,
        dataImportacao: DateTime(2026, 6, 29, 10),
      );

      final resultado = await processamentoImagemService.gerarMascaraAutomatica(
        imagem: imagem,
        mascaraId: 'mascara-teste',
        resultadoId: 'resultado-teste',
        dataHora: DateTime(2026, 6, 29, 10),
      );
      final bytesDepois = await arquivoOriginal.readAsBytes();

      expect(resultado.mascaraAutomatica.pixelsCeu, 2);
      expect(resultado.mascaraAutomatica.pixelsNaoCeu, 2);
      expect(resultado.resultadoAutomatico.percentualCeu, 50);
      expect(resultado.resultadoAutomatico.percentualDossel, 50);
      expect(
        resultado.mascaraAutomatica.caminhoArquivo,
        isNot(imagem.caminhoArquivo),
      );
      expect(
        File(resultado.mascaraAutomatica.caminhoArquivo).existsSync(),
        isTrue,
      );
      expect(
        resultado.mascaraAutomatica.caminhoArquivo.endsWith('.png'),
        isTrue,
      );
      expect(bytesDepois, bytesAntes);
    },
  );
}

Future<File> _criarImagemSintetica2x2(Directory diretorio) async {
  final imagem = img.Image(width: 2, height: 2, numChannels: 4);
  imagem.setPixelRgba(0, 0, 90, 150, 230, 255);
  imagem.setPixelRgba(1, 0, 225, 226, 228, 255);
  imagem.setPixelRgba(0, 1, 40, 150, 50, 255);
  imagem.setPixelRgba(1, 1, 150, 70, 40, 255);

  final arquivo = File(
    '${diretorio.path}${Platform.pathSeparator}original.png',
  );
  return arquivo.writeAsBytes(img.encodePng(imagem));
}
