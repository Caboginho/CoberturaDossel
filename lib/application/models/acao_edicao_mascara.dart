import '../../domain/domain.dart';

/// Representa a intenção de uma edição manual aplicada sobre a máscara.
///
/// A ação registra coordenada, classe, ferramenta e tamanho do pincel para
/// facilitar testes, auditoria futura e persistência das edições. Ela não contém
/// dados da imagem original, pois a Fase 7 deve alterar somente a máscara.
class AcaoEdicaoMascara {
  const AcaoEdicaoMascara({
    required this.x,
    required this.y,
    required this.tamanhoPincel,
    required this.classeAplicada,
    required this.ferramenta,
    required this.dataHora,
  }) : assert(tamanhoPincel > 0);

  final int x;
  final int y;
  final int tamanhoPincel;
  final ClassePixel classeAplicada;
  final TipoFerramenta ferramenta;
  final DateTime dataHora;
}
