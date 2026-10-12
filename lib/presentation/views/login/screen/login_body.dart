import 'package:flutter/material.dart';
import 'login_header.dart';
import '../common_effects.dart';

Widget loginBody(
    BuildContext context, {
    required TextEditingController emailController, // LoginPageで定義したcontrollerを引数として受け取る
    required TextEditingController passwordController, // LoginPageで定義したcontrollerを引数として受け取る
    required VoidCallback onLoginPressed, // ログインボタンが押されたときの処理を引数として受け取る
    required VoidCallback onCreateAccountPressed, // アカウント作成ボタンが押されたときの処理を引数として受け取る
}) {
    return Scaffold(
        backgroundColor: Color(0xFFf8f6f6),

        body: SingleChildScrollView(
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
                                    'SIGN IN',
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
                                    'We give medals to the timely and\nshame to the tardy',
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

                                // Login Button
                                Padding(
                                    padding: const EdgeInsets.only(top: 25, bottom: 24),
                                    child: Container(
                                        width: 320,
                                        height: 56,
                                        decoration: hardShadowDecoration(
                                            color: kBrandOrange,
                                        ),
                                        child: ElevatedButton(
                                            onPressed: onLoginPressed,
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent, // 背景はContainerに任せる
                                                shadowColor: Colors.transparent,
                                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                            ),
                                            child: const Text(
                                                'LOGIN',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                ),
                                            ),
                                        ),
                                    ),
                                ),

                                // CREATE ACCOUNT
                                Container(
                                    width: 320,
                                    height: 48,
                                    // 💡 ポイント：paddingをEdgeInsets.zeroにしてズレを防ぐ
                                    padding: EdgeInsets.zero,
                                    decoration: hardShadowDecoration(color: Colors.white),
                                    child: ElevatedButton(
                                        onPressed: onCreateAccountPressed,
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent, // ここは透明のままでOK（Containerの白が見える）
                                            shadowColor: Colors.transparent,     // ボタン自体の影を消す
                                            // 💡 ポイント：ボタンの最小サイズをContainerに合わせる
                                            minimumSize: const Size(320, 48), 
                                            padding: EdgeInsets.zero,
                                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                        ),
                                        child: const Text(
                                            'CREATE ACCOUNT',
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
    );
}