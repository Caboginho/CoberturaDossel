import 'package:flutter/material.dart';

import '../routes/rotas_app.dart';

/// Aplicativo principal da Fase 3.
///
/// Nesta fase o app configura tema, título e rotas iniciais. As telas ainda não
/// acessam câmera, galeria, segmentação real, editor real ou exportação real.
class CoberturaDosselApp extends StatelessWidget {
  const CoberturaDosselApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cobertura Dossel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      initialRoute: RotasApp.inicial,
      routes: RotasApp.rotas,
    );
  }
}
