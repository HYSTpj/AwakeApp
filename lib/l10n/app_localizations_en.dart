// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginRequiredFields =>
      'Please enter your email address and password';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get userNameRequired => 'Please enter a username';

  @override
  String get notLoggedIn => 'You are not logged in';

  @override
  String get profileSaveFailed => 'Failed to save profile';

  @override
  String get createProfile => 'CREATE PROFILE';

  @override
  String get createProfileDescription =>
      'Show the world who you are. Customize your look.';

  @override
  String get userName => 'USER NAME';

  @override
  String get enterUserName => 'Enter your username';

  @override
  String get profilePicture => 'PROFILE PICTURE';

  @override
  String get uploadImage => 'UPLOAD IMAGE';

  @override
  String get createAccount => 'CREATE ACCOUNT';

  @override
  String get returnToLogin => 'RETURN TO LOGIN';

  @override
  String get signIn => 'SIGN IN';

  @override
  String get loginCatchCopy =>
      'We give medals to the timely and\nshame to the tardy';

  @override
  String get emailAddress => 'EMAIL ADDRESS';

  @override
  String get password => 'PASSWORD';

  @override
  String get login => 'LOGIN';

  @override
  String get signupTitle => 'CREATE ACCOUNT';

  @override
  String get signupCatchCopy => 'Welcome to AWAKE.\nLet\'s get started.';
}
