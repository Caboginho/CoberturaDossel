import '../../domain/entities/metadados_analise.dart';
import '../../domain/enums/condicao_ceu.dart';
import '../../domain/enums/tipo_ambiente.dart';
import 'mapper_utils.dart';

/// Converte [MetadadosAnalise] para a tabela `metadados_analise`.
///
/// Metadados ajudam a interpretar limitações de captura e segmentação, sem
/// alterar imagem, máscara ou resultados.
class MetadadosAnaliseMapper {
  const MetadadosAnaliseMapper._();

  static Map<String, dynamic> paraMapa(MetadadosAnalise metadados) {
    return {
      'id': metadados.id,
      'analise_id': metadados.analiseId,
      'local_descricao': metadados.localDescricao,
      'latitude': metadados.latitude,
      'longitude': metadados.longitude,
      'condicao_ceu': metadados.condicaoCeu.name,
      'tipo_ambiente': metadados.tipoAmbiente.name,
      'observacoes_campo': metadados.observacoesCampo,
    };
  }

  static MetadadosAnalise deMapa(Map<String, dynamic> mapa) {
    return MetadadosAnalise(
      id: mapa['id'] as String,
      analiseId: mapa['analise_id'] as String,
      localDescricao: mapa['local_descricao'] as String,
      latitude: (mapa['latitude'] as num?)?.toDouble(),
      longitude: (mapa['longitude'] as num?)?.toDouble(),
      condicaoCeu: enumPorNome(
        CondicaoCeu.values,
        mapa['condicao_ceu'] as String,
      ),
      tipoAmbiente: enumPorNome(
        TipoAmbiente.values,
        mapa['tipo_ambiente'] as String,
      ),
      observacoesCampo: mapa['observacoes_campo'] as String? ?? '',
    );
  }
}
