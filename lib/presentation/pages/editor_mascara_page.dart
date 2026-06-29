import 'package:flutter/material.dart';

import '../routes/rotas_app.dart';
import '../widgets/botao_primario.dart';
import '../widgets/cartao_informativo.dart';
import '../widgets/pagina_base.dart';
import '../widgets/titulo_secao.dart';

/// Tela placeholder do editor de máscara.
///
/// A edição real ainda não existe. A regra de negócio essencial já aparece na
/// interface: correções devem ocorrer somente na máscara, nunca na imagem
/// original.
class EditorMascaraPage extends StatelessWidget {
  const EditorMascaraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PaginaBase(
      titulo: 'Editor de máscara',
      filhos: [
        const CartaoInformativo(
          titulo: 'Imagem original preservada',
          texto:
              'A edição ocorre apenas sobre a máscara. A imagem original não '
              'será alterada.',
          icone: Icons.lock_outline,
        ),
        const TituloSecao('Classes'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _FerramentaPlaceholder(
              icone: Icons.wb_sunny_outlined,
              rotulo: 'Classe céu',
            ),
            _FerramentaPlaceholder(
              icone: Icons.forest_outlined,
              rotulo: 'Classe não céu',
            ),
          ],
        ),
        const TituloSecao('Ferramentas'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _FerramentaPlaceholder(
              icone: Icons.brush_outlined,
              rotulo: 'Pincel',
            ),
            _FerramentaPlaceholder(
              icone: Icons.auto_fix_off,
              rotulo: 'Borracha',
            ),
            _FerramentaPlaceholder(icone: Icons.zoom_in, rotulo: 'Zoom'),
            _FerramentaPlaceholder(icone: Icons.undo, rotulo: 'Desfazer'),
            _FerramentaPlaceholder(icone: Icons.redo, rotulo: 'Refazer'),
          ],
        ),
        BotaoPrimario(
          rotulo: 'Validar máscara',
          icone: Icons.check_circle_outline,
          aoPressionar: () => Navigator.pushNamed(context, RotasApp.resultados),
        ),
      ],
    );
  }
}

class _FerramentaPlaceholder extends StatelessWidget {
  const _FerramentaPlaceholder({required this.icone, required this.rotulo});

  final IconData icone;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icone),
      label: Text(rotulo),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$rotulo será implementado em fase posterior.'),
          ),
        );
      },
    );
  }
}
