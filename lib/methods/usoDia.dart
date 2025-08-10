import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:engenharia_de_software/methods/usoDiaModelo.dart';

Future<void> confirmarUso(String rotaId, String data, AlunoDia aluno) async {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final docRef = db
      .collection('rotas')
      .doc(rotaId)
      .collection('dias')
      .doc(data);

  final docSnapshot = await docRef.get();
  final alunoNovo = aluno.toMap();

  if (docSnapshot.exists) {
    final List<dynamic> alunos = docSnapshot.data()?['alunos'] ?? [];

    // Substitui se o aluno já existir
    final List updatedAlunos = alunos
        .where((a) => a['uid'] != aluno.uid)
        .toList();
    updatedAlunos.add(alunoNovo);

    await docRef.update({'alunos': updatedAlunos});
  } else {
    await docRef.set({
      'data': data,
      'alunos': [alunoNovo],
    });
  }
}
