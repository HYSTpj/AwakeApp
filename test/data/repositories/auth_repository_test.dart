import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/data/repositories/auth_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<PostgrestList> {}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<PostgrestList> {}

// single() の戻り値として Future を正しく委譲する Fake クラス
class FakePostgrestMapTransformBuilder extends Fake
    implements PostgrestTransformBuilder<PostgrestMap> {
  final Future<PostgrestMap> _future;

  FakePostgrestMapTransformBuilder(PostgrestMap response)
    : _future = Future.value(response);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(PostgrestMap value) onValue, {
    Function? onError,
  }) {
    return _future.then(onValue, onError: onError);
  }
}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late SupabaseAuthRepository repository;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();

    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    repository = SupabaseAuthRepository(mockSupabaseClient);
  });

  group('SupabaseAuthRepository - updateNickname テスト', () {
    test('未ログイン時: Exception が投げられること', () async {
      when(() => mockGoTrueClient.currentUser).thenReturn(null);

      expect(
        () => repository.updateNickname('ValidName'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('ユーザーが認証されていません'),
          ),
        ),
      );
    });

    test('空白のみの名前を渡した場合: 通信前に ArgumentError が投げられること', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('test-user-id');
      when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

      expect(
        () => repository.updateNickname(''),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => repository.updateNickname('   '),
        throwsA(isA<ArgumentError>()),
      );

      verifyNever(() => mockSupabaseClient.from(any()));
    });

    test('30文字を超える名前を渡した場合: 通信前に ArgumentError が投げられること', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('test-user-id');
      when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

      final over30Chars = 'a' * 31;

      expect(
        () => repository.updateNickname(over30Chars),
        throwsA(isA<ArgumentError>()),
      );

      verifyNever(() => mockSupabaseClient.from(any()));
    });

    test(
      '前後に空白がある有効な名前を渡した場合: trim された名前で Supabase に update が発行されること',
      () async {
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('test-user-id');
        when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

        final dummyResponse = <String, dynamic>{
          'id': 'test-user-id',
          'nickname': 'Alice',
          'avatar_url': null,
          'sleep_past_count': 0,
          'late_count': 0,
          'created_at': '2026-09-21T00:00:00.000Z',
          'updated_at': '2026-10-21T00:00:00.000Z',
        };

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilder();
        final mockTransformBuilder = MockPostgrestTransformBuilder();
        final fakeMapTransformBuilder = FakePostgrestMapTransformBuilder(
          dummyResponse,
        );

        when(
          () => mockSupabaseClient.from('profiles'),
        ).thenAnswer((_) => mockQueryBuilder);
        when(
          () => mockQueryBuilder.update(any()),
        ).thenAnswer((_) => mockFilterBuilder);
        when(
          () => mockFilterBuilder.eq('id', 'test-user-id'),
        ).thenAnswer((_) => mockFilterBuilder);
        when(
          () => mockFilterBuilder.select(),
        ).thenAnswer((_) => mockTransformBuilder);

        // single() は fakeMapTransformBuilder を返す（.then の委譲により await が正常完了する）
        when(
          () => mockTransformBuilder.single(),
        ).thenAnswer((_) => fakeMapTransformBuilder);

        final result = await repository.updateNickname('   Alice   ');

        expect(result.nickname, equals('Alice'));

        final captured = verify(
          () => mockQueryBuilder.update(captureAny()),
        ).captured;
        final updatePayload = Map<String, dynamic>.from(captured.first as Map);
        expect(updatePayload['nickname'], equals('Alice'));
      },
    );
  });
}
