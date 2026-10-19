// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get loginRequiredFields => 'メールアドレスとパスワードを入力してください';

  @override
  String get loginFailed => 'ログインに失敗しました';

  @override
  String get userNameRequired => 'ユーザー名を入力してください';

  @override
  String get notLoggedIn => 'ログインしていません';

  @override
  String get profileSaveFailed => 'プロファイルの保存に失敗しました';

  @override
  String get createProfile => 'プロフィール作成';

  @override
  String get createProfileDescription => 'プロフィール画像とユーザー名を設定します';

  @override
  String get userName => 'ユーザー名';

  @override
  String get enterUserName => 'ユーザー名を入力';

  @override
  String get profilePicture => 'プロフィール画像';

  @override
  String get uploadImage => '画像をアップロード';

  @override
  String get createAccount => 'アカウント作成';

  @override
  String get returnToLogin => 'ログイン画面へ戻る';

  @override
  String get signIn => 'ログイン';

  @override
  String get loginCatchCopy => '遅刻するものには汚名を。\n間に合うものには称号を。';

  @override
  String get emailAddress => 'メールアドレス';

  @override
  String get password => 'パスワード';

  @override
  String get login => 'ログイン';

  @override
  String get signupTitle => 'アカウント作成';

  @override
  String get signupCatchCopy => '時間を制する仲間たちへようこそ。\nAWAKEを始めましょう！';
}
