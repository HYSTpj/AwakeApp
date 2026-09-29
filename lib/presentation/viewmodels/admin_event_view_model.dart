import 'package:flutter/foundation.dart';
import '../../data/repositories/admin_event_repository.dart';
import '../../models/event.dart';
import '../../models/profile.dart';

class AdminEventState {
  final List<Event> events;
  final List<Profile> groupMembers;
  final bool isLoading;
  final String? errorMessage;

  const AdminEventState({
    this.events = const [],
    this.groupMembers = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AdminEventState copyWith({
    List<Event>? events,
    List<Profile>? groupMembers,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminEventState(
      events: events ?? this.events,
      groupMembers: groupMembers ?? this.groupMembers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AdminEventViewModel extends ChangeNotifier {
  final AdminEventRepository _repository;
  AdminEventState _state = const AdminEventState();

  AdminEventViewModel(this._repository);

  AdminEventState get state => _state;

  Future<void> loadEvents(String groupId) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final events = await _repository.getEvents(groupId);
      _state = _state.copyWith(events: events, isLoading: false);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
    }
  }

  Future<void> loadGroupMembers(String groupId) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final members = await _repository.getGroupMembers(groupId);
      _state = _state.copyWith(groupMembers: members, isLoading: false);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
    }
  }

  Future<String?> createEventWithParticipants({
    required String groupId,
    required String title,
    required String destinationName,
    double? latitude,
    double? longitude,
    required String qrcodeId,
    required String password,
    required DateTime arrivalTime,
    required List<String> participantUserIds,
  }) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final eventId = await _repository.createEventWithParticipants(
        groupId: groupId,
        title: title,
        destinationName: destinationName,
        latitude: latitude,
        longitude: longitude,
        qrcodeId: qrcodeId,
        password: password,
        arrivalTime: arrivalTime,
        participantUserIds: participantUserIds,
      );
      // 作成成功時に画面側の一覧を最新状態へ自動同期
      await loadEvents(groupId);
      return eventId;
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
      return null;
    }
  }
}