import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/alarm_service.dart';
import '../../models/event_report.dart';
import '../../data/repositories/member_event_repository.dart';
import '../../utils/alarm_id.dart';
import '../../utils/alarm_settings_builder.dart';

class SetTimeViewModel extends ChangeNotifier {
  final String eventId;
  final MemberEventRepository _repository;
  final AlarmService _alarmService;

  DateTime? wakeupTime;
  DateTime? departureTime;
  String? errorMessage;
  bool isSaving = false;

  SetTimeViewModel({
    required this.eventId,
    MemberEventRepository? repository,
    AlarmService? alarmService,
    SupabaseClient? supabaseClient,
  })  : _alarmService = alarmService ?? RealAlarmService(),
        _repository = repository ??
            SupabaseMemberEventRepository(
              supabaseClient ??
                  (Supabase.instance.isInitialized
                      ? Supabase.instance.client
                      : SupabaseClient('https://dummy.supabase.co', 'dummy-key')),
            );

  Future<void> loadTime() async {
    try {
      final EventReport? report = await _repository.getMyReport(eventId);

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
    if (wakeupTime == null || departureTime == null) {
      errorMessage = '起床時刻と出発時刻を入力してください。';
      notifyListeners();
      return false;
    }

    isSaving = true;
    errorMessage = null; // エラーメッセージをクリア
    notifyListeners();

    try {
      DateTime wakeupTimeDay = DateTime(
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

      // もし起床時間が到着時間より後になっていたら、前日の夜に修正
      if (wakeupTimeDay.isAfter(arrivalTime)) {
        wakeupTimeDay = wakeupTimeDay.subtract(const Duration(days: 1));
      }

      // 出発時間も同様
      if (departureTimeDay.isAfter(arrivalTime)) {
        departureTimeDay = departureTimeDay.subtract(const Duration(days: 1));
      }

      // まずローカルでアラームの登録を行う
      final wakeupSettings = buildAlarmSettings(
        id: getAlarmId(eventId, 'wakeup'),
        dateTime: wakeupTimeDay,
        eventId: eventId,
        phase: 'wakeup',
        title: '起床時間です！',
        body: '起きたら忘れずアプリで報告しましょう！!',
      );

      final departureSettings = buildAlarmSettings(
        id: getAlarmId(eventId, 'departure'),
        dateTime: departureTimeDay,
        eventId: eventId,
        phase: 'departure',
        title: '出発時間です！',
        body: '忘れ物はないですか？出発を報告しましょう',
      );

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
        await _repository.setPlannedTimes(
          eventId: eventId,
          wakeupTime: wakeupTimeDay,
          departureTime: departureTimeDay,
        );

        isSaving = false;
        notifyListeners();
        return true;
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
