import 'package:flutter/material.dart';

import '../routes/rotas_app.dart';
import '../widgets/botao_primario.dart';
import '../widgets/cartao_informativo.dart';
import '../widgets/pagina_base.dart';

/// Tela inicial do aplicativo.
///
/// Apresenta o objetivo científico do MVP sem prometer IA, medição direta de LAI
/// ou processamento real nesta fase.
class TelaInicialPage extends StatelessWidget {
  const TelaInicialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PaginaBase(
      titulo: 'Cobertura Dossel',
      mostrarVoltar: false,
      filhos: [
        Text(
          'Cobertura Dossel',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const Text(
          'Aplicativo para estimar céu visível e dossel estimado a partir de '
          'imagem digital e máscara validada pelo pesquisador.',
        ),
        const CartaoInformativo(
          titulo: 'Funcionamento local',
          texto:
              'O MVP foi planejado para funcionar localmente e offline. '
              'A imagem original deve permanecer preservada durante todo o fluxo.',
          icone: Icons.offline_pin,
        ),
        BotaoPrimario(
          rotulo: 'Nova análise',
          icone: Icons.add_circle_outline,
          aoPressionar: () =>
              Navigator.pushNamed(context, RotasApp.novaAnalise),
        ),
        BotaoPrimario(
          rotulo: 'Análises salvas',
          icone: Icons.folder_open,
          aoPressionar: () =>
              Navigator.pushNamed(context, RotasApp.analisesSalvas),
        ),
      ],
    );
  }
}
