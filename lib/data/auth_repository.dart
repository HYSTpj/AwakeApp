// Firebaseからuser情報取得するためのパッケージ
import 'package:firebase_auth/firebase_auth.dart';

// auth_users ドキュメント
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // アカウント作成
  Future<void> createUser(String email, String password) async {
    // 2.リクエスト
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
  }
  // 3.成功 (成功 => 戻り値void, 失敗 => error)

  // ログイン
  Future<void> signIn(String email, String password) async {
    // 2.リクエスト
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password
    );
  }
  // 3.成功 (成功 => 戻り値void, 失敗 => error)

  // パスワード再設定
  Future<void> sendPassword(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email
    );
  }
}