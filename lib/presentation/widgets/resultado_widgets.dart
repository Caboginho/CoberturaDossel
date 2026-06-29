import 'package:flutter/material.dart';

import '../../domain/domain.dart';
import 'cartao_informativo.dart';
import 'titulo_secao.dart';

/// Linha reutilizável para métricas percentuais, contagens e caminhos curtos.
class LinhaMetricaResultado extends StatelessWidget {
  const LinhaMetricaResultado({
    required this.rotulo,
    required this.valor,
    super.key,
  });

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
            Flexible(
              child: Text(
                valor,
                textAlign: TextAlign.end,
                style: tema.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Aviso usado quando só existe resultado automático preliminar.
class AvisoResultadoPreliminar extends StatelessWidget {
  const AvisoResultadoPreliminar({required this.mensagem, super.key});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return CartaoInformativo(
      titulo: 'Resultado automático preliminar',
      texto: mensagem,
      icone: Icons.pending_actions,
    );
  }
}

/// Aviso usado quando a máscara final já foi validada pelo pesquisador.
class AvisoResultadoValidado extends StatelessWidget {
  const AvisoResultadoValidado({required this.mensagem, super.key});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return CartaoInformativo(
      titulo: 'Resultado final validado',
      texto: mensagem,
      icone: Icons.verified_outlined,
    );
  }
}

/// Conjunto de métricas do resultado automático calculado pela máscara inicial.
class CartaoResultadoAutomatico extends StatelessWidget {
  const CartaoResultadoAutomatico({required this.resultado, super.key});

  final ResultadoAnalise resultado;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TituloSecao('Resultado automático preliminar'),
        LinhaMetricaResultado(
          rotulo: 'Céu visível automático',
          valor: _formatarPercentual(resultado.percentualCeu),
        ),
        const SizedBox(height: 12),
        LinhaMetricaResultado(
          rotulo: 'Dossel estimado automático',
          valor: _formatarPercentual(resultado.percentualDossel),
        ),
        const SizedBox(height: 12),
        LinhaMetricaResultado(
          rotulo: 'Pixels de céu automático',
          valor: resultado.pixelsCeu.toString(),
        ),
        const SizedBox(height: 12),
        LinhaMetricaResultado(
          rotulo: 'Pixels de não céu automático',
          valor: resultado.pixelsNaoCeu.toString(),
        ),
      ],
    );
  }
}

/// Conjunto de métricas do resultado final calculado pela máscara validada.
class CartaoResultadoFinal extends StatelessWidget {
  const CartaoResultadoFinal({
    required this.resultado,
    required this.diferencaPercentual,
    super.key,
  });

  final ResultadoAnalise resultado;
  final double diferencaPercentual;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TituloSecao('Resultado final'),
        LinhaMetricaResultado(
          rotulo: 'Céu visível final',
          valor: _formatarPercentual(resultado.percentualCeu),
        ),
        const SizedBox(height: 12),
        LinhaMetricaResultado(
          rotulo: 'Dossel estimado final',
          valor: _formatarPercentual(resultado.percentualDossel),
        ),
        const SizedBox(height: 12),
        LinhaMetricaResultado(
          rotulo: 'Diferença automático/final',
          valor: '${diferencaPercentual.toStringAsFixed(2)} pontos percentuais',
        ),
        const SizedBox(height: 12),
        LinhaMetricaResultado(
          rotulo: 'Pixels de céu final',
          valor: resultado.pixelsCeu.toString(),
        ),
        const SizedBox(height: 12),
        LinhaMetricaResultado(
          rotulo: 'Pixels de não céu final',
          valor: resultado.pixelsNaoCeu.toString(),
        ),
      ],
    );
  }
}

String _formatarPercentual(double valor) {
  return '${valor.toStringAsFixed(2)}%';
}
