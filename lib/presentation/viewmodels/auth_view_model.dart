import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/auth_repository.dart';
import '../../models/profile.dart';

// 直前のサインイン/サインアップ/プロフィール更新試行の結果を表す。
// errorMessage と isEmailConfirmationPending を別々の bool/String として持つと
// 両方が同時に値を持つ「あり得ない組み合わせ」を型で防げないため、
// 単一の sealed class に統一している。
sealed class AuthOutcome {
  const AuthOutcome();
}

// 通常の失敗（メール/パスワード不正など）
class AuthFailed extends AuthOutcome {
  final String message;
  const AuthFailed(this.message);
}

// サインアップ後、メール確認待ちであることを示す（失敗ではない）
class AuthEmailConfirmationPending extends AuthOutcome {
  const AuthEmailConfirmationPending();
}

// 認証関連の UI 状態を保持する不変（Immutable）ステートクラス
class AuthState {
  // ログイン中のユーザープロフィール（未ログイン時は null）
  final Profile? user;
  final bool isLoading;
  final AuthOutcome? outcome;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.outcome,
  });

  // 通常の失敗時のメッセージ（失敗でなければ null）
  String? get errorMessage => switch (outcome) {
        AuthFailed(:final message) => message,
        _ => null,
      };

  // メール確認待ちで保留中かどうか
  bool get isEmailConfirmationPending => outcome is AuthEmailConfirmationPending;

  // 既存の状態を維持しつつ一部のフィールドのみを更新した新しい [AuthState] を生成する
  AuthState copyWith({
    Profile? user,
    bool? isLoading,
    AuthOutcome? outcome,
    bool clearOutcome = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      outcome: clearOutcome ? null : (outcome ?? this.outcome),
    );
  }
}

/// 認証フロー（新規登録・ログイン・ログアウト・プロフィール更新）の
/// ビジネスロジックおよび状態を管理する ViewModel
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
  }) {
    return _guardedCall(
      () => _authRepository.signUp(email: email, password: password),
    );
  }

  // メールアドレスとパスワードでサインインし、プロフィール状態を更新する
  Future<bool> signIn({
    required String email,
    required String password,
  }) {
    return _guardedCall(
      () => _authRepository.signIn(email: email, password: password),
    );
  }

  // ニックネーム・プロフィール画像を更新する
  Future<bool> completeProfile({
    required String nickname,
    File? avatarImage,
  }) {
    return _guardedCall(
      () => _authRepository.updateProfile(
        nickname: nickname,
        avatarImage: avatarImage,
      ),
    );
  }

  // サインアウトを実行し、保持している認証状態（プロフィール情報）を初期化する
  Future<void> signOut() async {
    await _authRepository.signOut();
    _state = const AuthState();
    notifyListeners();
  }

  // signUp/signIn/completeProfile に共通する、多重タップでの多重送信防止・
  // ローディング状態管理・エラーハンドリングをまとめた内部ヘルパー
  Future<bool> _guardedCall(Future<Profile> Function() action) async {
    // 実行中の多重タップで複数回リクエストが飛ぶのを防ぐ
    if (_state.isLoading) return false;

    _state = _state.copyWith(isLoading: true, clearOutcome: true);
    notifyListeners();

    try {
      final profile = await action();
      _state = _state.copyWith(user: profile, isLoading: false);
      notifyListeners();
      return true;
    } on EmailConfirmationPendingException {
      // 通常の失敗とは区別し、メール確認待ちであることを状態に反映する
      _state = _state.copyWith(
        isLoading: false,
        outcome: const AuthEmailConfirmationPending(),
      );
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('認証操作でエラーが発生しました: $e');
      _state = _state.copyWith(
        isLoading: false,
        outcome: AuthFailed(_toUserMessage(e)),
      );
      notifyListeners();
      return false;
    }
  }
}

// Supabaseの例外をそのまま表示すると内部実装が露出した読みにくい文字列になるため、
// ユーザー向けの日本語メッセージに変換する
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
  return 'エラーが発生しました。しばらくしてから再度お試しください';
}
