import '../../domain/entities/resultado_analise.dart';
import '../../domain/enums/tipo_mascara.dart';
import 'mapper_utils.dart';

/// Converte [ResultadoAnalise] para a tabela `resultados_analise`.
///
/// O campo `tipo_resultado` recebe o tipo de máscara usado no cálculo, mantendo
/// a separação entre resultado automático preliminar e resultado final validado.
class ResultadoAnaliseMapper {
  const ResultadoAnaliseMapper._();

  static Map<String, dynamic> paraMapa(ResultadoAnalise resultado) {
    return {
      'id': resultado.id,
      'analise_id': resultado.analiseId,
      'mascara_id': resultado.mascaraId,
      'tipo_resultado': resultado.tipoMascara.name,
      'pixels_validos': resultado.pixelsValidos,
      'pixels_ceu': resultado.pixelsCeu,
      'pixels_nao_ceu': resultado.pixelsNaoCeu,
      'percentual_ceu': resultado.percentualCeu,
      'percentual_dossel': resultado.percentualDossel,
      'diferenca_percentual': resultado.diferencaPercentual,
      'data_calculo': dataParaTexto(resultado.dataCalculo),
    };
  }

  static ResultadoAnalise deMapa(Map<String, dynamic> mapa) {
    return ResultadoAnalise(
      id: mapa['id'] as String,
      analiseId: mapa['analise_id'] as String,
      mascaraId: mapa['mascara_id'] as String,
      tipoMascara: enumPorNome(
        TipoMascara.values,
        mapa['tipo_resultado'] as String,
      ),
      pixelsValidos: mapa['pixels_validos'] as int,
      pixelsCeu: mapa['pixels_ceu'] as int,
      pixelsNaoCeu: mapa['pixels_nao_ceu'] as int,
      percentualCeu: (mapa['percentual_ceu'] as num).toDouble(),
      percentualDossel: (mapa['percentual_dossel'] as num).toDouble(),
      diferencaPercentual: (mapa['diferenca_percentual'] as num?)?.toDouble(),
      dataCalculo: textoParaData(mapa['data_calculo']),
    );
  }
}
