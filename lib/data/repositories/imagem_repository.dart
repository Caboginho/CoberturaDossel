import 'package:sqflite/sqflite.dart';

import '../../domain/entities/imagem.dart';
import '../database/banco_dados_local.dart';
import '../mappers/imagem_mapper.dart';

/// Repositório local da tabela `imagens`.
///
/// A imagem original é persistida apenas como caminho e metadados. O repositório
/// não altera nem copia o arquivo de imagem.
class ImagemRepository {
  ImagemRepository(this.bancoDadosLocal);

  final BancoDadosLocal bancoDadosLocal;

  Future<void> salvar(Imagem imagem) async {
    final banco = await bancoDadosLocal.abrir();
    await banco.insert(
      'imagens',
      ImagemMapper.paraMapa(imagem),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Imagem?> buscarPorId(String id) async {
    final banco = await bancoDadosLocal.abrir();
    final mapas = await banco.query(
      'imagens',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (mapas.isEmpty) {
      return null;
    }

    return ImagemMapper.deMapa(mapas.first);
  }

  Future<List<Imagem>> listarTodos() async {
    final banco = await bancoDadosLocal.abrir();
    final mapas = await banco.query('imagens', orderBy: 'data_importacao DESC');
    return mapas.map(ImagemMapper.deMapa).toList();
  }

  Future<List<Imagem>> listarPorAnaliseId(String analiseId) async {
    final banco = await bancoDadosLocal.abrir();
    final mapas = await banco.query(
      'imagens',
      where: 'analise_id = ?',
      whereArgs: [analiseId],
      orderBy: 'data_importacao DESC',
    );
    return mapas.map(ImagemMapper.deMapa).toList();
  }

  Future<int> atualizar(Imagem imagem) async {
    final banco = await bancoDadosLocal.abrir();
    return banco.update(
      'imagens',
      ImagemMapper.paraMapa(imagem),
      where: 'id = ?',
      whereArgs: [imagem.id],
    );
  }

  Future<int> excluir(String id) async {
    final banco = await bancoDadosLocal.abrir();
    return banco.delete('imagens', where: 'id = ?', whereArgs: [id]);
  }
}
