import 'package:cloud_firestore/cloud_firestore.dart';

enum UsoTipo { idaEVolta, apenasIda, apenasVolta, naoIrei }

class UsoDiaService {
  final FirebaseFirestore firestore;

  UsoDiaService({required this.firestore});

  Future<void> registrarUsoDoDia({
    required String alunoId,
    required String rotaId,
    required DateTime dia,
    required UsoTipo tipo,
  }) async {
    final docRef = firestore
        .collection('uso_dia')
        .doc('$rotaId-${dia.toIso8601String().substring(0, 10)}')
        .collection('alunos')
        .doc(alunoId);

    await docRef.set({'uso': tipo.name, 'data': dia.toIso8601String()});
  }

  Future<String?> obterUsoDoDia({
    required String alunoId,
    required String rotaId,
    required DateTime dia,
  }) async {
    final docRef = firestore
        .collection('uso_dia')
        .doc('$rotaId-${dia.toIso8601String().substring(0, 10)}')
        .collection('alunos')
        .doc(alunoId);

    final doc = await docRef.get();

    final data = doc.data();
    if (doc.exists && data != null) {
      return data['uso'] as String?;
    }
    return null;
  }
}
