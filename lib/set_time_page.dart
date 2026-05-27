import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'viewmodels/set_time_viewmodel.dart';
import 'common_layout.dart';
import 'return_button.dart';
import 'save_changes_page.dart';

class SetTimePage extends StatefulWidget {
  final String groupId;
  final String eventId;
  final String eventTitle;
  final int myRole;
  final DateTime arrivalTime;
  final SetTimeViewModel? viewModel;

  const SetTimePage({
    super.key,
    required this.groupId,
    required this.eventId,
    required this.eventTitle,
    required this.myRole,
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
    return CommonLayout(
      groupId: widget.groupId,
      eventId: widget.eventId,
      eventTitle: widget.eventTitle,
      myRole: widget.myRole,
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) {
          return SingleChildScrollView(
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
                                fontSize: 22,
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