import '../../domain/domain.dart';

/// Modelo de apresentação consolidado para a tela de resultados.
///
/// O resumo agrupa imagem, máscaras e resultados sem fazer novos cálculos. Ele
/// deixa explícito se existe resultado final validado pelo pesquisador ou se a
/// análise ainda mostra apenas o resultado automático preliminar.
class ResumoResultadoAnalise {
  const ResumoResultadoAnalise({
    required this.imagemOriginal,
    required this.mascaraAutomatica,
    this.mascaraFinal,
    required this.resultadoAutomatico,
    this.resultadoFinal,
    this.diferencaPercentual,
    required this.resultadoFinalValidado,
    required this.mensagemStatus,
  });

  final Imagem imagemOriginal;
  final Mascara mascaraAutomatica;
  final Mascara? mascaraFinal;
  final ResultadoAnalise resultadoAutomatico;
  final ResultadoAnalise? resultadoFinal;
  final double? diferencaPercentual;
  final bool resultadoFinalValidado;
  final String mensagemStatus;
}
