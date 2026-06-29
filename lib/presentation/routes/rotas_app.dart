import 'package:flutter/material.dart';

import '../pages/analise_page.dart';
import '../pages/analises_salvas_page.dart';
import '../pages/editor_mascara_page.dart';
import '../pages/escolher_imagem_page.dart';
import '../pages/exportacao_page.dart';
import '../pages/nova_analise_page.dart';
import '../pages/processamento_page.dart';
import '../pages/resultados_page.dart';
import '../pages/tela_inicial_page.dart';

/// Nomes de rotas usados pela navegação principal do MVP.
///
/// Centralizar os nomes evita strings duplicadas nas telas e facilita evolução
/// quando a camada de aplicação passar a coordenar o fluxo real.
class RotasApp {
  const RotasApp._();

  static const String inicial = '/';
  static const String novaAnalise = '/nova-analise';
  static const String escolherImagem = '/escolher-imagem';
  static const String processamento = '/processamento';
  static const String analise = '/analise';
  static const String editorMascara = '/editor-mascara';
  static const String resultados = '/resultados';
  static const String analisesSalvas = '/analises-salvas';
  static const String exportacao = '/exportacao';

  static Map<String, WidgetBuilder> get rotas {
    return {
      inicial: (_) => const TelaInicialPage(),
      novaAnalise: (_) => const NovaAnalisePage(),
      escolherImagem: (_) => const EscolherImagemPage(),
      processamento: (_) => const ProcessamentoPage(),
      analise: (_) => const AnalisePage(),
      editorMascara: (_) => const EditorMascaraPage(),
      resultados: (_) => const ResultadosPage(),
      analisesSalvas: (_) => const AnalisesSalvasPage(),
      exportacao: (_) => const ExportacaoPage(),
    };
  }
}
