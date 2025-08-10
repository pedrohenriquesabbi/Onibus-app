import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DefinirRotaScreen extends StatefulWidget {
  const DefinirRotaScreen({super.key});

  @override
  State<DefinirRotaScreen> createState() => _DefinirRotaScreenState();
}

class _DefinirRotaScreenState extends State<DefinirRotaScreen> {
  String? _cidadeSelecionada;
  String? _universidadeSelecionada;
  String? _motoristaSelecionado;
  bool _isLoading = false; // Para o indicador de progresso

  final List<String> _opcoesCidade = [
    'Viçosa do Ceará',
    'Tianguá',
    'Ubajara',
    'São Benedito',
    'Ibiapina',
    'Carnaubal',
    'Ipu',
  ];
  final List<String> _opcoesUniversidade = [
    'IFCE-Tianguá',
    'IFCE-Ubajara',
    'UNINTA',
    'UniChristus',
  ];
  final List<String> _opcoesMotorista = [
    'Sr. Ronaldo',
    'Sr. Zé',
    'Sr. João',
    'Sr. Sérgio',
  ];

  // 2. NOVA FUNÇÃO PARA SALVAR A ROTA NO FIRESTORE
  Future<void> _salvarRota() async {
    // Valida se todas as opções foram selecionadas
    if (_cidadeSelecionada == null ||
        _universidadeSelecionada == null ||
        _motoristaSelecionado == null) {
      _mostrarDialogoDeErro();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Pega o utilizador atualmente logado
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Salva ou atualiza os dados no Firestore
        // Usamos .set() porque ele cria o documento se não existir ou atualiza se já existir.
        await FirebaseFirestore.instance
            .collection('rotas_usuarios') // Coleção para armazenar as rotas
            .doc(
              user.uid,
            ) // O documento é identificado pelo ID único do utilizador
            .set({
              'cidade': _cidadeSelecionada,
              'universidade': _universidadeSelecionada,
              'motorista': _motoristaSelecionado,
              'lastUpdated':
                  Timestamp.now(), // Guarda a data da última atualização
            });

        if (mounted) _mostrarDialogoDeSucesso();
      } else {
        // Este erro acontecerá se o login não estiver a funcionar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              'Erro: Utilizador não encontrado. Faça login novamente.',
            ),
          ),
        );
      }
    } catch (e) {
      // Mostra um erro genérico se a comunicação com o Firestore falhar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Erro ao salvar a rota: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _mostrarDialogoDeSucesso() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Sucesso!"),
          content: const Text("Sua rota foi salva com sucesso."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoDeErro() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Atenção!"),
          content: const Text(
            "Por favor, selecione todas as opções antes de salvar.",
          ),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(color: Colors.white, fontSize: 16);

    return Scaffold(
      backgroundColor: const Color(0xFF424242),
      appBar: AppBar(
        title: const Text('Definir Rota'),
        backgroundColor: const Color(0xFF303030),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Icon(Icons.directions_bus, size: 100, color: Colors.white70),
            const SizedBox(height: 32),

            const Text('Cidade onde moro:', style: labelStyle),
            const SizedBox(height: 8),
            _buildDropdown(
              value: _cidadeSelecionada,
              hint: 'Selecione sua cidade',
              items: _opcoesCidade,
              onChanged: (val) => setState(() => _cidadeSelecionada = val),
            ),
            const SizedBox(height: 24),

            const Text('Universidade em que estudo:', style: labelStyle),
            const SizedBox(height: 8),
            _buildDropdown(
              value: _universidadeSelecionada,
              hint: 'Selecione sua universidade',
              items: _opcoesUniversidade,
              onChanged: (val) =>
                  setState(() => _universidadeSelecionada = val),
            ),
            const SizedBox(height: 24),

            const Text('Motorista do meu ônibus:', style: labelStyle),
            const SizedBox(height: 8),
            _buildDropdown(
              value: _motoristaSelecionado,
              hint: 'Selecione seu motorista',
              items: _opcoesMotorista,
              onChanged: (val) => setState(() => _motoristaSelecionado = val),
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
              ),
              // 3. O BOTÃO AGORA CHAMA A FUNÇÃO DE SALVAR
              onPressed: _isLoading ? null : _salvarRota,
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    )
                  : const Text(
                      'SALVAR',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint, style: TextStyle(color: Colors.grey[400])),
      dropdownColor: const Color(0xFF424242),
      iconEnabledColor: Colors.white70,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: const Color(0xFF303030),
      ),
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
    );
  }
}
