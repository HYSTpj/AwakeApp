import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'common_layout.dart';
import 'group/view/group_list_view.dart';

class SaveChangesPage extends StatefulWidget {
  final String eventId;
  final DateTime wakeupTime;
  final DateTime departureTime;
  final DateTime arrivalTime;

  const SaveChangesPage({
    super.key,
    required this.eventId,
    required this.wakeupTime,
    required this.departureTime,
    required this.arrivalTime,
  });

  @override
  State<SaveChangesPage> createState() => _SaveChangesPageState();
}

class _SaveChangesPageState extends State<SaveChangesPage> {
  final user = FirebaseAuth.instance.currentUser; // 今ログイン中のユーザー情報を取得

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      // 共通レイアウトを使用
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                // アイコンツリー
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      // アラームアイコン
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                          color: Colors.deepOrange,
                        ),
                        child: const Icon(
                          Icons.notifications_active,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),

                      // 間の黒線
                      Container(width: 3, height: 150, color: Colors.black),

                      // コンパスアイコン
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.black,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.near_me,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),

                      // 間の黒線
                      Container(width: 3, height: 160, color: Colors.black),

                      // ロックアイコン
                      const CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.black,
                        child: Icon(Icons.lock, color: Colors.white, size: 20),
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: Column(
                      children: [
                        // wake up box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CALCULATED WAKE-UP',
                                style: TextStyle(
                                  color: Colors.deepOrangeAccent,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat(
                                      'HH:mm',
                                    ).format(widget.wakeupTime),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      height: 1,
                                    ),
                                  ),
                                  const Text(
                                    'PRIMARY ALARM',
                                    style: TextStyle(
                                      color: Colors.deepOrangeAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 準備時間
                        Container(
                          width: 180,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            color: Colors.deepOrangeAccent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.hourglass_bottom,
                                color: Colors.white,
                                size: 18,
                              ),

                              const SizedBox(width: 8),

                              Text(
                                '${widget.departureTime.difference(widget.wakeupTime).inMinutes}M PREP', // 時間差
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // departure box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CALCULATED DEPARTURE',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                DateFormat(
                                  'HH:mm',
                                ).format(widget.departureTime),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 移動時間
                        Container(
                          width: 180,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            color: Colors.deepOrangeAccent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.directions_car,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.arrivalTime.difference(widget.departureTime).inMinutes}M TRANSIT',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // arrival box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ARRIVAL GOAL',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('HH:mm').format(widget.arrivalTime),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100),

              // イベント一覧移動ボタン
              Container(
                width: double.infinity,
                height: 70,
                decoration: BoxDecoration(color: Colors.deepOrangeAccent),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      // グループリストページへ移動
                      MaterialPageRoute(
                        builder: (context) => const GroupListPage(),
                      ),
                    );
                    debugPrint('イベント一覧画面へ移動');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    side: const BorderSide(color: Colors.black, width: 3),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'APPLY SEQUENCE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
