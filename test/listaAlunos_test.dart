import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:engenharia_de_software/services/listaAlunos_service.dart';
import 'mocks.mocks.dart';

@GenerateMocks([FirebaseFirestore, CollectionReference, DocumentReference, QuerySnapshot, QueryDocumentSnapshot])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDoc1;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDoc2;

  late ListaAlunosService listaAlunosService;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockDoc1 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
    mockDoc2 = MockQueryDocumentSnapshot<Map<String, dynamic>>();

    listaAlunosService = ListaAlunosService(firestore: mockFirestore);
  });

  test('deve retornar lista de alunos para uma rota válida', () async {
    const rotaId = 'rota123';

    when(mockFirestore.collection('rotas'))
        .thenReturn(mockCollection);
    when(mockCollection.doc(rotaId)).thenReturn(MockDocumentReference());
    when(mockCollection.doc(rotaId).collection('alunos')).thenReturn(mockCollection);
    when(mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);

    when(mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);

    when(mockDoc1.data()).thenReturn({'nome': 'João', 'id': '1'});
    when(mockDoc2.data()).thenReturn({'nome': 'Maria', 'id': '2'});

    final alunos = await listaAlunosService.listarAlunos(rotaId: rotaId);

    expect(alunos.length, 2);
    expect(alunos[0]['nome'], 'João');
    expect(alunos[1]['nome'], 'Maria');
  });
}
