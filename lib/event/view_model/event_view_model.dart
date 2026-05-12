import 'package:flutter/material.dart';
import '../../data/group_repository.dart';
import '../data/event_data.dart';
import '../domain/event_entity.dart';

abstract class BaseEventViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? errorMessage;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? message) {
    errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}

class EventListViewModel extends BaseEventViewModel {
  String groupId;
  final String currentUserId;
  final GroupRepository _groupRepository;
  final EventRepository _eventRepository;

  List<EventEntity> _events = [];
  List<EventEntity> get events => List.unmodifiable(_events);
  int? myRole;

  EventListViewModel({
    required this.groupId,
    required this.currentUserId,
    GroupRepository? groupRepository,
    EventRepository? eventRepository,
  })  : _groupRepository = groupRepository ?? GroupRepository(),
        _eventRepository = eventRepository ?? EventRepositoryImpl();

  Future<void> updateGroupId(String newGroupId) async {
    groupId = newGroupId;
    await loadData();
  }

  Future<void> loadData() async {
    setLoading(true);
    setError(null);

    if (currentUserId.isEmpty) {
      setError('User ID is required.');
      setLoading(false);
      _events = [];
      return;
    }

    try {
      final role = await _groupRepository.getRole(
        id: currentUserId,
        groupId: groupId,
      );
      myRole = role ?? 1;
      _events = await _eventRepository.getEvents(groupId);
    } catch (e) {
      setError('Failed to load events: $e');
      _events = [];
    } finally {
      setLoading(false);
    }
  }
}
