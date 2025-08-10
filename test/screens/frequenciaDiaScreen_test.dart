import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:engenharia_de_software/ui/screens/frequenciaDia_screen.dart';

void main() {
  testWidgets('FrequenciaDoDiaScreen - seleção e diálogos', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: FrequenciaDoDiaScreen()),
    );

    // Verifica os textos básicos
    expect(find.text('Selecionar Itinerário'), findsOneWidget);
    expect(find.text('SALVAR'), findsOneWidget);

    // Tenta salvar sem selecionar nada: deve aparecer diálogo de erro
    await tester.tap(find.text('SALVAR'));
    await tester.pumpAndSettle();

    expect(find.text('Atenção!'), findsOneWidget);
    expect(find.text('Por favor, selecione uma das opções de itinerário.'), findsOneWidget);

    // Fecha o diálogo de erro
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Atenção!'), findsNothing);

    // Seleciona a opção "Apenas Ida"
    await tester.tap(find.text('Apenas Ida'));
    await tester.pumpAndSettle();

    // Confirma que o radio está selecionado
    final radioApenasIda = find.byWidgetPredicate((widget) {
      if (widget is RadioListTile) {
        return widget.value == ItinerarioOption.apenasIda && widget.groupValue == ItinerarioOption.apenasIda;
      }
      return false;
    });
    expect(radioApenasIda, findsOneWidget);

    // Clica em salvar agora que tem opção selecionada
    await tester.tap(find.text('SALVAR'));
    await tester.pumpAndSettle();

    expect(find.text('Sucesso!'), findsOneWidget);
    expect(find.text('Sua frequência para hoje foi salva.'), findsOneWidget);

    // Fecha o diálogo de sucesso
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Sucesso!'), findsNothing);
  });
}
