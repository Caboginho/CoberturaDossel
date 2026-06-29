import 'package:cobertura_dossel/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const classificador = ClassificadorCeuNaoCeuService();

  test('pixel azul claro deve ser classificado como céu', () {
    final classe = classificador.classificarRgb(
      vermelho: 90,
      verde: 150,
      azul: 230,
    );

    expect(classe, ClassePixel.ceu);
  });

  test('pixel verde deve ser classificado como não céu', () {
    final classe = classificador.classificarRgb(
      vermelho: 40,
      verde: 150,
      azul: 50,
    );

    expect(classe, ClassePixel.naoCeu);
  });

  test('pixel escuro deve ser classificado como não céu', () {
    final classe = classificador.classificarRgb(
      vermelho: 20,
      verde: 20,
      azul: 30,
    );

    expect(classe, ClassePixel.naoCeu);
  });

  test(
    'pixel branco ou cinza claro de baixa saturação deve ser classificado como céu',
    () {
      final classe = classificador.classificarRgb(
        vermelho: 225,
        verde: 226,
        azul: 228,
      );

      expect(classe, ClassePixel.ceu);
    },
  );

  test('pixel vermelho ou marrom deve ser classificado como não céu', () {
    final classe = classificador.classificarRgb(
      vermelho: 150,
      verde: 70,
      azul: 40,
    );

    expect(classe, ClassePixel.naoCeu);
  });
}
