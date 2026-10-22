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
