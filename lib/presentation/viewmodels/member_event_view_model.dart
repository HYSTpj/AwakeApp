import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/repositories/member_event_repository.dart';
import '../../models/event_report.dart';

class MemberEventState {
  final EventReport? myReport;
  final List<EventReport> allReports;
  final bool isLoading;
  final String? errorMessage;
  final String? message;

  const MemberEventState({
    this.myReport,
    this.allReports = const [],
    this.isLoading = false,
    this.errorMessage,
    this.message,
  });

  MemberEventState copyWith({
    EventReport? myReport,
    List<EventReport>? allReports,
    bool? isLoading,
    String? errorMessage,
    String? message,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return MemberEventState(
      myReport: myReport ?? this.myReport,
      allReports: allReports ?? this.allReports,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

class MemberEventViewModel extends ChangeNotifier {
  final MemberEventRepository _repository;
  final String currentUserId;
  StreamSubscription<List<EventReport>>? _reportsSubscription;

  MemberEventState _state = const MemberEventState();

  MemberEventViewModel(this._repository, {required this.currentUserId});

  MemberEventState get state => _state;

  void init(String eventId) {
    _reportsSubscription?.cancel();
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    _reportsSubscription = _repository.watchEventReports(eventId).listen(
      (reports) {
        EventReport? mine;
        try {
          mine = reports.firstWhere((r) => r.userId == currentUserId);
        } catch (_) {
          mine = null;
        }

        _state = _state.copyWith(
          allReports: reports,
          myReport: mine,
          isLoading: false,
        );
        notifyListeners();
      },
      onError: (err) {
        _state = _state.copyWith(
          isLoading: false,
          errorMessage: err.toString(),
        );
        notifyListeners();
      },
    );
  }

  Future<void> savePlannedTimes(String eventId, DateTime wakeup, DateTime departure) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      await _repository.setPlannedTimes(
        eventId: eventId,
        wakeupTime: wakeup,
        departureTime: departure,
      );
      _state = _state.copyWith(isLoading: false, message: '予定時間を保存しました');
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
    }
  }

  Future<bool> reportWakeUp(String eventId) async {
    return _executeAction(() => _repository.reportWakeUp(eventId));
  }

  Future<bool> reportDeparture(String eventId) async {
    return _executeAction(() => _repository.reportDeparture(eventId));
  }

  Future<bool> checkInWithQr(String eventId, String qrCode) async {
    return _executeAction(() => _repository.checkInWithQr(eventId, qrCode));
  }

  Future<bool> checkInWithPasscode(String eventId, String passcode) async {
    return _executeAction(() => _repository.checkInWithPasscode(eventId, passcode));
  }

  Future<bool> submitLateReport({
    required String eventId,
    required String reason,
    String? photoUrl,
    double? latitude,
    double? longitude,
  }) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      await _repository.submitLateReport(
        eventId: eventId,
        reason: reason,
        photoUrl: photoUrl,
        latitude: latitude,
        longitude: longitude,
      );
      _state = _state.copyWith(isLoading: false, message: '遅刻レポートを投稿しました');
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
      return false;
    }
  }

  /// 各種打刻アクションの実行およびローディング・メッセージ通知を共通管理するヘルパー
  Future<bool> _executeAction(Future<Map<String, dynamic>> Function() action) async {
    _state = _state.copyWith(isLoading: true, clearError: true, clearMessage: true);
    notifyListeners();

    try {
      final res = await action();
      final msg = res['message'] as String? ?? '更新完了';
      _state = _state.copyWith(isLoading: false, message: msg);
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _reportsSubscription?.cancel();
    super.dispose();
  }
}