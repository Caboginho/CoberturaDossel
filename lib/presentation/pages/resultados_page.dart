import 'package:flutter/material.dart';

import '../../application/application.dart';
import '../../domain/domain.dart';
import '../routes/rotas_app.dart';
import '../widgets/botao_primario.dart';
import '../widgets/cartao_informativo.dart';
import '../widgets/pagina_base.dart';
import '../widgets/resultado_widgets.dart';
import '../widgets/titulo_secao.dart';

/// Tela de resultados da análise.
///
/// A Fase 8 usa [ResumoResultadoAnalise] para apresentar dados reais quando
/// disponíveis. Valores simulados aparecem somente quando a tela é aberta sem
/// dados de processamento ou validação.
class ResultadosPage extends StatelessWidget {
  const ResultadosPage({
    this.salvamentoAnaliseService,
    ResultadoAnaliseService resultadoAnaliseService =
        const ResultadoAnaliseService(),
    super.key,
  }) : _resultadoAnaliseService = resultadoAnaliseService;

  final SalvamentoAnaliseService? salvamentoAnaliseService;
  final ResultadoAnaliseService _resultadoAnaliseService;

  @override
  Widget build(BuildContext context) {
    final argumento = ModalRoute.of(context)?.settings.arguments;
    final resumo = _obterResumo(argumento);

    return PaginaBase(
      titulo: 'Resultados',
      filhos: [
        if (resumo != null)
          ..._resultadoReal(resumo)
        else
          ..._resultadoExemplo(),
        BotaoPrimario(
          rotulo: 'Salvar análise',
          icone: Icons.save_outlined,
          aoPressionar: () => _salvarAnalise(context, argumento),
        ),
        BotaoPrimario(
          rotulo: 'Exportar resultado',
          icone: Icons.ios_share,
          aoPressionar: () => Navigator.pushNamed(
            context,
            RotasApp.exportacao,
            arguments: _criarDadosExportacao(argumento),
          ),
        ),
      ],
    );
  }

  ResumoResultadoAnalise? _obterResumo(Object? argumento) {
    if (argumento is ResumoResultadoAnalise) {
      return argumento;
    }

    if (argumento is DadosValidacaoAnalise) {
      return _resultadoAnaliseService.criarResumoDeValidacao(
        argumento.validacao,
      );
    }

    if (argumento is ResultadoValidacaoMascara) {
      return _resultadoAnaliseService.criarResumoDeValidacao(argumento);
    }

    if (argumento is DadosProcessamentoAnalise) {
      return _resultadoAnaliseService.criarResumoDeProcessamento(
        argumento.processamento,
      );
    }

    if (argumento is ResultadoProcessamentoImagem) {
      return _resultadoAnaliseService.criarResumoDeProcessamento(argumento);
    }

    return null;
  }

  DadosExportacaoAnalise? _criarDadosExportacao(Object? argumento) {
    if (argumento is DadosValidacaoAnalise) {
      final validacao = argumento.validacao;
      return DadosExportacaoAnalise(
        analise: argumento.analise,
        imagem: validacao.imagem,
        mascaraAutomatica: validacao.mascaraAutomatica,
        mascaraFinal: validacao.mascaraFinal,
        resultadoAutomatico: validacao.resultadoAutomatico,
        resultadoFinal: validacao.resultadoFinal,
        formatoExportacao: FormatoExportacao.csv,
      );
    }

    if (argumento is DadosProcessamentoAnalise) {
      final processamento = argumento.processamento;
      return DadosExportacaoAnalise(
        analise: argumento.analise,
        imagem: processamento.imagem,
        mascaraAutomatica: processamento.mascaraAutomatica,
        resultadoAutomatico: processamento.resultadoAutomatico,
        formatoExportacao: FormatoExportacao.csv,
      );
    }

    return null;
  }

  Future<void> _salvarAnalise(BuildContext context, Object? argumento) async {
    final dados = _criarDadosSalvamento(argumento);
    if (dados == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não há dados reais de análise para salvar nesta tela.',
          ),
        ),
      );
      return;
    }

    final servico = salvamentoAnaliseService ?? SalvamentoAnaliseService();
    final resultado = await servico.salvarAnalise(dados);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(resultado.mensagem)));
  }

  DadosSalvamentoAnalise? _criarDadosSalvamento(Object? argumento) {
    if (argumento is DadosValidacaoAnalise) {
      final validacao = argumento.validacao;
      return DadosSalvamentoAnalise(
        analise: argumento.analise,
        imagem: validacao.imagem,
        mascaraAutomatica: validacao.mascaraAutomatica,
        mascaraFinal: validacao.mascaraFinal,
        resultadoAutomatico: validacao.resultadoAutomatico,
        resultadoFinal: validacao.resultadoFinal,
      );
    }

    if (argumento is DadosProcessamentoAnalise) {
      final processamento = argumento.processamento;
      return DadosSalvamentoAnalise(
        analise: argumento.analise,
        imagem: processamento.imagem,
        mascaraAutomatica: processamento.mascaraAutomatica,
        resultadoAutomatico: processamento.resultadoAutomatico,
      );
    }

    return null;
  }

  List<Widget> _resultadoReal(ResumoResultadoAnalise resumo) {
    final resultadoFinal = resumo.resultadoFinal;
    final mascaraFinal = resumo.mascaraFinal;

    return [
      if (resumo.resultadoFinalValidado)
        AvisoResultadoValidado(mensagem: resumo.mensagemStatus)
      else
        AvisoResultadoPreliminar(mensagem: resumo.mensagemStatus),
      CartaoResultadoAutomatico(resultado: resumo.resultadoAutomatico),
      if (resultadoFinal != null && mascaraFinal != null)
        CartaoResultadoFinal(
          resultado: resultadoFinal,
          diferencaPercentual: resumo.diferencaPercentual ?? 0,
        ),
      CartaoInformativo(
        titulo: 'Arquivos da análise',
        texto:
            'Imagem original: ${resumo.imagemOriginal.caminhoArquivo}\n'
            'Máscara automática: ${resumo.mascaraAutomatica.caminhoArquivo}'
            '${mascaraFinal == null ? '' : '\nMáscara final: ${mascaraFinal.caminhoArquivo}'}',
        icone: Icons.folder_open_outlined,
      ),
    ];
  }

  List<Widget> _resultadoExemplo() {
    return const [
      CartaoInformativo(
        titulo: 'Valores de exemplo',
        texto:
            'Os percentuais abaixo são simulados para demonstrar a tela. '
            'Na versão funcional, o cálculo usará a máscara validada.',
        icone: Icons.info_outline,
      ),
      TituloSecao('Resumo percentual'),
      LinhaMetricaResultado(rotulo: 'Céu visível', valor: '48,0%'),
      LinhaMetricaResultado(rotulo: 'Dossel estimado', valor: '52,0%'),
      LinhaMetricaResultado(
        rotulo: 'Diferença automático/final',
        valor: '3,5 pontos percentuais',
      ),
      CartaoInformativo(
        titulo: 'Interpretação',
        texto:
            'O resultado automático é preliminar. O resultado final depende '
            'da máscara validada pelo pesquisador.',
        icone: Icons.verified,
      ),
    ];
  }
}
