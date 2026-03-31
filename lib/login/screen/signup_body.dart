import 'package:flutter/material.dart';
import 'login_header_screen.dart'; // ヘッダーを定義したファイルをインポート

Widget SignupBody({
    required TextEditingController emailController, // LoginPageで定義したcontrollerを引数として受け取る
    required TextEditingController passwordController, // LoginPageで定義したcontrollerを引数として受け取る 
    required VoidCallback onRegisterPressed, // ログインボタンが押されたときの処理を引数として受け取る
    required VoidCallback onReturnToLoginPressed, // ログイン画面に遷移するボタンが押されたときの処理を引数として受け取る
}) {
    return Scaffold(
        backgroundColor: Color(0xFFf8f6f6),
        body: SingleChildScrollView(
            child: Center(
                child: Column(
                    children: [

                        myHeader(), // ヘッダーを呼び出す
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
                                        'Join us among the elite who master time.',
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
                                        child: TextField(
                                            controller: emailController, // LoginPageで定義したcontrollerをTextFieldに渡す
                                            decoration: InputDecoration(
                                                filled: true, // 色を塗ることを許可する
                                                fillColor: Colors.white, // colorの代わりにfillColor
                                                
                                                border: OutlineInputBorder( // shapeの代わりにborderを使う
                                                    borderSide: BorderSide(
                                                        width: 1,
                                                        color: const Color(0xFF6B7280),
                                                    ),
                                                ),

                                                hintText: 'your@email.com'
                                            ),
                                        ),
                                    ),

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

                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                color: const Color(0xFF6B7280), 
                                                width: 1,
                                            ),
                                            boxShadow: const [
                                                BoxShadow(
                                                    color: Colors.black,
                                                    offset: Offset(4, 4), // 右下のくっきりした影
                                                ),
                                            ],
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
                                            decoration: BoxDecoration(
                                                color: const Color(0xFFEC5B13), // オレンジ色
                                                border: Border.all(color: Colors.black, width: 1), // 枠線
                                                boxShadow: const [
                                                BoxShadow(
                                                    color: Colors.black,
                                                    offset: Offset(4, 4), // あの影！
                                                ),
                                                ],
                                            ),
                                            child: ElevatedButton(
                                                onPressed: onRegisterPressed, // 引数で受け取ったonRegisterPressedをここで呼び出す
                                                style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent, // 背景を透明にしてContainerの色を出す
                                                shadowColor: Colors.transparent,     // ボタン自体の影を消す
                                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), // 四角いボタンにする
                                                ),
                                                child: const Text(
                                                'CREATE ACCOUNT',
                                                style: TextStyle(
                                                    color: Colors.white, // 文字色
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                ),
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
                                    decoration: BoxDecoration(
                                        // ✅ 解決策：ここを不透明な「白」にする
                                        color: Colors.white, 
                                        border: Border.all(color: Colors.black, width: 1), // 枠線
                                        boxShadow: const [
                                        BoxShadow(
                                            color: Colors.black,
                                            offset: Offset(4, 4), // 影
                                        ),
                                        ],
                                    ),
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