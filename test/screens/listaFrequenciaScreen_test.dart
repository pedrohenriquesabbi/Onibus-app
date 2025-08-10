import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:engenharia_de_software/ui/screens/listaFrequencia_screen.dart';

void main() {
  testWidgets('ListaFrequenciaScreen exibe título, total e lista de registros',
      (WidgetTester tester) async {
    // Monta o widget dentro de um MaterialApp para suporte a Scaffold e temas
    await tester.pumpWidget(
      MaterialApp(
        home: ListaFrequenciaScreen(),
      ),
    );

    // Verifica título do AppBar
    expect(find.text('Lista de Frequência'), findsOneWidget);

    // Verifica texto com total de registros
    expect(find.text('Total: 5'), findsOneWidget);

    // Verifica se há exatamente 5 Cards (um por registro)
    expect(find.byType(Card), findsNWidgets(5));

    // Verifica se um nome específico está visível na lista
    expect(find.text('Maria Eduarda Silva'), findsOneWidget);

    // Verifica se um CPF específico está visível (parte do subtitle)
    expect(find.textContaining('CPF: 111.222.333-44'), findsOneWidget);

    // Verifica se o status "Presente" aparece (nos Chips)
    expect(find.text('Presente'), findsNWidgets(5));

    // Verifica se o primeiro caractere do nome aparece no CircleAvatar
    expect(find.text('M'), findsWidgets);
  });
}
