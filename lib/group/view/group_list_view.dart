import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // 招待コードをコピーするためにインポート
import 'package:flutter_application_1/group/domain/group_entity.dart';

import '../data/group_data.dart';
import '../view_model/group_view_model.dart';
import '../../common_layout.dart';
import 'create_add_delete_view.dart';
import '../../event/view/event_list_view.dart'; // イベント一覧表示画面できたらインポート
import '../../event_selection_home.dart';

/// グループリストページ
class GroupListPage extends StatefulWidget {
  final String? initialGroupId;

  const GroupListPage({super.key, this.initialGroupId});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  final repository = GroupRepositoryImpl();
  late final viewModel = GroupListViewModel(repository);

  final user = FirebaseAuth.instance.currentUser; // 今ログイン中のユーザー情報を取得

  String? selectedGroupId;
  int? myRole;

  // 初期化
  @override
  void initState() {
    super.initState();

    viewModel.addListener(_onViewModelUpdated);
    _initializeScreen();
  }

  // 初期化時にグループIDが引き継がれていたら自動ロードする処理
  Future<void> _initializeScreen() async {
    if (user != null) {
      await viewModel.getGroups(user!.uid);
    }
    
    // 利用者画面からグループIDが渡されてきていたら、自動でそのグループをセットする
    if (widget.initialGroupId != null && mounted) {
      final String uid = user?.uid ?? "";
      final int? role = await repository.getRole(id: uid, groupId: widget.initialGroupId!);
      
      setState(() {
        selectedGroupId = widget.initialGroupId;
        myRole = role;
      });
      debugPrint("利用者画面からグループ $selectedGroupId (役割: $myRole) を引き継ぎ");
    }
  }

  @override
  // メモリを解放するための関数
  void dispose() {
    viewModel.removeListener(_onViewModelUpdated);
    viewModel.dispose();  // _controller内を掃除
    super.dispose();  // 親クラスでも掃除
  }

  void _onViewModelUpdated() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // エラーメッセージを表示
    if (viewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.errorMessage!)),
        );
        viewModel.errorMessage = null; // 表示後クリア
      });
    }

    return CommonLayout(
      // 共通レイアウトを使用
      groupId: selectedGroupId,
      myRole: myRole,
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator()) // ロード中はくるくるを出す
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
                        ...viewModel.groups.map((GroupEntity group) {
                          return DropdownMenuItem<String>(
                            value: group.groupId,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  group.groupName, // 統一感を出すために大文字化
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1C1C),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: group.groupId));
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
                        DropdownMenuItem<String>(
                          value: 'create_add_delete',
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'CREATE OR ADD OR DELETE',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFF5C00), // オレンジのアクセント
                                ),
                              ),
                              Icon(Icons.add_box, color: Color(0xFFFF5C00)),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (String? value) async {
                        if (value == null) return;
                        if (value == 'create_add_delete') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CreateOrAddOrDeletePage()),
                          );
                        } else {

                          final String uid = user?.uid ?? "";

                          // myGroupsから選択されたグループのデrータを探す
                          final int? role = await repository.getRole(id: uid, groupId: value);

                          if (!context.mounted) return;

                          if (role == 1) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventSelectionHome(groupId: value),
                              ),
                            );
                            return;
                          }

                          setState(() {
                            selectedGroupId = value;
                            myRole = role;
                          });

                          debugPrint("グループ $value (役割: $myRole) を選択");
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
                      : EventListPage(groupId: selectedGroupId!, myRole: myRole!) // 管理者
                ),
              ],
            ),
    );
  }
}