import 'package:flutter/material.dart';

/// Estrutura comum das páginas da Fase 3.
///
/// Mantém largura máxima e espaçamento consistentes sem acoplar as telas a
/// regras de negócio ou persistência.
class PaginaBase extends StatelessWidget {
  const PaginaBase({
    required this.titulo,
    required this.filhos,
    this.mostrarVoltar = true,
    super.key,
  });

  final String titulo;
  final List<Widget> filhos;
  final bool mostrarVoltar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        automaticallyImplyLeading: mostrarVoltar,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _comEspacamento(filhos),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _comEspacamento(List<Widget> itens) {
    return [
      for (var indice = 0; indice < itens.length; indice++) ...[
        if (indice > 0) const SizedBox(height: 16),
        itens[indice],
      ],
    ];
  }
}
