import 'dart:async';

import 'test_helpers/firebase_mock_setup.dart';

/// `test/` 以下の全テストファイルに対して、各ファイルの `main()` が動く前に一度だけ
/// 実行される（flutter_testの規約）。`CommonLayout` など `FirebaseAuth.instance` を
/// 参照するWidgetをpumpWidgetするテストが、個々のファイルで `setUpAll` を書かなくても
/// 素通りできるようにするための共通セットアップ。
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await setupFirebaseCoreMocks();
  await testMain();
}
