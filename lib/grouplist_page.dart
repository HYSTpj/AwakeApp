import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/services.dart'; // 招待コードをコピーするためにインポート

import '../data/group_repository.dart';
import 'common_layout.dart';
import 'create_add_delete.dart';
// import 'eventlise_page.dart';  // イベント一覧表示画面できたらインポート

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});
  
  @override
  State<GroupListPage> createState() => GroupListPageState();
}

class GroupListPageState extends State<GroupListPage> {

  final user = FirebaseAuth.instance.currentUser; // 今ログイン中のユーザー情報を取得

  String? selectedGroup;  // 今選択中のグループ

  @override
  Widget build(BuildContext context) {

    final String uid = user?.uid ?? "no user"; // ユーザーid取得，ログインしてない場合のエラーも書く

    return CommonLayout(  // 共通レイアウトを使用

      body: FutureBuilder<List<Map<String, dynamic>>> ( // 作業終わるまで置き換えておく画面作成
        future: GroupRepository().getGroups(uid),  // グループリストを作る予約
        builder: (context, snapshot) {  // 状況(snapshot)に合わせて作る画面作成

          if(snapshot.connectionState == ConnectionState.waiting) { // 待ち状態のとき
            return const Center(child: CircularProgressIndicator());  // 読み込み中のくるくる表示
          }

          if (snapshot.hasError) {  // エラーのとき
            return Center(child: Text('${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {  // データが届かないor空のとき
            return const Center(child: Text('You do not belong to any group.'));
          }
          
          // 取得し終わったとき
          final myGroups = snapshot.data!;

          return Column(  // 垂直に並べる
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
                  child: DropdownButtonHideUnderline( // ドロップダウンの下線削除
                    child: DropdownButton<String>(

                      value: selectedGroup, // 今どのグループが選択されているか
                      isExpanded: true, // 横幅広げる
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),

                      // グループが選択されていない時に表示されるテキスト
                      hint: const Text(
                        'Select group',
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),

                      items: myGroups.map((group) { // myGroupsリストから一つずつgroupを取り出す
                        return DropdownMenuItem<String> (
                          value: group['group_name'] ?? 'unnamed group',  // グループ名を取得，空の場合も指定
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,  // 両端に追いやる
                            children: [
                              Text(
                                group['group_name'] ?? 'unnamed group',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: group['invitation_code'] ?? ""));  // クリップボードに招待コードをコピー
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('copied the invitation code')),
                                  );
                                  debugPrint('招待コードをコピー');
                                },
                                child: const Icon(Icons.content_copy, color: Colors.black),
                              ),
                            ],
                          ),
                        );
                      }).toList(),  // リストに連結

                      onChanged: (String? newGroup) { // グループが選ばれたとき
                        if (newGroup == null) return;

                        setState(() {
                          selectedGroup = newGroup;
                        });

                        debugPrint('$newGroupのイベント一覧へ移動');
                      },
                    ),
                  ),
                ),
              ),

              /*
              // それぞれのイベント一覧表示画面へ移動
              Expanded(
                child: selectedGroup == null
                  ? const Center(child: Text('Select group'))
                  : EventListPage(groupName: selectedGroup!),
              ),
              */
            ],
          );      
        },
      ),

      // グループ新規作成か新しく参加するためのボタン
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[900],
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const CreateOrAddOrDeletePage()),
          );
          debugPrint('作成or参加画面へ移動');
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
