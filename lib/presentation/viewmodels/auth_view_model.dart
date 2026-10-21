import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository.dart';
import '../../models/profile.dart';

// 認証関連の UI 状態を保持する不変（Immutable）ステートクラス
class AuthState {
  final Profile? user;
  // ローディング状態を分離
  final bool isProfileLoading;
  final bool isAuthActionLoading;

  final String? profileErrorMessage;
  final String? authErrorMessage;

  const AuthState({
    this.user,
    this.isProfileLoading = false,
    this.isAuthActionLoading = false,
    this.profileErrorMessage,
    this.authErrorMessage,
  });

  // 既存コード（LoginPage, CreateAccountPage）との後方互換用ゲッター
  bool get isLoading => isAuthActionLoading || isProfileLoading;
  String? get errorMessage => authErrorMessage ?? profileErrorMessage;

  AuthState copyWith({
    Profile? user,
    bool? isProfileLoading,
    bool? isAuthActionLoading,
    String? profileErrorMessage,
    String? authErrorMessage,
    bool clearProfileError = false,
    bool clearAuthError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isProfileLoading: isProfileLoading ?? this.isProfileLoading,
      isAuthActionLoading: isAuthActionLoading ?? this.isAuthActionLoading,
      profileErrorMessage: clearProfileError
          ? null
          : (profileErrorMessage ?? this.profileErrorMessage),
      authErrorMessage: clearAuthError
          ? null
          : (authErrorMessage ?? this.authErrorMessage),
    );
  }
}

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  AuthState _state = const AuthState();

  // 画面非依存で非同期タスクの有効性を保証する世代番号
  int _activeSessionToken = 0;

  AuthViewModel(this._authRepository);

  AuthState get state => _state;

  Future<bool> signUp({
    required String email,
    required String password,
    String? nickname,
  }) async {
    if (_state.isAuthActionLoading) return false;

    _activeSessionToken++;

    _state = _state.copyWith(
      isAuthActionLoading: true,
      clearAuthError: true,
      isProfileLoading: false,
      clearProfileError: true,
    );
    notifyListeners();

    try {
      final profile = await _authRepository.signUp(
        email: email,
        password: password,
        nickname: nickname,
      );
      _state = _state.copyWith(
        user: profile,
        isAuthActionLoading: false,
        isProfileLoading: false,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        isAuthActionLoading: false,
        isProfileLoading: false,
        authErrorMessage: e.toString(),
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    if (_state.isAuthActionLoading) return false;

    _activeSessionToken++;

    _state = _state.copyWith(
      isAuthActionLoading: true,
      clearAuthError: true,
      isProfileLoading: false,
      clearProfileError: true,
    );
    notifyListeners();

    try {
      final profile = await _authRepository.signIn(
        email: email,
        password: password,
      );
      _state = _state.copyWith(
        user: profile,
        isAuthActionLoading: false,
        isProfileLoading: false,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        isAuthActionLoading: false,
        isProfileLoading: false,
        authErrorMessage: e.toString(),
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> signOut() async {
    if (_state.isAuthActionLoading) return false;

    _activeSessionToken++;

    _state = _state.copyWith(
      isAuthActionLoading: true,
      clearAuthError: true,
      isProfileLoading: false,
      clearProfileError: true,
    );
    notifyListeners();

    try {
      await _authRepository.signOut();
      _state = const AuthState();
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        isAuthActionLoading: false,
        isProfileLoading: false,
        authErrorMessage: 'ログアウトに失敗しました: $e',
      );
      notifyListeners();
      return false;
    }
  }

  Future<void> loadCurrentProfile() async {
    if (_state.isAuthActionLoading) return;

    final uidAtStart = _authRepository.currentUserId;
    if (uidAtStart == null) {
      if (_state.user != null || _state.isProfileLoading) {
        _state = _state.copyWith(clearUser: true, isProfileLoading: false);
        notifyListeners();
      }
      return;
    }

    final currentToken = ++_activeSessionToken;

    _state = _state.copyWith(isProfileLoading: true, clearProfileError: true);
    notifyListeners();

    try {
      final profile = await _authRepository.getCurrentProfile();

      if (currentToken != _activeSessionToken) return;

      // 外部でセッションが変わっていたら、安全にクリアして終了
      if (_authRepository.currentUserId != uidAtStart) {
        _state = _state.copyWith(clearUser: true, isProfileLoading: false);
        notifyListeners();
        return;
      }

      if (profile != null) {
        _state = _state.copyWith(user: profile, isProfileLoading: false);
      } else {
        _state = _state.copyWith(clearUser: true, isProfileLoading: false);
      }
    } catch (e) {
      if (currentToken != _activeSessionToken) return;

      // 外部でセッションが変わっていた場合も、スピナーを解除して古いユーザー情報をクリア
      if (_authRepository.currentUserId != uidAtStart) {
        _state = _state.copyWith(clearUser: true, isProfileLoading: false);
        notifyListeners();
        return;
      }

      // 同一セッションでプロフィール取得に失敗した場合
      _state = _state.copyWith(
        clearUser: true,
        isProfileLoading: false,
        profileErrorMessage: 'プロフィール取得失敗: $e',
      );
    }
    notifyListeners();
  }
}