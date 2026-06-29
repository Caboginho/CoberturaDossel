import 'package:flutter/material.dart';

import 'cartao_informativo.dart';
import 'modo_visualizacao_mascara.dart';

/// Controle de modos de visualização da máscara automática.
///
/// O controle comunica que a máscara ainda é preliminar e permite ajustar a
/// opacidade apenas no modo de sobreposição.
class ControleVisualizacaoMascara extends StatelessWidget {
  const ControleVisualizacaoMascara({
    required this.modoSelecionado,
    required this.opacidadeMascara,
    required this.aoAlterarModo,
    required this.aoAlterarOpacidade,
    super.key,
  });

  final ModoVisualizacaoMascara modoSelecionado;
  final double opacidadeMascara;
  final ValueChanged<ModoVisualizacaoMascara> aoAlterarModo;
  final ValueChanged<double> aoAlterarOpacidade;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CartaoInformativo(
          titulo: 'Máscara automática ainda não validada',
          texto:
              'Use os modos abaixo para inspecionar o resultado automático. A '
              'revisão real da máscara será implementada na próxima fase.',
          icone: Icons.visibility_outlined,
        ),
        const SizedBox(height: 12),
        SegmentedButton<ModoVisualizacaoMascara>(
          segments: [
            for (final modo in ModoVisualizacaoMascara.values)
              ButtonSegment(value: modo, label: Text(modo.rotulo)),
          ],
          selected: {modoSelecionado},
          onSelectionChanged: (selecionados) {
            aoAlterarModo(selecionados.first);
          },
        ),
        if (modoSelecionado == ModoVisualizacaoMascara.sobreposicao) ...[
          const SizedBox(height: 12),
          Text('Opacidade da máscara: ${(opacidadeMascara * 100).round()}%'),
          Slider(
            value: opacidadeMascara,
            min: 0.1,
            max: 1,
            divisions: 9,
            label: '${(opacidadeMascara * 100).round()}%',
            onChanged: aoAlterarOpacidade,
          ),
        ],
      ],
    );
  }
}
