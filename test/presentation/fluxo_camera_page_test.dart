import 'dart:io';

import 'package:cobertura_dossel/application/application.dart';
import 'package:cobertura_dossel/domain/domain.dart';
import 'package:cobertura_dossel/infrastructure/infrastructure.dart';
import 'package:cobertura_dossel/presentation/pages/escolher_imagem_page.dart';
import 'package:cobertura_dossel/presentation/pages/nova_analise_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory diretorioTemporario;
  late AnaliseEmAndamentoService analiseEmAndamentoService;

  setUp(() async {
    diretorioTemporario = await Directory.systemTemp.createTemp(
      'cobertura_dossel_fluxo_camera_',
    );
    analiseEmAndamentoService = AnaliseEmAndamentoService();
  });

  tearDown(() async {
    if (await diretorioTemporario.exists()) {
      await diretorioTemporario.delete(recursive: true);
    }
  });

  testWidgets('NovaAnalisePage recupera dados preservados do fluxo', (
    tester,
  ) async {
    analiseEmAndamentoService.guardarAnalise(_criarAnalise());

    await tester.pumpWidget(
      MaterialApp(
        home: NovaAnalisePage(
          analiseEmAndamentoService: analiseEmAndamentoService,
        ),
      ),
    );

    expect(find.text('Teste de campo Moto G15'), findsOneWidget);
    expect(find.text('Observação preservada'), findsOneWidget);
  });

  testWidgets(
    'EscolherImagemPage recupera imagem perdida e preserva analise em andamento',
    (tester) async {
      final arquivoCamera = File(
        '${diretorioTemporario.path}${Platform.pathSeparator}captura_camera.png',
      );
      analiseEmAndamentoService.guardarAnalise(_criarAnalise());

      await tester.pumpWidget(
        MaterialApp(
          home: EscolherImagemPage(
            entradaImagemService: _EntradaImagemRecuperadaService(
              arquivoRecuperado: arquivoCamera,
            ),
            imagemService: _ImagemServiceFake(),
            analiseEmAndamentoService: analiseEmAndamentoService,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Análise em andamento preservada'), findsOneWidget);
      expect(find.textContaining('Teste de campo Moto G15'), findsOneWidget);
      expect(
        find.text(
          'Imagem recuperada após retorno da câmera. Os dados da análise foram preservados.',
        ),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text('Continuar para processamento'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(find.text('Continuar para processamento'), findsOneWidget);
      expect(find.text('Origem: CAMERA'), findsOneWidget);
    },
  );
}

Analise _criarAnalise() {
  return Analise(
    id: 'analise-moto-g15',
    nome: 'Teste de campo Moto G15',
    dataCriacao: DateTime(2026, 6, 29, 10),
    dataAtualizacao: DateTime(2026, 6, 29, 10),
    observacoes: 'Observação preservada',
    versaoAlgoritmo: 'regras_visuais_mvp',
  );
}

class _EntradaImagemRecuperadaService implements EntradaImagemService {
  const _EntradaImagemRecuperadaService({required this.arquivoRecuperado});

  final File arquivoRecuperado;

  @override
  Future<ResultadoEntradaImagem> capturarComCamera() async {
    return ResultadoEntradaImagem.cancelado();
  }

  @override
  Future<ResultadoEntradaImagem> importarDaGaleria() async {
    return ResultadoEntradaImagem.cancelado();
  }

  @override
  Future<ResultadoEntradaImagem> recuperarImagemPerdida() async {
    return ResultadoEntradaImagem.sucesso(
      arquivoRecuperado,
      dadosPerdidosRecuperados: true,
    );
  }
}

class _ImagemServiceFake extends ImagemService {
  _ImagemServiceFake()
    : super(leitorDimensoes: (_) async => (largura: 120, altura: 80));

  @override
  Future<ImagemPreparada> prepararImagemOriginal({
    required File arquivoExterno,
    required OrigemImagem origem,
    required String analiseId,
    String? idImagem,
    DateTime? dataHora,
  }) async {
    return ImagemPreparada(
      imagem: Imagem(
        id: idImagem ?? 'imagem-recuperada',
        analiseId: analiseId,
        caminhoArquivo: arquivoExterno.path,
        largura: 120,
        altura: 80,
        formato: 'png',
        origem: origem,
        dataCaptura: dataHora ?? DateTime(2026, 6, 29, 10),
      ),
      nomeArquivo: 'captura_camera.png',
      tamanhoBytes: 4,
    );
  }
}
