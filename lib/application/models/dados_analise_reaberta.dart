import '../../domain/domain.dart';
import '../services/resultado_processamento_imagem.dart';
import '../services/resultado_validacao_mascara.dart';

/// Dados completos para reabrir uma análise salva.
///
/// O modelo reúne somente entidades, resultados e caminhos já persistidos. Ele
/// não carrega bytes de imagem nem altera arquivos; a imagem original, a máscara
/// automática e a máscara final permanecem separadas.
class DadosAnaliseReaberta {
  const DadosAnaliseReaberta({
    required this.analise,
    required this.imagem,
    required this.mascaraAutomatica,
    this.mascaraFinal,
    required this.resultadoAutomatico,
    this.resultadoFinal,
    this.metadadosAnalise,
  });

  final Analise analise;
  final Imagem imagem;
  final Mascara mascaraAutomatica;
  final Mascara? mascaraFinal;
  final ResultadoAnalise resultadoAutomatico;
  final ResultadoAnalise? resultadoFinal;
  final MetadadosAnalise? metadadosAnalise;

  bool get possuiResultadoFinal =>
      mascaraFinal != null && resultadoFinal != null;

  ResultadoProcessamentoImagem get processamento {
    return ResultadoProcessamentoImagem(
      imagem: imagem,
      mascaraAutomatica: mascaraAutomatica,
      resultadoAutomatico: resultadoAutomatico,
    );
  }

  ResultadoValidacaoMascara? get validacao {
    final mascara = mascaraFinal;
    final resultado = resultadoFinal;
    if (mascara == null || resultado == null) {
      return null;
    }

    return ResultadoValidacaoMascara(
      processamento: processamento,
      mascaraFinal: mascara,
      resultadoFinal: resultado,
    );
  }
}
