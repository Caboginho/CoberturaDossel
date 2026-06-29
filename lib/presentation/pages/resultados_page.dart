import 'package:flutter/material.dart';

import '../../application/application.dart';
import '../routes/rotas_app.dart';
import '../widgets/botao_primario.dart';
import '../widgets/cartao_informativo.dart';
import '../widgets/pagina_base.dart';
import '../widgets/titulo_secao.dart';

/// Tela de resultados da análise.
///
/// Quando recebe dados reais da Fase 7, diferencia resultado automático
/// preliminar e resultado final calculado a partir da máscara validada pelo
/// pesquisador. Sem argumentos, preserva valores de exemplo para navegação.
class ResultadosPage extends StatelessWidget {
  const ResultadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final argumento = ModalRoute.of(context)?.settings.arguments;

    return PaginaBase(
      titulo: 'Resultados',
      filhos: [
        if (argumento is ResultadoValidacaoMascara)
          ..._resultadoValidado(argumento)
        else if (argumento is ResultadoProcessamentoImagem)
          ..._resultadoAutomatico(argumento)
        else
          ..._resultadoExemplo(),
        BotaoPrimario(
          rotulo: 'Salvar análise',
          icone: Icons.save_outlined,
          aoPressionar: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Salvamento será conectado em fase posterior.'),
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

  List<Widget> _resultadoValidado(ResultadoValidacaoMascara validacao) {
    final automatico = validacao.resultadoAutomatico;
    final finalValidado = validacao.resultadoFinal;
    final diferenca = finalValidado.diferencaPercentual ?? 0;

    return [
      const CartaoInformativo(
        titulo: 'Resultado final validado',
        texto:
            'O resultado final foi calculado a partir da máscara validada pelo '
            'pesquisador.',
        icone: Icons.verified_outlined,
      ),
      const TituloSecao('Resultado automático preliminar'),
      _LinhaResultado(
        rotulo: 'Céu visível automático',
        valor: _formatarPercentual(automatico.percentualCeu),
      ),
      _LinhaResultado(
        rotulo: 'Dossel estimado automático',
        valor: _formatarPercentual(automatico.percentualDossel),
      ),
      const TituloSecao('Resultado final'),
      _LinhaResultado(
        rotulo: 'Céu visível final',
        valor: _formatarPercentual(finalValidado.percentualCeu),
      ),
      _LinhaResultado(
        rotulo: 'Dossel estimado final',
        valor: _formatarPercentual(finalValidado.percentualDossel),
      ),
      _LinhaResultado(
        rotulo: 'Diferença automático/final',
        valor: '${diferenca.toStringAsFixed(2)} pontos percentuais',
      ),
      _LinhaResultado(
        rotulo: 'Pixels de céu final',
        valor: finalValidado.pixelsCeu.toString(),
      ),
      _LinhaResultado(
        rotulo: 'Pixels de não céu final',
        valor: finalValidado.pixelsNaoCeu.toString(),
      ),
      CartaoInformativo(
        titulo: 'Arquivos da análise',
        texto:
            'Imagem original: ${validacao.imagem.caminhoArquivo}\n'
            'Máscara automática: ${validacao.mascaraAutomatica.caminhoArquivo}\n'
            'Máscara final: ${validacao.mascaraFinal.caminhoArquivo}',
        icone: Icons.folder_open_outlined,
      ),
    ];
  }

  List<Widget> _resultadoAutomatico(
    ResultadoProcessamentoImagem processamento,
  ) {
    final automatico = processamento.resultadoAutomatico;

    return [
      const CartaoInformativo(
        titulo: 'Resultado automático preliminar',
        texto:
            'A máscara ainda não foi validada pelo pesquisador. O resultado '
            'final será calculado após a revisão manual.',
        icone: Icons.pending_actions,
      ),
      const TituloSecao('Resultado automático'),
      _LinhaResultado(
        rotulo: 'Céu visível automático',
        valor: _formatarPercentual(automatico.percentualCeu),
      ),
      _LinhaResultado(
        rotulo: 'Dossel estimado automático',
        valor: _formatarPercentual(automatico.percentualDossel),
      ),
      CartaoInformativo(
        titulo: 'Arquivos da análise',
        texto:
            'Imagem original: ${processamento.imagem.caminhoArquivo}\n'
            'Máscara automática: ${processamento.mascaraAutomatica.caminhoArquivo}',
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
      _LinhaResultado(rotulo: 'Céu visível', valor: '48,0%'),
      _LinhaResultado(rotulo: 'Dossel estimado', valor: '52,0%'),
      _LinhaResultado(
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

  static String _formatarPercentual(double valor) {
    return '${valor.toStringAsFixed(2)}%';
  }
}

class _LinhaResultado extends StatelessWidget {
  const _LinhaResultado({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: tema.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: Text(rotulo)),
            Text(valor, style: tema.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
