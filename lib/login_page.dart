import 'package:flutter/material.dart';

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
                            onPressed: () {
                                // ログイン処理をここに実装
                                String email = emailController.text;
                                String password = passwordController.text;
                                print(email);
                                print(password);
                            },
                            child: const Text("ログイン"))
                    ],
                ),
                )
        );
    }
}