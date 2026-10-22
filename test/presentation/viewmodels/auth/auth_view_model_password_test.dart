import 'dart:async';

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

  group('AuthViewModel - updatePassword', () {
    test('現在のパスワードが空の場合は失敗し適切なメッセージをセットする', () async {
      final result = await viewModel.updatePassword(
        currentPassword: '',
        newPassword: 'newPassword123',
        confirmPassword: 'newPassword123',
      );

      expect(result, isFalse);
      expect(viewModel.state.authErrorMessage, '現在のパスワードを入力してください');
      verifyNever(
        () => mockAuthRepository.updatePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      );
    });

    test('新しいパスワードが空の場合は失敗し適切なメッセージをセットする', () async {
      final result = await viewModel.updatePassword(
        currentPassword: 'currentPassword123',
        newPassword: '',
        confirmPassword: '',
      );

      expect(result, isFalse);
      expect(viewModel.state.authErrorMessage, '新しいパスワードを入力してください');
      verifyNever(
        () => mockAuthRepository.updatePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      );
    });

    test('新しいパスワードが6文字未満の場合は失敗する', () async {
      final result = await viewModel.updatePassword(
        currentPassword: 'currentPassword123',
        newPassword: '12345',
        confirmPassword: '12345',
      );

      expect(result, isFalse);
      expect(viewModel.state.authErrorMessage, '新しいパスワードは6文字以上で入力してください');
      verifyNever(
        () => mockAuthRepository.updatePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      );
    });

    test('新しいパスワードが現在のパスワードと同じ場合は失敗する', () async {
      final result = await viewModel.updatePassword(
        currentPassword: 'password123',
        newPassword: 'password123',
        confirmPassword: 'password123',
      );

      expect(result, isFalse);
      expect(
        viewModel.state.authErrorMessage,
        '新しいパスワードは現在のパスワードと異なるものを設定してください',
      );
      verifyNever(
        () => mockAuthRepository.updatePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      );
    });

    test('確認用パスワードが一致しない場合は失敗する', () async {
      final result = await viewModel.updatePassword(
        currentPassword: 'currentPassword123',
        newPassword: 'password123',
        confirmPassword: 'password456',
      );

      expect(result, isFalse);
      expect(viewModel.state.authErrorMessage, '確認用パスワードが一致しません');
      verifyNever(
        () => mockAuthRepository.updatePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      );
    });

    test('正常に入力された場合はRepositoryを呼び出して成功する（空白も含めて維持）', () async {
      const currentPass = 'currentPass123';
      const validPass = 'pass word 123 ';
      when(
        () => mockAuthRepository.updatePassword(
          currentPassword: currentPass,
          newPassword: validPass,
        ),
      ).thenAnswer((_) async {});

      final result = await viewModel.updatePassword(
        currentPassword: currentPass,
        newPassword: validPass,
        confirmPassword: validPass,
      );

      expect(result, isTrue);
      expect(viewModel.state.authErrorMessage, isNull);
      expect(viewModel.state.isAuthActionLoading, isFalse);
      verify(
        () => mockAuthRepository.updatePassword(
          currentPassword: currentPass,
          newPassword: validPass,
        ),
      ).called(1);
    });

    test('Repositoryが例外をスローした場合は失敗状態を保持する', () async {
      when(
        () => mockAuthRepository.updatePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenThrow(const AuthException('現在のパスワードが正しくありません'));

      final result = await viewModel.updatePassword(
        currentPassword: 'wrongPassword',
        newPassword: 'newPassword123',
        confirmPassword: 'newPassword123',
      );

      expect(result, isFalse);
      expect(viewModel.state.authErrorMessage, '現在のパスワードが正しくありません');
      expect(viewModel.state.isAuthActionLoading, isFalse);
    });

    test('updatePassword 実行中に再度呼んでも、2回目は早期リターンしてRepositoryが呼ばれないこと', () async {
      final completer = Completer<void>();
      when(
        () => mockAuthRepository.updatePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) => completer.future);

      final firstCall = viewModel.updatePassword(
        currentPassword: 'currentPass123',
        newPassword: 'password123',
        confirmPassword: 'password123',
      );
      final secondCall = viewModel.updatePassword(
        currentPassword: 'currentPass123',
        newPassword: 'password123',
        confirmPassword: 'password123',
      );

      completer.complete();
      final results = await Future.wait([firstCall, secondCall]);

      expect(results[0], isTrue);
      expect(results[1], isFalse);
      verify(
        () => mockAuthRepository.updatePassword(
          currentPassword: 'currentPass123',
          newPassword: 'password123',
        ),
      ).called(1);
    });

    test('セッション切れ（未ログイン）例外時は再ログインを促すメッセージを設定する', () async {
      when(
        () => mockAuthRepository.updatePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenThrow(const AuthException('認証セッションがありません'));

      final result = await viewModel.updatePassword(
        currentPassword: 'currentPass123',
        newPassword: 'password123',
        confirmPassword: 'password123',
      );

      expect(result, isFalse);
      expect(viewModel.state.authErrorMessage, 'ログインの有効期限が切れています。再度ログインしてください');
      expect(viewModel.state.isAuthActionLoading, isFalse);
    });
  });
}
