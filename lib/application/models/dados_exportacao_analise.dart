import '../../domain/domain.dart';

/// Entrada organizada para exportar uma análise em CSV ou JSON.
///
/// O modelo carrega apenas entidades, metadados e caminhos de arquivos. A
/// exportação deve ler os dados já calculados e não deve alterar a imagem
/// original, a máscara automática ou a máscara final validada.
class DadosExportacaoAnalise {
  const DadosExportacaoAnalise({
    required this.analise,
    required this.imagem,
    required this.mascaraAutomatica,
    this.mascaraFinal,
    required this.resultadoAutomatico,
    this.resultadoFinal,
    this.metadadosAnalise,
    required this.formatoExportacao,
  });

  final Analise analise;
  final Imagem imagem;
  final Mascara mascaraAutomatica;
  final Mascara? mascaraFinal;
  final ResultadoAnalise resultadoAutomatico;
  final ResultadoAnalise? resultadoFinal;
  final MetadadosAnalise? metadadosAnalise;
  final FormatoExportacao formatoExportacao;

  bool get possuiResultadoFinal =>
      mascaraFinal != null && resultadoFinal != null;

  DadosExportacaoAnalise copiarComFormato(FormatoExportacao formato) {
    return DadosExportacaoAnalise(
      analise: analise,
      imagem: imagem,
      mascaraAutomatica: mascaraAutomatica,
      mascaraFinal: mascaraFinal,
      resultadoAutomatico: resultadoAutomatico,
      resultadoFinal: resultadoFinal,
      metadadosAnalise: metadadosAnalise,
      formatoExportacao: formato,
    );
  }
}
