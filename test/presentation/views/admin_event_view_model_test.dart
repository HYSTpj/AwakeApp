import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_application_1/data/repositories/admin_event_repository.dart';
import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/models/profile.dart';
import 'package:flutter_application_1/presentation/views/admin_event_view_model.dart';

class MockAdminEventRepository extends Mock implements AdminEventRepository {}

void main() {
  late MockAdminEventRepository mockRepository;
  late AdminEventViewModel viewModel;

  final testEvent = Event(
    id: 'event-uuid-001',
    groupId: 'group-uuid-001',
    title: '名古屋集合テスト',
    destinationName: '名古屋駅 金時計前',
    latitude: 35.170915,
    longitude: 136.881537,
    qrcodeId: 'QR-TEST-001',
    password: 'pass',
    arrivalTime: DateTime.parse('2026-09-25T09:00:00Z'),
    status: 'active',
    createdAt: DateTime.parse('2026-09-21T10:00:00Z'),
    updatedAt: DateTime.parse('2026-09-21T10:00:00Z'),
  );

  final testMember = Profile(
    id: 'user-001',
    nickname: 'MemberA',
    avatarUrl: null,
    sleepPastCount: 0,
    lateCount: 0,
    createdAt: DateTime.parse('2026-09-20T00:00:00Z'),
    updatedAt: DateTime.parse('2026-09-20T00:00:00Z'),
  );

  setUp(() {
    mockRepository = MockAdminEventRepository();
    viewModel = AdminEventViewModel(mockRepository);
  });

  group('AdminEventViewModel - イベント一覧読み込みテスト', () {
    test('loadEvents 成功時: events リストが保持されること', () async {
      when(() => mockRepository.getEvents('group-uuid-001'))
          .thenAnswer((_) async => [testEvent]);

      await viewModel.loadEvents('group-uuid-001');

      expect(viewModel.state.events.length, equals(1));
      expect(viewModel.state.events.first.title, equals('名古屋集合テスト'));
      expect(viewModel.state.isLoading, isFalse);
    });

    test('loadEvents 失敗時: errorMessage に例外内容が設定されること', () async {
      when(() => mockRepository.getEvents('group-uuid-001'))
          .thenThrow(Exception('DB Error'));

      await viewModel.loadEvents('group-uuid-001');

      expect(viewModel.state.events, isEmpty);
      expect(viewModel.state.errorMessage, contains('DB Error'));
    });
  });

  group('AdminEventViewModel - グループメンバー取得テスト', () {
    test('loadGroupMembers 成功時: 参加候補メンバー一覧が格納されること', () async {
      when(() => mockRepository.getGroupMembers('group-uuid-001'))
          .thenAnswer((_) async => [testMember]);

      await viewModel.loadGroupMembers('group-uuid-001');

      expect(viewModel.state.groupMembers.length, equals(1));
      expect(viewModel.state.groupMembers.first.nickname, equals('MemberA'));
    });
  });

  group('AdminEventViewModel - イベント作成 & 参加者割当テスト', () {
    test('createEventWithParticipants 成功時: eventId が返却されイベント一覧が再取得されること', () async {
      when(() => mockRepository.createEventWithParticipants(
            groupId: 'group-uuid-001',
            title: '名古屋集合テスト',
            destinationName: '名古屋駅 金時計前',
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            qrcodeId: 'QR-TEST-001',
            password: 'pass',
            arrivalTime: any(named: 'arrivalTime'),
            participantUserIds: ['user-001'],
          )).thenAnswer((_) async => 'event-uuid-001');

      when(() => mockRepository.getEvents('group-uuid-001'))
          .thenAnswer((_) async => [testEvent]);

      final eventId = await viewModel.createEventWithParticipants(
        groupId: 'group-uuid-001',
        title: '名古屋集合テスト',
        destinationName: '名古屋駅 金時計前',
        latitude: 35.170915,
        longitude: 136.881537,
        qrcodeId: 'QR-TEST-001',
        password: 'pass',
        arrivalTime: DateTime.parse('2026-09-25T09:00:00Z'),
        participantUserIds: ['user-001'],
      );

      expect(eventId, equals('event-uuid-001'));
      expect(viewModel.state.events.length, equals(1));
      verify(() => mockRepository.getEvents('group-uuid-001')).called(1);
    });
  });
}