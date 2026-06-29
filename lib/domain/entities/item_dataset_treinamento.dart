/// Item opcional para evolução futura com conjunto de treinamento.
///
/// A Fase 2 apenas modela e prepara persistência para esta entidade. O MVP
/// atual não implementa inteligência artificial, mas mantém a estrutura para
/// registrar pares imagem/máscara que tenham autorização explícita de uso futuro.
class ItemDatasetTreinamento {
  const ItemDatasetTreinamento({
    required this.id,
    required this.analiseId,
    required this.caminhoImagemOriginal,
    required this.caminhoMascaraAutomatica,
    required this.caminhoMascaraFinal,
    this.versaoAlgoritmo = '',
    this.diferencaPercentual,
    this.autorizado = false,
    required this.dataRegistro,
  });

  final String id;
  final String analiseId;

  /// Caminho da imagem original preservada, sem alteração pelo sistema.
  final String caminhoImagemOriginal;

  final String caminhoMascaraAutomatica;
  final String caminhoMascaraFinal;
  final String versaoAlgoritmo;
  final double? diferencaPercentual;
  final bool autorizado;
  final DateTime dataRegistro;
}
