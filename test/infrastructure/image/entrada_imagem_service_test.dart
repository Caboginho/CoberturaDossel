import 'package:cobertura_dossel/infrastructure/infrastructure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cancelamento de seleção não é tratado como erro', () {
    final resultado = ResultadoEntradaImagem.cancelado();

    expect(resultado.cancelado, isTrue);
    expect(resultado.possuiErro, isFalse);
    expect(resultado.possuiArquivo, isFalse);
  });
}
