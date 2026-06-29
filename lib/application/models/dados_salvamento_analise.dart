import '../../domain/domain.dart';

/// Entrada organizada para salvar uma análise completa ou parcial.
///
/// O modelo contém somente entidades e caminhos de arquivos. O SQLite deve
/// persistir metadados e resultados, nunca bytes de imagem ou pixels
/// individuais.
class DadosSalvamentoAnalise {
  const DadosSalvamentoAnalise({
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
}
