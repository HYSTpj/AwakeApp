import 'dart:convert';

import 'package:alarm/alarm.dart';
import 'package:flutter/foundation.dart';

/// 鳴り始めの音量。無音から始めると最初の30〜45秒ほどが聞こえにくくなるため、
/// 最初からこの音量で鳴らす。
const _initialVolume = 0.8;

/// 音量を引き上げ終える最終音量。
const _maxVolume = 1.0;

/// [_initialVolume] から [_maxVolume] まで引き上げるまでの経過時間。
const _volumeRampUpDuration = Duration(seconds: 30);

/// 起床・出発アラーム共通の音量設定（無音からのフェードインだと鳴り始めが聞こえにくいため避けている）。
VolumeSettings buildAlarmVolumeSettings() => VolumeSettings.staircaseFade(
      fadeSteps: [
        VolumeFadeStep(Duration.zero, _initialVolume),
        VolumeFadeStep(_volumeRampUpDuration, _maxVolume),
      ],
      volumeEnforced: true,
    );

/// alarmパッケージ自身のネイティブ振動を有効にするかどうか。
///
/// Androidは同じVibratorを共有し後発命令が上書きするだけなので有効（アプリ完全終了時も鳴らせる）。
/// iOSは振動の仕組みが独立していて互いに止められず二重振動になるため無効にする。
bool _shouldUseNativeVibration() =>
    defaultTargetPlatform == TargetPlatform.android;

/// 起床・出発アラームで共通の設定を持つ [AlarmSettings] を組み立てる。
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
    vibrate: _shouldUseNativeVibration(),
    volumeSettings: buildAlarmVolumeSettings(),
    payload: jsonEncode({'eventId': eventId, 'phase': phase}),
    notificationSettings: NotificationSettings(
      title: title,
      body: body,
      stopButton: 'ストップ',
    ),
  );
}
