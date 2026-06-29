import 'package:cobertura_dossel/application/application.dart';
import 'package:cobertura_dossel/domain/domain.dart';
import 'package:cobertura_dossel/presentation/pages/analises_salvas_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/banco_teste_utils.dart';

void main() {
  setUpAll(inicializarBancoFfiParaTestes);

  testWidgets('mostra mensagem quando não há análises salvas', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AnalisesSalvasPage(
          consultaAnaliseService: _ConsultaAnaliseFake(const []),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Nenhuma análise salva ainda'), findsOneWidget);
  });

  testWidgets('exibe análise salva quando houver dados fake', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AnalisesSalvasPage(
          consultaAnaliseService: _ConsultaAnaliseFake([
            _criarResumoAnaliseSalva(possuiFinal: false),
          ]),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Análise salva para lista'), findsOneWidget);
    expect(find.textContaining('Resultado automático'), findsOneWidget);
  });

  testWidgets('indica se a análise está validada', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AnalisesSalvasPage(
          consultaAnaliseService: _ConsultaAnaliseFake([
            _criarResumoAnaliseSalva(possuiFinal: true),
          ]),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Validada'), findsOneWidget);
    expect(find.textContaining('Resultado final'), findsOneWidget);
  });
}

class _ConsultaAnaliseFake extends ConsultaAnaliseService {
  _ConsultaAnaliseFake(this.resumos)
    : super(bancoDadosLocal: criarBancoEmMemoria());

  final List<ResumoAnaliseSalva> resumos;

  @override
  Future<List<ResumoAnaliseSalva>> listarAnalisesSalvas() async {
    return resumos;
  }
}

ResumoAnaliseSalva _criarResumoAnaliseSalva({required bool possuiFinal}) {
  final dados = _criarDadosSalvamento(possuiFinal: possuiFinal);

  return ResumoAnaliseSalva(
    analise: Analise(
      id: dados.analise.id,
      nome: dados.analise.nome,
      dataCriacao: dados.analise.dataCriacao,
      dataAtualizacao: dados.analise.dataAtualizacao,
      versaoAlgoritmo: dados.analise.versaoAlgoritmo,
      statusValidacao: possuiFinal,
    ),
    imagem: dados.imagem,
    mascaras: [
      dados.mascaraAutomatica,
      if (dados.mascaraFinal != null) dados.mascaraFinal!,
    ],
    resultados: [
      dados.resultadoAutomatico,
      if (dados.resultadoFinal != null) dados.resultadoFinal!,
    ],
  );
}

DadosSalvamentoAnalise _criarDadosSalvamento({required bool possuiFinal}) {
  final data = DateTime(2026, 6, 29, 10);
  final analise = Analise(
    id: 'analise-lista',
    nome: 'Análise salva para lista',
    dataCriacao: data,
    dataAtualizacao: data,
    versaoAlgoritmo: 'regras_visuais_mvp',
  );
  final imagem = Imagem(
    id: 'imagem-lista',
    analiseId: analise.id,
    caminhoArquivo: '/arquivos/original-lista.png',
    largura: 10,
    altura: 10,
    formato: 'png',
    origem: OrigemImagem.galeria,
    dataImportacao: data,
  );
  final mascaraAutomatica = Mascara(
    id: 'mascara-automatica-lista',
    analiseId: analise.id,
    tipo: TipoMascara.automatica,
    caminhoArquivo: '/arquivos/automatica-lista.png',
    largura: 10,
    altura: 10,
    pixelsCeu: 5,
    pixelsNaoCeu: 5,
    dataCriacao: data,
  );
  final resultadoAutomatico = ResultadoAnalise(
    id: 'resultado-automatico-lista',
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

  if (!possuiFinal) {
    return DadosSalvamentoAnalise(
      analise: analise,
      imagem: imagem,
      mascaraAutomatica: mascaraAutomatica,
      resultadoAutomatico: resultadoAutomatico,
    );
  }

  final mascaraFinal = Mascara(
    id: 'mascara-final-lista',
    analiseId: analise.id,
    tipo: TipoMascara.finalValidada,
    caminhoArquivo: '/arquivos/final-lista.png',
    largura: 10,
    altura: 10,
    pixelsCeu: 2,
    pixelsNaoCeu: 8,
    dataCriacao: data,
  );
  final resultadoFinal = ResultadoAnalise(
    id: 'resultado-final-lista',
    analiseId: analise.id,
    mascaraId: mascaraFinal.id,
    tipoMascara: TipoMascara.finalValidada,
    pixelsValidos: 10,
    pixelsCeu: 2,
    pixelsNaoCeu: 8,
    percentualCeu: 20,
    percentualDossel: 80,
    dataCalculo: data,
  );

  return DadosSalvamentoAnalise(
    analise: analise,
    imagem: imagem,
    mascaraAutomatica: mascaraAutomatica,
    mascaraFinal: mascaraFinal,
    resultadoAutomatico: resultadoAutomatico,
    resultadoFinal: resultadoFinal,
  );
}
