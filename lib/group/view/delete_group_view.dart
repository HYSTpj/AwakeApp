import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/group_data.dart';
import '../view_model/group_view_model.dart';
import '../../common_layout.dart';
import 'return_button.dart';
import 'group_list_view.dart';

/// グループ脱退ページ
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

  bool _isLoading = false; // 削除処理中のフラグ

  @override
  // メモリを解放するための関数
  void dispose() {
    _controller.dispose();  // _controller内を掃除
    super.dispose();  // 親クラスでも掃除
  }

  /// グループ脱退処理
  Future<void> _deleteGroup() async {
    final groupId = _controller.text.trim();
    if (groupId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your group ID.')),
      );
      return;
    }

    // 確認ダイアログを表示
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('confirmation'),
        content: const Text('Are you really going to leave this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // ログインチェック
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar( // スナックバーにログインするよう表示
        const SnackBar(content: Text('Please log in.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await viewModel.deleteGroup(user.uid, groupId);

      if (!mounted) return;
      
      if (success) {
        Navigator.push(context, MaterialPageRoute(  // 新しい画面へ進む
          builder: (context) => const GroupListPage()
        ),);

        ScaffoldMessenger.of(context).showSnackBar( // スナックバーにメッセージを表示
          const SnackBar(
            content: Text('You have left the group.')
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar( // スナックバーにメッセージを表示
          SnackBar(
            content: Text(viewModel.errorMessage ?? 'An error has occurred.')
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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

  // グループ削除ボタン
  Widget _deleteButton() {
    return SizedBox(
      width: 400,
      height: 80,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _deleteGroup, // ローディング中は無効
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator() // ローディングインジケーター
            : const Text(
                'Delete',
                style: TextStyle(fontSize: 24),
              ),
      ),
    );
  }
}