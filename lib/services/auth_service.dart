import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth auth;

  AuthService({FirebaseAuth? firebaseAuth}) : auth = firebaseAuth ?? FirebaseAuth.instance;

  Future<UserCredential> login(String email, String password) async {
    return await auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> cadastro(String email, String senha) async {
    return await auth.createUserWithEmailAndPassword(email: email, password: senha);
  }
}
