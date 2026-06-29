import 'package:sqflite/sqflite.dart';

import '../../domain/entities/analise.dart';
import '../database/banco_dados_local.dart';
import '../mappers/analise_mapper.dart';

/// Repositório local da tabela `analises`.
///
/// A análise é o agregado principal do fluxo. Entidades associadas, como imagem
/// e máscara, são salvas em repositórios próprios para preservar a separação das
/// responsabilidades.
class AnaliseRepository {
  AnaliseRepository(this.bancoDadosLocal);

  final BancoDadosLocal bancoDadosLocal;

  Future<void> salvar(Analise analise) async {
    final banco = await bancoDadosLocal.abrir();
    await banco.insert(
      'analises',
      AnaliseMapper.paraMapa(analise),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Analise?> buscarPorId(String id) async {
    final banco = await bancoDadosLocal.abrir();
    final mapas = await banco.query(
      'analises',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (mapas.isEmpty) {
      return null;
    }

    return AnaliseMapper.deMapa(mapas.first);
  }

  Future<List<Analise>> listarTodos() async {
    final banco = await bancoDadosLocal.abrir();
    final mapas = await banco.query('analises', orderBy: 'data_criacao DESC');
    return mapas.map(AnaliseMapper.deMapa).toList();
  }

  Future<int> atualizar(Analise analise) async {
    final banco = await bancoDadosLocal.abrir();
    return banco.update(
      'analises',
      AnaliseMapper.paraMapa(analise),
      where: 'id = ?',
      whereArgs: [analise.id],
    );
  }

  Future<int> excluir(String id) async {
    final banco = await bancoDadosLocal.abrir();
    return banco.delete('analises', where: 'id = ?', whereArgs: [id]);
  }
}
