import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ViewModel
import '../presentation/viewmodels/auth_view_model.dart';

// 画面遷移先・UI
import 'screen/signup_body.dart'; // アカウント作成画面のUIを定義したファイル
import 'create_profile_page.dart'; // プロフィール作成画面

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
        final email = emailController.text.trim();
        final password = passwordController.text;

        if (email.isEmpty || password.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('メールアドレスとパスワードを入力してください')),
          );
          return;
        }

        // AuthViewModel 経由でアカウント登録実行
        final authViewModel = context.read<AuthViewModel>();
        final success = await authViewModel.signUp(
          email: email,
          password: password,
        );

        if (!context.mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('アカウントが作成されました')),
          );

          // 成功したらプロフィール設定画面へ遷移
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CreateAccountProfile()),
          );
        } else {
          final errorMsg = authViewModel.state.errorMessage ?? 'アカウント作成に失敗しました';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg)),
          );
        }
      },
      onReturnToLoginPressed: () {
        Navigator.pop(context); // ログイン画面に戻る
      },
    );
  }
}
