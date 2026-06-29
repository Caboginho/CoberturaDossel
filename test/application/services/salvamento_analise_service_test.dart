import 'package:cobertura_dossel/application/application.dart';
import 'package:cobertura_dossel/data/data.dart';
import 'package:cobertura_dossel/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/banco_teste_utils.dart';

void main() {
  setUpAll(inicializarBancoFfiParaTestes);

  late BancoDadosLocal bancoDadosLocal;
  late SalvamentoAnaliseService salvamentoAnaliseService;
  late AnaliseRepository analiseRepository;
  late ImagemRepository imagemRepository;
  late MascaraRepository mascaraRepository;
  late ResultadoAnaliseRepository resultadoRepository;

  setUp(() {
    bancoDadosLocal = criarBancoEmMemoria();
    salvamentoAnaliseService = SalvamentoAnaliseService(
      bancoDadosLocal: bancoDadosLocal,
    );
    analiseRepository = AnaliseRepository(bancoDadosLocal);
    imagemRepository = ImagemRepository(bancoDadosLocal);
    mascaraRepository = MascaraRepository(bancoDadosLocal);
    resultadoRepository = ResultadoAnaliseRepository(bancoDadosLocal);
  });

  tearDown(() async {
    await bancoDadosLocal.fechar();
  });

  test('salva análise com imagem e resultado automático', () async {
    final dados = _criarDadosSalvamento(possuiFinal: false);

    final resultado = await salvamentoAnaliseService.salvarAnalise(dados);

    final analise = await analiseRepository.buscarPorId(dados.analise.id);
    final imagens = await imagemRepository.listarPorAnaliseId(dados.analise.id);
    final resultados = await resultadoRepository.listarPorAnaliseId(
      dados.analise.id,
    );

    expect(resultado.sucesso, isTrue);
    expect(analise, isNotNull);
    expect(imagens.single.caminhoArquivo, dados.imagem.caminhoArquivo);
    expect(resultados.single.tipoMascara, TipoMascara.automatica);
  });

  test('salva análise com máscara automática e resultado automático', () async {
    final dados = _criarDadosSalvamento(possuiFinal: false);

    await salvamentoAnaliseService.salvarAnalise(dados);

    final mascaras = await mascaraRepository.listarPorAnaliseId(
      dados.analise.id,
    );
    final resultados = await resultadoRepository.listarPorAnaliseId(
      dados.analise.id,
    );

    expect(mascaras.single.id, dados.mascaraAutomatica.id);
    expect(resultados.single.mascaraId, dados.mascaraAutomatica.id);
  });

  test('salva análise com máscara final e resultado final', () async {
    final dados = _criarDadosSalvamento(possuiFinal: true);

    final resultado = await salvamentoAnaliseService.salvarAnalise(dados);

    final mascaras = await mascaraRepository.listarPorAnaliseId(
      dados.analise.id,
    );
    final resultados = await resultadoRepository.listarPorAnaliseId(
      dados.analise.id,
    );

    expect(resultado.mensagem, 'Análise salva com resultado final validado.');
    expect(mascaras, hasLength(2));
    expect(
      mascaras.any((mascara) => mascara.tipo == TipoMascara.finalValidada),
      isTrue,
    );
    expect(resultados, hasLength(2));
    expect(
      resultados.any(
        (resultado) => resultado.tipoMascara == TipoMascara.finalValidada,
      ),
      isTrue,
    );
  });

  test('salva análise parcial sem resultado final', () async {
    final dados = _criarDadosSalvamento(possuiFinal: false);

    final resultado = await salvamentoAnaliseService.salvarAnalise(dados);

    expect(resultado.mensagem, 'Análise salva sem validação final da máscara.');
    final resultados = await resultadoRepository.listarPorAnaliseId(
      dados.analise.id,
    );
    expect(resultados, hasLength(1));
  });

  test(
    'mantém statusValidacao falso quando não houver máscara final validada',
    () async {
      final dados = _criarDadosSalvamento(possuiFinal: false);

      await salvamentoAnaliseService.salvarAnalise(dados);

      final analise = await analiseRepository.buscarPorId(dados.analise.id);
      expect(analise!.statusValidacao, isFalse);
    },
  );

  test(
    'marca statusValidacao verdadeiro quando houver resultado final',
    () async {
      final dados = _criarDadosSalvamento(possuiFinal: true);

      await salvamentoAnaliseService.salvarAnalise(dados);

      final analise = await analiseRepository.buscarPorId(dados.analise.id);
      expect(analise!.statusValidacao, isTrue);
    },
  );

  test('persiste caminhos de arquivos, não blobs de imagem', () async {
    final dados = _criarDadosSalvamento(possuiFinal: true);

    await salvamentoAnaliseService.salvarAnalise(dados);

    final imagens = await imagemRepository.listarPorAnaliseId(dados.analise.id);
    final mascaras = await mascaraRepository.listarPorAnaliseId(
      dados.analise.id,
    );

    expect(imagens.single.caminhoArquivo, '/arquivos/imagem-original.png');
    expect(
      mascaras.map((mascara) => mascara.caminhoArquivo),
      containsAll([
        '/arquivos/mascara-automatica.png',
        '/arquivos/mascara-final.png',
      ]),
    );
  });
}

DadosSalvamentoAnalise _criarDadosSalvamento({required bool possuiFinal}) {
  final data = DateTime(2026, 6, 29, 10);
  final analise = Analise(
    id: 'analise-salvamento',
    nome: 'Análise de salvamento',
    dataCriacao: data,
    dataAtualizacao: data,
    observacoes: 'Teste de salvamento completo.',
    versaoAlgoritmo: 'regras_visuais_mvp',
  );
  final imagem = Imagem(
    id: 'imagem-salvamento',
    analiseId: analise.id,
    caminhoArquivo: '/arquivos/imagem-original.png',
    largura: 10,
    altura: 10,
    formato: 'png',
    origem: OrigemImagem.galeria,
    dataImportacao: data,
  );
  final mascaraAutomatica = Mascara(
    id: 'mascara-automatica',
    analiseId: analise.id,
    tipo: TipoMascara.automatica,
    caminhoArquivo: '/arquivos/mascara-automatica.png',
    largura: 10,
    altura: 10,
    pixelsCeu: 5,
    pixelsNaoCeu: 5,
    dataCriacao: data,
  );
  final resultadoAutomatico = ResultadoAnalise(
    id: 'resultado-automatico',
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
    id: 'mascara-final',
    analiseId: analise.id,
    tipo: TipoMascara.finalValidada,
    caminhoArquivo: '/arquivos/mascara-final.png',
    largura: 10,
    altura: 10,
    pixelsCeu: 3,
    pixelsNaoCeu: 7,
    dataCriacao: data,
  );
  final resultadoFinal = ResultadoAnalise(
    id: 'resultado-final',
    analiseId: analise.id,
    mascaraId: mascaraFinal.id,
    tipoMascara: TipoMascara.finalValidada,
    pixelsValidos: 10,
    pixelsCeu: 3,
    pixelsNaoCeu: 7,
    percentualCeu: 30,
    percentualDossel: 70,
    diferencaPercentual: 20,
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
