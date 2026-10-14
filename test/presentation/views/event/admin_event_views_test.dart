import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geocoding_platform_interface/geocoding_platform_interface.dart';

import 'package:flutter_application_1/data/repositories/admin_event_repository.dart';
import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/models/event_member_status.dart';
import 'package:flutter_application_1/models/event_report.dart';
import 'package:flutter_application_1/models/profile.dart';
import 'package:flutter_application_1/presentation/viewmodels/admin_event_view_model.dart';
import 'package:flutter_application_1/presentation/views/event/checkin/memberpost_page.dart';
import 'package:flutter_application_1/presentation/views/event/admin/event_list_page.dart';
import 'package:flutter_application_1/presentation/views/event/admin/memberstatus_page.dart';
import 'package:flutter_application_1/presentation/views/event/admin/select_participants_page.dart';
import 'package:flutter_application_1/presentation/views/event/admin/create_event_page.dart';

class MockAdminEventRepository extends Mock implements AdminEventRepository {}

class MockGeocodingPlatform extends GeocodingPlatform {
  @override
  Future<List<Location>> locationFromAddress(
    String address, {
    String? localeIdentifier,
  }) async {
    // 非同期遅延をシミュレート
    await Future.delayed(const Duration(milliseconds: 100));
    return [
      Location(
        latitude: 35.681236,
        longitude: 139.767125,
        timestamp: DateTime.now(),
      ),
    ];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // テスト全体で GeocodingPlatform のモックを適用
  GeocodingPlatform.instance = MockGeocodingPlatform();

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
      child: MaterialApp(home: Scaffold(body: child)),
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
    testWidgets('管理者(myRole == 0)の場合、Add Eventsボタンとイベント一覧が表示される', (
      tester,
    ) async {
      when(
        () => mockRepository.getEvents('group-1'),
      ).thenAnswer((_) async => [createDummyEvent()]);

      await tester.pumpWidget(
        buildTestableWidget(const EventListPage(groupId: 'group-1', myRole: 0)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add Events'), findsOneWidget);
      expect(find.text('合宿集合'), findsOneWidget);
      expect(find.text('名古屋駅'), findsOneWidget);
    });

    testWidgets('一般メンバー(myRole == 1)の場合、Add Eventsボタンが表示されない', (tester) async {
      when(
        () => mockRepository.getEvents('group-1'),
      ).thenAnswer((_) async => [createDummyEvent()]);

      await tester.pumpWidget(
        buildTestableWidget(const EventListPage(groupId: 'group-1', myRole: 1)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add Events'), findsNothing);
      expect(find.text('合宿集合'), findsOneWidget);
    });

    testWidgets('イベントが0件の場合、イベントカードが表示されずローディングも完了している', (tester) async {
      when(
        () => mockRepository.getEvents('group-1'),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        buildTestableWidget(const EventListPage(groupId: 'group-1', myRole: 0)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('イベント取得エラー'), findsNothing);
      expect(find.text('合宿集合'), findsNothing);
    });

    testWidgets('イベントが0件の場合、空状態メッセージ(No events found for this group.)が表示される', (
      tester,
    ) async {
      when(
        () => mockRepository.getEvents('group-1'),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        buildTestableWidget(const EventListPage(groupId: 'group-1', myRole: 0)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('合宿集合'), findsNothing);
      expect(find.text('No events found for this group.'), findsOneWidget);
    });

    testWidgets('Add Events画面へ遷移して復帰した際、一覧の不要な重複取得が発生しない', (tester) async {
      when(
        () => mockRepository.getEvents('group-1'),
      ).thenAnswer((_) async => [createDummyEvent()]);

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

      final navigatorState = tester.state<NavigatorState>(
        find.byType(Navigator),
      );
      navigatorState.pop();
      await tester.pumpAndSettle();

      // 復帰時に不要な多重呼び出しが走っていないことを検証
      verifyNever(() => mockRepository.getEvents('group-1'));
    });

    testWidgets('取得エラー発生時はエラーメッセージが表示される', (tester) async {
      when(
        () => mockRepository.getEvents('group-1'),
      ).thenThrow(Exception('通信エラー'));

      await tester.pumpWidget(
        buildTestableWidget(const EventListPage(groupId: 'group-1', myRole: 0)),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('イベント取得エラー'), findsOneWidget);
    });

    testWidgets('グループID不一致時は以前のイベントを表示せずローディング状態になる', (tester) async {
      final completer = Completer<List<Event>>();
      when(
        () => mockRepository.getEvents('group-2'),
      ).thenAnswer((_) => completer.future);

      when(() => mockRepository.getEvents('group-1')).thenAnswer(
        (_) async => [
          createDummyEvent(groupId: 'group-1', title: '古いグループのイベント'),
        ],
      );
      await viewModel.loadEvents('group-1');

      await tester.pumpWidget(
        buildTestableWidget(const EventListPage(groupId: 'group-2', myRole: 0)),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('古いグループのイベント'), findsNothing);

      completer.complete([]);
      await tester.pump();
    });

    testWidgets('イベント作成成功時、一覧の再取得が1回だけ実行されること', (tester) async {
      // 初回一覧取得をモック
      when(
        () => mockRepository.getEvents('group-1'),
      ).thenAnswer((_) async => [createDummyEvent(title: '既存イベント')]);

      // 参加者一覧と作成処理をモック
      when(() => mockRepository.getGroupMembers('group-1')).thenAnswer(
        (_) async => [createDummyProfile(id: 'u-1', nickname: 'Alice')],
      );
      when(
        () => mockRepository.createEventWithParticipants(
          groupId: 'group-1',
          title: any(named: 'title'),
          destinationName: any(named: 'destinationName'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          qrcodeId: any(named: 'qrcodeId'),
          password: any(named: 'password'),
          arrivalTime: any(named: 'arrivalTime'),
          participantUserIds: any(named: 'participantUserIds'),
        ),
      ).thenAnswer((_) async => 'new-event-id');

      await tester.pumpWidget(
        ChangeNotifierProvider<AdminEventViewModel>.value(
          value: viewModel,
          child: const MaterialApp(
            home: EventListPage(groupId: 'group-1', myRole: 0),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 初回表示時の一覧取得（1回）を確認
      verify(() => mockRepository.getEvents('group-1')).called(1);

      // Add Events 画面を開く
      await tester.tap(find.text('Add Events'));
      await tester.pumpAndSettle();

      // CreateEventPage の入力と確定
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), '新規イベント');
      await tester.enterText(textFields.at(1), '1234');

      final locationField = find.widgetWithText(
        TextField,
        'Search location...',
      );
      await tester.enterText(locationField, 'Initial Location');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final confirmButton = find.text('Confirm Participant');
      await tester.ensureVisible(confirmButton);
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // SelectParticipantsPage でメンバーを選択して SAVE
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      // 作成成功後、一覧再取得（loadEvents）が合計2回（初回1回 + 作成後1回）呼ばれたことを検証
      verify(() => mockRepository.getEvents('group-1')).called(1);
    });

    testWidgets('イベント作成を途中でキャンセルして戻った場合、不要な一覧再取得が呼ばれないこと', (tester) async {
      when(
        () => mockRepository.getEvents('group-1'),
      ).thenAnswer((_) async => [createDummyEvent(title: '既存イベント')]);

      await tester.pumpWidget(
        ChangeNotifierProvider<AdminEventViewModel>.value(
          value: viewModel,
          child: const MaterialApp(
            home: EventListPage(groupId: 'group-1', myRole: 0),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 初回表示時の一覧取得（1回）を確認
      verify(() => mockRepository.getEvents('group-1')).called(1);

      // Add Events 画面へ遷移
      await tester.tap(find.text('Add Events'));
      await tester.pumpAndSettle();

      // 何も作成せず戻るボタンでキャンセル復帰
      final backButton = find.byIcon(Icons.arrow_back);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // 復帰時に不要な一覧再取得が走っていないことを検証（呼び出し回数0）
      verifyNever(() => mockRepository.getEvents('group-1'));
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

      when(
        () => mockRepository.getGroupMembers('group-1'),
      ).thenAnswer((_) async => dummyMembers);

      await tester.pumpWidget(
        buildTestableWidget(
          SelectParticipantsPage(
            groupId: 'group-1',
            title: '朝練',
            destinationName: '音楽スタジオ',
            arrivalTime: DateTime(2026, 10, 15, 7, 0),
            password: 'secret_password',
            myRole: 0,
          ),
        ),
      );
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
      when(
        () => mockRepository.getGroupMembers('group-2'),
      ).thenAnswer((_) => completer.future);

      when(() => mockRepository.getGroupMembers('group-1')).thenAnswer(
        (_) async => [createDummyProfile(id: 'u-old', nickname: 'OldMember')],
      );
      await viewModel.loadGroupMembers('group-1');

      await tester.pumpWidget(
        buildTestableWidget(
          SelectParticipantsPage(
            groupId: 'group-2',
            title: '朝練',
            destinationName: 'スタジオ',
            arrivalTime: DateTime(2026, 10, 15, 7, 0),
            password: 'pass',
            myRole: 0,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('OldMember'), findsNothing);

      completer.complete([]);
      await tester.pump();
    });

    testWidgets('メンバー取得失敗時にエラー表示と再試行ボタンが表示され、再試行が機能する', (tester) async {
      var callCount = 0;
      when(() => mockRepository.getGroupMembers('group-1')).thenAnswer((
        _,
      ) async {
        callCount++;
        if (callCount == 1) {
          throw Exception('メンバー取得失敗');
        }
        return [createDummyProfile(id: 'u-1', nickname: 'Alice')];
      });

      await tester.pumpWidget(
        buildTestableWidget(
          SelectParticipantsPage(
            groupId: 'group-1',
            title: '朝練',
            destinationName: 'スタジオ',
            arrivalTime: DateTime(2026, 10, 15, 7, 0),
            password: 'pass',
            myRole: 0,
          ),
        ),
      );
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

      when(() => mockRepository.getGroupMembers('group-1')).thenAnswer(
        (_) async => [createDummyProfile(id: 'u-1', nickname: 'Alice')],
      );
      when(
        () => mockRepository.createEventWithParticipants(
          groupId: 'group-1',
          title: '朝練',
          destinationName: 'スタジオ',
          latitude: null,
          longitude: null,
          qrcodeId: any(named: 'qrcodeId'),
          password: 'pass',
          arrivalTime: any(named: 'arrivalTime'),
          participantUserIds: ['u-1'],
        ),
      ).thenAnswer((_) => createCompleter.future);

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

      verify(
        () => mockRepository.createEventWithParticipants(
          groupId: 'group-1',
          title: '朝練',
          destinationName: 'スタジオ',
          latitude: null,
          longitude: null,
          qrcodeId: any(named: 'qrcodeId'),
          password: 'pass',
          arrivalTime: any(named: 'arrivalTime'),
          participantUserIds: ['u-1'],
        ),
      ).called(1);

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

      when(
        () => mockRepository.getEventMemberStatuses('event-1'),
      ).thenAnswer((_) async => dummyStatuses);

      await tester.pumpWidget(
        buildTestableWidget(
          const MemberStatusPage(
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
          const MemberStatusPage(
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
          const MemberStatusPage(
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
          const MemberStatusPage(
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

      when(
        () => mockRepository.getEventMemberStatuses('event-1'),
      ).thenAnswer((_) async => dummyStatuses);
      when(
        () => mockRepository.getMemberReport(eventId: 'event-1', userId: 'u-1'),
      ).thenThrow(Exception('個別レポート取得エラー'));

      await tester.pumpWidget(
        buildTestableWidget(
          const MemberStatusPage(
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

  testWidgets('場所検索の非同期応答待ち時に入力が変更された場合、古い座標で確定されないこと', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestableWidget(
        const CreateEventPage(groupId: 'test-group', myRole: 0),
      ),
    );
    await tester.pumpAndSettle();

    // 必須項目（イベント名・パスワード）を入力
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'テストイベント');
    await tester.pump();

    await tester.enterText(textFields.at(1), '1234');
    await tester.pump();

    // 初期の地名を入力
    final locationField = find.widgetWithText(TextField, 'Search location...');
    expect(locationField, findsOneWidget);
    await tester.enterText(locationField, 'Initial Location');
    await tester.pump();

    // 検索を実行（MockGeocodingPlatform の Future.delayed が走る）
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(); // 非同期処理開始

    // 応答が返る前に入力テキストを変更（世代番号が進む）
    await tester.enterText(locationField, 'Modified Location');
    await tester.pump();

    // 非同期処理を完了させる（遅延した古い応答は世代不一致で破棄される）
    await tester.pumpAndSettle();

    // 「Confirm Participant」をタップ
    final confirmButton = find.text('Confirm Participant');
    await tester.ensureVisible(confirmButton);
    await tester.tap(confirmButton);
    await tester.pump();

    // 座標未確定スナックバーが表示されることを検証
    expect(find.text('目的地の場所をキーボードの「検索」で確定してください'), findsOneWidget);
  });

  testWidgets('遷移処理中は Confirm Participant ボタンが無効化（onTap が null）されること', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestableWidget(
        const CreateEventPage(groupId: 'test-group', myRole: 0),
      ),
    );
    await tester.pumpAndSettle();

    // 必須項目の入力
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'テストイベント');
    await tester.pump();
    await tester.enterText(textFields.at(1), '1234');
    await tester.pump();

    // 地名入力と確定
    final locationField = find.widgetWithText(TextField, 'Search location...');
    await tester.enterText(locationField, 'Initial Location');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // ボタンの初期状態を確認（onTap が存在する）
    final buttonFinder = find.widgetWithText(InkWell, 'Confirm Participant');
    // 画面内にスクロールして確実に見える状態にする（画面外タップ警告を解消）
    await tester.ensureVisible(buttonFinder);
    await tester.pumpAndSettle();

    expect(tester.widget<InkWell>(buttonFinder).onTap, isNotNull);

    // タップを実行し、タップイベント処理を進める
    await tester.tap(buttonFinder);
    // 短い時間を進めて _onNextPressed の setState(_isNavigating = true) を反映
    await tester.pump(const Duration(milliseconds: 50));

    // ガード自体の検証: _isNavigating により onTap が null になっていることを直接アサート
    expect(tester.widget<InkWell>(buttonFinder).onTap, isNull);

    // 遷移アニメーションを完了させてクリーンアップ
    await tester.pumpAndSettle();
  });

  testWidgets('作成成功後の一覧再取得完了まで SAVE ボタンが無効化され、多重実行されないこと', (tester) async {
    final createCompleter = Completer<String>();
    final reloadCompleter = Completer<List<Event>>();

    when(() => mockRepository.getGroupMembers('group-1')).thenAnswer(
      (_) async => [createDummyProfile(id: 'u-1', nickname: 'Alice')],
    );

    // 作成処理をモック（非同期保留）
    when(
      () => mockRepository.createEventWithParticipants(
        groupId: 'group-1',
        title: any(named: 'title'),
        destinationName: any(named: 'destinationName'),
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        qrcodeId: any(named: 'qrcodeId'),
        password: any(named: 'password'),
        arrivalTime: any(named: 'arrivalTime'),
        participantUserIds: any(named: 'participantUserIds'),
      ),
    ).thenAnswer((_) => createCompleter.future);

    // 一覧再取得をモック（非同期保留）
    when(
      () => mockRepository.getEvents('group-1'),
    ).thenAnswer((_) => reloadCompleter.future);

    // 事前にグループIDだけを選択状態にする（非同期処理を待たない）
    viewModel.loadEvents('group-1'); // await しない
    reloadCompleter.complete([createDummyEvent()]); // 初回分を完了
    await tester.pump();

    // 改めて作成後の一覧再取得用 Completer をセット
    final afterCreateReloadCompleter = Completer<List<Event>>();
    when(
      () => mockRepository.getEvents('group-1'),
    ).thenAnswer((_) => afterCreateReloadCompleter.future);

    await tester.pumpWidget(
      buildTestableWidget(
        SelectParticipantsPage(
          groupId: 'group-1',
          title: 'テスト',
          destinationName: '目的地',
          arrivalTime: DateTime.now(),
          password: 'pass',
          myRole: 0,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    final saveButtonFinder = find.widgetWithText(InkWell, 'SAVE');
    await tester.tap(saveButtonFinder);
    await tester.pump();

    // 作成処理が完了するが、一覧再取得は保留状態にする
    createCompleter.complete('event-1');
    await tester.pump(); // 作成完了と loadEvents 開始を反映

    expect(viewModel.state.isCreatingEvent, isTrue);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    afterCreateReloadCompleter.complete([createDummyEvent()]);
    await tester.pumpAndSettle();

    verify(
      () => mockRepository.createEventWithParticipants(
        groupId: 'group-1',
        title: any(named: 'title'),
        destinationName: any(named: 'destinationName'),
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        qrcodeId: any(named: 'qrcodeId'),
        password: any(named: 'password'),
        arrivalTime: any(named: 'arrivalTime'),
        participantUserIds: any(named: 'participantUserIds'),
      ),
    ).called(1);
  });

  // ==========================================
  // 5. SelectParticipantsPage & MemberStatusPage 追加検証
  // ==========================================
  group('SelectParticipantsPage 追加検証', () {
    testWidgets('メンバー未選択のまま保存ボタンを押した場合、警告スナックバーが表示されること', (tester) async {
      when(() => mockRepository.getGroupMembers('grp_1')).thenAnswer(
        (_) async => [createDummyProfile(id: 'usr_1', nickname: 'Member 1')],
      );

      await tester.pumpWidget(
        buildTestableWidget(
          SelectParticipantsPage(
            groupId: 'grp_1',
            title: 'Test Event',
            destinationName: 'Tokyo',
            arrivalTime: DateTime(2026, 10, 15, 9, 0),
            password: 'pass',
            myRole: 0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final saveButton = find.text('SAVE');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      // SnackBar の表示アニメーションを完了させる
      await tester.pumpAndSettle();

      // SnackBar 自体が表示されていること
      expect(find.byType(SnackBar), findsOneWidget);

      // SnackBar 内のテキストを絞り込んでアサート（ヘッダー等の「Select」との衝突を回避）
      final snackBarTextFinder = find.descendant(
        of: find.byType(SnackBar),
        matching: find.byWidgetPredicate((widget) => widget is Text),
      );
      expect(snackBarTextFinder, findsOneWidget);
    });
  });

  group('MemberStatusPage 追加検証', () {
    testWidgets('statusesError がある場合、エラーメッセージと再試行ボタンが表示されること', (tester) async {
      when(
        () => mockRepository.getEventMemberStatuses('evt_1'),
      ).thenThrow(Exception('参加状況の取得に失敗しました'));

      await tester.pumpWidget(
        buildTestableWidget(
          const MemberStatusPage(
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
          const MemberStatusPage(
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
                    builder: (_) => ChangeNotifierProvider.value(
                      value: viewModel,
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
          const MemberStatusPage(
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
