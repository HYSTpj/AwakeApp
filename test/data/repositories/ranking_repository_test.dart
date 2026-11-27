import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/data/repositories/ranking_repository.dart';

import 'supabase_test_mocks.dart';

class MockRankingQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class FakeEventUpdateBuilder extends Fake
    implements
        PostgrestFilterBuilder<List<Map<String, dynamic>>>,
        PostgrestTransformBuilder<List<Map<String, dynamic>>> {
  final Future<List<Map<String, dynamic>>> _future;
  final Map<String, Object> filters = {};
  final List<String> selectCalls = [];

  FakeEventUpdateBuilder(this._future);

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(
    String column,
    Object value,
  ) => this..filters[column] = value;

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> select([
    String columns = '*',
  ]) => this..selectCalls.add(columns);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(List<Map<String, dynamic>> value) onValue, {
    Function? onError,
  }) {
    return _future.then(onValue, onError: onError);
  }
}

class FakeRankingRpcBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {
  final Future<T> _future;

  FakeRankingRpcBuilder(this._future);

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
  late MockRankingQueryBuilder queryBuilder;
  late SupabaseRankingRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    queryBuilder = MockRankingQueryBuilder();
    repository = SupabaseRankingRepository(mockClient);
  });

  group('completeEvent', () {
    setUp(() {
      when(() => mockClient.from('events')).thenAnswer((_) => queryBuilder);
    });

    test('throws when no event was updated', () async {
      final updateBuilder = FakeEventUpdateBuilder(Future.value([]));
      when(() => queryBuilder.update(any())).thenAnswer((_) => updateBuilder);

      await expectLater(
        repository.completeEvent('event-001'),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('Event not found or permission denied'),
          ),
        ),
      );
      expect(updateBuilder.filters, {'id': 'event-001'});
      expect(updateBuilder.selectCalls, ['id']);
    });

    test('succeeds when an event was updated', () async {
      final updateBuilder = FakeEventUpdateBuilder(
        Future.value([
          {'id': 'event-001'},
        ]),
      );
      when(() => queryBuilder.update(any())).thenAnswer((_) => updateBuilder);

      await expectLater(repository.completeEvent('event-001'), completes);
    });
  });

  test('returns group metrics sorted by total delay descending', () async {
    final response = [
      {
        'id': 'user-001',
        'nickname': 'A',
        'avatar_url': null,
        'streak': 2,
        'total_delay_minutes': 35,
        'avg_delay_minutes': 12,
      },
      {
        'id': 'user-002',
        'nickname': 'B',
        'avatar_url': 'https://example.com/avatar.png',
        'streak': 1,
        'total_delay_minutes': 80,
        'avg_delay_minutes': 40,
      },
    ];
    when(
      () => mockClient.rpc(
        'get_group_rankings',
        params: {'p_group_id': 'group-001'},
      ),
    ).thenAnswer((_) => FakeRankingRpcBuilder(Future.value(response)));

    final rankings = await repository.getGroupRankings('group-001');

    expect(rankings.map((user) => user.id), ['user-002', 'user-001']);
    expect(rankings.first.totalDelayMinutes, 80);
    expect(rankings.first.avgDelayMinutes, 40);
    verify(
      () => mockClient.rpc(
        'get_group_rankings',
        params: {'p_group_id': 'group-001'},
      ),
    ).called(1);
  });
}
