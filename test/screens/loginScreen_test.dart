import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:engenharia_de_software/ui/screens/login_screen.dart';
import 'package:engenharia_de_software/ui/screens/home_screen.dart';
import 'package:engenharia_de_software/ui/screens/signup_screen.dart';

void main() {
  testWidgets('LoginScreen - renderiza, troca visibilidade e navega', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginScreen()),
    );

    // Verifica se o texto "Bem-vindo de volta!" está presente
    expect(find.text('Bem-vindo de volta!'), findsOneWidget);

    // Verifica se o campo email está presente
    expect(find.byType(TextFormField), findsNWidgets(2));

    // Verifica que inicialmente o ícone é visibility_off (senha oculta)
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);

    // Clica no botão para mostrar a senha
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pumpAndSettle();

    // Agora o ícone deve ser visibility (senha visível)
    expect(find.byIcon(Icons.visibility), findsOneWidget);

    // Clica no ícone para alternar visibilidade da senha
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pumpAndSettle();

    // Clica no botão Entrar e verifica navegação para HomeScreen
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);

    // Volta para o LoginScreen para testar o botão de cadastro
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Clica no botão "Não tem uma conta? Cadastre-se"
    await tester.tap(find.text('Não tem uma conta? Cadastre-se'));
    await tester.pumpAndSettle();

    // Verifica navegação para SignupScreen
    expect(find.byType(SignupScreen), findsOneWidget);
  });
}
