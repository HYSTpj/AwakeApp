import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter_application_1/utils/alarm_settings_builder.dart';

void main() {
  group('buildAlarmSettings', () {
    test('音量は最初から0.8で鳴り、30秒後に最大音量まで引き上がる', () {
      final settings = buildAlarmSettings(
        id: 1,
        dateTime: DateTime(2026, 5, 14, 6, 30),
        eventId: 'event-1',
        phase: 'wakeup',
        title: '起床時間です！',
        body: 'body',
      );

      expect(
        settings.volumeSettings,
        VolumeSettings.staircaseFade(
          fadeSteps: [
            VolumeFadeStep(Duration.zero, 0.8),
            VolumeFadeStep(const Duration(seconds: 30), 1.0),
          ],
          volumeEnforced: true,
        ),
      );
    });

    test('payloadにeventIdとphaseが正しくエンコードされる', () {
      final settings = buildAlarmSettings(
        id: 1,
        dateTime: DateTime(2026, 5, 14, 6, 30),
        eventId: 'event-42',
        phase: 'departure',
        title: 'title',
        body: 'body',
      );

      final payload = jsonDecode(settings.payload!) as Map<String, dynamic>;
      expect(payload['eventId'], 'event-42');
      expect(payload['phase'], 'departure');
    });

    test('id・dateTime・通知文言がそのまま反映される', () {
      final dateTime = DateTime(2026, 5, 14, 7, 15);
      final settings = buildAlarmSettings(
        id: 123,
        dateTime: dateTime,
        eventId: 'event-1',
        phase: 'wakeup',
        title: '出発時間です！',
        body: '忘れ物はないですか？',
      );

      expect(settings.id, 123);
      expect(settings.dateTime, dateTime);
      expect(settings.notificationSettings.title, '出発時間です！');
      expect(settings.notificationSettings.body, '忘れ物はないですか？');
      // GradualVibrationControllerが振動を制御するため、alarmパッケージ自身の
      // 固定振動パターンとの二重鳴動を避けるためfalseにしている
      expect(settings.vibrate, isFalse);
      expect(settings.loopAudio, isTrue);
    });
  });
}
