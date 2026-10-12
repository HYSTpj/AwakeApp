import 'package:flutter/material.dart';
import 'package:flutter_application_1/common_layout.dart';

// --- プレビュー用のメイン関数 ---
void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RankingPreview(),
    ),
  );
}

// 一つの画面として動く形にパッケージングしたもの
class RankingPreview extends StatelessWidget { // 表示専用のウィジェット
  const RankingPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: eventPageBody(),
    );
  }
}

// --- ランキング画面の中身 ---
Widget eventPageBody() {

  //　画面全体で使うデザインのルール
  final BoxBorder neoBorder = Border.all(color: Colors.black, width: 2.5); // すべての箱を囲む枠線
  final List<BoxShadow> neoShadow = [
    const BoxShadow(color: Colors.black, offset: Offset(4, 4)), // すべての箱に適用される影
  ];
  
  // テスト用データ（Firebaseを通さない）
  const String userImageUrl = 'https://via.placeholder.com/150';
  const String displayName = 'USERNAME';

  return SingleChildScrollView(
    // 画面の淵の余白を一括で設定。下はスペースを大きめに取る。
    padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
    child: Column(
      children: [
        // アイコンとRankingのタイトルを横並び
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_alt_outlined, size: 28),
            SizedBox(width: 8),
            Text(
              'Ranking',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        // タイトル下の隙間
        const SizedBox(height: 20),

        // 白いカード
        Stack( // stack→重ねるための土台
          // 1位の大きな白いカードの土台
          clipBehavior: Clip.none, // はみ出す部分も表示する
          children: [
            // メインの白いカード
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: neoBorder,
                boxShadow: neoShadow,
              ),
              child: Column(
                // #1のユーザーカードの内容
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFBDDCF),
                      border: neoBorder,
                      boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                      image: const DecorationImage(
                        image: NetworkImage(userImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // ★ 名前をテスト用の displayName に連動
                  Text(
                    displayName,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'LATE CHAMP',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEC5B13),
                      border: neoBorder,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // ★ ストリークと遅刻時間の部分をRowで横並びにして、スペースを空ける
                      children: [
                        const Text('STREAK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 2)),
                          child: const Text('8 DAYS', style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _buildSmallBox('TOTAL DELAY', '12H 44M', neoBorder, neoShadow),
                      const SizedBox(width: 10),
                      _buildSmallBox('AVG. DELAY', '42 MIN', neoBorder, neoShadow),
                    ],
                  ),
                ],
              ),
            ),

            // #1のラベル
            Positioned(
              top: -10,
              left: -5,
              child: Transform.rotate(
                angle: -0.1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEC5B13),
                    border: neoBorder,
                    boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
                  ),
                  child: const Text('#1', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 24)),
                ),
              ),
            ),
          ],
        ),

        // #2以降のユーザーカードの内容
        const SizedBox(height: 20),
        _buildListItem('#2', 'Alex Riv', '@alex_riv_2024', '8 DAYS', neoBorder, neoShadow),
        const SizedBox(height: 15),
        _buildListItem('#3', 'Alex Riv', '@alex_riv_2024', '8 DAYS', neoBorder, neoShadow),
      ],
    ),
  );
}

// #1のユーザーカードのストリークと遅刻時間の部分を作る関数
Widget _buildSmallBox(String title, String value, BoxBorder border, List<BoxShadow> shadow) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFE5E7EB), border: border, boxShadow: shadow),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      ),
    ),
  );
}

// #2以降のユーザーカードを作る関数
Widget _buildListItem(String rank, String name, String id, String days, BoxBorder border, List<BoxShadow> shadow) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, border: border, boxShadow: shadow),
    child: Row(
      children: [
        Text(rank, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        const SizedBox(width: 10),
        const CircleAvatar(backgroundColor: Color(0xFFFBDDCF), radius: 20, child: Icon(Icons.person, color: Colors.black)),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(id, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 2)),
          child: Text(days, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
        ),
      ],
    ),
  );
}