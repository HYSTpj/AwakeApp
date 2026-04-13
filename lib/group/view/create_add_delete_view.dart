import 'package:flutter/material.dart';

import '../../common_layout.dart';
import 'create_group_view.dart';
import 'add_group_view.dart';
import 'delete_group_view.dart';

class CreateOrAddOrDeletePage extends StatelessWidget {
  const CreateOrAddOrDeletePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonLayout(  // 共通レイアウトを使用
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [

            // 戻るボタン
            _returnButton(context),

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

  // 戻るボタン
  Widget _returnButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Align(
        alignment: Alignment.topLeft,
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context); // createOrAddOrDeleteに戻る
            debugPrint('1画面戻る');
          },
          child: Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green[900],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(Icons.arrow_back, color: Colors.white, size: 25),
            )
          )
        ),
      )
    );
  }

  // グループ作成ボタン
  Widget _createButton(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 100,
      child: ElevatedButton(
        onPressed: () async {                                
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateGroupPage(),
            ),
          );
          debugPrint('グループ作成画面へ移動');
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Delete group',
          style: TextStyle(fontSize: 24),
        )
      ),
    );
  }
}
