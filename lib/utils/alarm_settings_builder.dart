import 'dart:convert';

import 'package:alarm/alarm.dart';

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
    // alarmパッケージ自身の振動(500ms鳴動/500ms休止を繰り返す固定パターン)は
    // 無効にする。振動はGradualVibrationControllerによる段階的な強度制御のみで
    // 行うため、両方を有効にすると振動が二重に鳴ってしまう。
    vibrate: false,
    volumeSettings: buildAlarmVolumeSettings(),
    payload: jsonEncode({'eventId': eventId, 'phase': phase}),
    notificationSettings: NotificationSettings(
      title: title,
      body: body,
      stopButton: 'ストップ',
    ),
  );
}
