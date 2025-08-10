// lib/frequenciaDia_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// 1. IMPORTE OS PACOTES DO FIREBASE
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Enum para representar as opções de forma segura e legível
enum ItinerarioOption { idaEVolta, apenasIda, apenasVolta, naoVou }

class FrequenciaDoDiaScreen extends StatefulWidget {
  const FrequenciaDoDiaScreen({super.key});

  @override
  State<FrequenciaDoDiaScreen> createState() => _FrequenciaDoDiaScreenState();
}

class _FrequenciaDoDiaScreenState extends State<FrequenciaDoDiaScreen> {
  ItinerarioOption? _selectedOption;
  bool _isLoading = false; // Para o botão de salvar
  bool _isPageLoading = true; // Para o carregamento inicial da página

  @override
  void initState() {
    super.initState();
    // Ao abrir a tela, tenta carregar a frequência já salva para o dia de hoje
    _carregarFrequenciaDoDia();
  }

  // 2. FUNÇÃO PARA CARREGAR A ESCOLHA JÁ FEITA (LÓGICA ALTERADA)
  Future<void> _carregarFrequenciaDoDia() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isPageLoading = false);
      return;
    }

    // Cria um ID de documento único combinando o ID do utilizador e a data
    final String dateId = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String compositeDocId = '${user.uid}_$dateId';

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('frequencias') // Coleção principal, como em 'definirRota'
          .doc(compositeDocId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final itinerarioSalvo = data?['itinerario'] as String?;
        if (itinerarioSalvo != null) {
          // Converte a string salva de volta para o enum e atualiza a UI
          _selectedOption = ItinerarioOption.values.firstWhere(
            (e) => e.toString() == itinerarioSalvo,
          );
        }
      }
    } catch (e) {
      print("Erro ao carregar frequência: $e");
    } finally {
      if (mounted) {
        setState(() => _isPageLoading = false);
      }
    }
  }

  // 3. FUNÇÃO PARA SALVAR O ITINERÁRIO NO FIRESTORE (LÓGICA ALTERADA)
  Future<void> _salvarItinerario() async {
    if (_selectedOption == null) {
      _mostrarDialogoDeErro();
      return;
    }

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Erro: Utilizador não autenticado.'),
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    final String dateId = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String compositeDocId = '${user.uid}_$dateId';

    try {
      // Salva ou atualiza o documento da frequência do dia numa coleção principal
      await FirebaseFirestore.instance
          .collection('frequencias') // Coleção principal
          .doc(compositeDocId) // ID único para o utilizador e o dia
          .set({
            'itinerario': _selectedOption.toString(), // Salva o enum como texto
            'lastUpdated': Timestamp.now(),
            'userId':
                user.uid, // Salva o ID do utilizador para referência futura
            'date': dateId, // Salva a data para referência futura
          });

      if (mounted) _mostrarDialogoDeSucesso();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Erro ao salvar: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Funções de diálogo (sem alterações)
  void _mostrarDialogoDeSucesso() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sucesso!"),
        content: const Text("Sua frequência para hoje foi salva."),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoDeErro() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Atenção!"),
        content: const Text(
          "Por favor, selecione uma das opções de itinerário.",
        ),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFF424242),
      appBar: AppBar(
        title: const Text('Frequência do Dia'),
        backgroundColor: const Color(0xFF303030),
        foregroundColor: Colors.white,
      ),
      body: _isPageLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.directions_bus,
                    size: 80,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Selecionar Itinerário',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Frequência do dia: $formattedDate',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(unselectedWidgetColor: Colors.white70),
                    child: Column(
                      children: <Widget>[
                        _buildRadioOption(
                          title: 'Ida e Volta',
                          value: ItinerarioOption.idaEVolta,
                        ),
                        _buildRadioOption(
                          title: 'Apenas Ida',
                          value: ItinerarioOption.apenasIda,
                        ),
                        _buildRadioOption(
                          title: 'Apenas Volta',
                          value: ItinerarioOption.apenasVolta,
                        ),
                        _buildRadioOption(
                          title: 'Não vou hoje',
                          value: ItinerarioOption.naoVou,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoading ? null : _salvarItinerario,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
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

  Widget _buildRadioOption({
    required String title,
    required ItinerarioOption value,
  }) {
    return RadioListTile<ItinerarioOption>(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      groupValue: _selectedOption,
      onChanged: (ItinerarioOption? newValue) {
        setState(() {
          _selectedOption = newValue;
        });
      },
      activeColor: Colors.white,
      contentPadding: EdgeInsets.zero,
    );
  }
}
