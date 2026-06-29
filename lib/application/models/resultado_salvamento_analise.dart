/// Retorno do fluxo de salvamento da análise no SQLite.
///
/// A interface usa este resultado para exibir mensagens claras de sucesso ou
/// falha sem expor detalhes técnicos do banco ao pesquisador.
class ResultadoSalvamentoAnalise {
  const ResultadoSalvamentoAnalise({
    required this.sucesso,
    required this.analiseId,
    required this.mensagem,
    required this.dataSalvamento,
  });

  final bool sucesso;
  final String analiseId;
  final String mensagem;
  final DateTime dataSalvamento;
}
