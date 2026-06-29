import 'package:flutter/material.dart';

import '../routes/rotas_app.dart';
import '../widgets/botao_primario.dart';
import '../widgets/cartao_informativo.dart';
import '../widgets/pagina_base.dart';
import '../widgets/titulo_secao.dart';

/// Tela de resultados com valores simulados para a Fase 3.
///
/// Os percentuais reais serão calculados a partir da máscara nas próximas fases.
/// O texto evita qualquer promessa de medição direta de LAI.
class ResultadosPage extends StatelessWidget {
  const ResultadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PaginaBase(
      titulo: 'Resultados',
      filhos: [
        const CartaoInformativo(
          titulo: 'Valores de exemplo',
          texto:
              'Os percentuais abaixo são simulados para demonstrar a tela. '
              'Na versão funcional, o cálculo usará a máscara validada.',
          icone: Icons.info_outline,
        ),
        const TituloSecao('Resumo percentual'),
        const _LinhaResultado(rotulo: 'Céu visível', valor: '48,0%'),
        const _LinhaResultado(rotulo: 'Dossel estimado', valor: '52,0%'),
        const _LinhaResultado(
          rotulo: 'Diferença automático/final',
          valor: '3,5 pontos percentuais',
        ),
        const CartaoInformativo(
          titulo: 'Interpretação',
          texto:
              'O resultado automático é preliminar. O resultado final depende '
              'da máscara validada pelo pesquisador.',
          icone: Icons.verified,
        ),
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
