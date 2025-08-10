import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _cpfController = TextEditingController();

  final maskFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _cpfController.dispose();
    super.dispose();
  }

  Future<void> _cadastrarUsuario() async {
    print("✅ PASSO 1: Função _cadastrarUsuario iniciada.");

    if (_senhaController.text != _confirmarSenhaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('As senhas não coincidem!'),
        ),
      );
      return;
    }
    if (_nomeController.text.isEmpty ||
        _cpfController.text.isEmpty ||
        _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Por favor, preencha todos os campos.'),
        ),
      );
      return;
    }

    print("✅ PASSO 2: Validações de campos passaram.");

    setState(() {
      _isLoading = true;
    });

    try {
      print("⏳ PASSO 3: Tentando criar usuário no Firebase Authentication...");
      print("   - Email: ${_emailController.text.trim()}");

      // PONTO CRÍTICO 1: Criação do usuário no Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _senhaController.text.trim(),
          );

      print("✅ PASSO 4: Usuário criado no Auth com sucesso!");
      print("   - UID do usuário: ${userCredential.user!.uid}");

      print("⏳ PASSO 5: Tentando salvar dados adicionais no Firestore...");

      // PONTO CRÍTICO 2: Escrita no banco de dados
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
            'nome': _nomeController.text.trim(),
            'cpf': _cpfController.text.trim(),
            'email': _emailController.text.trim(),
            'uid': userCredential.user!.uid,
            'createdAt': Timestamp.now(),
          });

      print("✅ PASSO 6: Dados salvos no Firestore com sucesso!");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Conta criada com sucesso! Faça o login.'),
          ),
        );
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      print("❌ ERRO CAPTURADO! O processo parou aqui.");
      print("   - CÓDIGO DO ERRO: ${e.code}");
      print("   - MENSAGEM COMPLETA: ${e.message}");
      print("   - ERRO DETALHADO DO FIREBASE: ${e.toString()}");

      String mensagemErro = "Ocorreu um erro ao criar a conta.";
      if (e.code == 'weak-password') {
        mensagemErro = 'A senha fornecida é muito fraca (mínimo 6 caracteres).';
      } else if (e.code == 'email-already-in-use') {
        mensagemErro = 'Este email já está em uso por outra conta.';
      } else if (e.code == 'invalid-email') {
        mensagemErro = 'O email fornecido é inválido.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(mensagemErro),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const inputDecorationTheme = InputDecoration(
      filled: true,
      fillColor: Color(0xFF303030),
      labelStyle: TextStyle(color: Colors.white70),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide.none,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF424242),
      appBar: AppBar(
        title: const Text('Criar Conta'),
        backgroundColor: const Color(0xFF303030),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Preencha os dados para se cadastrar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nomeController,
                style: const TextStyle(color: Colors.white),
                decoration: inputDecorationTheme.copyWith(
                  labelText: 'Nome Completo',
                  prefixIcon: Icon(Icons.person_outline, color: Colors.white70),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cpfController,
                style: const TextStyle(color: Colors.white),
                decoration: inputDecorationTheme.copyWith(
                  labelText: 'CPF',
                  prefixIcon: Icon(Icons.badge_outlined, color: Colors.white70),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [maskFormatter],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: inputDecorationTheme.copyWith(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.white70),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senhaController,
                style: const TextStyle(color: Colors.white),
                obscureText: !_senhaVisivel,
                decoration: inputDecorationTheme.copyWith(
                  labelText: 'Senha',
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.white70),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _senhaVisivel ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white70,
                    ),
                    onPressed: () =>
                        setState(() => _senhaVisivel = !_senhaVisivel),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmarSenhaController,
                style: const TextStyle(color: Colors.white),
                obscureText: !_confirmarSenhaVisivel,
                decoration: inputDecorationTheme.copyWith(
                  labelText: 'Confirmar Senha',
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.white70),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confirmarSenhaVisivel
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white70,
                    ),
                    onPressed: () => setState(
                      () => _confirmarSenhaVisivel = !_confirmarSenhaVisivel,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isLoading ? null : _cadastrarUsuario,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      )
                    : const Text(
                        'Cadastrar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
