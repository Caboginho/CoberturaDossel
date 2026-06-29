import 'package:cobertura_dossel/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = CalculoDosselService();

  group('CalculoDosselService', () {
    test(
      'calcula 50% de céu e 50% de dossel quando a máscara tem metade céu e metade não céu',
      () {
        final pixelsValidos = service.calcularPixelsValidos(
          pixelsCeu: 50,
          pixelsNaoCeu: 50,
        );
        final percentualCeu = service.calcularPercentualCeu(
          pixelsCeu: 50,
          pixelsValidos: pixelsValidos,
        );
        final percentualDossel = service.calcularPercentualDossel(
          percentualCeu: percentualCeu,
          pixelsValidos: pixelsValidos,
        );

        expect(pixelsValidos, 100);
        expect(percentualCeu, 50);
        expect(percentualDossel, 50);
      },
    );

    test(
      'calcula 100% de céu e 0% de dossel quando todos os pixels válidos são céu',
      () {
        final pixelsValidos = service.calcularPixelsValidos(
          pixelsCeu: 100,
          pixelsNaoCeu: 0,
        );
        final percentualCeu = service.calcularPercentualCeu(
          pixelsCeu: 100,
          pixelsValidos: pixelsValidos,
        );
        final percentualDossel = service.calcularPercentualDossel(
          percentualCeu: percentualCeu,
          pixelsValidos: pixelsValidos,
        );

        expect(percentualCeu, 100);
        expect(percentualDossel, 0);
      },
    );

    test(
      'calcula 0% de céu e 100% de dossel quando todos os pixels válidos são não céu',
      () {
        final pixelsValidos = service.calcularPixelsValidos(
          pixelsCeu: 0,
          pixelsNaoCeu: 100,
        );
        final percentualCeu = service.calcularPercentualCeu(
          pixelsCeu: 0,
          pixelsValidos: pixelsValidos,
        );
        final percentualDossel = service.calcularPercentualDossel(
          percentualCeu: percentualCeu,
          pixelsValidos: pixelsValidos,
        );

        expect(percentualCeu, 0);
        expect(percentualDossel, 100);
      },
    );

    test('retorna 0% de céu e 0% de dossel quando não há pixels válidos', () {
      final pixelsValidos = service.calcularPixelsValidos(
        pixelsCeu: 0,
        pixelsNaoCeu: 0,
      );
      final percentualCeu = service.calcularPercentualCeu(
        pixelsCeu: 0,
        pixelsValidos: pixelsValidos,
      );
      final percentualDossel = service.calcularPercentualDossel(
        percentualCeu: percentualCeu,
        pixelsValidos: pixelsValidos,
      );

      expect(pixelsValidos, 0);
      expect(percentualCeu, 0);
      expect(percentualDossel, 0);
    });

    test(
      'calcula a diferença absoluta entre resultado automático preliminar e resultado final validado',
      () {
        final diferenca = service.calcularDiferencaPercentual(
          percentualAutomatico: 42.5,
          percentualFinal: 47.0,
        );

        expect(diferenca, 4.5);
      },
    );
  });
}
