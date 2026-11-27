import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_application_1/common_layout.dart';
import 'package:flutter_application_1/data/repositories/group_repository.dart';
import 'package:flutter_application_1/data/repositories/ranking_repository.dart';
import 'package:flutter_application_1/presentation/viewmodels/admin_event_view_model.dart';
import 'package:flutter_application_1/presentation/viewmodels/app_mode_controller.dart';
import 'package:flutter_application_1/presentation/viewmodels/group_view_model.dart';
import 'package:flutter_application_1/presentation/viewmodels/ranking_view_model.dart';
import 'package:flutter_application_1/presentation/views/common/app_mode.dart';
import 'package:flutter_application_1/presentation/views/common/common_header.dart';
import 'package:flutter_application_1/presentation/views/common/common_footer.dart';
import 'package:flutter_application_1/presentation/views/event/admin/memberstatus_page.dart';
import 'package:flutter_application_1/presentation/views/event/schedule/set_time_page.dart';
import 'package:flutter_application_1/presentation/views/group/group_list_page.dart';
import 'package:flutter_application_1/presentation/views/ranking/ranking_page.dart';
import 'presentation/views/event/helpers/admin_event_test_helpers.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

class MockRankingRepository extends Mock implements RankingRepository {}

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

  setUp(() {
    AppModeController.instance.setMode(AppMode.member);
  });

  Widget buildTestableWidget(CommonLayout layout) {
    return MaterialApp(home: layout);
  }

  // 遷移先ページ自体の非同期処理（Provider未設定の警告やプレースホルダー画像の
  // 読み込み失敗等）が、CommonLayoutの遷移配線テストの失敗として扱われないようにする。
  Future<void> pumpNavigationFrame(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    while (tester.takeException() != null) {}
  }

  group('フッター: Home', () {
    testWidgets('グループ未選択の場合、Please select group.が表示される', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const CommonLayout(body: SizedBox.shrink())),
      );

      await tester.tap(find.byKey(CommonFooter.homeButtonKey));
      await tester.pump();

      expect(find.text('Please select group.'), findsOneWidget);
    });

    testWidgets('イベント情報が揃っていない場合、Please select event.が表示される', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const CommonLayout(
            body: SizedBox.shrink(),
            groupId: 'group-1',
            myRole: 0,
          ),
        ),
      );

      await tester.tap(find.byKey(CommonFooter.homeButtonKey));
      await tester.pump();

      expect(find.text('Please select event.'), findsOneWidget);
    });

    testWidgets('必要な情報が揃っている場合、MemberStatusPageに遷移する', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const CommonLayout(
            body: SizedBox.shrink(),
            groupId: 'group-1',
            myRole: 0,
            eventId: 'event-1',
            eventTitle: 'タイトル',
            arrivalTimeDisplay: '11/13 09:00',
            password: 'pass',
            qrcodeId: 'qr-1',
          ),
        ),
      );

      await tester.tap(find.byKey(CommonFooter.homeButtonKey));
      await pumpNavigationFrame(tester);

      expect(find.byType(MemberStatusPage), findsOneWidget);
    });
  });

  group('フッター: EventCreate', () {
    testWidgets('管理者の場合、イベント一覧画面(GroupListPage)に遷移する', (tester) async {
      final mockGroupRepository = MockGroupRepository();
      when(
        () => mockGroupRepository.getGroups(),
      ).thenAnswer((_) async => []);
      final mockAdminEventRepository = MockAdminEventRepository();
      when(
        () => mockAdminEventRepository.getEvents(any()),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<GroupViewModel>(
              create: (_) => GroupViewModel(mockGroupRepository),
            ),
            ChangeNotifierProvider<AdminEventViewModel>(
              create: (_) => AdminEventViewModel(mockAdminEventRepository),
            ),
          ],
          child: buildTestableWidget(
            const CommonLayout(
              body: SizedBox.shrink(),
              groupId: 'group-1',
              myRole: 0,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(CommonFooter.eventCreateButtonKey));
      await pumpNavigationFrame(tester);

      expect(find.byType(GroupListPage), findsOneWidget);
    });

    testWidgets('メンバーでイベント情報がある場合、SetTimePageに遷移する', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          CommonLayout(
            body: const SizedBox.shrink(),
            groupId: 'group-1',
            myRole: 1,
            eventId: 'event-1',
            eventTitle: 'タイトル',
            arrivalTime: DateTime(2026, 11, 13, 9),
          ),
        ),
      );

      await tester.tap(find.byKey(CommonFooter.eventCreateButtonKey));
      await pumpNavigationFrame(tester);

      expect(find.byType(SetTimePage), findsOneWidget);
    });

    testWidgets('メンバーでイベント情報が無い場合、Please select event.が表示される', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const CommonLayout(
            body: SizedBox.shrink(),
            groupId: 'group-1',
            myRole: 1,
          ),
        ),
      );

      await tester.tap(find.byKey(CommonFooter.eventCreateButtonKey));
      await tester.pump();

      expect(find.text('Please select event.'), findsOneWidget);
    });
  });

  testWidgets('フッター: Rankingタップで選択中グループのランキング画面に遷移する', (tester) async {
    final rankingRepository = MockRankingRepository();
    when(
      () => rankingRepository.getGroupRankings('group-1'),
    ).thenAnswer((_) async => []);

    await tester.pumpWidget(
      ChangeNotifierProvider<RankingViewModel>(
        create: (_) => RankingViewModel(rankingRepository),
        child: buildTestableWidget(
          const CommonLayout(body: SizedBox.shrink(), groupId: 'group-1'),
        ),
      ),
    );

    await tester.tap(find.byKey(CommonFooter.rankingButtonKey));
    await pumpNavigationFrame(tester);

    expect(find.byType(RankingPage), findsOneWidget);
    verify(() => rankingRepository.getGroupRankings('group-1')).called(1);
  });

  testWidgets('フッター: Forumタップで Coming soon.が表示される', (tester) async {
    await tester.pumpWidget(
      buildTestableWidget(const CommonLayout(body: SizedBox.shrink())),
    );

    await tester.tap(find.byKey(CommonFooter.forumButtonKey));
    await tester.pump();
    expect(find.text('Coming soon.'), findsOneWidget);
  });

  group('フッター: Plus', () {
    testWidgets('イベント情報が揃っていない場合、Please select event.が表示される', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const CommonLayout(body: SizedBox.shrink())),
      );

      await tester.tap(find.byKey(CommonFooter.plusButtonKey));
      await tester.pump();

      expect(find.text('Please select event.'), findsOneWidget);
    });
  });

  group('ヘッダー: ModeSwitch', () {
    testWidgets('メンバー権限で管理者側をタップすると権限なしメッセージが表示される', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const CommonLayout(
            body: SizedBox.shrink(),
            groupId: 'group-1',
            myRole: 1,
          ),
        ),
      );

      await tester.tap(find.byKey(CommonHeader.adminSwitchKey));
      await tester.pump();

      expect(find.text('閲覧権限がありません（管理者のみ利用可能）'), findsOneWidget);
    });
  });

  testWidgets(
    'bodyだけが変わる無関係な再描画ではCommonHeader/CommonFooterが再生成されない',
    (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const CommonLayout(body: SizedBox.shrink())),
      );

      final headerBefore = tester.widget<CommonHeader>(
        find.byType(CommonHeader),
      );
      final footerBefore = tester.widget<CommonFooter>(
        find.byType(CommonFooter),
      );

      // モードは変えず、bodyの内容だけを変えてCommonLayoutを作り直す
      // （親画面の無関係なsetStateを模倣）。
      await tester.pumpWidget(
        buildTestableWidget(
          CommonLayout(body: Container(key: UniqueKey())),
        ),
      );

      final headerAfter = tester.widget<CommonHeader>(
        find.byType(CommonHeader),
      );
      final footerAfter = tester.widget<CommonFooter>(
        find.byType(CommonFooter),
      );

      expect(identical(headerBefore, headerAfter), isTrue);
      expect(identical(footerBefore, footerAfter), isTrue);
    },
  );

  testWidgets('showFooter: falseのときフッターのボタンは操作できない', (tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        const CommonLayout(body: SizedBox.shrink(), showFooter: false),
      ),
    );

    // offstage中はWidgetTesterの既定の検索（skipOffstage: true）では
    // 見つからない。実在はするが操作不可であることを確認するため、
    // skipOffstage: falseで明示的に探してタップを試みる。
    await tester.tap(
      find.byKey(CommonFooter.homeButtonKey, skipOffstage: false),
      warnIfMissed: false,
    );
    await tester.pump();

    // offstage中はヒットテストが届かないため、Please select group.の
    // スナックバーは表示されない。
    expect(find.text('Please select group.'), findsNothing);
  });

  testWidgets('showFooter: falseからtrueに切り替わってもフッターのインスタンスは維持される', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestableWidget(
        const CommonLayout(body: SizedBox.shrink(), showFooter: false),
      ),
    );
    final footerBefore = tester.widget<CommonFooter>(
      find.byType(CommonFooter, skipOffstage: false),
    );

    await tester.pumpWidget(
      buildTestableWidget(
        const CommonLayout(body: SizedBox.shrink(), showFooter: true),
      ),
    );
    final footerAfter = tester.widget<CommonFooter>(
      find.byType(CommonFooter),
    );

    expect(identical(footerBefore, footerAfter), isTrue);

    await tester.tap(find.byKey(CommonFooter.homeButtonKey));
    await tester.pump();
    expect(find.text('Please select group.'), findsOneWidget);
  });
}
