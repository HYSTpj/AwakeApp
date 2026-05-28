import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';

abstract class AlarmService {
  Stream<AlarmSet> get ringing;
  Future<void> init();
  Future<void> setAlarm({required AlarmSettings alarmSettings});
  Future<void> stop(int id);
}

class RealAlarmService implements AlarmService {
  @override
  Stream<AlarmSet> get ringing => Alarm.ringing;

  @override
  Future<void> init() async {
    await Alarm.init();
  }

  @override
  Future<void> setAlarm({required AlarmSettings alarmSettings}) async {
    await Alarm.set(alarmSettings: alarmSettings);
  }

  @override
  Future<void> stop(int id) async {
    await Alarm.stop(id);
  }
}
