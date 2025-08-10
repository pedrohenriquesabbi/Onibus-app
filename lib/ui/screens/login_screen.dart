// lib/login_screen.dart

import 'package:flutter/material.dart';
import 'signup_screen.dart';
// 1. IMPORTE O PACOTE DE AUTENTICAÇÃO DO FIREBASE
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _senhaVisivel = false;
  bool _isLoading = false; // Para controlar o indicador de carregamento

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  // 2. NOVA FUNÇÃO COMPLETA PARA REALIZAR O LOGIN
  Future<void> _loginUsuario() async {
    if (_emailController.text.isEmpty || _senhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Por favor, preencha email e senha.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Tenta fazer o login com o Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );
      // Se o login for bem-sucedido, não precisamos navegar daqui.
      // O "Guardião" que vamos criar no main.dart fará isso automaticamente.
    } on FirebaseAuthException catch (e) {
      // Trata erros comuns de login
      String mensagemErro = "Ocorreu um erro ao fazer login.";
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        mensagemErro = 'Email ou senha incorretos. Tente novamente.';
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
      // Garante que o indicador de carregamento seja desativado no final
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
      hintStyle: TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide.none,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color(0xFF303030),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Volta para a tela anterior
          },
        ),
      ),
      backgroundColor: const Color(0xFF424242),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.directions_bus_filled_rounded,
                size: 80,
                color: Colors.white70,
              ),
              const SizedBox(height: 16),
              const Text(
                'Bem-vindo de volta!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Faça login para continuar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
              const SizedBox(height: 40),
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
                    onPressed: () {
                      setState(() {
                        _senhaVisivel = !_senhaVisivel;
                      });
                    },
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
                // 3. O BOTÃO AGORA CHAMA A FUNÇÃO DE LOGIN
                onPressed: _isLoading ? null : _loginUsuario,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      )
                    : const Text(
                        'Entrar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignupScreen(),
                    ),
                  );
                },
                child: const Text('Não tem uma conta? Cadastre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
