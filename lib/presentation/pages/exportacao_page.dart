import 'package:flutter/material.dart';

import '../widgets/cartao_informativo.dart';
import '../widgets/pagina_base.dart';
import '../widgets/titulo_secao.dart';

/// Tela placeholder para exportação de resultados.
///
/// A Fase 3 apresenta os formatos previstos, mas não gera arquivos CSV, JSON ou
/// PDF.
class ExportacaoPage extends StatelessWidget {
  const ExportacaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PaginaBase(
      titulo: 'Exportação',
      filhos: [
        const CartaoInformativo(
          titulo: 'Exportação futura',
          texto:
              'A exportação real será implementada em fase posterior. '
              'Nenhum arquivo é gerado nesta tela.',
          icone: Icons.ios_share,
        ),
        const TituloSecao('Formatos previstos'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _FormatoPlaceholder(rotulo: 'CSV', icone: Icons.table_chart),
            _FormatoPlaceholder(rotulo: 'JSON', icone: Icons.data_object),
            _FormatoPlaceholder(rotulo: 'PDF', icone: Icons.picture_as_pdf),
          ],
        ),
      ],
    );
  }
}

class _FormatoPlaceholder extends StatelessWidget {
  const _FormatoPlaceholder({required this.rotulo, required this.icone});

  final String rotulo;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      avatar: Icon(icone),
      label: Text(rotulo),
      selected: false,
      onSelected: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exportação $rotulo será implementada depois.'),
          ),
        );
      },
    );
  }
}
