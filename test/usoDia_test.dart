import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';

import 'package:engenharia_de_software/services/usoDia_service.dart';
import 'mocks.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockUsoDiaCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDiaDoc;
  late MockCollectionReference<Map<String, dynamic>> mockAlunosCollection;
  late MockDocumentReference<Map<String, dynamic>> mockAlunoDoc;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocSnapshot;

  late UsoDiaService usoDiaService;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockUsoDiaCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDiaDoc = MockDocumentReference<Map<String, dynamic>>();
    mockAlunosCollection = MockCollectionReference<Map<String, dynamic>>();
    mockAlunoDoc = MockDocumentReference<Map<String, dynamic>>();
    mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

    usoDiaService = UsoDiaService(firestore: mockFirestore);
  });

  test('registrarUsoDoDia deve salvar o uso corretamente no Firestore', () async {
    final dia = DateTime(2025, 8, 5);
    const alunoId = 'aluno123';
    const rotaId = 'rota456';
    const tipo = UsoTipo.apenasIda;

    when(mockFirestore.collection('uso_dia')).thenReturn(mockUsoDiaCollection);
    when(mockUsoDiaCollection.doc('rota456-2025-08-05')).thenReturn(mockDiaDoc);
    when(mockDiaDoc.collection('alunos')).thenReturn(mockAlunosCollection);
    when(mockAlunosCollection.doc(alunoId)).thenReturn(mockAlunoDoc);

    await usoDiaService.registrarUsoDoDia(
      alunoId: alunoId,
      rotaId: rotaId,
      dia: dia,
      tipo: tipo,
    );

    verify(mockAlunoDoc.set({
      'uso': tipo.name,
      'data': dia.toIso8601String(),
    })).called(1);
  });

  test('obterUsoDoDia deve retornar o valor salvo se existir', () async {
    final dia = DateTime(2025, 8, 5);
    const alunoId = 'aluno123';
    const rotaId = 'rota456';

    when(mockFirestore.collection('uso_dia')).thenReturn(mockUsoDiaCollection);
    when(mockUsoDiaCollection.doc('rota456-2025-08-05')).thenReturn(mockDiaDoc);
    when(mockDiaDoc.collection('alunos')).thenReturn(mockAlunosCollection);
    when(mockAlunosCollection.doc(alunoId)).thenReturn(mockAlunoDoc);
    when(mockAlunoDoc.get()).thenAnswer((_) async => mockDocSnapshot);
    when(mockDocSnapshot.exists).thenReturn(true);
    when(mockDocSnapshot.data()).thenReturn({'uso': 'apenasIda'});

    final uso = await usoDiaService.obterUsoDoDia(
      alunoId: alunoId,
      rotaId: rotaId,
      dia: dia,
    );

    expect(uso, equals('apenasIda'));
  });

  test('obterUsoDoDia deve retornar null se o documento não existir', () async {
    final dia = DateTime(2025, 8, 5);
    const alunoId = 'aluno123';
    const rotaId = 'rota456';

    when(mockFirestore.collection('uso_dia')).thenReturn(mockUsoDiaCollection);
    when(mockUsoDiaCollection.doc('rota456-2025-08-05')).thenReturn(mockDiaDoc);
    when(mockDiaDoc.collection('alunos')).thenReturn(mockAlunosCollection);
    when(mockAlunosCollection.doc(alunoId)).thenReturn(mockAlunoDoc);
    when(mockAlunoDoc.get()).thenAnswer((_) async => mockDocSnapshot);
    when(mockDocSnapshot.exists).thenReturn(false);

    final uso = await usoDiaService.obterUsoDoDia(
      alunoId: alunoId,
      rotaId: rotaId,
      dia: dia,
    );

    expect(uso, isNull);
  });
}
