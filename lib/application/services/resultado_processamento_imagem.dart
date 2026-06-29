import '../../domain/domain.dart';

/// Resultado da segmentação automática inicial.
///
/// Agrupa a imagem original preservada, a máscara automática separada e o
/// resultado automático preliminar calculado a partir dessa máscara.
class ResultadoProcessamentoImagem {
  const ResultadoProcessamentoImagem({
    required this.imagem,
    required this.mascaraAutomatica,
    required this.resultadoAutomatico,
  });

  final Imagem imagem;
  final Mascara mascaraAutomatica;
  final ResultadoAnalise resultadoAutomatico;
}
