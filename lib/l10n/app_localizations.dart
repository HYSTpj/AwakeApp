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

  /// No description provided for @loginRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address and password'**
  String get loginRequiredFields;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @userNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get userNameRequired;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You are not logged in'**
  String get notLoggedIn;

  /// No description provided for @profileSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile'**
  String get profileSaveFailed;

  /// No description provided for @createProfile.
  ///
  /// In en, this message translates to:
  /// **'CREATE PROFILE'**
  String get createProfile;

  /// No description provided for @createProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Show the world who you are. Customize your look.'**
  String get createProfileDescription;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'USER NAME'**
  String get userName;

  /// No description provided for @enterUserName.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterUserName;

  /// No description provided for @profilePicture.
  ///
  /// In en, this message translates to:
  /// **'PROFILE PICTURE'**
  String get profilePicture;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'UPLOAD IMAGE'**
  String get uploadImage;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get createAccount;

  /// No description provided for @returnToLogin.
  ///
  /// In en, this message translates to:
  /// **'RETURN TO LOGIN'**
  String get returnToLogin;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get signIn;

  /// No description provided for @loginCatchCopy.
  ///
  /// In en, this message translates to:
  /// **'We give medals to the timely and\nshame to the tardy'**
  String get loginCatchCopy;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'EMAIL ADDRESS'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get login;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get signupTitle;

  /// No description provided for @signupCatchCopy.
  ///
  /// In en, this message translates to:
  /// **'Join us among the elite who master time.\nLet\'s AWAKE!'**
  String get signupCatchCopy;

  /// No description provided for @invitationCode.
  ///
  /// In en, this message translates to:
  /// **'Invitation Code'**
  String get invitationCode;

  /// No description provided for @enterInvitationCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter your invitation code'**
  String get enterInvitationCode;

  /// No description provided for @pleaseLogIn.
  ///
  /// In en, this message translates to:
  /// **'Please log in'**
  String get pleaseLogIn;

  /// No description provided for @joinedGroup.
  ///
  /// In en, this message translates to:
  /// **'Joined the group'**
  String get joinedGroup;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error has occurred'**
  String get errorOccurred;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'ADD'**
  String get add;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get createGroup;

  /// No description provided for @addGroup.
  ///
  /// In en, this message translates to:
  /// **'Add group'**
  String get addGroup;

  /// No description provided for @deleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Delete group'**
  String get deleteGroup;

  /// No description provided for @enterGroupName.
  ///
  /// In en, this message translates to:
  /// **'Please enter group name'**
  String get enterGroupName;

  /// No description provided for @createdNewGroup.
  ///
  /// In en, this message translates to:
  /// **'Created a new group'**
  String get createdNewGroup;

  /// No description provided for @enterNewGroupName.
  ///
  /// In en, this message translates to:
  /// **'Enter new group name'**
  String get enterNewGroupName;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @leaveGroupConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you really going to leave this group?'**
  String get leaveGroupConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get delete;

  /// No description provided for @leftGroup.
  ///
  /// In en, this message translates to:
  /// **'You have left the group'**
  String get leftGroup;

  /// No description provided for @enterInvitationCodeToLeave.
  ///
  /// In en, this message translates to:
  /// **'Enter invitation code to leave'**
  String get enterInvitationCodeToLeave;

  /// No description provided for @deleteGroupAction.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get deleteGroupAction;

  /// No description provided for @youHaveLeftTheGroup.
  ///
  /// In en, this message translates to:
  /// **'You have left the group'**
  String get youHaveLeftTheGroup;

  /// No description provided for @areYouSureYouWantToLeaveThisGroup.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave this group?'**
  String get areYouSureYouWantToLeaveThisGroup;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'GROUP NAME'**
  String get groupName;

  /// No description provided for @copiedInvitationCode.
  ///
  /// In en, this message translates to:
  /// **'Copied the invitation code'**
  String get copiedInvitationCode;

  /// No description provided for @createOrAddOrDelete.
  ///
  /// In en, this message translates to:
  /// **'CREATE OR ADD OR DELETE'**
  String get createOrAddOrDelete;

  /// No description provided for @failedToGetRole.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve role information'**
  String get failedToGetRole;

  /// No description provided for @selectGroup.
  ///
  /// In en, this message translates to:
  /// **'Select group'**
  String get selectGroup;
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
