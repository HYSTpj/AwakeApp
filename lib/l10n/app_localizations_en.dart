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
  String get editUsernameSuccess => 'Username changed';

  @override
  String get editUsernameFailure => 'Failed to change username';

  @override
  String get editUsernameLabel => 'NEW USER NAME';

  @override
  String get editUsernameHint => 'Enter username';

  @override
  String get editUsernameRequired => 'Please enter a username';

  @override
  String get editUsernameTooLong => 'Username must be 30 characters or fewer';

  @override
  String get editUsernameSave => 'Save changes';

  @override
  String get editPasswordSuccess => 'Password changed';

  @override
  String get editPasswordFailure => 'Failed to change password';

  @override
  String get editPasswordDescription =>
      'For security, enter your current password and a new password.';

  @override
  String get editPasswordCurrentLabel => 'CURRENT PASSWORD';

  @override
  String get editPasswordCurrentHint => 'Current password';

  @override
  String get editPasswordCurrentRequired =>
      'Please enter your current password';

  @override
  String get editPasswordNewLabel => 'NEW PASSWORD';

  @override
  String get editPasswordNewHint => 'New password (6 or more characters)';

  @override
  String get editPasswordNewRequired => 'Please enter a new password';

  @override
  String get editPasswordTooShort => 'Password must be at least 6 characters';

  @override
  String get editPasswordDifferentRequired =>
      'Please enter a password different from your current password';

  @override
  String get editPasswordConfirmLabel => 'CONFIRM PASSWORD';

  @override
  String get editPasswordConfirmHint => 'Re-enter new password';

  @override
  String get editPasswordConfirmRequired =>
      'Please enter the password for confirmation';

  @override
  String get editPasswordMismatch => 'Passwords do not match';

  @override
  String get editPasswordSubmit => 'Change password';

  @override
  String get avatarPickFailure => 'Failed to select an image';

  @override
  String get avatarPermissionHint => 'Please check your permissions';

  @override
  String get avatarUnexpectedFailure =>
      'An unexpected error occurred while getting the image';

  @override
  String get avatarUpdateSuccess => 'Profile image changed';

  @override
  String get avatarUpdateFailure => 'Failed to update the image';

  @override
  String profileSubPagePreparing(String title) {
    return '$title is currently under construction';
  }
}
