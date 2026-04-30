import 'package:flutter/material.dart';
import 'package:flutter_application_1/ranking/ranking_screen.dart';

class CommonLayout extends StatelessWidget {
  // 各画面の代入する中身
  final Widget body;

  // それぞれのページで使うボタン
  final Widget? floatingActionButton;

  const CommonLayout({
    super.key,
    required this.body,
    this.floatingActionButton,
  });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 背景の色
      backgroundColor: const Color(0xFFF8F6F6),

      appBar: _buildAppBar(),
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leadingWidth: 100,
      leading: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.flag),
            onPressed: () {
              debugPrint('flagボタンが押されました');
            },
          ),
          IconButton(
            icon: const Icon(Icons.schedule),
            onPressed: () {
              debugPrint('scheduleボタンが押されました');
            },
          ),
        ],
      ),
      title: const Text(
        'AWAKE',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () {
            debugPrint('profileボタンが押されました');
          },
        ),
      ],
      backgroundColor: Colors.deepOrangeAccent,
      foregroundColor: Colors.black,
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepOrangeAccent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: _bottomNavigationItems,
        onTap: (index) {
          debugPrint('$index番目のボタンが押されました');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const RankingPreview(),
            ),
          );
        },
      ),
    );
  }
}
