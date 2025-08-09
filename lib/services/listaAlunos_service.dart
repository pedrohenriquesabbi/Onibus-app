import 'package:cloud_firestore/cloud_firestore.dart';

class ListaAlunosService {
  final FirebaseFirestore firestore;

  ListaAlunosService({required this.firestore});

  Future<List<Map<String, dynamic>>> listarAlunos({required String rotaId}) async {
    final alunosSnapshot = await firestore
        .collection('rotas')
        .doc(rotaId)
        .collection('alunos')
        .get();

    return alunosSnapshot.docs.map((doc) => doc.data()).toList();
  }
}
