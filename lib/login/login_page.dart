import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ViewModel
import '../presentation/viewmodels/auth_view_model.dart';

// 画面遷移先
import '../group/view/group_list_view.dart';
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
    // パスワード用のコントローラー破棄
    passwordController.dispose();
    // 親クラスの破棄処理
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffoldを消して直接loginBodyを呼び出す
    return loginBody(
      emailController: emailController,
      passwordController: passwordController,
      onLoginPressed: () async {
        final email = emailController.text.trim();
        final password = passwordController.text;

        if (email.isEmpty || password.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('メールアドレスとパスワードを入力してください')),
          );
          return;
        }

        // AuthViewModel 経由でログイン実行
        final authViewModel = context.read<AuthViewModel>();
        final success = await authViewModel.signIn(
          email: email,
          password: password,
        );

        if (!context.mounted) return;

        if (success) {
          debugPrint("ログイン成功");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const GroupListPage()),
          );
        } else {
          final errorMsg = authViewModel.state.errorMessage ?? 'ログインに失敗しました';
          debugPrint("ログイン失敗: $errorMsg");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg)),
          );
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