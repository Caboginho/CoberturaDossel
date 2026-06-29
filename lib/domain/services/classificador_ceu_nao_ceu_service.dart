import '../enums/classe_pixel.dart';
import '../value_objects/parametros_segmentacao.dart';

/// Classificador simples de pixels em céu e não céu.
///
/// A regra considera céu azul quando o canal azul é dominante e o pixel tem
/// brilho suficiente. Também considera céu claro/nublado quando o pixel é muito
/// claro e tem baixa saturação. Essa heurística pode errar em folhas claras,
/// flores claras, céu nublado, reflexos e bordas complexas; por isso o resultado
/// automático é preliminar e deve ser validado pelo pesquisador.
class ClassificadorCeuNaoCeuService {
  const ClassificadorCeuNaoCeuService({
    this.parametros = const ParametrosSegmentacao(),
  });

  final ParametrosSegmentacao parametros;

  ClassePixel classificarRgb({
    required int vermelho,
    required int verde,
    required int azul,
  }) {
    final brilho = calcularBrilho(vermelho: vermelho, verde: verde, azul: azul);
    final saturacao = calcularSaturacaoAproximada(
      vermelho: vermelho,
      verde: verde,
      azul: azul,
    );

    final ceuAzul =
        azul - vermelho >= parametros.diferencaAzulVermelho &&
        azul - verde >= parametros.diferencaAzulVerde &&
        brilho >= parametros.brilhoMinimoCeuAzul;

    final ceuClaro =
        brilho >= parametros.brilhoMinimoCeuClaro &&
        saturacao <= parametros.saturacaoMaximaCeuClaro;

    if (ceuAzul || ceuClaro) {
      return ClassePixel.ceu;
    }

    return ClassePixel.naoCeu;
  }

  double calcularBrilho({
    required int vermelho,
    required int verde,
    required int azul,
  }) {
    return (vermelho + verde + azul) / 3;
  }

  double calcularSaturacaoAproximada({
    required int vermelho,
    required int verde,
    required int azul,
  }) {
    final maior = [vermelho, verde, azul].reduce((a, b) => a > b ? a : b);
    final menor = [vermelho, verde, azul].reduce((a, b) => a < b ? a : b);
    return (maior - menor).toDouble();
  }
}
