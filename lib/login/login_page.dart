import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_page.dart'; // アカウント作成画面への遷移に必要
import 'screen/login_body.dart'; // ログイン画面のUIを定義したファイル
import 'screen/signup_body.dart'; // アカウント作成画面のUIを定
import 'screen/login_header_screen.dart'; // ログイン画面のヘッダーを定義したファイル

// ログイン機能
class LoginPage extends StatefulWidget {      
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState(); 
}

class _LoginPageState extends State<LoginPage> {
        final emailController = TextEditingController();
        final passwordController = TextEditingController();

        @override
        void dispose() {
        // メールアドレス用のコントローラー破棄
          emailController.dispose();
        //パスワード用のコントローラー破棄
          passwordController.dispose();
        //親クラスの破棄処理
          super.dispose();
        }

        @override
        Widget build(BuildContext context) {
        // 画面のベース（アプリの見た目の骨組み）作成
          return Scaffold(
            
            body: loginBody(
              emailController: emailController,
              passwordController: passwordController,
              
              // ログインボタンが押された時の処理
              onLoginPressed: () async {
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );
                  print("ログイン成功");
                  // ここにログイン後の画面遷移を書くと完璧です！
                } catch (e) {
                  print("ログイン失敗: $e");
                }
              },

              // アカウント作成ボタンが押された時の処理
              onCreateAccountPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateAccountPage()), // signup_page.dart へ
                );
              },
            ),
          );
    }
}