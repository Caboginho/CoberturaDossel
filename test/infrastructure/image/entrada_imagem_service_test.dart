import 'dart:io';

import 'package:cobertura_dossel/infrastructure/infrastructure.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  test('cancelamento de seleção não é tratado como erro', () {
    final resultado = ResultadoEntradaImagem.cancelado();

    expect(resultado.cancelado, isTrue);
    expect(resultado.possuiErro, isFalse);
    expect(resultado.possuiArquivo, isFalse);
  });

  test('retrieveLostData vazio não é tratado como erro', () async {
    final service = ImagePickerEntradaImagemService(
      recuperarDadosPerdidos: () async => LostDataResponse.empty(),
    );

    final resultado = await service.recuperarImagemPerdida();

    expect(resultado.semDadosPerdidos, isTrue);
    expect(resultado.possuiErro, isFalse);
    expect(resultado.possuiArquivo, isFalse);
  });

  test('retrieveLostData com imagem retorna arquivo recuperado', () async {
    final arquivo = File('${Directory.systemTemp.path}/foto_recuperada.jpg');
    final service = ImagePickerEntradaImagemService(
      recuperarDadosPerdidos: () async =>
          LostDataResponse(file: XFile(arquivo.path), type: RetrieveType.image),
    );

    final resultado = await service.recuperarImagemPerdida();

    expect(resultado.possuiArquivo, isTrue);
    expect(resultado.dadosPerdidosRecuperados, isTrue);
    expect(resultado.arquivo!.path, arquivo.path);
  });

  test('retrieveLostData com erro retorna mensagem compreensível', () async {
    final service = ImagePickerEntradaImagemService(
      recuperarDadosPerdidos: () async => LostDataResponse(
        exception: PlatformException(
          code: 'camera_error',
          message: 'Falha simulada na câmera',
        ),
        type: RetrieveType.image,
      ),
    );

    final resultado = await service.recuperarImagemPerdida();

    expect(resultado.possuiErro, isTrue);
    expect(
      resultado.mensagemErro,
      contains('Não foi possível recuperar a imagem capturada'),
    );
  });
}
