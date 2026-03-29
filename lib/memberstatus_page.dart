import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/event_repository.dart';

class MemberStatusPage extends StatefulWidget {

  final String eventId;
  final String eventTitle;

  const MemberStatusPage({
    super.key,
    required this.eventId,
    required this.eventTitle
  });
  
  @override
  State<MemberStatusPage> createState() => MemberStatusPageState();
}

class MemberStatusPageState extends State<MemberStatusPage> {

  final user = FirebaseAuth.instance.currentUser; // 今ログイン中のユーザー情報を取得

  // ステータスボタン定義
  Widget _statusButton(String label, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: SizedBox(
        height: 40,
        width: 80,
        child: ElevatedButton.icon(
          onPressed: () {
            /*
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (contet) => ShowQrcodePage(),
                ),
              ),
            );
            */
            debugPrint('$labelを表示');
          },
          icon: Icon(icon, color: iconColor),
          label: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold
            )
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
              side: const BorderSide(color: Colors.black, width: 1)
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final String uid = user?.uid ?? "no user"; // ユーザーid取得，ログインしてない場合のエラーも書く

    return  FutureBuilder<List<dynamic>> ( // 作業終わるまで置き換えておく画面作成
      future: Future.wait([
        EventRepository().getEventMembers(widget.eventId)  // イベントメンバーを取得する予約
      ]),
      builder: (context, snapshot) {  // 状況(snapshot)に合わせて作る画面作成

        if(snapshot.connectionState == ConnectionState.waiting) { // 待ち状態のとき
          return const Center(child: CircularProgressIndicator());  // 読み込み中のくるくる表示
        }

        if (snapshot.hasError) {  // エラーのとき
          return Center(child: Text('${snapshot.error}'));
        }
        
        // 取得し終わったとき
        final List<dynamic> eventMembers = (snapshot.data != null && snapshot.data!.isNotEmpty)
          ? snapshot.data![0] as List<dynamic>
          : [];

        return Column(
          children: [
            // QR code表示ボタン
            Padding(
              padding: const EdgeInsets.all(15),
              child: SizedBox(
                height: 80,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    /*
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (contet) => ShowQrcodePage(),
                        ),
                      ),
                    );
                    */
                    debugPrint('QRコード表示ページへ移動');
                  },
                  icon: const Icon(Icons.qr_code_2, color: Colors.black),
                  label: const Text(
                    'SHOW QR CODE',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25
                    )
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                      side: const BorderSide(color: Colors.black, width: 2)
                    ),
                  ),
                ),
              ),
            ),


            // ステータス選択ボタン
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  _statusButton('ALL MEMBERS', Icons.filter_list, Colors.deepOrangeAccent),
                  _statusButton('0: SLEEPING', Icons.circle, Colors.grey),
                  _statusButton('1: AWAKE', Icons.circle, Colors.greenAccent),
                  _statusButton('2: OVERSLEPT', Icons.circle, Colors.pinkAccent),
                  _statusButton('3: MOVING', Icons.circle, Colors.lightBlueAccent),
                  _statusButton('4: ARRIVED', Icons.circle, Colors.orangeAccent),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // メンバー一覧
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Text(
                    "MEMBER'S STATUS",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                  Spacer(),

                  // 何人起きてるか
                ],
              ),
            ),



            // メンバー一覧
            Expanded(
              child: eventMembers.isEmpty
              ? const Center(child: Text('No event member found for this group.'))  // イベントメンバーがいないの時
              : ListView.builder( // イベントメンバーがいる時
                itemCount: eventMembers.length,  // いくつ表示するか
                itemBuilder: (context, index) {

                  final member = eventMembers[index] as Map<String, dynamic>? ?? {};

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5
                    ),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2)
                    ),

                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white)
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Text(
                            member['nickname'] ?? 'No name',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        ),

                        Container (
                          padding: const EdgeInsets.all(5),
                          color: Colors.greenAccent,
                          child: const Text('AWAKE'),
                        )
                      ],
                    ),
                  );
                }
              )
            )

          ],
        );
      }
    );
  }
}