import 'package:flutter/material.dart';
import 'login/login_page.dart'; // ログインページのインポート

// Firebaseを利用するためのパッケージ
import 'package:firebase_core/firebase_core.dart';
import '../data/firebase_options.dart';

// Supabaseを利用するためのパッケージ
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Flutterを初期化
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebaseを初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Supabaseを初期化
  await Supabase.initialize(
    url: 'https://nnxfbifnaebzfapgbfkr.supabase.co',  // Project URL
    anonKey: 'sb_publishable_eldYHgMllFya3mprP7AMXw_SJrK6bkv', // Anon Key
  );
  
  // 画面のUIスタート
  runApp(const MyApp());
}

// アプリ全体の設定
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // デザインシステム設定
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // これがアプリテーマ
        //
        // "flutter run"でアプリケーションを実行してみると
        // アプリケーションに紫色のツールバーが表示される
        // 次に，アプリを終了せずに，以下の"colorScheme"の"seedColor"を"Colors.green"に変更してみる
        // その後，"hot reload"を実行する（変更を保存するか，Flutter対応IDEの"hot reload"ボタンを押すか，
        // コマンドラインでアプリを起動した場合は"r"キーを押す）
        //
        // カウンターがゼロにリセットされていないことに注意
        // アプリケーションの状態は，再読み込み中に失われない
        // 状態をリセットするには，代わりに"hot restart"を使用
        //
        // これは値だけでなくコードにも適用できる．ほとんどのコード変更は，"hot reload"だけでテストできる

        // デザインタイプの有効設定
        useMaterial3:true,
        //アプリ全体の基本色設定
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // 最初に表示する画面
      home: LoginPage()
    );
  }
}