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
      when(() => mockAuthRepository.signUp(
            email: 'test@example.com',
            password: 'password123',
            nickname: 'TestUser',
          )).thenAnswer((_) async => testProfile);

      final result = await viewModel.signUp(
        email: 'test@example.com',
        password: 'password123',
        nickname: 'TestUser',
      );

      expect(result, isTrue);
      expect(viewModel.state.user, equals(testProfile));
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.errorMessage, isNull);
    });

    test('signUp 失敗時: errorMessage に例外内容が入り、false が返却されること', () async {
      when(() => mockAuthRepository.signUp(
            email: 'fail@example.com',
            password: 'password123',
            nickname: 'TestUser',
          )).thenThrow(const AuthException('User already registered'));

      final result = await viewModel.signUp(
        email: 'fail@example.com',
        password: 'password123',
        nickname: 'TestUser',
      );

      expect(result, isFalse);
      expect(viewModel.state.user, isNull);
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.errorMessage, contains('User already registered'));
    });
  });

  group('AuthViewModel - ログインテスト', () {
    test('signIn 成功時: user が設定され true が返ること', () async {
      when(() => mockAuthRepository.signIn(
            email: 'test@example.com',
            password: 'password123',
          )).thenAnswer((_) async => testProfile);

      final result = await viewModel.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isTrue);
      expect(viewModel.state.user?.id, equals('user-uuid-1234'));
      expect(viewModel.state.errorMessage, isNull);
    });

    test('signIn 失敗時: 適切なエラーメッセージが保持されること', () async {
      when(() => mockAuthRepository.signIn(
            email: 'test@example.com',
            password: 'wrongpassword',
          )).thenThrow(const AuthException('Invalid login credentials'));

      final result = await viewModel.signIn(
        email: 'test@example.com',
        password: 'wrongpassword',
      );

      expect(result, isFalse);
      expect(viewModel.state.user, isNull);
      expect(viewModel.state.errorMessage, contains('Invalid login credentials'));
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
      when(() => mockAuthRepository.getCurrentProfile())
          .thenAnswer((_) async => testProfile);

      await viewModel.loadCurrentProfile();

      expect(viewModel.state.user, equals(testProfile));
      expect(viewModel.state.isProfileLoading, isFalse);
      expect(viewModel.state.profileErrorMessage, isNull);
    });

    test('loadCurrentProfile 失敗時: 古いユーザー情報が破棄され profileErrorMessage にエラーが格納されること', () async {
      when(() => mockAuthRepository.currentUserId).thenReturn(testProfile.id);
      when(() => mockAuthRepository.getCurrentProfile())
          .thenThrow(Exception('Network Error'));

      await viewModel.loadCurrentProfile();

      expect(viewModel.state.user, isNull);
      expect(viewModel.state.isProfileLoading, isFalse);
      expect(viewModel.state.profileErrorMessage, contains('プロフィール取得失敗'));
      // 認証アクションエラーには影響しないこと
      expect(viewModel.state.authErrorMessage, isNull);
    });

    test('プロフィール取得中にログアウトが完了した場合: 遅れて返ったプロフィールは破棄され未ログイン状態が維持されること', () async {
      final profileCompleter = Completer<Profile?>();

      // 取得開始時点ではログイン中
      when(() => mockAuthRepository.currentUserId).thenReturn(testProfile.id);
      when(() => mockAuthRepository.getCurrentProfile())
          .thenAnswer((_) => profileCompleter.future);
      when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});

      // 1. プロフィール取得を開始（レスポンス待ちで一時停止）
      final profileFuture = viewModel.loadCurrentProfile();
      expect(viewModel.state.isProfileLoading, isTrue);

      // 2. 取得完了前にログアウトを実行
      // ログアウト完了後は currentUserId が null になる状態をシミュレート
      when(() => mockAuthRepository.currentUserId).thenReturn(null);
      await viewModel.signOut();

      expect(viewModel.state.user, isNull);
      expect(viewModel.state.isProfileLoading, isFalse);

      // 3. 遅れてプロフィール取得が完了
      profileCompleter.complete(testProfile);
      await profileFuture;

      // 4. 古いプロフィールが状態に反映されないことを確認
      expect(viewModel.state.user, isNull);
      expect(viewModel.state.isProfileLoading, isFalse);
    });

    test('プロフィール取得中に別アカウントでサインインした場合: 前のアカウント情報は破棄され、新しいアカウント情報とローディング解除が反映されること', () async {
      final oldProfileCompleter = Completer<Profile?>();

      when(() => mockAuthRepository.currentUserId).thenReturn(testProfile.id);
      when(() => mockAuthRepository.getCurrentProfile())
          .thenAnswer((_) => oldProfileCompleter.future);
      when(() => mockAuthRepository.signIn(
            email: 'other@example.com',
            password: 'password123',
          )).thenAnswer((_) async => otherProfile);

      // 1. 旧プロフィールの取得を開始
      final oldProfileFuture = viewModel.loadCurrentProfile();
      expect(viewModel.state.isProfileLoading, isTrue);

      // 2. 完了前に別アカウントでサインイン
      when(() => mockAuthRepository.currentUserId).thenReturn(otherProfile.id);
      await viewModel.signIn(
        email: 'other@example.com',
        password: 'password123',
      );

      expect(viewModel.state.user, equals(otherProfile));
      expect(viewModel.state.isProfileLoading, isFalse);

      // 3. 旧プロフィールの結果が遅れて返却
      oldProfileCompleter.complete(testProfile);
      await oldProfileFuture;

      // 4. 新アカウントの情報が上書きされず保持されていること
      expect(viewModel.state.user, equals(otherProfile));
      expect(viewModel.state.user?.id, equals('user-uuid-5678'));
    });

    test('プロフィール取得中に外部要因でセッションが変わり例外が発生した場合: スピナーが解除されユーザー情報がクリアされること', () async {
      final profileCompleter = Completer<Profile?>();

      when(() => mockAuthRepository.currentUserId).thenReturn(testProfile.id);
      when(() => mockAuthRepository.getCurrentProfile())
          .thenAnswer((_) => profileCompleter.future);

      // 1. プロフィール取得を開始
      final profileFuture = viewModel.loadCurrentProfile();
      expect(viewModel.state.isProfileLoading, isTrue);

      // 2. 外部（Supabase等）でセッションが切断された状態をシミュレート
      when(() => mockAuthRepository.currentUserId).thenReturn(null);

      // 3. 通信エラーなどの例外が発生して終了
      profileCompleter.completeError(Exception('Network disconnected'));
      await profileFuture;

      // 4. スピナーが解除され、ユーザー情報がクリアされていること
      expect(viewModel.state.isProfileLoading, isFalse);
      expect(viewModel.state.user, isNull);
      // 無効なセッションではプロフィール取得エラーを設定しない
      expect(viewModel.state.profileErrorMessage, isNull);
    });

    test('認証操作中（isAuthActionLoading 中）に loadCurrentProfile が呼ばれた場合: 処理が開始されず即時リターンすること', () async {
      final signInCompleter = Completer<Profile>();

      when(() => mockAuthRepository.signIn(
            email: 'test@example.com',
            password: 'password123',
          )).thenAnswer((_) => signInCompleter.future);

      // 1. サインインを開始して非同期待機中（isAuthActionLoading: true）にする
      final signInFuture = viewModel.signIn(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(viewModel.state.isAuthActionLoading, isTrue);

      // 2. 認証操作中に loadCurrentProfile を呼び出す
      await viewModel.loadCurrentProfile();

      // getCurrentProfile が呼ばれていないこと（即座に return されたこと）を検証
      verifyNever(() => mockAuthRepository.getCurrentProfile());
      expect(viewModel.state.isProfileLoading, isFalse);

      // 3. サインインを完了させてテストをクリーンアップ
      signInCompleter.complete(testProfile);
      await signInFuture;
      expect(viewModel.state.isAuthActionLoading, isFalse);
    });
  });
}