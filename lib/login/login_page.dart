import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/grouplist_page.dart';
import 'signup_page.dart'; // アカウント作成画面への遷移に必要
import 'screen/login_body.dart'; // ログイン画面のUIを定義したファイル

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
          // Scaffoldを消して直接loginBodyを呼び出す
          return loginBody(
            emailController: emailController,
            passwordController: passwordController,
            
            onLoginPressed: () async {
              try {
                // ★ここを確実に controller.text で取得するようにします
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                );
                debugPrint("ログイン成功");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GroupListPage()),
                );
              } catch (e) {
                debugPrint("ログイン失敗: $e");
              }
            },

            onCreateAccountPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateAccountPage()),
              );
            },
          );
        }
}