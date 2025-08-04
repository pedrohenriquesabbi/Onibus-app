import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> cadastrar({
    required String email,
    required String senha,
    required String nome,
    required String telefone,
    required String cpf,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // Dados salvos no Firestore
      await _db.collection('usuarios').doc(cred.user!.uid).set({
        'nome': nome,
        'email': email,
        'telefone': telefone,
        'cpf': cpf,
        'uid': cred.user!.uid,
      });

      return null; 
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Erro desconhecido: $e';
    }
  }

  Future<String?> login({
    required String email,
    required String senha,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Erro desconhecido: $e';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get usuarioAtual => _auth.currentUser;
}
