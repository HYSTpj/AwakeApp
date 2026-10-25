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
