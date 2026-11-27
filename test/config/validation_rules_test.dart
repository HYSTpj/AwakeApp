import 'package:flutter_application_1/config/validation_constants.dart';
import 'package:flutter_application_1/config/validation_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ValidationRules.nickname', () {
    test('空白と最大文字数を共通ルールで検証する', () {
      expect(ValidationRules.nickname('  '), 'ユーザー名を入力してください');
      expect(
        ValidationRules.nickname('a' * ValidationConstants.nicknameMaxLength),
        isNull,
      );
      expect(
        ValidationRules.nickname(
          'a' * (ValidationConstants.nicknameMaxLength + 1),
        ),
        'ユーザー名は${ValidationConstants.nicknameMaxLength}文字以内で入力してください',
      );
    });
  });

  group('ValidationRules password checks', () {
    test('新しいパスワードの長さと現在値を同じ文言で検証する', () {
      expect(
        ValidationRules.newPassword('abcde', currentPassword: 'current'),
        '新しいパスワードは${ValidationConstants.passwordMinLength}文字以上で入力してください',
      );
      expect(
        ValidationRules.newPassword('current', currentPassword: 'current'),
        '新しいパスワードは現在のパスワードと異なるものを設定してください',
      );
      expect(
        ValidationRules.newPassword('newPassword', currentPassword: 'current'),
        isNull,
      );
    });

    test('確認用パスワードの空欄と不一致を区別する', () {
      expect(
        ValidationRules.passwordConfirmation('', 'newPassword'),
        '確認用パスワードを入力してください',
      );
      expect(
        ValidationRules.passwordConfirmation('otherPassword', 'newPassword'),
        '確認用パスワードが一致しません',
      );
      expect(
        ValidationRules.passwordConfirmation('newPassword', 'newPassword'),
        isNull,
      );
    });
  });
}
