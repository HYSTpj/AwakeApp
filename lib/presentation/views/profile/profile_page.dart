import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../style/app_color.dart';
import '../../../widgets/return_button.dart';
import '../../viewmodels/profile_view_model.dart';
import '../login/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 祖先ツリーに ProfileViewModel がない場合はここで生成して注入
    return ChangeNotifierProvider(
      create: (context) {
        final authRepo =
            context.read<AuthRepository?>() ??
            SupabaseAuthRepository(Supabase.instance.client);
        final vm = ProfileViewModel(authRepo);
        vm.loadProfile();
        return vm;
      },
      child: const _ProfilePageContent(),
    );
  }
}

class _ProfilePageContent extends StatelessWidget {
  const _ProfilePageContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();
    final state = viewModel.state;
    final profile = state.profile;

    final userName = profile?.nickname ?? (state.isLoading ? '' : '未設定');
    final avatarUrl = profile?.avatarUrl;

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
                  image: (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(avatarUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (avatarUrl == null || avatarUrl.isEmpty)
                    ? const Icon(Icons.person, size: 64, color: Colors.grey)
                    : null,
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
                  border: Border.all(color: AppColors.border, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: state.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
              ),

              const SizedBox(height: 24),

              // アカウント設定
              _buildCardGroup([
                _buildListTile(
                  icon: Icons.person_outline,
                  title: 'ユーザー名変更',
                  onTap: () {},
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE2E8F0),
                ),
                _buildListTile(
                  icon: Icons.image_outlined,
                  title: 'プロフィール画像変更',
                  onTap: () {},
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE2E8F0),
                ),
                _buildListTile(
                  icon: Icons.lock_outline,
                  title: 'パスワード変更',
                  onTap: () {},
                ),
              ]),

              const SizedBox(height: 16),

              // 通知設定
              _buildCardGroup([
                _buildListTile(
                  icon: Icons.notifications_outlined,
                  title: '通知設定',
                  onTap: () {},
                ),
              ]),

              const SizedBox(height: 16),

              // アプリ情報
              _buildCardGroup([
                _buildListTile(title: '利用規約', onTap: () {}),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE2E8F0),
                ),
                _buildListTile(title: 'プライバシーポリシー', onTap: () {}),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE2E8F0),
                ),
                _buildListTile(title: 'お知らせ', onTap: () {}),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE2E8F0),
                ),
                _buildListTile(title: 'ライセンス', onTap: () {}),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE2E8F0),
                ),
                _buildListTile(title: 'お問い合わせ', onTap: () {}),
              ]),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () async {
                          // 誤タップ防止の確認ダイアログを表示
                          final shouldSignOut = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppColors.background,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: AppColors.border,
                                  width: 2,
                                ),
                              ),
                              title: const Text(
                                'ログアウト',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              content: const Text('ログアウトしてもよろしいですか？'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text(
                                    'キャンセル',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.orange,
                                    foregroundColor: Colors.black,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      side: const BorderSide(
                                        color: AppColors.border,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'ログアウト',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (shouldSignOut != true || !context.mounted) return;

                          // ログアウト実行
                          final success = await viewModel.signOut();
                          if (context.mounted && success) {
                            // 画面スタックをすべてクリアして LoginPage に完全遷移
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                              (route) => false,
                            );
                          }
                        },
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
                  child: const Text(
                    'ログアウト',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: state.isLoading ? null : () {},
                  style:
                      OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ).copyWith(
                        overlayColor: WidgetStatePropertyAll(
                          Colors.red.withValues(alpha: 0.1),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Column(children: children),
      ),
    );
  }

  static Widget _buildListTile({
    IconData? icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      splashColor: AppColors.orange.withValues(alpha: 0.2),
      hoverColor: AppColors.orange.withValues(alpha: 0.1),
      leading: icon != null ? Icon(icon, color: Colors.black) : null,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black54),
      dense: true,
      onTap: onTap,
    );
  }
}
