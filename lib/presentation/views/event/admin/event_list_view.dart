import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../data/repositories/group_repository.dart';
import '../../../../data/repositories/admin_event_repository.dart';
import '../../../../../models/event.dart';
import 'memberstatus_page.dart';
import 'create_event_page.dart';

class EventListPage extends StatefulWidget {
  final String groupId;

  const EventListPage({super.key, required this.groupId});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final _supabase = Supabase.instance.client;
  late final GroupRepository _groupRepository;
  late final AdminEventRepository _adminEventRepository;

  Future<Map<String, dynamic>>? _pageDataFuture;

  String? selectedEventId;
  String? selectedEventTitle;

  @override
  void initState() {
    super.initState();
    _groupRepository = SupabaseGroupRepository(_supabase);
    _adminEventRepository = SupabaseAdminEventRepository(_supabase);
    _loadData();
  }

  void _loadData() {
    _pageDataFuture = Future.wait([
      // 戻り値が null の場合はデフォルト 1
      _groupRepository.getRole(widget.groupId),
      _adminEventRepository.getEvents(widget.groupId),
    ]).then((results) {
      return {
        'role': (results[0] as int?) ?? 1,
        'events': results[1] as List<Event>,
      };
    });
  }

  @override
  void didUpdateWidget(EventListPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // groupIdが変わった時だけ更新
    if (oldWidget.groupId != widget.groupId) {
      setState(() {
        selectedEventId = null;
        selectedEventTitle = null;
        _loadData();
      });
    }
  }

  /// 時間フォーマット処理 (DateTime / String 両対応)
  String _formatTime(dynamic arrivalTime) {
    if (arrivalTime == null) return 'Not decided yet';

    try {
      if (arrivalTime is DateTime) {
        return DateFormat("M/dd HH:mm").format(arrivalTime);
      }
      if (arrivalTime is String) {
        final parsedDate = DateTime.parse(arrivalTime);
        return DateFormat("M/dd HH:mm").format(parsedDate);
      }
    } catch (e) {
      debugPrint('時間変換エラー: $e');
    }
    return 'Not decided yet';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _pageDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('エラーが発生しました: ${snapshot.error}'),
          );
        }

        final data = snapshot.data;
        if (data == null) {
          return const Center(child: Text('データを読み込めませんでした'));
        }

        final myRole = data['role'] as int;
        final myEvents = data['events'] as List<Event>;

        // 詳細画面へインラインで切り替える場合の処理
        if (selectedEventId != null) {
          final selectedEvent = myEvents.firstWhere(
            (e) => e.id == selectedEventId,
            orElse: () => myEvents.first,
          );

          final displayTime = _formatTime(selectedEvent.arrivalTime);

          return MemberStatusPage(
            groupId: widget.groupId,
            eventId: selectedEventId!,
            eventTitle: selectedEventTitle ?? selectedEvent.title,
            myRole: myRole,
            arrivalTime: displayTime,
            password: selectedEvent.password,
            qrcodeId: selectedEvent.qrcodeId,
          );
        }

        return Column(
          children: [
            // 管理者（myRole == 0）のみイベント追加ボタンを表示
            if (myRole == 0)
              Padding(
                padding: const EdgeInsets.all(15),
                child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateEventPage(
                            groupId: widget.groupId,
                            myRole: myRole,
                          ),
                        ),
                      );

                      if (mounted) {
                        setState(() {
                          _loadData();
                        });
                        debugPrint('イベント一覧をリフレッシュ');
                      }
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

            // イベント一覧リスト
            Expanded(
              child: myEvents.isEmpty
                  ? const Center(
                      child: Text('No events found for this group.'),
                    )
                  : ListView.builder(
                      itemCount: myEvents.length,
                      itemBuilder: (context, index) {
                        final event = myEvents[index];
                        final arrivalTime = _formatTime(event.arrivalTime);

                        return GestureDetector(
                          onTap: () async {
                            if (!mounted) return;

                            if (myRole == 0) {
                              setState(() {
                                selectedEventId = event.id;
                                selectedEventTitle = event.title;
                              });
                              debugPrint('${event.title} の管理者ページへ移動');
                            } else {
                              debugPrint('${event.title} の利用者ページへ移動');
                            }
                          },
                          child: Container(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 集合時間
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
                                ),
                                const SizedBox(height: 10),

                                // 集合場所
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.deepOrangeAccent,
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        event.destinationName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  color: Colors.black,
                                  thickness: 2,
                                  height: 20,
                                ),
                                const SizedBox(height: 10),

                                // イベント名 & 設定ボタン
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        event.title.isNotEmpty
                                            ? event.title
                                            : 'No named yet',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(4),
                                        icon: const Icon(
                                          Icons.settings,
                                          color: Colors.grey,
                                          size: 30,
                                        ),
                                        onPressed: () {
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
