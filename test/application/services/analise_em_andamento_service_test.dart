import 'package:cobertura_dossel/application/application.dart';
import 'package:cobertura_dossel/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preserva dados da analise em andamento ate o salvamento', () {
    final service = AnaliseEmAndamentoService();
    final analise = Analise(
      id: 'analise-moto-g15',
      nome: 'Teste Moto G15',
      dataCriacao: DateTime(2026, 6, 29, 10),
      dataAtualizacao: DateTime(2026, 6, 29, 10),
      observacoes: 'Captura real em campo',
      versaoAlgoritmo: 'regras_visuais_mvp',
    );

    service.guardarAnalise(analise);

    final recuperada = service.recuperarAnalise();
    expect(recuperada, isNotNull);
    expect(recuperada!.id, 'analise-moto-g15');
    expect(recuperada.nome, 'Teste Moto G15');
    expect(recuperada.observacoes, 'Captura real em campo');

    service.limpar();

    expect(service.recuperarAnalise(), isNull);
  });
}
