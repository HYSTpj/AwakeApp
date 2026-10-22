import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/auth_repository.dart';
import '../../models/profile.dart';

/// 直前のサインイン/サインアップ/プロフィール更新試行の結果を表す sealed class
sealed class AuthOutcome {
  const AuthOutcome();
}

/// 通常の失敗（メール/パスワード不正など）
class AuthFailed extends AuthOutcome {
  final String message;
  const AuthFailed(this.message);
}

/// サインアップ後、メール確認待ちであることを示す（失敗ではない）
class AuthEmailConfirmationPending extends AuthOutcome {
  const AuthEmailConfirmationPending();
}

/// 認証関連の UI 状態を保持する不変（Immutable）ステートクラス
class AuthState {
  final Profile? user;

  // ローディング状態を分離（競合・レースコンディション対策）
  final bool isProfileLoading;
  final bool isAuthActionLoading;

  // 認証アクションの結果（成功/失敗/メール確認待ち）
  final AuthOutcome? outcome;
  final String? profileErrorMessage;

  const AuthState({
    this.user,
    this.isProfileLoading = false,
    this.isAuthActionLoading = false,
    this.outcome,
    this.profileErrorMessage,
  });

  // 既存画面（LoginPage, CreateAccountPage）との後方互換用ゲッター
  bool get isLoading => isAuthActionLoading || isProfileLoading;

  String? get authErrorMessage => switch (outcome) {
    AuthFailed(:final message) => message,
    _ => null,
  };

  String? get errorMessage => authErrorMessage ?? profileErrorMessage;

  bool get isEmailConfirmationPending =>
      outcome is AuthEmailConfirmationPending;

  AuthState copyWith({
    Profile? user,
    bool? isProfileLoading,
    bool? isAuthActionLoading,
    AuthOutcome? outcome,
    String? profileErrorMessage,
    bool clearOutcome = false,
    bool clearProfileError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isProfileLoading: isProfileLoading ?? this.isProfileLoading,
      isAuthActionLoading: isAuthActionLoading ?? this.isAuthActionLoading,
      outcome: clearOutcome ? null : (outcome ?? this.outcome),
      profileErrorMessage: clearProfileError
          ? null
          : (profileErrorMessage ?? this.profileErrorMessage),
    );
  }
}

/// 認証フロー（新規登録・ログイン・ログアウト・プロフィール更新）の ViewModel
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  AuthState _state = const AuthState();

  // 画面非依存で非同期タスクの有効性を保証する世代番号
  int _activeSessionToken = 0;

  AuthViewModel(this._authRepository);

  AuthState get state => _state;

  /// サインアップ
  Future<bool> signUp({required String email, required String password}) async {
    return _guardedAction(
      () => _authRepository.signUp(email: email, password: password),
    );
  }

  /// サインイン
  Future<bool> signIn({required String email, required String password}) async {
    return _guardedAction(
      () => _authRepository.signIn(email: email, password: password),
    );
  }

  /// サインアウト
  Future<bool> signOut() async {
    if (_state.isAuthActionLoading) return false;

    _activeSessionToken++;

    _state = _state.copyWith(
      isAuthActionLoading: true,
      clearOutcome: true,
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
        outcome: AuthFailed('ログアウトに失敗しました: $e'),
      );
      notifyListeners();
      return false;
    }
  }

  /// 現在のプロフィールを取得
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

      // 外部でセッションが変わっていたら安全にクリア
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

      if (_authRepository.currentUserId != uidAtStart) {
        _state = _state.copyWith(clearUser: true, isProfileLoading: false);
        notifyListeners();
        return;
      }

      _state = _state.copyWith(
        clearUser: true,
        isProfileLoading: false,
        profileErrorMessage: 'プロフィール取得失敗: $e',
      );
    }
    notifyListeners();
  }

  /// ユーザー名の入力値をトリムして検証する共通ヘルパー
  /// 有効な場合はトリム済み文字列を返し、無効な場合は null を返してエラー状態を設定する
  String? _validateAndTrimNickname(String nickname) {
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) {
      _state = _state.copyWith(outcome: const AuthFailed('ユーザー名を入力してください'));
      notifyListeners();
      return null;
    }
    if (trimmed.length > 30) {
      _state = _state.copyWith(
        outcome: const AuthFailed('ユーザー名は30文字以内で入力してください'),
      );
      notifyListeners();
      return null;
    }
    return trimmed;
  }

  /// ニックネーム・アイコン画像両方の更新（オンボーディング完了時など）
  Future<bool> completeProfile({
    required String nickname,
    File? avatarImage,
  }) async {
    final validNickname = _validateAndTrimNickname(nickname);
    if (validNickname == null) return false;

    return _guardedAction(
      () => _authRepository.updateProfile(
        nickname: validNickname,
        avatarImage: avatarImage,
      ),
    );
  }

  /// ユーザー名の更新
  Future<bool> updateNickname(String newNickname) async {
    // プロフィール取得中および別アクション実行中は競合を防ぐため拒否
    if (_state.isAuthActionLoading || _state.isProfileLoading) {
      return false;
    }

    final validNickname = _validateAndTrimNickname(newNickname);
    if (validNickname == null) return false;

    return _guardedAction(() => _authRepository.updateNickname(validNickname));
  }

  /// 共通アクションガード（多重実行防止・結果ハンドリング）
  Future<bool> _guardedAction(Future<Profile> Function() action) async {
    if (_state.isAuthActionLoading) return false;

    _activeSessionToken++;

    _state = _state.copyWith(
      isAuthActionLoading: true,
      clearOutcome: true,
      isProfileLoading: false,
      clearProfileError: true,
    );
    notifyListeners();

    try {
      final profile = await action();
      _state = _state.copyWith(
        user: profile,
        isAuthActionLoading: false,
        isProfileLoading: false,
      );
      notifyListeners();
      return true;
    } on EmailConfirmationPendingException {
      _state = _state.copyWith(
        isAuthActionLoading: false,
        isProfileLoading: false,
        outcome: const AuthEmailConfirmationPending(),
      );
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('認証操作でエラーが発生しました: $e');
      _state = _state.copyWith(
        isAuthActionLoading: false,
        isProfileLoading: false,
        outcome: AuthFailed(_toUserMessage(e)),
      );
      notifyListeners();
      return false;
    }
  }
}

/// エラーメッセージをユーザー向け日本語に変換
String _toUserMessage(Object error) {
  if (error is AuthException) {
    switch (error.message) {
      case 'Invalid login credentials':
        return 'メールアドレスまたはパスワードが正しくありません';
      case 'User already registered':
        return 'このメールアドレスは既に登録されています';
      case 'ログインしていません':
        return error.message;
    }
  }
  if (error is ArgumentError) {
    return error.message.toString();
  }
  return 'エラーが発生しました。しばらくしてから再度お試しください';
}
