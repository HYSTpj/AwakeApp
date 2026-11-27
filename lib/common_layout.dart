import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'presentation/views/common/app_mode.dart';
import 'presentation/views/common/common_footer.dart';
import 'presentation/views/group/group_list_page.dart';
import 'presentation/views/event/admin/memberstatus_page.dart';
import 'presentation/views/event/schedule/set_time_page.dart';
import 'presentation/views/ranking/ranking_page.dart';
import 'presentation/views/event/event_selection_home_page.dart';
import 'presentation/views/event/checkin/late_report_page.dart';
import 'presentation/views/profile/profile_page.dart';
import 'presentation/viewmodels/member_check_in_viewmodel.dart';

class CommonLayout extends StatefulWidget {
  final Widget body; // 各画面の代入する中身
  final Widget? floatingActionButton; // それぞれのページで使うボタン
  // メイン画面（GroupListPage）でグループが未選択のときにフッターを隠すためのフラグ。
  // それ以外の画面は常に表示する。
  final bool showFooter;
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
  static const Color _themeColor = Colors.deepOrangeAccent;
  static const Color _backgroundColor = Color(0xFFF8F6F6);
  static const Color _borderColor = Color(0xFF1A1C1C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      // フッターのピル以外の余白部分を透明にし、bodyの内容が透けて見えるようにする。
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 4.0),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: _borderColor, width: 4),
            ),
          ),
          child: _buildAppBar(context),
        ),
      ),
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
      // showFooterに応じてnull/ウィジェットを切り替えると、再表示のたびに
      // フッターが都度アンマウント→再マウントされてしまう。
      // Visibility(maintainState: true)でフッターのElement自体は維持したまま
      // 表示/非表示だけ切り替える。
      bottomNavigationBar: Visibility(
        visible: widget.showFooter,
        maintainState: true,
        maintainAnimation: true,
        child: CommonFooter(
          mode: widget.myRole == 0 ? AppMode.admin : AppMode.member,
          onHomeTap: () => _onHomeTap(context),
          onEventCreateTap: () => _onEventCreateTap(context),
          onForumTap: () => _onComingSoon(context),
          onRankingTap: () => _onRankingTap(context),
          onPlusTap: () => _onPlusTap(context),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leadingWidth: 100,
      leading: _buildLeftIcons(context),
      title: const Text(
        'AWAKE',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: _buildRightIcons(context),
      backgroundColor: _themeColor,
      foregroundColor: Colors.black,
      elevation: 0,
    );
  }
  Widget _buildLeftIcons(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.flag, color: Colors.black),
          onPressed: () {
            _onLeaderPressed(context);
          },
        ),
        IconButton(
          icon: const Icon(Icons.schedule, color: Colors.black),
          onPressed: () {
            _onMemberPressed(context);
          },
        ),
      ],
    );
  }

  ///AppBarの右側
  List<Widget> _buildRightIcons(BuildContext context) {
    final client = Supabase.instance.client;
    final currentUser = client.auth.currentUser;

    if (currentUser == null) {
      return [
        const Padding(
          padding: EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
        )
      ];
    }
    return [
      Padding(
        padding: const EdgeInsets.only(right: 16),
        child: GestureDetector(
          onTap: () => _onProfilePressed(context),
          child: FutureBuilder<Map<String, dynamic>?>(
            future: client
                .from('profiles')
                .select('avatar_url')
                .eq('id', currentUser.id)
                .maybeSingle(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.hasError ||
                  !snapshot.hasData) {
                return const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                );
              }

              final profileData = snapshot.data ?? {};
              final String? avatarUrl = profileData['avatar_url'];

              return CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? NetworkImage(avatarUrl)
                    : null,
                child: (avatarUrl == null || avatarUrl.isEmpty)
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              );
            },
          ),
        ),
      ),
    ];
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
    Navigator.pushReplacement(
      context,
      _instantRoute((context) => const RankingPreview()),
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              GroupListPage(initialGroupId: widget.groupId),
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
