import '../../domain/domain.dart';

/// Resultado da geração de um arquivo exportado.
///
/// O caminho retornado aponta para um novo arquivo no diretório de exportações.
/// A operação não modifica arquivos de imagem ou máscaras.
class ResultadoExportacao {
  const ResultadoExportacao({
    required this.sucesso,
    required this.formato,
    this.caminhoArquivo,
    required this.mensagem,
    required this.dataExportacao,
  });

  final bool sucesso;
  final FormatoExportacao formato;
  final String? caminhoArquivo;
  final String mensagem;
  final DateTime dataExportacao;
}
