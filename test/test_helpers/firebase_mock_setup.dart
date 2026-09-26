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
/// 成立させる。`CommonLayout` など `FirebaseAuth.instance.currentUser` を同期的に
/// 参照するだけのWidgetであれば、これで十分。
///
/// 注意: ここでFakeにしているのは `firebase_core`（`FirebasePlatform`）だけで、
/// `firebase_auth` の `FirebaseAuthPlatform` は差し替えていない。`currentUser` の
/// 同期nullチェックは通るが、`signInWithEmailAndPassword` など実際のプラットフォーム
/// 往復を必要とするAuth操作をpumpWidget内で呼ぶテストでは、別途
/// `FirebaseAuthPlatform.instance` もFakeに差し替える必要がある（未対応）。
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

Future<void> setupFirebaseCoreMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  FirebasePlatform.instance = FakeFirebasePlatform();
  await Firebase.initializeApp();
}
