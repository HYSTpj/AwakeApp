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
      'For those who are late, a mark of shame.\nFor those who make it on time, a badge of honor.';

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

  @override
  String get invitationCode => 'Invitation Code';

  @override
  String get enterInvitationCode => 'Please enter your invitation code';

  @override
  String get pleaseLogIn => 'Please log in';

  @override
  String get joinedGroup => 'Joined the group';

  @override
  String get errorOccurred => 'An error has occurred';

  @override
  String get add => 'ADD';

  @override
  String get createGroup => 'Create group';

  @override
  String get addGroup => 'Add group';

  @override
  String get deleteGroup => 'Delete group';

  @override
  String get enterGroupName => 'Please enter group name';

  @override
  String get createdNewGroup => 'Created a new group';

  @override
  String get enterNewGroupName => 'Enter new group name';

  @override
  String get create => 'Create';

  @override
  String get confirmation => 'Confirmation';

  @override
  String get leaveGroupConfirmation =>
      'Are you sure you want to leave this group?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Leave';

  @override
  String get leftGroup => 'You have left the group';

  @override
  String get enterInvitationCodeToLeave => 'Enter invitation code to leave';

  @override
  String get deleteGroupAction => 'Leave';

  @override
  String get groupName => 'GROUP NAME';

  @override
  String get copiedInvitationCode => 'Copied the invitation code';

  @override
  String get createOrAddOrDelete => 'CREATE OR ADD OR DELETE';

  @override
  String get failedToGetRole => 'Failed to retrieve role information';

  @override
  String get selectGroup => 'Select group';
}
