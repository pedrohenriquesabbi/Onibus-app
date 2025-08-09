import 'package:engenharia_de_software/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'mocks.mocks.dart';

void main() {
  late MockFirebaseAuth mockFirebaseAuth; 
  late AuthService authService;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
    authService = AuthService(firebaseAuth: mockFirebaseAuth);
  });

  test('login com sucesso', () async {
    when(mockFirebaseAuth.signInWithEmailAndPassword(email: anyNamed('email'), password: anyNamed('password')))
        .thenAnswer((_) async => mockUserCredential);

    final resultado = await authService.login('teste@teste.com', '123456');

    expect(resultado, mockUserCredential);
    verify(mockFirebaseAuth.signInWithEmailAndPassword(email: 'teste@teste.com', password: '123456')).called(1);
  });

  test('cadastro com sucesso', () async {
    when(mockFirebaseAuth.createUserWithEmailAndPassword(email: anyNamed('email'), password: anyNamed('password')))
        .thenAnswer((_) async => mockUserCredential);

    final resultado = await authService.cadastro('teste@teste.com', '123456');

    expect(resultado, mockUserCredential);
    verify(mockFirebaseAuth.createUserWithEmailAndPassword(email: 'teste@teste.com', password: '123456')).called(1);
  });

  test('login falha lança exceção', () async {
    when(mockFirebaseAuth.signInWithEmailAndPassword(email: anyNamed('email'), password: anyNamed('password')))
        .thenThrow(FirebaseAuthException(code: 'user-not-found', message: 'Usuário não encontrado'));

    expect(() => authService.login('naoexiste@teste.com', '123456'), throwsA(isA<FirebaseAuthException>()));
  });
}
