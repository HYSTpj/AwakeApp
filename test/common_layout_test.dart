import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_application_1/common_layout.dart';
import 'package:flutter_application_1/presentation/views/common/common_header.dart';
import 'package:flutter_application_1/presentation/views/common/common_footer.dart';
import 'package:flutter_application_1/presentation/views/event/admin/memberstatus_page.dart';
import 'package:flutter_application_1/presentation/views/event/admin/create_event_page.dart';
import 'package:flutter_application_1/presentation/views/event/schedule/set_time_page.dart';
import 'package:flutter_application_1/presentation/views/ranking/ranking_page.dart';

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
    testWidgets('管理者の場合、CreateEventPageに遷移する', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const CommonLayout(
            body: SizedBox.shrink(),
            groupId: 'group-1',
            myRole: 0,
          ),
        ),
      );

      await tester.tap(find.byKey(CommonFooter.eventCreateButtonKey));
      await pumpNavigationFrame(tester);

      expect(find.byType(CreateEventPage), findsOneWidget);
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

  testWidgets('フッター: Rankingタップで RankingPreview に遷移する', (tester) async {
    await tester.pumpWidget(
      buildTestableWidget(const CommonLayout(body: SizedBox.shrink())),
    );

    await tester.tap(find.byKey(CommonFooter.rankingButtonKey));
    await pumpNavigationFrame(tester);

    expect(find.byType(RankingPreview), findsOneWidget);
  });

  testWidgets('フッター: Forum/Plusタップで Coming soon.が表示される', (tester) async {
    await tester.pumpWidget(
      buildTestableWidget(const CommonLayout(body: SizedBox.shrink())),
    );

    await tester.tap(find.byKey(CommonFooter.forumButtonKey));
    await tester.pump();
    expect(find.text('Coming soon.'), findsOneWidget);

    await tester.tap(find.byKey(CommonFooter.plusButtonKey));
    await tester.pump();
    expect(find.text('Coming soon.'), findsOneWidget);
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
}
