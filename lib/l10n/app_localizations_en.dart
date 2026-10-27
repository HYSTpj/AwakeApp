// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get profileRetry => 'Retry';

  @override
  String get profileLogout => 'Log out';

  @override
  String get profileLogoutConfirmation => 'Are you sure you want to log out?';

  @override
  String get profileCancel => 'Cancel';

  @override
  String get profileDeleteAccountConfirmationTitle =>
      'Confirm account deletion';

  @override
  String get profileDeleteAccountConfirmation =>
      'Deleting your account will permanently erase your wake-up records and profile information.\n\nNote:\nIf you are the sole administrator of any groups, those groups and all events and participation records of their other members will also be deleted.\n\nAre you sure you want to delete your account?';

  @override
  String get profileDeleteAccountConfirm => 'Delete permanently';

  @override
  String get profileAccountDeleted => 'Account deleted';

  @override
  String get profileAccountDelete => 'Delete account';

  @override
  String get profileLogoutFailed => 'Failed to log out';

  @override
  String get profileAccountDeleteFailed => 'Failed to delete account';

  @override
  String get profileFetchFailed => 'Failed to load';

  @override
  String get profileNotSet => 'Not set';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileHeading => 'PROFILE';

  @override
  String get profileDescription => 'View your profile information';

  @override
  String get profileUsernameLabel => 'USER NAME';

  @override
  String get profileChangeUsername => 'Change username';

  @override
  String get profileChangePassword => 'Change password';

  @override
  String get profileNotificationSettings => 'Notification settings';

  @override
  String get profileTermsOfUse => 'Terms of use';

  @override
  String get profilePrivacyPolicy => 'Privacy policy';

  @override
  String get profileAnnouncements => 'Announcements';

  @override
  String get profileLicenses => 'Licenses';

  @override
  String get profileContact => 'Contact us';

  @override
  String profileSubPagePreparing(String title) {
    return '$title is currently under construction';
  }
}
