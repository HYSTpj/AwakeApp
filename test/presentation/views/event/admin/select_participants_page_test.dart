import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/models/profile.dart';
import 'package:flutter_application_1/presentation/viewmodels/auth_view_model.dart';
import 'package:flutter_application_1/presentation/viewmodels/admin_event_view_model.dart';
import 'package:flutter_application_1/presentation/views/event/admin/select_participants_page.dart';
import '../helpers/admin_event_test_helpers.dart';

void main() {
  setupTestEnvironment();

  late MockAdminEventRepository mockRepository;
  late AdminEventViewModel viewModel;

  setUp(() {
    mockRepository = MockAdminEventRepository();
    viewModel = AdminEventViewModel(mockRepository);
  });

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
          viewModel: viewModel,
          child: SelectParticipantsPage(
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
          viewModel: viewModel,
          child: SelectParticipantsPage(
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
          viewModel: viewModel,
          child: SelectParticipantsPage(
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
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AdminEventViewModel>.value(value: viewModel),
            ChangeNotifierProvider<AuthViewModel>.value(
              value: createMockAuthViewModel(),
            ),
          ],
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

    testWidgets('作成成功後の一覧再取得完了まで SAVE ボタンが無効化され、多重実行されないこと', (tester) async {
      final createCompleter = Completer<String>();
      final reloadCompleter = Completer<List<Event>>();

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
      ).thenAnswer((_) => createCompleter.future);

      when(
        () => mockRepository.getEvents('group-1'),
      ).thenAnswer((_) => reloadCompleter.future);

      viewModel.loadEvents('group-1');
      reloadCompleter.complete([createDummyEvent()]);
      await tester.pump();

      final afterCreateReloadCompleter = Completer<List<Event>>();
      when(
        () => mockRepository.getEvents('group-1'),
      ).thenAnswer((_) => afterCreateReloadCompleter.future);

      await tester.pumpWidget(
        buildTestableWidget(
          viewModel: viewModel,
          child: SelectParticipantsPage(
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

      createCompleter.complete('event-1');
      await tester.pump();

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

    testWidgets('メンバー未選択のまま保存ボタンを押した場合、警告スナックバーが表示されること', (tester) async {
      when(() => mockRepository.getGroupMembers('grp_1')).thenAnswer(
        (_) async => [createDummyProfile(id: 'usr_1', nickname: 'Member 1')],
      );

      await tester.pumpWidget(
        buildTestableWidget(
          viewModel: viewModel,
          child: SelectParticipantsPage(
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
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);

      final snackBarTextFinder = find.descendant(
        of: find.byType(SnackBar),
        matching: find.byWidgetPredicate((widget) => widget is Text),
      );
      expect(snackBarTextFinder, findsOneWidget);
    });
  });
}
