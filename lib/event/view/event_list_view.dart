import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../memberstatus_page.dart';
import '../../create_event_page.dart';
import '../view_model/event_view_model.dart';
import '../domain/event_entity.dart';

class EventListPage extends StatefulWidget {
  final String groupId;

  const EventListPage({super.key, required this.groupId});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  late final EventListViewModel _viewModel;
  String? selectedEventId;
  String? selectedEventTitle;

  @override
  void initState() {
    super.initState();
    _viewModel = EventListViewModel(
      groupId: widget.groupId,
      currentUserId: _currentUserId,
    );
    _viewModel.addListener(_onViewModelUpdated);
    _viewModel.loadData();
  }

  @override
  void didUpdateWidget(EventListPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // groupIdが変わった時だけ更新
    if (oldWidget.groupId != widget.groupId) {
      setState(() {
        selectedEventId = null;
        selectedEventTitle = null;
      });
      _viewModel.updateGroupId(widget.groupId);
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelUpdated);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'No decided yet';
    }
    return DateFormat('M/dd HH:mm').format(dateTime);
  }

  Widget _buildEventTile(EventEntity event, int myRole) {
    final arrivalTime = _formatTime(event.arrivalTime);

    return GestureDetector(
      onTap: () {
        if (!mounted) return;
        if (myRole == 0) {
          setState(() {
            selectedEventId = event.eventId;
            selectedEventTitle = event.title;
          });
          debugPrint('${event.title}の管理者ページへ移動');
        } else {
          debugPrint('${event.title}の利用者ページへ移動');
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.schedule,
                  color: Colors.deepOrangeAccent,
                ),
                const SizedBox(width: 5),
                Text(
                  arrivalTime,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(color: Colors.black, thickness: 2, height: 20),
            const SizedBox(height: 10),
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
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.black, thickness: 2, height: 20),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2),
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
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_viewModel.errorMessage!)),
        );
        _viewModel.clearError();
      });
    }

    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final myRole = _viewModel.myRole ?? 1;
    final events = _viewModel.events;

    if (selectedEventId != null) {
      final selectedEvent = events.firstWhere(
        (e) => e.eventId == selectedEventId,
        orElse: () => EventEntity(
          eventId: selectedEventId!,
          title: selectedEventTitle ?? 'No named yet',
          destinationName: 'No decided yet',
          location: '',
          password: '',
          arrivalTime: null,
          status: '',
        ),
      );

      return MemberStatusPage(
        eventId: selectedEvent.eventId,
        eventTitle: selectedEventTitle ?? selectedEvent.title,
        arrivalTime: _formatTime(selectedEvent.arrivalTime),
        password: selectedEvent.password,
      );
    }

    return Column(
      children: [
        if (myRole == 0)
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
                      builder: (context) => CreateEventPage(groupId: widget.groupId),
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
                    side: const BorderSide(color: Colors.black, width: 4),
                  ),
                ),
              ),
            ),
          ),
        Expanded(
          child: events.isEmpty
              ? const Center(child: Text('No events found for this group.'))
              : ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) => _buildEventTile(events[index], myRole),
                ),
        ),
      ],
    );
  }
}
