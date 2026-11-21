import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_application_1/data/repositories/group_repository.dart';
import 'package:flutter_application_1/presentation/viewmodels/admin_event_view_model.dart';
import 'package:flutter_application_1/presentation/viewmodels/group_view_model.dart';
import 'package:flutter_application_1/presentation/views/group/group_list_page.dart';
import '../event/helpers/admin_event_test_helpers.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

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

  // ログイン直後（グループ・イベントともに未選択）の再現:
  // DropdownButtonのitems/selectedItemBuilderの不整合によるアサーション
  // クラッシュが再発しないことを確認する回帰テスト。
  testWidgets('ログイン直後（グループ0件）でクラッシュせず、グループ選択を促す表示になる', (
    tester,
  ) async {
    final mockGroupRepository = MockGroupRepository();
    when(() => mockGroupRepository.getGroups()).thenAnswer((_) async => []);
    final mockAdminEventRepository = MockAdminEventRepository();
    when(
      () => mockAdminEventRepository.getEvents(any()),
    ).thenAnswer((_) async => []);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<GroupRepository>.value(value: mockGroupRepository),
          ChangeNotifierProvider<GroupViewModel>(
            create: (_) => GroupViewModel(mockGroupRepository),
          ),
          ChangeNotifierProvider<AdminEventViewModel>(
            create: (_) => AdminEventViewModel(mockAdminEventRepository),
          ),
        ],
        child: const MaterialApp(home: GroupListPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('グループを選択してください'), findsOneWidget);
  });
}
