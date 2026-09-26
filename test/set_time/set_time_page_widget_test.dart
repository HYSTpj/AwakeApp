import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/set_time_page.dart';
import 'package:flutter_application_1/viewmodels/set_time_viewmodel.dart';
import 'package:flutter/material.dart';

// SetTimePage は内部の CommonLayout で FirebaseAuth.instance を参照するため、
// Firebase未初期化のままpumpWidgetすると [core/no-app] で失敗する。
// test/flutter_test_config.dart が全テストに対して自動でFirebaseの初期化を
// 済ませるため、このファイルで個別にセットアップする必要はない。
void main() {
  testWidgets('Member set time UI smoke test', (WidgetTester tester) async {
    // Inject a test view model to avoid Firebase dependency during build
    final vm = SetTimeViewModel(eventId: 'test');
    await tester.pumpWidget(MaterialApp(
      home: SetTimePage(
        groupId: 'test',
        eventId: 'test',
        eventTitle: 'test',
        myRole: 0,
        arrivalTime: DateTime(2023, 1, 1, 9, 0), 
        viewModel: vm
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('My Schedule'), findsOneWidget);
    expect(find.text('SAVE CHANGES'), findsOneWidget);
  });
}
