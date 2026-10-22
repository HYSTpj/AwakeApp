import 'dart:io';

import 'package:flutter_application_1/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  group('SupabaseAuthRepository.updateProfile', () {
    test('未ログイン状態の場合、AuthException を投げること', () async {
      when(() => mockGoTrueClient.currentUser).thenReturn(null);

      expect(
        () => repository.updateProfile(nickname: 'NewName'),
        throwsA(isA<AuthException>()),
      );
    });

    test('空白のみの名前を渡した場合: 通信前に ArgumentError が投げられること', () async {
      expect(
        () => repository.updateProfile(nickname: ''),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => repository.updateProfile(nickname: '    '),
        throwsA(isA<ArgumentError>()),
      );

      verifyNever(() => mockSupabaseClient.from(any()));
    });

    test('30文字を超える名前を渡した場合: 通信前に ArgumentError が投げられること', () async {
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
        final dummyProfile = <String, dynamic>{
          'id': testUserId,
          'nickname': 'Bob',
          'avatar_url': null,
          'sleep_past_count': 0,
          'late_count': 0,
          'created_at': '2026-09-21T00:00:00.000Z',
          'updated_at': '2026-10-21T00:00:00.000Z',
        };

        final mockFilterBuilder = MockPostgrestFilterBuilder();
        final fakeUpsertBuilder = FakePostgrestFilterBuilder();
        final fakeMaybeSingleBuilder = FakePostgrestNullableMapTransformBuilder(
          dummyProfile,
        );

        when(
          () => mockQueryBuilder.upsert(any()),
        ).thenAnswer((_) => fakeUpsertBuilder);
        when(
          () => mockQueryBuilder.select(),
        ).thenAnswer((_) => mockFilterBuilder);
        when(
          () => mockFilterBuilder.eq('id', testUserId),
        ).thenAnswer((_) => mockFilterBuilder);
        when(
          () => mockFilterBuilder.maybeSingle(),
        ).thenAnswer((_) => fakeMaybeSingleBuilder);

        final result = await repository.updateProfile(nickname: '    Bob    ');

        expect(result.nickname, equals('Bob'));

        final captured = verify(
          () => mockQueryBuilder.upsert(captureAny()),
        ).captured;
        final payload = Map<String, dynamic>.from(captured.first as Map);
        expect(payload['nickname'], equals('Bob'));
        expect(payload['id'], equals(testUserId));
        expect(payload.containsKey('avatar_url'), isFalse);

        verifyNever(
          () => mockStorageFileApi.upload(
            any(),
            any(),
            fileOptions: any(named: 'fileOptions'),
          ),
        );
        verifyNever(() => mockStorageFileApi.remove(any()));
      },
    );

    test('PNG 画像指定時: 正しい拡張子と Content-Type (image/png) でアップロードされること', () async {
      final mockPngFile = MockFile();
      when(() => mockPngFile.path).thenReturn('/tmp/avatar.png');

      when(
        () => mockStorageFileApi.upload(
          any(that: endsWith('.png')),
          mockPngFile,
          fileOptions: any(
            named: 'fileOptions',
            that: predicate<FileOptions>(
              (opt) => opt.contentType == 'image/png',
            ),
          ),
        ),
      ).thenAnswer((_) async => 'uploaded_path.png');

      when(
        () => mockStorageFileApi.getPublicUrl(any()),
      ).thenReturn('https://example.com/avatar.png');

      final dummyProfile = <String, dynamic>{
        'id': testUserId,
        'nickname': 'TestUser',
        'avatar_url': 'https://example.com/avatar.png',
        'sleep_past_count': 0,
        'late_count': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final mockFilterBuilder = MockPostgrestFilterBuilder();
      final fakeUpsertBuilder = FakePostgrestFilterBuilder();
      final fakeMaybeSingleBuilder = FakePostgrestNullableMapTransformBuilder(
        dummyProfile,
      );

      when(
        () => mockQueryBuilder.upsert(any()),
      ).thenAnswer((_) => fakeUpsertBuilder);
      when(
        () => mockQueryBuilder.select(),
      ).thenAnswer((_) => mockFilterBuilder);
      when(
        () => mockFilterBuilder.eq('id', testUserId),
      ).thenAnswer((_) => mockFilterBuilder);
      when(
        () => mockFilterBuilder.maybeSingle(),
      ).thenAnswer((_) => fakeMaybeSingleBuilder);

      final result = await repository.updateProfile(
        nickname: 'TestUser',
        avatarImage: mockPngFile,
      );

      expect(result.avatarUrl, equals('https://example.com/avatar.png'));

      verify(
        () => mockStorageFileApi.upload(
          any(
            that: predicate<String>(
              (path) =>
                  path.startsWith('$testUserId/') && path.endsWith('.png'),
            ),
          ),
          mockPngFile,
          fileOptions: any(
            named: 'fileOptions',
            that: predicate<FileOptions>(
              (opt) => opt.contentType == 'image/png',
            ),
          ),
        ),
      ).called(1);
    });

    test(
      'HEIC 画像指定時: 正しい拡張子と Content-Type (image/heic) でアップロードされること',
      () async {
        final mockHeicFile = MockFile();
        when(() => mockHeicFile.path).thenReturn('/tmp/photo.HEIC');

        when(
          () => mockStorageFileApi.upload(
            any(that: endsWith('.heic')),
            mockHeicFile,
            fileOptions: any(
              named: 'fileOptions',
              that: predicate<FileOptions>(
                (opt) => opt.contentType == 'image/heic',
              ),
            ),
          ),
        ).thenAnswer((_) async => 'uploaded_path.heic');

        when(
          () => mockStorageFileApi.getPublicUrl(any()),
        ).thenReturn('https://example.com/avatar.heic');

        final dummyProfile = <String, dynamic>{
          'id': testUserId,
          'nickname': 'TestUser',
          'avatar_url': 'https://example.com/avatar.heic',
          'sleep_past_count': 0,
          'late_count': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        final mockFilterBuilder = MockPostgrestFilterBuilder();
        final fakeUpsertBuilder = FakePostgrestFilterBuilder();
        final fakeMaybeSingleBuilder = FakePostgrestNullableMapTransformBuilder(
          dummyProfile,
        );

        when(
          () => mockQueryBuilder.upsert(any()),
        ).thenAnswer((_) => fakeUpsertBuilder);
        when(
          () => mockQueryBuilder.select(),
        ).thenAnswer((_) => mockFilterBuilder);
        when(
          () => mockFilterBuilder.eq('id', testUserId),
        ).thenAnswer((_) => mockFilterBuilder);
        when(
          () => mockFilterBuilder.maybeSingle(),
        ).thenAnswer((_) => fakeMaybeSingleBuilder);

        await repository.updateProfile(
          nickname: 'TestUser',
          avatarImage: mockHeicFile,
        );

        verify(
          () => mockStorageFileApi.upload(
            any(that: predicate<String>((path) => path.endsWith('.heic'))),
            mockHeicFile,
            fileOptions: any(
              named: 'fileOptions',
              that: predicate<FileOptions>(
                (opt) => opt.contentType == 'image/heic',
              ),
            ),
          ),
        ).called(1);
      },
    );

    test(
      'DB 更新失敗時: アップロードされた画像が Storage から削除（ロールバック）され、例外が再スローされること',
      () async {
        final mockJpegFile = MockFile();
        when(() => mockJpegFile.path).thenReturn('/tmp/avatar.jpg');

        when(
          () => mockStorageFileApi.upload(
            any(),
            mockJpegFile,
            fileOptions: any(named: 'fileOptions'),
          ),
        ).thenAnswer((_) async => 'uploaded_path.jpg');

        when(
          () => mockStorageFileApi.getPublicUrl(any()),
        ).thenReturn('https://example.com/avatar.jpg');

        when(
          () => mockStorageFileApi.remove(any()),
        ).thenAnswer((_) async => []);

        when(() => mockQueryBuilder.upsert(any())).thenAnswer(
          (_) => FakePostgrestFilterBuilder.error(
            const PostgrestException(message: 'DB connection error'),
          ),
        );

        await expectLater(
          () => repository.updateProfile(
            nickname: 'TestUser',
            avatarImage: mockJpegFile,
          ),
          throwsA(isA<PostgrestException>()),
        );

        verify(
          () => mockStorageFileApi.remove(
            any(
              that: predicate<List<String>>((paths) {
                return paths.length == 1 &&
                    paths.first.startsWith('$testUserId/avatar_') &&
                    paths.first.endsWith('.jpg');
              }),
            ),
          ),
        ).called(1);
      },
    );
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
