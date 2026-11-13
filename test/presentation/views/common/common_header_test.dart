import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_application_1/presentation/views/common/app_mode.dart';
import 'package:flutter_application_1/presentation/views/common/common_header.dart';

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

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('AWAKEのタイトルが表示される', (tester) async {
    await tester.pumpWidget(
      buildTestableWidget(const CommonHeader(mode: AppMode.admin)),
    );

    expect(find.text('AWAKE'), findsOneWidget);
  });

  testWidgets('プロフィールボタンをタップするとコールバックが呼ばれる', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      buildTestableWidget(
        CommonHeader(
          mode: AppMode.member,
          onProfileTap: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.byKey(CommonHeader.profileButtonKey));
    expect(tapped, isTrue);
  });

  testWidgets('ModeSwitchをタップするとモード変更コールバックが呼ばれる', (tester) async {
    AppMode? selected;
    await tester.pumpWidget(
      buildTestableWidget(
        CommonHeader(
          mode: AppMode.admin,
          onModeChanged: (mode) => selected = mode,
        ),
      ),
    );

    await tester.tap(find.byKey(CommonHeader.memberSwitchKey));
    expect(selected, AppMode.member);
  });
}
