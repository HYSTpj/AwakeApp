/*
  * ranking_page.dart
  *
  * 遅刻王ランキング画面のプレビュー用コードです。
  * ここでは、RankingPageをMaterialAppでラップして、アプリ全体のテーマを設定しています。
  * 実際のアプリでは、CommonLayoutを使用して、他の画面と一貫したレイアウトを提供することができます。
  *
*/

import 'package:flutter/material.dart';
import '../common_layout.dart';
import 'widgets/ranking_list.dart';
import 'widgets/zange_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/event_repository.dart';

class RankingPage extends StatefulWidget {
  final String groupId;
  final int myRole;

  const RankingPage({
    super.key,
    required this.groupId,
    required this.myRole,
  });

  @override
  State<RankingPage> createState() => RankingPageState();
}

class RankingPageState extends State<RankingPage> {

  // groupIdの取得
  final user = FirebaseAuth.instance.currentUser; // 今ログイン中のユーザー情報を取得

  // データベース用のインスタンス（仮）
  final _dbService = EventRepository();

  // スクロールをコントロールするための変数
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();

    // スクロール位置を監視するリスナーを登録
    _scrollController.addListener(() {
      setState(() {
        if (_scrollController.offset > 400) {
          _showBackToTopButton = true;
        } else {
          _showBackToTopButton = false;
        }
      });
    });
  }

  @override
  void dispose() {
    // 使い終わったコントローラーを破棄
    _scrollController.dispose();
    super.dispose();
  }

  // 最上部までスムーズにスクロール
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    
    return CommonLayout( // 共通レイアウトを使用
      groupId: widget.groupId,
      myRole: widget.myRole,
      body: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController, // コントローラーをセット
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 16), // 上に余白

                  // ランキングの背景コンテナ
                  Center(
                    child: Container(
                      
                      width: 0.9 * MediaQuery.of(context).size.width, // 画面幅の90%
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.white,

                        // 枠
                        border: Border.all(color: Color(0xFF1A1C1C), width: 2),

                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [

                          // ヘッダー
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF5C00),
                              border: Border(
                                bottom: BorderSide(color: Color(0xFF1A1C1C), width: 2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'WEEKLY LATE RANKING',
                                  style: TextStyle(
                                    color: Color(0xFF521800),
                                    fontSize: 18,
                                    fontFamily: 'Space Grotesk',
                                    fontWeight: FontWeight.w900,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                            // ランキングリストを表示するウィジェット
                            RankingList(
                                key: ValueKey(widget.groupId),
                                groupId: widget.groupId,
                              ),
                          ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 遅刻投稿の表示
                  FutureBuilder<List<Map<String, dynamic>>>(
                      
                      future: _dbService.getGroupAllZange(widget.groupId),

                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (snapshot.hasError) { // 写真がない
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'There have been no recent confession posts.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }
                        final members = snapshot.data!;

                        return Column(
                          children: members.map((member) => ZangeCard(memberData: member)).toList(),
                        );
                      }
                    ),
                  const SizedBox(height: 90),
                ],
              ),
            ),

            // 8. 「上に戻る」ボタンの配置（Positionedを外側に出して、中身を出し分けします）
            Positioned(
              right: 20,
              bottom: 20,
              child: _showBackToTopButton
                  ? GestureDetector(
                      onTap: _scrollToTop,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5C00), // ヘッダーと同じオレンジ
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF1A1C1C), width: 3), // アプリ全体の太枠に合わせた黒枠
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF1A1C1C),
                              offset: Offset(3, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                  )
                : const SizedBox.shrink(), // 非表示のときは透明なサイズ0の箱にする
          ),
        ],
      ),
    );
  }
}