import 'dart:io';

import 'package:cobertura_dossel/application/application.dart';
import 'package:cobertura_dossel/domain/domain.dart';
import 'package:cobertura_dossel/infrastructure/infrastructure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory diretorioTemporario;
  late ImagemService imagemService;

  setUp(() async {
    diretorioTemporario = await Directory.systemTemp.createTemp(
      'cobertura_dossel_imagem_service_',
    );
    imagemService = ImagemService(
      arquivoService: ArquivoService(diretorioBase: diretorioTemporario),
      leitorDimensoes: (_) async => (largura: 100, altura: 80),
    );
  });

  tearDown(() async {
    if (await diretorioTemporario.exists()) {
      await diretorioTemporario.delete(recursive: true);
    }
  });

  test('valida extensão JPG como formato aceito', () {
    expect(imagemService.validarFormatoImagem('foto.JPG'), isTrue);
  });

  test('valida extensão JPEG como formato aceito', () {
    expect(imagemService.validarFormatoImagem('foto.jpeg'), isTrue);
  });

  test('valida extensão PNG como formato aceito', () {
    expect(imagemService.validarFormatoImagem('foto.png'), isTrue);
  });

  test('rejeita extensão inválida', () {
    expect(imagemService.validarFormatoImagem('foto.gif'), isFalse);
  });

  test(
    'registra origem da imagem como CAMERA ao preparar imagem capturada',
    () async {
      final arquivo = await _criarPngTeste(diretorioTemporario, 'captura.png');

      final preparada = await imagemService.prepararImagemOriginal(
        arquivoExterno: arquivo,
        origem: OrigemImagem.camera,
        analiseId: 'analise-1',
        idImagem: 'imagem-camera',
        dataHora: DateTime(2026, 6, 29, 9),
      );

      expect(preparada.imagem.origem, OrigemImagem.camera);
      expect(preparada.imagem.dataCaptura, isNotNull);
      expect(preparada.imagem.dataImportacao, isNull);
    },
  );

  test(
    'registra origem da imagem como GALERIA ao preparar imagem importada',
    () async {
      final arquivo = await _criarPngTeste(diretorioTemporario, 'galeria.png');

      final preparada = await imagemService.prepararImagemOriginal(
        arquivoExterno: arquivo,
        origem: OrigemImagem.galeria,
        analiseId: 'analise-1',
        idImagem: 'imagem-galeria',
        dataHora: DateTime(2026, 6, 29, 9),
      );

      expect(preparada.imagem.origem, OrigemImagem.galeria);
      expect(preparada.imagem.dataCaptura, isNull);
      expect(preparada.imagem.dataImportacao, isNotNull);
    },
  );
}

Future<File> _criarPngTeste(Directory diretorio, String nomeArquivo) async {
  final arquivo = File(
    '${diretorio.path}${Platform.pathSeparator}$nomeArquivo',
  );
  return arquivo.writeAsBytes([1, 2, 3, 4]);
}
