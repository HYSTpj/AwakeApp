import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../style/app_color.dart';
import '../../../widgets/return_button.dart';
import '../../viewmodels/auth_view_model.dart';
import '../login/login_page.dart';
import 'edit_username_page.dart';

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
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final vm = context.read<AuthViewModel>();
    await vm.loadCurrentProfile();

    if (!mounted) return;
    if (vm.state.profileErrorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.state.profileErrorMessage!),
          action: SnackBarAction(
            label: '再試行',
            textColor: AppColors.orange,
            onPressed: _loadProfile,
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
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 2),
        ),
        title: const Text(
          'ログアウト',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text('ログアウトしてもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.black54)
                .copyWith(
                  overlayColor: WidgetStatePropertyAll(
                    AppColors.orange.withValues(alpha: 0.2),
                  ),
                ),
            child: const Text('キャンセル'),
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
            child: const Text(
              'ログアウト',
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
          content: Text(viewModel.state.authErrorMessage ?? 'ログアウトに失敗しました'),
        ),
      );
    }
  }

  /// アカウント削除確認ダイアログの表示と画面遷移
  Future<void> _handleDeleteAccount(
    BuildContext context,
    AuthViewModel viewModel,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 2),
        ),
        title: const Text(
          'アカウント削除（準備中）',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.red,
          ),
        ),
        content: const Text(
          '現在アカウント削除機能は準備中です。\n実行するとログアウトしてログイン画面に戻ります。よろしいですか？',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.black54)
                .copyWith(
                  overlayColor: WidgetStatePropertyAll(
                    AppColors.orange.withValues(alpha: 0.2),
                  ),
                ),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: const BorderSide(color: AppColors.border, width: 1.5),
                  ),
                ).copyWith(
                  overlayColor: WidgetStatePropertyAll(
                    AppColors.orange.withValues(alpha: 0.3),
                  ),
                ),
            child: const Text(
              'ログアウトする',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;

    // TODO: 将来的にアカウント削除用API/Repository処理に差し替える
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
          content: Text(viewModel.state.authErrorMessage ?? 'ログアウトに失敗しました'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    final state = viewModel.state;
    final profile = state.user;
    final avatarUrl = profile?.avatarUrl;

    final String displayName;
    final Color nameColor;

    final isAnyLoading = state.isProfileLoading || state.isAuthActionLoading;

    if (state.isProfileLoading) {
      displayName = '';
      nameColor = Colors.black;
    } else if (state.profileErrorMessage != null) {
      displayName = '取得失敗';
      nameColor = Colors.red;
    } else if (profile != null && profile.nickname.isNotEmpty) {
      displayName = profile.nickname;
      nameColor = Colors.black;
    } else {
      displayName = '未設定';
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
            title: const Text(
              'プロフィール',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              const Text(
                'PROFILE',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'View your profile information',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),

              const SizedBox(height: 32),

              // プロフィール画像
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 3),
                ),
                child: ClipOval(
                  child: (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.person,
                                size: 64,
                                color: Colors.grey,
                              ),
                        )
                      : const Icon(Icons.person, size: 64, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 32),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'USER NAME',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ユーザー名表示
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
                              onPressed: _loadProfile,
                            ),
                        ],
                      ),
              ),

              const SizedBox(height: 24),

              // アカウント設定
              _buildCardGroup([
                _buildListTile(
                  icon: Icons.person_outline,
                  title: 'ユーザー名変更',
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
                  icon: Icons.image_outlined,
                  title: 'プロフィール画像変更',
                  onTap: () => _navigateToSubPage(context, 'プロフィール画像変更'),
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE2E8F0),
                ),
                _buildListTile(
                  icon: Icons.lock_outline,
                  title: 'パスワード変更',
                  onTap: () => _navigateToSubPage(context, 'パスワード変更'),
                ),
              ]),

              const SizedBox(height: 16),

              // 通知設定
              _buildCardGroup([
                _buildListTile(
                  icon: Icons.notifications_outlined,
                  title: '通知設定',
                  onTap: () => _navigateToSubPage(context, '通知設定'),
                ),
              ]),

              const SizedBox(height: 16),

              // アプリ情報
              _buildCardGroup([
                _buildListTile(
                  title: '利用規約',
                  onTap: () => _navigateToSubPage(context, '利用規約'),
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE2E8F0),
                ),
                _buildListTile(
                  title: 'プライバシーポリシー',
                  onTap: () => _navigateToSubPage(context, 'プライバシーポリシー'),
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE2E8F0),
                ),
                _buildListTile(
                  title: 'お知らせ',
                  onTap: () => _navigateToSubPage(context, 'お知らせ'),
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE2E8F0),
                ),
                _buildListTile(
                  title: 'ライセンス',
                  onTap: () => _navigateToSubPage(context, 'ライセンス'),
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE2E8F0),
                ),
                _buildListTile(
                  title: 'お問い合わせ',
                  onTap: () => _navigateToSubPage(context, 'お問い合わせ'),
                ),
              ]),

              const SizedBox(height: 28),

              // ログアウトボタン
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
                      : const Text(
                          'ログアウト',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // アカウント削除ボタン
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: isAnyLoading
                      ? null
                      : () => _handleDeleteAccount(context, viewModel),
                  style:
                      OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ).copyWith(
                        overlayColor: WidgetStatePropertyAll(
                          AppColors.orange.withValues(alpha: 0.2),
                        ),
                      ),
                  child: const Text(
                    'アカウント削除',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
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
              '$title は現在準備中です',
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
