import '../../domain/domain.dart';
import 'resultado_processamento_imagem.dart';

/// Resultado produzido após a validação humana da máscara editada.
///
/// Mantém juntos o resultado automático preliminar e o resultado final validado,
/// preservando a diferença conceitual exigida pelo projeto.
class ResultadoValidacaoMascara {
  const ResultadoValidacaoMascara({
    required this.processamento,
    required this.mascaraFinal,
    required this.resultadoFinal,
  });

  final ResultadoProcessamentoImagem processamento;
  final Mascara mascaraFinal;
  final ResultadoAnalise resultadoFinal;

  Imagem get imagem => processamento.imagem;
  Mascara get mascaraAutomatica => processamento.mascaraAutomatica;
  ResultadoAnalise get resultadoAutomatico => processamento.resultadoAutomatico;
}
