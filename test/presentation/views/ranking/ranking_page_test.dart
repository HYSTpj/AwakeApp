import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_application_1/data/repositories/ranking_repository.dart';
import 'package:flutter_application_1/models/ranking_user.dart';
import 'package:flutter_application_1/presentation/viewmodels/ranking_view_model.dart';
import 'package:flutter_application_1/presentation/views/ranking/ranking_page.dart';

class MockRankingRepository extends Mock implements RankingRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockRankingRepository repository;

  setUpAll(() async {
    const channel = MethodChannel('plugins.flutter.io/shared_preferences');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getAll') return <String, dynamic>{};
          return true;
        });

    await Supabase.initialize(
      url: 'https://dummy.supabase.co',
      publishableKey: 'dummy-anon-key-for-widget-testing',
    );
  });

  setUp(() {
    repository = MockRankingRepository();
  });

  testWidgets('renders group ranking metrics from repository data', (
    tester,
  ) async {
    when(() => repository.getGroupRankings('group-001')).thenAnswer(
      (_) async => [
        const RankingUser(
          id: 'user-001',
          nickname: 'Late Champion',
          streak: 3,
          totalDelayMinutes: 125,
          avgDelayMinutes: 42,
        ),
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => RankingViewModel(repository),
        child: const MaterialApp(home: RankingPage(groupId: 'group-001')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Late Champion'), findsOneWidget);
    expect(find.text('3 EVENTS'), findsOneWidget);
    expect(find.text('2H 5M'), findsOneWidget);
    expect(find.text('42 MIN'), findsOneWidget);
  });

  testWidgets('shows an empty state when the group has no ranking members', (
    tester,
  ) async {
    when(
      () => repository.getGroupRankings('group-001'),
    ).thenAnswer((_) async => []);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => RankingViewModel(repository),
        child: const MaterialApp(home: RankingPage(groupId: 'group-001')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ランキングデータがありません。'), findsOneWidget);
  });
}
