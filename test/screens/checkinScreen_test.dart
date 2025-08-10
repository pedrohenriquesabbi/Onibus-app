import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:engenharia_de_software/ui/screens/checkIn_screen.dart';

void main() {
  testWidgets('CheckInScreen inicia corretamente e faz check-in',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CheckInScreen()),
    );

    // Verifica título da AppBar
    expect(find.text('Frequência'), findsOneWidget);

    // Verifica texto REGISTRO DO DIA aparece (não checamos data fixa)
    expect(find.byWidgetPredicate((w) {
      if (w is Text) {
        return w.data != null && w.data!.startsWith('REGISTRO DO DIA: ');
      }
      return false;
    }), findsOneWidget);

    // Verifica o botão com texto CHECK-IN está presente e habilitado
    final checkInButton = find.widgetWithText(ElevatedButton, 'CHECK-IN');
    expect(checkInButton, findsOneWidget);
    expect(tester.widget<ElevatedButton>(checkInButton).enabled, isTrue);

    // Verifica que o texto de instrução está para antes do check-in
    expect(find.text('Aperte o botão acima para registrar\nsua entrada no ônibus'), findsOneWidget);

    // Clica no botão CHECK-IN
    await tester.tap(checkInButton);
    await tester.pump(); // rebuild após setState
    await tester.pump(const Duration(seconds: 1)); // para o showDialog animar

    // Agora o botão deve estar desabilitado (onPressed == null)
    final disabledButton = find.byType(ElevatedButton);
    expect(tester.widget<ElevatedButton>(disabledButton).enabled, isFalse);

    // O botão deve mostrar o ícone de check agora
    expect(find.byIcon(Icons.check), findsOneWidget);

    // O diálogo de confirmação aparece com título "Sucesso!"
    expect(find.text('Sucesso!'), findsOneWidget);
    expect(find.text('Check-in realizado com sucesso!'), findsOneWidget);

    // Fecha o diálogo
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // O diálogo deve desaparecer
    expect(find.text('Sucesso!'), findsNothing);

    // O texto de instrução deve mudar para a mensagem pós check-in
    expect(find.text('Seu registro de hoje foi concluído!'), findsOneWidget);
  });
}
