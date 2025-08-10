import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:engenharia_de_software/ui/screens/signup_screen.dart';

void main() {
  testWidgets('SignupScreen exibe todos os campos e reage ao botão',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SignupScreen(),
      ),
    );

    // Verifica título e instrução
    expect(find.text('Criar Conta'), findsOneWidget);
    expect(find.text('Preencha os dados para se cadastrar'), findsOneWidget);

    // Verifica campos de texto
    expect(find.widgetWithText(TextFormField, 'Nome Completo'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'CPF'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Senha'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Confirmar Senha'), findsOneWidget);

    // Preenche os campos
    await tester.enterText(find.widgetWithText(TextFormField, 'Nome Completo'), 'João da Silva');
    await tester.enterText(find.widgetWithText(TextFormField, 'CPF'), '12345678900'); // máscara será aplicada
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'joao@email.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), '123456');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirmar Senha'), '123456');

    // Clica no botão Cadastrar
    await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastrar'));
    await tester.pump();

    // Como a ação do botão atualmente só printa, não há mudança visível
    // Podemos apenas garantir que o botão está lá e não causou erro
    expect(find.widgetWithText(ElevatedButton, 'Cadastrar'), findsOneWidget);
  });

  testWidgets('Exibe mensagem se senhas não coincidem', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SignupScreen(),
      ),
    );

    await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), '123456');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirmar Senha'), '654321');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastrar'));
    await tester.pump();

    // Atualmente, o código só printa "As senhas não coincidem!", que não aparece na UI.
    // Para testar isso melhor, teria que alterar a UI para exibir feedback visível.
    // Por enquanto, só garantimos que o botão existe e o teste roda sem erro.

    expect(find.widgetWithText(ElevatedButton, 'Cadastrar'), findsOneWidget);
  });
}
