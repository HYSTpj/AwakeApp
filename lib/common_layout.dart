import 'package:flutter/material.dart';
import 'package:flutter_application_1/group/view/group_list_view.dart';
import 'create_event_page.dart';
import 'member_check_in.dart';
import 'ranking/ranking_screen.dart';
import 'event_selection_home.dart';

class CommonLayout extends StatelessWidget {
  final Widget body;  // 各画面の代入する中身
  final Widget? floatingActionButton;  // それぞれのページで使うボタン
  final String? groupId;
  final String? eventId;
  final String? eventTitle;
  final int? myRole;

  // ボトムナビゲーション
  static const _bottomNavigationItems = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.only(top: 25),
        child: Icon(Icons.group),
      ),
      label: 'status',
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
          icon: const Icon(Icons.flag),
          onPressed: () => _onLeaderPressed(context),
        ),
        IconButton(
          icon: const Icon(Icons.schedule),
          onPressed: () => _onMemberPressed(context),
        ),
      ],
    );
  }

  ///AppBarの右側
  List<Widget> _buildRightIcons() {
    return [
      IconButton(
        icon: const Icon(Icons.account_circle),
        onPressed: _onProfilePressed,
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
    Widget? nextPage;
    switch (index) {
      case 0:
        nextPage = const EventSelectionHome();  // あとからポスト，ランキング画面に変更
        break;
      case 1:
        // IDがない場合
        if (groupId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select group.')),
          );
          debugPrint("グループが選択されていません");
          return;
        } else if (eventId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select event.')),
          );
          debugPrint("イベントが選択されていません");
          return;
        }
        if (myRole == 0) {
          nextPage = CreateEventPage(groupId: groupId!);
        } else {
          nextPage = MemberCheckInPage(eventId: eventId!, eventTitle: eventTitle!, groupId: groupId!);
        }
        break;
      case 2:
        nextPage = const RankingPreview();
        break;
    }
    if (nextPage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => nextPage!)
      );
    }
  }

  // 管理者ボタンが押された時の処理
  void _onLeaderPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GroupListPage()),
    );
    debugPrint('管理者ボタンが押されました');
  }

  // 利用者ボタンが押された時の処理
  void _onMemberPressed(BuildContext context) {
    Navigator.push(
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
