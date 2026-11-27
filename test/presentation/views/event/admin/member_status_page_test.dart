import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/models/event_member_status.dart';
import 'package:flutter_application_1/models/event_report.dart';
import 'package:flutter_application_1/presentation/viewmodels/auth_view_model.dart';
import 'package:flutter_application_1/presentation/viewmodels/admin_event_view_model.dart';
import 'package:flutter_application_1/presentation/views/event/admin/memberstatus_page.dart';
import 'package:flutter_application_1/presentation/views/event/checkin/memberpost_page.dart';
import '../helpers/admin_event_test_helpers.dart';

void main() {
  setupTestEnvironment();

  late MockAdminEventRepository mockRepository;
  late AdminEventViewModel viewModel;

  setUp(() {
    mockRepository = MockAdminEventRepository();
    viewModel = AdminEventViewModel(mockRepository);
  });

  group('MemberStatusPage Widget Tests', () {
    testWidgets('ステータスフィルターの切り替えで該当ステータスのメンバーのみ絞り込まれる', (tester) async {
      final dummyStatuses = [
        EventMemberStatus(
          profile: createDummyProfile(id: 'u-1', nickname: 'Charlie'),
          report: createDummyReport(userId: 'u-1', status: 1), // AWAKE
        ),
        EventMemberStatus(
          profile: createDummyProfile(id: 'u-2', nickname: 'Dave'),
          report: createDummyReport(userId: 'u-2', status: 4), // ARRIVED
        ),
      ];

      when(
        () => mockRepository.getEventMemberStatuses('event-1'),
      ).thenAnswer((_) async => dummyStatuses);

      await tester.pumpWidget(
        buildTestableWidget(
          viewModel: viewModel,
          child: const MemberStatusPage(
            groupId: 'group-1',
            eventId: 'event-1',
            eventTitle: '大会当日',
            myRole: 0,
            arrivalTime: '10/15 08:00',
            password: 'pass',
            qrcodeId: 'qr-123',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Charlie'), findsOneWidget);
      expect(find.text('Dave'), findsOneWidget);

      // 一覧のステータス表示とフィルターボタンの両方を確認
      final awakeWidgets = find.textContaining('AWAKE');
      expect(awakeWidgets, findsNWidgets(2));

      await tester.tap(awakeWidgets.first);
      await tester.pumpAndSettle();

      expect(find.text('Charlie'), findsOneWidget);
      expect(find.text('Dave'), findsNothing);
    });

    testWidgets('対象イベントIDが不一致の間は古い参加状況を表示せずローディングになる', (tester) async {
      final completer = Completer<List<EventMemberStatus>>();
      when(
        () => mockRepository.getEventMemberStatuses('event-2'),
      ).thenAnswer((_) => completer.future);

      when(() => mockRepository.getEventMemberStatuses('event-1')).thenAnswer(
        (_) async => [
          EventMemberStatus(
            profile: createDummyProfile(id: 'u-old', nickname: 'OldMember'),
            report: null,
          ),
        ],
      );
      await viewModel.loadEventMemberStatuses('event-1');

      await tester.pumpWidget(
        buildTestableWidget(
          viewModel: viewModel,
          child: const MemberStatusPage(
            groupId: 'group-1',
            eventId: 'event-2',
            eventTitle: '大会当日',
            myRole: 0,
            arrivalTime: '10/15 08:00',
            password: 'pass',
            qrcodeId: 'qr-123',
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('OldMember'), findsNothing);

      completer.complete([]);
      await tester.pump();
    });

    testWidgets('レポート取得成功時に型安全なMemberPostPageへ遷移する', (tester) async {
      final dummyStatuses = [
        EventMemberStatus(
          profile: createDummyProfile(id: 'u-1', nickname: 'Charlie'),
          report: null,
        ),
      ];
      final report = createDummyReport(
        eventId: 'event-1',
        userId: 'u-1',
        status: 1,
      );

      when(
        () => mockRepository.getEventMemberStatuses('event-1'),
      ).thenAnswer((_) async => dummyStatuses);
      when(
        () => mockRepository.getMemberReport(eventId: 'event-1', userId: 'u-1'),
      ).thenAnswer((_) async => report);

      await tester.pumpWidget(
        buildTestableWidget(
          viewModel: viewModel,
          child: const MemberStatusPage(
            groupId: 'group-1',
            eventId: 'event-1',
            eventTitle: '大会当日',
            myRole: 0,
            arrivalTime: '10/15 08:00',
            password: 'pass',
            qrcodeId: 'qr-123',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Charlie'));
      await tester.pumpAndSettle();

      expect(find.byType(MemberPostPage), findsOneWidget);
      expect(find.text('LATE REASON'), findsOneWidget);
    });

    testWidgets('レポート非同期取得中に画面が破棄されてもエラーが発生しない(mountedガード)', (tester) async {
      final completer = Completer<EventReport?>();
      final dummyStatuses = [
        EventMemberStatus(
          profile: createDummyProfile(id: 'u-1', nickname: 'Charlie'),
          report: null,
        ),
      ];

      when(
        () => mockRepository.getEventMemberStatuses('event-1'),
      ).thenAnswer((_) async => dummyStatuses);
      when(
        () => mockRepository.getMemberReport(eventId: 'event-1', userId: 'u-1'),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        buildTestableWidget(
          viewModel: viewModel,
          child: const MemberStatusPage(
            groupId: 'group-1',
            eventId: 'event-1',
            eventTitle: '大会当日',
            myRole: 0,
            arrivalTime: '10/15 08:00',
            password: 'pass',
            qrcodeId: 'qr-123',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Charlie'));
      await tester.pump();

      await tester.pumpWidget(
        buildTestableWidget(
          viewModel: viewModel,
          child: const SizedBox.shrink(),
        ),
      );

      completer.complete(createDummyReport(eventId: 'event-1', userId: 'u-1'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('レポート取得失敗時はエラー通知スナックバーを表示する', (tester) async {
      final dummyStatuses = [
        EventMemberStatus(
          profile: createDummyProfile(id: 'u-1', nickname: 'Charlie'),
          report: null,
        ),
      ];

      when(
        () => mockRepository.getEventMemberStatuses('event-1'),
      ).thenAnswer((_) async => dummyStatuses);
      when(
        () => mockRepository.getMemberReport(eventId: 'event-1', userId: 'u-1'),
      ).thenThrow(Exception('個別レポート取得エラー'));

      await tester.pumpWidget(
        buildTestableWidget(
          viewModel: viewModel,
          child: const MemberStatusPage(
            groupId: 'group-1',
            eventId: 'event-1',
            eventTitle: '大会当日',
            myRole: 0,
            arrivalTime: '10/15 08:00',
            password: 'pass',
            qrcodeId: 'qr-123',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Charlie'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text && (widget.data?.contains('個別レポート取得エラー') ?? false),
        ),
        findsOneWidget,
      );
    });

    testWidgets('statusesError がある場合、エラーメッセージと再試行ボタンが表示されること', (tester) async {
      when(
        () => mockRepository.getEventMemberStatuses('evt_1'),
      ).thenThrow(Exception('参加状況の取得に失敗しました'));

      await tester.pumpWidget(
        buildTestableWidget(
          viewModel: viewModel,
          child: const MemberStatusPage(
            groupId: 'grp_1',
            eventId: 'evt_1',
            eventTitle: 'Test Event',
            myRole: 0,
            arrivalTime: '09:00',
            password: 'pass',
            qrcodeId: 'qr_1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('参加状況の取得に失敗しました'), findsOneWidget);
      expect(find.text('再試行'), findsOneWidget);
    });

    testWidgets('個別レポートが null の場合、MemberPostPage に遷移せず通知が表示されること', (
      tester,
    ) async {
      when(() => mockRepository.getEventMemberStatuses('evt_1')).thenAnswer(
        (_) async => [
          EventMemberStatus(
            profile: createDummyProfile(id: 'usr_1', nickname: 'Member 1'),
            report: null,
          ),
        ],
      );
      when(
        () => mockRepository.getMemberReport(eventId: 'evt_1', userId: 'usr_1'),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(
        buildTestableWidget(
          viewModel: viewModel,
          child: const MemberStatusPage(
            groupId: 'grp_1',
            eventId: 'evt_1',
            eventTitle: 'Test Event',
            myRole: 0,
            arrivalTime: '09:00',
            password: 'pass',
            qrcodeId: 'qr_1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Member 1'));
      await tester.pumpAndSettle();

      expect(find.byType(MemberPostPage), findsNothing);
      expect(find.text('There are no posts yet.'), findsOneWidget);
    });

    testWidgets('個別レポート取得中に画面が pop された場合、完了後に画面遷移が発生しないこと', (tester) async {
      final cReport = Completer<EventReport?>();
      when(() => mockRepository.getEventMemberStatuses('evt_1')).thenAnswer(
        (_) async => [
          EventMemberStatus(
            profile: createDummyProfile(id: 'usr_1', nickname: 'Member 1'),
            report: null,
          ),
        ],
      );
      when(
        () => mockRepository.getMemberReport(eventId: 'evt_1', userId: 'usr_1'),
      ).thenAnswer((_) => cReport.future);

      final rootNavKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: rootNavKey,
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {
                rootNavKey.currentState!.push(
                  MaterialPageRoute(
                    builder: (_) => MultiProvider(
                      providers: [
                        ChangeNotifierProvider<AdminEventViewModel>.value(
                          value: viewModel,
                        ),
                        ChangeNotifierProvider<AuthViewModel>.value(
                          value: createMockAuthViewModel(),
                        ),
                      ],
                      child: const Scaffold(
                        body: MemberStatusPage(
                          groupId: 'grp_1',
                          eventId: 'evt_1',
                          eventTitle: 'Test Event',
                          myRole: 0,
                          arrivalTime: '09:00',
                          password: 'pass',
                          qrcodeId: 'qr_1',
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Member 1'));
      await tester.pump();

      rootNavKey.currentState!.pop();
      await tester.pumpAndSettle();

      cReport.complete(
        EventReport(
          id: 'rep_1',
          eventId: 'evt_1',
          userId: 'usr_1',
          status: 4,
          updatedAt: DateTime.now(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MemberPostPage), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('個別レポート取得成功時、遷移先の MemberPostPage に正しい値が引き渡されていること', (
      tester,
    ) async {
      final dummyReport = EventReport(
        id: 'rep_target_1',
        eventId: 'evt_1',
        userId: 'usr_1',
        status: 4,
        lateReason: null,
        photoUrl: 'https://example.com/test.jpg',
        latitude: 35.6812,
        longitude: 139.7671,
        updatedAt: DateTime(2026, 10, 14, 9, 30),
      );

      when(() => mockRepository.getEventMemberStatuses('evt_1')).thenAnswer(
        (_) async => [
          EventMemberStatus(
            profile: createDummyProfile(id: 'usr_1', nickname: 'Member Target'),
            report: null,
          ),
        ],
      );
      when(
        () => mockRepository.getMemberReport(eventId: 'evt_1', userId: 'usr_1'),
      ).thenAnswer((_) async => dummyReport);

      await tester.pumpWidget(
        buildTestableWidget(
          viewModel: viewModel,
          child: const MemberStatusPage(
            groupId: 'grp_1',
            eventId: 'evt_1',
            eventTitle: 'Test Event Title',
            myRole: 0,
            arrivalTime: '09:00',
            password: 'pass',
            qrcodeId: 'qr_1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Member Target'));
      await tester.pumpAndSettle();

      final postPageFinder = find.byType(MemberPostPage);
      expect(postPageFinder, findsOneWidget);

      final postPageWidget = tester.widget<MemberPostPage>(postPageFinder);
      expect(postPageWidget.profile.id, 'usr_1');
      expect(postPageWidget.profile.nickname, 'Member Target');
      expect(postPageWidget.report.id, 'rep_target_1');
      expect(postPageWidget.report.latitude, 35.6812);
      expect(postPageWidget.report.longitude, 139.7671);
    });
  });
}
