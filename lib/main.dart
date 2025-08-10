// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_app_check/firebase_app_check.dart';

// Adapte os caminhos de importação para a sua estrutura de pastas
import 'ui/screens/firebase_options.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/start_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Ativa o App Check para segurança
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        AndroidProvider.playIntegrity, // Use .playIntegrity em produção
  );

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Onibus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // O "GUARDIÃO" DE AUTENTICAÇÃO
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Enquanto verifica o status, mostra uma tela de carregamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // Se o snapshot tem dados, significa que o usuário ESTÁ logado
          if (snapshot.hasData) {
            // Se está logado, busca os dados do usuário no Firestore para personalizar a HomeScreen
            return UserDataFetcher(userId: snapshot.data!.uid);
          }
          // Se não tem dados, o usuário NÃO está logado, mostra a StartPage (que leva para o login/cadastro)
          return const StartPage();
        },
      ),
    );
  }
}

// Widget auxiliar para buscar os dados do usuário após o login
class UserDataFetcher extends StatelessWidget {
  final String userId;
  const UserDataFetcher({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!.exists) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final nome = userData['nome'] ?? 'Usuário';
            return HomeScreen(nomeUsuario: nome);
          }
          // Se não encontrar os dados do usuário (raro), desloga por segurança
          FirebaseAuth.instance.signOut();
          return const StartPage();
        }
        // Enquanto busca os dados, mostra uma tela de carregamento
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
