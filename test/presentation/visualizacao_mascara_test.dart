import 'dart:io';

import 'package:cobertura_dossel/presentation/pages/analise_page.dart';
import 'package:cobertura_dossel/presentation/widgets/controle_visualizacao_mascara.dart';
import 'package:cobertura_dossel/presentation/widgets/imagem_com_mascara.dart';
import 'package:cobertura_dossel/presentation/widgets/modo_visualizacao_mascara.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  group('ModoVisualizacaoMascara', () {
    test('possui modos e rótulos esperados em português', () {
      expect(
        ModoVisualizacaoMascara.values,
        containsAll([
          ModoVisualizacaoMascara.imagemOriginal,
          ModoVisualizacaoMascara.mascaraAutomatica,
          ModoVisualizacaoMascara.sobreposicao,
          ModoVisualizacaoMascara.ladoALado,
        ]),
      );
      expect(ModoVisualizacaoMascara.imagemOriginal.rotulo, 'Imagem original');
      expect(
        ModoVisualizacaoMascara.mascaraAutomatica.rotulo,
        'Máscara automática',
      );
      expect(ModoVisualizacaoMascara.sobreposicao.rotulo, 'Sobreposição');
      expect(ModoVisualizacaoMascara.ladoALado.rotulo, 'Lado a lado');
    });
  });

  group('ImagemComMascara', () {
    late Directory diretorioTemporario;
    late String caminhoImagemOriginal;
    late String caminhoMascaraAutomatica;

    setUp(() async {
      diretorioTemporario = await Directory.systemTemp.createTemp(
        'cobertura_dossel_visualizacao_',
      );
      caminhoImagemOriginal = await _criarImagemPng(
        diretorioTemporario,
        'original.png',
        (x, y) => (20, 120, 220),
      );
      caminhoMascaraAutomatica = await _criarImagemPng(
        diretorioTemporario,
        'mascara.png',
        (x, y) => x == y ? (255, 255, 255) : (0, 0, 0),
      );
    });

    tearDown(() async {
      if (await diretorioTemporario.exists()) {
        await diretorioTemporario.delete(recursive: true);
      }
    });

    testWidgets('renderiza a imagem original no modo imagemOriginal', (
      tester,
    ) async {
      await _montarImagemComMascara(
        tester,
        caminhoImagemOriginal: caminhoImagemOriginal,
        caminhoMascaraAutomatica: caminhoMascaraAutomatica,
        modo: ModoVisualizacaoMascara.imagemOriginal,
      );

      expect(find.byKey(ImagemComMascara.chaveImagemOriginal), findsOneWidget);
    });

    testWidgets('renderiza a máscara no modo mascaraAutomatica', (
      tester,
    ) async {
      await _montarImagemComMascara(
        tester,
        caminhoImagemOriginal: caminhoImagemOriginal,
        caminhoMascaraAutomatica: caminhoMascaraAutomatica,
        modo: ModoVisualizacaoMascara.mascaraAutomatica,
      );

      expect(
        find.byKey(ImagemComMascara.chaveMascaraAutomatica),
        findsOneWidget,
      );
    });

    testWidgets('renderiza a sobreposição no modo sobreposicao', (
      tester,
    ) async {
      await _montarImagemComMascara(
        tester,
        caminhoImagemOriginal: caminhoImagemOriginal,
        caminhoMascaraAutomatica: caminhoMascaraAutomatica,
        modo: ModoVisualizacaoMascara.sobreposicao,
      );

      expect(find.byKey(ImagemComMascara.chaveSobreposicao), findsOneWidget);
      expect(find.byKey(ImagemComMascara.chaveImagemOriginal), findsOneWidget);
      expect(
        find.byKey(ImagemComMascara.chaveMascaraAutomatica),
        findsOneWidget,
      );
    });
  });

  group('ControleVisualizacaoMascara', () {
    testWidgets('exibe rótulos e aviso de máscara ainda não validada', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControleVisualizacaoMascara(
              modoSelecionado: ModoVisualizacaoMascara.sobreposicao,
              opacidadeMascara: 0.55,
              aoAlterarModo: (_) {},
              aoAlterarOpacidade: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Imagem original'), findsOneWidget);
      expect(find.text('Máscara automática'), findsOneWidget);
      expect(find.text('Sobreposição'), findsOneWidget);
      expect(find.text('Lado a lado'), findsOneWidget);
      expect(
        find.text('Máscara automática ainda não validada'),
        findsOneWidget,
      );
    });
  });

  group('AnalisePage', () {
    testWidgets('exibe aviso de resultado automático ainda não validado', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AnalisePage()));

      expect(
        find.text('Resultado automático inicial — ainda não validado.'),
        findsOneWidget,
      );
    });

    testWidgets('exibe aviso de preservação da imagem original', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AnalisePage()));

      expect(find.text('Imagem original preservada'), findsOneWidget);
      expect(
        find.textContaining(
          'A imagem original é preservada. A revisão manual ocorre apenas '
          'sobre a máscara.',
        ),
        findsOneWidget,
      );
    });
  });
}

Future<void> _montarImagemComMascara(
  WidgetTester tester, {
  required String caminhoImagemOriginal,
  required String caminhoMascaraAutomatica,
  required ModoVisualizacaoMascara modo,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ImagemComMascara(
          caminhoImagemOriginal: caminhoImagemOriginal,
          caminhoMascaraAutomatica: caminhoMascaraAutomatica,
          modo: modo,
        ),
      ),
    ),
  );
}

Future<String> _criarImagemPng(
  Directory diretorio,
  String nomeArquivo,
  (int, int, int) Function(int x, int y) corPixel,
) async {
  final imagem = img.Image(width: 2, height: 2, numChannels: 4);
  for (var y = 0; y < imagem.height; y++) {
    for (var x = 0; x < imagem.width; x++) {
      final (vermelho, verde, azul) = corPixel(x, y);
      imagem.setPixelRgba(x, y, vermelho, verde, azul, 255);
    }
  }

  final arquivo = File(
    '${diretorio.path}${Platform.pathSeparator}$nomeArquivo',
  );
  await arquivo.writeAsBytes(img.encodePng(imagem));
  return arquivo.path;
}
