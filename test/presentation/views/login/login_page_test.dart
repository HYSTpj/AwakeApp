import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/data/repositories/auth_repository.dart';
import 'package:flutter_application_1/presentation/viewmodels/auth_view_model.dart';
import 'package:flutter_application_1/presentation/views/login/login_page.dart';
import 'package:flutter_application_1/presentation/views/login/signup_page.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthViewModel viewModel;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    viewModel = AuthViewModel(mockAuthRepository);
  });

  Future<void> pumpLoginPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>.value(
        value: viewModel,
        child: const MaterialApp(home: LoginPage()),
      ),
    );
  }

  testWidgets(
      'メール・パスワードが空の場合、LOGINボタン押下でAuthRepository.signInが呼ばれず早期リターンすること',
      (tester) async {
    await pumpLoginPage(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
    await tester.pump();

    verifyNever(() => mockAuthRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ));
  });

  testWidgets(
      'メールのみ空（パスワードは入力済み）の場合も、signInが呼ばれず早期リターンすること',
      (tester) async {
    await pumpLoginPage(tester);

    await tester.enterText(find.byType(TextField).last, 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
    await tester.pump();

    verifyNever(() => mockAuthRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ));
  });

  testWidgets(
      'パスワードのみ空（メールは入力済み）の場合も、signInが呼ばれず早期リターンすること',
      (tester) async {
    await pumpLoginPage(tester);

    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
    await tester.pump();

    verifyNever(() => mockAuthRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ));
  });

  testWidgets(
      'メール・パスワードが空の場合、LOGINボタン押下でSnackBarが表示されること',
      (tester) async {
    await pumpLoginPage(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
    await tester.pump();

    expect(find.text('メールアドレスとパスワードを入力してください'), findsOneWidget);
  });

  testWidgets(
      'CREATE ACCOUNTリンク押下でCreateAccountPageへ画面遷移すること',
      (tester) async {
    await pumpLoginPage(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'CREATE ACCOUNT'));
    await tester.pumpAndSettle();

    expect(find.byType(CreateAccountPage), findsOneWidget);
  });
}
