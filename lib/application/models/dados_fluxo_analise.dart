import '../../domain/domain.dart';
import '../services/resultado_processamento_imagem.dart';
import '../services/resultado_validacao_mascara.dart';

/// Dados carregados entre a criação da análise e a escolha da imagem.
///
/// A entidade [Analise] preserva nome, observações e estado de validação durante
/// o fluxo antes do salvamento definitivo no SQLite.
class DadosImagemAnalise {
  const DadosImagemAnalise({required this.analise, required this.imagem});

  final Analise analise;
  final Imagem imagem;
}

/// Resultado automático associado à análise criada pelo pesquisador.
class DadosProcessamentoAnalise {
  const DadosProcessamentoAnalise({
    required this.analise,
    required this.processamento,
  });

  final Analise analise;
  final ResultadoProcessamentoImagem processamento;
}

/// Resultado final validado associado à análise criada pelo pesquisador.
class DadosValidacaoAnalise {
  const DadosValidacaoAnalise({required this.analise, required this.validacao});

  final Analise analise;
  final ResultadoValidacaoMascara validacao;
}
