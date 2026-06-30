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
    this.dadosPerdidosRecuperados = false,
    this.semDadosPerdidos = false,
  });

  factory ResultadoEntradaImagem.sucesso(
    File arquivo, {
    bool dadosPerdidosRecuperados = false,
  }) {
    return ResultadoEntradaImagem._(
      arquivo: arquivo,
      dadosPerdidosRecuperados: dadosPerdidosRecuperados,
    );
  }

  factory ResultadoEntradaImagem.cancelado() {
    return const ResultadoEntradaImagem._(cancelado: true);
  }

  factory ResultadoEntradaImagem.erro(String mensagemErro) {
    return ResultadoEntradaImagem._(mensagemErro: mensagemErro);
  }

  factory ResultadoEntradaImagem.semDadosPerdidos() {
    return const ResultadoEntradaImagem._(semDadosPerdidos: true);
  }

  final File? arquivo;
  final bool cancelado;
  final String? mensagemErro;
  final bool dadosPerdidosRecuperados;
  final bool semDadosPerdidos;

  bool get possuiErro => mensagemErro != null;
  bool get possuiArquivo => arquivo != null;
}
