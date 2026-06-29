import 'package:flutter/material.dart';

import '../widgets/cartao_informativo.dart';
import '../widgets/pagina_base.dart';

/// Tela preparada para futura integração com [AnaliseRepository].
///
/// A Fase 3 não lista dados reais do SQLite; isso será conectado quando o fluxo
/// de salvamento da análise estiver implementado.
class AnalisesSalvasPage extends StatelessWidget {
  const AnalisesSalvasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PaginaBase(
      titulo: 'Análises salvas',
      filhos: [
        CartaoInformativo(
          titulo: 'Nenhuma análise salva ainda',
          texto:
              'Esta tela será integrada ao AnaliseRepository em fase '
              'posterior, quando o fluxo real de salvamento estiver ativo.',
          icone: Icons.folder_off_outlined,
        ),
      ],
    );
  }
}
