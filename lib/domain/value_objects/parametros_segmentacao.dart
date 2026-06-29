/// Parâmetros heurísticos usados na segmentação automática inicial.
///
/// Estes valores são ajustáveis e não representam modelo treinado ou
/// inteligência artificial. Eles apenas orientam uma primeira classificação por
/// regras visuais, suficiente para produzir uma máscara preliminar revisável.
class ParametrosSegmentacao {
  const ParametrosSegmentacao({
    this.brilhoMinimoCeuAzul = 90,
    this.diferencaAzulVermelho = 25,
    this.diferencaAzulVerde = 10,
    this.brilhoMinimoCeuClaro = 200,
    this.saturacaoMaximaCeuClaro = 35,
  });

  /// Brilho mínimo para considerar um pixel azulado como céu.
  final double brilhoMinimoCeuAzul;

  /// Diferença mínima entre azul e vermelho para céu azul.
  final double diferencaAzulVermelho;

  /// Diferença mínima entre azul e verde para céu azul.
  final double diferencaAzulVerde;

  /// Brilho mínimo para considerar céu claro ou nublado.
  final double brilhoMinimoCeuClaro;

  /// Saturação máxima para céu claro ou nublado de baixa cor.
  final double saturacaoMaximaCeuClaro;
}
