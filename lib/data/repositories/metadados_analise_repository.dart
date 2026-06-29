import 'package:sqflite/sqflite.dart';

import '../../domain/entities/metadados_analise.dart';
import '../database/banco_dados_local.dart';
import '../mappers/metadados_analise_mapper.dart';

/// Repositório local da tabela `metadados_analise`.
///
/// Metadados contextualizam a coleta e ajudam na interpretação científica, mas
/// não modificam imagem, máscara ou resultado.
class MetadadosAnaliseRepository {
  MetadadosAnaliseRepository(this.bancoDadosLocal);

  final BancoDadosLocal bancoDadosLocal;

  Future<void> salvar(MetadadosAnalise metadados) async {
    final banco = await bancoDadosLocal.abrir();
    await banco.insert(
      'metadados_analise',
      MetadadosAnaliseMapper.paraMapa(metadados),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MetadadosAnalise?> buscarPorId(String id) async {
    final banco = await bancoDadosLocal.abrir();
    final mapas = await banco.query(
      'metadados_analise',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (mapas.isEmpty) {
      return null;
    }

    return MetadadosAnaliseMapper.deMapa(mapas.first);
  }

  Future<MetadadosAnalise?> buscarPorAnaliseId(String analiseId) async {
    final banco = await bancoDadosLocal.abrir();
    final mapas = await banco.query(
      'metadados_analise',
      where: 'analise_id = ?',
      whereArgs: [analiseId],
      limit: 1,
    );

    if (mapas.isEmpty) {
      return null;
    }

    return MetadadosAnaliseMapper.deMapa(mapas.first);
  }

  Future<List<MetadadosAnalise>> listarTodos() async {
    final banco = await bancoDadosLocal.abrir();
    final mapas = await banco.query('metadados_analise');
    return mapas.map(MetadadosAnaliseMapper.deMapa).toList();
  }

  Future<int> atualizar(MetadadosAnalise metadados) async {
    final banco = await bancoDadosLocal.abrir();
    return banco.update(
      'metadados_analise',
      MetadadosAnaliseMapper.paraMapa(metadados),
      where: 'id = ?',
      whereArgs: [metadados.id],
    );
  }

  Future<int> excluir(String id) async {
    final banco = await bancoDadosLocal.abrir();
    return banco.delete('metadados_analise', where: 'id = ?', whereArgs: [id]);
  }
}
