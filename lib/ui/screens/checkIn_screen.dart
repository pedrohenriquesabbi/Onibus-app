import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Enum para o estado do check-in
enum CheckInStatus {
  carregando,
  podeFazerCheckInIda,
  podeFazerCheckInVolta,
  concluido,
  erro,
}

// Enum para o itinerário, para referência
enum ItinerarioOption { idaEVolta, apenasIda, apenasVolta, naoVou }

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  CheckInStatus _status = CheckInStatus.carregando;
  bool _isSaving = false;
  late Timer _timer;
  DateTime _currentTime = DateTime.now();
  String _errorMessage = "Ocorreu um erro inesperado.";

  Map<String, dynamic>? _dadosRota;
  ItinerarioOption? _itinerarioDoDia;

  @override
  void initState() {
    super.initState();
    _carregarDadosDaTela();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Função atualizada para carregar todos os dados e aplicar a nova lógica
  Future<void> _carregarDadosDaTela() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _status = CheckInStatus.erro;
        _errorMessage = "Utilizador não autenticado.";
      });
      return;
    }

    final String hoje = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      // Busca todos os dados necessários em paralelo
      final checkInFuture = FirebaseFirestore.instance
          .collection('checkins')
          .where('userId', isEqualTo: user.uid)
          .where('dataRegistro', isEqualTo: hoje)
          .get();

      final rotaFuture = FirebaseFirestore.instance
          .collection('rotas_usuarios')
          .doc(user.uid)
          .get();

      final frequenciaFuture = FirebaseFirestore.instance
          .collection('frequencias')
          .doc('${user.uid}_$hoje')
          .get();

      final results = await Future.wait([
        checkInFuture,
        rotaFuture,
        frequenciaFuture,
      ]);

      final querySnapshot = results[0] as QuerySnapshot;
      final rotaDoc = results[1] as DocumentSnapshot;
      final frequenciaDoc = results[2] as DocumentSnapshot;

      // Processa os dados da rota
      if (rotaDoc.exists) {
        _dadosRota = rotaDoc.data() as Map<String, dynamic>;
      } else {
        throw Exception("Por favor, defina sua rota primeiro.");
      }

      // Processa a frequência do dia
      if (frequenciaDoc.exists) {
        final itinerarioSalvo =
            (frequenciaDoc.data() as Map<String, dynamic>)['itinerario']
                as String?;
        if (itinerarioSalvo != null) {
          _itinerarioDoDia = ItinerarioOption.values.firstWhere(
            (e) => e.toString() == itinerarioSalvo,
          );
        } else {
          throw Exception("Frequência do dia não encontrada.");
        }
      } else {
        throw Exception(
          "Por favor, defina sua frequência para o dia de hoje primeiro.",
        );
      }

      // REGRA: Se o utilizador marcou que não vai, mostra erro
      if (_itinerarioDoDia == ItinerarioOption.naoVou) {
        throw Exception(
          "Você selecionou que não irá utilizar o ônibus hoje. Volte para a tela de Frequência do dia e selecione uma Rota.",
        );
      }

      // Processa o status do check-in
      bool fezCheckInIda = false;
      bool fezCheckInVolta = false;
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['tipoCheckIn'] == 'ida') fezCheckInIda = true;
        if (data['tipoCheckIn'] == 'volta') fezCheckInVolta = true;
      }

      // Aplica as regras de itinerário para definir o estado da tela
      if ((_itinerarioDoDia == ItinerarioOption.apenasIda && fezCheckInIda) ||
          (_itinerarioDoDia == ItinerarioOption.apenasVolta &&
              fezCheckInVolta) ||
          (fezCheckInIda && fezCheckInVolta)) {
        setState(() => _status = CheckInStatus.concluido);
      } else if (fezCheckInIda ||
          _itinerarioDoDia == ItinerarioOption.apenasVolta) {
        setState(() => _status = CheckInStatus.podeFazerCheckInVolta);
      } else {
        setState(() => _status = CheckInStatus.podeFazerCheckInIda);
      }
    } catch (e) {
      setState(() {
        _status = CheckInStatus.erro;
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
      });
      print("Erro ao carregar dados do check-in: $e");
    }
  }

  Future<void> _handleCheckIn() async {
    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilizador não autenticado!')),
      );
      setState(() => _isSaving = false);
      return;
    }

    try {
      final nomeDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      if (!nomeDoc.exists)
        throw Exception("Dados do utilizador não encontrados.");

      final dadosUsuario = nomeDoc.data() as Map<String, dynamic>;
      final tipoCheckIn = (_status == CheckInStatus.podeFazerCheckInIda)
          ? 'ida'
          : 'volta';

      await FirebaseFirestore.instance.collection('checkins').add({
        'userId': user.uid,
        'nomeUsuario': dadosUsuario['nome'] ?? 'Nome não encontrado',
        'checkInTimestamp': Timestamp.now(),
        'tipoCheckIn': tipoCheckIn,
        'itinerarioDoDia': _itinerarioDoDia.toString(),
        'dadosDaRota': _dadosRota,
        'dataRegistro': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      });

      await _carregarDadosDaTela();
      _mostrarDialogoDeSucesso();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _mostrarDialogoDeSucesso() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sucesso!"),
        content: const Text("Check-in realizado com sucesso!"),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  Widget _getInstructionText() {
    const defaultStyle = TextStyle(color: Colors.white, fontSize: 16);
    const boldStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    if (_status == CheckInStatus.concluido) {
      return Text(
        'Os seus check-ins de hoje foram concluídos!',
        style: defaultStyle,
      );
    }

    if (_dadosRota != null) {
      final motorista = _dadosRota!['motorista'] ?? 'N/D';
      final cidade = _dadosRota!['cidade'] ?? 'N/D';
      final faculdade = _dadosRota!['universidade'] ?? 'N/D';

      if (_status == CheckInStatus.podeFazerCheckInIda) {
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: defaultStyle,
            children: <TextSpan>[
              const TextSpan(text: 'Confirmo a entrada no autocarro do '),
              TextSpan(text: motorista, style: boldStyle),
              const TextSpan(text: ' a sair de '),
              TextSpan(text: cidade, style: boldStyle),
              const TextSpan(text: ' com destino a '),
              TextSpan(text: faculdade, style: boldStyle),
              const TextSpan(text: ' no trajeto de ida.'),
            ],
          ),
        );
      } else if (_status == CheckInStatus.podeFazerCheckInVolta) {
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: defaultStyle,
            children: <TextSpan>[
              const TextSpan(text: 'Confirmo a entrada no autocarro do '),
              TextSpan(text: motorista, style: boldStyle),
              const TextSpan(text: ' a sair de '),
              TextSpan(text: faculdade, style: boldStyle),
              const TextSpan(text: ' com destino a '),
              TextSpan(text: cidade, style: boldStyle),
              const TextSpan(text: ' no trajeto de volta.'),
            ],
          ),
        );
      }
    }

    return Text(
      'Prima o botão acima para registar a sua entrada no autocarro.',
      style: defaultStyle,
    );
  }

  Widget _buildBody() {
    final String formattedDate = DateFormat('dd/MM/yyyy').format(_currentTime);
    final String formattedTime = DateFormat('HH:mm:ss').format(_currentTime);
    String buttonText = 'CHECK-IN';
    bool isButtonEnabled = true;
    IconData buttonIcon = Icons.login;

    switch (_status) {
      case CheckInStatus.carregando:
        return const Center(child: CircularProgressIndicator());
      case CheckInStatus.podeFazerCheckInIda:
        buttonText = 'CHECK-IN IDA';
        buttonIcon = Icons.arrow_upward;
        // REGRA: Desativa o check-in de ida se a opção for apenas volta
        if (_itinerarioDoDia == ItinerarioOption.apenasVolta) {
          isButtonEnabled = false;
          buttonText = 'APENAS VOLTA';
          buttonIcon = Icons.block;
        }
        break;
      case CheckInStatus.podeFazerCheckInVolta:
        buttonText = 'CHECK-IN VOLTA';
        buttonIcon = Icons.arrow_downward;
        break;
      case CheckInStatus.concluido:
        buttonText = 'CONCLUÍDO';
        isButtonEnabled = false;
        buttonIcon = Icons.check;
        break;
      case CheckInStatus.erro:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 18),
            ),
          ),
        );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'REGISTO DO DIA: $formattedDate',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            formattedTime,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 200,
            height: 200,
            child: ElevatedButton(
              onPressed: (isButtonEnabled && !_isSaving)
                  ? _handleCheckIn
                  : null,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: isButtonEnabled
                    ? Colors.grey[300]
                    : Colors.green,
                foregroundColor: isButtonEnabled ? Colors.black : Colors.white,
                disabledBackgroundColor: isButtonEnabled
                    ? Colors.grey[600]
                    : Colors.green[600],
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(buttonIcon, size: 60),
                        const SizedBox(height: 8),
                        Text(
                          buttonText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _getInstructionText(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF424242),
      appBar: AppBar(
        title: const Text('Check-In'),
        backgroundColor: const Color(0xFF303030),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }
}
