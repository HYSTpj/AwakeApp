import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../data/repositories/group_repository.dart';
import '../../viewmodels/group_view_model.dart';
import '../../../../../common_layout.dart';
import '../../../widgets/return_button.dart';

/// グループ脱退ページ
class DeleteGroupPage extends StatefulWidget {
  const DeleteGroupPage({super.key});

  @override
  State<DeleteGroupPage> createState() => _DeleteGroupPageState();
}

class _DeleteGroupPageState extends State<DeleteGroupPage> {
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

    // Supabase のログインチェック
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in.')),
      );
      return;
    }

    final success = await _viewModel.deleteOrLeaveGroup(groupId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have left the group.')),
      );
      // true を返して選択画面に戻る
      Navigator.pop(context, true);
    } else {
      final errorMsg = _viewModel.state.errorMessage ?? 'An error has occurred.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Enter invitation code to leave',
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(left: 15, top: 15),
        ),
      ),
    );
  }

  // グループ削除ボタン
  Widget _deleteButton() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final isLoading = _viewModel.state.isLoading;

        return SizedBox(
          width: 400,
          height: 80,
          child: ElevatedButton(
            onPressed: isLoading ? null : _deleteGroup,
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
                    'Delete',
                    style: TextStyle(fontSize: 24),
                  ),
          ),
        );
      },
    );
  }
}