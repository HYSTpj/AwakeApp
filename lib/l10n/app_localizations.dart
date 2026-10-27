import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @profileRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get profileRetry;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileLogout;

  /// No description provided for @profileLogoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get profileLogoutConfirmation;

  /// No description provided for @profileCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileCancel;

  /// No description provided for @profileDeleteAccountConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm account deletion'**
  String get profileDeleteAccountConfirmationTitle;

  /// No description provided for @profileDeleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account will permanently erase your wake-up records and profile information.\n\nNote:\nIf you are the sole administrator of any groups, those groups and all events and participation records of their other members will also be deleted.\n\nAre you sure you want to delete your account?'**
  String get profileDeleteAccountConfirmation;

  /// No description provided for @profileDeleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get profileDeleteAccountConfirm;

  /// No description provided for @profileAccountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get profileAccountDeleted;

  /// No description provided for @profileAccountDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get profileAccountDelete;

  /// No description provided for @profileLogoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to log out'**
  String get profileLogoutFailed;

  /// No description provided for @profileAccountDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account'**
  String get profileAccountDeleteFailed;

  /// No description provided for @profileFetchFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get profileFetchFailed;

  /// No description provided for @profileNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get profileNotSet;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileHeading.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get profileHeading;

  /// No description provided for @profileDescription.
  ///
  /// In en, this message translates to:
  /// **'View your profile information'**
  String get profileDescription;

  /// No description provided for @profileUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'USER NAME'**
  String get profileUsernameLabel;

  /// No description provided for @profileChangeUsername.
  ///
  /// In en, this message translates to:
  /// **'Change username'**
  String get profileChangeUsername;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get profileChangePassword;

  /// No description provided for @profileNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get profileNotificationSettings;

  /// No description provided for @profileTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get profileTermsOfUse;

  /// No description provided for @profilePrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get profilePrivacyPolicy;

  /// No description provided for @profileAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get profileAnnouncements;

  /// No description provided for @profileLicenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get profileLicenses;

  /// No description provided for @profileContact.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get profileContact;

  /// No description provided for @editUsernameSuccess.
  ///
  /// In en, this message translates to:
  /// **'Username changed'**
  String get editUsernameSuccess;

  /// No description provided for @editUsernameFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to change username'**
  String get editUsernameFailure;

  /// No description provided for @editUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'NEW USER NAME'**
  String get editUsernameLabel;

  /// No description provided for @editUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get editUsernameHint;

  /// No description provided for @editUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get editUsernameRequired;

  /// No description provided for @editUsernameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Username must be 30 characters or fewer'**
  String get editUsernameTooLong;

  /// No description provided for @editUsernameSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get editUsernameSave;

  /// Message shown on profile setting pages that are not implemented yet.
  ///
  /// In en, this message translates to:
  /// **'{title} is currently under construction'**
  String profileSubPagePreparing(String title);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
