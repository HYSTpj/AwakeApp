import 'dart:async';

import 'package:flutter_application_1/models/profile.dart';
import 'package:flutter_application_1/presentation/viewmodels/auth_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'auth_view_model_test_mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthViewModel viewModel;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    viewModel = AuthViewModel(mockAuthRepository);
  });

  group('AuthViewModel - プロフィール取得と競合（並行処理）対策テスト', () {
    test('loadCurrentProfile 成功時: プロフィールが正しくセットされること', () async {
      when(() => mockAuthRepository.currentUserId).thenReturn(testProfile.id);
      when(
        () => mockAuthRepository.getCurrentProfile(),
      ).thenAnswer((_) async => testProfile);

      await viewModel.loadCurrentProfile();

      expect(viewModel.state.user, equals(testProfile));
      expect(viewModel.state.isProfileLoading, isFalse);
      expect(viewModel.state.profileErrorMessage, isNull);
    });

    test(
      'loadCurrentProfile 失敗時: 古いユーザー情報が破棄され profileErrorMessage にエラーが格納されること',
      () async {
        when(() => mockAuthRepository.currentUserId).thenReturn(testProfile.id);
        when(
          () => mockAuthRepository.getCurrentProfile(),
        ).thenThrow(Exception('Network Error'));

        await viewModel.loadCurrentProfile();

        expect(viewModel.state.user, isNull);
        expect(viewModel.state.isProfileLoading, isFalse);
        expect(
          viewModel.state.profileErrorMessage,
          'プロフィールの取得に失敗しました。時間をおいて再試行してください',
        );
        expect(viewModel.state.authErrorMessage, isNull);
      },
    );

    test('プロフィール取得中にログアウトが完了した場合: 遅れて返ったプロフィールは破棄され未ログイン状態が維持されること', () async {
      final profileCompleter = Completer<Profile?>();

      when(() => mockAuthRepository.currentUserId).thenReturn(testProfile.id);
      when(
        () => mockAuthRepository.getCurrentProfile(),
      ).thenAnswer((_) => profileCompleter.future);
      when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});

      final profileFuture = viewModel.loadCurrentProfile();
      expect(viewModel.state.isProfileLoading, isTrue);

      when(() => mockAuthRepository.currentUserId).thenReturn(null);
      await viewModel.signOut();

      expect(viewModel.state.user, isNull);
      expect(viewModel.state.isProfileLoading, isFalse);

      profileCompleter.complete(testProfile);
      await profileFuture;

      expect(viewModel.state.user, isNull);
      expect(viewModel.state.isProfileLoading, isFalse);
    });

    test(
      'プロフィール取得中に別アカウントでサインインした場合: 前のアカウント情報は破棄され、新しいアカウント情報とローディング解除が反映されること',
      () async {
        final oldProfileCompleter = Completer<Profile?>();

        when(() => mockAuthRepository.currentUserId).thenReturn(testProfile.id);
        when(
          () => mockAuthRepository.getCurrentProfile(),
        ).thenAnswer((_) => oldProfileCompleter.future);
        when(
          () => mockAuthRepository.signIn(
            email: 'other@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => otherProfile);

        final oldProfileFuture = viewModel.loadCurrentProfile();
        expect(viewModel.state.isProfileLoading, isTrue);

        when(
          () => mockAuthRepository.currentUserId,
        ).thenReturn(otherProfile.id);
        await viewModel.signIn(
          email: 'other@example.com',
          password: 'password123',
        );

        expect(viewModel.state.user, equals(otherProfile));
        expect(viewModel.state.isProfileLoading, isFalse);

        oldProfileCompleter.complete(testProfile);
        await oldProfileFuture;

        expect(viewModel.state.user, equals(otherProfile));
        expect(viewModel.state.user?.id, equals('user-uuid-5678'));
      },
    );

    test(
      'プロフィール取得中に外部要因でセッションが変わり例外が発生した場合: スピナーが解除されユーザー情報がクリアされること',
      () async {
        final profileCompleter = Completer<Profile?>();

        when(() => mockAuthRepository.currentUserId).thenReturn(testProfile.id);
        when(
          () => mockAuthRepository.getCurrentProfile(),
        ).thenAnswer((_) => profileCompleter.future);

        final profileFuture = viewModel.loadCurrentProfile();
        expect(viewModel.state.isProfileLoading, isTrue);

        when(() => mockAuthRepository.currentUserId).thenReturn(null);

        profileCompleter.completeError(Exception('Network disconnected'));
        await profileFuture;

        expect(viewModel.state.isProfileLoading, isFalse);
        expect(viewModel.state.user, isNull);
        expect(viewModel.state.profileErrorMessage, isNull);
      },
    );

    test(
      '認証操作中（isAuthActionLoading 中）に loadCurrentProfile が呼ばれた場合: 処理が開始されず即時リターンすること',
      () async {
        final signInCompleter = Completer<Profile>();

        when(
          () => mockAuthRepository.signIn(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) => signInCompleter.future);

        final signInFuture = viewModel.signIn(
          email: 'test@example.com',
          password: 'password123',
        );
        expect(viewModel.state.isAuthActionLoading, isTrue);

        await viewModel.loadCurrentProfile();

        verifyNever(() => mockAuthRepository.getCurrentProfile());
        expect(viewModel.state.isProfileLoading, isFalse);

        signInCompleter.complete(testProfile);
        await signInFuture;
        expect(viewModel.state.isAuthActionLoading, isFalse);
      },
    );

    test(
      'キャッシュが存在する場合: forceRefresh が false なら通信をスキップし Repository を呼ばないこと',
      () async {
        // 1回目の取得（キャッシュの作成）
        when(() => mockAuthRepository.currentUserId).thenReturn(testProfile.id);
        when(
          () => mockAuthRepository.getCurrentProfile(),
        ).thenAnswer((_) async => testProfile);

        await viewModel.loadCurrentProfile();
        expect(viewModel.state.user, equals(testProfile));
        verify(() => mockAuthRepository.getCurrentProfile()).called(1);

        // 2回目の呼び出し（通常呼び出し: スキップされるべき）
        await viewModel.loadCurrentProfile(forceRefresh: false);

        // 呼び出し回数が1回のままで増えていないことを検証
        verifyNever(() => mockAuthRepository.getCurrentProfile());
        expect(viewModel.state.isProfileLoading, isFalse);
      },
    );

    test(
      'キャッシュが存在する場合でも: forceRefresh が true なら Repository を再取得すること',
      () async {
        // 1回目の取得
        when(() => mockAuthRepository.currentUserId).thenReturn(testProfile.id);
        when(
          () => mockAuthRepository.getCurrentProfile(),
        ).thenAnswer((_) async => testProfile);

        await viewModel.loadCurrentProfile();
        verify(() => mockAuthRepository.getCurrentProfile()).called(1);

        // 更新後プロフィールのモック
        final updatedProfile = Profile(
          id: testProfile.id,
          nickname: 'UpdatedNickname',
          avatarUrl: testProfile.avatarUrl,
          sleepPastCount: testProfile.sleepPastCount,
          lateCount: testProfile.lateCount,
          createdAt: testProfile.createdAt,
          updatedAt: DateTime.now(),
        );
        when(
          () => mockAuthRepository.getCurrentProfile(),
        ).thenAnswer((_) async => updatedProfile);

        // 強制再取得を実行
        await viewModel.loadCurrentProfile(forceRefresh: true);

        // Repository が再度呼ばれ、状態が更新されたことを検証
        verify(() => mockAuthRepository.getCurrentProfile()).called(1);
        expect(viewModel.state.user?.nickname, equals('UpdatedNickname'));
      },
    );

    test(
      '既に isProfileLoading が true の場合: 2回目の呼び出しは早期リターンして重複通信しないこと',
      () async {
        final completer = Completer<Profile?>();
        when(() => mockAuthRepository.currentUserId).thenReturn(testProfile.id);
        when(
          () => mockAuthRepository.getCurrentProfile(),
        ).thenAnswer((_) => completer.future);

        final firstCall = viewModel.loadCurrentProfile();
        expect(viewModel.state.isProfileLoading, isTrue);

        // 読み込み完了前に2回目の呼び出し（forceRefresh が true でも抑止される）
        final secondCall = viewModel.loadCurrentProfile(forceRefresh: true);

        completer.complete(testProfile);
        await Future.wait([firstCall, secondCall]);

        // 1回しか Repository が呼ばれていないことを検証
        verify(() => mockAuthRepository.getCurrentProfile()).called(1);
        expect(viewModel.state.isProfileLoading, isFalse);
      },
    );
  });
}
