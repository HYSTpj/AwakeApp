import 'package:flutter/material.dart';
import 'presentation/views/common/app_mode.dart';
import 'presentation/views/common/common_header.dart';
import 'presentation/views/common/common_footer.dart';
import 'presentation/views/group/group_list_page.dart';
import 'presentation/views/event/admin/memberstatus_page.dart';
import 'presentation/views/event/schedule/set_time_page.dart';
import 'presentation/views/ranking/ranking_page.dart';
import 'presentation/views/event/event_selection_home_page.dart';
import 'presentation/views/event/checkin/late_report_page.dart';
import 'presentation/views/profile/profile_page.dart';
import 'presentation/viewmodels/app_mode_controller.dart';
import 'presentation/viewmodels/member_check_in_viewmodel.dart';

class CommonLayout extends StatefulWidget {
  final Widget body; // 各画面の代入する中身
  final Widget? floatingActionButton; // それぞれのページで使うボタン
  // メイン画面（GroupListPage）でグループが未選択のときにフッターを隠すためのフラグ。
  // それ以外の画面は常に表示する。
  final bool showFooter;
  // 管理者/メンバー切替時にのみ渡される、body+footer（メインコンテンツ）を
  // 下から上へスライドインさせるためのアニメーション。ヘッダーには適用しない。
  final Animation<double>? bodyTransitionAnimation;
  final String? groupId;
  final String? groupName;
  final String? eventId;
  final String? eventTitle;
  final int? myRole;
  // SetTimePage（メンバーのEventCreateボタン遷移先）に渡すための、そのイベントの到着目標時刻。
  final DateTime? arrivalTime;
  // MemberStatusPage（Homeボタン遷移先）表示用。整形済み文字列・パスコード・QRコード照合トークン。
  final String? arrivalTimeDisplay;
  final String? password;
  final String? qrcodeId;

  const CommonLayout({
    super.key,
    required this.body,
    this.floatingActionButton,
    this.showFooter = true,
    this.bodyTransitionAnimation,
    this.groupId,
    this.groupName,
    this.eventId,
    this.eventTitle,
    this.myRole,
    this.arrivalTime,
    this.arrivalTimeDisplay,
    this.password,
    this.qrcodeId,
  });


  @override
  State<CommonLayout> createState() => _CommonLayoutState();
}

class _CommonLayoutState extends State<CommonLayout> {
  static const Color _backgroundColor = Color(0xFFF8F6F6);

  // 管理者/メンバー切替時のみ、body・footer（メインコンテンツ）を下から
  // 上へスライドインさせる。ヘッダーはこのアニメーションの対象外とし、
  // 従来通り即時に切り替わる。
  Widget _withBodyTransition(Widget child) {
    final animation = widget.bodyTransitionAnimation;
    if (animation == null) return child;

    final offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(animation);

    return SlideTransition(position: offsetAnimation, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppModeController.instance,
      builder: (context, _) {
        final mode = AppModeController.instance.mode;
        return Scaffold(
          backgroundColor: _backgroundColor,
          // フッターのピル以外の余白部分を透明にし、bodyの内容が透けて見えるようにする。
          extendBody: true,
          appBar: CommonHeader(
            mode: mode,
            onModeChanged: (mode) => _onModeChanged(context, mode),
            onProfileTap: () => _onProfilePressed(context),
          ),
          body: _withBodyTransition(widget.body),
          floatingActionButton: widget.floatingActionButton,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: widget.showFooter
              ? _withBodyTransition(
                  CommonFooter(
                    mode: mode,
                    onHomeTap: () => _onHomeTap(context),
                    onEventCreateTap: () => _onEventCreateTap(context),
                    onForumTap: () => _onComingSoon(context),
                    onRankingTap: () => _onRankingTap(context),
                    onPlusTap: () => _onPlusTap(context),
                  ),
                )
              : null,
        );
      },
    );
  }

  void _onModeChanged(BuildContext context, AppMode mode) {
    // 既に選択中のモードを再タップした場合は、無駄な再遷移（同じページの
    // reloadレース）を避けるため何もしない。
    if (AppModeController.instance.mode == mode) return;

    if (mode == AppMode.member) {
      _onMemberPressed(context);
    } else {
      _onLeaderPressed(context);
    }
  }

  void _onHomeTap(BuildContext context) {
    if (widget.groupId == null || widget.myRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select group.')),
      );
      return;
    }

    if (widget.eventId == null ||
        widget.eventTitle == null ||
        widget.arrivalTimeDisplay == null ||
        widget.password == null ||
        widget.qrcodeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select event.')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MemberStatusPage(
          groupId: widget.groupId!,
          eventId: widget.eventId!,
          eventTitle: widget.eventTitle!,
          myRole: widget.myRole!,
          arrivalTime: widget.arrivalTimeDisplay!,
          password: widget.password!,
          qrcodeId: widget.qrcodeId!,
        ),
      ),
    );
  }

  void _onEventCreateTap(BuildContext context) {
    if (widget.groupId == null || widget.myRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select group.')),
      );
      return;
    }

    if (widget.myRole == 0) {
      // 管理者はまずMEMBER STATUSと同じイベント一覧（GroupListPage→EventListPage）
      // へ遷移し、そこの「+Add Events」から作成フォーム（CreateEventPage）に進む。
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              GroupListPage(initialGroupId: widget.groupId),
        ),
      );
      return;
    }

    if (widget.eventId == null ||
        widget.eventTitle == null ||
        widget.arrivalTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select event.')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SetTimePage(
          groupId: widget.groupId!,
          eventId: widget.eventId!,
          eventTitle: widget.eventTitle!,
          myRole: widget.myRole!,
          arrivalTime: widget.arrivalTime!,
        ),
      ),
    );
  }

  void _onRankingTap(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RankingPreview()),
    );
  }

  void _onComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon.')),
    );
  }

  Future<void> _onPlusTap(BuildContext context) async {
    if (widget.groupId == null || widget.eventId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select event.')),
      );
      return;
    }

    final checkInViewModel = MemberCheckInViewModel(
      eventId: widget.eventId!,
      groupId: widget.groupId!,
    );
    final reportId = await checkInViewModel.getOrCreateReportId();

    if (!context.mounted) return;

    if (reportId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('投稿を作成できませんでした。')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LateReportPage(
          reportId: reportId,
          eventId: widget.eventId!,
        ),
      ),
    );
  }

  void _onLeaderPressed(BuildContext context) {
    // グループが選ばれていないとき
    if (widget.myRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select group.')),
      );
      return;
    }

    // 管理者のときだけ遷移を許可
    if (widget.myRole == 0) {
      AppModeController.instance.setMode(AppMode.admin);
      Navigator.pushReplacement(
        context,
        _slideInRoute(
          (animation) => GroupListPage(
            initialGroupId: widget.groupId,
            bodyTransitionAnimation: animation,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('閲覧権限がありません（管理者のみ利用可能）')),
      );
    }
  }

  void _onMemberPressed(BuildContext context) {
    if (widget.groupId == null || widget.myRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select group.')),
      );
      return;
    }

    AppModeController.instance.setMode(AppMode.member);
    Navigator.pushReplacement(
      context,
      _slideInRoute(
        (animation) => EventSelectionHome(
          groupId: widget.groupId!,
          groupName: widget.groupName ?? 'Group',
          myRole: widget.myRole!,
          bodyTransitionAnimation: animation,
        ),
      ),
    );
  }

  // 管理者/メンバー切替専用の画面遷移。ページ全体（ヘッダー含む）は従来通り
  // 即時に切り替わり、渡したanimationを使って遷移先ページのbody/footerだけが
  // 下から上へスライドインする。
  // 参考: https://qiita.com/isekiryu/items/be7477659b70bb152733
  PageRoute<void> _slideInRoute(
    Widget Function(Animation<double> animation) builder,
  ) {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) =>
          builder(animation),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          child,
    );
  }

  // プロフィールボタンが押された時の処理
  void _onProfilePressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );

    debugPrint('プロフィールページへ遷移');
  }
}
