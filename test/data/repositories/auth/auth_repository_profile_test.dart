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

  group('SupabaseAuthRepository.deleteAccount', () {
    late MockStorageFileApi mockLateStorageApi;

    setUp(() {
      mockLateStorageApi = MockStorageFileApi();
      when(
        () => mockStorageClient.from('late-evidences'),
      ).thenReturn(mockLateStorageApi);

      when(
        () => mockStorageFileApi.list(
          path: any(named: 'path'),
          searchOptions: any(named: 'searchOptions'),
        ),
      ).thenAnswer((_) async => <FileObject>[]);

      when(
        () => mockLateStorageApi.list(
          path: any(named: 'path'),
          searchOptions: any(named: 'searchOptions'),
        ),
      ).thenAnswer((_) async => <FileObject>[]);

      when(() => mockStorageFileApi.remove(any())).thenAnswer((_) async => []);
      when(() => mockLateStorageApi.remove(any())).thenAnswer((_) async => []);
    });

    test('未ログイン状態では AuthException を投げること', () async {
      when(() => mockGoTrueClient.currentUser).thenReturn(null);

      expect(() => repository.deleteAccount(), throwsA(isA<AuthException>()));
    });

    test(
      'RPC呼び出しが失敗した場合: AuthException をスローし、Storage削除やsignOutは行われないこと',
      () async {
        when(() => mockSupabaseClient.rpc('delete_user')).thenAnswer(
          (_) => FakePostgrestFilterBuilder.error(
            const PostgrestException(message: 'DB Error'),
          ),
        );

        await expectLater(
          () => repository.deleteAccount(),
          throwsA(isA<AuthException>()),
        );

        // RPC が失敗した段階で中断するため、Storage削除や signOut は一切実行されない
        verifyNever(() => mockStorageFileApi.remove(any()));
        verifyNever(() => mockLateStorageApi.remove(any()));
        verifyNever(() => mockGoTrueClient.signOut());
      },
    );

    test(
      '【順序検証】RPC成功後、Storage削除（avatars/late-evidences）が実行され、最後にsignOutが呼ばれること',
      () async {
        when(
          () => mockSupabaseClient.rpc('delete_user'),
        ).thenAnswer((_) => FakePostgrestFilterBuilder());
        when(() => mockGoTrueClient.signOut()).thenAnswer((_) async {});

        // avatars にファイルが存在する設定
        final avatarFile = FileObject.fromJson(<String, dynamic>{
          'name': 'avatar_1.jpg',
          'id': '1',
          'updated_at': '',
          'created_at': '',
          'last_accessed_at': '',
          'metadata': <String, dynamic>{},
          'bucket_id': 'avatars',
          'owner': testUserId,
        });
        when(
          () => mockStorageFileApi.list(
            path: testUserId,
            searchOptions: any(named: 'searchOptions'),
          ),
        ).thenAnswer((_) async => [avatarFile]);

        await repository.deleteAccount();

        verifyInOrder([
          () => mockSupabaseClient.rpc('delete_user'),
          () => mockStorageFileApi.remove(['$testUserId/avatar_1.jpg']),
          () => mockGoTrueClient.signOut(),
        ]);
      },
    );

    test(
      '【パス完全性検証】101件のファイルが存在する場合: 全パスが欠落なく100件と1件のチャンクに分割されて削除されること',
      () async {
        when(
          () => mockSupabaseClient.rpc('delete_user'),
        ).thenAnswer((_) => FakePostgrestFilterBuilder());
        when(() => mockGoTrueClient.signOut()).thenAnswer((_) async {});

        final dummyFilesPage1 = List.generate(
          100,
          (i) => FileObject.fromJson(<String, dynamic>{
            'name': 'file_$i.jpg',
            'id': '$i',
            'updated_at': '',
            'created_at': '',
            'last_accessed_at': '',
            'metadata': <String, dynamic>{},
            'bucket_id': 'avatars',
            'owner': testUserId,
          }),
        );
        final dummyFilesPage2 = [
          FileObject.fromJson(<String, dynamic>{
            'name': 'file_100.jpg',
            'id': '100',
            'updated_at': '',
            'created_at': '',
            'last_accessed_at': '',
            'metadata': <String, dynamic>{},
            'bucket_id': 'avatars',
            'owner': testUserId,
          }),
        ];

        when(
          () => mockStorageFileApi.list(
            path: any(named: 'path'),
            searchOptions: any(
              named: 'searchOptions',
              that: predicate<SearchOptions>((opt) => opt.offset == 0),
            ),
          ),
        ).thenAnswer((_) async => dummyFilesPage1);

        when(
          () => mockStorageFileApi.list(
            path: any(named: 'path'),
            searchOptions: any(
              named: 'searchOptions',
              that: predicate<SearchOptions>((opt) => opt.offset == 100),
            ),
          ),
        ).thenAnswer((_) async => dummyFilesPage2);

        await repository.deleteAccount();

        final capturedRemoves = verify(
          () => mockStorageFileApi.remove(captureAny()),
        ).captured;
        expect(capturedRemoves.length, equals(2));

        // 1チャンク目のパス完全性検証 (0〜99)
        final chunk1 = capturedRemoves[0] as List<String>;
        expect(chunk1.length, equals(100));
        for (int i = 0; i < 100; i++) {
          expect(chunk1[i], equals('$testUserId/file_$i.jpg'));
        }

        // 2チャンク目のパス完全性検証 (100)
        final chunk2 = capturedRemoves[1] as List<String>;
        expect(chunk2.length, equals(1));
        expect(chunk2[0], equals('$testUserId/file_100.jpg'));
      },
    );

    test(
      '【階層探索検証】late-evidences の階層構造 (userId/eventId/...) を正しく走査して全ファイルが削除されること',
      () async {
        when(
          () => mockSupabaseClient.rpc('delete_user'),
        ).thenAnswer((_) => FakePostgrestFilterBuilder());
        when(() => mockGoTrueClient.signOut()).thenAnswer((_) async {});

        // 1. $userId 直下のイベントフォルダ一覧 (event_a, event_b)
        final eventDirA = FileObject.fromJson(<String, dynamic>{
          'name': 'event_a',
          'id': 'dir-a',
          'updated_at': '',
          'created_at': '',
          'last_accessed_at': '',
          'metadata': <String, dynamic>{},
        });
        final eventDirB = FileObject.fromJson(<String, dynamic>{
          'name': 'event_b',
          'id': 'dir-b',
          'updated_at': '',
          'created_at': '',
          'last_accessed_at': '',
          'metadata': <String, dynamic>{},
        });
        when(
          () => mockLateStorageApi.list(
            path: testUserId,
            searchOptions: any(named: 'searchOptions'),
          ),
        ).thenAnswer((_) async => [eventDirA, eventDirB]);

        // 2. event_a 配下のファイル (photo1.jpg)
        final fileA1 = FileObject.fromJson(<String, dynamic>{
          'name': 'photo1.jpg',
          'id': 'f-a1',
          'updated_at': '',
          'created_at': '',
          'last_accessed_at': '',
          'metadata': <String, dynamic>{},
        });
        when(
          () => mockLateStorageApi.list(
            path: '$testUserId/event_a',
            searchOptions: any(named: 'searchOptions'),
          ),
        ).thenAnswer((_) async => [fileA1]);

        // 3. event_b 配下のファイル (photo2.jpg, photo3.jpg)
        final fileB1 = FileObject.fromJson(<String, dynamic>{
          'name': 'photo2.jpg',
          'id': 'f-b1',
          'updated_at': '',
          'created_at': '',
          'last_accessed_at': '',
          'metadata': <String, dynamic>{},
        });
        final fileB2 = FileObject.fromJson(<String, dynamic>{
          'name': 'photo3.jpg',
          'id': 'f-b2',
          'updated_at': '',
          'created_at': '',
          'last_accessed_at': '',
          'metadata': <String, dynamic>{},
        });
        when(
          () => mockLateStorageApi.list(
            path: '$testUserId/event_b',
            searchOptions: any(named: 'searchOptions'),
          ),
        ).thenAnswer((_) async => [fileB1, fileB2]);

        await repository.deleteAccount();

        // late-evidences の remove に渡されたパスを検証
        final capturedLateRemoves = verify(
          () => mockLateStorageApi.remove(captureAny()),
        ).captured;
        expect(capturedLateRemoves.length, equals(1));

        final deletedPaths = capturedLateRemoves.first as List<String>;
        expect(
          deletedPaths,
          containsAll([
            '$testUserId/event_a/photo1.jpg',
            '$testUserId/event_b/photo2.jpg',
            '$testUserId/event_b/photo3.jpg',
          ]),
        );
        expect(deletedPaths.length, equals(3));
      },
    );

    test('Storage削除中に例外が発生しても、メソッド全体は正常終了すること', () async {
      when(
        () => mockSupabaseClient.rpc('delete_user'),
      ).thenAnswer((_) => FakePostgrestFilterBuilder());
      when(
        () => mockStorageFileApi.list(
          path: any(named: 'path'),
          searchOptions: any(named: 'searchOptions'),
        ),
      ).thenThrow(Exception('Storage network timeout'));
      when(() => mockGoTrueClient.signOut()).thenAnswer((_) async {});

      await expectLater(repository.deleteAccount(), completes);

      verify(() => mockSupabaseClient.rpc('delete_user')).called(1);
      verify(() => mockGoTrueClient.signOut()).called(1);
    });

    test(
      '【順序検証】RPC成功後、avatars削除、late-evidences削除が実行され、最後にsignOutが呼ばれること',
      () async {
        when(
          () => mockSupabaseClient.rpc('delete_user'),
        ).thenAnswer((_) => FakePostgrestFilterBuilder());
        when(() => mockGoTrueClient.signOut()).thenAnswer((_) async {});

        final avatarFile = FileObject.fromJson(<String, dynamic>{
          'name': 'avatar_1.jpg',
          'id': '1',
          'updated_at': '',
          'created_at': '',
          'last_accessed_at': '',
          'metadata': <String, dynamic>{},
          'bucket_id': 'avatars',
          'owner': testUserId,
        });
        when(
          () => mockStorageFileApi.list(
            path: testUserId,
            searchOptions: any(named: 'searchOptions'),
          ),
        ).thenAnswer((_) async => [avatarFile]);

        final eventDir = FileObject.fromJson(<String, dynamic>{
          'name': 'event_1',
          'id': 'dir_1',
          'updated_at': '',
          'created_at': '',
          'last_accessed_at': '',
          'metadata': <String, dynamic>{},
        });
        when(
          () => mockLateStorageApi.list(
            path: testUserId,
            searchOptions: any(named: 'searchOptions'),
          ),
        ).thenAnswer((_) async => [eventDir]);

        final lateFile = FileObject.fromJson(<String, dynamic>{
          'name': 'evidence_1.jpg',
          'id': 'f_1',
          'updated_at': '',
          'created_at': '',
          'last_accessed_at': '',
          'metadata': <String, dynamic>{},
        });
        when(
          () => mockLateStorageApi.list(
            path: '$testUserId/event_1',
            searchOptions: any(named: 'searchOptions'),
          ),
        ).thenAnswer((_) async => [lateFile]);

        await repository.deleteAccount();

        verifyInOrder([
          () => mockSupabaseClient.rpc('delete_user'),
          () => mockStorageFileApi.remove(['$testUserId/avatar_1.jpg']),
          () =>
              mockLateStorageApi.remove(['$testUserId/event_1/evidence_1.jpg']),
          () => mockGoTrueClient.signOut(),
        ]);
      },
    );

    test(
      '【独立実行検証】avatars の削除で例外が発生しても、late-evidences の削除と signOut は継続して実行されること',
      () async {
        when(
          () => mockSupabaseClient.rpc('delete_user'),
        ).thenAnswer((_) => FakePostgrestFilterBuilder());
        when(() => mockGoTrueClient.signOut()).thenAnswer((_) async {});

        when(
          () => mockStorageFileApi.list(
            path: any(named: 'path'),
            searchOptions: any(named: 'searchOptions'),
          ),
        ).thenThrow(Exception('avatars storage timeout'));

        final eventDir = FileObject.fromJson(<String, dynamic>{
          'name': 'event_1',
          'id': 'dir_1',
          'updated_at': '',
          'created_at': '',
          'last_accessed_at': '',
          'metadata': <String, dynamic>{},
        });
        when(
          () => mockLateStorageApi.list(
            path: testUserId,
            searchOptions: any(named: 'searchOptions'),
          ),
        ).thenAnswer((_) async => [eventDir]);

        final lateFile = FileObject.fromJson(<String, dynamic>{
          'name': 'evidence_1.jpg',
          'id': 'f_1',
          'updated_at': '',
          'created_at': '',
          'last_accessed_at': '',
          'metadata': <String, dynamic>{},
        });
        when(
          () => mockLateStorageApi.list(
            path: '$testUserId/event_1',
            searchOptions: any(named: 'searchOptions'),
          ),
        ).thenAnswer((_) async => [lateFile]);

        // メソッド全体がクラッシュせず正常終了すること
        await expectLater(repository.deleteAccount(), completes);

        // avatars が失敗しても、late-evidences の削除と signOut がスキップされずに呼ばれたことを検証
        verify(
          () =>
              mockLateStorageApi.remove(['$testUserId/event_1/evidence_1.jpg']),
        ).called(1);
        verify(() => mockGoTrueClient.signOut()).called(1);
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
