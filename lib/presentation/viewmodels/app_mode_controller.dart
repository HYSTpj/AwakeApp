import 'package:flutter/foundation.dart';

import '../views/common/app_mode.dart';

/// ヘッダー・フッターの管理者/メンバー表示を保持するアプリ全体の状態。
///
/// 画面（Widget）単位ではなくアプリ全体で単一のインスタンスを共有することで、
/// 画面遷移をしても値が変わらず、ヘッダーのモード切替アイコンをタップしたときだけ
/// [setMode] で更新される。BuildContext を介さずに参照できるよう、
/// Provider 経由ではなくシングルトンとして公開する。
class AppModeController extends ChangeNotifier {
  AppModeController._();

  static final AppModeController instance = AppModeController._();

  AppMode _mode = AppMode.member;

  AppMode get mode => _mode;

  void setMode(AppMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }
}
