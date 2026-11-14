import 'package:flutter/material.dart';
import 'presentation/views/common/app_mode.dart';
import 'presentation/views/common/common_header.dart';
import 'presentation/views/common/common_footer.dart';
import 'presentation/views/group/group_list_page.dart';
import 'presentation/views/event/admin/create_event_page.dart';
import 'presentation/views/event/admin/memberstatus_page.dart';
import 'presentation/views/event/schedule/set_time_page.dart';
import 'presentation/views/ranking/ranking_page.dart';
import 'presentation/views/event/event_selection_home_page.dart';
import 'presentation/views/profile/profile_page.dart';

class CommonLayout extends StatefulWidget {
  final Widget body; // 各画面の代入する中身
  final Widget? floatingActionButton; // それぞれのページで使うボタン
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

  AppMode get _mode => widget.myRole == 0 ? AppMode.admin : AppMode.member;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: CommonHeader(
        mode: _mode,
        onModeChanged: (mode) => _onModeChanged(context, mode),
        onProfileTap: () => _onProfilePressed(context),
      ),
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CommonFooter(
        mode: _mode,
        onHomeTap: () => _onHomeTap(context),
        onEventCreateTap: () => _onEventCreateTap(context),
        onForumTap: () => _onComingSoon(context),
        onRankingTap: () => _onRankingTap(context),
        onPlusTap: () => _onComingSoon(context),
      ),
    );
  }

  void _onModeChanged(BuildContext context, AppMode mode) {
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CreateEventPage(
            groupId: widget.groupId!,
            myRole: widget.myRole!,
          ),
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GroupListPage(initialGroupId: widget.groupId)),
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EventSelectionHome(
          groupId: widget.groupId!,
          groupName: widget.groupName ?? 'Group',
          myRole: widget.myRole!,
        ),
      ),
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
