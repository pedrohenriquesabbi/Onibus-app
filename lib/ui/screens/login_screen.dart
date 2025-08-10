import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:engenharia_de_software/ui/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_screen.dart';
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

  Future<void> _loginUsuario() async {
  String email = _emailController.text.trim();
  String senha = _senhaController.text.trim();

  if (email.isEmpty || senha.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preencha todos os campos')),
    );
    return;
  }

  try {
    // Tenta fazer login no Firebase
    UserCredential credenciais = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: senha);

    User? usuario = credenciais.user;

    if (usuario != null) {
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', usuario.uid);

      // Tenta pegar o nome do perfil
    String nomeUsuario = usuario?.displayName ?? "Usuário";

    // Se você guarda o nome no Firestore, tem que buscar lá:
    if (nomeUsuario == "Usuário") {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario!.uid)
          .get();
      nomeUsuario = snapshot['nome'];
    }

      // Redireciona para tela inicial
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(nomeUsuario: nomeUsuario),
        ),
      );
    } else {
      // Se não tiver usuário válido
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha no login. Tente novamente.')),
      );
    }
  } on FirebaseAuthException catch (e) {
    String mensagemErro;

    if (e.code == 'user-not-found') {
      mensagemErro = 'Usuário não encontrado.';
    } else if (e.code == 'wrong-password') {
      mensagemErro = 'Senha incorreta.';
    } else {
      mensagemErro = 'Erro: ${e.message}';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagemErro)),
    );
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
