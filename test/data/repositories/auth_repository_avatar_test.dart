import 'dart:io';

import 'package:flutter_application_1/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_repository_test_mocks.dart';

void main() {
  setUpAll(() {
    registerAuthRepositoryTestFallbacks();
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

  group('SupabaseAuthRepository.updateAvatar', () {
    test('未ログイン状態の場合、AuthException を投げること', () async {
      when(() => mockGoTrueClient.currentUser).thenReturn(null);

      expect(
        () => repository.updateAvatar(File('dummy.jpg')),
        throwsA(isA<AuthException>()),
      );
    });

    test(
      '画像ファイルが指定された場合: Storage にアップロードされ、profiles.update が発行されること',
      () async {
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('test-user-id');
        when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

        final dummyResponse = <String, dynamic>{
          'id': 'test-user-id',
          'nickname': 'TestUser',
          'avatar_url': 'https://example.com/new_avatar.jpg',
          'sleep_past_count': 0,
          'late_count': 0,
          'created_at': '2026-09-21T00:00:00.000Z',
          'updated_at': '2026-10-22T00:00:00.000Z',
        };

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilder();
        when(
          () => mockSupabaseClient.from('profiles'),
        ).thenAnswer((_) => mockQueryBuilder);
        when(
          () => mockQueryBuilder.select('avatar_url'),
        ).thenAnswer((_) => mockFilterBuilder);
        when(
          () => mockFilterBuilder.eq('id', 'test-user-id'),
        ).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.maybeSingle()).thenAnswer(
          (_) => FakePostgrestNullableMapTransformBuilder({'avatar_url': null}),
        );

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
        ).thenReturn('https://example.com/new_avatar.jpg');

        final mockTransformBuilder = MockPostgrestTransformBuilder();
        final fakeMapTransformBuilder = FakePostgrestMapTransformBuilder(
          dummyResponse,
        );

        when(
          () => mockQueryBuilder.update(any()),
        ).thenAnswer((_) => mockFilterBuilder);
        when(
          () => mockFilterBuilder.select(),
        ).thenAnswer((_) => mockTransformBuilder);
        when(
          () => mockTransformBuilder.single(),
        ).thenAnswer((_) => fakeMapTransformBuilder);

        final dummyFile = File('dummy.jpg');
        final result = await repository.updateAvatar(dummyFile);

        expect(result.avatarUrl, equals('https://example.com/new_avatar.jpg'));

        verify(
          () => mockStorageFileApi.upload(
            any(that: contains('test-user-id/avatar_')),
            dummyFile,
            fileOptions: any(named: 'fileOptions'),
          ),
        ).called(1);

        final captured = verify(
          () => mockQueryBuilder.update(captureAny()),
        ).captured;
        final payload = Map<String, dynamic>.from(captured.first as Map);
        expect(
          payload['avatar_url'],
          equals('https://example.com/new_avatar.jpg'),
        );
      },
    );

    test(
      'Storage へのアップロードが失敗した場合: profiles は更新されず StorageException を投げること',
      () async {
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('test-user-id');
        when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilder();
        when(
          () => mockSupabaseClient.from('profiles'),
        ).thenAnswer((_) => mockQueryBuilder);
        when(
          () => mockQueryBuilder.select(any()),
        ).thenAnswer((_) => mockFilterBuilder);
        when(
          () => mockFilterBuilder.eq('id', 'test-user-id'),
        ).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.maybeSingle()).thenAnswer(
          (_) => FakePostgrestNullableMapTransformBuilder({'avatar_url': null}),
        );

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
        ).thenThrow(const StorageException('Upload failed'));

        expect(
          () => repository.updateAvatar(File('dummy.jpg')),
          throwsA(isA<StorageException>()),
        );

        verifyNever(() => mockQueryBuilder.update(any()));
      },
    );

    test('古い画像が存在する場合: プロフィール更新成功後に古い画像が削除されること', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('test-user-id');
      when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

      const oldPath = 'test-user-id/avatar_old.jpg';
      const oldUrl =
          'https://example.com/storage/v1/object/public/avatars/$oldPath';

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
      ).thenAnswer((_) async => 'path/to/new_avatar');
      when(
        () => mockStorageFileApi.getPublicUrl(any()),
      ).thenReturn('https://example.com/new_avatar.jpg');
      when(
        () => mockStorageFileApi.remove(any<List<String>>()),
      ).thenAnswer((_) async => <FileObject>[]);

      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockSelectFilterBuilder = MockPostgrestFilterBuilder();
      when(
        () => mockSupabaseClient.from('profiles'),
      ).thenAnswer((_) => mockQueryBuilder);
      when(
        () => mockQueryBuilder.select('avatar_url'),
      ).thenAnswer((_) => mockSelectFilterBuilder);
      when(
        () => mockSelectFilterBuilder.eq('id', 'test-user-id'),
      ).thenAnswer((_) => mockSelectFilterBuilder);
      when(() => mockSelectFilterBuilder.maybeSingle()).thenAnswer(
        (_) => FakePostgrestNullableMapTransformBuilder({'avatar_url': oldUrl}),
      );

      final mockUpdateFilterBuilder = MockPostgrestFilterBuilder();
      final mockTransformBuilder = MockPostgrestTransformBuilder();
      final fakeMapTransformBuilder = FakePostgrestMapTransformBuilder({
        'id': 'test-user-id',
        'nickname': 'TestUser',
        'avatar_url': 'https://example.com/new_avatar.jpg',
        'sleep_past_count': 0,
        'late_count': 0,
        'created_at': '2026-09-21T00:00:00.000Z',
        'updated_at': '2026-10-22T00:00:00.000Z',
      });

      when(
        () => mockQueryBuilder.update(any()),
      ).thenAnswer((_) => mockUpdateFilterBuilder);
      when(
        () => mockUpdateFilterBuilder.eq('id', 'test-user-id'),
      ).thenAnswer((_) => mockUpdateFilterBuilder);
      when(
        () => mockUpdateFilterBuilder.select(),
      ).thenAnswer((_) => mockTransformBuilder);
      when(
        () => mockTransformBuilder.single(),
      ).thenAnswer((_) => fakeMapTransformBuilder);

      final result = await repository.updateAvatar(File('dummy.jpg'));

      expect(result.avatarUrl, equals('https://example.com/new_avatar.jpg'));
      verify(() => mockStorageFileApi.remove([oldPath])).called(1);
    });

    test('profiles の更新が失敗した場合: アップロード済みの新画像が削除（ロールバック）され、例外を投げること', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('test-user-id');
      when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

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
      ).thenReturn('https://example.com/new_avatar.jpg');
      when(
        () => mockStorageFileApi.remove(any<List<String>>()),
      ).thenAnswer((_) async => <FileObject>[]);

      final mockSelectQueryBuilder = MockSupabaseQueryBuilder();
      final mockUpdateQueryBuilder = MockSupabaseQueryBuilder();

      var fromCallCount = 0;
      when(() => mockSupabaseClient.from('profiles')).thenAnswer((_) {
        fromCallCount++;
        return fromCallCount == 1
            ? mockSelectQueryBuilder
            : mockUpdateQueryBuilder;
      });

      final mockSelectFilterBuilder = MockPostgrestFilterBuilder();
      when(
        () => mockSelectQueryBuilder.select(any()),
      ).thenAnswer((_) => mockSelectFilterBuilder);
      when(
        () => mockSelectFilterBuilder.eq('id', 'test-user-id'),
      ).thenAnswer((_) => mockSelectFilterBuilder);
      when(() => mockSelectFilterBuilder.maybeSingle()).thenAnswer(
        (_) => FakePostgrestNullableMapTransformBuilder({'avatar_url': null}),
      );

      final mockUpdateFilterBuilder = MockPostgrestFilterBuilder();
      final mockTransformBuilder = MockPostgrestTransformBuilder();

      when(
        () => mockUpdateQueryBuilder.update(any()),
      ).thenAnswer((_) => mockUpdateFilterBuilder);
      when(
        () => mockUpdateFilterBuilder.eq('id', 'test-user-id'),
      ).thenAnswer((_) => mockUpdateFilterBuilder);
      when(
        () => mockUpdateFilterBuilder.select(),
      ).thenAnswer((_) => mockTransformBuilder);
      when(() => mockTransformBuilder.single()).thenAnswer(
        (_) => FakePostgrestErrorTransformBuilder(
          const PostgrestException(message: 'DB Error'),
        ),
      );

      expect(
        () => repository.updateAvatar(File('dummy.jpg')),
        throwsA(isA<PostgrestException>()),
      );

      await untilCalled(() => mockStorageFileApi.remove(any<List<String>>()));

      final captured = verify(
        () => mockStorageFileApi.remove(captureAny<List<String>>()),
      ).captured;
      expect(captured.isNotEmpty, isTrue);

      final removedList = captured.first as List<String>;
      expect(removedList.length, equals(1));
      expect(removedList.first, startsWith('test-user-id/avatar_'));
    });
  });
}
