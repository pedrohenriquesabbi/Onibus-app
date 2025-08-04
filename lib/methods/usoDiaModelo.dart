class AlunoDia {
  final String uid;
  final String nome;
  final String uso; // "ida_volta", "apenas_ida", "apenas_volta", "nao_irei"
  final bool presenteIda;
  final bool presenteVolta;

  AlunoDia({
    required this.uid,
    required this.nome,
    required this.uso,
    this.presenteIda = false,
    this.presenteVolta = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'uso': uso,
      'presenteIda': presenteIda,
      'presenteVolta': presenteVolta,
    };
  }

  factory AlunoDia.fromMap(Map<String, dynamic> map) {
    return AlunoDia(
      uid: map['uid'],
      nome: map['nome'],
      uso: map['uso'],
      presenteIda: map['presenteIda'] ?? false,
      presenteVolta: map['presenteVolta'] ?? false,
    );
  }
}
