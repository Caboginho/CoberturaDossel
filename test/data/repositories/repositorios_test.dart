import 'package:cobertura_dossel/data/data.dart';
import 'package:flutter_test/flutter_test.dart';

import '../banco_teste_utils.dart';
import '../entidades_teste.dart';

void main() {
  setUpAll(inicializarBancoFfiParaTestes);

  late BancoDadosLocal bancoDadosLocal;
  late AnaliseRepository analiseRepository;
  late ImagemRepository imagemRepository;
  late MascaraRepository mascaraRepository;
  late ResultadoAnaliseRepository resultadoRepository;

  setUp(() {
    bancoDadosLocal = criarBancoEmMemoria();
    analiseRepository = AnaliseRepository(bancoDadosLocal);
    imagemRepository = ImagemRepository(bancoDadosLocal);
    mascaraRepository = MascaraRepository(bancoDadosLocal);
    resultadoRepository = ResultadoAnaliseRepository(bancoDadosLocal);
  });

  tearDown(() async {
    await bancoDadosLocal.fechar();
  });

  test('salva e recupera uma análise local', () async {
    final analise = criarAnaliseTeste();

    await analiseRepository.salvar(analise);
    final recuperada = await analiseRepository.buscarPorId(analise.id);

    expect(recuperada, isNotNull);
    expect(recuperada!.nome, analise.nome);
    expect(recuperada.versaoAlgoritmo, analise.versaoAlgoritmo);
  });

  test(
    'salva e recupera imagem associada a uma análise sem alterar o arquivo original',
    () async {
      final analise = criarAnaliseTeste();
      final imagem = criarImagemTeste();

      await analiseRepository.salvar(analise);
      await imagemRepository.salvar(imagem);
      final recuperada = await imagemRepository.buscarPorId(imagem.id);

      expect(recuperada, isNotNull);
      expect(recuperada!.analiseId, analise.id);
      expect(recuperada.caminhoArquivo, imagem.caminhoArquivo);
    },
  );

  test('salva e recupera máscara associada a uma análise', () async {
    final analise = criarAnaliseTeste();
    final mascara = criarMascaraTeste();

    await analiseRepository.salvar(analise);
    await mascaraRepository.salvar(mascara);
    final recuperada = await mascaraRepository.buscarPorId(mascara.id);

    expect(recuperada, isNotNull);
    expect(recuperada!.analiseId, analise.id);
    expect(recuperada.pixelsValidos, mascara.pixelsValidos);
  });

  test('salva e recupera resultado associado a análise e máscara', () async {
    final analise = criarAnaliseTeste();
    final mascara = criarMascaraTeste();
    final resultado = criarResultadoTeste();

    await analiseRepository.salvar(analise);
    await mascaraRepository.salvar(mascara);
    await resultadoRepository.salvar(resultado);
    final recuperado = await resultadoRepository.buscarPorId(resultado.id);

    expect(recuperado, isNotNull);
    expect(recuperado!.analiseId, analise.id);
    expect(recuperado.mascaraId, mascara.id);
    expect(recuperado.percentualCeu, 50);
  });
}
