/*
  * ranking_list.dart
  * 
  * 遅刻ランキングを表示するためのウィジェット
*/

import 'package:flutter/material.dart';
import '../ranking_logic.dart'; // ランキングのロジックをインポート

class RankingList extends StatefulWidget {
  final String groupId; // グループIDを受け取るためのプロパティ
  const RankingList({super.key, required this.groupId});

  @override
  State<RankingList> createState() => _RankingListState();
}

class _RankingListState extends State<RankingList> {

  final RankingLogic _logic = RankingLogic();
  late Future<List<RankingUser>> _rankingFuture;

  // 共通の太黒枠のデザイン設定
  final double borderWidth = 4.0;
  final Color borderColor = Colors.black;

  @override
  void initState() {
    super.initState();
    // 画面が開いた瞬間に、Firebaseからこのグループのデータを取ってくる予約をする
    _rankingFuture = _logic.getGroupRanking(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RankingUser>>(
      future: _rankingFuture,
      builder: (context, snapshot) {
        // ⏳ データをまだ読み込み中のとき（くるくる回るローディングを表示）
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(color: Colors.black),
          ));
        }

        // ❌ エラーが発生した、またはデータが空っぽのとき
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('No ranking data available.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ));
        }

        // ⭕ 無事にデータが届いたとき（usersの中にランキング順の全員のデータが入っています！）
        final users = snapshot.data!;

        // 💡 念のため、データが足りないとき（1人しかいないときなど）にエラーにならないための仕掛け
        final user1 = users.isNotEmpty ? users[0] : null;
        final user2 = users.length > 1 ? users[1] : null;
        final user3 = users.length > 2 ? users[2] : null;

        return Column(
          children: [
            /* 1位のカード */
            if (user1 != null)
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: borderColor, width: borderWidth),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [

                          // アイコン表示（URLがあればネットから、なければカタツムリ）
                          Container(
                            width: 140,
                            height: 140,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(71, 253, 173, 132),
                              shape: BoxShape.circle,
                              border: Border.all(color: borderColor, width: borderWidth),
                              image: user1.avatarUrl.isNotEmpty
                                  ? DecorationImage(image: NetworkImage(user1.avatarUrl), fit: BoxFit.cover)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 名前とカタツムリ
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/katatsumuri.png', width: 40, height: 40),
                              const SizedBox(width: 8),
                              
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // 左揃えにします
                                children: [
                                  Text(
                                    user1.nickname, // 💡 1位のユーザー名
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontFamily: 'Space Grotesk',
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Text(
                                    user1.uid, // 💡 user1.id から user1.uid に修正（RankingUserの定義に合わせる）
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // LATE CHAMPのバッジ (1位の称号)
                          Transform.rotate(
                            angle: 0.14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: const BoxDecoration(color: Colors.black),
                              child: const Text(
                                'LATE CHAMP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Space Grotesk',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // STREAK
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEC5B13),
                              border: Border.all(color: borderColor, width: borderWidth),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'STREAK',
                                  style: TextStyle(color: Colors.white, fontFamily: 'Space Grotesk', fontWeight: FontWeight.w900, fontSize: 18),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: borderColor, width: borderWidth),
                                  ),
                                  child: Text(
                                    '${user1.lateCount} DAYS', // 💡 1位の遅刻回数をここに表示！
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Space Grotesk',
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 2位と3位の表示
                          Row(
                            children: [
                              Expanded(child: _buildStatusBox('TOTAL DELAY', '${user1.sleepcount}回')), // 💡 サブ情報として寝坊回数を入れてみました
                              const SizedBox(width: 12),
                              Expanded(child: _buildStatusBox('TOTAL TIME', '24H 30M')),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /* 1位のバッジ */
                    Container(
                      transform: Matrix4.identity()..rotateZ(-0.09),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFEC5B13),
                        shape: const RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black, width: 4),
                        ),
                      ),
                      child: const Text(
                        '#1',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 32,
                          fontFamily: 'Space Grotesk',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            /* 2位と3位のカード */
            // 💡 それぞれデータが存在するときだけ、名前と遅刻回数（〇〇DAYS）を渡して表示する
            if (user2 != null) _buildSubRankRow('#2', user2.uid, user2.nickname, '${user2.lateCount} DAYS', user2.avatarUrl),
            if (user3 != null) _buildSubRankRow('#3', user3.uid, user3.nickname, '${user3.lateCount} DAYS', user3.avatarUrl),
          ],
        );
      },
    );
  }

  // 1位のカード内のステータスボックスを作るためのパーツ（ここはそのまま！）
  Widget _buildStatusBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFEC5B13),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 2位と3位のカードを作るためのパーツ
  Widget _buildSubRankRow(String rankNum, String userid, String username, String streakDays, String avatarUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Row(
        children: [
          // ランキング番号
          Text(
            rankNum,
            style: const TextStyle(fontSize: 20, fontFamily: 'Space Grotesk', fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 12),

          // アイコン表示
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color.fromARGB(71, 253, 173, 132),
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 3),
              image: avatarUrl.isNotEmpty
                  ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // ユーザー名
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(username, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(userid, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // STREAK表示のボックス
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEC5B13),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: Text(
              streakDays, // 💡 ここに遅刻回数（〇 DAYS）が入ります
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}