import 'dart:io';

import 'package:cobertura_dossel/infrastructure/infrastructure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory diretorioTemporario;
  late ArquivoService arquivoService;

  setUp(() async {
    diretorioTemporario = await Directory.systemTemp.createTemp(
      'cobertura_dossel_arquivo_service_',
    );
    arquivoService = ArquivoService(diretorioBase: diretorioTemporario);
  });

  tearDown(() async {
    if (await diretorioTemporario.exists()) {
      await diretorioTemporario.delete(recursive: true);
    }
  });

  test('gera caminho interno seguro para imagem original', () async {
    final caminho = await arquivoService.gerarCaminhoSeguroImagemOriginal(
      'Minha Imagem de Teste.JPG',
      id: 'imagem-123',
    );

    expect(caminho, contains('imagens_originais'));
    expect(p.basename(caminho), 'minha_imagem_de_teste_imagem-123.jpg');
  });

  test(
    'gera caminho de máscara automática em diretório separado e com extensão png',
    () async {
      final caminho = await arquivoService.gerarCaminhoSeguroMascaraAutomatica(
        imagemId: 'imagem-123',
        id: 'mascara-123',
      );

      expect(caminho, contains('mascaras'));
      expect(caminho, isNot(contains('imagens_originais')));
      expect(p.extension(caminho), '.png');
      expect(
        p.basename(caminho),
        'mascara_automatica_imagem-123_mascara-123.png',
      );
    },
  );
}
