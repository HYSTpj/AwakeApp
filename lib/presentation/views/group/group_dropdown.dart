import 'package:flutter/material.dart';

import '../../../../models/group.dart';

/// グループ名だけを表示・選択する共通ドロップダウン。
///
/// 「GROUP NAME」ヒント表示、グループ一覧、
/// 「CREATE OR ADD OR DELETE」特殊項目を表示する。選択中グループが現在の
/// [groups]に存在しない場合は自動的に未選択表示にフォールバックする。
class GroupDropdown extends StatelessWidget {
  const GroupDropdown({
    super.key,
    required this.groups,
    required this.selectedGroupId,
    this.onGroupSelected,
    this.onCreateAddDelete,
  });

  final List<Group> groups;
  final String? selectedGroupId;
  final ValueChanged<Group>? onGroupSelected;
  final VoidCallback? onCreateAddDelete;

  @override
  Widget build(BuildContext context) {
    final dropdownValue = groups.any((g) => g.id == selectedGroupId)
        ? selectedGroupId
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
          // グループ名が2行に折り返しても項目が高さ48pxにクリップされないよう、
          // 項目の実コンテンツに応じた可変高さにする。
          itemHeight: null,
          // ボタン自体は横並びの半分幅だが、選択肢一覧は画面幅いっぱいに
          // 広げて見やすくする（左右のマージン24pxずつを差し引く）。
          menuWidth: MediaQuery.of(context).size.width - 48,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black,
            size: 24,
          ),
          hint: const Text(
            'GROUP NAME',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1C1C),
              letterSpacing: 0.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          items: [
            ...groups.map((Group group) {
              return DropdownMenuItem<String>(
                value: group.id,
                child: Text(
                  group.groupName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1C1C),
                    letterSpacing: 0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
            const DropdownMenuItem<String>(
              value: 'create_add_delete',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CREATE OR ADD OR DELETE',
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
          onChanged: (String? value) {
            if (value == null) return;

            if (value == 'create_add_delete') {
              onCreateAddDelete?.call();
              return;
            }

            final group = groups.firstWhere((g) => g.id == value);
            onGroupSelected?.call(group);
          },
        ),
      ),
    );
  }
}
