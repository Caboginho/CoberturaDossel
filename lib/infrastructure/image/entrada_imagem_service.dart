import 'dart:io';

import 'package:image_picker/image_picker.dart';

import 'resultado_entrada_imagem.dart';

/// Abstração para entrada de imagem por galeria ou câmera.
///
/// A tela depende desta abstração para facilitar testes e evitar chamada direta
/// ao plugin `image_picker` na camada de apresentação.
abstract class EntradaImagemService {
  Future<ResultadoEntradaImagem> importarDaGaleria();

  Future<ResultadoEntradaImagem> capturarComCamera();
}

/// Implementação de entrada de imagem usando o plugin `image_picker`.
class ImagePickerEntradaImagemService implements EntradaImagemService {
  ImagePickerEntradaImagemService({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  @override
  Future<ResultadoEntradaImagem> importarDaGaleria() {
    return _obterImagem(ImageSource.gallery);
  }

  @override
  Future<ResultadoEntradaImagem> capturarComCamera() {
    return _obterImagem(ImageSource.camera);
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
