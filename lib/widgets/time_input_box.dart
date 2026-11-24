import 'package:flutter/material.dart';
import '../style/app_color.dart';

const _sheetBorderColor = Color(0xFF121212);
const _dimTextColor = Color(0xFF9E9E9E);
const _bandColor = Color(0xFFFFE5D1);

/// `TimeOfDay`を"HH:mm"形式の文字列に変換する共通フォーマッタ。
String formatTimeOfDay(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// Figmaの"Wake-up Time"/"Departure Time"入力と同じ「HH:MM表示＋タップで編集」の
/// パターンを再利用できるようにした時刻入力ボックス。
/// タップするとFigmaの"TimeSheet"仕様([showSpinnerTimePicker])を開く。
class TimeInputBox extends StatelessWidget {
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay> onChanged;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final Color textColor;
  final double height;
  final BorderRadius borderRadius;
  final String placeholder;
  final String pickerLabel;
  final String pickerTitle;

  const TimeInputBox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.pickerLabel,
    required this.pickerTitle,
    this.backgroundColor = Colors.white,
    this.borderColor = _sheetBorderColor,
    this.borderWidth = 1,
    this.textColor = _sheetBorderColor,
    this.height = 40,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.placeholder = '--:--',
  });

  Future<void> _onTap(BuildContext context) async {
    final picked = await showSpinnerTimePicker(
      context,
      initialTime: value,
      label: pickerLabel,
      title: pickerTitle,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final text = value == null ? placeholder : formatTimeOfDay(value!);

    return GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: borderRadius,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
    );
  }
}

/// FigmaのTimeSheet仕様(ドラッグハンドル/カテゴリラベル/12時間制3列ホイール/
/// CANCEL・SETボタン)に忠実なボトムシート型の時刻ピッカー。
Future<TimeOfDay?> showSpinnerTimePicker(
  BuildContext context, {
  required String label,
  required String title,
  TimeOfDay? initialTime,
}) {
  final initial = initialTime ?? TimeOfDay.now();
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x8C000000),
    isScrollControlled: true,
    builder: (context) => _TimeSheet(initialTime: initial, label: label, title: title),
  );
}

class _TimeSheet extends StatefulWidget {
  final TimeOfDay initialTime;
  final String label;
  final String title;

  const _TimeSheet({required this.initialTime, required this.label, required this.title});

  @override
  State<_TimeSheet> createState() => _TimeSheetState();
}

class _TimeSheetState extends State<_TimeSheet> {
  late int _hour12;
  late int _minute;
  late bool _isPm;

  @override
  void initState() {
    super.initState();
    final hour24 = widget.initialTime.hour;
    _isPm = hour24 >= 12;
    final h12 = hour24 % 12;
    _hour12 = h12 == 0 ? 12 : h12;
    _minute = widget.initialTime.minute;
  }

  void _confirm() {
    var hour24 = _hour12 % 12;
    if (_isPm) hour24 += 12;
    Navigator.pop(context, TimeOfDay(hour: hour24, minute: _minute));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _sheetBorderColor, width: 3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 11, 24, 24 + bottomInset),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(color: _sheetBorderColor, borderRadius: BorderRadius.circular(3)),
            ),
            const SizedBox(height: 14),
            Text(
              widget.label.toUpperCase(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.orange, letterSpacing: 2),
            ),
            const SizedBox(height: 2),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _sheetBorderColor),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: _bandColor,
                      border: Border.all(color: _sheetBorderColor, width: 3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _WheelColumn(
                        itemCount: 12,
                        initialItem: _hour12 - 1,
                        labelBuilder: (i) => (i + 1).toString().padLeft(2, '0'),
                        onChanged: (v) => setState(() => _hour12 = v + 1),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(':', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: _sheetBorderColor)),
                      ),
                      _WheelColumn(
                        itemCount: 60,
                        initialItem: _minute,
                        labelBuilder: (i) => i.toString().padLeft(2, '0'),
                        onChanged: (v) => setState(() => _minute = v),
                      ),
                      _WheelColumn(
                        itemCount: 2,
                        initialItem: _isPm ? 1 : 0,
                        labelBuilder: (i) => i == 0 ? 'AM' : 'PM',
                        onChanged: (v) => setState(() => _isPm = v == 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: _sheetBorderColor, width: 3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)],
                      ),
                      child: const Text('CANCEL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _sheetBorderColor, letterSpacing: 1)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: _confirm,
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        border: Border.all(color: _sheetBorderColor, width: 3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)],
                      ),
                      child: const Text('SET', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _sheetBorderColor, letterSpacing: 1)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }
}

/// 選択中の項目を太字/大きく、隣接項目をグレー/小さく表示するホイール列。
/// FigmaのSpinbutton("06 / 07 / 08"の擬似3D表示)を再現する。
class _WheelColumn extends StatefulWidget {
  final int itemCount;
  final int initialItem;
  final String Function(int index) labelBuilder;
  final ValueChanged<int> onChanged;

  const _WheelColumn({
    required this.itemCount,
    required this.initialItem,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  State<_WheelColumn> createState() => _WheelColumnState();
}

class _WheelColumnState extends State<_WheelColumn> {
  late final FixedExtentScrollController _controller =
      FixedExtentScrollController(initialItem: widget.initialItem);
  late int _selectedIndex = widget.initialItem;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSelectedItemChanged(int index) {
    setState(() => _selectedIndex = index);
    widget.onChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: ListWheelScrollView.useDelegate(
        controller: _controller,
        itemExtent: 56,
        diameterRatio: 2.2,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: _handleSelectedItemChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: widget.itemCount,
          builder: (context, index) {
            final isCenter = index == _selectedIndex;
            return Center(
              child: Text(
                widget.labelBuilder(index),
                style: TextStyle(
                  fontSize: isCenter ? 40 : 24,
                  fontWeight: FontWeight.bold,
                  color: isCenter ? _sheetBorderColor : _dimTextColor,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
