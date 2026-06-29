import '../../domain/domain.dart';
import '../models/resumo_resultado_analise.dart';
import 'resultado_processamento_imagem.dart';
import 'resultado_validacao_mascara.dart';

/// Serviço de aplicação que centraliza a criação e apresentação dos resultados.
///
/// As fórmulas continuam concentradas em [CalculoDosselService]. Este serviço
/// coordena entidades, tipos de resultado e mensagens de status, evitando que
/// telas ou serviços de processamento dupliquem regras de negócio.
class ResultadoAnaliseService {
  const ResultadoAnaliseService({
    CalculoDosselService calculoDosselService = const CalculoDosselService(),
  }) : _calculoDosselService = calculoDosselService;

  static const String mensagemFinalNaoValidado =
      'Resultado final ainda não validado pelo pesquisador.';
  static const String mensagemFinalValidado =
      'O resultado final foi calculado a partir da máscara validada pelo pesquisador.';

  final CalculoDosselService _calculoDosselService;

  /// Cria o resultado automático preliminar a partir da máscara automática.
  ///
  /// O método não altera a máscara nem a imagem original; usa apenas contagens
  /// já registradas na entidade de máscara.
  ResultadoAnalise criarResultadoAutomatico({
    required Mascara mascaraAutomatica,
    String? resultadoId,
    DateTime? dataHora,
  }) {
    return _criarResultado(
      mascara: mascaraAutomatica,
      tipoMascara: TipoMascara.automatica,
      resultadoId: resultadoId,
      dataHora: dataHora,
    );
  }

  /// Cria o resultado final a partir da máscara validada pelo pesquisador.
  ///
  /// A diferença percentual é calculada em relação ao resultado automático
  /// preliminar, mantendo a rastreabilidade entre as duas etapas do fluxo.
  ResultadoAnalise criarResultadoFinal({
    required Mascara mascaraFinal,
    required ResultadoAnalise resultadoAutomatico,
    String? resultadoId,
    DateTime? dataHora,
  }) {
    final resultadoFinalBase = _criarResultado(
      mascara: mascaraFinal,
      tipoMascara: TipoMascara.finalValidada,
      resultadoId: resultadoId,
      dataHora: dataHora,
    );
    final diferencaPercentual = calcularDiferencaPercentual(
      resultadoAutomatico: resultadoAutomatico,
      resultadoFinal: resultadoFinalBase,
    );

    return ResultadoAnalise(
      id: resultadoFinalBase.id,
      analiseId: resultadoFinalBase.analiseId,
      mascaraId: resultadoFinalBase.mascaraId,
      tipoMascara: resultadoFinalBase.tipoMascara,
      pixelsValidos: resultadoFinalBase.pixelsValidos,
      pixelsCeu: resultadoFinalBase.pixelsCeu,
      pixelsNaoCeu: resultadoFinalBase.pixelsNaoCeu,
      percentualCeu: resultadoFinalBase.percentualCeu,
      percentualDossel: resultadoFinalBase.percentualDossel,
      diferencaPercentual: diferencaPercentual,
      dataCalculo: resultadoFinalBase.dataCalculo,
    );
  }

  /// Calcula a diferença percentual entre automático e final.
  ///
  /// A comparação usa o percentual de dossel estimado porque ele é o indicador
  /// final apresentado ao pesquisador. O cálculo é absoluto, então diferenças
  /// positivas e negativas geram pontos percentuais positivos.
  double calcularDiferencaPercentual({
    required ResultadoAnalise resultadoAutomatico,
    required ResultadoAnalise resultadoFinal,
  }) {
    return _calculoDosselService.calcularDiferencaPercentual(
      percentualAutomatico: resultadoAutomatico.percentualDossel,
      percentualFinal: resultadoFinal.percentualDossel,
    );
  }

  /// Informa se existe resultado final validado e coerente com a máscara final.
  bool resultadoFinalEstaValidado({
    required Mascara? mascaraFinal,
    required ResultadoAnalise? resultadoFinal,
  }) {
    return mascaraFinal != null &&
        resultadoFinal != null &&
        resultadoFinal.tipoMascara == TipoMascara.finalValidada &&
        resultadoFinal.mascaraId == mascaraFinal.id;
  }

  /// Monta resumo contendo apenas o resultado automático preliminar.
  ResumoResultadoAnalise criarResumoAutomatico({
    required Imagem imagemOriginal,
    required Mascara mascaraAutomatica,
    required ResultadoAnalise resultadoAutomatico,
  }) {
    return ResumoResultadoAnalise(
      imagemOriginal: imagemOriginal,
      mascaraAutomatica: mascaraAutomatica,
      resultadoAutomatico: resultadoAutomatico,
      resultadoFinalValidado: false,
      mensagemStatus: mensagemFinalNaoValidado,
    );
  }

  /// Monta resumo contendo resultado automático e resultado final validado.
  ResumoResultadoAnalise criarResumoValidado({
    required Imagem imagemOriginal,
    required Mascara mascaraAutomatica,
    required Mascara mascaraFinal,
    required ResultadoAnalise resultadoAutomatico,
    required ResultadoAnalise resultadoFinal,
  }) {
    final diferencaPercentual =
        resultadoFinal.diferencaPercentual ??
        calcularDiferencaPercentual(
          resultadoAutomatico: resultadoAutomatico,
          resultadoFinal: resultadoFinal,
        );

    final finalValidado = resultadoFinalEstaValidado(
      mascaraFinal: mascaraFinal,
      resultadoFinal: resultadoFinal,
    );

    return ResumoResultadoAnalise(
      imagemOriginal: imagemOriginal,
      mascaraAutomatica: mascaraAutomatica,
      mascaraFinal: mascaraFinal,
      resultadoAutomatico: resultadoAutomatico,
      resultadoFinal: resultadoFinal,
      diferencaPercentual: diferencaPercentual,
      resultadoFinalValidado: finalValidado,
      mensagemStatus: finalValidado
          ? mensagemFinalValidado
          : mensagemFinalNaoValidado,
    );
  }

  ResumoResultadoAnalise criarResumoDeProcessamento(
    ResultadoProcessamentoImagem processamento,
  ) {
    return criarResumoAutomatico(
      imagemOriginal: processamento.imagem,
      mascaraAutomatica: processamento.mascaraAutomatica,
      resultadoAutomatico: processamento.resultadoAutomatico,
    );
  }

  ResumoResultadoAnalise criarResumoDeValidacao(
    ResultadoValidacaoMascara validacao,
  ) {
    return criarResumoValidado(
      imagemOriginal: validacao.imagem,
      mascaraAutomatica: validacao.mascaraAutomatica,
      mascaraFinal: validacao.mascaraFinal,
      resultadoAutomatico: validacao.resultadoAutomatico,
      resultadoFinal: validacao.resultadoFinal,
    );
  }

  ResultadoAnalise _criarResultado({
    required Mascara mascara,
    required TipoMascara tipoMascara,
    String? resultadoId,
    DateTime? dataHora,
  }) {
    final pixelsValidos = _calculoDosselService.calcularPixelsValidos(
      pixelsCeu: mascara.pixelsCeu,
      pixelsNaoCeu: mascara.pixelsNaoCeu,
    );
    final percentualCeu = _calculoDosselService.calcularPercentualCeu(
      pixelsCeu: mascara.pixelsCeu,
      pixelsValidos: pixelsValidos,
    );
    final percentualDossel = _calculoDosselService.calcularPercentualDossel(
      percentualCeu: percentualCeu,
      pixelsValidos: pixelsValidos,
    );
    final agora = dataHora ?? DateTime.now();

    return ResultadoAnalise(
      id: resultadoId ?? 'resultado_${agora.microsecondsSinceEpoch}',
      analiseId: mascara.analiseId,
      mascaraId: mascara.id,
      tipoMascara: tipoMascara,
      pixelsValidos: pixelsValidos,
      pixelsCeu: mascara.pixelsCeu,
      pixelsNaoCeu: mascara.pixelsNaoCeu,
      percentualCeu: percentualCeu,
      percentualDossel: percentualDossel,
      dataCalculo: agora,
    );
  }
}
