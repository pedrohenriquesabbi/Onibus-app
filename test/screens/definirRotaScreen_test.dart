import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:engenharia_de_software/ui/screens/definirRota_screen.dart';

void main() {
  testWidgets('DefinirRotaScreen - interações básicas e diálogos',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DefinirRotaScreen()),
    );

    // Verifica se os textos principais aparecem
    expect(find.text('Cidade onde moro:'), findsOneWidget);
    expect(find.text('Universidade em que estudo:'), findsOneWidget);
    expect(find.text('Motorista do meu ônibus:'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'SALVAR'), findsOneWidget);

    // Tenta clicar no botão SALVAR sem preencher nada e verifica diálogo de erro
    await tester.tap(find.widgetWithText(ElevatedButton, 'SALVAR'));
    await tester.pumpAndSettle();

    expect(find.text('Atenção!'), findsOneWidget);
    expect(find.text('Por favor, selecione todas as opções antes de salvar.'), findsOneWidget);

    // Fecha o diálogo de erro
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Atenção!'), findsNothing);

    // Seleciona uma opção em cada Dropdown

    // Cidade
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tianguá').last);
    await tester.pumpAndSettle();

    // Universidade
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('IFCE-Tianguá').last);
    await tester.pumpAndSettle();

    // Motorista
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sr. Ronaldo').last);
    await tester.pumpAndSettle();

    // Agora clica no SALVAR novamente e verifica diálogo de sucesso
    await tester.tap(find.widgetWithText(ElevatedButton, 'SALVAR'));
    await tester.pumpAndSettle();

    expect(find.text('Sucesso!'), findsOneWidget);
    expect(find.text('Sua rota foi salva com sucesso.'), findsOneWidget);

    // Fecha o diálogo de sucesso
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Sucesso!'), findsNothing);
  });
}
