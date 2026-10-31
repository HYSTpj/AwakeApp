import 'package:flutter_application_1/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_repository_test_mocks.dart';

void main() {
  setUpAll(() {
    registerAuthRepositoryTestFallbacks();
  });

  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late SupabaseAuthRepository repository;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();

    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    repository = SupabaseAuthRepository(mockSupabaseClient);
  });

  group('SupabaseAuthRepository.signUp', () {
    test(
      'session が null（メール確認待ち）の場合、EmailConfirmationPendingException を投げること',
      () async {
        final user = User(
          id: 'user-uuid-1234',
          appMetadata: const {},
          userMetadata: const {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        );

        when(
          () => mockGoTrueClient.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => AuthResponse(session: null, user: user));

        expect(
          () => repository.signUp(
            email: 'pending@example.com',
            password: 'password123',
          ),
          throwsA(isA<EmailConfirmationPendingException>()),
        );
      },
    );

    test('user が null の場合、AuthException を投げること', () async {
      when(
        () => mockGoTrueClient.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => AuthResponse(session: null, user: null));

      expect(
        () => repository.signUp(
          email: 'fail@example.com',
          password: 'password123',
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('SupabaseAuthRepository - updatePassword', () {
    test('現在のパスワードが空の場合は ArgumentError をスローする', () async {
      expect(
        () => repository.updatePassword(
          currentPassword: '',
          newPassword: 'newPassword123',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('新しいパスワードが空の場合は ArgumentError をスローする', () async {
      expect(
        () => repository.updatePassword(
          currentPassword: 'currentPassword123',
          newPassword: '',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('新しいパスワードが6文字未満は ArgumentError をスローする', () async {
      expect(
        () => repository.updatePassword(
          currentPassword: 'currentPassword123',
          newPassword: 'abcde',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('未ログイン状態では AuthException をスローする', () async {
      when(() => mockGoTrueClient.currentUser).thenReturn(null);

      expect(
        () => repository.updatePassword(
          currentPassword: 'currentPassword123',
          newPassword: 'newPassword123',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('現在のパスワードが不正な場合は AuthException をスローし、updateUser は呼ばれないこと', () async {
      final mockUser = MockUser();
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
      when(
        () => mockGoTrueClient.signInWithPassword(
          email: 'test@example.com',
          password: 'wrongPassword',
        ),
      ).thenThrow(const AuthException('Invalid login credentials'));

      expect(
        () => repository.updatePassword(
          currentPassword: 'wrongPassword',
          newPassword: 'newPassword123',
        ),
        throwsA(
          predicate<AuthException>((e) => e.message == '現在のパスワードが正しくありません'),
        ),
      );

      verifyNever(() => mockGoTrueClient.updateUser(any()));
    });

    test('再認証成功後に updateUser を呼ぶ', () async {
      final mockUser = MockUser();
      final mockUserResponse = MockUserResponse();
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockUserResponse.user).thenReturn(mockUser);

      when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
      when(
        () => mockGoTrueClient.signInWithPassword(
          email: 'test@example.com',
          password: 'currentPass123',
        ),
      ).thenAnswer((_) async => AuthResponse(session: null, user: mockUser));
      when(
        () => mockGoTrueClient.updateUser(any()),
      ).thenAnswer((_) async => mockUserResponse);

      await repository.updatePassword(
        currentPassword: 'currentPass123',
        newPassword: ' newPass123 ',
      );

      verify(
        () => mockGoTrueClient.signInWithPassword(
          email: 'test@example.com',
          password: 'currentPass123',
        ),
      ).called(1);
      verify(
        () => mockGoTrueClient.updateUser(
          any(
            that: predicate<UserAttributes>(
              (attr) => attr.password == ' newPass123 ',
            ),
          ),
        ),
      ).called(1);
    });
  });
}
