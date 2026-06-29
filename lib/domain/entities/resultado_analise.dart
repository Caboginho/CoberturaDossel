import '../enums/tipo_mascara.dart';

/// Resultado percentual calculado a partir de uma máscara específica.
///
/// O vínculo com [mascaraId] e [tipoMascara] preserva a rastreabilidade entre
/// resultado automático preliminar e resultado final validado pelo pesquisador.
class ResultadoAnalise {
  const ResultadoAnalise({
    required this.id,
    required this.analiseId,
    required this.mascaraId,
    required this.tipoMascara,
    required this.pixelsValidos,
    required this.pixelsCeu,
    required this.pixelsNaoCeu,
    required this.percentualCeu,
    required this.percentualDossel,
    this.diferencaPercentual,
    required this.dataCalculo,
  }) : assert(pixelsValidos >= 0),
       assert(pixelsCeu >= 0),
       assert(pixelsNaoCeu >= 0),
       assert(percentualCeu >= 0 && percentualCeu <= 100),
       assert(percentualDossel >= 0 && percentualDossel <= 100);

  final String id;
  final String analiseId;
  final String mascaraId;

  /// Tipo da máscara usada no cálculo deste resultado.
  final TipoMascara tipoMascara;

  final int pixelsValidos;
  final int pixelsCeu;
  final int pixelsNaoCeu;
  final double percentualCeu;
  final double percentualDossel;

  /// Diferença em relação a outro resultado, normalmente automático versus final.
  final double? diferencaPercentual;

  final DateTime dataCalculo;
}
