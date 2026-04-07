import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebaseの認証機能
import 'package:flutter_application_1/login/screen/createaccount_body.dart';
import 'login_page.dart'; // ログイン画面への遷移に必要
import 'screen/signup_body.dart'; // アカウント作成画面のUIを定義したファイル
import 'screen/login_header_screen.dart'; // ログイン画面のヘッダーを

// アカウント作成画面
class CreateAccountPage extends StatefulWidget { 
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
    // テキスト（メール・パスワード）入力を取得・操作するためのコントローラー作成
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    @override
    void dispose() {
      emailController.dispose();
      passwordController.dispose();
      super.dispose();
    }
    

    // 画面のベース（アプリの見た目の骨組み）作成
    @override
    Widget build(BuildContext context) {
      return SignupBody(
        emailController: emailController,
        passwordController: passwordController,
        onRegisterPressed: () async {
        if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('メールアドレスとパスワードを入力してください')),
            );
            return;
          }        
          // ✅ ここにFirebaseの登録処理を書く
          try {
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text,
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CreateAccountBody(context),
              ),
            );
          } on FirebaseAuthException catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.message ?? '失敗しました')),
            );
          }
        },
        onReturnToLoginPressed: () {
          Navigator.pop(context); // ログイン画面に戻る
        },
      );
  }
}
