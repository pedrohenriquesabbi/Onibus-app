import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Modelo simplificado para os dados de um passageiro
class Passageiro {
  final String uid;
  final String nome;

  Passageiro({required this.uid, required this.nome});
}

class ListaFrequenciaScreen extends StatefulWidget {
  const ListaFrequenciaScreen({super.key});

  @override
  State<ListaFrequenciaScreen> createState() => _ListaFrequenciaScreenState();
}

class _ListaFrequenciaScreenState extends State<ListaFrequenciaScreen> {
  // Future para buscar a rota do utilizador atual uma única vez
  late Future<DocumentSnapshot> _rotaUsuarioFuture;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _rotaUsuarioFuture = FirebaseFirestore.instance
          .collection('rotas_usuarios')
          .doc(user.uid)
          .get();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF424242),
        appBar: AppBar(title: const Text('Lista de Frequência')),
        body: const Center(
          child: Text(
            'Erro: Utilizador não autenticado.',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF424242),
      appBar: AppBar(
        title: const Text('Lista de Frequência'),
        backgroundColor: const Color(0xFF303030),
        foregroundColor: Colors.white,
      ),
      // FutureBuilder espera que a rota do utilizador seja carregada
      body: FutureBuilder<DocumentSnapshot>(
        future: _rotaUsuarioFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Para ver a lista de passageiros, por favor, defina a sua rota primeiro.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Erro ao carregar a sua rota.',
                style: TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final rotaData = snapshot.data!.data() as Map<String, dynamic>;
          final motorista = rotaData['motorista'];

          // StreamBuilder para ouvir em tempo real a lista de passageiros
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('rotas_usuarios')
                .where('motorista', isEqualTo: motorista)
                .snapshots(),
            builder: (context, streamSnapshot) {
              if (streamSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!streamSnapshot.hasData ||
                  streamSnapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'Nenhum passageiro encontrado para o motorista $motorista.',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              }
              if (streamSnapshot.hasError) {
                return const Center(
                  child: Text(
                    'Erro ao carregar a lista de passageiros.',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                );
              }

              final passageirosDocs = streamSnapshot.data!.docs;

              // FutureBuilder para buscar os nomes de todos os passageiros
              return FutureBuilder<List<Passageiro>>(
                future: _buscarDadosPassageiros(passageirosDocs),
                builder: (context, passageirosSnapshot) {
                  if (!passageirosSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final listaDePassageiros = passageirosSnapshot.data!;

                  return ListView.builder(
                    itemCount: listaDePassageiros.length,
                    itemBuilder: (context, index) {
                      final passageiro = listaDePassageiros[index];
                      return PassageiroTile(passageiro: passageiro);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Função auxiliar para buscar os dados da coleção 'usuarios'
  Future<List<Passageiro>> _buscarDadosPassageiros(
    List<QueryDocumentSnapshot> docs,
  ) async {
    List<Passageiro> passageiros = [];
    for (var doc in docs) {
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(doc.id)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        passageiros.add(
          Passageiro(
            uid: userDoc.id,
            nome: data['nome'] ?? 'Nome não encontrado',
          ),
        );
      }
    }
    // Ordena a lista de passageiros por nome
    passageiros.sort((a, b) => a.nome.compareTo(b.nome));
    return passageiros;
  }
}

// WIDGET DEDICADO PARA CADA PASSAGEIRO NA LISTA
class PassageiroTile extends StatelessWidget {
  final Passageiro passageiro;

  const PassageiroTile({super.key, required this.passageiro});

  @override
  Widget build(BuildContext context) {
    final String hoje = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF303030),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      // StreamBuilder para buscar o status do check-in em tempo real
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('checkins')
            .where('userId', isEqualTo: passageiro.uid)
            .where('dataRegistro', isEqualTo: hoje)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mostra um ListTile com placeholders enquanto carrega
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[700],
                child: Text(
                  passageiro.nome.isNotEmpty
                      ? passageiro.nome.substring(0, 1)
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                passageiro.nome,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Verificando status...',
                style: TextStyle(color: Colors.grey[500]),
              ),
              trailing: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final checkInDocs = snapshot.data?.docs ?? [];
          final fezCheckIn = checkInDocs.isNotEmpty;

          Widget subtitle;
          if (fezCheckIn) {
            // Pega o horário do primeiro check-in do dia
            final checkInData =
                checkInDocs.first.data() as Map<String, dynamic>;
            final timestamp = checkInData['checkInTimestamp'] as Timestamp;
            final formattedTime = DateFormat(
              'HH:mm',
            ).format(timestamp.toDate());
            subtitle = Text(
              'Check-in às $formattedTime',
              style: TextStyle(color: Colors.green[400]),
            );
          } else {
            subtitle = Text(
              'Aguardando check-in',
              style: TextStyle(color: Colors.grey[400]),
            );
          }

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[700],
              child: Text(
                passageiro.nome.isNotEmpty
                    ? passageiro.nome.substring(0, 1)
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              passageiro.nome,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: subtitle,
            trailing: Chip(
              label: Text(
                fezCheckIn ? 'Presente' : 'Ausente',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: fezCheckIn ? Colors.green[600] : Colors.red[700],
            ),
          );
        },
      ),
    );
  }
}
