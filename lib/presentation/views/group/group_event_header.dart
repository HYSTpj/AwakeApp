import 'package:flutter/material.dart';

import '../../../../models/event.dart';
import '../../../../models/group.dart';
import 'event_dropdown.dart';
import 'group_dropdown.dart';

/// MEMBER STATUS画面など、グループ名とイベント名を横並びで表示・選択する
/// 画面共通のヘッダー（[GroupDropdown] + [EventDropdown]）。
///
/// グループ名のみを表示すればよい画面は[GroupDropdown]を単体で使うこと。
class GroupEventHeader extends StatelessWidget {
  const GroupEventHeader({
    super.key,
    required this.groups,
    required this.selectedGroupId,
    this.onGroupSelected,
    this.onCreateAddDelete,
    required this.events,
    required this.selectedEventId,
    this.onEventSelected,
    this.onAddEvent,
  });

  final List<Group> groups;
  final String? selectedGroupId;
  final ValueChanged<Group>? onGroupSelected;
  final VoidCallback? onCreateAddDelete;

  final List<Event> events;
  final String? selectedEventId;
  final ValueChanged<Event>? onEventSelected;
  final VoidCallback? onAddEvent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 24, top: 16, bottom: 16),
            child: GroupDropdown(
              groups: groups,
              selectedGroupId: selectedGroupId,
              onGroupSelected: onGroupSelected,
              onCreateAddDelete: onCreateAddDelete,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 24, top: 16, bottom: 16),
            child: EventDropdown(
              events: events,
              selectedEventId: selectedEventId,
              enabled: selectedGroupId != null,
              onEventSelected: onEventSelected,
              onAddEvent: onAddEvent,
            ),
          ),
        ),
      ],
    );
  }
}
