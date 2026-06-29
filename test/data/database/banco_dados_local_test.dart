import 'package:flutter_test/flutter_test.dart';

import '../banco_teste_utils.dart';

void main() {
  setUpAll(inicializarBancoFfiParaTestes);

  test('cria o banco local em memória para os testes da Fase 2', () async {
    final bancoDadosLocal = criarBancoEmMemoria();

    final banco = await bancoDadosLocal.abrir();

    expect(banco.isOpen, isTrue);

    await bancoDadosLocal.fechar();
  });

  test('cria todas as tabelas SQLite previstas para o MVP', () async {
    final bancoDadosLocal = criarBancoEmMemoria();
    final banco = await bancoDadosLocal.abrir();

    final tabelas = await banco.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );
    final nomesTabelas = tabelas.map((linha) => linha['name']).toSet();

    expect(
      nomesTabelas,
      containsAll({
        'analises',
        'imagens',
        'mascaras',
        'resultados_analise',
        'metadados_analise',
        'edicoes_mascara',
        'exportacoes',
        'itens_dataset_treinamento',
      }),
    );

    await bancoDadosLocal.fechar();
  });
}
