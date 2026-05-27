import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alarm/alarm.dart';
import '../services/alarm_service.dart';
import '../domain/entities/event_report.dart';
import '../domain/repositories/i_event_report_repository.dart';
import '../data/repositories/event_report_repository_impl.dart';
import '../utils/alarm_id.dart';

class SetTimeViewModel extends ChangeNotifier {
  final String eventId;
  final IEventReportRepository? _repository;
  final AlarmService _alarmService;
  final String? injectedUserId;

  DateTime? wakeupTime;
  DateTime? departureTime;
  String? errorMessage;
  bool isSaving = false;

  SetTimeViewModel({
    required this.eventId,
    IEventReportRepository? repository,
    AlarmService? alarmService,
    this.injectedUserId,
  })  : _repository = repository,
        _alarmService = alarmService ?? RealAlarmService();

  Future<void> loadTime() async {
    final uid = injectedUserId ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      errorMessage = "ユーザーがログインしていません。";
      notifyListeners();
      return;
    }

    try {
      final repository = _repository ?? EventReportRepositoryImpl();
      final EventReport? report = await repository.getEventReport(
        eventId,
        uid,
      );

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

  // Pure helper to build AlarmSettings for wakeup (easier to unit test)
  AlarmSettings _buildWakeupSettings(DateTime dateTime) {
    return AlarmSettings(
      id: getAlarmId(eventId, 'wakeup'),
      dateTime: dateTime,
      assetAudioPath: 'assets/alarm.mp3',
      loopAudio: true,
      vibrate: true,
      volumeSettings: VolumeSettings.fixed(volume: 0.8),
      payload: jsonEncode({'eventId': eventId, 'phase': 'wakeup'}),
      notificationSettings: const NotificationSettings(
        title: '起床時間です！',
        body: 'チェックイン画面から起きたことを報告しましょう',
        stopButton: 'ストップ',
      ),
    );
  }

  // Pure helper to build AlarmSettings for departure (easier to unit test)
  AlarmSettings _buildDepartureSettings(DateTime dateTime) {
    return AlarmSettings(
      id: getAlarmId(eventId, 'departure'),
      dateTime: dateTime,
      assetAudioPath: 'assets/alarm.mp3',
      loopAudio: true,
      vibrate: true,
      volumeSettings: VolumeSettings.fixed(volume: 0.8),
      payload: jsonEncode({'eventId': eventId, 'phase': 'departure'}),
      notificationSettings: const NotificationSettings(
        title: '出発時間です！',
        body: '忘れ物はないですか？出発を報告しましょう',
        stopButton: 'ストップ',
      ),
    );
  }

  Future<bool> saveChanges(DateTime arrivalTime) async {
    final uid = injectedUserId ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || wakeupTime == null || departureTime == null) {
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
        DateTime departureTimeDay = DateTime(
        arrivalTime.year,
        arrivalTime.month,
        arrivalTime.day,
        departureTime!.hour,
        departureTime!.minute,
      );

      // Build AlarmSettings using pure helpers (easy to unit-test)
      final wakeupSettings = _buildWakeupSettings(wakeupTimeDay);
      final departureSettings = _buildDepartureSettings(departureTimeDay);

      try {
        await _alarmService.setAlarm(alarmSettings: wakeupSettings);
        await _alarmService.setAlarm(alarmSettings: departureSettings);
      } catch (e) {
        isSaving = false;
        errorMessage = "アラームの登録に失敗しました。";
        notifyListeners();
        return false;
      }

      // アラーム登録成功後、Firestoreへ保存を行う
      try {
        final String? reportId = await repository.setReport(
          eventId: eventId,
          userId: uid,
          wakeupTime: wakeupTimeDay,
          departureTime: departureTimeDay,
        );

        isSaving = false;
        notifyListeners();

        return reportId != null;
      } catch (e) {
        // 保存に失敗した場合は、設定したアラームをキャンセル(ロールバック)する
        await _alarmService.stop(getAlarmId(eventId, 'wakeup'));
        await _alarmService.stop(getAlarmId(eventId, 'departure'));

        isSaving = false;
        errorMessage = "保存に失敗しました。";
        notifyListeners();
        return false;
      }
    } catch (e) {
      isSaving = false;
      errorMessage = "予期せぬエラーが発生しました。";
      notifyListeners();
      
      return false;
    }
  }
}
