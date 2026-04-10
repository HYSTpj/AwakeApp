import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/group_repository.dart';
import '../data/event_repository.dart';

import 'package:intl/intl.dart'; //DateFormatを使用するために追加
import 'memberstatus_page.dart';
import 'create_event_page.dart';

class EventListPage extends StatefulWidget {
  final String groupId; // grouplist_pageのドロップダウンで指定されたgroup_id

  const EventListPage({super.key, required this.groupId});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final user = FirebaseAuth.instance.currentUser; // 今ログイン中のユーザー情報を取得
  Future<List<dynamic>>? _pageDataFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final String uid = user?.uid ?? "no user"; // ユーザーid取得，ログインしてない場合のエラーも書く
    _pageDataFuture = Future.wait([
      GroupRepository().getRole(id: uid, groupId: widget.groupId),  // 自分の役割を取得する予約 snapshot.data[0]
      EventRepository().getEvents(widget.groupId),  // イベントリストを作る予約 snapshot.data[1]
    ]);
  }

  @override
  void didUpdateWidget(EventListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groupId != widget.groupId) {
      setState(() {
        _loadData();
      });
    }
  }

  String? selectedEventId; // 今どのイベントの詳細を見ているか
  String? selectedEventTitle; // 選ばれていない時はnull

  // 時間変換処理
  String _time(dynamic timestamp) {
    if (timestamp != null && timestamp is Timestamp) {
      return DateFormat("M/dd HH:mm").format(timestamp.toDate());
    }
    return 'No decided yet';
  }

  @override
  Widget build(BuildContext context) {
    final String uid = user?.uid ?? "no user"; // ユーザーid取得，ログインしてない場合のエラーも書く

    return FutureBuilder<List<dynamic>>(
      // 作業終わるまで置き換えておく画面作成
      future: _pageDataFuture,
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
        final myRole = (snapshot.data![0] ?? 1) as int;  // int型だと教えてあげる

        final myEvents = snapshot.data![1] as List;

        if (selectedEventId != null) {
          // イベント管理者ページへ飛ぶ時
          final selectedEvent = myEvents.firstWhere(
            (e) => e['event_id'] == selectedEventId,
          ); // 選択したイベントid保存

          // 時間変換処理
          String displayTime = _time(selectedEvent['arrival_time']);

          return MemberStatusPage(
            eventId: selectedEventId!,
            eventTitle: selectedEventTitle!,
            arrivalTime: displayTime,
            password: selectedEvent['password'] ?? '',
          );
        }

        return Column(
          children: [
            // イベント作成ボタン
            if (myRole == 0) // 管理者にだけ表示
              Padding(
                padding: const EdgeInsets.all(15),
                child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (contet) => CreateEventPage(groupId: widget.groupId)  // group_idも渡す,
                          ),
                      );
                           
                      debugPrint('イベント作成ページへ移動');
                    },
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: const Text(
                      'Add Events',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                  ),
                ),
              ),

            // イベント一覧
            Expanded(
              // 残り画面スペース全体に表示
              child: myEvents.isEmpty
                  ? const Center(
                      child: Text('No events found for this group.'),
                    ) // イベントがないの時
                  : ListView.builder(
                      // イベントがある時
                      itemCount: myEvents.length, // いくつ表示するか
                      itemBuilder: (context, index) {
                        // 中身設定

                        final event = myEvents[index];

                        // 時間変換処理
                        String arrivalTime = _time(event['arrival_time']);

                        return GestureDetector(
                          onTap: () async {
                            // それぞれのイベント押したとき
                            if (!mounted) return;

                            if (myRole == 0) {
                              // 管理者の時

                              setState(() {
                                // ビルドやり直してイベント管理者ページへ移動
                                selectedEventId = event['event_id'];
                                selectedEventTitle = event['title'];
                              });

                              debugPrint('${event['title']}の管理者ページへ移動');
                            } else {
                              // 利用者の時
                              /*
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MemberCheckInPage(
                              eventId: event['event_id'],
                              eventTitle: event['title'],
                              groupId: widget.groupId,
                            ),
                          ),
                        );
                        */
                              debugPrint('${event['title']}の利用者ページへ移動');
                            }
                          },
                          child: Container(
                            // イベント箱全体設定
                            margin: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 8,
                            ),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start, // 左よせ
                              children: [
                                // 集合時間表示
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.schedule,
                                      color: Colors.deepOrangeAccent,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      arrivalTime,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                const Divider(
                                  color: Colors.black,
                                  thickness: 2,
                                  height: 20,
                                ), // 間の黒線追加
                                const SizedBox(height: 10), // 隙間追加
                                // 集合場所表示
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.deepOrangeAccent,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      event['destination_name'] ??
                                          'No decided yet',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow:
                                          TextOverflow.ellipsis, // 長すぎたら...にする
                                    ),
                                  ],
                                ),

                                const Divider(
                                  color: Colors.black,
                                  thickness: 2,
                                  height: 20,
                                ), // 間の黒線追加
                                const SizedBox(height: 10), // 隙間追加
                                // イベント名表示
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween, // 両サイドに位置設定
                                  children: [
                                    Expanded(
                                      child: Text(
                                        event['title'] ?? 'No named yet',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                        overflow: TextOverflow
                                            .ellipsis, // 長すぎたら...にする
                                      ),
                                    ),

                                    // 設定ボタン
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: IconButton(
                                        constraints:
                                            const BoxConstraints(), // 余計な余白を消す
                                        padding: const EdgeInsets.all(4),
                                        icon: const Icon(
                                          Icons.settings,
                                          color: Colors.grey,
                                          size: 30,
                                        ),
                                        onPressed: () {
                                          /*
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (contet) => EventSettingPage()
                                      ),
                                    );
                                    */
                                          debugPrint('イベント設定ページへ移動');
                                        },
                                      ),
                                    ),
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
