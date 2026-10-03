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

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    viewModel = AuthViewModel(mockAuthRepository);
  });

  group('AuthViewModel - サインアップテスト', () {
    test('signUp 成功時: user が格納され、isLoading が false に戻ること', () async {
      when(() => mockAuthRepository.signUp(
            email: 'test@example.com',
            password: 'password123',
          )).thenAnswer((_) async => testProfile);

      final result = await viewModel.signUp(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isTrue);
      expect(viewModel.state.user, equals(testProfile));
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.errorMessage, isNull);
    });

    test(
        'signUp 失敗時(Invalid login credentials以外の既知メッセージ): '
        'ユーザー向けの日本語メッセージに変換されること', () async {
      when(() => mockAuthRepository.signUp(
            email: 'fail@example.com',
            password: 'password123',
          )).thenThrow(const AuthException('User already registered'));

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
      when(() => mockAuthRepository.signUp(
            email: 'fail2@example.com',
            password: 'password123',
          )).thenThrow(const AuthException('some internal detail'));

      final result = await viewModel.signUp(
        email: 'fail2@example.com',
        password: 'password123',
      );

      expect(result, isFalse);
      expect(viewModel.state.errorMessage, equals('エラーが発生しました。しばらくしてから再度お試しください'));
      expect(viewModel.state.errorMessage, isNot(contains('AuthException')));
      expect(viewModel.state.errorMessage, isNot(contains('some internal detail')));
    });

    test(
        'signUp 時に EmailConfirmationPendingException が発生した場合: '
        'isEmailConfirmationPending が true になり、errorMessage は設定されず false が返却されること',
        () async {
      when(() => mockAuthRepository.signUp(
            email: 'pending@example.com',
            password: 'password123',
          )).thenThrow(const EmailConfirmationPendingException());

      final result = await viewModel.signUp(
        email: 'pending@example.com',
        password: 'password123',
      );

      expect(result, isFalse);
      expect(viewModel.state.user, isNull);
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.errorMessage, isNull);
      expect(viewModel.state.isEmailConfirmationPending, isTrue);
    });

    test(
        'signUp 実行中に再度 signUp を呼んでも、2回目は早期リターンしてRepositoryが呼ばれないこと',
        () async {
      final completer = Completer<Profile>();
      when(() => mockAuthRepository.signUp(
            email: 'test@example.com',
            password: 'password123',
          )).thenAnswer((_) => completer.future);

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
      verify(() => mockAuthRepository.signUp(
            email: 'test@example.com',
            password: 'password123',
          )).called(1);
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

    test(
        '直前の signUp でメール確認待ちになっていても、signIn 成功時に isEmailConfirmationPending が false にリセットされること',
        () async {
      when(() => mockAuthRepository.signUp(
            email: 'pending@example.com',
            password: 'password123',
          )).thenThrow(const EmailConfirmationPendingException());
      await viewModel.signUp(
        email: 'pending@example.com',
        password: 'password123',
      );
      expect(viewModel.state.isEmailConfirmationPending, isTrue);

      when(() => mockAuthRepository.signIn(
            email: 'test@example.com',
            password: 'password123',
          )).thenAnswer((_) async => testProfile);

      final result = await viewModel.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isTrue);
      expect(viewModel.state.isEmailConfirmationPending, isFalse);
    });

    test('signIn 失敗時: ユーザー向けの日本語メッセージに変換されること', () async {
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
      expect(viewModel.state.errorMessage, equals('メールアドレスまたはパスワードが正しくありません'));
    });

    test(
        'signIn 実行中に再度 signIn を呼んでも、2回目は早期リターンしてRepositoryが呼ばれないこと',
        () async {
      final completer = Completer<Profile>();
      when(() => mockAuthRepository.signIn(
            email: 'test@example.com',
            password: 'password123',
          )).thenAnswer((_) => completer.future);

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
      verify(() => mockAuthRepository.signIn(
            email: 'test@example.com',
            password: 'password123',
          )).called(1);
    });
  });

  group('AuthViewModel - プロフィール設定テスト', () {
    test('completeProfile 成功時: user が更新され true が返ること', () async {
      when(() => mockAuthRepository.updateProfile(
            nickname: 'NewName',
            avatarImage: null,
          )).thenAnswer((_) async => testProfile);

      final result = await viewModel.completeProfile(nickname: 'NewName');

      expect(result, isTrue);
      expect(viewModel.state.user, equals(testProfile));
      expect(viewModel.state.isLoading, isFalse);
    });

    test('completeProfile 失敗時: ユーザー向けメッセージが設定され false が返ること', () async {
      when(() => mockAuthRepository.updateProfile(
            nickname: 'NewName',
            avatarImage: null,
          )).thenThrow(Exception('storage error'));

      final result = await viewModel.completeProfile(nickname: 'NewName');

      expect(result, isFalse);
      expect(viewModel.state.errorMessage, equals('エラーが発生しました。しばらくしてから再度お試しください'));
    });

    test(
        'completeProfile 実行中に再度呼んでも、2回目は早期リターンしてRepositoryが呼ばれないこと',
        () async {
      final completer = Completer<Profile>();
      when(() => mockAuthRepository.updateProfile(
            nickname: 'NewName',
            avatarImage: null,
          )).thenAnswer((_) => completer.future);

      final firstCall = viewModel.completeProfile(nickname: 'NewName');
      final secondCall = viewModel.completeProfile(nickname: 'NewName');

      completer.complete(testProfile);
      final results = await Future.wait([firstCall, secondCall]);

      expect(results[0], isTrue);
      expect(results[1], isFalse);
      verify(() => mockAuthRepository.updateProfile(
            nickname: 'NewName',
            avatarImage: null,
          )).called(1);
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
}
