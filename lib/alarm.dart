/*import 'dart:math';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'flutter_local_notifications.dart';
import 'just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmSettings {

  // アラームの設定を作成
  final alarmSettings = AlarmSettings(
    id: 42,
    dateTime: dateTime,
    assetAudioPath: 'assets/alarm.mp3',
    loopAudio: true,
    vibrate: true,
    fadeDuration: 3.0,
    notificationTitle: 'This is the title',
    notificationBody: 'This is the body',
    enableNotificationOnKill: true,
  );

  // アラームを登録
  await Alarm.set(setting: alarmSettings);

  // アラームを止めるor削除
  await Alarm.stop(id: 42);

  // 取得
  final alarm = await Alarm.getAlarm(id: 42);

  Alarm.ringStream.stream.listen((_) {
    // アラームが鳴ったときの処理

  });

}*/
