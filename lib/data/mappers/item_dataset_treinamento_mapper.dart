import '../../domain/entities/item_dataset_treinamento.dart';
import 'mapper_utils.dart';

/// Converte [ItemDatasetTreinamento] para `itens_dataset_treinamento`.
///
/// A estrutura prepara evolução futura com dados autorizados, mas não ativa
/// inteligência artificial no MVP.
class ItemDatasetTreinamentoMapper {
  const ItemDatasetTreinamentoMapper._();

  static Map<String, dynamic> paraMapa(ItemDatasetTreinamento item) {
    return {
      'id': item.id,
      'analise_id': item.analiseId,
      'caminho_imagem_original': item.caminhoImagemOriginal,
      'caminho_mascara_automatica': item.caminhoMascaraAutomatica,
      'caminho_mascara_final': item.caminhoMascaraFinal,
      'versao_algoritmo': item.versaoAlgoritmo,
      'diferenca_percentual': item.diferencaPercentual,
      'autorizado': boolParaInteiro(item.autorizado),
      'data_registro': dataParaTexto(item.dataRegistro),
    };
  }

  static ItemDatasetTreinamento deMapa(Map<String, dynamic> mapa) {
    return ItemDatasetTreinamento(
      id: mapa['id'] as String,
      analiseId: mapa['analise_id'] as String,
      caminhoImagemOriginal: mapa['caminho_imagem_original'] as String,
      caminhoMascaraAutomatica: mapa['caminho_mascara_automatica'] as String,
      caminhoMascaraFinal: mapa['caminho_mascara_final'] as String,
      versaoAlgoritmo: mapa['versao_algoritmo'] as String? ?? '',
      diferencaPercentual: (mapa['diferenca_percentual'] as num?)?.toDouble(),
      autorizado: inteiroParaBool(mapa['autorizado']),
      dataRegistro: textoParaData(mapa['data_registro']),
    );
  }
}
