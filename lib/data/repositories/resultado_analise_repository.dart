import 'package:sqflite/sqflite.dart';

import '../../domain/entities/resultado_analise.dart';
import '../database/banco_dados_local.dart';
import '../mappers/resultado_analise_mapper.dart';

/// Repositório local da tabela `resultados_analise`.
///
/// Cada resultado fica vinculado à máscara que originou o cálculo, permitindo
/// separar resultado automático preliminar e resultado final validado.
class ResultadoAnaliseRepository {
  ResultadoAnaliseRepository(this.bancoDadosLocal);

  final BancoDadosLocal bancoDadosLocal;

  Future<void> salvar(ResultadoAnalise resultado) async {
    final banco = await bancoDadosLocal.abrir();
    await banco.insert(
      'resultados_analise',
      ResultadoAnaliseMapper.paraMapa(resultado),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ResultadoAnalise?> buscarPorId(String id) async {
    final banco = await bancoDadosLocal.abrir();
    final mapas = await banco.query(
      'resultados_analise',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (mapas.isEmpty) {
      return null;
    }

    return ResultadoAnaliseMapper.deMapa(mapas.first);
  }

  Future<List<ResultadoAnalise>> listarTodos() async {
    final banco = await bancoDadosLocal.abrir();
    final mapas = await banco.query(
      'resultados_analise',
      orderBy: 'data_calculo DESC',
    );
    return mapas.map(ResultadoAnaliseMapper.deMapa).toList();
  }

  Future<List<ResultadoAnalise>> listarPorAnaliseId(String analiseId) async {
    final banco = await bancoDadosLocal.abrir();
    final mapas = await banco.query(
      'resultados_analise',
      where: 'analise_id = ?',
      whereArgs: [analiseId],
      orderBy: 'data_calculo DESC',
    );
    return mapas.map(ResultadoAnaliseMapper.deMapa).toList();
  }

  Future<int> atualizar(ResultadoAnalise resultado) async {
    final banco = await bancoDadosLocal.abrir();
    return banco.update(
      'resultados_analise',
      ResultadoAnaliseMapper.paraMapa(resultado),
      where: 'id = ?',
      whereArgs: [resultado.id],
    );
  }

  Future<int> excluir(String id) async {
    final banco = await bancoDadosLocal.abrir();
    return banco.delete('resultados_analise', where: 'id = ?', whereArgs: [id]);
  }
}
