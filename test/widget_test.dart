import 'package:cobertura_dossel/presentation/app/cobertura_dossel_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app renderiza a Tela Inicial', (tester) async {
    await tester.pumpWidget(const CoberturaDosselApp());

    expect(find.text('Cobertura Dossel'), findsWidgets);
    expect(
      find.textContaining('imagem digital e máscara validada'),
      findsOneWidget,
    );
    expect(
      find.textContaining('não usa inteligência artificial'),
      findsOneWidget,
    );
    expect(find.textContaining('não mede LAI diretamente'), findsOneWidget);
    expect(find.textContaining('ainda não gera PDF'), findsOneWidget);
  });
}
