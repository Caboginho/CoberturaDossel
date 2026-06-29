import 'package:flutter/material.dart';

/// Título curto para separar blocos importantes das telas.
class TituloSecao extends StatelessWidget {
  const TituloSecao(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(texto, style: Theme.of(context).textTheme.titleLarge);
  }
}
