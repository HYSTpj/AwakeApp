import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository.dart';
import '../../models/profile.dart';

// 認証関連の UI 状態を保持する不変（Immutable）ステートクラス
class AuthState {
// ログイン中のユーザープロフィール（未ログイン時は null）
  final Profile? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  // 既存の状態を維持しつつ一部のフィールドのみを更新した新しい [AuthState] を生成する
  AuthState copyWith({
    Profile? user,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// 認証フロー（新規登録・ログイン・ログアウト）のビジネスロジックおよび状態を管理する ViewModel
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  AuthState _state = const AuthState();

  AuthViewModel(this._authRepository);

  /// 外部（View層）から購読するための現在の状態ゲッター
  AuthState get state => _state;

  // 新規アカウントを登録し、成功時はプロフィール状態を更新する
  Future<bool> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final profile = await _authRepository.signUp(
        email: email,
        password: password,
        nickname: nickname,
      );
      _state = _state.copyWith(user: profile, isLoading: false);
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
      return false;
    }
  }

  // メールアドレスとパスワードでサインインし、プロフィール状態を更新する
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final profile = await _authRepository.signIn(
        email: email,
        password: password,
      );
      _state = _state.copyWith(user: profile, isLoading: false);
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
      return false;
    }
  }

  // サインアウトを実行し、保持している認証状態（プロフィール情報）を初期化する
  Future<void> signOut() async {
    await _authRepository.signOut();
    _state = const AuthState();
    notifyListeners();
  }
}