import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/event_repository.dart';

import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'; // 時刻選択用パッケージ
import 'package:intl/intl.dart';
import 'save_changes_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SetTimePage extends StatefulWidget {
  final String eventId;
  final DateTime arrivalTime;

  const SetTimePage({
    super.key,
    required this.eventId,
    required this.arrivalTime,
  });

  @override
  State<SetTimePage> createState() => _SetTimePageState();
}

class _SetTimePageState extends State<SetTimePage> {
  final user = FirebaseAuth.instance.currentUser; // 今ログイン中のユーザー情報を取得

  DateTime? _wakeupTime;
  DateTime? _departureTime;

  Future<void> _loadTime() async {
    if (user == null) return;

    // ユーザーが存在する時eventIdとuserIdが一致するevent_reportsを取得
    final List<Map<String, dynamic>> reports = await EventRepository()
        .getEventReport(widget.eventId, user!.uid);

    // 空でないかつ画面が変わっていないなら
    if (reports.isNotEmpty && mounted) {
      final report = reports.first; // 最初の1件を取得

      setState(() {
        final rawWakeup =
            report['planned_wakeup_time'] ?? report['wakeupTime']; // 空の時は引数代入
        final rawDeparture =
            report['planned_departure_time'] ?? report['departureTime'];

        if (rawWakeup is Timestamp) {
          _wakeupTime = rawWakeup.toDate(); //timestampをdate型に変換
        }
        if (rawDeparture is Timestamp) {
          _departureTime = rawDeparture.toDate();
        }
      });
    }
  }

  @override
  void initState() {
    // 画面が生成されるときだけ実行
    super.initState();
    _loadTime(); // Firestoreからデータを取得
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '00:00'; // 初期値設定
    return DateFormat('HH:mm').format(time); // 時間表示
  }

  Widget _timeSelectionRow({
    required String label,
    required IconData icon,
    required DateTime? currentTime,
    required Function(DateTime) onConfirm,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        color: Colors.white,
      ),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 両端寄せ
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              color: Colors.deepOrange,
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 15),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton(
            onPressed: () {
              DatePicker.showTimePicker(
                context,
                showTitleActions: true, // キャンセル，完了表示
                showSecondsColumn: false, // 秒表記なし
                onConfirm: onConfirm,
                currentTime: DateTime.now(), // 初期値設定
                locale: LocaleType.en, // アプリに合わせて言語を英語に設定
              );
            },
            child: Text(
              currentTime != null
                  ? _formatTime(currentTime) // 時間が指定されたとき
                  : '-- : --', // 時間がnullのとき
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 左寄せ
        children: [
          // My Schedule表示
          const Text(
            'My Schedule',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 32,
            ),
          ),

          // 間のオレンジ線
          const Divider(
            color: Colors.deepOrangeAccent,
            thickness: 2,
            height: 20,
          ),

          // 起床時間設定
          _timeSelectionRow(
            label: 'Wake-up Time',
            icon: Icons.alarm,
            currentTime: _wakeupTime,
            onConfirm: (date) => setState(() {
              // 完了ボタンを押した時変数に代入
              _wakeupTime = date;
            }),
          ),

          // 到着時間設定
          _timeSelectionRow(
            label: 'Departure Time',
            icon: Icons.departure_board,
            currentTime: _departureTime,
            onConfirm: (date) => setState(() {
              _departureTime = date;
            }),
          ),

          // 集合時間表示
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              color: Colors.deepOrangeAccent,
            ),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // カレンダーアイコン
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    color: Colors.black,
                  ),
                  child: const Icon(Icons.event, color: Colors.white, size: 30),
                ),

                const SizedBox(width: 15),

                // Arrival Goal
                const Text(
                  'Arrival Goal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const Spacer(),

                // 時間表示
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    color: Colors.white,
                  ),
                  child: Text(DateFormat('HH:mm').format(widget.arrivalTime)),
                ),
              ],
            ),
          ),

          const Spacer(flex: 1),

          // SAVE CHANGESボタン
          SizedBox(
            width: double.infinity,
            height: 80,
            child: ElevatedButton(
              onPressed: () async {
                if (user != null &&
                    _wakeupTime != null &&
                    _departureTime != null) {
                  // 引数が空でない時

                  final wakeupTimeDay = DateTime(
                    // 日にちをarrivalTimeに合わせる
                    widget.arrivalTime.year,
                    widget.arrivalTime.month,
                    widget.arrivalTime.day,
                    _wakeupTime!.hour,
                    _wakeupTime!.minute,
                  );
                  final departureTimeDay = DateTime(
                    widget.arrivalTime.year,
                    widget.arrivalTime.month,
                    widget.arrivalTime.day,
                    _departureTime!.hour,
                    _departureTime!.minute,
                  );
                  final String? reportId = await EventRepository().setReport(
                    // データベースに保存
                    eventId: widget.eventId,
                    userId: user!.uid,
                    wakeupTime: wakeupTimeDay,
                    departureTime: departureTimeDay,
                  );
                  if (reportId != null) {
                    // レポートが存在したら
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SaveChangesPage(
                            eventId: widget.eventId,
                            wakeupTime: wakeupTimeDay,
                            departureTime: departureTimeDay,
                            arrivalTime: widget.arrivalTime,
                          ),
                        ),
                      );
                      debugPrint('保存画面へ移動');
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter wake-up time and departure time.',
                      ),
                    ),
                  );
                  return;
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                side: const BorderSide(color: Colors.black, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // 中央寄せ
                children: [
                  Text(
                    'SAVE CHANGES',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
