import '../../domain/entities/mascara.dart';
import '../../domain/enums/tipo_mascara.dart';
import 'mapper_utils.dart';

/// Converte [Mascara] para a tabela `mascaras`.
///
/// A máscara é armazenada como arquivo separado. O banco guarda o caminho e as
/// contagens necessárias para cálculo e auditoria.
class MascaraMapper {
  const MascaraMapper._();

  static Map<String, dynamic> paraMapa(Mascara mascara) {
    return {
      'id': mascara.id,
      'analise_id': mascara.analiseId,
      'tipo_mascara': mascara.tipo.name,
      'caminho_arquivo': mascara.caminhoArquivo,
      'largura': mascara.largura,
      'altura': mascara.altura,
      'pixels_ceu': mascara.pixelsCeu,
      'pixels_nao_ceu': mascara.pixelsNaoCeu,
      'pixels_invalidos': mascara.pixelsInvalidos,
      'origem_mascara': mascara.origemMascara,
      'data_criacao': dataParaTexto(mascara.dataCriacao),
    };
  }

  static Mascara deMapa(Map<String, dynamic> mapa) {
    return Mascara(
      id: mapa['id'] as String,
      analiseId: mapa['analise_id'] as String,
      tipo: enumPorNome(TipoMascara.values, mapa['tipo_mascara'] as String),
      caminhoArquivo: mapa['caminho_arquivo'] as String,
      largura: mapa['largura'] as int,
      altura: mapa['altura'] as int,
      pixelsCeu: mapa['pixels_ceu'] as int,
      pixelsNaoCeu: mapa['pixels_nao_ceu'] as int,
      pixelsInvalidos: mapa['pixels_invalidos'] as int,
      origemMascara: mapa['origem_mascara'] as String? ?? '',
      dataCriacao: textoParaData(mapa['data_criacao']),
    );
  }
}
