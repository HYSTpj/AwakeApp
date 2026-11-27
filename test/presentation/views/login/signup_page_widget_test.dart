import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/data/repositories/auth_repository.dart';
import 'package:flutter_application_1/presentation/viewmodels/auth_view_model.dart';
import 'package:flutter_application_1/presentation/views/login/signup_page.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthViewModel viewModel;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    viewModel = AuthViewModel(mockAuthRepository);
  });

  testWidgets(
    'サインアップでメール確認待ちになった場合: 確認ダイアログが表示されること',
    (WidgetTester tester) async {
      when(() => mockAuthRepository.signUp(
            email: 'pending@example.com',
            password: 'password123',
          )).thenThrow(const EmailConfirmationPendingException());

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthViewModel>.value(
          value: viewModel,
          child: const MaterialApp(home: CreateAccountPage()),
        ),
      );

      await tester.enterText(
        find.byType(TextField).first,
        'pending@example.com',
      );
      await tester.enterText(
        find.byType(TextField).last,
        'password123',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'CREATE ACCOUNT'));
      await tester.pumpAndSettle();

      // フラグが期待した入力値の呼び出しから立ったことを明示的に確認する
      verify(() => mockAuthRepository.signUp(
            email: 'pending@example.com',
            password: 'password123',
          )).called(1);

      expect(find.text('サインアップについて'), findsOneWidget);
      expect(
        find.text(
          '確認メールが届いた場合はリンクからログインしてください。'
          '届かない場合は、既存アカウントでログインしてください。',
        ),
        findsOneWidget,
      );
    },
  );
}
