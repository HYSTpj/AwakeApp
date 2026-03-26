import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/group_repository.dart';
import 'common_layout.dart';
import 'grouplist_page.dart';


class DeleteGroup extends StatefulWidget {
  const DeleteGroup({super.key});
  
  @override
  State<DeleteGroup> createState() => DeleteGroupState();
}

class DeleteGroupState extends State<DeleteGroup> {

  final _controller = TextEditingController();  // テキスト内の文字をリアルタイムで記録
  final User? user = FirebaseAuth.instance.currentUser; // 今ログイン中のユーザー情報を取得

  @override
  // メモリを解放するための関数
  void dispose() {
    _controller.dispose();  // _controller内を掃除
    super.dispose();  // 親クラスでも掃除
  }

  Future<void> _invitation() async {
    final invitationCode = _controller.text.trim(); // コピーした最後のスペースを削除
    final String uid = user?.uid ?? "no user"; // ユーザーid取得，ログインしてない場合のエラーも書く

    if (invitationCode.isNotEmpty && uid.isNotEmpty) {  // 招待コードとユーザーidが空でないとき
      try {
        await GroupRepository().deleteGroup(
          id: uid,
          group_id: invitationCode
        );

        if (!mounted) return; // もし画面が閉じられていればここで終了

        Navigator.push(context, MaterialPageRoute(  // 新しい画面へ進む
          builder: (context) => GroupList()
        ),);

        ScaffoldMessenger.of(context).showSnackBar( // スナックバーにメッセージを表示
          const SnackBar(
            content: Text('Deleted the group')
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar( // スナックバーにメッセージを表示
          SnackBar(
            content: Text('$e')
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar( // スナックバーにメッセージを表示
        const SnackBar(
          content: Text('Please enter invitation code.')
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
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context); // createOrAddOrDeleteに戻る
                  print('1画面戻る');
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

            const Spacer(),

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
                  hintText: 'Enter invitation code', // うっすら文字
                  border: InputBorder.none, // 枠線
                  contentPadding: EdgeInsets.only(left: 15, top: 15),  // 余白
                ),
              ),
            ),

            const SizedBox(height: 50,),

            // グループ脱退ボタン
            SizedBox(
              width: 400,
              height: 80,
              child: ElevatedButton(
                onPressed: _invitation,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(fontSize: 24),
                )
              ),
            ),

            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
