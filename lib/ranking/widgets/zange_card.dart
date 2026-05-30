/*
  * zange_card.dart
  * 
  * 懺悔投稿カードのウィジェット  
*/

import 'package:flutter/material.dart';

class ZangeCard extends StatefulWidget {
    final Map<String, dynamic> memberData;
    // コンストラクタ
    const ZangeCard({super.key, required this.memberData});

    @override
    State<ZangeCard> createState() => _ZangeCardState();
}

class _ZangeCardState extends State<ZangeCard> {

    int donmaiCount = 0;

    @override
    Widget build(BuildContext context) {
        // データを取り出す
        final String avatarUrl = widget.memberData['avatar_url'] ?? '';  // アイコン
        final String nickname = widget.memberData['nickname'] ?? 'anonymous';  // 名前
        final String userId = widget.memberData['user_id'] ?? 'unknown';  // ユーザーID
        final String eventName = widget.memberData['event_name'] ?? 'event'; // イベント名
        final String status = widget.memberData['status'] ?? 'STATUS'; // ステータス
        final String reason = widget.memberData['reason'] ?? 'No reason.';  // 遅刻理由
        final String latePhotoUrl = widget.memberData['late_photo_url'] ?? ''; // 遅刻写真

        // Widgetを返す
        return Container(
            width: 0.9 * MediaQuery.of(context).size.width, // 画面幅の90%
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2.0),
            ),

            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                    // ヘッダー
                    Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                bottom: BorderSide(color: Color(0xFF1A1C1C), width: 2.0),
                            ),
                        ),

                        // ユーザー情報（アイコン，名前，ID，ステータス）
                        child: Row(
                            children: [
                                // アイコン
                                Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: const Color.fromARGB(71, 253, 173, 132),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.black, width: 2),
                                        image: avatarUrl.isNotEmpty
                                            ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
                                            : null,
                                    ),
                                ),
                                const SizedBox(width: 12),

                                // 名前とID
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.start, // 左寄せ
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        // 名前
                                        Text(
                                            nickname,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                            ),
                                        ),
                                        const SizedBox(height: 4),

                                        // ID
                                        Text(
                                            userId,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                            ),
                                        ),
                                    ],
                                ),
                                const Spacer(),

                                // イベント名とステータス
                                Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [

                                        // イベント名
                                        Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                                color: const Color(0xFFFF5C00),
                                                border: Border.all(color: Colors.black, width: 2),
                                            ),
                                            child: Text(
                                                eventName,
                                                style: const TextStyle(
                                                    color: Color(0xFF521800),
                                                    fontSize: 10,
                                                    fontFamily: 'Space Grotesk',
                                                    fontWeight: FontWeight.w900,
                                                ),
                                            ),
                                        ),
                                        const SizedBox(width: 2),

                                        // ステータス
                                        Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                                color: const Color(0xFFFF5C00),
                                                border: Border.all(color: Colors.black, width: 2),
                                            ),
                                            child: Text(
                                                status,
                                                style: const TextStyle(
                                                    color: Color(0xFF521800),
                                                    fontSize: 10,
                                                    fontFamily: 'Space Grotesk',
                                                    fontWeight: FontWeight.w900,
                                                ),
                                            ),
                                        ),
                                    ],
                                ),
                            ],
                        ),

                    ),

                    // 本文
                    Padding(
                        padding: EdgeInsets.all(8.0),

                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                        
                                // 遅刻写真
                                if (latePhotoUrl.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Center(
                                        child: Container(
                                            
                                            width: 0.7 * MediaQuery.of(context).size.width, // 画面幅の90%
                                            height: 200,

                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(
                                                border: Border.all(color: Colors.black, width: 3.0),
                                                image: DecorationImage(
                                                    image: NetworkImage(latePhotoUrl),
                                                    fit: BoxFit.cover,
                                                ),
                                            ),
                                        ),
                                    ),
                                ],

                                const SizedBox(height: 12),

                                // 遅刻理由
                                Center(
                                    child: Container(
                                        width: 0.8 * MediaQuery.of(context).size.width, // 画面幅の90%
                                        padding: const EdgeInsets.all(12),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Colors.black, width: 3.0), 
                                        ),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Container(
                                                    padding: const EdgeInsets.only(bottom: 2.0),
                                                    decoration: const BoxDecoration(
                                                        border: Border(
                                                            bottom: BorderSide(color: Colors.black, width: 2.0),
                                                        ),
                                                    ),
                                                    child: const Text(
                                                        'LATE REASON',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 12,
                                                            fontFamily: 'Space Grotesk',
                                                            fontWeight: FontWeight.w700,
                                                        ),
                                                    ),
                                                ),
                                                const SizedBox(height: 4),

                                                Text(
                                                    reason,
                                                    style: TextStyle(
                                                        color: const Color(0xFF5B4137),
                                                        fontSize: 10,
                                                        fontFamily: 'Space Grotesk',
                                                        fontWeight: FontWeight.w700,
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                ),
                            ],
                        ),
                    ),

                    // フッター(ドンマイボタン)
                    Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                            padding: const EdgeInsets.only(right: 12.0, bottom: 12.0), // カードの右下からの余白
                            child: Container(
                            // ボタンの外枠
                                decoration: BoxDecoration(
                                    color: const Color(0xFFFF5C00),
                                    border: Border.all(color: Colors.black, width: 2.0), // 太めの黒枠
                                ),
                                child: IconButton(
                                    icon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                            const Icon(
                                                Icons.thumb_up_alt_outlined, // いいねアイコン（親指マーク）
                                                color: Colors.black,
                                                size: 20,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                                '$donmaiCount', // ボタンの文字
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: 'Space Grotesk',
                                                ),
                                            ),
                                        ],
                                    ),
                                    onPressed: () {
                                        setState(() {
                                            donmaiCount++;
                                        });
                                    },
                                ),
                            ),
                        ), 
                    ),
                ],
            ),
        );
    }
}