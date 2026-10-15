import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/models/event_report.dart';
import 'package:flutter_application_1/presentation/views/event/checkin/memberpost_page.dart';
import '../helpers/admin_event_test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('MemberPostPage Widget Tests', () {
    testWidgets('ProfileおよびEventReportの情報が型安全に描画される', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final dummyProfile = createDummyProfile(
        id: 'u-1',
        nickname: 'Eve',
        avatarUrl: '',
      );

      final dummyReport = EventReport(
        id: 'rep-1',
        eventId: 'event-1',
        userId: 'u-1',
        status: 2,
        actualWakeupTime: DateTime(2026, 10, 15, 6, 45),
        latitude: 35.15,
        longitude: 136.92,
        lateReason: '電車遅延のため',
        updatedAt: testNow,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemberPostPage(
              profile: dummyProfile,
              report: dummyReport,
              status: 2,
              groupId: 'group-1',
              eventId: 'event-1',
              eventTitle: '大会当日',
              myRole: 0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Eve'), findsOneWidget);
      expect(find.text('WAKE-UP: 10/15 06:45'), findsOneWidget);

      final locationFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            (widget.data?.contains('35.') ?? false) &&
            (widget.data?.contains('136.') ?? false),
      );
      await tester.scrollUntilVisible(locationFinder, 100);
      await tester.pumpAndSettle();

      expect(locationFinder, findsOneWidget);
      expect(find.text('電車遅延のため'), findsOneWidget);
    });
  });
}
