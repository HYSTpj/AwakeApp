import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alarm/alarm.dart';
import '../domain/entities/event_report.dart';
import '../domain/repositories/i_event_report_repository.dart';
import '../data/repositories/event_report_repository_impl.dart';

class SetTimeViewModel extends ChangeNotifier {
  final String eventId;
  final IEventReportRepository? _repository;

  DateTime? wakeupTime;
  DateTime? departureTime;
  String? errorMessage;
  bool isSaving = false;

  SetTimeViewModel({
    required this.eventId,
    IEventReportRepository? repository,
  }) : _repository = repository;

  Future<void> loadTime() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      errorMessage = "ユーザーがログインしていません。";
      notifyListeners();
      return;
    }

    try {
      final repository = _repository ?? EventReportRepositoryImpl();
      final EventReport? report = await repository.getEventReport(eventId, user.uid);
          
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || wakeupTime == null || departureTime == null) {
      errorMessage = '起床時刻と出発時刻を入力してください。';
      notifyListeners();
      return false;
    }

    isSaving = true;
    errorMessage = null; // エラーメッセージをクリア
    notifyListeners();

    try {
      final repository = _repository ?? EventReportRepositoryImpl();
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

      final String? reportId = await repository.setReport(
        eventId: eventId,
        userId: user.uid,
        wakeupTime: wakeupTimeDay,
        departureTime: departureTimeDay,
      );

      // アラームの登録
      final wakeupSettings = AlarmSettings(
        id: 1, // 起床アラームの固定ID
        dateTime: wakeupTimeDay,
        assetAudioPath: 'assets/alarm.mp3',
        loopAudio: true,
        vibrate: true,
        volumeSettings: VolumeSettings.fixed(volume: 0.8),
        notificationSettings: const NotificationSettings(
          title: '起床時間です！',
          body: 'チェックイン画面から起きたことを報告しましょう',
          stopButton: 'ストップ',
        ),
      );
      
      final departureSettings = AlarmSettings(
        id: 2, // 出発アラームの固定ID
        dateTime: departureTimeDay,
        assetAudioPath: 'assets/alarm.mp3',
        loopAudio: true,
        vibrate: true,
        volumeSettings: VolumeSettings.fixed(volume: 0.8),
        notificationSettings: const NotificationSettings(
          title: '出発時間です！',
          body: '忘れ物はないですか？出発を報告しましょう',
          stopButton: 'ストップ',
        ),
      );

      await Alarm.set(alarmSettings: wakeupSettings);
      await Alarm.set(alarmSettings: departureSettings);

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
