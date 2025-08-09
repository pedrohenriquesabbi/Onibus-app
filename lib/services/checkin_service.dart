import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInService {
  final FirebaseFirestore firestore;

  CheckInService({FirebaseFirestore? firestoreInstance})
      : firestore = firestoreInstance ?? FirebaseFirestore.instance;

  Future<void> marcarCheckIn({
    required String alunoId,
    required String data, // exemplo: '2025-08-05'
    required String turno, // exemplo: 'ida' ou 'volta'
  }) async {
    final docRef = firestore
        .collection('presencas')
        .doc('$data-$alunoId');

    await docRef.set({
      'alunoId': alunoId,
      'data': data,
      'turno_$turno': true,
      'ultimaAtualizacao': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
