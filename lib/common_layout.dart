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

  // ヘッダー・フッターは一度だけ生成し、以後は同一インスタンスを使い回す。
  // CommonLayout自体の再構築（親画面の無関係なsetState等）のたびに
  // ヘッダー/フッターまでbuildし直されるのを防ぎ、AppModeControllerの
  // 変更時（各ウィジェット内部のListenableBuilder）だけ再描画されるようにする。
  late final PreferredSizeWidget _header;
  late final Widget _footer;

  @override
  void initState() {
    super.initState();
    _header = _AnimatedCommonHeader(
      onModeChanged: (mode) => _onModeChanged(context, mode),
      onProfileTap: () => _onProfilePressed(context),
    );
    _footer = _AnimatedCommonFooter(
      onHomeTap: () => _onHomeTap(context),
      onEventCreateTap: () => _onEventCreateTap(context),
      onForumTap: () => _onComingSoon(context),
      onRankingTap: () => _onRankingTap(context),
      onPlusTap: () => _onPlusTap(context),
    );
  }

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
    return Scaffold(
      backgroundColor: _backgroundColor,
      // フッターのピル以外の余白部分を透明にし、bodyの内容が透けて見えるようにする。
      extendBody: true,
      appBar: _header,
      body: _withBodyTransition(widget.body),
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // showFooterに応じてnull/ウィジェットを切り替えると、再表示のたびに
      // _footerが都度アンマウント→再マウントされてしまう（ヘッダーには
      // こうした分岐が無く、常に同一インスタンスを参照している）。
      // Visibility(maintainState: true)でフッターのElement自体は維持した
      // まま表示/非表示だけ切り替え、ヘッダーと同じく_footerが
      // 不要に作り直されないようにする。
      bottomNavigationBar: Visibility(
        visible: widget.showFooter,
        maintainState: true,
        maintainAnimation: true,
        child: _withBodyTransition(_footer),
      ),
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
      _instantRoute(
        (context) => MemberStatusPage(
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
        _instantRoute(
          (context) => GroupListPage(initialGroupId: widget.groupId),
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
      _instantRoute(
        (context) => SetTimePage(
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
    if (widget.groupId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select group.')));
      return;
    }

    Navigator.pushReplacement(
      context,
      _instantRoute((context) => RankingPage(groupId: widget.groupId!)),
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
      _instantRoute(
        (context) => LateReportPage(
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

  // フッターからの画面遷移共通のルート。ページ全体がスライドする
  // 「ページング」のような見た目（旧ヘッダー/フッターが新しいものと
  // 一緒にスライドして二重に見える）を避けるため、ページ切り替えに
  // トランジションを付けない。遷移先ページが非同期読み込み中に表示する
  // CircularProgressIndicator（ローディングのくるくる）がそのまま
  // 即座に見える形になる。
  PageRoute<T> _instantRoute<T>(WidgetBuilder builder) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) =>
          builder(context),
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

// CommonLayoutが何度再構築されても、AppModeControllerが実際に変更通知を
// 出したときだけCommonHeaderをbuildし直すためのラッパー。_CommonLayoutState
// 側で一度だけ生成し、インスタンスを使い回すことで効果を発揮する。
class _AnimatedCommonHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const _AnimatedCommonHeader({this.onModeChanged, this.onProfileTap});

  final ValueChanged<AppMode>? onModeChanged;
  final VoidCallback? onProfileTap;

  @override
  Size get preferredSize =>
      const Size.fromHeight(CommonHeader.preferredHeight);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppModeController.instance,
      builder: (context, _) => CommonHeader(
        mode: AppModeController.instance.mode,
        onModeChanged: onModeChanged,
        onProfileTap: onProfileTap,
      ),
    );
  }
}

// _AnimatedCommonHeaderと同じ理由で、CommonFooterをAppModeControllerの
// 変更時だけbuildし直すためのラッパー。
class _AnimatedCommonFooter extends StatelessWidget {
  const _AnimatedCommonFooter({
    this.onHomeTap,
    this.onEventCreateTap,
    this.onForumTap,
    this.onRankingTap,
    this.onPlusTap,
  });

  final VoidCallback? onHomeTap;
  final VoidCallback? onEventCreateTap;
  final VoidCallback? onForumTap;
  final VoidCallback? onRankingTap;
  final VoidCallback? onPlusTap;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppModeController.instance,
      builder: (context, _) => CommonFooter(
        mode: AppModeController.instance.mode,
        onHomeTap: onHomeTap,
        onEventCreateTap: onEventCreateTap,
        onForumTap: onForumTap,
        onRankingTap: onRankingTap,
        onPlusTap: onPlusTap,
      ),
    );
  }
}
