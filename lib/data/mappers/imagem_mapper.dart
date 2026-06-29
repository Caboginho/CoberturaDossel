import '../../domain/entities/imagem.dart';
import '../../domain/enums/origem_imagem.dart';
import 'mapper_utils.dart';

/// Converte [Imagem] para a tabela `imagens`.
///
/// A imagem original é persistida apenas como caminho de arquivo. O mapper não
/// carrega, copia ou altera bytes da imagem.
class ImagemMapper {
  const ImagemMapper._();

  static Map<String, dynamic> paraMapa(Imagem imagem) {
    return {
      'id': imagem.id,
      'analise_id': imagem.analiseId,
      'caminho_arquivo': imagem.caminhoArquivo,
      'largura': imagem.largura,
      'altura': imagem.altura,
      'formato': imagem.formato,
      'origem': imagem.origem.name,
      'data_captura': dataOpcionalParaTexto(imagem.dataCaptura),
      'data_importacao': dataOpcionalParaTexto(imagem.dataImportacao),
    };
  }

  static Imagem deMapa(Map<String, dynamic> mapa) {
    return Imagem(
      id: mapa['id'] as String,
      analiseId: mapa['analise_id'] as String,
      caminhoArquivo: mapa['caminho_arquivo'] as String,
      largura: mapa['largura'] as int,
      altura: mapa['altura'] as int,
      formato: mapa['formato'] as String,
      origem: enumPorNome(OrigemImagem.values, mapa['origem'] as String),
      dataCaptura: textoParaDataOpcional(mapa['data_captura']),
      dataImportacao: textoParaDataOpcional(mapa['data_importacao']),
    );
  }
}
