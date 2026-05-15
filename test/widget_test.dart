import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/set_time_page.dart';
import 'package:flutter_application_1/viewmodels/set_time_viewmodel.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Member set time UI smoke test', (WidgetTester tester) async {
    // Inject a test view model to avoid Firebase dependency during build
    final vm = SetTimeViewModel(eventId: 'test');
    await tester.pumpWidget(MaterialApp(
      home: SetTimePage(eventId: 'test', arrivalTime: DateTime(2023, 1, 1, 9, 0), viewModel: vm),
    ));
    await tester.pumpAndSettle();

    expect(find.text('My Schedule'), findsOneWidget);
    expect(find.text('SAVE CHANGES'), findsOneWidget);
  });
}
