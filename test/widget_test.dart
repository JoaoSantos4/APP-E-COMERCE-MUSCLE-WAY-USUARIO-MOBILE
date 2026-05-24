import 'package:app_muscley/src/app.muscley.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mostra tela de login do Muscleway', (WidgetTester tester) async {
    await tester.pumpWidget(const AppMuscley());

    expect(find.text('Muscleway'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar uma conta Muscleway'), findsOneWidget);
  });
}
