import '../enums/classe_pixel.dart';
import '../enums/tipo_ferramenta.dart';

/// Registro de uma ação de correção realizada sobre a máscara.
///
/// A edição é tratada como dado científico auditável. Ela documenta a ferramenta
/// usada e a classe aplicada, reforçando que a correção ocorre na máscara e não
/// na imagem original.
class EdicaoMascara {
  const EdicaoMascara({
    required this.id,
    required this.analiseId,
    required this.mascaraId,
    required this.dataHora,
    required this.ferramenta,
    required this.classeAplicada,
    required this.tamanhoPincel,
    this.descricao = '',
  });

  final String id;
  final String analiseId;
  final String mascaraId;
  final DateTime dataHora;
  final TipoFerramenta ferramenta;
  final ClassePixel classeAplicada;
  final double tamanhoPincel;
  final String descricao;
}
