import 'package:engenharia_de_software/services/checkin_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'mocks.mocks.dart';

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockDocumentReference<Map<String, dynamic>> mockDocRef;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionRef;
  late CheckInService checkInService;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockDocRef = MockDocumentReference();
    mockCollectionRef = MockCollectionReference();

    when(mockFirestore.collection('presencas')).thenReturn(mockCollectionRef);
    when(mockCollectionRef.doc(any)).thenReturn(mockDocRef);

    checkInService = CheckInService(firestoreInstance: mockFirestore);
  });

  test('marcarCheckIn chama set corretamente com merge', () async {
    when(mockDocRef.set(any, SetOptions(merge: true)))
        .thenAnswer((_) async => Future.value());

    await checkInService.marcarCheckIn(
      alunoId: 'aluno123',
      data: '2025-08-05',
      turno: 'ida',
    );

    verify(mockFirestore.collection('presencas')).called(1);
    verify(mockCollectionRef.doc('2025-08-05-aluno123')).called(1);
    verify(mockDocRef.set(argThat(allOf(
      containsPair('alunoId', 'aluno123'),
      containsPair('data', '2025-08-05'),
      contains('turno_ida'),
    )), SetOptions(merge: true))).called(1);
  });

  test('marcarCheckIn lança exceção se o Firestore falhar', () async {
    when(mockDocRef.set(any, any)).thenThrow(FirebaseException(plugin: 'firestore'));

    expect(
      () => checkInService.marcarCheckIn(
        alunoId: 'erro',
        data: '2025-08-05',
        turno: 'volta',
      ),
      throwsA(isA<FirebaseException>()),
    );
  });
}
