import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/data/repositories/auth_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late SupabaseAuthRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockClient.auth).thenReturn(mockAuth);
    repository = SupabaseAuthRepository(mockClient);
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

      when(() => mockAuth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => AuthResponse(session: null, user: user));

      expect(
        () => repository.signUp(
          email: 'pending@example.com',
          password: 'password123',
        ),
        throwsA(isA<EmailConfirmationPendingException>()),
      );
    });

    test('user が null の場合、AuthException を投げること', () async {
      when(() => mockAuth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => AuthResponse(session: null, user: null));

      expect(
        () => repository.signUp(
          email: 'fail@example.com',
          password: 'password123',
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('SupabaseAuthRepository.updateProfile', () {
    test('未ログイン状態の場合、AuthException を投げること', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      expect(
        () => repository.updateProfile(nickname: 'NewName'),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
