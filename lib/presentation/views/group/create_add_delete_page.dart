import 'package:flutter/material.dart';

import '../../../../common_layout.dart';
import '../../../widgets/return_button.dart';
import '../login/common_effects.dart';
import 'create_group_page.dart';
import 'add_group_page.dart';
import 'delete_group_page.dart';

const _kDangerRed = Color(0xFFF26A63);

/// グループ作成、参加、脱退を選択するページ
class CreateOrAddOrDeletePage extends StatelessWidget {
  const CreateOrAddOrDeletePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonLayout(  // 共通レイアウトを使用
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 16),
            // 戻るボタン
            ReturnButton(onTap: () {
              Navigator.pop(context);
              debugPrint('1画面戻る');
            }),

            const Spacer(), // 真ん中に押し出す

            // グループ新規作成ボタン
            _createButton(context),

            const SizedBox(height: 50,),  // ボタン同士の隙間

            // グループ参加ボタン
            _addButton(context),

            const SizedBox(height: 50,),  // ボタン同士の隙間

            // グループ脱退ボタン
            _deleteButton(context),

            const Spacer(), // 真ん中に押し出す
          ],
        )
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    const size = Size(400, 100);
    return Container(
      width: size.width,
      height: size.height,
      decoration: hardShadowDecoration(color: backgroundColor),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: size,
          padding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 24, color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // グループ作成ボタン
  Widget _createButton(BuildContext context) {
    return _actionButton(
      context,
      label: 'Create group',
      backgroundColor: kBrandOrange,
      textColor: Colors.white,
      onPressed: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateGroupPage(),
          ),
        );

        // 削除が成功して戻ってきた場合、この選択画面も閉じて一覧画面へ戻る
        if (result == true && context.mounted) {
          Navigator.pop(context, true);
        }
        debugPrint('グループ作成画面へ移動');
      },
    );
  }

  // グループ参加ボタン
  Widget _addButton(BuildContext context) {
    return _actionButton(
      context,
      label: 'Add group',
      backgroundColor: Colors.white,
      textColor: Colors.black,
      onPressed: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => const AddGroupPage(),
          ),
        );

        // 削除が成功して戻ってきた場合、この選択画面も閉じて一覧画面へ戻る
        if (result == true && context.mounted) {
          Navigator.pop(context, true);
        }
        debugPrint('グループ参加画面へ移動');
      },
    );
  }

  // グループ脱退ボタン
  Widget _deleteButton(BuildContext context) {
    return _actionButton(
      context,
      label: 'Delete group',
      backgroundColor: _kDangerRed,
      textColor: Colors.white,
      onPressed: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => const DeleteGroupPage(),
          ),
        );

        // 削除が成功して戻ってきた場合、この選択画面も閉じて一覧画面へ戻る
        if (result == true && context.mounted) {
          Navigator.pop(context, true);
        }
      },
    );
  }
}