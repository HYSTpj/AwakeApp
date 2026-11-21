import 'package:flutter/material.dart';

import '../../../../models/event.dart';

/// イベント名だけを表示・選択する共通ドロップダウン。[GroupDropdown]と
/// 組み合わせて[GroupEventHeader]として使う想定。
///
/// 「EVENT NAME」ヒント表示（カレンダーアイコン付き）、イベント一覧、
/// 「+ ADD EVENT」特殊項目を表示する。[enabled]がfalseの場合（グループが
/// 未選択等）は操作不可になる。
class EventDropdown extends StatelessWidget {
  const EventDropdown({
    super.key,
    required this.events,
    required this.selectedEventId,
    this.enabled = true,
    this.onEventSelected,
    this.onAddEvent,
  });

  final List<Event> events;
  final String? selectedEventId;
  final bool enabled;
  final ValueChanged<Event>? onEventSelected;
  final VoidCallback? onAddEvent;

  @override
  Widget build(BuildContext context) {
    final dropdownValue = events.any((e) => e.id == selectedEventId)
        ? selectedEventId
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: dropdownValue,
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black,
            size: 24,
          ),
          hint: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.calendar_today, color: Color(0xFF1A1C1C), size: 16),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'EVENT NAME',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1C1C),
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          selectedItemBuilder: (context) => events
              .map(
                (e) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    e.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1C1C),
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          items: !enabled
              ? const []
              : [
                  ...events.map((Event event) {
                    return DropdownMenuItem<String>(
                      value: event.id,
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1C1C),
                        ),
                      ),
                    );
                  }),
                  const DropdownMenuItem<String>(
                    value: 'add_event',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '+ ADD EVENT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF5C00),
                          ),
                        ),
                        Icon(Icons.add_box, color: Color(0xFFFF5C00)),
                      ],
                    ),
                  ),
                ],
          onChanged: !enabled
              ? null
              : (String? value) {
                  if (value == null) return;

                  if (value == 'add_event') {
                    onAddEvent?.call();
                    return;
                  }

                  final event = events.firstWhere((e) => e.id == value);
                  onEventSelected?.call(event);
                },
        ),
      ),
    );
  }
}
