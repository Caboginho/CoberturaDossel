import 'package:flutter/material.dart';

import '../../application/application.dart';
import '../routes/rotas_app.dart';
import '../widgets/botao_primario.dart';
import '../widgets/cartao_informativo.dart';
import '../widgets/pagina_base.dart';
import '../widgets/titulo_secao.dart';

/// Tela de análise com visualização temporária de imagem e máscara.
///
/// A visualização real será implementada em fase posterior. Esta tela mantém a
/// separação conceitual entre resultado automático preliminar e resultado final.
class AnalisePage extends StatelessWidget {
  const AnalisePage({super.key});

  @override
  Widget build(BuildContext context) {
    final argumento = ModalRoute.of(context)?.settings.arguments;
    final resultadoProcessamento = argumento is ResultadoProcessamentoImagem
        ? argumento
        : null;

    return PaginaBase(
      titulo: 'Análise',
      filhos: [
        const TituloSecao('Imagem e máscara'),
        const _AreaVisualTemporaria(),
        if (resultadoProcessamento != null)
          CartaoInformativo(
            titulo: 'Dados reais da máscara automática',
            texto:
                'Imagem original: ${resultadoProcessamento.imagem.caminhoArquivo}\n'
                'Máscara automática: ${resultadoProcessamento.mascaraAutomatica.caminhoArquivo}\n'
                'Céu visível automático: ${resultadoProcessamento.resultadoAutomatico.percentualCeu.toStringAsFixed(2)}%\n'
                'Dossel estimado automático: ${resultadoProcessamento.resultadoAutomatico.percentualDossel.toStringAsFixed(2)}%',
            icone: Icons.analytics_outlined,
          ),
        const CartaoInformativo(
          titulo: 'Resultado automático preliminar',
          texto:
              'Valor calculado futuramente a partir da máscara automática. '
              'Ele serve como apoio e não substitui a validação do pesquisador.',
          icone: Icons.pending_actions,
        ),
        const CartaoInformativo(
          titulo: 'Resultado final validado',
          texto:
              'Será calculado somente após a validação da máscara final pelo '
              'pesquisador.',
          icone: Icons.verified_outlined,
        ),
        BotaoPrimario(
          rotulo: 'Revisar máscara',
          icone: Icons.brush_outlined,
          aoPressionar: () =>
              Navigator.pushNamed(context, RotasApp.editorMascara),
        ),
        BotaoPrimario(
          rotulo: 'Ver resultados',
          icone: Icons.percent,
          aoPressionar: () => Navigator.pushNamed(context, RotasApp.resultados),
        ),
      ],
    );
  }
}

class _AreaVisualTemporaria extends StatelessWidget {
  const _AreaVisualTemporaria();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Container(
      height: 220,
      decoration: BoxDecoration(
        border: Border.all(color: tema.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: ColoredBox(
              color: tema.colorScheme.surfaceContainerHighest,
              child: const Center(child: Text('Imagem original')),
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: tema.colorScheme.primaryContainer,
              child: const Center(child: Text('Máscara céu/não céu')),
            ),
          ),
        ],
      ),
    );
  }
}
