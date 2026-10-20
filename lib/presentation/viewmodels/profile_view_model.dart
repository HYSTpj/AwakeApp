import 'package:flutter/foundation.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../models/profile.dart';

/// プロフィール画面の状態
class ProfileState {
  final Profile? profile;
  final bool isLoading;
  final String? errorMessage;

  const ProfileState({this.profile, this.isLoading = false, this.errorMessage});

  ProfileState copyWith({
    Profile? profile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// プロフィール画面のビジネスロジック・状態管理
class ProfileViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  ProfileState _state = const ProfileState(isLoading: true);
  bool _isDisposed = false;

  ProfileViewModel(this._authRepository);

  ProfileState get state => _state;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  /// プロフィール情報の取得
  Future<void> loadProfile() async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final profile = await _authRepository.getCurrentProfile();
      _state = _state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'プロフィールの取得に失敗しました: $e',
      );
    }
    notifyListeners();
  }

  /// ログアウト処理
  Future<bool> signOut() async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      await _authRepository.signOut();
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'ログアウトに失敗しました: $e',
      );
      notifyListeners();
      return false;
    }
  }

  /// エラーメッセージのクリア
  void clearError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }
}
