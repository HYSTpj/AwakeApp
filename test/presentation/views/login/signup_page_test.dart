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

  Future<void> pumpSignupPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>.value(
        value: viewModel,
        child: const MaterialApp(home: CreateAccountPage()),
      ),
    );
  }

  testWidgets(
      'メール・パスワードが空の場合、CREATE ACCOUNTボタン押下でAuthRepository.signUpが呼ばれず早期リターンすること',
      (tester) async {
    await pumpSignupPage(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'CREATE ACCOUNT'));
    await tester.pump();

    verifyNever(() => mockAuthRepository.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ));
  });

  testWidgets(
      'メールのみ空（パスワードは入力済み）の場合も、signUpが呼ばれず早期リターンすること',
      (tester) async {
    await pumpSignupPage(tester);

    await tester.enterText(find.byType(TextField).last, 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'CREATE ACCOUNT'));
    await tester.pump();

    verifyNever(() => mockAuthRepository.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ));
  });

  testWidgets(
      'パスワードのみ空（メールは入力済み）の場合も、signUpが呼ばれず早期リターンすること',
      (tester) async {
    await pumpSignupPage(tester);

    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.tap(find.widgetWithText(ElevatedButton, 'CREATE ACCOUNT'));
    await tester.pump();

    verifyNever(() => mockAuthRepository.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ));
  });

  testWidgets(
      'メール・パスワードが空の場合、CREATE ACCOUNTボタン押下でSnackBarが表示されること',
      (tester) async {
    await pumpSignupPage(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'CREATE ACCOUNT'));
    await tester.pump();

    expect(find.text('メールアドレスとパスワードを入力してください'), findsOneWidget);
  });
}
