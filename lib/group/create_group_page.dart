import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/services.dart'; // 招待コードをコピーするためにインポート

import '../../data/group_repository.dart';
import '../common_layout.dart';
import 'grouplist_page.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});
  
  @override
  State<CreateGroupPage> createState() => CreateGroupPageState();
}


class CreateGroupPageState extends State<CreateGroupPage> {

  final _controller = TextEditingController();  // テキスト内の文字をリアルタイムで記録
  final user = FirebaseAuth.instance.currentUser; // 今ログイン中のユーザー情報を取得

  @override
  // メモリを解放するための関数
  void dispose() {
    _controller.dispose();  // _controller内を掃除
    super.dispose();  // 親クラスでも掃除
  }

  Future<void> _newName() async {
    final newGroup = _controller.text.trim();

    // ログインチェック
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar( // スナックバーにログインするよう表示
        const SnackBar(content: Text('Please log in.')),
      );
      return;
    }

    if (newGroup.isNotEmpty) { // 入力されている時
      final String? newGroupId = await GroupRepository().setGroup(
        id: user.uid,
        groupName: newGroup
      );

      if (!mounted) return; // もし画面が閉じられていればここで終了

      if (newGroupId != null) { // group_idが作られたとき
        Navigator.push(context, MaterialPageRoute(  // 新しい画面へ進む
          builder: (context) => IdPage(
            groupId: newGroupId,  // 新しいIdPageでgroupIdとgroupNameを保持
            groupName: newGroup
          ),
        ),);
      }
    } else {  // 入力されていない時

      if (!mounted) return; // もし画面が閉じられていればここで終了

      ScaffoldMessenger.of(context).showSnackBar( // スナックバーにメッセージを表示
        const SnackBar(
          content: Text('Please enter a new group name.')
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(  // 共通レイアウトを使用

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [

            // 戻るボタン
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.topLeft, // 左上に表示
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
            ),

            const Spacer(), // スペースを開ける

            // 検索窓
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,  //背景色
                borderRadius: BorderRadius.circular(10),  // 角を丸く
              ),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Enter new group name', // うっすら文字
                  border: InputBorder.none, // 枠線
                  contentPadding: EdgeInsets.only(left: 15, top: 15),  // 余白
                ),
              ),
            ),

            const SizedBox(height: 50), // スペースを開ける

            // グループ新規作成ボタン
            SizedBox(
              width: 400,
              height: 80,
              child: ElevatedButton(
                onPressed: _newName,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Create',
                  style: TextStyle(fontSize: 24),
                )
              ),
            ),

            const Spacer(flex: 2),  // スペースを開ける
          ],
        ),
      ),
    );
  }
}

// 招待コード表示ページ
class IdPage extends StatelessWidget {  // 前のページから引数groupId, groupNameを受け取る
  final String groupId;
  final String groupName;

  const IdPage({
    super.key,
    required this.groupId,
    required this.groupName
  });

  @override
  Widget build(BuildContext context) {
    return CommonLayout(  // 共通レイアウトを使用
      body: Center(
        child: Column(  // 縦に並べる
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Created a new group', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('「$groupName」', style: TextStyle(fontSize: 18)), // 変数だからconstは消す
            const SizedBox(height: 10),
            const Text('invitation_code : ', style: TextStyle(fontSize: 18, color: Colors.grey)),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,  // 両端に追いやる
                children: [
                  Flexible(
                    child: SelectableText( // 長押しでコピーできるテキスト
                      groupId,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                  ),

                  const SizedBox(width: 20),  // スペースを開ける

                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: groupId));  // クリップボードに招待コードをコピー
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied the invitation code')),
                      );
                      debugPrint('招待コードをコピー');
                    },
                    child: const Icon(Icons.content_copy, color: Colors.black),
                  ),
                ],
              ),
            ),
            

            const SizedBox(height: 40), // スペースを開ける

            // grouplist_pageへ戻るボタン
            ElevatedButton(
              onPressed: () {
                // 今までの画面を全部消して戻る
                Navigator.pushReplacement(context, MaterialPageRoute(  // 新しい画面へ進む
                  builder: (context) => const GroupListPage(),
                ),);
                debugPrint('grouplistへ戻る');
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Return'),
            ),
          ],
        ),
      ),
    );
  }
}
