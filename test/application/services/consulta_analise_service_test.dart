import 'package:cobertura_dossel/application/application.dart';
import 'package:cobertura_dossel/data/data.dart';
import 'package:cobertura_dossel/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/banco_teste_utils.dart';

void main() {
  setUpAll(inicializarBancoFfiParaTestes);

  late BancoDadosLocal bancoDadosLocal;
  late SalvamentoAnaliseService salvamentoAnaliseService;
  late ConsultaAnaliseService consultaAnaliseService;

  setUp(() {
    bancoDadosLocal = criarBancoEmMemoria();
    salvamentoAnaliseService = SalvamentoAnaliseService(
      bancoDadosLocal: bancoDadosLocal,
    );
    consultaAnaliseService = ConsultaAnaliseService(
      bancoDadosLocal: bancoDadosLocal,
    );
  });

  tearDown(() async {
    await bancoDadosLocal.fechar();
  });

  test('retorna lista vazia quando não houver análise', () async {
    final resumos = await consultaAnaliseService.listarAnalisesSalvas();

    expect(resumos, isEmpty);
  });

  test('lista análises salvas', () async {
    await salvamentoAnaliseService.salvarAnalise(
      _criarDadosSalvamento(analiseId: 'analise-1', possuiFinal: false),
    );

    final resumos = await consultaAnaliseService.listarAnalisesSalvas();

    expect(resumos, hasLength(1));
    expect(resumos.single.analise.nome, 'Análise analise-1');
  });

  test('busca análise com imagem, máscaras e resultados associados', () async {
    final dados = _criarDadosSalvamento(
      analiseId: 'analise-detalhe',
      possuiFinal: true,
    );
    await salvamentoAnaliseService.salvarAnalise(dados);

    final resumo = await consultaAnaliseService.buscarResumoPorId(
      dados.analise.id,
    );

    expect(resumo.imagem!.id, dados.imagem.id);
    expect(resumo.mascaras, hasLength(2));
    expect(resumo.resultados, hasLength(2));
    expect(resumo.resultadoFinal, isNotNull);
  });

  test('diferencia análise validada e não validada', () async {
    await salvamentoAnaliseService.salvarAnalise(
      _criarDadosSalvamento(analiseId: 'analise-parcial', possuiFinal: false),
    );
    await salvamentoAnaliseService.salvarAnalise(
      _criarDadosSalvamento(analiseId: 'analise-validada', possuiFinal: true),
    );

    final parcial = await consultaAnaliseService.buscarResumoPorId(
      'analise-parcial',
    );
    final validada = await consultaAnaliseService.buscarResumoPorId(
      'analise-validada',
    );

    expect(parcial.validada, isFalse);
    expect(parcial.resultadoAutomatico, isNotNull);
    expect(validada.validada, isTrue);
    expect(validada.resultadoFinal, isNotNull);
  });
}

DadosSalvamentoAnalise _criarDadosSalvamento({
  required String analiseId,
  required bool possuiFinal,
}) {
  final data = DateTime(2026, 6, 29, 10);
  final analise = Analise(
    id: analiseId,
    nome: 'Análise $analiseId',
    dataCriacao: data,
    dataAtualizacao: data,
    versaoAlgoritmo: 'regras_visuais_mvp',
  );
  final imagem = Imagem(
    id: 'imagem-$analiseId',
    analiseId: analise.id,
    caminhoArquivo: '/arquivos/$analiseId-original.png',
    largura: 10,
    altura: 10,
    formato: 'png',
    origem: OrigemImagem.galeria,
    dataImportacao: data,
  );
  final mascaraAutomatica = Mascara(
    id: 'mascara-automatica-$analiseId',
    analiseId: analise.id,
    tipo: TipoMascara.automatica,
    caminhoArquivo: '/arquivos/$analiseId-automatica.png',
    largura: 10,
    altura: 10,
    pixelsCeu: 5,
    pixelsNaoCeu: 5,
    dataCriacao: data,
  );
  final resultadoAutomatico = ResultadoAnalise(
    id: 'resultado-automatico-$analiseId',
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
    id: 'mascara-final-$analiseId',
    analiseId: analise.id,
    tipo: TipoMascara.finalValidada,
    caminhoArquivo: '/arquivos/$analiseId-final.png',
    largura: 10,
    altura: 10,
    pixelsCeu: 2,
    pixelsNaoCeu: 8,
    dataCriacao: data,
  );
  final resultadoFinal = ResultadoAnalise(
    id: 'resultado-final-$analiseId',
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
