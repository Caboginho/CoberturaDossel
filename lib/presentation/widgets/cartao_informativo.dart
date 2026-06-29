import 'package:flutter/material.dart';

/// Bloco visual simples para mensagens de orientação e placeholders.
///
/// O uso deste widget deixa explícito quando uma parte da tela é informativa e
/// ainda não representa funcionalidade real do MVP.
class CartaoInformativo extends StatelessWidget {
  const CartaoInformativo({
    required this.titulo,
    required this.texto,
    this.icone,
    super.key,
  });

  final String titulo;
  final String texto;
  final IconData? icone;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icone != null) ...[
              Icon(icone, color: tema.colorScheme.primary),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: tema.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(texto),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
