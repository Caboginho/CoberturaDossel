import 'package:flutter/material.dart';

import '../../application/application.dart';
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
    ResultadoAnaliseService resultadoAnaliseService =
        const ResultadoAnaliseService(),
    super.key,
  }) : _resultadoAnaliseService = resultadoAnaliseService;

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
          aoPressionar: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Salvamento será conectado na Fase 9.'),
              ),
            );
          },
        ),
        BotaoPrimario(
          rotulo: 'Exportar resultado',
          icone: Icons.ios_share,
          aoPressionar: () => Navigator.pushNamed(context, RotasApp.exportacao),
        ),
      ],
    );
  }

  ResumoResultadoAnalise? _obterResumo(Object? argumento) {
    if (argumento is ResumoResultadoAnalise) {
      return argumento;
    }

    if (argumento is ResultadoValidacaoMascara) {
      return _resultadoAnaliseService.criarResumoDeValidacao(argumento);
    }

    if (argumento is ResultadoProcessamentoImagem) {
      return _resultadoAnaliseService.criarResumoDeProcessamento(argumento);
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
