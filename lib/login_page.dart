import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'signup_page.dart';
import 'grouplist_page.dart'; // グループリストページへ移動

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
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // メールアドレス
            TextField(
              controller:emailController,
              decoration: const InputDecoration(labelText: "メールアドレス", border:OutlineInputBorder(),)
            ),

            const SizedBox(height: 20),
            // パスワード
            TextField(
                controller:passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "パスワード", border:OutlineInputBorder(),)
            ),

            const SizedBox(height: 30),
            // ログインボタン
            ElevatedButton(
              onPressed: () async{

                // ログイン処理をここに実装
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text
                  );

                  if (context.mounted) {
                    Navigator.push(
                      context,
                      // グループリストページへ移動
                      MaterialPageRoute(
                        builder: (context) => const GroupListPage(),
                      ),
                    );
                    debugPrint("ログイン成功");
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('ログインに失敗しました：$e'),
                      ),
                    );
                    debugPrint("ログイン失敗: $e");
                  }
                }
              },
              child: const Text("ログイン"),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 均等に
              children: [
                // FOREGOT PASSWORD? ボタン
                ElevatedButton(
                  onPressed: () async {
                    // 入力されたメールアドレス宛にパスワード再設定メールを送信
                    final email = emailController.text.trim();
                    if (email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('パスワード再設定用のメールアドレスを入力してください。'),
                        ),
                      );
                      return;
                    }
                    try {
                      await FirebaseAuth.instance
                        .sendPasswordResetEmail(email: email);

                      // 今画面に表示されているか確認
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('パスワード再設定用のメールを送信しました。'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('パスワード再設定に失敗しました: $e'),
                        ),
                      );
                    }
                  },
                  child: const Text('FORGOT PASSWORD?')
                ),

                // アカウント作成ボタン
                ElevatedButton(
                  onPressed: () {

                    // アカウント作成の処理をここに実装                   
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateAccountPage(),
                      ),
                    );

                  },
                  child: const Text('CREATE ACCOUNT')
                ),
              ]
            )
          ],
        ),
      )
    );
  }
}
