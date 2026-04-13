import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/group_data.dart';
import '../view_model/group_view_model.dart';
import '../../common_layout.dart';
import 'group_list_view.dart';


class DeleteGroupPage extends StatefulWidget {
  const DeleteGroupPage({super.key});
  
  @override
  State<DeleteGroupPage> createState() => _DeleteGroupPageState();
}

class _DeleteGroupPageState extends State<DeleteGroupPage> {

  final repository = GroupRepositoryImpl();
  late final viewModel = DeleteGroupViewModel(repository);

  final _controller = TextEditingController();  // テキスト内の文字をリアルタイムで記録
  final user = FirebaseAuth.instance.currentUser; // 今ログイン中のユーザー情報を取得

  @override
  // メモリを解放するための関数
  void dispose() {
    _controller.dispose();  // _controller内を掃除
    super.dispose();  // 親クラスでも掃除
  }

  Future<void> _deleteGroup() async {

    // ログインチェック
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar( // スナックバーにログインするよう表示
        const SnackBar(content: Text('Please log in.')),
      );
      return;
    }

    final success = await viewModel.deleteGroup(
      user.uid, 
      _controller.text.trim()
    );

    if (!mounted) return;
    
    if (success) {
      Navigator.push(context, MaterialPageRoute(  // 新しい画面へ進む
        builder: (context) => const GroupListPage()
      ),);

      ScaffoldMessenger.of(context).showSnackBar( // スナックバーにメッセージを表示
        const SnackBar(
          content: Text('Deleted the group')
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar( // スナックバーにメッセージを表示
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Error')
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
            _returnButton(),

            const Spacer(),

            // 検索窓
            _searchBox(),

            const SizedBox(height: 50,),

            // グループ削除ボタン
            _deleteButton(),

            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  // 戻るボタン
  Widget _returnButton() {
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

  // 検索窓
  Widget _searchBox() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,  //背景色
        borderRadius: BorderRadius.circular(10),  // 角を丸く
      ),
      child: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Enter groupID to leave', // うっすら文字
          border: InputBorder.none, // 枠線
          contentPadding: EdgeInsets.only(left: 15, top: 15),  // 余白
        ),
      ),
    );
  }

  // グループ作成ボタン
  Widget _deleteButton() {
    return SizedBox(
      width: 400,
      height: 80,
      child: ElevatedButton(
        onPressed: _deleteGroup,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
        child: const Text(
          'Delete',
          style: TextStyle(fontSize: 24),
        )
      ),
    );
  }
}
