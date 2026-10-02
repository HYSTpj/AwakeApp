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

/// 起床・出発アラーム共通の音量設定。
///
/// 無音から1分かけてフェードインする方式だと、鳴り始めの30〜45秒ほどが
/// かえって聞こえにくくなってしまう。最初から一定の音量で鳴らしつつ、
/// 30秒後に最大音量まで引き上げることで、鳴り始めから確実に聞こえるように
/// している。
VolumeSettings buildAlarmVolumeSettings() => VolumeSettings.staircaseFade(
      fadeSteps: [
        VolumeFadeStep(Duration.zero, _initialVolume),
        VolumeFadeStep(_volumeRampUpDuration, _maxVolume),
      ],
      volumeEnforced: true,
    );

/// alarmパッケージ自身のネイティブ振動を有効にするかどうか。
///
/// Androidでは、alarmパッケージのネイティブ振動(`VibrationService.kt`)も
/// vibrationパッケージ(`GradualVibrationController`が使う)も、どちらも
/// 端末に1つしかないシステムの`Vibrator`サービスを共有している。後から
/// 発行した振動命令が前の命令を自動的に上書きするため、二重に振動することは
/// なく、むしろFlutterエンジンがまだ起動していない間(アプリを完全終了した
/// 状態でアラームが鳴った場合など)もネイティブ側だけで振動が鳴り続けられる
/// メリットがある。そのためAndroidでは有効にする。
///
/// iOSでは、alarmパッケージのネイティブ振動(`VibrationManager.swift`)と
/// vibrationパッケージの振動(`CHHapticEngine`)が完全に独立した別々の仕組みで、
/// どちらも相手を止める手段を持たない。両方有効にすると、アプリが起動して
/// `GradualVibrationController`が動き出した後もネイティブ側の振動が並行して
/// 鳴り続け、本物の二重振動になってしまう。そのためiOSでは無効のままにし、
/// アプリ完全終了時に振動が遅れる/欠落するリスクは許容する。
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
