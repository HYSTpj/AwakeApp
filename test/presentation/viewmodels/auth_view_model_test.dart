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
}