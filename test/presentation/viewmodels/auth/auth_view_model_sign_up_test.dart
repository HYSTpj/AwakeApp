import 'dart:async';

import 'package:flutter_application_1/data/repositories/auth_repository.dart';
import 'package:flutter_application_1/models/profile.dart';
import 'package:flutter_application_1/presentation/viewmodels/auth_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_view_model_test_mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthViewModel viewModel;

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
}
