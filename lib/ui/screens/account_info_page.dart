import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:engenharia_de_software/constants/colorsConstants.dart';

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({super.key});

  @override
  State<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  bool _isLoading = true;
  String? _nome, _email, _cpf, _telefone;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (mounted && docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _nome = data['nome'];
          _email = data['email'];
          _cpf = data['cpf'];
          _telefone = data['telefone'];
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar dados: $e')));
      }
    }
  }

  void _abrirDialogoAlteracao() {
    final telefoneController = TextEditingController(text: _telefone);
    final emailController = TextEditingController(text: _email);
    final senhaAtualController = TextEditingController();
    final novaSenhaController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF424242),
          title: const Text(
            'Alterar Dados',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: telefoneController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Novo Telefone',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Novo Email',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
                TextField(
                  controller: novaSenhaController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nova Senha (opcional)',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Para alterar email ou senha, por favor, confirme sua senha atual:',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                TextField(
                  controller: senhaAtualController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Senha Atual',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              child: const Text('Salvar'),
              onPressed: () {
                _alterarDados(
                  ctx,
                  telefone: telefoneController.text,
                  novoEmail: emailController.text,
                  senhaAtual: senhaAtualController.text,
                  novaSenha: novaSenhaController.text,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _alterarDados(
    BuildContext dialogContext, {
    required String telefone,
    required String novoEmail,
    required String senhaAtual,
    required String novaSenha,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    bool precisaReautenticar =
        (novoEmail.isNotEmpty && novoEmail != _email) || novaSenha.isNotEmpty;

    if (precisaReautenticar && senhaAtual.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            'Por favor, insira sua senha atual para fazer alterações.',
          ),
        ),
      );
      return;
    }

    Navigator.of(dialogContext).pop();
    setState(() => _isLoading = true);

    try {
      if (precisaReautenticar) {
        final credencial = EmailAuthProvider.credential(
          email: user.email!,
          password: senhaAtual,
        );
        await user.reauthenticateWithCredential(credencial);
      }

      final firestoreDoc = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid);

      if (novoEmail.isNotEmpty && novoEmail != _email) {
        await user.verifyBeforeUpdateEmail(novoEmail);
        await firestoreDoc.update({'email': novoEmail});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.orange,
            content: Text('Email de verificação enviado para o novo endereço!'),
          ),
        );
      }

      if (novaSenha.isNotEmpty) {
        await user.updatePassword(novaSenha);
      }

      if (telefone != _telefone) {
        await firestoreDoc.update({'telefone': telefone});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Dados atualizados com sucesso!'),
        ),
      );
      await _carregarDadosUsuario();
    } on FirebaseAuthException catch (e) {
      String erro = 'Ocorreu um erro.';
      if (e.code == 'wrong-password') {
        erro = 'A senha atual está incorreta.';
      } else if (e.code == 'email-already-in-use') {
        erro = 'O novo email já está em uso.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.redAccent, content: Text(erro)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: const Color(0xFF303030),
        title: const Text(
          'Sua Conta',
          style: TextStyle(color: AppColors.lightText),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.account_circle,
                    size: 100,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _nome ?? 'Carregando...',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoField('Email:', _email ?? 'Não informado'),
                  const SizedBox(height: 12),
                  _buildInfoField('CPF:', _cpf ?? 'Não informado'),
                  const SizedBox(height: 12),
                  _buildInfoField('Telefone:', _telefone ?? 'Não informado'),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _abrirDialogoAlteracao,
                    child: const Text('Alterar Dados'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
