import 'package:flutter/material.dart';

import '../../common_layout.dart';
import '../../return_button.dart';
import 'create_group_view.dart';
import 'add_group_view.dart';
import 'delete_group_view.dart';

/// グループ作成、参加、脱退を選択するページ
class CreateOrAddOrDeletePage extends StatelessWidget {
  const CreateOrAddOrDeletePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonLayout(  // 共通レイアウトを使用
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 戻るボタン
              ReturnButton(onTap: () {
                Navigator.pop(context);
                debugPrint('1画面戻る');
              }),

              // 余白
              const SizedBox(height: 40), 

              // グループ新規作成ボタン
              _createButton(context),

              const SizedBox(height: 32),

              // グループ参加ボタン
              _addButton(context),

              const SizedBox(height: 32),

              // グループ脱退ボタン
              _deleteButton(context),

              const SizedBox(height: 40), 
            ],
          ),
        ),
      ),
    );
  }

  /// 共通のボタンスタイル
  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.black, width: 2),
      ),
    );
  }

  // グループ作成ボタン
  Widget _createButton(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 100,
      child: ElevatedButton(
        onPressed: () {                                
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateGroupPage(),
            ),
          );
          debugPrint('グループ作成画面へ移動');
        },
        style: _buttonStyle(),
        child: const Text(
          'Create group',
          style: TextStyle(fontSize: 24),
        )
      ),
    );
  }

  // グループ参加ボタン
  Widget _addButton(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 100,
      child: ElevatedButton(
        onPressed: () {                
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddGroupPage(),
            ),
          );
          debugPrint('グループ参加画面へ移動');
        },
        style: _buttonStyle(),
        child: const Text(
          'Add group',
          style: TextStyle(fontSize: 24),
        )
      ),
    );
  }

  // グループ脱退ボタン
  Widget _deleteButton(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 100,
      child: ElevatedButton(
        onPressed: () {                
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DeleteGroupPage(),
            ),
          );
          debugPrint('グループ脱退画面へ移動');
        },
        style: _buttonStyle(),
        child: const Text(
          'Delete group',
          style: TextStyle(fontSize: 24),
        )
      ),
    );
  }
}