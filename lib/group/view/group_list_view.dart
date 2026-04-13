import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // 招待コードをコピーするためにインポート
import 'package:flutter_application_1/group/domain/group_entity.dart';

import '../data/group_data.dart';
import '../view_model/group_view_model.dart';
import '../../common_layout.dart';
import 'create_add_delete_view.dart';
import '../../eventlist_page.dart'; // イベント一覧表示画面できたらインポート

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  final repository = GroupRepositoryImpl();
  late final viewModel = GroupListViewModel(repository);

  final user = FirebaseAuth.instance.currentUser; // 今ログイン中のユーザー情報を取得

  String? selectedGroupId;

  // 初期化
  @override
  void initState() {
    super.initState();

    viewModel.addListener(_onViewModelUpdated);
    if (user != null) {
      viewModel.getGroups(user!.uid);
    }
  }

  void _onViewModelUpdated() {
    if (mounted) setState(() {});
  } 

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      // 共通レイアウトを使用
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator()) // ロード中はくるくるを出す
          : Column(
              // 垂直に並べる
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: DropdownButtonHideUnderline(
                      // ドロップダウンの下線削除
                      child: DropdownButton<String>(
                        value: selectedGroupId, // 今どのグループが選択されているか
                        isExpanded: true, // 横幅広げる
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.black,
                        ),

                        // グループが選択されていない時に表示されるテキスト
                        hint: const Text(
                          'Select group',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        items: [
                          // items:[... ]でリスト連結
                          ...viewModel.groups.map((GroupEntity group) {
                            // myGroupsリストから一つずつgroupを取り出す
                            return DropdownMenuItem<String>(
                              value: group.groupId, // グループIDを取得，空の場合も指定
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween, // 両端に追いやる
                                children: [
                                  Text(
                                    group.groupName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(
                                        ClipboardData(text: group.groupId),
                                      ); // クリップボードに招待コードをコピー
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'copied the invitation code',
                                          ),
                                        ),
                                      );
                                      debugPrint('招待コードをコピー');
                                    },
                                    child: const Icon(
                                      Icons.content_copy,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const DropdownMenuItem<String>(
                            // ドロップダウンにcreate_add_deleteページ移動追加
                            value: 'create_add_delete',
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween, // 両端に追いやる
                              children: [
                                Text('Create or Add or Delete group'),
                                SizedBox(width: 10),
                                Icon(
                                  Icons.add_box,
                                  color: Colors.deepOrangeAccent,
                                ),
                              ],
                            ),
                          ),
                        ],

                        onChanged: (String? value) {
                          // グループが選ばれたとき
                          if (value == null) return;

                          if (value == 'create_add_delete') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CreateOrAddOrDeletePage(),
                              ),
                            );
                            debugPrint('作成or参加or脱退画面へ移動');
                          } else {
                            setState(() {
                              selectedGroupId = value;
                            });

                            debugPrint('$valueのイベント一覧へ移動');
                          }
                        },
                      ),
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
