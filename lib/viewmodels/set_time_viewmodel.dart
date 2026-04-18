import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/entities/event_report.dart';
import '../domain/repositories/i_event_report_repository.dart';
import '../data/repositories/event_report_repository_impl.dart';

class SetTimeViewModel extends ChangeNotifier {
  final String eventId;
  final IEventReportRepository _repository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime? wakeupTime;
  DateTime? departureTime;
  String? errorMessage;
  bool isSaving = false;

  SetTimeViewModel({
    required this.eventId,
    IEventReportRepository? repository,
  }) : _repository = repository ?? EventReportRepositoryImpl();

  Future<void> loadTime() async {
    final user = _auth.currentUser;
    if (user == null) {
      errorMessage = "ユーザーがログインしていません。";
      notifyListeners();
      return;
    }

    try {
      final EventReport? report =
          await _repository.getEventReport(eventId, user.uid);
          
      if (report != null) {
        wakeupTime = report.plannedWakeupTime;
        departureTime = report.plannedDepartureTime;
        notifyListeners();
      }
    } catch (e) {
      errorMessage = "データの取得に失敗しました。";
      notifyListeners();
    }
  }

  void setWakeupTime(DateTime time) {
    wakeupTime = time;
    notifyListeners();
  }

  void setDepartureTime(DateTime time) {
    departureTime = time;
    notifyListeners();
  }

  Future<bool> saveChanges(DateTime arrivalTime) async {
    final user = _auth.currentUser;
    if (user == null || wakeupTime == null || departureTime == null) {
      errorMessage = 'Please enter wake-up time and departure time.';
      notifyListeners();
      return false;
    }

    isSaving = true;
    errorMessage = null; // エラーメッセージをクリア
    notifyListeners();

    try {
      final wakeupTimeDay = DateTime(
        arrivalTime.year,
        arrivalTime.month,
        arrivalTime.day,
        wakeupTime!.hour,
        wakeupTime!.minute,
      );
      final departureTimeDay = DateTime(
        arrivalTime.year,
        arrivalTime.month,
        arrivalTime.day,
        departureTime!.hour,
        departureTime!.minute,
      );

      final String? reportId = await _repository.setReport(
        eventId: eventId,
        userId: user.uid,
        wakeupTime: wakeupTimeDay,
        departureTime: departureTimeDay,
      );

      isSaving = false;
      notifyListeners();

      return reportId != null;
    } catch (e) {
      isSaving = false;
      errorMessage = "保存に失敗しました。";
      notifyListeners();
      return false;
    }
  }
}
