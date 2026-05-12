import 'package:flutter/material.dart';
import 'ranking/ranking_screen.dart';
import 'event_selection_home.dart';
import 'event/view/event_list_view.dart';
import 'qr_scanner_page.dart';

/// アプリ全体で共通のレイアウトを提供するウィジェット
/// AppBar、Body、FloatingActionButton、BottomNavigationBarを含む
class CommonLayout extends StatelessWidget {
  /// 各画面のメインコンテンツ
  final Widget body;

  /// 画面固有のフローティングアクションボタン
  final Widget? floatingActionButton;

  const CommonLayout({
    super.key,
    required this.body,
    this.floatingActionButton,
  });

  /// ボトムナビゲーションのアイテム定義
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
      label: 'calendar',
    ),
    BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.only(top: 25),
        child: Icon(Icons.qr_code),
      ),
      label: 'QRcode',
    ),
  ];

  /// アプリのテーマカラー
  static const Color _themeColor = Colors.deepOrangeAccent;

  /// 背景色
  static const Color _backgroundColor = Color(0xFFF8F6F6);

  /// 境界線カラー
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
          child: _buildAppBar(),
        ),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  /// AppBarを構築する
  AppBar _buildAppBar() {
    return AppBar(
      leadingWidth: 100,
      leading: _buildLeadingIcons(),
      title: const Text(
        'AWAKE',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: _buildActions(),
      backgroundColor: _themeColor,
      foregroundColor: Colors.black,
      elevation: 0,
    );
  }

  /// AppBarのleading部分のアイコンを構築
  Widget _buildLeadingIcons() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.flag),
          onPressed: _onFlagPressed,
        ),
        IconButton(
          icon: const Icon(Icons.schedule),
          onPressed: _onSchedulePressed,
        ),
      ],
    );
  }

  /// AppBarのactionsを構築
  List<Widget> _buildActions() {
    return [
      IconButton(
        icon: const Icon(Icons.account_circle),
        onPressed: _onProfilePressed,
      ),
    ];
  }

  /// BottomNavigationBarを構築する
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

  /// ナビゲーションタップ時の処理
  void _onNavigationTap(BuildContext context, int index) {
    Widget? nextPage;
    switch (index) {
      case 0:
        nextPage = const EventSelectionHome();
        break;
      case 1:
        // calendar: イベントリストページ。groupIdが必要だが、仮にデフォルトグループを使用
        nextPage = const EventListPage(groupId: 'default_group_id');
        break;
      case 2:
        nextPage = const QRScannerPage();
        break;
      default:
        nextPage = const RankingPreview();
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => nextPage!),
    );
  }

  /// フラグボタンが押された時の処理
  void _onFlagPressed() {
    debugPrint('flagボタンが押されました');
  }

  /// スケジュールボタンが押された時の処理
  void _onSchedulePressed() {
    debugPrint('scheduleボタンが押されました');
  }

  /// プロファイルボタンが押された時の処理
  void _onProfilePressed() {
    debugPrint('profileボタンが押されました');
  }
}
