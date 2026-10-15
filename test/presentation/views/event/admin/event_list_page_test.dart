import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/presentation/viewmodels/admin_event_view_model.dart';
import 'package:flutter_application_1/presentation/views/event/admin/event_list_page.dart';
import '../helpers/admin_event_test_helpers.dart';

void main() {
  setupTestEnvironment();

  late MockAdminEventRepository mockRepository;
  late AdminEventViewModel viewModel;

  setUp(() {
    mockRepository = MockAdminEventRepository();
    viewModel = AdminEventViewModel(mockRepository);
  });

  group('EventListPage Widget Tests', () {
    testWidgets('管理者(myRole == 0)の場合、Add Eventsボタンとイベント一覧が表示される', (
      tester,
    ) async {
      when(
        () => mockRepository.getEvents('group-1'),
      ).thenAnswer((_) async => [createDummyEvent()]);
      await tester.pumpWidget(
        buildTestableWidget(
          viewModel: viewModel,
          child: const EventListPage(groupId: 'group-1', myRole: 0),
        ),
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
        buildTestableWidget(
          viewModel: viewModel,
          child: const EventListPage(groupId: 'group-1', myRole: 1),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add Events'), findsNothing);
      expect(find.text('合宿集合'), findsOneWidget);
    });

    testWidgets('イベントが0件の場合、インジケータが消え空状態メッセージが表示される', (
      tester,
    ) async {
      when(
        () => mockRepository.getEvents('group-1'),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        buildTestableWidget(
          viewModel: viewModel,
          child: const EventListPage(groupId: 'group-1', myRole: 0),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('イベント取得エラー'), findsNothing);
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

      verifyNever(() => mockRepository.getEvents('group-1'));
    });

    testWidgets('取得エラー発生時はエラーメッセージが表示される', (tester) async {
      when(
        () => mockRepository.getEvents('group-1'),
      ).thenThrow(Exception('通信エラー'));
      await tester.pumpWidget(
        buildTestableWidget(
          viewModel: viewModel,
          child: const EventListPage(groupId: 'group-1', myRole: 0),
        ),
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
        buildTestableWidget(
          viewModel: viewModel,
          child: const EventListPage(groupId: 'group-2', myRole: 0),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('古いグループのイベント'), findsNothing);

      completer.complete([]);
      await tester.pump();
    });
  });
}
