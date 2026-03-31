import 'package:flutter/material.dart';
import 'package:flutter_application_1/common_layout.dart';
import 'package:flutter_application_1/ranking/ranking_screen.dart';

class CommonLayout extends StatefulWidget{
  // 各画面の代入する中身
  final Widget body;

  // それぞれのページで使うボタン
  final Widget? floatingActionButton;

  const CommonLayout({
    super.key,
    required this.body,

    // それぞれのページで使うボタン
    this.floatingActionButton,
  });
  
  @override
  State<CommonLayout> createState() => CommonLayoutState();
}

class CommonLayoutState extends State<CommonLayout> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // 背景の色
      backgroundColor: const Color(0xFFF8F6F6),

      // 上のバー表示
      appBar: AppBar(
        leadingWidth: 100,
        leading: Row( // 左側に水平に並べる
          children: [

            // flagボタン
            IconButton(
              icon: const Icon(Icons.flag),
              onPressed: () {
                debugPrint('flagボタンが押されました');
              },
            ),

            // scheduleボタン
            IconButton(
              icon: const Icon(Icons.schedule),
              onPressed: () {
                debugPrint('scheduleボタンが押されました');
              },
            )
          ],
        ),

        // アプリ名表示
        title: const Text(  // 真ん中
          'AWAKE', // アプリ名入れる
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
        centerTitle: true,

        // profileボタン
        actions: [  // 右側
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              debugPrint('profileボタンが押されました');
            }),
        ],
        
        // 色決め
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors. black,
      ),

      // 各画面のメイン
      body: widget.body,

      // それぞれのページで使うボタン追加
      floatingActionButton: widget.floatingActionButton, 
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // 下のボタン表示
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.deepOrangeAccent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,  // 場所固定
          backgroundColor: Colors.transparent,  // 透明にするとContainerの色になる
          elevation: 0, // 影消す
          showSelectedLabels: false,  // labelの表示を消す
          showUnselectedLabels: false,
          items: const [

            // groupボタン
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsetsGeometry.only(top: 25),
                child: Icon(Icons.group),
              ),
              label: 'group'
            ),

            // calenderボタン
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsetsGeometry.only(top: 25),
                child: Icon(Icons.calendar_month),
              ),
              label: 'calender'
            ),
              
            // QRcodeボタン
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsetsGeometry.only(top: 25),
                child: Icon(Icons.qr_code),
              ),
              label: 'QRcode'
            ),
          ],
          onTap: (index) {
            debugPrint('$index番目のボタンが押されました');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RankingPreview(),
              ),
            );
          },
        ),
      ),
    );
  }
}
