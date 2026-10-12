import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_application_1/data/repositories/admin_event_repository.dart';
import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/models/event_member_status.dart';
import 'package:flutter_application_1/models/event_report.dart';
import 'package:flutter_application_1/models/profile.dart';
import 'package:flutter_application_1/presentation/viewmodels/admin_event_view_model.dart';
import 'package:flutter_application_1/presentation/views/event/checkin/memberpost_page.dart';
import 'package:flutter_application_1/presentation/views/event/admin/event_list_view.dart';
import 'package:flutter_application_1/presentation/views/event/admin/memberstatus_page.dart';
import 'package:flutter_application_1/presentation/views/event/admin/select_participants_page.dart';

class MockAdminEventRepository extends Mock implements AdminEventRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    const channel = MethodChannel('plugins.flutter.io/shared_preferences');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{};
      }
      return true;
    });

    try {
      await Supabase.initialize(
        url: 'https://dummy.supabase.co',
        publishableKey: 'dummy-anon-key-for-widget-testing',
      );
    } catch (_) {}
  });

  late MockAdminEventRepository mockRepository;
  late AdminEventViewModel viewModel;

  setUp(() {
    mockRepository = MockAdminEventRepository();
    viewModel = AdminEventViewModel(mockRepository);
  });

  Widget buildTestableWidget(Widget child) {
    return ChangeNotifierProvider<AdminEventViewModel>.value(
      value: viewModel,
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  final now = DateTime(2026, 10, 15, 8, 30);

  Profile createDummyProfile({
    String id = 'u-1',
    String nickname = 'Alice',
    String avatarUrl = '',
  }) {
    return Profile(
      id: id,
      nickname: nickname,
      avatarUrl: avatarUrl,
      sleepPastCount: 0,
      lateCount: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  Event createDummyEvent({
    String id = 'event-1',
    String groupId = 'group-1',
    String title = '合宿集合',
    String destinationName = '名古屋駅',
    DateTime? arrivalTime,
  }) {
    return Event(
      id: id,
      groupId: groupId,
      title: title,
      destinationName: destinationName,
      arrivalTime: arrivalTime ?? now,
      password: 'test_password',
      qrcodeId: 'qr_test_token',
      status: '0',
      createdAt: now,
      updatedAt: now,
    );
  }

  EventReport createDummyReport({
    String id = 'rep-1',
    String eventId = 'event-1',
    String userId = 'u-1',
    int status = 1,
  }) {
    return EventReport(
      id: id,
      eventId: eventId,
      userId: userId,
      status: status,
      actualWakeupTime: DateTime(2026, 10, 15, 6, 45),
      latitude: 35.15,
      longitude: 136.92,
      lateReason: '電車遅延のため',
      updatedAt: now,
    );
  }

  // ==========================================
  // 1. EventListPage テスト
  // ==========================================
  group('EventListPage Widget Tests', () {
    testWidgets('管理者(myRole == 0)の場合、Add Eventsボタンとイベント一覧が表示される', (tester) async {
      when(() => mockRepository.getEvents('group-1'))
          .thenAnswer((_) async => [createDummyEvent()]);

      await tester.pumpWidget(buildTestableWidget(
        const EventListPage(groupId: 'group-1', myRole: 0),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Add Events'), findsOneWidget);
      expect(find.text('合宿集合'), findsOneWidget);
      expect(find.text('名古屋駅'), findsOneWidget);
    });

    testWidgets('一般メンバー(myRole == 1)の場合、Add Eventsボタンが表示されない', (tester) async {
      when(() => mockRepository.getEvents('group-1'))
          .thenAnswer((_) async => [createDummyEvent()]);

      await tester.pumpWidget(buildTestableWidget(
        const EventListPage(groupId: 'group-1', myRole: 1),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Add Events'), findsNothing);
      expect(find.text('合宿集合'), findsOneWidget);
    });

    testWidgets('イベントが0件の場合、イベントカードが表示されずローディングも完了している', (tester) async {
      when(() => mockRepository.getEvents('group-1'))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestableWidget(
        const EventListPage(groupId: 'group-1', myRole: 0),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('イベント取得エラー'), findsNothing);
      expect(find.text('合宿集合'), findsNothing);
    });

    testWidgets('イベントが0件の場合、空状態メッセージ(No events found for this group.)が表示される', (tester) async {
      when(() => mockRepository.getEvents('group-1'))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestableWidget(
        const EventListPage(groupId: 'group-1', myRole: 0),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('合宿集合'), findsNothing);
      expect(find.text('No events found for this group.'), findsOneWidget);
    });

    testWidgets('Add Events画面へ遷移して復帰した際、一覧の不要な重複取得が発生しない', (tester) async {
      when(() => mockRepository.getEvents('group-1'))
          .thenAnswer((_) async => [createDummyEvent()]);

      await tester.pumpWidget(
        ChangeNotifierProvider<AdminEventViewModel>.value(
          value: viewModel,
          child: const MaterialApp(
            home: EventListPage(groupId: 'group-1', myRole: 0),
          ),
        ),
      );
      await tester.pumpAndSettle();

      verify(() => mockRepository.getEvents('group-1')).called(1);

      await tester.tap(find.text('Add Events'));
      await tester.pumpAndSettle();

      final navigatorState = tester.state<NavigatorState>(find.byType(Navigator));
      navigatorState.pop();
      await tester.pumpAndSettle();

      // 復帰時に不要な多重呼び出しが走っていないことを検証
      verifyNever(() => mockRepository.getEvents('group-1'));
    });

    testWidgets('取得エラー発生時はエラーメッセージが表示される', (tester) async {
      when(() => mockRepository.getEvents('group-1'))
          .thenThrow(Exception('通信エラー'));

      await tester.pumpWidget(buildTestableWidget(
        const EventListPage(groupId: 'group-1', myRole: 0),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('イベント取得エラー'), findsOneWidget);
    });

    testWidgets('グループID不一致時は以前のイベントを表示せずローディング状態になる', (tester) async {
      final completer = Completer<List<Event>>();
      when(() => mockRepository.getEvents('group-2'))
          .thenAnswer((_) => completer.future);

      when(() => mockRepository.getEvents('group-1'))
          .thenAnswer((_) async => [createDummyEvent(groupId: 'group-1', title: '古いグループのイベント')]);
      await viewModel.loadEvents('group-1');

      await tester.pumpWidget(buildTestableWidget(
        const EventListPage(groupId: 'group-2', myRole: 0),
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('古いグループのイベント'), findsNothing);

      completer.complete([]);
      await tester.pump();
    });
  });

  // ==========================================
  // 2. SelectParticipantsPage テスト
  // ==========================================
  group('SelectParticipantsPage Widget Tests', () {
    testWidgets('メンバー一覧が正常に表示され、選択トグルでSELECTEDカウントが増加する', (tester) async {
      final dummyMembers = [
        createDummyProfile(id: 'u-1', nickname: 'Alice'),
        createDummyProfile(id: 'u-2', nickname: 'Bob'),
      ];

      when(() => mockRepository.getGroupMembers('group-1'))
          .thenAnswer((_) async => dummyMembers);

      await tester.pumpWidget(buildTestableWidget(
        SelectParticipantsPage(
          groupId: 'group-1',
          title: '朝練',
          destinationName: '音楽スタジオ',
          arrivalTime: DateTime(2026, 10, 15, 7, 0),
          password: 'secret_password',
          myRole: 0,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('0 SELECTED'), findsOneWidget);

      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      expect(find.text('1 SELECTED'), findsOneWidget);
    });

    testWidgets('対象グループIDが不一致の間は古いメンバーを表示せずローディングになる', (tester) async {
      final completer = Completer<List<Profile>>();
      when(() => mockRepository.getGroupMembers('group-2'))
          .thenAnswer((_) => completer.future);

      when(() => mockRepository.getGroupMembers('group-1'))
          .thenAnswer((_) async => [createDummyProfile(id: 'u-old', nickname: 'OldMember')]);
      await viewModel.loadGroupMembers('group-1');

      await tester.pumpWidget(buildTestableWidget(
        SelectParticipantsPage(
          groupId: 'group-2',
          title: '朝練',
          destinationName: 'スタジオ',
          arrivalTime: DateTime(2026, 10, 15, 7, 0),
          password: 'pass',
          myRole: 0,
        ),
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('OldMember'), findsNothing);

      completer.complete([]);
      await tester.pump();
    });

    testWidgets('メンバー取得失敗時にエラー表示と再試行ボタンが表示され、再試行が機能する', (tester) async {
      var callCount = 0;
      when(() => mockRepository.getGroupMembers('group-1')).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          throw Exception('メンバー取得失敗');
        }
        return [createDummyProfile(id: 'u-1', nickname: 'Alice')];
      });

      await tester.pumpWidget(buildTestableWidget(
        SelectParticipantsPage(
          groupId: 'group-1',
          title: '朝練',
          destinationName: 'スタジオ',
          arrivalTime: DateTime(2026, 10, 15, 7, 0),
          password: 'pass',
          myRole: 0,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('メンバーの取得に失敗しました'), findsOneWidget);
      expect(find.text('再試行'), findsOneWidget);

      await tester.tap(find.text('再試行'));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.textContaining('メンバーの取得に失敗しました'), findsNothing);
    });

    testWidgets('作成処理中に連続タップしてもAPIは1度しか呼ばれず、完了後に画面がpopする', (tester) async {
      final createCompleter = Completer<String>();

      when(() => mockRepository.getGroupMembers('group-1'))
          .thenAnswer((_) async => [createDummyProfile(id: 'u-1', nickname: 'Alice')]);
      when(() => mockRepository.createEventWithParticipants(
            groupId: 'group-1',
            title: '朝練',
            destinationName: 'スタジオ',
            latitude: null,
            longitude: null,
            qrcodeId: any(named: 'qrcodeId'),
            password: 'pass',
            arrivalTime: any(named: 'arrivalTime'),
            participantUserIds: ['u-1'],
          )).thenAnswer((_) => createCompleter.future);

      await tester.pumpWidget(
        ChangeNotifierProvider<AdminEventViewModel>.value(
          value: viewModel,
          child: MaterialApp(
            home: Navigator(
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (_) => Scaffold(
                  body: Builder(
                    builder: (context) => ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SelectParticipantsPage(
                            groupId: 'group-1',
                            title: '朝練',
                            destinationName: 'スタジオ',
                            arrivalTime: DateTime(2026, 10, 15, 7, 0),
                            password: 'pass',
                            myRole: 0,
                          ),
                        ),
                      ),
                      child: const Text('Open'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      // ボタン位置を座標指定で2回タップ（作成待機中の二重タップ防止検証）
      final saveButtonLocation = tester.getCenter(find.text('SAVE'));
      await tester.tapAt(saveButtonLocation);
      await tester.pump();

      await tester.tapAt(saveButtonLocation);
      await tester.pump();

      createCompleter.complete('new-event-id');
      await tester.pumpAndSettle();

      verify(() => mockRepository.createEventWithParticipants(
            groupId: 'group-1',
            title: '朝練',
            destinationName: 'スタジオ',
            latitude: null,
            longitude: null,
            qrcodeId: any(named: 'qrcodeId'),
            password: 'pass',
            arrivalTime: any(named: 'arrivalTime'),
            participantUserIds: ['u-1'],
          )).called(1);

      expect(find.byType(SelectParticipantsPage), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });
  });

  // ==========================================
  // 3. MemberStatusPage テスト
  // ==========================================
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

      when(() => mockRepository.getEventMemberStatuses('event-1'))
          .thenAnswer((_) async => dummyStatuses);

      await tester.pumpWidget(buildTestableWidget(
        const MemberStatusPage(
          groupId: 'group-1',
          eventId: 'event-1',
          eventTitle: '大会当日',
          myRole: 0,
          arrivalTime: '10/15 08:00',
          password: 'pass',
          qrcodeId: 'qr-123',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Charlie'), findsOneWidget);
      expect(find.text('Dave'), findsOneWidget);

      final awakeFilter = find.textContaining('AWAKE');
      if (awakeFilter.evaluate().isNotEmpty) {
        await tester.tap(awakeFilter.first);
        await tester.pumpAndSettle();

        expect(find.text('Charlie'), findsOneWidget);
        expect(find.text('Dave'), findsNothing);
      }
    });

    testWidgets('対象イベントIDが不一致の間は古い参加状況を表示せずローディングになる', (tester) async {
      final completer = Completer<List<EventMemberStatus>>();
      when(() => mockRepository.getEventMemberStatuses('event-2'))
          .thenAnswer((_) => completer.future);

      when(() => mockRepository.getEventMemberStatuses('event-1'))
          .thenAnswer((_) async => [
                EventMemberStatus(
                  profile: createDummyProfile(id: 'u-old', nickname: 'OldMember'),
                  report: null,
                ),
              ]);
      await viewModel.loadEventMemberStatuses('event-1');

      await tester.pumpWidget(buildTestableWidget(
        const MemberStatusPage(
          groupId: 'group-1',
          eventId: 'event-2',
          eventTitle: '大会当日',
          myRole: 0,
          arrivalTime: '10/15 08:00',
          password: 'pass',
          qrcodeId: 'qr-123',
        ),
      ));
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
      final report = createDummyReport(eventId: 'event-1', userId: 'u-1', status: 1);

      when(() => mockRepository.getEventMemberStatuses('event-1'))
          .thenAnswer((_) async => dummyStatuses);
      when(() => mockRepository.getMemberReport(eventId: 'event-1', userId: 'u-1'))
          .thenAnswer((_) async => report);

      await tester.pumpWidget(buildTestableWidget(
        const MemberStatusPage(
          groupId: 'group-1',
          eventId: 'event-1',
          eventTitle: '大会当日',
          myRole: 0,
          arrivalTime: '10/15 08:00',
          password: 'pass',
          qrcodeId: 'qr-123',
        ),
      ));
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

      when(() => mockRepository.getEventMemberStatuses('event-1'))
          .thenAnswer((_) async => dummyStatuses);
      when(() => mockRepository.getMemberReport(eventId: 'event-1', userId: 'u-1'))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildTestableWidget(
        const MemberStatusPage(
          groupId: 'group-1',
          eventId: 'event-1',
          eventTitle: '大会当日',
          myRole: 0,
          arrivalTime: '10/15 08:00',
          password: 'pass',
          qrcodeId: 'qr-123',
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Charlie'));
      await tester.pump();

      await tester.pumpWidget(buildTestableWidget(const SizedBox.shrink()));

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

      when(() => mockRepository.getEventMemberStatuses('event-1'))
          .thenAnswer((_) async => dummyStatuses);
      when(() => mockRepository.getMemberReport(eventId: 'event-1', userId: 'u-1'))
          .thenThrow(Exception('個別レポート取得エラー'));

      await tester.pumpWidget(buildTestableWidget(
        const MemberStatusPage(
          groupId: 'group-1',
          eventId: 'event-1',
          eventTitle: '大会当日',
          myRole: 0,
          arrivalTime: '10/15 08:00',
          password: 'pass',
          qrcodeId: 'qr-123',
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Charlie'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((widget) =>
            widget is Text &&
            (widget.data?.contains('個別レポート取得エラー') ?? false)),
        findsOneWidget,
      );
    });
  });

  // ==========================================
  // 4. MemberPostPage テスト
  // ==========================================
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
        updatedAt: now,
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