import 'package:cobertura_dossel/application/application.dart';
import 'package:cobertura_dossel/domain/domain.dart';
import 'package:cobertura_dossel/presentation/pages/exportacao_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exibe opção CSV', (tester) async {
    await _montarExportacaoPage(tester, argumento: _criarDadosExportacao());

    expect(find.text('CSV'), findsOneWidget);
  });

  testWidgets('exibe opção JSON', (tester) async {
    await _montarExportacaoPage(tester, argumento: _criarDadosExportacao());

    expect(find.text('JSON'), findsOneWidget);
  });

  testWidgets('exibe PDF como funcionalidade futura', (tester) async {
    await _montarExportacaoPage(tester, argumento: _criarDadosExportacao());

    expect(find.text('PDF futuro'), findsOneWidget);
  });

  testWidgets('exibe botão Exportar', (tester) async {
    await _montarExportacaoPage(tester, argumento: _criarDadosExportacao());

    expect(find.text('Exportar'), findsOneWidget);
  });

  testWidgets('mostra mensagem de sucesso ao exportar com serviço fake', (
    tester,
  ) async {
    final exportacaoFake = _ExportacaoFake();

    await _montarExportacaoPage(
      tester,
      argumento: _criarDadosExportacao(),
      exportacaoService: exportacaoFake,
    );

    await tester.tap(find.text('Exportar'));
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();

    expect(find.text('Exportação fake concluída.'), findsOneWidget);
    expect(exportacaoFake.dadosRecebidos, isNotNull);
  });

  testWidgets('mostra mensagem de erro quando faltar dado essencial', (
    tester,
  ) async {
    await _montarExportacaoPage(tester);

    await tester.tap(find.text('Exportar'));
    await tester.pump();

    expect(
      find.text('Não há dados essenciais para exportação.'),
      findsOneWidget,
    );
  });
}

class _ExportacaoFake extends ExportacaoService {
  _ExportacaoFake() : super(registrarExportacaoNoBanco: false);

  DadosExportacaoAnalise? dadosRecebidos;

  @override
  Future<ResultadoExportacao> exportarAnalise(
    DadosExportacaoAnalise dados,
  ) async {
    dadosRecebidos = dados;
    return ResultadoExportacao(
      sucesso: true,
      formato: dados.formatoExportacao,
      caminhoArquivo: '/tmp/exportacao.csv',
      mensagem: 'Exportação fake concluída.',
      dataExportacao: DateTime(2026, 6, 29, 15),
    );
  }
}

Future<void> _montarExportacaoPage(
  WidgetTester tester, {
  Object? argumento,
  ExportacaoService? exportacaoService,
}) {
  return tester.pumpWidget(
    MaterialApp(
      onGenerateRoute: (_) {
        return MaterialPageRoute<void>(
          settings: RouteSettings(arguments: argumento),
          builder: (_) => ExportacaoPage(exportacaoService: exportacaoService),
        );
      },
    ),
  );
}

DadosExportacaoAnalise _criarDadosExportacao() {
  final data = DateTime(2026, 6, 29, 10);
  final analise = Analise(
    id: 'analise-widget-exportacao',
    nome: 'Análise widget exportação',
    dataCriacao: data,
    dataAtualizacao: data,
    versaoAlgoritmo: 'regras_visuais_mvp',
  );
  final imagem = Imagem(
    id: 'imagem-widget-exportacao',
    analiseId: analise.id,
    caminhoArquivo: 'imagem_original_widget.png',
    largura: 10,
    altura: 10,
    formato: 'png',
    origem: OrigemImagem.galeria,
  );
  final mascaraAutomatica = Mascara(
    id: 'mascara-widget-exportacao',
    analiseId: analise.id,
    tipo: TipoMascara.automatica,
    caminhoArquivo: 'mascara_automatica_widget.png',
    largura: 10,
    altura: 10,
    pixelsCeu: 5,
    pixelsNaoCeu: 5,
    dataCriacao: data,
  );
  final resultadoAutomatico = ResultadoAnalise(
    id: 'resultado-widget-exportacao',
    analiseId: analise.id,
    mascaraId: mascaraAutomatica.id,
    tipoMascara: TipoMascara.automatica,
    pixelsValidos: 10,
    pixelsCeu: 5,
    pixelsNaoCeu: 5,
    percentualCeu: 50,
    percentualDossel: 50,
    dataCalculo: data,
  );

  return DadosExportacaoAnalise(
    analise: analise,
    imagem: imagem,
    mascaraAutomatica: mascaraAutomatica,
    resultadoAutomatico: resultadoAutomatico,
    formatoExportacao: FormatoExportacao.csv,
  );
}
