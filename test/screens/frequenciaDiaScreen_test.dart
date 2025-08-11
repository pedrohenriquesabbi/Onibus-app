import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:engenharia_de_software/ui/screens/frequenciaDia_screen.dart';

void main() {
  testWidgets('Renderiza todos os elementos da tela corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: FrequenciaDoDiaScreen()),
    );

    // AppBar
    expect(find.text('Frequência do Dia'), findsOneWidget);

    // Ícone do ônibus
    expect(find.byIcon(Icons.directions_bus), findsOneWidget);

    // Texto principal
    expect(find.text('Selecionar Itinerário'), findsOneWidget);

    // Texto da data formatada (pelo menos verifica parte do texto)
    expect(find.textContaining('Frequência do dia:'), findsOneWidget);

    // Opções de rádio
    expect(find.text('Ida e Volta'), findsOneWidget);
    expect(find.text('Apenas Ida'), findsOneWidget);
    expect(find.text('Apenas Volta'), findsOneWidget);
    expect(find.text('Não vou hoje'), findsOneWidget);

    // Botão SALVAR
    expect(find.widgetWithText(ElevatedButton, 'SALVAR'), findsOneWidget);
  });

  testWidgets('Permite selecionar opções de itinerário', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: FrequenciaDoDiaScreen()),
    );

    // Nenhuma opção selecionada inicialmente
    final radioFinder = find.byType(RadioListTile<ItinerarioOption>);
    expect(radioFinder, findsNWidgets(4));

    // Seleciona a opção 'Apenas Ida'
    await tester.tap(find.text('Apenas Ida'));
    await tester.pumpAndSettle();

    // Verifica que 'Apenas Ida' está selecionada (RadioListTile fica selecionado)
    RadioListTile radioApenasIda = tester.widget(find.widgetWithText(RadioListTile, 'Apenas Ida'));
    expect(radioApenasIda.checked, isTrue);

    // Seleciona a opção 'Não vou hoje'
    await tester.tap(find.text('Não vou hoje'));
    await tester.pumpAndSettle();

    RadioListTile radioNaoVou = tester.widget(find.widgetWithText(RadioListTile, 'Não vou hoje'));
    expect(radioNaoVou.checked, isTrue);
  });

  testWidgets('Mostra CircularProgressIndicator enquanto carrega a página', (WidgetTester tester) async {
    // Para simular o _isPageLoading = true, podemos criar um StatefulWidget com este estado inicial

    // Criar um wrapper simples que permita setar o estado, ou usar o próprio estado default.

    // Aqui o widget inicia com _isPageLoading true e só troca depois de um delay, mas como _carregarFrequenciaDoDia é async, podemos usar pump com delay.

    await tester.pumpWidget(
      const MaterialApp(home: FrequenciaDoDiaScreen()),
    );

    // No início, deve aparecer o CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Depois de aguardar (simula fim do carregamento)
    await tester.pumpAndSettle();

    // O CircularProgressIndicator desaparece
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Botão SALVAR fica desabilitado ao salvar e habilitado após', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: FrequenciaDoDiaScreen()),
    );

    // Aguarda carregamento da página inicial
    await tester.pumpAndSettle();

    final buttonFinder = find.widgetWithText(ElevatedButton, 'SALVAR');
    expect(buttonFinder, findsOneWidget);

    // Inicialmente o botão está habilitado
    ElevatedButton button = tester.widget(buttonFinder);
    expect(button.onPressed, isNotNull);

    // Seleciona uma opção
    await tester.tap(find.text('Ida e Volta'));
    await tester.pumpAndSettle();

    // Simula clique no botão SALVAR (chama _salvarItinerario)
    await tester.tap(buttonFinder);

    // Ao chamar _salvarItinerario, o botão fica desabilitado (_isLoading = true)
    await tester.pump();

    ElevatedButton buttonLoading = tester.widget(buttonFinder);
    expect(buttonLoading.onPressed, isNull);

    // Como o método é async, fazemos pumpAndSettle para esperar a conclusão
    await tester.pumpAndSettle();

    // Depois o botão volta a estar habilitado
    ElevatedButton buttonFinal = tester.widget(buttonFinder);
    expect(buttonFinal.onPressed, isNotNull);
  });

  testWidgets('Mostra diálogo de erro se nenhuma opção selecionada ao salvar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: FrequenciaDoDiaScreen()),
    );

    await tester.pumpAndSettle();

    // Sem selecionar nenhuma opção, tenta salvar
    await tester.tap(find.widgetWithText(ElevatedButton, 'SALVAR'));
    await tester.pumpAndSettle();

    // Deve aparecer um AlertDialog com título "Atenção!"
    expect(find.text('Atenção!'), findsOneWidget);
    expect(find.text('Por favor, selecione uma das opções de itinerário.'), findsOneWidget);

    // Fecha o diálogo
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Atenção!'), findsNothing);
  });

  testWidgets('Mostra diálogo de sucesso após salvar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: FrequenciaDoDiaScreen()),
    );

    await tester.pumpAndSettle();

    // Seleciona uma opção
    await tester.tap(find.text('Apenas Ida'));
    await tester.pumpAndSettle();

    // Pressiona SALVAR
    await tester.tap(find.widgetWithText(ElevatedButton, 'SALVAR'));

    // pumpAndSettle para esperar a execução e abrir diálogo
    await tester.pumpAndSettle();

    // Deve aparecer diálogo de sucesso
    expect(find.text('Sucesso!'), findsOneWidget);
    expect(find.text('Sua frequência para hoje foi salva.'), findsOneWidget);

    // Fecha o diálogo
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Sucesso!'), findsNothing);
  });
}
