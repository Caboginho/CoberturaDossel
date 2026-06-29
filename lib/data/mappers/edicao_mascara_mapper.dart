import '../../domain/entities/edicao_mascara.dart';
import '../../domain/enums/classe_pixel.dart';
import '../../domain/enums/tipo_ferramenta.dart';
import 'mapper_utils.dart';

/// Converte [EdicaoMascara] para a tabela `edicoes_mascara`.
///
/// A edição é registrada como ação sobre a máscara, preservando a imagem
/// original e permitindo auditoria posterior.
class EdicaoMascaraMapper {
  const EdicaoMascaraMapper._();

  static Map<String, dynamic> paraMapa(EdicaoMascara edicao) {
    return {
      'id': edicao.id,
      'analise_id': edicao.analiseId,
      'mascara_id': edicao.mascaraId,
      'data_hora': dataParaTexto(edicao.dataHora),
      'ferramenta': edicao.ferramenta.name,
      'classe_aplicada': edicao.classeAplicada.name,
      'tamanho_pincel': edicao.tamanhoPincel,
      'descricao': edicao.descricao,
    };
  }

  static EdicaoMascara deMapa(Map<String, dynamic> mapa) {
    return EdicaoMascara(
      id: mapa['id'] as String,
      analiseId: mapa['analise_id'] as String,
      mascaraId: mapa['mascara_id'] as String,
      dataHora: textoParaData(mapa['data_hora']),
      ferramenta: enumPorNome(
        TipoFerramenta.values,
        mapa['ferramenta'] as String,
      ),
      classeAplicada: enumPorNome(
        ClassePixel.values,
        mapa['classe_aplicada'] as String,
      ),
      tamanhoPincel: (mapa['tamanho_pincel'] as num).toDouble(),
      descricao: mapa['descricao'] as String? ?? '',
    );
  }
}
