import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:engenharia_de_software/ui/screens/signup_screen.dart';

void main() {
  testWidgets('SignupScreen - renderiza corretamente os campos e textos', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SignupScreen()),
    );

    // Título da AppBar
    expect(find.text('Criar Conta'), findsOneWidget);

    // Texto de instrução
    expect(find.text('Preencha os dados para se cadastrar'), findsOneWidget);

    // Campos de texto
    expect(find.widgetWithText(TextFormField, 'Nome Completo'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'CPF'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Senha'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Confirmar Senha'), findsOneWidget);

    // Botão Cadastrar
    expect(find.widgetWithText(ElevatedButton, 'Cadastrar'), findsOneWidget);
  });

  testWidgets('SignupScreen - alterna visibilidade dos campos de senha', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SignupScreen()),
    );

    // Ícone inicial da senha = visibility_off
    expect(find.byIcon(Icons.visibility_off), findsNWidgets(2)); // dois campos senha

    // Clicar no ícone do campo "Senha"
    await tester.tap(find.widgetWithIcon(IconButton, Icons.visibility_off).first);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.visibility), findsOneWidget);

    // Clicar no ícone do campo "Confirmar Senha"
    await tester.tap(find.widgetWithIcon(IconButton, Icons.visibility_off).last);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.visibility), findsNWidgets(2));
  });

  testWidgets('SignupScreen - mostra snackbar erro se senhas diferentes', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SignupScreen()),
    );

    // Preenche campos de senha diferentes
    await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), '123456');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirmar Senha'), '654321');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastrar'));
    await tester.pump(); // para mostrar snackbar

    // Snackbar deve aparecer com texto de erro de senha
    expect(find.text('As senhas não coincidem!'), findsOneWidget);
  });

  testWidgets('SignupScreen - mostra snackbar erro se campos obrigatórios vazios', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SignupScreen()),
    );

    // Senhas iguais para passar validação anterior
    await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), '123456');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirmar Senha'), '123456');

    // Não preenche nome, cpf ou email (vazio)

    await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastrar'));
    await tester.pump(); // para mostrar snackbar

    // Snackbar deve aparecer com texto de erro sobre campos vazios
    expect(find.text('Por favor, preencha todos os campos.'), findsOneWidget);
  });

  testWidgets('SignupScreen - aceita clique no botão Cadastrar com dados válidos', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SignupScreen()),
    );

    // Preenche todos os campos corretamente
    await tester.enterText(find.widgetWithText(TextFormField, 'Nome Completo'), 'Maria Silva');
    await tester.enterText(find.widgetWithText(TextFormField, 'CPF'), '123.456.789-00');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'maria@email.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), '123456');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirmar Senha'), '123456');

    // Clica no botão Cadastrar
    await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastrar'));
    await tester.pump();

    // Apenas verificamos que o botão está lá e a ação não causa erro no widget
    expect(find.widgetWithText(ElevatedButton, 'Cadastrar'), findsOneWidget);
  });
}
