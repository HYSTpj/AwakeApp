import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Member set time UI smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('My Schedule'), findsOneWidget);
    expect(find.text('SAVE CHANGES'), findsOneWidget);
  });
}
