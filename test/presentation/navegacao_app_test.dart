import 'package:cobertura_dossel/presentation/app/cobertura_dossel_app.dart';
import 'package:cobertura_dossel/presentation/pages/editor_mascara_page.dart';
import 'package:cobertura_dossel/presentation/pages/escolher_imagem_page.dart';
import 'package:cobertura_dossel/infrastructure/infrastructure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Tela Inicial possui botões Nova análise e Análises salvas', (
    tester,
  ) async {
    await tester.pumpWidget(const CoberturaDosselApp());

    expect(find.text('Nova análise'), findsOneWidget);
    expect(find.text('Análises salvas'), findsOneWidget);
  });

  testWidgets('navegação da Tela Inicial para NovaAnalisePage funciona', (
    tester,
  ) async {
    await tester.pumpWidget(const CoberturaDosselApp());

    await tester.tap(find.text('Nova análise'));
    await tester.pumpAndSettle();

    expect(find.text('Nome da análise'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
  });

  testWidgets('navegação da Tela Inicial para AnalisesSalvasPage funciona', (
    tester,
  ) async {
    await tester.pumpWidget(const CoberturaDosselApp());

    await tester.tap(find.text('Análises salvas'));
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma análise salva ainda'), findsOneWidget);
  });

  testWidgets(
    'Tela EditorMascaraPage informa que a imagem original não será alterada',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: EditorMascaraPage()));

      expect(find.text('Imagem original preservada'), findsOneWidget);
      expect(
        find.textContaining('A imagem original não será alterada'),
        findsOneWidget,
      );
    },
  );

  testWidgets('EscolherImagemPage renderiza botões de galeria e câmera', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EscolherImagemPage()));

    expect(find.text('Importar da galeria'), findsOneWidget);
    expect(find.text('Capturar com câmera'), findsOneWidget);
  });

  testWidgets('EscolherImagemPage trata cancelamento sem quebrar o app', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EscolherImagemPage(
          entradaImagemService: _EntradaImagemCanceladaService(),
        ),
      ),
    );

    await tester.tap(find.text('Importar da galeria'));
    await tester.pumpAndSettle();

    expect(find.text('Seleção de imagem cancelada.'), findsOneWidget);
  });
}

class _EntradaImagemCanceladaService implements EntradaImagemService {
  @override
  Future<ResultadoEntradaImagem> capturarComCamera() async {
    return ResultadoEntradaImagem.cancelado();
  }

  @override
  Future<ResultadoEntradaImagem> importarDaGaleria() async {
    return ResultadoEntradaImagem.cancelado();
  }
}
