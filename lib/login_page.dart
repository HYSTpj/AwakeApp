import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatelessWidget {
    const LoginPage({super.key});

    @override
    Widget build(BuildContext context) {
        final emailController = TextEditingController();
        final passwordController = TextEditingController();
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

                                print("ログイン成功");
                            } catch (e) {
                                print("ログイン失敗: $e");
                            }
                        },
                        child: const Text("ログイン"),
                        )
                    ],
                ),
                )
        );
    }
}