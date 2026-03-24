import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebaseの認証機能
import 'signup_page.dart'; // アカウント作成画面への遷移のためにインポート


// ログイン機能
class LoginPage extends StatefulWidget {      
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState(); 
}

    @override
class _LoginPageState extends State<LoginPage> {

        // テキスト（メール・パスワード）入力を取得・操作するためのコントローラー作成
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
            // 画面上部のバー（タイトルなどを表示する部分）作成
            appBar: AppBar(
                title: const Text('Login'),
            ),
            // 画面の内容部分作成
            body: Padding(
                padding: const EdgeInsets.all(20), // 周りの余白
                child: Column(
                    children: [
                        // メールアドレス
                        TextField(
                            controller:emailController,
                            decoration: const InputDecoration(
                              labelText: "メールアドレス",
                              border:OutlineInputBorder(),
                            ),
                        ),

                        const SizedBox(height: 20),

                        // パスワード
                        TextField(
                            controller:passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "パスワード",
                              border:OutlineInputBorder(),
                            ),
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

                                    print("ログイン成功");
                                } catch (e) {
                                    print("ログイン失敗: $e");
                                };
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
                                  // アカウント作成画面に遷移
                                  MaterialPageRoute(
                                    builder: (context) => CreateAccountPage(),
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