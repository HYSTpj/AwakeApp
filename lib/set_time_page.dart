import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'; // 時刻選択用パッケージ
import 'package:intl/intl.dart';
import 'save_changes_page.dart';
import 'viewmodels/set_time_viewmodel.dart';

class SetTimePage extends StatefulWidget {
  final String eventId;
  final DateTime arrivalTime;
  final SetTimeViewModel? viewModel;

  const SetTimePage({
    super.key,
    required this.eventId,
    required this.arrivalTime,
    this.viewModel,
  });

  @override
  State<SetTimePage> createState() => _SetTimePageState();
}

class _SetTimePageState extends State<SetTimePage> {
  late final SetTimeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? SetTimeViewModel(eventId: widget.eventId);
    // If a viewModel was injected (e.g. in tests), avoid auto-loading from Firebase
    if (widget.viewModel == null) {
      _viewModel.loadTime(); // Firestoreからデータを取得
    }
  }

  @override
  void dispose() {
    if (widget.viewModel == null) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '-- : --'; // 初期値設定
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
          const SizedBox(height: 10),
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
              _formatTime(currentTime),
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) {
          return SingleChildScrollView(
            child: Padding(
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

                  // エラーメッセージの表示
                  if (_viewModel.errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      color: Colors.redAccent,
                      child: Text(
                        _viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // 起床時間設定
                  _timeSelectionRow(
                    label: 'Wake-up Time',
                    icon: Icons.alarm,
                    currentTime: _viewModel.wakeupTime,
                    onConfirm: _viewModel.setWakeupTime,
                  ),

                  // 到着時間設定
                  _timeSelectionRow(
                    label: 'Departure Time',
                    icon: Icons.departure_board,
                    currentTime: _viewModel.departureTime,
                    onConfirm: _viewModel.setDepartureTime,
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
                          ),
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
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),

                  // SAVE CHANGESボタン
                  SizedBox(
                    width: double.infinity,
                    height: 80,
                    child: ElevatedButton(
                      onPressed: _viewModel.isSaving
                          ? null
                          : () async {
                              final success = await _viewModel.saveChanges(widget.arrivalTime);
                              if (success && context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SaveChangesPage(
                                      eventId: widget.eventId,
                                      wakeupTime: DateTime(
                                        widget.arrivalTime.year,
                                        widget.arrivalTime.month,
                                        widget.arrivalTime.day,
                                        _viewModel.wakeupTime!.hour,
                                        _viewModel.wakeupTime!.minute,
                                      ),
                                      departureTime: DateTime(
                                        widget.arrivalTime.year,
                                        widget.arrivalTime.month,
                                        widget.arrivalTime.day,
                                        _viewModel.departureTime!.hour,
                                        _viewModel.departureTime!.minute,
                                      ),
                                      arrivalTime: widget.arrivalTime,
                                    ),
                                  ),
                                );
                                debugPrint('保存画面へ移動');
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
                          if (_viewModel.isSaving)
                            const CircularProgressIndicator(color: Colors.white)
                          else
                            const Text(
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
          );
        },
      ),
    );
  }
}
