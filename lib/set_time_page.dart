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

  // SmartCalculator: 移動時間と準備時間から起床・出発時刻を自動計算する
  Future<void> _showSmartCalculatorDialog() async {
    int transitMinutes = 30;
    int prepMinutes = 60;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final previewDeparture = widget.arrivalTime.subtract(Duration(minutes: transitMinutes));
            final previewWakeup = previewDeparture.subtract(Duration(minutes: prepMinutes));
            return AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.auto_fix_high, color: Colors.deepOrange),
                  SizedBox(width: 8),
                  Text('Smart Calculate', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '集合時刻: ${DateFormat('HH:mm').format(widget.arrivalTime)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text('移動時間 (分)', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setDialogState(() {
                          if (transitMinutes > 5) transitMinutes -= 5;
                        }),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$transitMinutes 分', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () => setDialogState(() {
                          transitMinutes += 5;
                        }),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('準備時間 (分)', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setDialogState(() {
                          if (prepMinutes > 5) prepMinutes -= 5;
                        }),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$prepMinutes 分', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () => setDialogState(() {
                          prepMinutes += 5;
                        }),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 計算結果プレビュー
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.shade50,
                      border: Border.all(color: Colors.deepOrange, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('起床時刻: ${DateFormat('HH:mm').format(previewWakeup)}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('出発時刻: ${DateFormat('HH:mm').format(previewDeparture)}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('キャンセル'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _departureTime = previewDeparture;
                      _wakeupTime = previewWakeup;
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                  ),
                  child: const Text('適用', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _timeSelectionRow({
    required String label,
    required IconData icon,
    required DateTime? currentTime,
    required Function(DateTime) onConfirm,
  }) {
    return GestureDetector(
      onTap: () {
        DatePicker.showTimePicker(
          context,
          showTitleActions: true, // キャンセル，完了表示
          showSecondsColumn: false, // 秒表記なし
          onConfirm: onConfirm,
          currentTime: DateTime.now(), // 初期値設定
          locale: LocaleType.en, // アプリに合わせて言語を英語に設定
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          color: Colors.white,
        ),
        width: double.infinity,
        child: Row(
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
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: currentTime != null ? Colors.deepOrange : Colors.grey,
                  width: 2,
                ),
                color: currentTime != null
                    ? Colors.deepOrange.shade50
                    : Colors.grey.shade100,
              ),
              child: Text(
                currentTime != null
                    ? _formatTime(currentTime) // 時間が指定されたとき
                    : '-- : --', // 時間がnullのとき
                style: TextStyle(
                  color: currentTime != null ? Colors.deepOrange : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Schedule',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 左寄せ
            children: [
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
                    const Expanded(
                      child: Text(
                        'Arrival Goal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // 時間表示
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        color: Colors.white,
                      ),
                      child: Text(
                        DateFormat('HH:mm').format(widget.arrivalTime),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // スマートカリキュレーター
              SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton.icon(
                  onPressed: _showSmartCalculatorDialog,
                  icon: const Icon(Icons.auto_fix_high, color: Colors.deepOrange),
                  label: const Text(
                    'SMART CALCULATE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                      fontSize: 18,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.deepOrange, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

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
        ),
      ),
    );
  }
}
