import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/presentation/viewmodels/admin_event_view_model.dart';
import 'package:flutter_application_1/presentation/views/event/admin/create_event_page.dart';
import '../helpers/admin_event_test_helpers.dart';

void main() {
  setupTestEnvironment();

  late MockAdminEventRepository mockRepository;
  late AdminEventViewModel viewModel;

  setUp(() {
    mockRepository = MockAdminEventRepository();
    viewModel = AdminEventViewModel(mockRepository);
  });

  group('CreateEventPage Widget Tests', () {
    testWidgets('場所検索の非同期応答待ち時に入力が変更された場合、古い座標で確定されないこと', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          viewModel: viewModel,
          child: const CreateEventPage(groupId: 'test-group', myRole: 0),
        ),
      );
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'テストイベント');
      await tester.pump();

      await tester.enterText(textFields.at(1), '1234');
      await tester.pump();

      final locationField = find.widgetWithText(
        TextField,
        'Search location...',
      );
      expect(locationField, findsOneWidget);
      await tester.enterText(locationField, 'Initial Location');
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      await tester.enterText(locationField, 'Modified Location');
      await tester.pump();

      await tester.pumpAndSettle();

      final confirmButton = find.text('Confirm Participant');
      await tester.ensureVisible(confirmButton);
      await tester.tap(confirmButton);
      await tester.pump();

      expect(find.text('目的地の場所をキーボードの「検索」で確定してください'), findsOneWidget);
    });

    testWidgets('遷移処理中は Confirm Participant ボタンが無効化（onTap が null）されること', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          viewModel: viewModel,
          child: const CreateEventPage(groupId: 'test-group', myRole: 0),
        ),
      );
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'テストイベント');
      await tester.pump();
      await tester.enterText(textFields.at(1), '1234');
      await tester.pump();

      final locationField = find.widgetWithText(
        TextField,
        'Search location...',
      );
      await tester.enterText(locationField, 'Initial Location');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final buttonFinder = find.widgetWithText(InkWell, 'Confirm Participant');
      await tester.ensureVisible(buttonFinder);
      await tester.pumpAndSettle();

      expect(tester.widget<InkWell>(buttonFinder).onTap, isNotNull);

      await tester.tap(buttonFinder);
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.widget<InkWell>(buttonFinder).onTap, isNull);

      await tester.pumpAndSettle();
    });
  });
}
