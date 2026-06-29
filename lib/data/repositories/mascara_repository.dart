import 'package:sqflite/sqflite.dart';

import '../../domain/entities/mascara.dart';
import '../database/banco_dados_local.dart';
import '../mappers/mascara_mapper.dart';

/// Repositório local da tabela `mascaras`.
///
/// Máscaras são arquivos separados da imagem original. O repositório persiste o
/// caminho da máscara e as contagens de pixels necessárias para os cálculos.
class MascaraRepository {
  MascaraRepository(this.bancoDadosLocal);

  final BancoDadosLocal bancoDadosLocal;

  Future<void> salvar(Mascara mascara) async {
    final banco = await bancoDadosLocal.abrir();
    await banco.insert(
      'mascaras',
      MascaraMapper.paraMapa(mascara),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Mascara?> buscarPorId(String id) async {
    final banco = await bancoDadosLocal.abrir();
    final mapas = await banco.query(
      'mascaras',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (mapas.isEmpty) {
      return null;
    }

    return MascaraMapper.deMapa(mapas.first);
  }

  Future<List<Mascara>> listarTodos() async {
    final banco = await bancoDadosLocal.abrir();
    final mapas = await banco.query('mascaras', orderBy: 'data_criacao DESC');
    return mapas.map(MascaraMapper.deMapa).toList();
  }

  Future<List<Mascara>> listarPorAnaliseId(String analiseId) async {
    final banco = await bancoDadosLocal.abrir();
    final mapas = await banco.query(
      'mascaras',
      where: 'analise_id = ?',
      whereArgs: [analiseId],
      orderBy: 'data_criacao DESC',
    );
    return mapas.map(MascaraMapper.deMapa).toList();
  }

  Future<int> atualizar(Mascara mascara) async {
    final banco = await bancoDadosLocal.abrir();
    return banco.update(
      'mascaras',
      MascaraMapper.paraMapa(mascara),
      where: 'id = ?',
      whereArgs: [mascara.id],
    );
  }

  Future<int> excluir(String id) async {
    final banco = await bancoDadosLocal.abrir();
    return banco.delete('mascaras', where: 'id = ?', whereArgs: [id]);
  }
}
