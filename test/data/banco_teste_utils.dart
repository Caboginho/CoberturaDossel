import 'package:cobertura_dossel/data/data.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void inicializarBancoFfiParaTestes() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

BancoDadosLocal criarBancoEmMemoria() {
  return BancoDadosLocal(
    caminhoBanco: inMemoryDatabasePath,
    fabricaBanco: databaseFactoryFfi,
  );
}
