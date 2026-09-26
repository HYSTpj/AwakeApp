import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

const _fakeOptions = FirebaseOptions(
  apiKey: 'fake-api-key',
  appId: 'fake-app-id',
  messagingSenderId: 'fake-sender-id',
  projectId: 'fake-project-id',
);

class _FakeFirebaseAppPlatform extends FirebaseAppPlatform {
  _FakeFirebaseAppPlatform(super.name, super.options);
}

/// `FirebasePlatform.instance` をFakeに差し替えることで、実際のプラットフォーム
/// チャンネル（Pigeon）に触れずに `Firebase.initializeApp()` / `Firebase.app()` を
/// 成立させる。`CommonLayout` など `FirebaseAuth.instance.currentUser` を参照する
/// Widgetをpumpするテストで使う（`setupFirebaseCoreMocks()` 経由）。
///
/// 呼び出しは `test/flutter_test_config.dart` の `testExecutable` が全テストファイルに
/// 対して自動的に一度だけ行う。`firebase_core` は最初の `Firebase.*` アクセス時に
/// 内部で `FirebasePlatform.instance` をキャッシュするため、同一テストファイル内で
/// 本関数を2回以上呼んでも2回目以降は無視される（2回目のFakeには切り替わらない）。
class FakeFirebasePlatform extends FirebasePlatform {
  _FakeFirebaseAppPlatform? _app;

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    final app = _app;
    if (app == null || app.name != name) {
      throw FirebaseException(
        plugin: 'core',
        code: 'no-app',
        message:
            'No Firebase App "$name" has been created - call Firebase.initializeApp()',
      );
    }
    return app;
  }

  @override
  List<FirebaseAppPlatform> get apps => _app == null ? const [] : [_app!];

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    final app = _FakeFirebaseAppPlatform(
      name ?? defaultFirebaseAppName,
      options ?? _fakeOptions,
    );
    _app = app;
    return app;
  }
}

/// `FirebaseAuthPlatform.instance` をFakeに差し替えることで、`FirebaseAuth.instance`
/// を実プラットフォームチャンネル（Pigeonのリスナー登録含む）に一切触れさせずに
/// 済ませる。常に未ログイン（`currentUser == null`）として振る舞う。
///
/// 実装していないのは `delegateFor`/`setInitialValues`/`currentUser` の3つだけで、
/// サインイン等の実操作を呼ぶテストは対象外（`FirebaseAuthPlatform`の他メソッドは
/// 未オーバーライドのまま `UnimplementedError` を投げる）。
class FakeFirebaseAuthPlatform extends FirebaseAuthPlatform {
  @override
  FirebaseAuthPlatform delegateFor({required FirebaseApp app}) => this;

  @override
  FirebaseAuthPlatform setInitialValues({
    PigeonUserDetails? currentUser,
    String? languageCode,
  }) =>
      this;

  @override
  UserPlatform? get currentUser => null;
}

Future<void> setupFirebaseCoreMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  FirebasePlatform.instance = FakeFirebasePlatform();
  FirebaseAuthPlatform.instance = FakeFirebaseAuthPlatform();
  await Firebase.initializeApp();
}
