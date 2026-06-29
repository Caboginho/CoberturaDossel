import 'package:cobertura_dossel/application/application.dart';
import 'package:cobertura_dossel/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const resultadoAnaliseService = ResultadoAnaliseService();
  final dataHora = DateTime(2026, 6, 29, 10);

  test('cria resultado automático com 50% céu e 50% dossel', () {
    final mascara = _criarMascara(
      id: 'mascara-automatica',
      tipo: TipoMascara.automatica,
      pixelsCeu: 5,
      pixelsNaoCeu: 5,
      dataHora: dataHora,
    );

    final resultado = resultadoAnaliseService.criarResultadoAutomatico(
      mascaraAutomatica: mascara,
      dataHora: dataHora,
    );

    expect(resultado.tipoMascara, TipoMascara.automatica);
    expect(resultado.pixelsValidos, 10);
    expect(resultado.percentualCeu, 50);
    expect(resultado.percentualDossel, 50);
  });

  test('cria resultado final com valores diferentes do automático', () {
    final resultadoAutomatico = _criarResultado(
      tipo: TipoMascara.automatica,
      percentualCeu: 50,
      percentualDossel: 50,
      dataHora: dataHora,
    );
    final mascaraFinal = _criarMascara(
      id: 'mascara-final',
      tipo: TipoMascara.finalValidada,
      pixelsCeu: 2,
      pixelsNaoCeu: 8,
      dataHora: dataHora,
    );

    final resultadoFinal = resultadoAnaliseService.criarResultadoFinal(
      mascaraFinal: mascaraFinal,
      resultadoAutomatico: resultadoAutomatico,
      dataHora: dataHora,
    );

    expect(resultadoFinal.tipoMascara, TipoMascara.finalValidada);
    expect(resultadoFinal.percentualCeu, 20);
    expect(resultadoFinal.percentualDossel, 80);
    expect(resultadoFinal.diferencaPercentual, 30);
  });

  test('calcula diferença percentual positiva', () {
    final automatico = _criarResultado(
      tipo: TipoMascara.automatica,
      percentualCeu: 50,
      percentualDossel: 50,
      dataHora: dataHora,
    );
    final finalValidado = _criarResultado(
      tipo: TipoMascara.finalValidada,
      percentualCeu: 25,
      percentualDossel: 75,
      dataHora: dataHora,
    );

    final diferenca = resultadoAnaliseService.calcularDiferencaPercentual(
      resultadoAutomatico: automatico,
      resultadoFinal: finalValidado,
    );

    expect(diferenca, 25);
  });

  test('calcula diferença percentual negativa como valor absoluto', () {
    final automatico = _criarResultado(
      tipo: TipoMascara.automatica,
      percentualCeu: 20,
      percentualDossel: 80,
      dataHora: dataHora,
    );
    final finalValidado = _criarResultado(
      tipo: TipoMascara.finalValidada,
      percentualCeu: 40,
      percentualDossel: 60,
      dataHora: dataHora,
    );

    final diferenca = resultadoAnaliseService.calcularDiferencaPercentual(
      resultadoAutomatico: automatico,
      resultadoFinal: finalValidado,
    );

    expect(diferenca, 20);
  });

  test('indica quando resultado final está validado', () {
    final mascaraFinal = _criarMascara(
      id: 'mascara-final',
      tipo: TipoMascara.finalValidada,
      pixelsCeu: 1,
      pixelsNaoCeu: 1,
      dataHora: dataHora,
    );
    final resultadoFinal = _criarResultado(
      tipo: TipoMascara.finalValidada,
      mascaraId: mascaraFinal.id,
      percentualCeu: 50,
      percentualDossel: 50,
      dataHora: dataHora,
    );

    expect(
      resultadoAnaliseService.resultadoFinalEstaValidado(
        mascaraFinal: mascaraFinal,
        resultadoFinal: resultadoFinal,
      ),
      isTrue,
    );
  });

  test('indica quando resultado final ainda não existe', () {
    expect(
      resultadoAnaliseService.resultadoFinalEstaValidado(
        mascaraFinal: null,
        resultadoFinal: null,
      ),
      isFalse,
    );

    final resumo = resultadoAnaliseService.criarResumoAutomatico(
      imagemOriginal: _criarImagem(),
      mascaraAutomatica: _criarMascara(
        id: 'mascara-automatica',
        tipo: TipoMascara.automatica,
        pixelsCeu: 1,
        pixelsNaoCeu: 1,
        dataHora: dataHora,
      ),
      resultadoAutomatico: _criarResultado(
        tipo: TipoMascara.automatica,
        percentualCeu: 50,
        percentualDossel: 50,
        dataHora: dataHora,
      ),
    );

    expect(resumo.resultadoFinalValidado, isFalse);
    expect(
      resumo.mensagemStatus,
      ResultadoAnaliseService.mensagemFinalNaoValidado,
    );
  });

  test('trata zero pixels válidos com segurança', () {
    final mascara = _criarMascara(
      id: 'mascara-vazia',
      tipo: TipoMascara.automatica,
      pixelsCeu: 0,
      pixelsNaoCeu: 0,
      dataHora: dataHora,
    );

    final resultado = resultadoAnaliseService.criarResultadoAutomatico(
      mascaraAutomatica: mascara,
      dataHora: dataHora,
    );

    expect(resultado.pixelsValidos, 0);
    expect(resultado.percentualCeu, 0);
    expect(resultado.percentualDossel, 0);
  });
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

Mascara _criarMascara({
  required String id,
  required TipoMascara tipo,
  required int pixelsCeu,
  required int pixelsNaoCeu,
  required DateTime dataHora,
}) {
  return Mascara(
    id: id,
    analiseId: 'analise-teste',
    tipo: tipo,
    caminhoArquivo: '$id.png',
    largura: 10,
    altura: 10,
    pixelsCeu: pixelsCeu,
    pixelsNaoCeu: pixelsNaoCeu,
    dataCriacao: dataHora,
  );
}

ResultadoAnalise _criarResultado({
  required TipoMascara tipo,
  String mascaraId = 'mascara-teste',
  required double percentualCeu,
  required double percentualDossel,
  required DateTime dataHora,
}) {
  return ResultadoAnalise(
    id: 'resultado-${tipo.name}-$percentualCeu',
    analiseId: 'analise-teste',
    mascaraId: mascaraId,
    tipoMascara: tipo,
    pixelsValidos: 10,
    pixelsCeu: percentualCeu ~/ 10,
    pixelsNaoCeu: percentualDossel ~/ 10,
    percentualCeu: percentualCeu,
    percentualDossel: percentualDossel,
    dataCalculo: dataHora,
  );
}
