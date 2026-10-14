import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_application_1/data/repositories/admin_event_repository.dart';
import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/models/event_member_status.dart';
import 'package:flutter_application_1/models/event_report.dart';
import 'package:flutter_application_1/models/profile.dart';
import 'package:flutter_application_1/presentation/viewmodels/admin_event_view_model.dart';

class MockAdminEventRepository extends Mock implements AdminEventRepository {}

void main() {
  late MockAdminEventRepository mockRepository;
  late AdminEventViewModel viewModel;

  setUp(() {
    mockRepository = MockAdminEventRepository();
    viewModel = AdminEventViewModel(mockRepository);
  });

  Event createDummyEvent(String id, String groupId, String title) {
    return Event(
      id: id,
      groupId: groupId,
      title: title,
      destinationName: 'Tokyo',
      qrcodeId: 'qr',
      password: 'pass',
      arrivalTime: DateTime(2026, 10, 20),
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Profile createDummyProfile(String id, String nickname) {
    return Profile(
      id: id,
      nickname: nickname,
      avatarUrl: null,
      sleepPastCount: 0,
      lateCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  group('世代カウンター & 画面切り替え時の破棄テスト', () {
    test('別グループ切り替え時、遅れて完了した旧グループのイベント取得結果が破棄されること', () async {
      final cOld = Completer<List<Event>>();
      final cNew = Completer<List<Event>>();

      when(() => mockRepository.getEvents('grp_old'))
          .thenAnswer((_) => cOld.future);
      when(() => mockRepository.getEvents('grp_new'))
          .thenAnswer((_) => cNew.future);

      final fOld = viewModel.loadEvents('grp_old');
      final fNew = viewModel.loadEvents('grp_new');

      cNew.complete([createDummyEvent('evt_new', 'grp_new', 'New Group Event')]);
      await fNew;

      cOld.complete([createDummyEvent('evt_old', 'grp_old', 'Old Group Event')]);
      await fOld;

      expect(viewModel.state.selectedGroupId, 'grp_new');
      expect(viewModel.state.events.length, 1);
      expect(viewModel.state.events.first.id, 'evt_new');
    });

    test('別グループ切り替え時、遅れて完了した旧グループのメンバー取得結果が破棄されること', () async {
      final cOld = Completer<List<Profile>>();
      final cNew = Completer<List<Profile>>();

      when(() => mockRepository.getGroupMembers('grp_old'))
          .thenAnswer((_) => cOld.future);
      when(() => mockRepository.getGroupMembers('grp_new'))
          .thenAnswer((_) => cNew.future);

      final fOld = viewModel.loadGroupMembers('grp_old');
      final fNew = viewModel.loadGroupMembers('grp_new');

      cNew.complete([createDummyProfile('usr_new', 'New Member')]);
      await fNew;

      cOld.complete([createDummyProfile('usr_old', 'Old Member')]);
      await fOld;

      expect(viewModel.state.selectedMembersGroupId, 'grp_new');
      expect(viewModel.state.groupMembers.first.id, 'usr_new');
    });

    test('同一 groupId に対する連続 loadEvents で、遅れた第1リクエストが結果を上書きしないこと', () async {
      final c1 = Completer<List<Event>>();
      final c2 = Completer<List<Event>>();

      when(() => mockRepository.getEvents('grp_1'))
          .thenAnswer((_) => c1.future);

      final f1 = viewModel.loadEvents('grp_1');

      when(() => mockRepository.getEvents('grp_1'))
          .thenAnswer((_) => c2.future);

      final f2 = viewModel.loadEvents('grp_1');

      c2.complete([createDummyEvent('evt_latest', 'grp_1', 'Latest Event')]);
      await f2;

      c1.complete([createDummyEvent('evt_stale', 'grp_1', 'Stale Event')]);
      await f1;

      expect(viewModel.state.events.first.id, 'evt_latest');
    });

    test('別イベント切り替え時、遅れて完了した旧イベントの参加状況一覧が破棄されること', () async {
      final cOld = Completer<List<EventMemberStatus>>();
      final cNew = Completer<List<EventMemberStatus>>();

      when(() => mockRepository.getEventMemberStatuses('evt_old'))
          .thenAnswer((_) => cOld.future);
      when(() => mockRepository.getEventMemberStatuses('evt_new'))
          .thenAnswer((_) => cNew.future);

      final fOld = viewModel.loadEventMemberStatuses('evt_old');
      final fNew = viewModel.loadEventMemberStatuses('evt_new');

      cNew.complete([
        EventMemberStatus(
          profile: createDummyProfile('u_new', 'New User'),
          report: null,
        )
      ]);
      await fNew;

      cOld.complete([
        EventMemberStatus(
          profile: createDummyProfile('u_old', 'Old User'),
          report: null,
        )
      ]);
      await fOld;

      expect(viewModel.state.selectedEventId, 'evt_new');
      expect(viewModel.state.memberStatuses.first.profile.id, 'u_new');
    });

    test('個別レポート取得時、別ユーザーに切り替えた場合は遅れた旧レポートが破棄されること', () async {
      final cOld = Completer<EventReport?>();
      final cNew = Completer<EventReport?>();

      when(() => mockRepository.getMemberReport(eventId: 'evt_1', userId: 'usr_old'))
          .thenAnswer((_) => cOld.future);
      when(() => mockRepository.getMemberReport(eventId: 'evt_1', userId: 'usr_new'))
          .thenAnswer((_) => cNew.future);

      final fOld = viewModel.loadMemberReport(eventId: 'evt_1', userId: 'usr_old');
      final fNew = viewModel.loadMemberReport(eventId: 'evt_1', userId: 'usr_new');

      final newReport = EventReport(
        id: 'rep_new',
        eventId: 'evt_1',
        userId: 'usr_new',
        status: 4,
        updatedAt: DateTime.now(),
      );
      cNew.complete(newReport);
      await fNew;

      final oldReport = EventReport(
        id: 'rep_old',
        eventId: 'evt_1',
        userId: 'usr_old',
        status: 2,
        updatedAt: DateTime.now(),
      );
      cOld.complete(oldReport);
      await fOld;

      expect(viewModel.state.selectedReportUserId, 'usr_new');
      expect(viewModel.state.selectedMemberReport?.id, 'rep_new');
    });

    test('同一 groupId に対する連続 loadGroupMembers で、遅れた第1リクエストが結果を上書きしないこと', () async {
      final c1 = Completer<List<Profile>>();
      final c2 = Completer<List<Profile>>();

      when(() => mockRepository.getGroupMembers('grp_1'))
          .thenAnswer((_) => c1.future);

      final f1 = viewModel.loadGroupMembers('grp_1');

      when(() => mockRepository.getGroupMembers('grp_1'))
          .thenAnswer((_) => c2.future);

      final f2 = viewModel.loadGroupMembers('grp_1');

      // 第2リクエスト（最新）が先に完了
      c2.complete([createDummyProfile('usr_latest', 'Latest Member')]);
      await f2;

      // 遅れて第1リクエストが完了
      c1.complete([createDummyProfile('usr_stale', 'Stale Member')]);
      await f1;

      // 最新のメンバー一覧が維持されていることを検証
      expect(viewModel.state.groupMembers.first.id, 'usr_latest');
      expect(viewModel.state.groupMembers.first.nickname, 'Latest Member');
    });
  });

  group('異常系・エラー分離 & ローディング解除テスト', () {
    test('loadEvents 失敗時に eventsError が設定され isLoadingEvents が false に戻ること', () async {
      when(() => mockRepository.getEvents('grp_1'))
          .thenThrow(Exception('Events network error'));

      await viewModel.loadEvents('grp_1');

      expect(viewModel.state.eventsError, contains('Events network error'));
      expect(viewModel.state.isLoadingEvents, isFalse);
      expect(viewModel.state.membersError, isNull);
    });

    test('loadGroupMembers 失敗時に membersError が設定され isLoadingMembers が false に戻ること', () async {
      when(() => mockRepository.getGroupMembers('grp_1'))
          .thenThrow(Exception('Members fetch error'));

      await viewModel.loadGroupMembers('grp_1');

      expect(viewModel.state.membersError, contains('Members fetch error'));
      expect(viewModel.state.isLoadingMembers, isFalse);
      expect(viewModel.state.eventsError, isNull);
    });

    test('loadEventMemberStatuses 失敗時に statusesError が設定され isLoadingStatuses が false に戻ること', () async {
      when(() => mockRepository.getEventMemberStatuses('evt_1'))
          .thenThrow(Exception('Statuses fetch error'));

      await viewModel.loadEventMemberStatuses('evt_1');

      expect(viewModel.state.statusesError, contains('Statuses fetch error'));
      expect(viewModel.state.isLoadingStatuses, isFalse);
      expect(viewModel.state.eventsError, isNull);
      expect(viewModel.state.membersError, isNull);
    });

    test('loadMemberReport 失敗時に memberReportError が設定され isLoadingMemberReport が false に戻ること', () async {
      when(() => mockRepository.getMemberReport(eventId: 'evt_1', userId: 'u1'))
          .thenThrow(Exception('Report fetch error'));

      await viewModel.loadMemberReport(eventId: 'evt_1', userId: 'u1');

      expect(viewModel.state.memberReportError, contains('Report fetch error'));
      expect(viewModel.state.isLoadingMemberReport, isFalse);
    });

    test('createEventWithParticipants 失敗時に createEventError が設定され isCreatingEvent が false にリセットされること', () async {
      when(() => mockRepository.createEventWithParticipants(
            groupId: 'grp_1',
            title: 'Event',
            destinationName: 'Tokyo',
            latitude: null,
            longitude: null,
            qrcodeId: 'qr',
            password: 'pass',
            arrivalTime: any(named: 'arrivalTime'),
            participantUserIds: ['u1'],
          )).thenThrow(Exception('Create event RPC error'));

      final result = await viewModel.createEventWithParticipants(
        groupId: 'grp_1',
        title: 'Event',
        destinationName: 'Tokyo',
        latitude: null,
        longitude: null,
        qrcodeId: 'qr',
        password: 'pass',
        arrivalTime: DateTime.now(),
        participantUserIds: ['u1'],
      );

      expect(result, isNull);
      expect(viewModel.state.isCreatingEvent, isFalse);
      expect(viewModel.state.createEventError, contains('Create event RPC error'));
    });
  });

  group('全4系統のローディング状態の独立性テスト', () {
    test('イベント・メンバー・状況一覧・個別レポートの全ローディングフラグが独立して動作すること', () async {
      final cEvents = Completer<List<Event>>();
      final cMembers = Completer<List<Profile>>();
      final cStatuses = Completer<List<EventMemberStatus>>();
      final cReport = Completer<EventReport?>();

      when(() => mockRepository.getEvents('grp_1')).thenAnswer((_) => cEvents.future);
      when(() => mockRepository.getGroupMembers('grp_1')).thenAnswer((_) => cMembers.future);
      when(() => mockRepository.getEventMemberStatuses('evt_1')).thenAnswer((_) => cStatuses.future);
      when(() => mockRepository.getMemberReport(eventId: 'evt_1', userId: 'u1')).thenAnswer((_) => cReport.future);

      final fEvents = viewModel.loadEvents('grp_1');
      final fMembers = viewModel.loadGroupMembers('grp_1');
      final fStatuses = viewModel.loadEventMemberStatuses('evt_1');
      final fReport = viewModel.loadMemberReport(eventId: 'evt_1', userId: 'u1');

      expect(viewModel.state.isLoadingEvents, isTrue);
      expect(viewModel.state.isLoadingMembers, isTrue);
      expect(viewModel.state.isLoadingStatuses, isTrue);
      expect(viewModel.state.isLoadingMemberReport, isTrue);

      cMembers.complete([]);
      await fMembers;
      expect(viewModel.state.isLoadingMembers, isFalse);
      expect(viewModel.state.isLoadingEvents, isTrue);
      expect(viewModel.state.isLoadingStatuses, isTrue);
      expect(viewModel.state.isLoadingMemberReport, isTrue);

      cReport.complete(null);
      await fReport;
      expect(viewModel.state.isLoadingMemberReport, isFalse);
      expect(viewModel.state.isLoadingEvents, isTrue);
      expect(viewModel.state.isLoadingStatuses, isTrue);

      cEvents.complete([]);
      await fEvents;
      expect(viewModel.state.isLoadingEvents, isFalse);
      expect(viewModel.state.isLoadingStatuses, isTrue);

      cStatuses.complete([]);
      await fStatuses;
      expect(viewModel.state.isLoadingStatuses, isFalse);
    });
  });

  group('二重送信防止 & 逆流防止テスト', () {
    test('isCreatingEvent 中の多重呼び出しは即座にガードされ null を返すこと', () async {
      final c = Completer<String>();

      when(() => mockRepository.createEventWithParticipants(
            groupId: 'grp_1',
            title: 'Event',
            destinationName: 'Tokyo',
            latitude: null,
            longitude: null,
            qrcodeId: 'qr',
            password: 'pass',
            arrivalTime: any(named: 'arrivalTime'),
            participantUserIds: ['u1'],
          )).thenAnswer((_) => c.future);

      final f1 = viewModel.createEventWithParticipants(
        groupId: 'grp_1',
        title: 'Event',
        destinationName: 'Tokyo',
        latitude: null,
        longitude: null,
        qrcodeId: 'qr',
        password: 'pass',
        arrivalTime: DateTime.now(),
        participantUserIds: ['u1'],
      );

      expect(viewModel.state.isCreatingEvent, isTrue);

      final f2Result = await viewModel.createEventWithParticipants(
        groupId: 'grp_1',
        title: 'Event',
        destinationName: 'Tokyo',
        latitude: null,
        longitude: null,
        qrcodeId: 'qr',
        password: 'pass',
        arrivalTime: DateTime.now(),
        participantUserIds: ['u1'],
      );

      expect(f2Result, isNull);
      c.complete('evt_created');
      await f1;
      expect(viewModel.state.isCreatingEvent, isFalse);
    });

    test('同一グループでも作成中に一覧世代が進んでいた場合は再取得をスキップすること', () async {
      final cCreate = Completer<String>();

      when(() => mockRepository.getEvents('grp_1')).thenAnswer((_) async => []);
      when(() => mockRepository.createEventWithParticipants(
            groupId: 'grp_1',
            title: 'Event',
            destinationName: 'Tokyo',
            latitude: null,
            longitude: null,
            qrcodeId: 'qr',
            password: 'pass',
            arrivalTime: any(named: 'arrivalTime'),
            participantUserIds: ['u1'],
          )).thenAnswer((_) => cCreate.future);

      await viewModel.loadEvents('grp_1');
      clearInteractions(mockRepository);

      final fCreate = viewModel.createEventWithParticipants(
        groupId: 'grp_1',
        title: 'Event',
        destinationName: 'Tokyo',
        latitude: null,
        longitude: null,
        qrcodeId: 'qr',
        password: 'pass',
        arrivalTime: DateTime.now(),
        participantUserIds: ['u1'],
      );

      await viewModel.loadEvents('grp_1');
      clearInteractions(mockRepository);

      cCreate.complete('evt_1');
      await fCreate;

      verifyNever(() => mockRepository.getEvents('grp_1'));
    });

    test('作成処理中に別グループへ切り替わった場合、作成完了後の旧グループ一覧再取得がスキップされること', () async {
      final cCreate = Completer<String>();

      when(() => mockRepository.getEvents('grp_1')).thenAnswer((_) async => []);
      when(() => mockRepository.getEvents('grp_2')).thenAnswer((_) async => []);
      when(() => mockRepository.createEventWithParticipants(
            groupId: 'grp_1',
            title: 'Event',
            destinationName: 'Tokyo',
            latitude: null,
            longitude: null,
            qrcodeId: 'qr',
            password: 'pass',
            arrivalTime: any(named: 'arrivalTime'),
            participantUserIds: ['u1'],
          )).thenAnswer((_) => cCreate.future);

      // grp_1 で初期一覧を取得
      await viewModel.loadEvents('grp_1');
      clearInteractions(mockRepository);

      // grp_1 でイベント作成を開始（非同期保留）
      final fCreate = viewModel.createEventWithParticipants(
        groupId: 'grp_1',
        title: 'Event',
        destinationName: 'Tokyo',
        latitude: null,
        longitude: null,
        qrcodeId: 'qr',
        password: 'pass',
        arrivalTime: DateTime.now(),
        participantUserIds: ['u1'],
      );

      // 作成処理が完了する前に別グループ grp_2 へ画面・状態を切り替える
      await viewModel.loadEvents('grp_2');
      clearInteractions(mockRepository);

      // 作成処理が完了
      cCreate.complete('evt_created_1');
      await fCreate;

      // grp_1 の一覧再取得はスキップされ、呼ばれていないことを検証
      verifyNever(() => mockRepository.getEvents('grp_1'));
      expect(viewModel.state.selectedGroupId, 'grp_2');
    });
  });

  test('同一 userId で別イベントのレポート取得に切り替えた場合、遅れて完了した旧イベントのレポートが破棄されること', () async {
      final cOld = Completer<EventReport?>();
      final cNew = Completer<EventReport?>();

      when(() => mockRepository.getMemberReport(eventId: 'evt_old', userId: 'u_same'))
          .thenAnswer((_) => cOld.future);
      when(() => mockRepository.getMemberReport(eventId: 'evt_new', userId: 'u_same'))
          .thenAnswer((_) => cNew.future);

      final fOld = viewModel.loadMemberReport(eventId: 'evt_old', userId: 'u_same');
      final fNew = viewModel.loadMemberReport(eventId: 'evt_new', userId: 'u_same');

      final newReport = EventReport(
        id: 'rep_new',
        eventId: 'evt_new',
        userId: 'u_same',
        status: 4,
        updatedAt: DateTime.now(),
      );
      cNew.complete(newReport);
      await fNew;

      final oldReport = EventReport(
        id: 'rep_old',
        eventId: 'evt_old',
        userId: 'u_same',
        status: 2,
        updatedAt: DateTime.now(),
      );
      cOld.complete(oldReport);
      await fOld;

      // selectedReportEventId も含めて新しいイベント側のレポートが保持されていることを検証
      expect(viewModel.state.selectedReportEventId, 'evt_new');
      expect(viewModel.state.selectedReportUserId, 'u_same');
      expect(viewModel.state.selectedMemberReport?.id, 'rep_new');
      expect(viewModel.state.selectedMemberReport?.eventId, 'evt_new');
    });
}