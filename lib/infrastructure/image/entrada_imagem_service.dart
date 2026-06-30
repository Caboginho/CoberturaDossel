import 'dart:io';

import 'package:image_picker/image_picker.dart';

import 'resultado_entrada_imagem.dart';

/// Abstração para entrada de imagem por galeria, câmera e recuperação Android.
///
/// A tela depende desta abstração para facilitar testes e evitar chamada direta
/// ao plugin `image_picker` na camada de apresentação. A recuperação de dados
/// perdidos é importante em Android, onde a activity pode ser destruída após a
/// abertura da câmera.
abstract class EntradaImagemService {
  Future<ResultadoEntradaImagem> importarDaGaleria();

  Future<ResultadoEntradaImagem> capturarComCamera();

  Future<ResultadoEntradaImagem> recuperarImagemPerdida();
}

typedef RecuperarDadosPerdidosImagePicker = Future<LostDataResponse> Function();

/// Implementação de entrada de imagem usando o plugin `image_picker`.
class ImagePickerEntradaImagemService implements EntradaImagemService {
  ImagePickerEntradaImagemService({
    ImagePicker? imagePicker,
    RecuperarDadosPerdidosImagePicker? recuperarDadosPerdidos,
  }) : _imagePicker = imagePicker ?? ImagePicker(),
       _recuperarDadosPerdidos = recuperarDadosPerdidos;

  final ImagePicker _imagePicker;
  final RecuperarDadosPerdidosImagePicker? _recuperarDadosPerdidos;

  @override
  Future<ResultadoEntradaImagem> importarDaGaleria() {
    return _obterImagem(ImageSource.gallery);
  }

  @override
  Future<ResultadoEntradaImagem> capturarComCamera() {
    return _obterImagem(ImageSource.camera);
  }

  @override
  Future<ResultadoEntradaImagem> recuperarImagemPerdida() async {
    try {
      final recuperar =
          _recuperarDadosPerdidos ?? _imagePicker.retrieveLostData;
      final resposta = await recuperar();

      if (resposta.isEmpty) {
        return ResultadoEntradaImagem.semDadosPerdidos();
      }

      final excecao = resposta.exception;
      if (excecao != null) {
        return ResultadoEntradaImagem.erro(
          'Não foi possível recuperar a imagem capturada. Detalhe: ${excecao.message ?? excecao.code}',
        );
      }

      final arquivo = resposta.file ?? resposta.files?.firstOrNull;
      if (arquivo == null) {
        return ResultadoEntradaImagem.erro(
          'Não foi possível recuperar a imagem capturada.',
        );
      }

      return ResultadoEntradaImagem.sucesso(
        File(arquivo.path),
        dadosPerdidosRecuperados: true,
      );
    } on UnimplementedError {
      return ResultadoEntradaImagem.semDadosPerdidos();
    } on Exception catch (erro) {
      return ResultadoEntradaImagem.erro(
        'Não foi possível recuperar a imagem capturada. Detalhe: $erro',
      );
    }
  }

  Future<ResultadoEntradaImagem> _obterImagem(ImageSource origem) async {
    try {
      final imagem = await _imagePicker.pickImage(source: origem);

      if (imagem == null) {
        return ResultadoEntradaImagem.cancelado();
      }

      return ResultadoEntradaImagem.sucesso(File(imagem.path));
    } on Exception catch (erro) {
      return ResultadoEntradaImagem.erro(
        'Não foi possível acessar a imagem. Verifique as permissões do aplicativo. Detalhe: $erro',
      );
    }
  }
}
