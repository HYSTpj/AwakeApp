import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../presentation/viewmodels/admin_event_view_model.dart';
import 'memberstatus_page.dart';
import 'create_event_page.dart';

class EventListPage extends StatefulWidget {
  final String groupId;
  final int myRole;

  const EventListPage({
    super.key,
    required this.groupId,
    required this.myRole,
  });

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  String? selectedEventId;
  String? selectedEventTitle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminEventViewModel>().loadEvents(widget.groupId);
    });
  }

  @override
  void didUpdateWidget(EventListPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.groupId != widget.groupId) {
      setState(() {
        selectedEventId = null;
        selectedEventTitle = null;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AdminEventViewModel>().loadEvents(widget.groupId);
      });
    }
  }

  String _formatTime(dynamic arrivalTime) {
    if (arrivalTime == null) return 'Not decided yet';

    try {
      if (arrivalTime is DateTime) {
        return DateFormat('M/dd HH:mm').format(arrivalTime);
      }
      if (arrivalTime is String) {
        final parsedDate = DateTime.parse(arrivalTime);
        return DateFormat('M/dd HH:mm').format(parsedDate);
      }
    } catch (e) {
      debugPrint('時間変換エラー: $e');
    }
    return 'Not decided yet';
  }

  @override
  Widget build(BuildContext context) {
    // 共有 Provider の ViewModel / State を購読
    final viewModel = context.watch<AdminEventViewModel>();
    final state = viewModel.state;

    // 画面整合性ガード：対象グループIDが一致し、イベント読み込み中でないか
    final isMatchingGroup = state.selectedGroupId == widget.groupId;
    final isLoading = state.isLoadingEvents || !isMatchingGroup;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.eventsError != null) {
      return Center(
        child: Text('イベント取得エラー: ${state.eventsError}'),
      );
    }

    final myEvents = state.events;

    // インラインで参加状況詳細画面（MemberStatusPage）を表示する場合
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
        myRole: widget.myRole,
        arrivalTime: displayTime,
        password: selectedEvent.password ?? '',
        qrcodeId: selectedEvent.qrcodeId ?? '',
      );
    }

    return Column(
      children: [
        // 管理者（widget.myRole == 0）のみイベント追加ボタンを表示
        if (widget.myRole == 0)
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
                        myRole: widget.myRole,
                      ),
                    ),
                  );
                  // 作成成功時は共有 ViewModel 内部で自動再同期されるため手動再取得は不要
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
                      onTap: () {
                        if (!mounted) return;

                        if (widget.myRole == 0) {
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

                            // イベント名 & 設定アイコン
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
  }
}