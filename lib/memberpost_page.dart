import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'common_layout.dart';
import 'package:intl/intl.dart'; //DateFormatを使用するために追加
import 'return_button.dart';

class MemberPostPage extends StatelessWidget {
  final Map<String, dynamic> member; // 名前やアイコン用
  final Map<String, dynamic> report; // 理由や写真用
  final String groupId;
  final String eventId;
  final String eventTitle;
  final int myRole;

  const MemberPostPage({
    super.key,
    required this.member,
    required this.report,
    required this.groupId,
    required this.eventId,
    required this.eventTitle,
    required this.myRole,
  });

  // 位置情報を文字に変換する関数
  String _formatLocation(dynamic location) {
    if (location is GeoPoint) {
      // 緯度と経度を「(35.1, 136.9)」みたいな文字にする
      return '${location.latitude.toStringAsFixed(1)}, ${location.longitude.toStringAsFixed(1)}';
    }
    return location?.toString() ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    // 時間を文字に変換する処理（下のListViewと同じやり方）
    final dynamic rawTime = report['actual_wakeup_time'];
    String displayTime = '--:--';
    if (rawTime != null && rawTime is Timestamp) {
      displayTime = DateFormat("M/dd HH:mm").format(rawTime.toDate());
    }

    return CommonLayout(
      groupId: groupId,
      eventId: eventId,
      eventTitle: eventTitle,
      myRole: myRole,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // 戻るボタン
            ReturnButton(onTap: () {
              Navigator.pop(context);
              debugPrint('1画面戻る');
            }),

            const SizedBox(height: 10),
            // ユーザー情報（アイコンと名前）
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage: member['avatar_url'] != null
                      ? NetworkImage(member['avatar_url'])
                      : null,
                  child: member['avatar_url'] == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 15),
                Text(
                  member['nickname'] ?? 'No name',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ★ 証拠写真（Figmaのコーヒー写真の部分）
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                color: Colors.white, // 画像がない時の背景色
              ),
              // DecorationImage を使わずに、child に Image.network を入れます
              child: report['photo_url'] != null && report['photo_url'] != ""
                  ? Image.network(
                      // photo_urlに中身がある時
                      report['photo_url'],
                      fit: BoxFit.cover,
                      // ここが「くるくる」の魔法です！
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child; // 読み込み完了なら画像を表示
                        }
                        return const Center(
                          child: CircularProgressIndicator(), // 読み込み中はくるくるを表示
                        );
                      },
                      // 万が一画像が読み込めなかった時のエラー表示
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.error));
                      },
                    )
                  : const Center(
                      // 中身がない時
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'No Image',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            // 起きた時間と場所（Figmaのタグ部分）
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoTag(
                  Icons.location_on,
                  _formatLocation(report['location']),
                ),
                _infoTag(Icons.alarm, 'WAKE-UP: $displayTime'),
              ],
            ),
            const SizedBox(height: 20),

            // 遅刻理由（LATE REASON）
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LATE REASON',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Text(report['late_reason'] ?? 'The reason is not entered.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(0),
        color: Colors.grey[300],
      ),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
