T enumPorNome<T extends Enum>(List<T> valores, String nome) {
  return valores.firstWhere((valor) => valor.name == nome);
}

int boolParaInteiro(bool valor) => valor ? 1 : 0;

bool inteiroParaBool(Object? valor) => valor == 1;

String dataParaTexto(DateTime data) => data.toIso8601String();

DateTime textoParaData(Object? valor) => DateTime.parse(valor! as String);

String? dataOpcionalParaTexto(DateTime? data) => data?.toIso8601String();

DateTime? textoParaDataOpcional(Object? valor) {
  if (valor == null) {
    return null;
  }
  return DateTime.parse(valor as String);
}
