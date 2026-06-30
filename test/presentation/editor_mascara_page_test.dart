import 'dart:typed_data';

import 'package:cobertura_dossel/domain/domain.dart';
import 'package:cobertura_dossel/presentation/pages/editor_mascara_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

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

    await _rolarAteTexto(tester, 'Classe ativa');

    expect(find.text('Classe ativa'), findsOneWidget);
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

  testWidgets('exibe botões Navegar e Editar com ajuda para gesto mobile', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EditorMascaraPage()));

    expect(find.text('Navegar'), findsOneWidget);
    expect(find.text('Editar'), findsOneWidget);
    expect(find.textContaining('Em celular, use Navegar'), findsOneWidget);
  });

  testWidgets('exibe modos Sobreposição, Imagem original e Máscara', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EditorMascaraPage()));

    expect(find.text('Sobreposição'), findsOneWidget);
    expect(find.text('Imagem original'), findsOneWidget);
    expect(find.text('Máscara'), findsOneWidget);
    expect(find.textContaining('Opacidade da máscara'), findsOneWidget);
  });

  testWidgets('em modo Navegar, gesto não altera a máscara', (tester) async {
    var quantidadeToques = 0;

    await _abrirAreaEdicao(
      tester,
      modoInteracao: ModoInteracaoEditorMascara.navegar,
      aoTocar: (_) => quantidadeToques++,
    );

    await _tocarAreaEdicao(tester);

    expect(quantidadeToques, 0);
  });

  testWidgets('em modo Editar, toque altera a máscara', (tester) async {
    Offset? posicaoPintada;

    await _abrirAreaEdicao(
      tester,
      modoInteracao: ModoInteracaoEditorMascara.editar,
      aoTocar: (posicao) => posicaoPintada = posicao,
    );

    await _tocarAreaEdicao(tester);

    expect(posicaoPintada, isNotNull);
  });

  testWidgets('classe Céu e tamanho do pincel aparecem no feedback visual', (
    tester,
  ) async {
    await _abrirAreaEdicao(
      tester,
      modoInteracao: ModoInteracaoEditorMascara.editar,
      classeAtiva: ClassePixel.ceu,
      tamanhoPincel: 9,
    );

    expect(find.textContaining('Editando: Céu | 9 px'), findsOneWidget);
  });

  testWidgets('classe Não céu aparece no feedback visual', (tester) async {
    await _abrirAreaEdicao(
      tester,
      modoInteracao: ModoInteracaoEditorMascara.editar,
      classeAtiva: ClassePixel.naoCeu,
      tamanhoPincel: 7,
    );

    expect(find.textContaining('Editando: Não céu | 7 px'), findsOneWidget);
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

Future<void> _abrirAreaEdicao(
  WidgetTester tester, {
  required ModoInteracaoEditorMascara modoInteracao,
  ClassePixel classeAtiva = ClassePixel.ceu,
  double tamanhoPincel = 5,
  ValueChanged<Offset>? aoTocar,
}) async {
  final mascara = img.Image(width: 12, height: 12);
  img.fill(mascara, color: img.ColorRgb8(34, 139, 34));
  final bytes = Uint8List.fromList(img.encodePng(mascara));

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: AreaEdicaoMascara(
            bytesMascara: bytes,
            largura: 12,
            altura: 12,
            modoInteracao: modoInteracao,
            modoVisualizacao: ModoVisualizacaoEditorMascara.sobreposicao,
            opacidadeMascara: 0.60,
            classeAtiva: classeAtiva,
            tamanhoPincel: tamanhoPincel,
            aoIniciarEdicao: (_) {},
            aoContinuarEdicao: (_) {},
            aoFinalizarEdicao: () {},
            aoTocar: aoTocar ?? (_) {},
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _tocarAreaEdicao(WidgetTester tester) async {
  final area = find.descendant(
    of: find.byType(InteractiveViewer),
    matching: find.byType(GestureDetector),
  );
  await tester.tap(area.last);
  await tester.pump();
}
