class Rota {
  final String id;
  final String nome;
  final String origem;
  final String destino;
  final String horario;
  final String motorista;

  Rota({
    required this.id,
    required this.nome,
    required this.origem,
    required this.destino,
    required this.horario,
    required this.motorista,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'origem': origem,
      'destino': destino,
      'horario': horario,
      'motorista': motorista,
    };
  }

  factory Rota.fromMap(Map<String, dynamic> map) {
    return Rota(
      id: map['id'],
      nome: map['nome'],
      origem: map['origem'],
      destino: map['destino'],
      horario: map['horario'],
      motorista: map['motorista'],
    );
  }
}
