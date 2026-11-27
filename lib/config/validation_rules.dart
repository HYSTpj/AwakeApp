import 'validation_constants.dart';

abstract final class ValidationRules {
  static String? nickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ユーザー名を入力してください';
    }
    if (value.trim().length > ValidationConstants.nicknameMaxLength) {
      return 'ユーザー名は${ValidationConstants.nicknameMaxLength}文字以内で入力してください';
    }
    return null;
  }

  static String? currentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '現在のパスワードを入力してください';
    }
    return null;
  }

  static String? newPassword(String? value, {String? currentPassword}) {
    if (value == null || value.isEmpty) {
      return '新しいパスワードを入力してください';
    }
    if (value.length < ValidationConstants.passwordMinLength) {
      return '新しいパスワードは${ValidationConstants.passwordMinLength}文字以上で入力してください';
    }
    if (currentPassword != null && value == currentPassword) {
      return '新しいパスワードは現在のパスワードと異なるものを設定してください';
    }
    return null;
  }

  static String? passwordConfirmation(String? value, String newPassword) {
    if (value == null || value.isEmpty) {
      return '確認用パスワードを入力してください';
    }
    if (value != newPassword) {
      return '確認用パスワードが一致しません';
    }
    return null;
  }
}
