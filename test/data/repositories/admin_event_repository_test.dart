import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_application_1/data/repositories/admin_event_repository.dart';
import 'supabase_test_mocks.dart';

class MockUser extends Mock implements User {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

/// select() や rpc() の戻り値としてチェーンを受け流し、引数条件の検証も可能にする Fake
class FakePostgrestBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T>, PostgrestTransformBuilder<T> {
  final Future<T> _future;
  final Map<String, Object> appliedFilters = {};

  FakePostgrestBuilder(this._future);

  @override
  PostgrestFilterBuilder<T> eq(String column, Object value) {
    appliedFilters[column] = value;
    return this;
  }

  @override
  PostgrestTransformBuilder<T> order(
    String column, {
    bool ascending = false,
    bool nullsFirst = false,
    String? referencedTable,
  }) =>
      this;

  @override
  PostgrestTransformBuilder<Map<String, dynamic>?> maybeSingle() {
    final mapped = _future.then((value) {
      if (value is List && value.isNotEmpty) {
        final first = value.first;
        if (first is Map<String, dynamic>) return first;
      }
      if (value is Map<String, dynamic>) return value;
      return null;
    });
    return FakePostgrestBuilder<Map<String, dynamic>?>(mapped);
  }

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T value) onValue, {
    Function? onError,
  }) {
    return _future.then(onValue, onError: onError);
  }
}

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;
  late SupabaseAdminEventRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();

    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('user_admin_01');

    repository = SupabaseAdminEventRepository(mockClient);
  });

  group('getEvents 単体テスト', () {
    test('管理者 (role == 0) の場合は get_admin_events RPC を呼び出すこと', () async {
      final mockFrom = MockSupabaseQueryBuilder();
      when(() => mockClient.from('groups_memberships')).thenAnswer((_) => mockFrom);
      when(() => mockFrom.select('role')).thenAnswer(
        (_) => FakePostgrestBuilder<List<Map<String, dynamic>>>(
          Future.value([
            {'role': 0}
          ]),
        ),
      );

      when(() => mockClient.rpc(
            'get_admin_events',
            params: {'p_group_id': 'grp_1'},
          )).thenAnswer(
        (_) => FakePostgrestBuilder<dynamic>(
          Future.value([
            {
              'id': 'evt_1',
              'group_id': 'grp_1',
              'title': 'Admin Event',
              'destination_name': 'Tokyo Station',
              'qrcode_id': 'qr_1',
              'password': 'secret_pass',
              'arrival_time': '2026-10-12T09:00:00.000Z',
              'status': 'active',
              'created_at': '2026-10-01T00:00:00.000Z',
              'updated_at': '2026-10-01T00:00:00.000Z',
            }
          ]),
        ),
      );

      final events = await repository.getEvents('grp_1');

      expect(events.length, 1);
      expect(events.first.title, 'Admin Event');
      expect(events.first.password, 'secret_pass');
    });

    test('一般メンバー (role != 0) の場合は events_view から取得すること', () async {
      final mockMembershipFrom = MockSupabaseQueryBuilder();
      when(() => mockClient.from('groups_memberships')).thenAnswer((_) => mockMembershipFrom);
      when(() => mockMembershipFrom.select('role')).thenAnswer(
        (_) => FakePostgrestBuilder<List<Map<String, dynamic>>>(
          Future.value([
            {'role': 1}
          ]),
        ),
      );

      final mockEventsViewFrom = MockSupabaseQueryBuilder();
      when(() => mockClient.from('events_view')).thenAnswer((_) => mockEventsViewFrom);
      when(() => mockEventsViewFrom.select()).thenAnswer(
        (_) => FakePostgrestBuilder<List<Map<String, dynamic>>>(
          Future.value([
            {
              'id': 'evt_2',
              'group_id': 'grp_1',
              'title': 'Member Event',
              'destination_name': 'Nagoya Station',
              'qrcode_id': null,
              'password': null,
              'arrival_time': '2026-10-12T10:00:00.000Z',
              'status': 'active',
              'created_at': '2026-10-01T00:00:00.000Z',
              'updated_at': '2026-10-01T00:00:00.000Z',
            }
          ]),
        ),
      );

      final events = await repository.getEvents('grp_1');

      expect(events.length, 1);
      expect(events.first.title, 'Member Event');
      expect(events.first.password, isNull);
    });
  });

  group('getEventMemberStatuses 単体テスト', () {
    test('event_reports と profiles が結合されたリストが EventMemberStatus にマッピングされること', () async {
      final mockFrom = MockSupabaseQueryBuilder();
      final builder = FakePostgrestBuilder<List<Map<String, dynamic>>>(
        Future.value([
          {
            'id': 'rep_1',
            'event_id': 'evt_1',
            'user_id': 'usr_1',
            'status': 4, // arrived
            'updated_at': '2026-10-12T08:50:00.000Z',
            'profiles': {
              'id': 'usr_1',
              'nickname': 'メンバー1',
              'avatar_url': null,
              'sleep_past_count': 0,
              'late_count': 0,
              'created_at': '2026-01-01T00:00:00.000Z',
              'updated_at': '2026-01-01T00:00:00.000Z',
            }
          }
        ]),
      );

      when(() => mockClient.from('event_reports')).thenAnswer((_) => mockFrom);
      when(() => mockFrom.select(any())).thenAnswer((_) => builder);

      final results = await repository.getEventMemberStatuses('evt_1');

      expect(builder.appliedFilters['event_id'], 'evt_1');
      expect(results.length, 1);
      expect(results.first.profile.nickname, 'メンバー1');
      expect(results.first.currentStatus, 4);
      expect(results.first.report?.isArrived, isTrue);
    });
  });

  group('getMemberReport 単体テスト', () {
    test('該当するレポートが存在する場合は EventReport を返却し、eventId と userId で絞り込まれていること', () async {
      final mockFrom = MockSupabaseQueryBuilder();
      final builder = FakePostgrestBuilder<List<Map<String, dynamic>>>(
        Future.value([
          {
            'id': 'rep_1',
            'event_id': 'evt_1',
            'user_id': 'usr_1',
            'status': 2, // overslept
            'late_reason': '寝坊しました',
            'updated_at': '2026-10-12T08:00:00.000Z',
          }
        ]),
      );

      when(() => mockClient.from('event_reports')).thenAnswer((_) => mockFrom);
      when(() => mockFrom.select()).thenAnswer((_) => builder);

      final report = await repository.getMemberReport(eventId: 'evt_1', userId: 'usr_1');

      // event_id と user_id の両方がクエリ条件に正しく設定されていることを保証
      expect(builder.appliedFilters['event_id'], 'evt_1');
      expect(builder.appliedFilters['user_id'], 'usr_1');

      expect(report, isNotNull);
      expect(report!.status, 2);
      expect(report.isOverslept, isTrue);
      expect(report.lateReason, '寝坊しました');
    });

    test('レポートが存在しない場合は null を返却すること', () async {
      final mockFrom = MockSupabaseQueryBuilder();
      final builder = FakePostgrestBuilder<List<Map<String, dynamic>>>(
        Future.value([]),
      );

      when(() => mockClient.from('event_reports')).thenAnswer((_) => mockFrom);
      when(() => mockFrom.select()).thenAnswer((_) => builder);

      final report = await repository.getMemberReport(eventId: 'evt_1', userId: 'usr_2');

      expect(builder.appliedFilters['event_id'], 'evt_1');
      expect(builder.appliedFilters['user_id'], 'usr_2');
      expect(report, isNull);
    });
  });

  group('createEventWithParticipants 単体テスト', () {
    test('成功時に event_id を返却すること', () async {
      when(() => mockClient.rpc(
            'create_event_with_participants',
            params: any(named: 'params'),
          )).thenAnswer(
        (_) => FakePostgrestBuilder<dynamic>(
          Future.value({'success': true, 'event_id': 'new_event_123'}),
        ),
      );

      final eventId = await repository.createEventWithParticipants(
        groupId: 'grp_1',
        title: 'New Event',
        destinationName: 'Nagoya',
        qrcodeId: 'qr_1',
        password: 'pass',
        arrivalTime: DateTime(2026, 10, 15, 9, 0),
        participantUserIds: ['usr_1', 'usr_2'],
      );

      expect(eventId, 'new_event_123');
    });

    test('success が false または失敗時は PostgrestException をスローすること', () async {
      when(() => mockClient.rpc(
            'create_event_with_participants',
            params: any(named: 'params'),
          )).thenAnswer(
        (_) => FakePostgrestBuilder<dynamic>(
          Future.value({'success': false}),
        ),
      );

      expect(
        () => repository.createEventWithParticipants(
          groupId: 'grp_1',
          title: 'New Event',
          destinationName: 'Nagoya',
          qrcodeId: 'qr_1',
          password: 'pass',
          arrivalTime: DateTime(2026, 10, 15, 9, 0),
          participantUserIds: ['usr_1'],
        ),
        throwsA(isA<PostgrestException>()),
      );
    });
  });
}