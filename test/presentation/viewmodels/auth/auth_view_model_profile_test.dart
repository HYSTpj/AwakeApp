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
}
