import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'data/profiles_repository.dart';
import 'group/view/group_list_view.dart';
import 'create_event_page.dart';
import 'member_check_in.dart';
import 'ranking/ranking_page.dart';
import 'event_selection_home.dart';

class CommonLayout extends StatelessWidget {
  // テスト用にナビゲーション先を差し替えられるようにするフック
  // テストでは `CommonLayout.pageBuilderOverride = (index, groupId: ..., myRole: ...) => MyFakePage();` のように使えます
  static Widget Function(int index, {String? groupId, int? myRole})? pageBuilderOverride;

  final Widget body;  // 各画面の代入する中身
  final Widget? floatingActionButton;  // それぞれのページで使うボタン
  final String? groupId;
  final String? eventId;
  final String? eventTitle;
  final int? myRole;

  const CommonLayout({
    super.key,
    required this.body,
    this.floatingActionButton,
    this.groupId,
    this.eventId,
    this.eventTitle,
    this.myRole,
  });

  // ボトムナビゲーション
  static const _bottomNavigationItems = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.only(top: 25),
        child: Icon(Icons.group),
      ),
      label: 'group',
    ),
    BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.only(top: 25),
        child: Icon(Icons.calendar_month),
      ),
      label: 'event',
    ),
    BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.only(top: 25),
        child: Icon(Icons.qr_code),
      ),
      label: 'ranking',
    ),
  ];

  // アプリのテーマカラー
  static const Color _themeColor = Colors.deepOrangeAccent;

  // 背景色
  static const Color _backgroundColor = Color(0xFFF8F6F6);

  // 境界線カラー
  static const Color _borderColor = Color(0xFF1A1C1C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 4.0), // 高さを調整
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: _borderColor, width: 4), // 境界線
            ),
          ),
          child: _buildAppBar(context),
        ),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // AppBar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leadingWidth: 100,
      leading: _buildLeftIcons(context),
      title: const Text(
        'AWAKE',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: _buildRightIcons(),
      backgroundColor: _themeColor,
      foregroundColor: Colors.black,
      elevation: 0,
    );
  }

  // AppBarの左側
  Widget _buildLeftIcons(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.flag, color: Colors.black),
          onPressed: () {
            _onLeaderPressed(context);
            debugPrint("管理者ボタン");
          },
        ),
        IconButton(
          icon: const Icon(Icons.schedule, color: Colors.black),
          onPressed: () {
            _onMemberPressed(context);
            debugPrint("利用者ボタン");
          },
        ),
      ],
    );
  }

  ///AppBarの右側
  List<Widget> _buildRightIcons() {
    final currentUser = FirebaseAuth.instance.currentUser;

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
          onTap: _onProfilePressed,
          child: FutureBuilder<Map<String, dynamic>?>(
            future: ProfilesRepository().getProfile(uid: currentUser.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting || snapshot.hasError || !snapshot.hasData) {
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

  /// BottomNavigationBar
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _themeColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _borderColor, width: 4),
      ),
      child: ClipRRect( // 枠線に合わせて中身も丸める
        borderRadius: BorderRadius.circular(26), 
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black.withValues(alpha: 0.5),
          items: _bottomNavigationItems,
          onTap: (index) => _onNavigationTap(context, index),
        ),
      ),
    );
  }

  // ナビゲーションタップ時の処理
  void _onNavigationTap(BuildContext context, int index) {
    // グループが選ばれていないとき
    if (index != 0) {
      if (groupId == null || myRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select group.')),
        );
        return;
      }
    }
    Widget? nextPage;

    // テスト時にページ生成を差し替えられるようにするフック
    if (CommonLayout.pageBuilderOverride != null) {
      nextPage = CommonLayout.pageBuilderOverride!(index, groupId: groupId, myRole: myRole);
    } else {
      switch (index) {
        case 0:
          nextPage = GroupListPage();   // あとからポスト，ランキング画面に変更
          break;
        case 1:
          if (myRole == 0) {
            // 管理者の時
            nextPage = CreateEventPage(
              groupId: groupId!,
              myRole: myRole!
            );
          } else {
            // 利用者の時
            if (eventId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select event.')),
              );
              return;
            }
            nextPage = MemberCheckInPage(
              eventId: eventId!, 
              eventTitle: eventTitle!, 
              groupId: groupId!, 
            );
          }
          break;
        case 2:
          nextPage = RankingPage(
            groupId: groupId!,
            myRole: myRole!
          );
          break;
      }
    }
    if (nextPage != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextPage!)
      );
    }
  }

  // 管理者ボタンが押された時の処理
  void _onLeaderPressed(BuildContext context) {
    // グループが選ばれていないとき
    if (myRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select group.')),
      );
      debugPrint('グループが選択されていません');
      return;
    }

    // 管理者のときだけ遷移を許可
    if (myRole == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GroupListPage()),
      );
      debugPrint('管理者ページへ移動');
    } else {
      // 利用者のとき
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('閲覧権限がありません（管理者のみ利用可能）')
        ),
      );
      debugPrint('利用者のため遷移不可');
    }
  }

  // 利用者ボタンが押された時の処理
  void _onMemberPressed(BuildContext context) {
    if (groupId == null || myRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select group.')),
      );
      debugPrint('グループが選択されていません');
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const EventSelectionHome()),
    );
    debugPrint('利用者ボタンが押されました');
  }

  // プロフィールボタンが押された時の処理
  void _onProfilePressed() {
    debugPrint('プロフィールボタンが押されました');
  }
}