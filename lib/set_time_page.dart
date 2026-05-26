import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/event_repository.dart';

import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'common_layout.dart';
import 'return_button.dart';

class SetTimePage extends StatefulWidget {
  final String groupId;
  final String eventId;
  final String eventTitle;
  final int myRole;
  final DateTime arrivalTime;

  const SetTimePage({
    super.key,
    required this.groupId,
    required this.eventId,
    required this.eventTitle,
    required this.myRole,
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
    final Map<String, dynamic>? report = await EventRepository()
        .getEventReport(widget.eventId, user!.uid);

    // 空でないかつ画面が変わっていないなら
    if (report != null && mounted) {

      setState(() {
        final rawWakeup = report['planned_wakeup_time'] ?? report['wakeupTime']; // 空の時は引数代入
        final rawDeparture = report['planned_departure_time'] ?? report['departureTime'];

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
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 3),
        color: Colors.white,
      ),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 3),
                  color: Colors.deepOrange,
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 15),
              Text(
                label, 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
          TextButton(
            onPressed: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: currentTime != null 
                    ? TimeOfDay.fromDateTime(currentTime) 
                    : const TimeOfDay(hour: 7, minute: 0), // デフォルトは朝7:00
              );

              if (picked != null) {
                final now = DateTime.now();
                final combinedDateTime = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  picked.hour,
                  picked.minute,
                );
                onConfirm(combinedDateTime);
              }
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
    return CommonLayout(
      groupId: widget.groupId,
      eventId: widget.eventId,
      eventTitle: widget.eventTitle,
      myRole: widget.myRole,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                thickness: 3,
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
              const SizedBox(height: 8),

              // 集合時間表示
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 3),
                  color: Colors.deepOrangeAccent,
                ),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // カレンダーアイコン
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            color: Colors.black,
                          ),
                          child: const Icon(
                            Icons.event,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 15),
                        // Arrival Goal
                        const Text(
                          'Arrival Goal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // 時間表示
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        color: Colors.white,
                      ),
                      child: Text(
                        DateFormat('HH:mm').format(widget.arrivalTime),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // SAVE CHANGESボタン
              SizedBox(
                width: double.infinity,
                height: 64,
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
                      final String? reportId = await EventRepository()
                          .setReport(
                            // データベースに保存
                            eventId: widget.eventId,
                            userId: user!.uid,
                            wakeupTime: wakeupTimeDay,
                            departureTime: departureTimeDay,
                          );
                      if (reportId != null) {
                        // レポートが存在したら
                        if (context.mounted) {
                          Navigator.pop(context); 
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Schedule saved successfully.')),
                          );
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
                    side: const BorderSide(color: Colors.black, width: 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  child: const Text(
                    'SAVE CHANGES',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 22,
                    ),
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