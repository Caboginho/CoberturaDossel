import 'package:flutter/material.dart';

/// Botão principal reutilizado nas telas iniciais do fluxo.
///
/// O componente mantém botões com ícone, texto e tamanho consistentes para que
/// a interface continue simples de manter nas próximas fases.
class BotaoPrimario extends StatelessWidget {
  const BotaoPrimario({
    required this.rotulo,
    required this.icone,
    required this.aoPressionar,
    super.key,
  });

  final String rotulo;
  final IconData icone;
  final VoidCallback? aoPressionar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: aoPressionar,
        icon: Icon(icone),
        label: Text(rotulo),
      ),
    );
  }
}
