import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'app_mode.dart';

/// Figma の「確定版ホーム画面」フッターに対応する共通フッター（ボトムナビ）。
///
/// [mode] によって3番目のアイコン（管理者: 一覧 / メンバー: ステータス）が切り替わる。
/// ナビゲーション（遷移）は別フェーズで実装するため、タップ時の挙動は
/// コールバックとして呼び出し元に委譲する。
class CommonFooter extends StatelessWidget {
  const CommonFooter({
    super.key,
    required this.mode,
    this.onHomeTap,
    this.onEventCreateTap,
    this.onForumTap,
    this.onRankingTap,
    this.onPlusTap,
  });

  final AppMode mode;
  final VoidCallback? onHomeTap;
  final VoidCallback? onEventCreateTap;
  final VoidCallback? onForumTap;
  final VoidCallback? onRankingTap;
  final VoidCallback? onPlusTap;

  static const Color _navBackground = Color(0xFFEC5B13);
  static const Color _navBorderColor = Color(0xFF334155);

  static const Key homeButtonKey = Key('common_footer_home_button');
  static const Key eventCreateButtonKey = Key(
    'common_footer_event_create_button',
  );
  static const Key forumButtonKey = Key('common_footer_forum_button');
  static const Key rankingButtonKey = Key('common_footer_ranking_button');
  static const Key plusButtonKey = Key('common_footer_plus_button');

  @override
  Widget build(BuildContext context) {
    final forumAsset = mode == AppMode.admin
        ? 'assets/icons/common_layout/icon_forum_admin.svg'
        : 'assets/icons/common_layout/icon_forum_member.svg';

    // bottomNavigationBar はホームインジケーター分の余白をScaffoldが
    // 自動で確保してくれないため、自前でSafeAreaに包んで被らないようにする。
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 92,
              constraints: const BoxConstraints(maxWidth: 384),
              width: 302,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: _navBackground,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: _navBorderColor, width: 4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _FooterIconButton(
                    key: CommonFooter.homeButtonKey,
                    assetName: 'assets/icons/common_layout/icon_home.svg',
                    boxSize: 52,
                    iconWidth: 25,
                    iconHeight: 22,
                    onTap: onHomeTap,
                  ),
                  _FooterIconButton(
                    key: CommonFooter.eventCreateButtonKey,
                    assetName:
                        'assets/icons/common_layout/icon_event_create.svg',
                    boxSize: 52,
                    iconWidth: 38,
                    iconHeight: 38,
                    onTap: onEventCreateTap,
                  ),
                  _FooterIconButton(
                    key: CommonFooter.forumButtonKey,
                    assetName: forumAsset,
                    boxSize: 52,
                    iconWidth: 23,
                    iconHeight: 23,
                    onTap: onForumTap,
                  ),
                  _FooterIconButton(
                    key: CommonFooter.rankingButtonKey,
                    assetName: 'assets/icons/common_layout/icon_crown.svg',
                    boxSize: 52,
                    iconWidth: 28,
                    iconHeight: 28,
                    onTap: onRankingTap,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _FooterIconButton(
              key: CommonFooter.plusButtonKey,
              assetName: 'assets/icons/common_layout/icon_plus.svg',
              backgroundColor: const Color(0xFF4ADE80),
              boxSize: 60,
              iconWidth: 35,
              iconHeight: 35,
              onTap: onPlusTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterIconButton extends StatelessWidget {
  const _FooterIconButton({
    super.key,
    required this.assetName,
    this.backgroundColor = Colors.white,
    this.boxSize = 48,
    required this.iconWidth,
    required this.iconHeight,
    this.onTap,
  });

  final String assetName;
  final Color backgroundColor;
  final double boxSize;
  final double iconWidth;
  final double iconHeight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: boxSize,
        height: boxSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(4, 4)),
          ],
        ),
        child: SvgPicture.asset(
          assetName,
          width: iconWidth,
          height: iconHeight,
        ),
      ),
    );
  }
}
