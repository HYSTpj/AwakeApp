// Firebaseからuser情報取得するためのパッケージ
import 'package:firebase_auth/firebase_auth.dart';

// auth_users ドキュメント
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }
}