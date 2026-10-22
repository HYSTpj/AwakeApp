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
}
