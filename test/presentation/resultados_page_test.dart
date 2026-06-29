import 'package:cobertura_dossel/application/application.dart';
import 'package:cobertura_dossel/domain/domain.dart';
import 'package:cobertura_dossel/presentation/pages/resultados_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exibe resultado automático preliminar com dados reais', (
    tester,
  ) async {
    await _montarResultadosPage(
      tester,
      argumento: _criarProcessamentoAutomatico(),
    );

    expect(find.text('Resultado automático preliminar'), findsWidgets);
    expect(find.text('Céu visível automático'), findsOneWidget);
    expect(find.text('50.00%'), findsNWidgets(2));
  });

  testWidgets('exibe mensagem quando resultado final ainda não foi validado', (
    tester,
  ) async {
    await _montarResultadosPage(
      tester,
      argumento: _criarProcessamentoAutomatico(),
    );

    expect(
      find.text(ResultadoAnaliseService.mensagemFinalNaoValidado),
      findsOneWidget,
    );
  });

  testWidgets('exibe resultado final quando recebido', (tester) async {
    await _montarResultadosPage(tester, argumento: _criarValidacaoFinal());

    expect(find.text('Resultado final validado'), findsOneWidget);
    expect(find.text('Céu visível final'), findsOneWidget);
    expect(find.text('25.00%'), findsOneWidget);
  });

  testWidgets('exibe diferença percentual entre automático e final', (
    tester,
  ) async {
    await _montarResultadosPage(tester, argumento: _criarValidacaoFinal());

    await _rolarAteTexto(tester, 'Diferença automático/final');

    expect(find.text('Diferença automático/final'), findsOneWidget);
    expect(find.text('25.00 pontos percentuais'), findsOneWidget);
  });

  testWidgets('exibe aviso de que final depende da máscara validada', (
    tester,
  ) async {
    await _montarResultadosPage(tester, argumento: _criarValidacaoFinal());

    expect(
      find.text(ResultadoAnaliseService.mensagemFinalValidado),
      findsOneWidget,
    );
  });

  testWidgets('não exibe valores simulados quando dados reais são enviados', (
    tester,
  ) async {
    await _montarResultadosPage(
      tester,
      argumento: _criarProcessamentoAutomatico(),
    );

    expect(find.text('Valores de exemplo'), findsNothing);
    expect(find.text('48,0%'), findsNothing);
    expect(find.text('52,0%'), findsNothing);
  });
}

Future<void> _montarResultadosPage(
  WidgetTester tester, {
  required Object argumento,
}) {
  return tester.pumpWidget(
    MaterialApp(
      onGenerateRoute: (_) {
        return MaterialPageRoute<void>(
          settings: RouteSettings(arguments: argumento),
          builder: (_) => const ResultadosPage(),
        );
      },
    ),
  );
}

Future<void> _rolarAteTexto(WidgetTester tester, String texto) async {
  await tester.scrollUntilVisible(
    find.text(texto),
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

ResultadoProcessamentoImagem _criarProcessamentoAutomatico() {
  final dataHora = DateTime(2026, 6, 29, 10);
  final imagem = _criarImagem();
  final mascaraAutomatica = Mascara(
    id: 'mascara-automatica',
    analiseId: imagem.analiseId,
    tipo: TipoMascara.automatica,
    caminhoArquivo: 'mascara_automatica.png',
    largura: 10,
    altura: 10,
    pixelsCeu: 5,
    pixelsNaoCeu: 5,
    dataCriacao: dataHora,
  );
  final resultadoAutomatico = ResultadoAnalise(
    id: 'resultado-automatico',
    analiseId: imagem.analiseId,
    mascaraId: mascaraAutomatica.id,
    tipoMascara: TipoMascara.automatica,
    pixelsValidos: 10,
    pixelsCeu: 5,
    pixelsNaoCeu: 5,
    percentualCeu: 50,
    percentualDossel: 50,
    dataCalculo: dataHora,
  );

  return ResultadoProcessamentoImagem(
    imagem: imagem,
    mascaraAutomatica: mascaraAutomatica,
    resultadoAutomatico: resultadoAutomatico,
  );
}

ResultadoValidacaoMascara _criarValidacaoFinal() {
  final processamento = _criarProcessamentoAutomatico();
  final dataHora = DateTime(2026, 6, 29, 11);
  final mascaraFinal = Mascara(
    id: 'mascara-final',
    analiseId: processamento.imagem.analiseId,
    tipo: TipoMascara.finalValidada,
    caminhoArquivo: 'mascara_final.png',
    largura: 10,
    altura: 10,
    pixelsCeu: 2,
    pixelsNaoCeu: 6,
    dataCriacao: dataHora,
  );
  final resultadoFinal = ResultadoAnalise(
    id: 'resultado-final',
    analiseId: processamento.imagem.analiseId,
    mascaraId: mascaraFinal.id,
    tipoMascara: TipoMascara.finalValidada,
    pixelsValidos: 8,
    pixelsCeu: 2,
    pixelsNaoCeu: 6,
    percentualCeu: 25,
    percentualDossel: 75,
    dataCalculo: dataHora,
  );

  return ResultadoValidacaoMascara(
    processamento: processamento,
    mascaraFinal: mascaraFinal,
    resultadoFinal: resultadoFinal,
  );
}

Imagem _criarImagem() {
  return Imagem(
    id: 'imagem-teste',
    analiseId: 'analise-teste',
    caminhoArquivo: 'imagem_original.png',
    largura: 10,
    altura: 10,
    formato: 'png',
    origem: OrigemImagem.galeria,
  );
}
