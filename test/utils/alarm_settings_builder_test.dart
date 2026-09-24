import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter_application_1/utils/alarm_settings_builder.dart';

void main() {
  group('buildAlarmSettings', () {
    test('音量が1分かけて最大音量までフェードするよう設定される', () {
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
        VolumeSettings.fade(
          volume: 1.0,
          fadeDuration: const Duration(minutes: 1),
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
      expect(settings.vibrate, isTrue);
      expect(settings.loopAudio, isTrue);
    });
  });
}
