import 'package:flutter/material.dart';

// Firebaseを利用するためのパッケージ
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Firestoreを利用するためのパッケージ
import 'package:cloud_firestore/cloud_firestore.dart';

// Supabaseを利用するためのパッケージ
import 'package:supabase_flutter/supabase_flutter.dart';

// Google Mapを利用するためのパッケージ
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

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
  
  runApp(const MyApp());
}

// アプリ全体の基盤
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
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      // アプリ起動時に一番に表示する画面設定
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // このウィジェットはアプリケーションのホームページ
  // ステートフルなウィジェットであり，表示方法に影響を与えるフィールドを含むStateオブジェクト（下記参照）を持っている
  // つまり，表示方法に影響を与えるフィールドが含まれている

  // このクラスは状態の設定
  // 親ウィジェット（この場合はアプリウィジェット）から提供された値（この場合はタイトル）を保持し，状態のビルドメソッドで使用される
  // ウィジェットサブクラスのフィールドは常に「final」とマークされる

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // この setState の呼び出しは，Flutter フレームワークにこのステートに何らかの変更があったことを伝え，
      // その結果，以下の build メソッドが再実行され，
      // ディスプレイに更新された値が反映される
      // もし，_counter を setState() を呼び出さずに変更した場合，
      // build メソッドは再実行されず，何も変化がないように見える
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // このメソッドは，例えば上記の_incrementCounterメソッドのように，setStateが呼び出されるたびに再実行される
    //
    // Flutterフレームワークは，ビルドメソッドの再実行を高速化するように最適化されているため，
    // ウィジェットのインスタンスを個別に変更するのではなく，更新が必要なものだけを再ビルドできる
    // ウィジェットのインスタンスを個別に変更する必要はない

    // 画面レイアウト
    return Scaffold(
      // 画面上部のタイトルバー
      appBar: AppBar(
        // ここで色を特定の色（例えばColors.amberなど）に変更し，"hot reload"を実行して，
        // AppBarの色だけが変化し，他の色はそのままになることを確認する
        // 他の色は変化しません。
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // ここでは、App.build メソッドによって作成された MyHomePage オブジェクトの値を取得し
        // それを使用してアプリバーのタイトルを設定する
        title: Text(widget.title),
      ),
      body: Center(
        // Centerはレイアウトウィジェット
        // 単一の子要素を受け取り，親要素の中央に配置する
        child: Column(
          // Columnもレイアウトウィジェット．子要素のリストを受け取り，それらを垂直方向に配置する
          // デフォルトでは，子要素の水平方向のサイズに合わせて自身をサイズ調整し，
          // 親要素と同じ高さになるように調整する
          //
          // Columnには，サイズや子要素の配置を制御するための様々なプロパティがある
          // ここでは，mainAxisAlignmentを使用して，子要素を垂直方向に中央揃えする
          // ここでいう主軸は垂直軸
          // Columnは垂直方向なので，主軸は垂直軸になる（交差軸は水平方向になる(Rowを用いる)）
          //
          // デバッグペイントを実行する（IDEで「デバッグペイントの切り替え」アクションを
          // 選択するか，コンソールで「p」を押す）
          // すると，各ウィジェットのワイヤーフレームが表示される
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}