import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/event_repository.dart';
import 'qrcode_page.dart';
import 'memberpost_page.dart';

class MemberStatusPage extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final String arrivalTime;
  final String password;

  const MemberStatusPage({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.arrivalTime,
    required this.password,
  });

  @override
  State<MemberStatusPage> createState() => _MemberStatusPageState();
}

class _MemberStatusPageState extends State<MemberStatusPage> {
  // privateに設定

  final user = FirebaseAuth.instance.currentUser; // 今ログイン中のユーザー情報を取得

  int? selectedFilter; // 今選択されているフィルター

  late Future<List<dynamic>> _membersFuture;
  @override
  void initState() {
    super.initState();
    _membersFuture = EventRepository().getEventMembers(
      widget.eventId,
    ); // 最初に一度だけデータを取得しにいく
  }

  // ステータスボタン定義
  Widget _statusButton(
    String label,
    IconData icon,
    Color iconColor,
    int? filterValue,
  ) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: SizedBox(
        height: 40,
        width: 126,
        child: ElevatedButton.icon(
          // 押したボタンのステータス状態の人を表示
          onPressed: () {
            setState(() {
              selectedFilter = filterValue;
            });
            debugPrint('$labelを表示');
          },
          icon: Icon(icon, color: iconColor, size: 10),
          label: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
              side: const BorderSide(color: Colors.black, width: 1),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      // 作業終わるまで置き換えておく画面作成
      future: _membersFuture, // アプリが重くならないように通信量を減らす
      builder: (context, snapshot) {
        // 状況(snapshot)に合わせて作る画面作成

        if (snapshot.connectionState == ConnectionState.waiting) {
          // 待ち状態のとき
          return const Center(
            child: CircularProgressIndicator(),
          ); // 読み込み中のくるくる表示
        }

        if (snapshot.hasError) {
          // エラーのとき
          return Center(child: Text('${snapshot.error}'));
        }

        // 取得し終わったとき
        final List<dynamic> eventMembers =
            (snapshot.data != null && snapshot.data!.isNotEmpty)
            ? snapshot.data!
            : [];

        final List<dynamic> filterMembers = selectedFilter == null
            ? eventMembers // フィルター未選択のとき全員表示
            : eventMembers
                  .where((m) => m['status'] == selectedFilter)
                  .toList(); // 選択されたフィルターと同じ値のstatusの人をリスト化

        final int all = eventMembers.length; // イベントメンバー人数
        final int arrived = eventMembers
            .where((m) => m['status'] == 4)
            .length; // イベントメンバーの内到着済み人数

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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QrcodePage(
                          eventId: widget.eventId,
                          eventTitle: widget.eventTitle,
                          arrivalTime: widget.arrivalTime,
                          password: widget.password,
                        ),
                      ),
                    );
                    debugPrint('QRコード表示ページへ移動');
                  },
                  icon: const Icon(
                    Icons.qr_code_2,
                    color: Colors.black,
                    size: 25,
                  ),
                  label: const Text(
                    'SHOW QR CODE',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                      side: const BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                ),
              ),
            ),

            // ステータス選択ボタン
            SingleChildScrollView(
              scrollDirection: Axis.horizontal, // 横スクロールできるように
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  _statusButton(
                    'ALL MEMBERS',
                    Icons.filter_list,
                    Colors.deepOrangeAccent,
                    null,
                  ),
                  _statusButton('0: SLEEPING', Icons.circle, Colors.grey, 0),
                  _statusButton(
                    '1: AWAKE',
                    Icons.circle,
                    Colors.greenAccent,
                    1,
                  ),
                  _statusButton(
                    '2: OVERSLEPT',
                    Icons.circle,
                    Colors.pinkAccent,
                    2,
                  ),
                  _statusButton(
                    '3: MOVING',
                    Icons.circle,
                    Colors.lightBlueAccent,
                    3,
                  ),
                  _statusButton(
                    '4: ARRIVED',
                    Icons.circle,
                    Colors.orangeAccent,
                    4,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 見出しテキスト
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  const Text(
                    "MEMBER'S STATUS",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const Spacer(),

                  // 何人起きてるか
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.deepOrangeAccent,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Text(
                      '$arrived / $all arrived',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // メンバー一覧
            Expanded(
              child: filterMembers.isEmpty
                  ? const Center(
                      child: Text('No members match this status.'),
                    ) // イベントメンバーがいないの時
                  : ListView.builder(
                      // イベントメンバーがいる時
                      key: ValueKey(selectedFilter), // フィルターが変わるごとにリストを最新にする
                      itemCount: filterMembers.length, // いくつ表示するか
                      itemBuilder: (context, index) {
                        final member =
                            filterMembers[index] as Map<String, dynamic>? ?? {};
                        final int status = member['status'] as int? ?? 0;

                        Color statusColor;
                        String statusText;

                        switch (status) {
                          case 0:
                            statusColor = Colors.grey;
                            statusText = 'SLEEPING';
                            break;
                          case 1:
                            statusColor = Colors.greenAccent;
                            statusText = 'AWAKE';
                            break;
                          case 2:
                            statusColor = Colors.pinkAccent;
                            statusText = 'OVERSLEPT';
                            break;
                          case 3:
                            statusColor = Colors.lightBlueAccent;
                            statusText = 'MOVING';
                            break;
                          case 4:
                            statusColor = Colors.orangeAccent;
                            statusText = 'ARRIVED';
                            break;
                          default: // statusColorとstatusTextがnull値にならないよう宣言
                            statusColor = Colors.grey;
                            statusText = 'SLEEPING';
                            break;
                        }

                        return GestureDetector(
                          onTap: () async {
                            final String? memberId = member['user_id'];

                            if (memberId == null) {
                              debugPrint('エラー: ユーザーIDが取得できていません');
                              return;
                            }

                            try {
                              final report = await EventRepository()
                                  .getMemberReport(widget.eventId, memberId);

                              if (context.mounted) {
                                if (report != null) {
                                  Navigator.push(
                                    // ポストページに移動
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MemberPostPage(
                                        member: member,
                                        report: report,
                                      ),
                                    ),
                                  );
                                  debugPrint('ポスト画面へ移動');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('There are no posts yet.'),
                                    ),
                                  );
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('There are no posts yet.'),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              debugPrint('$e');
                            }
                          },

                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 5,
                            ),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2),
                              color: Colors.white,
                            ),

                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  backgroundImage:
                                      (member['avatar_url'] != null &&
                                          member['avatar_url'] != "")
                                      ? NetworkImage(
                                          member['avatar_url'],
                                        ) // アイコンを写真のurlにする
                                      : null,
                                  child:
                                      (member['avatar_url'] == null ||
                                          member['avatar_url'] == "")
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        ) // 代替アイコンを使う
                                      : null,
                                ),

                                const SizedBox(width: 15),

                                Expanded(
                                  child: Text(
                                    member['nickname'] ?? 'No name',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                Column(
                                  children: [
                                    Container(
                                      // status表示
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 1,
                                        ),
                                        color: statusColor,
                                      ),
                                      child: Text(
                                        statusText,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),

                                    /*  // ここに通知ボタン
                              ElevatedButton(
                                onPressed: ,
                                child: 
                              )
                              */
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
