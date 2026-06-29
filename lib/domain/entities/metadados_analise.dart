import '../enums/condicao_ceu.dart';
import '../enums/tipo_ambiente.dart';

/// Metadados de campo registrados para contextualizar a análise.
///
/// Esses dados ajudam a interpretar limitações da segmentação, como céu nublado,
/// vegetação clara ou ambientes de borda.
class MetadadosAnalise {
  const MetadadosAnalise({
    required this.id,
    required this.analiseId,
    required this.localDescricao,
    this.latitude,
    this.longitude,
    required this.condicaoCeu,
    required this.tipoAmbiente,
    this.observacoesCampo = '',
  });

  final String id;
  final String analiseId;
  final String localDescricao;
  final double? latitude;
  final double? longitude;
  final CondicaoCeu condicaoCeu;
  final TipoAmbiente tipoAmbiente;
  final String observacoesCampo;
}
