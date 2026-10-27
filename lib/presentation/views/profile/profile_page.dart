import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../style/app_color.dart';
import '../../../widgets/return_button.dart';
import '../../viewmodels/auth_view_model.dart';
import '../login/login_page.dart';
import 'edit_username_page.dart';
import 'components/avatar_edit_view.dart';
import 'edit_password_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 画面が破棄されていないか確認してから実行
      if (!mounted) return;
      // キャッシュが存在するか取得中なら何もしない（forceRefresh: false）
      _loadProfile(forceRefresh: false);
    });
  }

  Future<void> _loadProfile({bool forceRefresh = false}) async {
    final vm = context.read<AuthViewModel>();
    final l10n = AppLocalizations.of(context)!;
    await vm.loadCurrentProfile(forceRefresh: forceRefresh);

    if (!mounted) return;
    if (vm.state.profileErrorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.state.profileErrorMessage!),
          action: SnackBarAction(
            label: l10n.profileRetry,
            textColor: AppColors.orange,
            onPressed: () => _loadProfile(forceRefresh: true),
          ),
        ),
      );
    }
  }

  // 本番画面が未実装の項目で使用するプレースホルダー遷移
  void _navigateToSubPage(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _ProfileSubPage(title: title)),
    );
  }

  /// ログアウト確認ダイアログの表示と実行
  Future<void> _handleSignOut(
    BuildContext context,
    AuthViewModel viewModel,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 2),
        ),
        title: Text(
          l10n.profileLogout,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Text(l10n.profileLogoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.black54)
                .copyWith(
                  overlayColor: WidgetStatePropertyAll(
                    AppColors.orange.withValues(alpha: 0.2),
                  ),
                ),
            child: Text(l10n.profileCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: const BorderSide(color: AppColors.border, width: 1.5),
                  ),
                ).copyWith(
                  overlayColor: WidgetStatePropertyAll(
                    Colors.black.withValues(alpha: 0.1),
                  ),
                ),
            child: Text(
              l10n.profileLogout,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (shouldSignOut != true || !context.mounted) return;

    final success = await viewModel.signOut();
    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.state.authErrorMessage ?? l10n.profileLogoutFailed,
          ),
        ),
      );
    }
  }

  /// アカウント削除確認ダイアログの表示と実行
  Future<void> _handleDeleteAccount(
    BuildContext context,
    AuthViewModel viewModel,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 2),
        ),
        title: Text(
          l10n.profileDeleteAccountConfirmationTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.red,
          ),
        ),
        content: Text(
          l10n.profileDeleteAccountConfirmation,
          style: TextStyle(height: 1.5, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(foregroundColor: Colors.black54),
            child: Text(l10n.profileCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: const BorderSide(color: AppColors.border, width: 1.5),
              ),
            ),
            child: Text(
              l10n.profileDeleteAccountConfirm,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;

    final success = await viewModel.deleteAccount();
    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileAccountDeleted),
          duration: Duration(seconds: 4),
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.state.authErrorMessage ?? l10n.profileAccountDeleteFailed,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.watch<AuthViewModel>();
    final state = viewModel.state;
    final profile = state.user;

    final String displayName;
    final Color nameColor;

    final isAnyLoading = state.isProfileLoading || state.isAuthActionLoading;

    if (state.isProfileLoading) {
      displayName = '';
      nameColor = Colors.black;
    } else if (state.profileErrorMessage != null) {
      displayName = l10n.profileFetchFailed;
      nameColor = Colors.red;
    } else if (profile != null && profile.nickname.isNotEmpty) {
      displayName = profile.nickname;
      nameColor = Colors.black;
    } else {
      displayName = l10n.profileNotSet;
      nameColor = Colors.black54;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 4.0),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 4),
            ),
          ),
          child: AppBar(
            backgroundColor: AppColors.orange,
            foregroundColor: Colors.black,
            elevation: 0,
            centerTitle: true,
            title: Text(
              l10n.profileTitle,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leadingWidth: 56,
            leading: const Padding(
              padding: EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
              child: ReturnButton(),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.orange,
        onRefresh: () => _loadProfile(forceRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 32),

                Text(
                  l10n.profileHeading,
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  l10n.profileDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),

                const SizedBox(height: 32),

                const AvatarEditView(size: 110),

                const SizedBox(height: 32),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.profileUsernameLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  height: 48,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: state.profileErrorMessage != null
                          ? Colors.red.withValues(alpha: 0.7)
                          : AppColors.border,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: state.isProfileLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: nameColor,
                                ),
                              ),
                            ),
                            if (state.profileErrorMessage != null)
                              IconButton(
                                icon: const Icon(
                                  Icons.refresh,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () =>
                                    _loadProfile(forceRefresh: true),
                              ),
                          ],
                        ),
                ),

                const SizedBox(height: 24),

                _buildCardGroup([
                  _buildListTile(
                    icon: Icons.person_outline,
                    title: l10n.profileChangeUsername,
                    onTap: isAnyLoading
                        ? () {}
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditUsernamePage(),
                            ),
                          ),
                    enabled: !isAnyLoading,
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE2E8F0),
                  ),
                  _buildListTile(
                    icon: Icons.lock_outline,
                    title: l10n.profileChangePassword,
                    onTap: isAnyLoading
                        ? () {}
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditPasswordPage(),
                            ),
                          ),
                    enabled: !isAnyLoading,
                  ),
                ]),

                const SizedBox(height: 16),

                _buildCardGroup([
                  _buildListTile(
                    icon: Icons.notifications_outlined,
                    title: l10n.profileNotificationSettings,
                    onTap: () => _navigateToSubPage(
                      context,
                      l10n.profileNotificationSettings,
                    ),
                  ),
                ]),

                const SizedBox(height: 16),

                _buildCardGroup([
                  _buildListTile(
                    title: l10n.profileTermsOfUse,
                    onTap: () =>
                        _navigateToSubPage(context, l10n.profileTermsOfUse),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE2E8F0),
                  ),
                  _buildListTile(
                    title: l10n.profilePrivacyPolicy,
                    onTap: () =>
                        _navigateToSubPage(context, l10n.profilePrivacyPolicy),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE2E8F0),
                  ),
                  _buildListTile(
                    title: l10n.profileAnnouncements,
                    onTap: () =>
                        _navigateToSubPage(context, l10n.profileAnnouncements),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE2E8F0),
                  ),
                  _buildListTile(
                    title: l10n.profileLicenses,
                    onTap: () =>
                        _navigateToSubPage(context, l10n.profileLicenses),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE2E8F0),
                  ),
                  _buildListTile(
                    title: l10n.profileContact,
                    onTap: () =>
                        _navigateToSubPage(context, l10n.profileContact),
                  ),
                ]),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isAnyLoading
                        ? null
                        : () => _handleSignOut(context, viewModel),
                    style:
                        ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          side: const BorderSide(
                            color: AppColors.border,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ).copyWith(
                          overlayColor: WidgetStatePropertyAll(
                            AppColors.orange.withValues(alpha: 0.2),
                          ),
                        ),
                    child: state.isAuthActionLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            l10n.profileLogout,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: isAnyLoading
                        ? null
                        : () => _handleDeleteAccount(context, viewModel),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: state.isAuthActionLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.red,
                            ),
                          )
                        : Text(
                            l10n.profileAccountDelete,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }

  static Widget _buildListTile({
    IconData? icon,
    required String title,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      splashColor: AppColors.orange.withValues(alpha: 0.35),
      highlightColor: AppColors.orange.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: enabled ? Colors.black : Colors.black26,
                size: 22,
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: enabled ? Colors.black : Colors.black26,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: enabled ? Colors.black54 : Colors.black26,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// 各設定項目の簡易プレースホルダー画面
class _ProfileSubPage extends StatelessWidget {
  final String title;

  const _ProfileSubPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 4.0),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 4),
            ),
          ),
          child: AppBar(
            backgroundColor: AppColors.orange,
            foregroundColor: Colors.black,
            elevation: 0,
            centerTitle: true,
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            leadingWidth: 56,
            leading: const Padding(
              padding: EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
              child: ReturnButton(),
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: const Icon(
                Icons.construction,
                size: 48,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.profileSubPagePreparing(title),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
