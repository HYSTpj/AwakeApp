import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/data/repositories/auth_repository.dart';
import 'package:flutter_application_1/models/profile.dart';
import 'package:flutter_application_1/presentation/viewmodels/auth_view_model.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthViewModel viewModel;

  final testProfile = Profile(
    id: 'user-uuid-1234',
    nickname: 'TestUser',
    avatarUrl: null,
    sleepPastCount: 0,
    lateCount: 0,
    createdAt: DateTime.parse('2026-09-21T00:00:00Z'),
    updatedAt: DateTime.parse('2026-09-21T00:00:00Z'),
  );

  final otherProfile = Profile(
    id: 'user-uuid-5678',
    nickname: 'OtherUser',
    avatarUrl: null,
    sleepPastCount: 0,
    lateCount: 0,
    createdAt: DateTime.parse('2026-09-21T00:00:00Z'),
    updatedAt: DateTime.parse('2026-09-21T00:00:00Z'),
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    viewModel = AuthViewModel(mockAuthRepository);
  });

  group('AuthViewModel - サインアップテスト', () {
    test('signUp 成功時: user が格納され、isLoading が false に戻ること', () async {
      when(
        () => mockAuthRepository.signUp(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => testProfile);

      final result = await viewModel.signUp(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isTrue);
      expect(viewModel.state.user, equals(testProfile));
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.errorMessage, isNull);
    });

    test('signUp 失敗時(既知メッセージ): ユーザー向けの日本語メッセージに変換されること', () async {
      when(
        () => mockAuthRepository.signUp(
          email: 'fail@example.com',
          password: 'password123',
        ),
      ).thenThrow(const AuthException('User already registered'));

      final result = await viewModel.signUp(
        email: 'fail@example.com',
        password: 'password123',
      );

      expect(result, isFalse);
      expect(viewModel.state.user, isNull);
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.errorMessage, equals('このメールアドレスは既に登録されています'));
      expect(viewModel.state.isEmailConfirmationPending, isFalse);
    });

    test('signUp 失敗時(未知のエラー): 汎用の日本語メッセージになり、生の例外文字列は表示されないこと', () async {
      when(
        () => mockAuthRepository.signUp(
          email: 'fail2@example.com',
          password: 'password123',
        ),
      ).thenThrow(const AuthException('some internal detail'));

      final result = await viewModel.signUp(
        email: 'fail2@example.com',
        password: 'password123',
      );

      expect(result, isFalse);
      expect(
        viewModel.state.errorMessage,
        equals('エラーが発生しました。しばらくしてから再度お試しください'),
      );
      expect(viewModel.state.errorMessage, isNot(contains('AuthException')));
      expect(
        viewModel.state.errorMessage,
        isNot(contains('some internal detail')),
      );
    });

    test(
      'signUp 時に EmailConfirmationPendingException が発生した場合: isEmailConfirmationPending が true になり errorMessage は設定されないこと',
      () async {
        when(
          () => mockAuthRepository.signUp(
            email: 'pending@example.com',
            password: 'password123',
          ),
        ).thenThrow(const EmailConfirmationPendingException());

        final result = await viewModel.signUp(
          email: 'pending@example.com',
          password: 'password123',
        );

        expect(result, isFalse);
        expect(viewModel.state.user, isNull);
        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.errorMessage, isNull);
        expect(viewModel.state.isEmailConfirmationPending, isTrue);
      },
    );

    test('signUp 実行中に再度 signUp を呼んでも、2回目は早期リターンしてRepositoryが呼ばれないこと', () async {
      final completer = Completer<Profile>();
      when(
        () => mockAuthRepository.signUp(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) => completer.future);

      final firstCall = viewModel.signUp(
        email: 'test@example.com',
        password: 'password123',
      );
      final secondCall = viewModel.signUp(
        email: 'test@example.com',
        password: 'password123',
      );

      completer.complete(testProfile);
      final results = await Future.wait([firstCall, secondCall]);

      expect(results[0], isTrue);
      expect(results[1], isFalse);
      verify(
        () => mockAuthRepository.signUp(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
    });
  });

  group('AuthViewModel - ログインテスト', () {
    test('signIn 成功時: user が設定され true が返ること', () async {
      when(
        () => mockAuthRepository.signIn(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => testProfile);

      final result = await viewModel.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isTrue);
      expect(viewModel.state.user?.id, equals('user-uuid-1234'));
      expect(viewModel.state.errorMessage, isNull);
    });

    test(
      '直前の signUp でメール確認待ちになっていても、signIn 成功時に isEmailConfirmationPending が false にリセットされること',
      () async {
        when(
          () => mockAuthRepository.signUp(
            email: 'pending@example.com',
            password: 'password123',
          ),
        ).thenThrow(const EmailConfirmationPendingException());
        await viewModel.signUp(
          email: 'pending@example.com',
          password: 'password123',
        );
        expect(viewModel.state.isEmailConfirmationPending, isTrue);

        when(
          () => mockAuthRepository.signIn(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => testProfile);

        final result = await viewModel.signIn(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result, isTrue);
        expect(viewModel.state.isEmailConfirmationPending, isFalse);
      },
    );

    test('signIn 失敗時: ユーザー向けの日本語メッセージに変換されること', () async {
      when(
        () => mockAuthRepository.signIn(
          email: 'test@example.com',
          password: 'wrongpassword',
        ),
      ).thenThrow(const AuthException('Invalid login credentials'));

      final result = await viewModel.signIn(
        email: 'test@example.com',
        password: 'wrongpassword',
      );

      expect(result, isFalse);
      expect(viewModel.state.user, isNull);
      expect(viewModel.state.errorMessage, equals('メールアドレスまたはパスワードが正しくありません'));
    });

    test('signIn 実行中に再度 signIn を呼んでも、2回目は早期リターンしてRepositoryが呼ばれないこと', () async {
      final completer = Completer<Profile>();
      when(
        () => mockAuthRepository.signIn(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) => completer.future);

      final firstCall = viewModel.signIn(
        email: 'test@example.com',
        password: 'password123',
      );
      final secondCall = viewModel.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      completer.complete(testProfile);
      final results = await Future.wait([firstCall, secondCall]);

      expect(results[0], isTrue);
      expect(results[1], isFalse);
      verify(
        () => mockAuthRepository.signIn(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
    });
  });

  group('AuthViewModel - プロフィール設定テスト', () {
    test('completeProfile 成功時: user が更新され true が返ること', () async {
      when(
        () => mockAuthRepository.updateProfile(
          nickname: 'NewName',
          avatarImage: null,
        ),
      ).thenAnswer((_) async => testProfile);

      final result = await viewModel.completeProfile(nickname: 'NewName');

      expect(result, isTrue);
      expect(viewModel.state.user, equals(testProfile));
      expect(viewModel.state.isLoading, isFalse);
    });

    test('completeProfile 失敗時: ユーザー向けメッセージが設定され false が返ること', () async {
      when(
        () => mockAuthRepository.updateProfile(
          nickname: 'NewName',
          avatarImage: null,
        ),
      ).thenThrow(Exception('storage error'));

      final result = await viewModel.completeProfile(nickname: 'NewName');

      expect(result, isFalse);
      expect(
        viewModel.state.errorMessage,
        equals('エラーが発生しました。しばらくしてから再度お試しください'),
      );
    });

    test('completeProfile 実行中に再度呼んでも、2回目は早期リターンしてRepositoryが呼ばれないこと', () async {
      final completer = Completer<Profile>();
      when(
        () => mockAuthRepository.updateProfile(
          nickname: 'NewName',
          avatarImage: null,
        ),
      ).thenAnswer((_) => completer.future);

      final firstCall = viewModel.completeProfile(nickname: 'NewName');
      final secondCall = viewModel.completeProfile(nickname: 'NewName');

      completer.complete(testProfile);
      final results = await Future.wait([firstCall, secondCall]);

      expect(results[0], isTrue);
      expect(results[1], isFalse);
      verify(
        () => mockAuthRepository.updateProfile(
          nickname: 'NewName',
          avatarImage: null,
        ),
      ).called(1);
    });
  });

  group('AuthViewModel - サインアウトテスト', () {
    test('signOut 実行時: state が初期化されること', () async {
      when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});

      await viewModel.signOut();

      expect(viewModel.state.user, isNull);
      expect(viewModel.state.isLoading, isFalse);
      verify(() => mockAuthRepository.signOut()).called(1);
    });
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
        expect(viewModel.state.profileErrorMessage, contains('プロフィール取得失敗'));
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
  });

  group('AuthViewModel - ユーザー名更新テスト', () {
    final updatedProfile = Profile(
      id: 'user-uuid-1234',
      nickname: 'NewNickname',
      avatarUrl: null,
      sleepPastCount: 0,
      lateCount: 0,
      createdAt: DateTime.parse('2026-09-21T00:00:00Z'),
      updatedAt: DateTime.parse('2026-09-21T00:00:00Z'),
    );

    test('updateNickname 成功時: user が更新され true が返ること', () async {
      when(
        () => mockAuthRepository.updateNickname('NewNickname'),
      ).thenAnswer((_) async => updatedProfile);

      final result = await viewModel.updateNickname('NewNickname');

      expect(result, isTrue);
      expect(viewModel.state.user?.nickname, equals('NewNickname'));
      expect(viewModel.state.isAuthActionLoading, isFalse);
      expect(viewModel.state.authErrorMessage, isNull);
      verify(() => mockAuthRepository.updateNickname('NewNickname')).called(1);
    });

    test('updateNickname 失敗時: authErrorMessage にエラーが入り false が返ること', () async {
      when(
        () => mockAuthRepository.updateNickname('NewNickname'),
      ).thenThrow(Exception('Update failed'));

      final result = await viewModel.updateNickname('NewNickname');

      expect(result, isFalse);
      expect(viewModel.state.isAuthActionLoading, isFalse);
      expect(
        viewModel.state.authErrorMessage,
        equals('エラーが発生しました。しばらくしてから再度お試しください'),
      );
    });

    test(
      '既にアクション処理中（isAuthActionLoading: true）の場合は実行されず false が返ること',
      () async {
        final completer = Completer<Profile>();
        when(
          () => mockAuthRepository.updateNickname(any()),
        ).thenAnswer((_) => completer.future);

        final firstFuture = viewModel.updateNickname('First');
        expect(viewModel.state.isAuthActionLoading, isTrue);

        final secondResult = await viewModel.updateNickname('Second');
        expect(secondResult, isFalse);

        completer.complete(updatedProfile);
        await firstFuture;
      },
    );

    test('プロフィール読み込み中の場合: updateNickname が拒否されて Repository が呼ばれないこと', () async {
      final profileCompleter = Completer<Profile?>();
      when(() => mockAuthRepository.currentUserId).thenReturn(testProfile.id);
      when(
        () => mockAuthRepository.getCurrentProfile(),
      ).thenAnswer((_) => profileCompleter.future);

      final loadFuture = viewModel.loadCurrentProfile();
      expect(viewModel.state.isProfileLoading, isTrue);

      final result = await viewModel.updateNickname('NewName');

      expect(result, isFalse);
      verifyNever(() => mockAuthRepository.updateNickname(any()));

      profileCompleter.complete(testProfile);
      await loadFuture;
    });
  });
}
