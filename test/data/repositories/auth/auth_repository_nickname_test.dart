import 'dart:io';

import 'package:flutter_application_1/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'auth_repository_test_mocks.dart';

class MockFile extends Mock implements File {}

void main() {
  setUpAll(() {
    registerAuthRepositoryTestFallbacks();
  });

  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockSupabaseStorageClient mockStorageClient;
  late MockStorageFileApi mockStorageFileApi;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late SupabaseAuthRepository repository;

  final mockUser = MockUser();
  const testUserId = 'test-user-id';

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockStorageClient = MockSupabaseStorageClient();
    mockStorageFileApi = MockStorageFileApi();
    mockQueryBuilder = MockSupabaseQueryBuilder();

    when(() => mockUser.id).thenReturn(testUserId);
    when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    when(() => mockSupabaseClient.storage).thenReturn(mockStorageClient);
    when(
      () => mockStorageClient.from('avatars'),
    ).thenReturn(mockStorageFileApi);

    when(
      () => mockSupabaseClient.from('profiles'),
    ).thenAnswer((_) => mockQueryBuilder);

    repository = SupabaseAuthRepository(mockSupabaseClient);
  });

  group('SupabaseAuthRepository.updateNickname', () {
    test('未ログイン時: Exception が投げられること', () async {
      when(() => mockGoTrueClient.currentUser).thenReturn(null);

      expect(
        () => repository.updateNickname('ValidName'),
        throwsA(
          predicate<Exception>((e) => e.toString().contains('ユーザーが認証されていません')),
        ),
      );
    });

    test('空白のみの名前を渡した場合: 通信前に ArgumentError が投げられること', () async {
      expect(
        () => repository.updateNickname(''),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => repository.updateNickname('    '),
        throwsA(isA<ArgumentError>()),
      );

      verifyNever(() => mockSupabaseClient.from(any()));
    });

    test('30文字を超える名前を渡した場合: 通信前に ArgumentError が投げられること', () async {
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
        final dummyResponse = <String, dynamic>{
          'id': testUserId,
          'nickname': 'Alice',
          'avatar_url': null,
          'sleep_past_count': 0,
          'late_count': 0,
          'created_at': '2026-09-21T00:00:00.000Z',
          'updated_at': '2026-10-21T00:00:00.000Z',
        };

        final mockFilterBuilder = MockPostgrestFilterBuilder();
        final mockTransformBuilder = MockPostgrestTransformBuilder();
        final fakeMapTransformBuilder = FakePostgrestMapTransformBuilder(
          dummyResponse,
        );

        when(
          () => mockQueryBuilder.update(any()),
        ).thenAnswer((_) => mockFilterBuilder);
        when(
          () => mockFilterBuilder.eq('id', testUserId),
        ).thenAnswer((_) => mockFilterBuilder);
        when(
          () => mockFilterBuilder.select(),
        ).thenAnswer((_) => mockTransformBuilder);
        when(
          () => mockTransformBuilder.single(),
        ).thenAnswer((_) => fakeMapTransformBuilder);

        final result = await repository.updateNickname('    Alice    ');

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
