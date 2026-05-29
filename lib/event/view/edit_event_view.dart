import 'package:flutter/material.dart';
import '../../common_layout.dart';
import '../domain/event_entity.dart';
import '../data/event_data.dart';
import '../view_model/edit_event_view_model.dart';

// CreateEventPageと共通のボダースタイル定義
const _kBorderSide = BorderSide(width: 3, color: Color(0xFF475569));
const _kLabelStyle = TextStyle(
  fontSize: 14,
  fontFamily: 'Noto Sans JP',
  fontWeight: FontWeight.w700,
  height: 1.43,
  letterSpacing: 0.70,
);
const _kValueStyle = TextStyle(
  fontSize: 14,
  fontFamily: 'Noto Sans JP',
  fontWeight: FontWeight.w700,
  color: Colors.black,
);

class _LabelText extends StatelessWidget {
  final String text;
  const _LabelText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(text, style: _kLabelStyle),
    );
  }
}

// 入力フィールドコンテナ
class _InputBox extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _InputBox({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: padding,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(side: _kBorderSide),
      ),
      child: child,
    );
  }
}

// 選択ボタン
class _PickerButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PickerButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 152,
          height: 48,
          alignment: Alignment.center,
          decoration: const ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(side: _kBorderSide),
          ),
          child: Text(label, style: _kValueStyle),
        ),
      ),
    );
  }
}

class EditEventPage extends StatefulWidget {
  final EventEntity event;
  final String groupId;
  final int myRole;

  const EditEventPage({
    super.key,
    required this.event,
    required this.groupId,
    required this.myRole,
  });

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _repository = EventRepositoryImpl(); 
  final EditEventViewModel _viewModel = EditEventViewModel();
  
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late DateTime _scheduledTime;

  // 時刻表示文字列
  String get _timeLabel {
    final h = _scheduledTime.hour % 12 == 0 ? 12 : _scheduledTime.hour % 12;
    final m = _scheduledTime.minute.toString().padLeft(2, '0');
    final period = _scheduledTime.hour < 12 ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')} : $m $period';
  }

  // 日付表示文字列
  String get _dateLabel {
    final month = _scheduledTime.month.toString().padLeft(2, '0');
    final day = _scheduledTime.day.toString().padLeft(2, '0');
    return '$month / $day / ${_scheduledTime.year}';
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event.title);
    _locationController = TextEditingController(text: widget.event.destinationName);
    _scheduledTime = widget.event.arrivalTime ?? DateTime.now();
    
    _viewModel.loadInitialData(widget.groupId, widget.event.eventId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (_nameController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    try {
      await _repository.updateEventDetails(
        eventId: widget.event.eventId,
        title: _nameController.text.trim(),
        destinationName: _locationController.text.trim(),
        arrivalTime: _scheduledTime.toIso8601String(),
        participants: _viewModel.selectedMembers.toList(), 
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event settings updated successfully!')),
      );
      Navigator.pop(context, true); 
    } catch (e) {
      debugPrint('更新失敗: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return CommonLayout(
          body: _viewModel.isLoading 
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    // 戻るボタン
                    Padding(
                      padding: const EdgeInsets.only(left: 14, top: 9),
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: const RoundedRectangleBorder(side: _kBorderSide),
                            shadows: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 0,
                                offset: const Offset(4, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
                        ),
                      ),
                    ),

                    // タイトル
                    const Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 16),
                      child: Center(
                        child: Text(
                          'Edit Event',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontFamily: 'Space Grotesk',
                            fontWeight: FontWeight.w700,
                            height: 1.33,
                            letterSpacing: -0.96,
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          // イベント名
                          const _LabelText('EVENT NAME'),
                          const SizedBox(height: 4),
                          _InputBox(
                            padding: const EdgeInsets.all(8),
                            child: TextField(
                              controller: _nameController,
                              textAlignVertical: TextAlignVertical.center,
                              style: _kValueStyle,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),

                          // 時間
                          const _LabelText('TIME'),
                          _PickerButton(
                            label: _timeLabel, 
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(_scheduledTime),
                              );
                              if (time == null) return;
                              setState(() {
                                _scheduledTime = DateTime(_scheduledTime.year, _scheduledTime.month, _scheduledTime.day, time.hour, time.minute);
                              });
                            }
                          ),

                          // 日付
                          const _LabelText('DATE'),
                          _PickerButton(
                            label: _dateLabel, 
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _scheduledTime,
                                firstDate: DateTime.now().subtract(const Duration(days: 7)),
                                lastDate: DateTime(2030),
                              );
                              if (date == null) return;
                              setState(() {
                                _scheduledTime = DateTime(date.year, date.month, date.day, _scheduledTime.hour, _scheduledTime.minute);
                              });
                            }
                          ),

                          // 場所
                          const _LabelText('Location'),
                          const SizedBox(height: 4),
                          _InputBox(
                            child: TextField(
                              controller: _locationController,
                              textAlignVertical: TextAlignVertical.center,
                              style: _kValueStyle,
                              decoration: const InputDecoration(
                                hintText: 'Search location...',
                                border: InputBorder.none,
                                isDense: true,
                                suffixIcon: Icon(Icons.search, color: Color(0xFF475569)),
                              ),
                            ),
                          ),

                          const Divider(height: 40, thickness: 2, color: Color(0xFF475569)),

                          // 参加者選択セクション
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const _LabelText('EDIT PARTICIPANTS'),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: const ShapeDecoration(
                                  color: Colors.black,
                                  shape: RoundedRectangleBorder(),
                                ),
                                child: Text(
                                  '${_viewModel.selectedMembers.length} SELECTED',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'Space Grotesk',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          // メンバーリスト枠
                          Container(
                            width: double.infinity,
                            decoration: const ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(side: _kBorderSide),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: _viewModel.allMembers.map((member) {
                                final uid = member['uid'] ?? '';
                                final isSelected = _viewModel.selectedMembers.contains(uid);
                                final nickname = member['nickname'] ?? 'No Name';
                                final avatarUrl = member['avatar_url'] ?? '';

                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    border: Border(bottom: BorderSide(width: 1, color: Color(0xFFE2E8F0))),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Colors.grey,
                                        backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                                        child: avatarUrl.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 24) : null,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(nickname, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                                            Text('@$uid', style: TextStyle(color: Colors.black.withValues(alpha: 0.5), fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          const Text('ATTENDING', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black)),
                                          Switch(
                                            value: isSelected,
                                            activeThumbColor: const Color(0xFFFF5C00),
                                            onChanged: (bool val) {
                                              _viewModel.toggleParticipant(uid, val);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          // SAVE SETTINGS ボタン
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 32),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepOrangeAccent,
                                  shape: const RoundedRectangleBorder(
                                    side: _kBorderSide,
                                  ),
                                ),
                                onPressed: _saveSettings, 
                                child: const Text(
                                  'SAVE SETTINGS', 
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        );
      }
    );
  }
}