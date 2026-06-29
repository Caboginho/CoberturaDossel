import 'dart:io';

/// Resultado da tentativa de importar ou capturar uma imagem.
///
/// O cancelamento pelo usuário não é tratado como erro. Isso permite que a tela
/// mostre uma mensagem simples e continue funcionando normalmente.
class ResultadoEntradaImagem {
  const ResultadoEntradaImagem._({
    this.arquivo,
    this.cancelado = false,
    this.mensagemErro,
  });

  factory ResultadoEntradaImagem.sucesso(File arquivo) {
    return ResultadoEntradaImagem._(arquivo: arquivo);
  }

  factory ResultadoEntradaImagem.cancelado() {
    return const ResultadoEntradaImagem._(cancelado: true);
  }

  factory ResultadoEntradaImagem.erro(String mensagemErro) {
    return ResultadoEntradaImagem._(mensagemErro: mensagemErro);
  }

  final File? arquivo;
  final bool cancelado;
  final String? mensagemErro;

  bool get possuiErro => mensagemErro != null;
  bool get possuiArquivo => arquivo != null;
}
