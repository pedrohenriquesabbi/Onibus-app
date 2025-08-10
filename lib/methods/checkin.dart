import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> marcarPresenca(
  String rotaId,
  String data,
  String uid, {
  required bool ida,
}) async {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final docRef = db
      .collection('rotas')
      .doc(rotaId)
      .collection('dias')
      .doc(data);
  final docSnapshot = await docRef.get();

  if (!docSnapshot.exists) return;

  final List<dynamic> alunos = docSnapshot.data()?['alunos'] ?? [];

  final List updatedAlunos = alunos.map((aluno) {
    if (aluno['uid'] == uid) {
      if (ida) {
        aluno['presenteIda'] = true;
      } else {
        aluno['presenteVolta'] = true;
      }
    }
    return aluno;
  }).toList();

  await docRef.update({'alunos': updatedAlunos});
}
