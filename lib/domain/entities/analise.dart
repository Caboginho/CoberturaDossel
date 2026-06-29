import 'imagem.dart';
import 'mascara.dart';
import 'metadados_analise.dart';
import 'resultado_analise.dart';

/// Representa uma análise científica realizada sobre uma imagem de dossel.
///
/// A análise agrega a imagem original, as máscaras produzidas durante o fluxo,
/// os resultados calculados e os metadados de campo. A imagem original deve ser
/// preservada; qualquer correção feita pelo pesquisador deve ser registrada nas
/// máscaras associadas à análise.
class Analise {
  Analise({
    required this.id,
    required this.nome,
    required this.dataCriacao,
    required this.dataAtualizacao,
    this.observacoes = '',
    this.versaoAlgoritmo = '',
    this.statusValidacao = false,
    this.imagem,
    List<Mascara> mascaras = const [],
    List<ResultadoAnalise> resultados = const [],
    this.metadados,
  }) : mascaras = List.unmodifiable(mascaras),
       resultados = List.unmodifiable(resultados);

  final String id;
  final String nome;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;
  final String observacoes;

  /// Versão do algoritmo ou regra visual usada no processamento da análise.
  ///
  /// Na Fase 2 este campo é apenas persistido para rastreabilidade. O MVP ainda
  /// não implementa inteligência artificial nem segmentação de imagem.
  final String versaoAlgoritmo;

  /// Indica se a máscara final já foi validada pelo pesquisador.
  ///
  /// O resultado automático é apenas preliminar; o resultado final depende de
  /// uma máscara validada.
  final bool statusValidacao;

  /// Imagem original vinculada à análise.
  ///
  /// Essa referência não autoriza alteração do arquivo original.
  final Imagem? imagem;

  /// Lista de máscaras vinculadas à análise, incluindo a automática e a final.
  final List<Mascara> mascaras;

  /// Resultados calculados a partir de máscaras específicas.
  ///
  /// Essa lista permite manter a diferença entre resultado automático e
  /// resultado final sem sobrescrever cálculos anteriores.
  final List<ResultadoAnalise> resultados;

  final MetadadosAnalise? metadados;
}
