// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get profileRetry => '再試行';

  @override
  String get profileLogout => 'ログアウト';

  @override
  String get profileLogoutConfirmation => 'ログアウトしてもよろしいですか？';

  @override
  String get profileCancel => 'キャンセル';

  @override
  String get profileDeleteAccountConfirmationTitle => 'アカウント削除の確認';

  @override
  String get profileDeleteAccountConfirmation =>
      'アカウントを削除すると、これまでの起床記録やプロフィール情報はすべて消去され、復元できません。\n\n【ご注意】\nあなたが「唯一の管理者」となっているグループが存在する場合、そのグループおよび他のメンバーのイベント・参加記録もすべて一緒に削除されます。\n\n本当にアカウントを削除しますか？';

  @override
  String get profileDeleteAccountConfirm => '完全に削除する';

  @override
  String get profileAccountDeleted => 'アカウントを削除しました';

  @override
  String get profileAccountDelete => 'アカウント削除';

  @override
  String get profileLogoutFailed => 'ログアウトに失敗しました';

  @override
  String get profileAccountDeleteFailed => 'アカウントの削除に失敗しました';

  @override
  String get profileFetchFailed => '取得失敗';

  @override
  String get profileNotSet => '未設定';

  @override
  String get profileTitle => 'プロフィール';

  @override
  String get profileHeading => 'プロフィール';

  @override
  String get profileDescription => 'プロフィール情報を確認できます';

  @override
  String get profileUsernameLabel => 'ユーザー名';

  @override
  String get profileChangeUsername => 'ユーザー名変更';

  @override
  String get profileChangePassword => 'パスワード変更';

  @override
  String get profileNotificationSettings => '通知設定';

  @override
  String get profileTermsOfUse => '利用規約';

  @override
  String get profilePrivacyPolicy => 'プライバシーポリシー';

  @override
  String get profileAnnouncements => 'お知らせ';

  @override
  String get profileLicenses => 'ライセンス';

  @override
  String get profileContact => 'お問い合わせ';

  @override
  String profileSubPagePreparing(String title) {
    return '$title は現在準備中です';
  }
}
