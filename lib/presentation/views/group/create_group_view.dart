import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../data/repositories/group_repository.dart';
import '../../viewmodels/group_view_model.dart';
import '../../../../../common_layout.dart';
import '../../../widgets/return_button.dart';

/// グループ作成ページ
class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  late final GroupViewModel _viewModel;
  bool _isLocalViewModel = false;

  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 祖先ツリーから GroupViewModel を取得、なければローカルで生成
    final parentViewModel = context.read<GroupViewModel?>();
    if (parentViewModel != null) {
      _viewModel = parentViewModel;
    } else {
      _viewModel = GroupViewModel(
        SupabaseGroupRepository(Supabase.instance.client),
      );
      _isLocalViewModel = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_isLocalViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  /// グループ作成処理
  Future<void> _newName() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter group name.')),
      );
      return;
    }

    // Supabase のログインチェック
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar( // スナックバーにログインするよう表示
        const SnackBar(content: Text('Please log in.')),
      );
      return;
    }

    final success = await _viewModel.createGroup(name);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Created a new group.')),
      );
      // 作成完了後は一覧まで戻る
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      final errorMsg = _viewModel.state.errorMessage ?? 'An error has occurred.';
      ScaffoldMessenger.of(context).showSnackBar( // スナックバーにメッセージを表示
        SnackBar(content: Text(errorMsg)),
      );
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

            const SizedBox(height: 50),

            // グループ作成ボタン
            _createButton(),

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
        color: Colors.white, // 背景色
        borderRadius: BorderRadius.circular(10), // 角を丸く
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Enter new group name', // うっすら文字
          border: InputBorder.none, // 枠線
          contentPadding: EdgeInsets.only(left: 15, top: 15), // 余白
        ),
      ),
    );
  }

  // グループ作成ボタン
  Widget _createButton() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final isLoading = _viewModel.state.isLoading;

        return SizedBox(
          width: 400,
          height: 80,
          child: ElevatedButton(
            onPressed: isLoading ? null : _newName, // ローディング中は無効
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.black, width: 2),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator() // ローディングインジケーター
                : const Text(
                    'Create',
                    style: TextStyle(fontSize: 24),
                  ),
          ),
        );
      },
    );
  }
}