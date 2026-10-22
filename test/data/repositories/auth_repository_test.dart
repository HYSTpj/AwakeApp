import 'dart:async';
import 'dart:io';

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

class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {}

class MockStorageFileApi extends Mock implements StorageFileApi {}

// File の Mocktail フォールバック用 Fake
class FakeFile extends Fake implements File {}

class FakeFileOptions extends Fake implements FileOptions {}

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

// 💡 maybeSingle() の戻り値として PostgrestTransformBuilder<PostgrestMap?> を委譲する Fake クラス
class FakePostgrestNullableMapTransformBuilder extends Fake
    implements PostgrestTransformBuilder<PostgrestMap?> {
  final Future<PostgrestMap?> _future;

  FakePostgrestNullableMapTransformBuilder(PostgrestMap? response)
    : _future = Future.value(response);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(PostgrestMap? value) onValue, {
    Function? onError,
  }) {
    return _future.then(onValue, onError: onError);
  }
}

// upsert() の戻り値として Future を正しく委譲する Fake クラス
class FakePostgrestFilterBuilder extends Fake
    implements PostgrestFilterBuilder<PostgrestList> {
  final Future<PostgrestList> _future;

  FakePostgrestFilterBuilder([PostgrestList? response])
    : _future = Future.value(response ?? []);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(PostgrestList value) onValue, {
    Function? onError,
  }) {
    return _future.then(onValue, onError: onError);
  }
}

void main() {
  setUpAll(() {
    // 💡 File および FileOptions の Fallback を登録
    registerFallbackValue(FakeFile());
    registerFallbackValue(const FileOptions());
  });

  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late SupabaseAuthRepository repository;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();

    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    repository = SupabaseAuthRepository(mockSupabaseClient);
  });

  group('SupabaseAuthRepository.signUp', () {
    test(
      'session が null（メール確認待ち）の場合、EmailConfirmationPendingException を投げること',
      () async {
        final user = User(
          id: 'user-uuid-1234',
          appMetadata: const {},
          userMetadata: const {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        );

        when(
          () => mockGoTrueClient.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => AuthResponse(session: null, user: user));

        expect(
          () => repository.signUp(
            email: 'pending@example.com',
            password: 'password123',
          ),
          throwsA(isA<EmailConfirmationPendingException>()),
        );
      },
    );

    test('user が null の場合、AuthException を投げること', () async {
      when(
        () => mockGoTrueClient.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => AuthResponse(session: null, user: null));

      expect(
        () => repository.signUp(
          email: 'fail@example.com',
          password: 'password123',
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('SupabaseAuthRepository.updateProfile', () {
    test('未ログイン状態の場合、AuthException を投げること', () async {
      when(() => mockGoTrueClient.currentUser).thenReturn(null);

      expect(
        () => repository.updateProfile(nickname: 'NewName'),
        throwsA(isA<AuthException>()),
      );
    });

    test('空白のみの名前を渡した場合: 通信前に ArgumentError が投げられること', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('test-user-id');
      when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

      expect(
        () => repository.updateProfile(nickname: ''),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => repository.updateProfile(nickname: '   '),
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
        () => repository.updateProfile(nickname: over30Chars),
        throwsA(isA<ArgumentError>()),
      );

      verifyNever(() => mockSupabaseClient.from(any()));
    });

    test(
      '前後に空白がある有効な名前と画像なしの場合: trim された名前で profiles に upsert され、プロフィールが再取得されること',
      () async {
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('test-user-id');
        when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

        final dummyProfile = <String, dynamic>{
          'id': 'test-user-id',
          'nickname': 'Bob',
          'avatar_url': null,
          'sleep_past_count': 0,
          'late_count': 0,
          'created_at': '2026-09-21T00:00:00.000Z',
          'updated_at': '2026-10-21T00:00:00.000Z',
        };

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilder();
        final fakeUpsertBuilder = FakePostgrestFilterBuilder();
        final fakeMaybeSingleBuilder = FakePostgrestNullableMapTransformBuilder(
          dummyProfile,
        );

        when(
          () => mockSupabaseClient.from('profiles'),
        ).thenAnswer((_) => mockQueryBuilder);
        when(
          () => mockQueryBuilder.upsert(any()),
        ).thenAnswer((_) => fakeUpsertBuilder);
        when(
          () => mockQueryBuilder.select(),
        ).thenAnswer((_) => mockFilterBuilder);
        when(
          () => mockFilterBuilder.eq('id', 'test-user-id'),
        ).thenAnswer((_) => mockFilterBuilder);
        // 💡 maybeSingle() は FakePostgrestNullableMapTransformBuilder を返す
        when(
          () => mockFilterBuilder.maybeSingle(),
        ).thenAnswer((_) => fakeMaybeSingleBuilder);

        final result = await repository.updateProfile(nickname: '   Bob   ');

        expect(result.nickname, equals('Bob'));

        final captured = verify(
          () => mockQueryBuilder.upsert(captureAny()),
        ).captured;
        final payload = Map<String, dynamic>.from(captured.first as Map);
        expect(payload['nickname'], equals('Bob'));
        expect(payload['id'], equals('test-user-id'));
        expect(payload.containsKey('avatar_url'), isFalse);
      },
    );

    test('画像ファイルが指定された場合: Storage にアップロードされ、URL を含めて upsert されること', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('test-user-id');
      when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

      final dummyProfile = <String, dynamic>{
        'id': 'test-user-id',
        'nickname': 'Bob',
        'avatar_url': 'https://example.com/avatar.jpg',
        'sleep_past_count': 0,
        'late_count': 0,
        'created_at': '2026-09-21T00:00:00.000Z',
        'updated_at': '2026-10-21T00:00:00.000Z',
      };

      final mockStorage = MockSupabaseStorageClient();
      final mockStorageFileApi = MockStorageFileApi();
      when(() => mockSupabaseClient.storage).thenReturn(mockStorage);
      when(() => mockStorage.from('avatars')).thenReturn(mockStorageFileApi);
      when(
        () => mockStorageFileApi.upload(
          any(),
          any(),
          fileOptions: any(named: 'fileOptions'),
        ),
      ).thenAnswer((_) async => 'path/to/avatar');
      when(
        () => mockStorageFileApi.getPublicUrl(any()),
      ).thenReturn('https://example.com/avatar.jpg');

      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();
      final fakeUpsertBuilder = FakePostgrestFilterBuilder();
      final fakeMaybeSingleBuilder = FakePostgrestNullableMapTransformBuilder(
        dummyProfile,
      );

      when(
        () => mockSupabaseClient.from('profiles'),
      ).thenAnswer((_) => mockQueryBuilder);
      when(
        () => mockQueryBuilder.upsert(any()),
      ).thenAnswer((_) => fakeUpsertBuilder);
      when(
        () => mockQueryBuilder.select(),
      ).thenAnswer((_) => mockFilterBuilder);
      when(
        () => mockFilterBuilder.eq('id', 'test-user-id'),
      ).thenAnswer((_) => mockFilterBuilder);
      when(
        () => mockFilterBuilder.maybeSingle(),
      ).thenAnswer((_) => fakeMaybeSingleBuilder);

      final dummyFile = File('dummy/path/avatar.jpg');

      final result = await repository.updateProfile(
        nickname: 'Bob',
        avatarImage: dummyFile,
      );

      expect(result.avatarUrl, equals('https://example.com/avatar.jpg'));

      verify(
        () => mockStorageFileApi.upload(
          any(that: contains('test-user-id/avatar_')),
          dummyFile,
          fileOptions: any(named: 'fileOptions'),
        ),
      ).called(1);

      final captured = verify(
        () => mockQueryBuilder.upsert(captureAny()),
      ).captured;
      final payload = Map<String, dynamic>.from(captured.first as Map);
      expect(payload['avatar_url'], equals('https://example.com/avatar.jpg'));
    });
  });

  group('SupabaseAuthRepository - updateNickname テスト', () {
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
