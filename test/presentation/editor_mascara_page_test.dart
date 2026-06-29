import 'package:cobertura_dossel/presentation/pages/editor_mascara_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exibe aviso de que a imagem original não será alterada', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EditorMascaraPage()));

    expect(find.text('Imagem original preservada'), findsOneWidget);
    expect(
      find.textContaining('A imagem original não será alterada'),
      findsOneWidget,
    );
  });

  testWidgets('exibe controles de Céu e Não céu', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: EditorMascaraPage()));

    expect(find.text('Céu'), findsOneWidget);
    expect(find.text('Não céu'), findsWidgets);
  });

  testWidgets('exibe controle de tamanho do pincel', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: EditorMascaraPage()));

    await _rolarAteTexto(tester, 'Tamanho do pincel');

    expect(find.textContaining('Tamanho do pincel'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
  });

  testWidgets('exibe botão Validar máscara', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: EditorMascaraPage()));

    await _rolarAteTexto(tester, 'Validar máscara');

    expect(find.text('Validar máscara'), findsOneWidget);
  });

  testWidgets('exibe botões Desfazer e Refazer', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: EditorMascaraPage()));

    await _rolarAteTexto(tester, 'Desfazer');

    expect(find.text('Desfazer'), findsOneWidget);
    expect(find.text('Refazer'), findsOneWidget);
  });
}

Future<void> _rolarAteTexto(WidgetTester tester, String texto) async {
  await tester.scrollUntilVisible(
    find.textContaining(texto),
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}
