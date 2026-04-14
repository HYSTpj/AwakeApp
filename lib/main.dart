import 'package:flutter/material.dart';
import 'presentation/views/member_settime.dart';

void main() {
  runApp(const UiPreviewApp());
}

class UiPreviewApp extends StatelessWidget {
  const UiPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HYST UI Preview',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MemberSetTimePage.withDummyData(),
    );
  }
}

// Temporary compatibility alias for tests and old references.
class MyApp extends UiPreviewApp {
  const MyApp({super.key});
}

/*
--- Existing main.dart (kept for later verification) ---

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
*/