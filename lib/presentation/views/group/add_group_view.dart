import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/group_repository.dart';
import '../../viewmodels/group_view_model.dart';
import '../../../../../common_layout.dart';
import '../../../widgets/return_button.dart';

/// グループ参加ページ
class AddGroupPage extends StatefulWidget {
  const AddGroupPage({super.key});

  @override
  State<AddGroupPage> createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  late final GroupViewModel _viewModel;
  bool _isLocalViewModel = false;

  final _controller = TextEditingController(); // テキスト内の文字をリアルタイムで記録

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
  // メモリを解放するための関数
  void dispose() {
    _controller.dispose();
    if (_isLocalViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  /// グループ参加処理
  Future<void> _invitation() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your invitation code.')),
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

    final success = await _viewModel.joinGroupByCode(code);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar( // スナックバーにメッセージを表示
        const SnackBar(content: Text('Joined the group.')),
      );
      // 参加完了後は一覧画面まで戻る
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

            // グループ参加ボタン
            _addButton(),

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Enter invitation code',
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(left: 15, top: 15),
        ),
      ),
    );
  }

  // グループ参加ボタン
  Widget _addButton() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final isLoading = _viewModel.state.isLoading;

        return SizedBox(
          width: 400,
          height: 80,
          child: ElevatedButton(
            onPressed: isLoading ? null : _invitation,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.black, width: 2),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text(
                    'Add',
                    style: TextStyle(fontSize: 24),
                  ),
          ),
        );
      },
    );
  }
}