import 'package:flutter/material.dart';
import 'login_header_screen.dart'; // ヘッダーを定義したファイルをインポート
import 'loading_button_label.dart';
import '../common_effects.dart';

class SignupBody extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onRegisterPressed;
  final VoidCallback onReturnToLoginPressed;
  final bool isLoading; // サインアップ処理中は true になり、多重タップによる多重送信を防ぐ

  const SignupBody({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onRegisterPressed,
    required this.onReturnToLoginPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFf8f6f6),
        body: SingleChildScrollView(
            child: Center(
                child: Column(
                    children: [

                        myHeader(context), // ヘッダーを呼び出す
                        /* ロゴとキャッチコピーの部分 */
                        Padding(
                            padding: const EdgeInsets.only(top: 34, bottom: 24),
                            child: Column(
                                children: [
                                    // ロゴ
                                    Text(
                                        'CREATE ACCOUNT',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                        color: const Color(0xFF0F172A),
                                        fontSize: 36,
                                        fontFamily: 'Noto Sans JP',
                                        fontWeight: FontWeight.w900,
                                        height: 1.25,
                                        letterSpacing: -1.80,
                                        ),
                                    ),

                                    // キャッチコピー
                                    Text(
                                        'Join us among the elite who master time.\nLet\'sAWAKE!',
                                        textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: const Color(0xFF334155),
                                                fontSize: 14,
                                                fontFamily: 'Noto Sans JP',
                                                fontWeight: FontWeight.w700,
                                                height: 1.63,
                                            ),
                                        ),

                                ],
                            ),
                        ),

                        // ボタン類
                        Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                                children: [
                                    
                                    // EMAIL ADDRESS
                                    Text(
                                        'EMAIL ADDRESS',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                        color: const Color(0xFF0F172A),
                                        fontSize: 12,
                                        fontFamily: 'Noto Sans JP',
                                        fontWeight: FontWeight.w900,
                                        height: 1.33,
                                        letterSpacing: 1.20,
                                        ),
                                    ),

                                    Container(
                                        width: 320,
                                        height: 56,
                                        decoration: hardShadowDecoration(
                                            color: Colors.white,
                                            borderColor: const Color(0xFF6B7280),
                                        ),
                                        child: TextField(
                                            controller: emailController, // LoginPageで定義したcontrollerをTextFieldに渡す
                                            decoration: const InputDecoration(
                                                hintText: 'your@email.com',
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                            ),
                                        ),
                                    ),
                                    const SizedBox(height: 16), // 影との重なりを防ぐための余白

                                    // PASSWORD
                                    Text(
                                        'PASSWORD',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                        color: const Color(0xFF0F172A),
                                        fontSize: 12,
                                        fontFamily: 'Noto Sans JP',
                                        fontWeight: FontWeight.w900,
                                        height: 1.33,
                                        letterSpacing: 1.20,
                                        ),
                                    ),

                                    Container(
                                        width: 320,
                                        height: 56,

                                        decoration: hardShadowDecoration(
                                            color: Colors.white,
                                            borderColor: const Color(0xFF6B7280),
                                        ),

                                        child: TextField(
                                            controller: passwordController, // LoginPageで定義したcontrollerを使用
                                            obscureText: true, // パスワードを隠す
                                            decoration: const InputDecoration(
                                                hintText: 'password',
                                                border: InputBorder.none, // デフォルトの枠線を消す
                                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18), // テキストと枠の間のスペース
                                            ),
                                        ),
                                    ),

                                    // REGISTER Button
                                    Padding(
                                        padding: const EdgeInsets.only(top: 25, bottom: 24),
                                        child: Container(
                                            width: 320,
                                            height: 56,
                                            padding: const EdgeInsets.only(top: 0, bottom: 0), // ボタン自体が中央に寄るので0でOK
                                            decoration: hardShadowDecoration(color: kBrandOrange),
                                            child: ElevatedButton(
                                                onPressed: isLoading ? null : onRegisterPressed, // 引数で受け取ったonRegisterPressedをここで呼び出す
                                                style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent, // 背景を透明にしてContainerの色を出す
                                                shadowColor: Colors.transparent,     // ボタン自体の影を消す
                                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), // 四角いボタンにする
                                                ),
                                                child: LoadingButtonLabel(
                                                isLoading: isLoading,
                                                label: 'CREATE ACCOUNT',
                                            ),
                                            ),
                                        ),
                                    ),

                                    // RETURN TOLOGIN ACCOUNT
                                    Container(
                                    width: 320,
                                    height: 48,
                                    // 💡 ポイント：paddingをEdgeInsets.zeroにしてズレを防ぐ
                                    padding: EdgeInsets.zero,
                                    decoration: hardShadowDecoration(color: Colors.white),
                                    child: ElevatedButton(
                                        onPressed: onReturnToLoginPressed,
                                        style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent, // ここは透明のままでOK（Containerの白が見える）
                                        shadowColor: Colors.transparent,     // ボタン自体の影を消す
                                        // 💡 ポイント：ボタンの最小サイズをContainerに合わせる
                                        minimumSize: const Size(320, 48), 
                                        padding: EdgeInsets.zero,
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                        ),
                                        child: const Text(
                                        'RETURN TO LOGIN',
                                        style: TextStyle(
                                            color: Colors.black, // 文字色
                                            fontFamily: 'Noto Sans JP',
                                            fontWeight: FontWeight.w900,
                                            fontSize: 10,
                                        ),
                                        ),
                                    ),
                                    ),
                                ],
                            ),
                        )
                    ],
                ),
            ),
        ),
    );
  }
}