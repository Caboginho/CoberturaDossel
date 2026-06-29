import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Gerencia a abertura, criação e versionamento do banco SQLite local.
///
/// O banco armazena metadados, caminhos de arquivos e resultados. Imagens
/// originais e máscaras permanecem como arquivos separados para preservar a
/// imagem original e manter rastreabilidade científica.
class BancoDadosLocal {
  BancoDadosLocal({this.caminhoBanco, DatabaseFactory? fabricaBanco})
    : fabricaBanco = fabricaBanco ?? databaseFactory;

  static const String nomeBanco = 'cobertura_dossel.db';
  static const int versaoBanco = 1;

  final String? caminhoBanco;
  final DatabaseFactory fabricaBanco;

  Database? _banco;

  /// Abre o banco local e cria as tabelas quando necessário.
  Future<Database> abrir() async {
    final bancoAberto = _banco;
    if (bancoAberto != null && bancoAberto.isOpen) {
      return bancoAberto;
    }

    final caminho =
        caminhoBanco ??
        p.join(await fabricaBanco.getDatabasesPath(), nomeBanco);

    _banco = await fabricaBanco.openDatabase(
      caminho,
      options: OpenDatabaseOptions(
        version: versaoBanco,
        onConfigure: _configurarBanco,
        onCreate: _criarBanco,
      ),
    );

    return _banco!;
  }

  /// Fecha a conexão aberta, útil principalmente em testes automatizados.
  Future<void> fechar() async {
    final bancoAberto = _banco;
    if (bancoAberto != null && bancoAberto.isOpen) {
      await bancoAberto.close();
    }
    _banco = null;
  }

  Future<void> _configurarBanco(Database banco) async {
    await banco.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _criarBanco(Database banco, int versao) async {
    await banco.execute('''
      CREATE TABLE analises (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        data_criacao TEXT NOT NULL,
        data_atualizacao TEXT NOT NULL,
        observacoes TEXT NOT NULL DEFAULT '',
        versao_algoritmo TEXT NOT NULL DEFAULT '',
        status_validacao INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await banco.execute('''
      CREATE TABLE imagens (
        id TEXT PRIMARY KEY,
        analise_id TEXT NOT NULL,
        caminho_arquivo TEXT NOT NULL,
        largura INTEGER NOT NULL,
        altura INTEGER NOT NULL,
        formato TEXT NOT NULL,
        origem TEXT NOT NULL,
        data_captura TEXT,
        data_importacao TEXT,
        FOREIGN KEY (analise_id) REFERENCES analises(id) ON DELETE CASCADE
      )
    ''');

    await banco.execute('''
      CREATE TABLE mascaras (
        id TEXT PRIMARY KEY,
        analise_id TEXT NOT NULL,
        tipo_mascara TEXT NOT NULL,
        caminho_arquivo TEXT NOT NULL,
        largura INTEGER NOT NULL,
        altura INTEGER NOT NULL,
        pixels_ceu INTEGER NOT NULL,
        pixels_nao_ceu INTEGER NOT NULL,
        pixels_invalidos INTEGER NOT NULL,
        origem_mascara TEXT NOT NULL DEFAULT '',
        data_criacao TEXT NOT NULL,
        FOREIGN KEY (analise_id) REFERENCES analises(id) ON DELETE CASCADE
      )
    ''');

    await banco.execute('''
      CREATE TABLE resultados_analise (
        id TEXT PRIMARY KEY,
        analise_id TEXT NOT NULL,
        mascara_id TEXT NOT NULL,
        tipo_resultado TEXT NOT NULL,
        pixels_validos INTEGER NOT NULL,
        pixels_ceu INTEGER NOT NULL,
        pixels_nao_ceu INTEGER NOT NULL,
        percentual_ceu REAL NOT NULL,
        percentual_dossel REAL NOT NULL,
        diferenca_percentual REAL,
        data_calculo TEXT NOT NULL,
        FOREIGN KEY (analise_id) REFERENCES analises(id) ON DELETE CASCADE,
        FOREIGN KEY (mascara_id) REFERENCES mascaras(id) ON DELETE CASCADE
      )
    ''');

    await banco.execute('''
      CREATE TABLE metadados_analise (
        id TEXT PRIMARY KEY,
        analise_id TEXT NOT NULL UNIQUE,
        local_descricao TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        condicao_ceu TEXT NOT NULL,
        tipo_ambiente TEXT NOT NULL,
        observacoes_campo TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (analise_id) REFERENCES analises(id) ON DELETE CASCADE
      )
    ''');

    await banco.execute('''
      CREATE TABLE edicoes_mascara (
        id TEXT PRIMARY KEY,
        analise_id TEXT NOT NULL,
        mascara_id TEXT NOT NULL,
        data_hora TEXT NOT NULL,
        ferramenta TEXT NOT NULL,
        classe_aplicada TEXT NOT NULL,
        tamanho_pincel REAL NOT NULL,
        descricao TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (analise_id) REFERENCES analises(id) ON DELETE CASCADE,
        FOREIGN KEY (mascara_id) REFERENCES mascaras(id) ON DELETE CASCADE
      )
    ''');

    await banco.execute('''
      CREATE TABLE exportacoes (
        id TEXT PRIMARY KEY,
        analise_id TEXT NOT NULL,
        formato TEXT NOT NULL,
        caminho_arquivo TEXT NOT NULL,
        data_exportacao TEXT NOT NULL,
        FOREIGN KEY (analise_id) REFERENCES analises(id) ON DELETE CASCADE
      )
    ''');

    await banco.execute('''
      CREATE TABLE itens_dataset_treinamento (
        id TEXT PRIMARY KEY,
        analise_id TEXT NOT NULL,
        caminho_imagem_original TEXT NOT NULL,
        caminho_mascara_automatica TEXT NOT NULL,
        caminho_mascara_final TEXT NOT NULL,
        versao_algoritmo TEXT NOT NULL DEFAULT '',
        diferenca_percentual REAL,
        autorizado INTEGER NOT NULL DEFAULT 0,
        data_registro TEXT NOT NULL,
        FOREIGN KEY (analise_id) REFERENCES analises(id) ON DELETE CASCADE
      )
    ''');
  }
}
