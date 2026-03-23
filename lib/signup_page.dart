import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebaseの認証機能

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
    

    // 画面のベース（アプリの見た目の骨組み）作成
@override
  Widget build(BuildContext context) {
    return Scaffold(

      // 画面上部のバー（タイトルなどを表示する部分）作成
appBar: AppBar(title: const Text('Create Account')),

      // 画面の内容部分作成
      body: Padding (
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

            // アカウント作成ボタン
            ElevatedButton(
              onPressed: () async {
                // アカウント作成の処理をここに実装
                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text
                  );

                  print("アカウント作成成功");
                  // 作成したアカウントで自動的にログインする場合
                  Navigator.pop(context); // 画面を閉じて前の画面に戻る
} on FirebaseAuthException catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.message ?? 'アカウント作成に失敗しました')),
  );
}
              },
              child: const Text('REGISTER')
             ),

             // ログイン画面に戻るボタン
              ElevatedButton(
                onPressed: () {
                  // ログイン画面に戻る処理をここに実装
                  Navigator.pop(context); // 画面を閉じて前の画面に戻る
                },
                child: const Text('LOGIN')
              ),
          ],
        ),
      ),
    );
  }
}