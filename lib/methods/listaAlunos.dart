import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:engenharia_de_software/methods/usoDiaModelo.dart';

Future<List<AlunoDia>> listarAlunos(String rotaId, String data) async {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final doc = await _db.collection('rotas').doc(rotaId).collection('dias').doc(data).get();

  if (!doc.exists) return [];

  final List<dynamic> alunosData = doc.data()?['alunos'] ?? [];

  return alunosData.map((aluno) => AlunoDia.fromMap(aluno)).toList();
}
