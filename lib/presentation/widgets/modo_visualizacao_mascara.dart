/// Modos disponíveis para visualizar imagem original e máscara automática.
///
/// A Fase 6 apenas alterna a visualização. Nenhum modo edita a imagem original
/// ou altera o arquivo da máscara.
enum ModoVisualizacaoMascara {
  imagemOriginal,
  mascaraAutomatica,
  sobreposicao,
  ladoALado,
}

extension ModoVisualizacaoMascaraRotulo on ModoVisualizacaoMascara {
  String get rotulo {
    return switch (this) {
      ModoVisualizacaoMascara.imagemOriginal => 'Imagem original',
      ModoVisualizacaoMascara.mascaraAutomatica => 'Máscara automática',
      ModoVisualizacaoMascara.sobreposicao => 'Sobreposição',
      ModoVisualizacaoMascara.ladoALado => 'Lado a lado',
    };
  }
}
