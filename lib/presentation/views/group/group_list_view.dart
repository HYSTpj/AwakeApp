import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 招待コードをコピーするためにインポート
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/group_repository.dart';
import '../../../../models/group.dart';
import '../../viewmodels/group_view_model.dart';
import '../../../common_layout.dart';
import 'create_add_delete_view.dart';
import '../event/admin/event_list_view.dart'; // イベント一覧表示画面

// グループリストページ
class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  late final GroupViewModel _viewModel;
  bool _isLocalViewModel = false;
  String? selectedGroupId;

  // 初期化
  @override
  void initState() {
    super.initState();

    // 祖先ツリーに GroupViewModel が提供されているか確認し、なければ生成する
    final parentViewModel = context.read<GroupViewModel?>();
    if (parentViewModel != null) {
      _viewModel = parentViewModel;
    } else {
      _viewModel = GroupViewModel(
        SupabaseGroupRepository(Supabase.instance.client),
      );
      _isLocalViewModel = true;
    }

    _viewModel.addListener(_onViewModelUpdated);
    _viewModel.loadGroups();
  }

  @override
  // メモリを解放するための関数
  void dispose() {
    _viewModel.removeListener(_onViewModelUpdated);
    if (_isLocalViewModel) {
      _viewModel.dispose(); // _controller内を掃除
    }
    super.dispose();
  }

  void _onViewModelUpdated() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // エラーメッセージを表示
    if (_viewModel.state.errorMessage != null) {
      final message = _viewModel.state.errorMessage!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        _viewModel.clearError(); // 表示後クリア
      });
    }

    final groups = _viewModel.state.groups;
    final isLoading = _viewModel.state.isLoading;

    return CommonLayout(
      // 共通レイアウトを使用
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              // 垂直に並べる
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedGroupId,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 28),
                      hint: const Text(
                        'GROUP NAME',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1C1C),
                          letterSpacing: 0.5,
                        ),
                      ),
                      items: [
                        ...groups.map((Group group) {
                          return DropdownMenuItem<String>(
                            value: group.id,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  group.groupName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1C1C),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                // コピーアイコンのタップ処理（invitationCode に変更）
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: group.invitationCode));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('copied the invitation code')),
                                    );
                                  },
                                  child: const Icon(Icons.content_copy, color: Colors.black, size: 20),
                                ),
                              ],
                            ),
                          );
                        }),
                        // 管理用メニューの項目
                        const DropdownMenuItem<String>(
                          value: 'create_add_delete',
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'CREATE OR ADD OR DELETE',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFF5C00),
                                ),
                              ),
                              Icon(Icons.add_box, color: Color(0xFFFF5C00)),
                            ],
                          ),
                        ),
                      ],
                      // DropdownButton の onChanged 処理
                      onChanged: (String? value) async {
                        if (value == null) return;

                        if (value == 'create_add_delete') {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateOrAddOrDeletePage(),
                            ),
                          );

                          // 削除・作成・参加から戻ってきたら一覧を再取得
                          if (result == true) {
                            await _viewModel.loadGroups();
                            setState(() {
                              selectedGroupId = null; // 選択状態をリセット
                            });
                          }
                        } else {
                          setState(() {
                            selectedGroupId = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
                // それぞれのイベント一覧表示画面へ移動
                Expanded(
                  child: selectedGroupId == null
                      ? const Center(
                          child: Text('Select group'),
                        ) // グループが選ばれていない時
                      : EventListPage(
                          groupId: selectedGroupId!,
                        ), // グループが選ばれている時
                ),
              ],
            ),
    );
  }
}