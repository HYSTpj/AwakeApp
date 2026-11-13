import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_mode.dart';

/// Figma の「確定版ホーム画面」ヘッダーに対応する共通ヘッダー。
///
/// [mode] によって ModeSwitch（管理者/メンバー切替）の強調表示が変わる。
/// ナビゲーション（遷移）は別フェーズで実装するため、タップ時の挙動は
/// コールバックとして呼び出し元に委譲する。
class CommonHeader extends StatelessWidget implements PreferredSizeWidget {
  const CommonHeader({
    super.key,
    required this.mode,
    this.onModeChanged,
    this.onProfileTap,
  });

  final AppMode mode;
  final ValueChanged<AppMode>? onModeChanged;
  final VoidCallback? onProfileTap;

  static const Color _background = Color(0xFFEC5B13);
  static const Color _borderColor = Colors.black;

  static const Key memberSwitchKey = Key('common_header_member_switch');
  static const Key adminSwitchKey = Key('common_header_admin_switch');
  static const Key profileButtonKey = Key('common_header_profile_button');

  @override
  Size get preferredSize => const Size.fromHeight(75);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 75,
      padding: const EdgeInsets.only(top: 24, right: 10, bottom: 16),
      decoration: const BoxDecoration(
        color: _background,
        border: Border(bottom: BorderSide(color: _borderColor, width: 3)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          const _AppNameLabel(),
          Positioned(
            left: 24,
            top: -10,
            child: _ModeSwitch(mode: mode, onChanged: onModeChanged),
          ),
          Positioned(
            right: 0,
            child: _ProfileSettingButton(
              key: profileButtonKey,
              onTap: onProfileTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppNameLabel extends StatelessWidget {
  const _AppNameLabel();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'AWAKE',
      style: TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 16,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.4,
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.mode, this.onChanged});

  final AppMode mode;
  final ValueChanged<AppMode>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF6B7280),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeSwitchButton(
            key: CommonHeader.memberSwitchKey,
            active: mode == AppMode.member,
            activeColor: const Color(0xFFFF7A1A),
            assetName: 'assets/icons/common_layout/icon_sunrise.svg',
            iconSize: 24,
            onTap: () => onChanged?.call(AppMode.member),
          ),
          const SizedBox(width: 12),
          _ModeSwitchButton(
            key: CommonHeader.adminSwitchKey,
            active: mode == AppMode.admin,
            activeColor: const Color(0xFF2563EB),
            assetName: 'assets/icons/common_layout/icon_glasses.svg',
            iconSize: 24,
            iconWidth: 26,
            onTap: () => onChanged?.call(AppMode.admin),
          ),
        ],
      ),
    );
  }
}

class _ModeSwitchButton extends StatelessWidget {
  const _ModeSwitchButton({
    super.key,
    required this.active,
    required this.activeColor,
    required this.assetName,
    required this.iconSize,
    this.iconWidth,
    this.onTap,
  });

  final bool active;
  final Color activeColor;
  final String assetName;
  final double iconSize;
  final double? iconWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: active ? activeColor : const Color(0xFFD1D5DA),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: active
              ? [
                  BoxShadow(color: activeColor.withValues(alpha: 0.85), blurRadius: 14),
                  const BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(3),
        child: Center(
          child: Opacity(
            opacity: active ? 1 : 0.4,
            child: SvgPicture.asset(
              assetName,
              width: iconWidth ?? iconSize,
              height: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileSettingButton extends StatelessWidget {
  const _ProfileSettingButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final currentUser = client.auth.currentUser;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        child: Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.fromBorderSide(BorderSide(color: Colors.black, width: 3)),
            boxShadow: [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
          ),
          child: ClipOval(
            child: currentUser == null
                ? _placeholderAvatar()
                : FutureBuilder<Map<String, dynamic>?>(
                    future: client
                        .from('profiles')
                        .select('avatar_url')
                        .eq('id', currentUser.id)
                        .maybeSingle(),
                    builder: (context, snapshot) {
                      final avatarUrl =
                          snapshot.data?['avatar_url'] as String?;
                      if (avatarUrl == null || avatarUrl.isEmpty) {
                        return _placeholderAvatar();
                      }
                      return Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _placeholderAvatar(),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _placeholderAvatar() {
    return Image.asset(
      'assets/icons/common_layout/profile_placeholder.png',
      fit: BoxFit.cover,
    );
  }
}
