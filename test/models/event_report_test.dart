import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/event_report.dart';
import 'package:flutter_application_1/models/event_member_status.dart';

void main() {
  group('EventReport.parseStatus 単体テスト', () {
    test('DB正規値の整数 (0〜5) がそのまま正しく保持されること', () {
      expect(EventReport.parseStatus(0), 0); // sleeping
      expect(EventReport.parseStatus(1), 1); // awake
      expect(EventReport.parseStatus(2), 2); // overslept
      expect(EventReport.parseStatus(3), 3); // moving
      expect(EventReport.parseStatus(4), 4); // arrived
      expect(EventReport.parseStatus(5), 5); // late
    });

    test('0〜5 の範囲外の整数値が渡された場合、デフォルト (0: sleeping) にフォールバックすること', () {
      expect(EventReport.parseStatus(-1), 0);
      expect(EventReport.parseStatus(6), 0);
      expect(EventReport.parseStatus(99), 0);
    });

    test('互換性: status 文字列が正しく対応する整数値にマッピングされ、overslept(2) と late(5) が区別されること', () {
      expect(EventReport.parseStatus('sleeping'), 0);
      expect(EventReport.parseStatus('awake'), 1);
      expect(EventReport.parseStatus('overslept'), 2);
      expect(EventReport.parseStatus('moving'), 3);
      expect(EventReport.parseStatus('arrived'), 4);
      expect(EventReport.parseStatus('late'), 5);

      expect(EventReport.parseStatus(' OVERSLEPT '), 2);
      expect(EventReport.parseStatus('Late'), 5);
    });

    test('互換性: 未知の文字列や null の場合、デフォルト (0: sleeping) にフォールバックすること', () {
      expect(EventReport.parseStatus('unknown_status'), 0);
      expect(EventReport.parseStatus(''), 0);
      expect(EventReport.parseStatus(null), 0);
      expect(EventReport.parseStatus(true), 0);
    });
  });

  group('EventReport.fromJson & toJson 単体テスト', () {
    test('計画時刻・実時刻・PostGISの文字列locationが正常にパースされ、toJsonでも保持されること', () {
      final json = {
        'id': 'rep_123',
        'event_id': 'evt_456',
        'user_id': 'usr_789',
        'planned_wakeup_time': '2026-10-12T06:30:00.000Z',
        'planned_departure_time': '2026-10-12T07:15:00.000Z',
        'actual_wakeup_time': '2026-10-12T06:35:00.000Z',
        'actual_departure_time': '2026-10-12T07:20:00.000Z',
        'status': 4,
        'late_reason': null,
        'photo_url': 'https://example.com/photo.jpg',
        'location': '(35.1815, 136.9066)',
        'updated_at': '2026-10-12T07:30:00.000Z',
      };

      final report = EventReport.fromJson(json);

      expect(report.id, 'rep_123');
      expect(report.eventId, 'evt_456');
      expect(report.userId, 'usr_789');
      expect(report.plannedWakeupTime, DateTime.parse('2026-10-12T06:30:00.000Z'));
      expect(report.plannedDepartureTime, DateTime.parse('2026-10-12T07:15:00.000Z'));
      expect(report.actualWakeupTime, DateTime.parse('2026-10-12T06:35:00.000Z'));
      expect(report.actualDepartureTime, DateTime.parse('2026-10-12T07:20:00.000Z'));
      expect(report.status, 4);
      expect(report.isArrived, isTrue);
      expect(report.latitude, 35.1815);
      expect(report.longitude, 136.9066);
      expect(report.photoUrl, 'https://example.com/photo.jpg');

      final serialized = report.toJson();
      expect(serialized['latitude'], 35.1815);
      expect(serialized['longitude'], 136.9066);
      expect(serialized['location'], '(35.1815, 136.9066)');
    });

    test('Map型の location (x, y) からも緯度経度が正しくパースされること', () {
      final json = {
        'id': 'rep_124',
        'event_id': 'evt_456',
        'user_id': 'usr_789',
        'status': 2,
        'location': {'x': 35.1815, 'y': 136.9066},
        'updated_at': '2026-10-12T07:30:00.000Z',
      };

      final report = EventReport.fromJson(json);

      expect(report.latitude, 35.1815);
      expect(report.longitude, 136.9066);
      expect(report.isOverslept, isTrue);
    });
  });

  group('EventMemberStatus (DTO) 単体テスト', () {
    test('Profile と EventReport が結合された JSON から正しくパースされること', () {
      final json = {
        'profiles': {
          'id': 'usr_001',
          'nickname': 'テストユーザー',
          'avatar_url': 'https://example.com/avatar.png',
          'sleep_past_count': 0,
          'late_count': 1,
          'created_at': '2026-01-01T00:00:00.000Z',
          'updated_at': '2026-01-01T00:00:00.000Z',
        },
        'event_reports': {
          'id': 'rep_001',
          'event_id': 'evt_001',
          'user_id': 'usr_001',
          'status': 5, // late
          'updated_at': '2026-10-12T08:00:00.000Z',
        },
      };

      final memberStatus = EventMemberStatus.fromJson(json);

      expect(memberStatus.profile.id, 'usr_001');
      expect(memberStatus.profile.nickname, 'テストユーザー');
      expect(memberStatus.report, isNotNull);
      expect(memberStatus.currentStatus, 5);
      expect(memberStatus.report!.isLate, isTrue);
    });

    test('event_reports が null の場合、currentStatus は 0 (sleeping) を返すこと', () {
      final json = {
        'profiles': {
          'id': 'usr_002',
          'nickname': 'レポートなしユーザー',
          'sleep_past_count': 0,
          'late_count': 0,
          'created_at': '2026-01-01T00:00:00.000Z',
          'updated_at': '2026-01-01T00:00:00.000Z',
        },
        'event_reports': null,
      };

      final memberStatus = EventMemberStatus.fromJson(json);

      expect(memberStatus.profile.nickname, 'レポートなしユーザー');
      expect(memberStatus.report, isNull);
      expect(memberStatus.currentStatus, 0);
    });
  });
}