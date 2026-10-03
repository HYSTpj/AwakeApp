import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ViewModel
import '../../viewmodels/auth_view_model.dart';

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
    // isLoading の変化で再描画されるよう state を購読する
    final isLoading = context.watch<AuthViewModel>().state.isLoading;

    return SignupBody(
      emailController: emailController,
      passwordController: passwordController,
      isLoading: isLoading,
      onRegisterPressed: () async {
        // 再描画が間に合わず連打で呼ばれた場合、誤った失敗メッセージを出さず黙って無視する
        if (context.read<AuthViewModel>().state.isLoading) return;

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
        } else if (authViewModel.state.isEmailConfirmationPending) {
          // メール確認待ち: 通常の失敗とは異なり、案内ダイアログを表示する
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('確認メールを送信しました'),
              content: const Text('メール内のリンクからログインしてください。'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
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
