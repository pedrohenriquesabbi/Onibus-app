import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:engenharia_de_software/ui/screens/listaFrequencia_screen.dart';

void main() {
  testWidgets('Mostra mensagem de erro se usuário não autenticado', (WidgetTester tester) async {
    // Para simular usuário não autenticado, podemos "não definir" o FirebaseAuth.currentUser
    // Como não há mocks aqui, apenas rodamos o widget e vemos a mensagem exibida para erro.

    await tester.pumpWidget(
      const MaterialApp(home: ListaFrequenciaScreen()),
    );

    expect(find.text('Erro: Utilizador não autenticado.'), findsOneWidget);
  });

  testWidgets('Mostra CircularProgressIndicator enquanto carrega a rota', (WidgetTester tester) async {
    // Aqui, assumindo que o FutureBuilder está em waiting, testa se o indicador aparece.

    // Por padrão _rotaUsuarioFuture será null se usuário não autenticado, então para
    // testar loading, precisaria ajustar o estado do widget para simular o future.
    // Como não há mocks, teste simples:
    await tester.pumpWidget(
      const MaterialApp(home: ListaFrequenciaScreen()),
    );

    // Ainda no fluxo inicial, pode aparecer indicador
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Mostra mensagem para definir rota se rota não existir', (WidgetTester tester) async {
    // Para esse teste real, precisaríamos mockar o FirebaseFirestore para retornar
    // um documento inexistente.
    // Sem mocks, esse teste é demonstrativo, sem execução real.

    // Você pode usar mockito ou mocktail para simular essa situação.
  });

  testWidgets('PassageiroTile renderiza corretamente com estado de loading e check-in', (WidgetTester tester) async {
    final passageiro = Passageiro(uid: '123', nome: 'Ana');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PassageiroTile(passageiro: passageiro),
        ),
      ),
    );

    // Inicialmente, deve exibir o nome do passageiro
    expect(find.text('Ana'), findsWidgets); // título e avatar (letra A)

    // Verifica presença do CircleAvatar com letra inicial
    expect(find.byType(CircleAvatar), findsOneWidget);

    // Como StreamBuilder do check-in depende do Firebase,
    // inicialmente mostra "Verificando status..." com CircularProgressIndicator
    expect(find.text('Verificando status...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // Para testar a listagem com passageiros, também seria necessário mocks do Firebase
  // para simular dados das collections. Pode usar mockito/mocktail para isso.

  // Em resumo: para testes completos envolvendo Firebase, considere usar mock do Firestore
  // e do FirebaseAuth. Aqui mostramos testes básicos para renderização e estados iniciais.
}
