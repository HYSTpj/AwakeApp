import 'package:flutter/foundation.dart';
import '../../data/repositories/admin_event_repository.dart';
import '../../models/event.dart';
import '../../models/event_member_status.dart';
import '../../models/event_report.dart';
import '../../models/profile.dart';

@immutable
class AdminEventState {
  // イベント一覧画面用
  final String? selectedGroupId;
  final List<Event> events;
  final bool isLoadingEvents;
  final String? eventsError;

  // メンバー選択・イベント作成画面用
  final String? selectedMembersGroupId;
  final List<Profile> groupMembers;
  final bool isLoadingMembers;
  final String? membersError;
  final bool isCreatingEvent;
  final String? createEventError;

  // 参加メンバー状況一覧画面用
  final String? selectedEventId;
  final List<EventMemberStatus> memberStatuses;
  final bool isLoadingStatuses;
  final String? statusesError;

  // 個別レポート詳細画面用
  final String? selectedReportEventId;
  final String? selectedReportUserId;
  final EventReport? selectedMemberReport;
  final bool isLoadingMemberReport;
  final String? memberReportError;

  const AdminEventState({
    this.selectedGroupId,
    this.events = const [],
    this.isLoadingEvents = false,
    this.eventsError,
    this.selectedMembersGroupId,
    this.groupMembers = const [],
    this.isLoadingMembers = false,
    this.membersError,
    this.isCreatingEvent = false,
    this.createEventError,
    this.selectedEventId,
    this.memberStatuses = const [],
    this.isLoadingStatuses = false,
    this.statusesError,
    this.selectedReportEventId,
    this.selectedReportUserId,
    this.selectedMemberReport,
    this.isLoadingMemberReport = false,
    this.memberReportError,
  });

  AdminEventState copyWith({
    String? selectedGroupId,
    bool clearGroupId = false,
    List<Event>? events,
    bool? isLoadingEvents,
    String? eventsError,
    bool clearEventsError = false,
    String? selectedMembersGroupId,
    bool clearMembersGroupId = false,
    List<Profile>? groupMembers,
    bool? isLoadingMembers,
    String? membersError,
    bool clearMembersError = false,
    bool? isCreatingEvent,
    String? createEventError,
    bool clearCreateEventError = false,
    String? selectedEventId,
    bool clearEventId = false,
    List<EventMemberStatus>? memberStatuses,
    bool? isLoadingStatuses,
    String? statusesError,
    bool clearStatusesError = false,
    String? selectedReportEventId,
    bool clearReportEventId = false,
    String? selectedReportUserId,
    bool clearReportUserId = false,
    EventReport? selectedMemberReport,
    bool clearMemberReport = false,
    bool? isLoadingMemberReport,
    String? memberReportError,
    bool clearMemberReportError = false,
  }) {
    return AdminEventState(
      selectedGroupId: clearGroupId
          ? null
          : (selectedGroupId ?? this.selectedGroupId),
      events: events ?? this.events,
      isLoadingEvents: isLoadingEvents ?? this.isLoadingEvents,
      eventsError: clearEventsError ? null : (eventsError ?? this.eventsError),
      selectedMembersGroupId: clearMembersGroupId
          ? null
          : (selectedMembersGroupId ?? this.selectedMembersGroupId),
      groupMembers: groupMembers ?? this.groupMembers,
      isLoadingMembers: isLoadingMembers ?? this.isLoadingMembers,
      membersError: clearMembersError
          ? null
          : (membersError ?? this.membersError),
      isCreatingEvent: isCreatingEvent ?? this.isCreatingEvent,
      createEventError: clearCreateEventError
          ? null
          : (createEventError ?? this.createEventError),
      selectedEventId: clearEventId
          ? null
          : (selectedEventId ?? this.selectedEventId),
      memberStatuses: memberStatuses ?? this.memberStatuses,
      isLoadingStatuses: isLoadingStatuses ?? this.isLoadingStatuses,
      statusesError: clearStatusesError
          ? null
          : (statusesError ?? this.statusesError),
      selectedReportEventId: clearReportEventId
          ? null
          : (selectedReportEventId ?? this.selectedReportEventId),
      selectedReportUserId: clearReportUserId
          ? null
          : (selectedReportUserId ?? this.selectedReportUserId),
      selectedMemberReport: clearMemberReport
          ? null
          : (selectedMemberReport ?? this.selectedMemberReport),
      isLoadingMemberReport:
          isLoadingMemberReport ?? this.isLoadingMemberReport,
      memberReportError: clearMemberReportError
          ? null
          : (memberReportError ?? this.memberReportError),
    );
  }
}

class AdminEventViewModel extends ChangeNotifier {
  final AdminEventRepository _repository;
  AdminEventState _state = const AdminEventState();

  // 非同期競合制御用の世代カウンター
  int _eventsGeneration = 0;
  int _membersGeneration = 0;
  int _statusesGeneration = 0;
  int _memberReportGeneration = 0;

  AdminEventViewModel(this._repository);

  AdminEventState get state => _state;

  Future<void> loadEvents(String groupId) async {
    final currentGen = ++_eventsGeneration;
    final isNewGroup = _state.selectedGroupId != groupId;

    _state = _state.copyWith(
      selectedGroupId: groupId,
      events: isNewGroup ? const [] : _state.events,
      isLoadingEvents: true,
      clearEventsError: true,
    );
    notifyListeners();

    try {
      final events = await _repository.getEvents(groupId);
      if (currentGen != _eventsGeneration) return;

      _state = _state.copyWith(events: events, isLoadingEvents: false);
      notifyListeners();
    } catch (e) {
      if (currentGen != _eventsGeneration) return;
      _state = _state.copyWith(
        isLoadingEvents: false,
        eventsError: e.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> loadGroupMembers(String groupId) async {
    final currentGen = ++_membersGeneration;
    final isNewGroup = _state.selectedMembersGroupId != groupId;

    _state = _state.copyWith(
      selectedMembersGroupId: groupId,
      groupMembers: isNewGroup ? const [] : _state.groupMembers,
      isLoadingMembers: true,
      clearMembersError: true,
    );
    notifyListeners();

    try {
      final members = await _repository.getGroupMembers(groupId);
      if (currentGen != _membersGeneration) return;

      _state = _state.copyWith(groupMembers: members, isLoadingMembers: false);
      notifyListeners();
    } catch (e) {
      if (currentGen != _membersGeneration) return;
      _state = _state.copyWith(
        isLoadingMembers: false,
        membersError: e.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> loadEventMemberStatuses(String eventId) async {
    final currentGen = ++_statusesGeneration;
    final isNewEvent = _state.selectedEventId != eventId;

    _state = _state.copyWith(
      selectedEventId: eventId,
      memberStatuses: isNewEvent ? const [] : _state.memberStatuses,
      isLoadingStatuses: true,
      clearStatusesError: true,
    );
    notifyListeners();

    try {
      final statuses = await _repository.getEventMemberStatuses(eventId);
      if (currentGen != _statusesGeneration) return;

      _state = _state.copyWith(
        memberStatuses: statuses,
        isLoadingStatuses: false,
      );
      notifyListeners();
    } catch (e) {
      if (currentGen != _statusesGeneration) return;
      _state = _state.copyWith(
        isLoadingStatuses: false,
        statusesError: e.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> loadMemberReport({
    required String eventId,
    required String userId,
  }) async {
    final currentGen = ++_memberReportGeneration;
    // eventId と userId のペアで新規対象かどうかを判定
    final isNewTarget =
        _state.selectedReportEventId != eventId ||
        _state.selectedReportUserId != userId;

    _state = _state.copyWith(
      selectedReportEventId: eventId,
      selectedReportUserId: userId,
      selectedMemberReport: isNewTarget ? null : _state.selectedMemberReport,
      clearMemberReport: isNewTarget,
      isLoadingMemberReport: true,
      clearMemberReportError: true,
    );
    notifyListeners();

    try {
      final report = await _repository.getMemberReport(
        eventId: eventId,
        userId: userId,
      );
      if (currentGen != _memberReportGeneration) return;

      _state = _state.copyWith(
        selectedMemberReport: report,
        clearMemberReport: report == null,
        isLoadingMemberReport: false,
      );
      notifyListeners();
    } catch (e) {
      if (currentGen != _memberReportGeneration) return;
      _state = _state.copyWith(
        isLoadingMemberReport: false,
        memberReportError: e.toString(),
      );
      notifyListeners();
    }
  }

  // イベント新規作成（二重送信ガード & 世代照合付き再同期）
  Future<String?> createEventWithParticipants({
    required String groupId,
    required String title,
    required String destinationName,
    required double? latitude,
    required double? longitude,
    required String qrcodeId,
    required String password,
    required DateTime arrivalTime,
    required List<String> participantUserIds,
  }) async {
    if (_state.isCreatingEvent) return null;

    final initialGen = _eventsGeneration; // 作成開始時の世代を記録

    _state = _state.copyWith(
      isCreatingEvent: true,
      clearCreateEventError: true,
    );
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

      // 選択中グループであり、かつ作成中に一覧取得世代が進んでいない場合のみ再取得
      if (_state.selectedGroupId == groupId &&
          initialGen == _eventsGeneration) {
        await loadEvents(groupId);
      }

      return eventId;
    } catch (e) {
      _state = _state.copyWith(createEventError: e.toString());
      return null;
    } finally {
      _state = _state.copyWith(isCreatingEvent: false);
      notifyListeners();
    }
  }
}
