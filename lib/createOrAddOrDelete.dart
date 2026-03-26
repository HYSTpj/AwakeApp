import 'package:flutter/material.dart';

import 'common_layout.dart';
import 'create_group_page.dart';
import 'add_group_page.dart';
import 'delete_group_page.dart';

class CreateOrAdd extends StatefulWidget {
  const CreateOrAdd({super.key});
  
  @override
  State<CreateOrAdd> createState() => CreateOrAddState();
}

class CreateOrAddState extends State<CreateOrAdd> {

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
              alignment: Alignment.topLeft, // 左上に表示
              child: Container(
                margin: const EdgeInsets.only(top: 10, left: 10),
                width: 60,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green[900],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 25),
                  onPressed: () {
                    Navigator.pop(context); // grouplist_pageに戻る
                    print('1画面戻る');
                  },
                )
              )
            ),

            const Spacer(), // 真ん中に押し出す

            // グループ新規作成ボタン
            SizedBox(
              width: 400,
              height: 100,
              child: ElevatedButton(
                onPressed: () async {                                
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateGroup(),
                    ),
                  );
                  print('グループ作成画面へ移動');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Create group',
                  style: TextStyle(fontSize: 24),
                )
              ),
            ),

            const SizedBox(height: 50,),  // ボタン同士の隙間

            // グループ参加ボタン
            SizedBox(
              width: 400,
              height: 100,
              child: ElevatedButton(
                onPressed: () {                
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddGroup(),
                    ),
                  );
                  print('グループ参加画面へ移動');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Add group',
                  style: TextStyle(fontSize: 24),
                )
              ),
            ),

            const SizedBox(height: 50,),  // ボタン同士の隙間

            // グループ脱退ボタン
            SizedBox(
              width: 400,
              height: 100,
              child: ElevatedButton(
                onPressed: () {                
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeleteGroup(),
                    ),
                  );
                  print('グループ脱退画面へ移動');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Delete group',
                  style: TextStyle(fontSize: 24),
                )
              ),
            ),

            const Spacer(), // 真ん中に押し出す
          ],
        )
      ),
    );
  }
}
