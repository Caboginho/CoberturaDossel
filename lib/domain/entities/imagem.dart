import '../enums/origem_imagem.dart';

/// Representa a imagem original usada como entrada da análise.
///
/// Esta entidade guarda apenas informações de identificação, caminho, dimensão,
/// formato e origem. Nenhuma regra de domínio deve alterar o arquivo apontado
/// por [caminhoArquivo].
class Imagem {
  const Imagem({
    required this.id,
    required this.analiseId,
    required this.caminhoArquivo,
    required this.largura,
    required this.altura,
    required this.formato,
    required this.origem,
    this.dataCaptura,
    this.dataImportacao,
  }) : assert(largura >= 0),
       assert(altura >= 0);

  final String id;
  final String analiseId;

  /// Caminho do arquivo original preservado no armazenamento local.
  final String caminhoArquivo;

  final int largura;
  final int altura;
  final String formato;
  final OrigemImagem origem;

  /// Data em que a imagem foi capturada pelo dispositivo, quando existir.
  final DateTime? dataCaptura;

  /// Data em que a imagem foi importada para o fluxo da análise, quando existir.
  final DateTime? dataImportacao;
}
