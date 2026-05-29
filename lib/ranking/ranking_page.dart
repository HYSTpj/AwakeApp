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
import 'package:firebase_auth/firebase_auth.dart';


class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => RankingPageState();
}

class RankingPageState extends State<RankingPage> {

  // groupIdの取得
  final user = FirebaseAuth.instance.currentUser; // 今ログイン中のユーザー情報を取得

  String? selectedGroupId;  // 今選択中のグループID

  @override
  Widget build(BuildContext context) {
    
    return CommonLayout( // 共通レイアウトを使用
      body: SingleChildScrollView(
        child: Column(
          children: [

            // 遅刻投稿の表示
            

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
                      selectedGroupId == null
                        ? const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              'Please select a group.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          )
                        : RankingList(
                          key: ValueKey(selectedGroupId),
                          groupId: selectedGroupId!,
                        ),
                    ],
                ),
              ),
            ),
            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}