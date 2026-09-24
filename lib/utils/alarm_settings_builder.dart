import 'dart:convert';

import 'package:alarm/alarm.dart';

/// 起床・出発アラームで共通の音量フェード設定を持つ [AlarmSettings] を組み立てる。
AlarmSettings buildAlarmSettings({
  required int id,
  required DateTime dateTime,
  required String eventId,
  required String phase,
  required String title,
  required String body,
}) {
  return AlarmSettings(
    id: id,
    dateTime: dateTime,
    assetAudioPath: 'assets/alarm.mp3',
    loopAudio: true,
    vibrate: true,
    volumeSettings: VolumeSettings.fade(
      volume: 1.0,
      fadeDuration: const Duration(minutes: 1),
      volumeEnforced: true,
    ),
    payload: jsonEncode({'eventId': eventId, 'phase': phase}),
    notificationSettings: NotificationSettings(
      title: title,
      body: body,
      stopButton: 'ストップ',
    ),
  );
}
