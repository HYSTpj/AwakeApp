import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_application_1/data/repositories/member_event_repository.dart';
import 'package:flutter_application_1/models/event_report.dart';
import 'package:flutter_application_1/presentation/views/member_event_view_model.dart';

class MockMemberEventRepository extends Mock implements MemberEventRepository {}

void main() {
  late MockMemberEventRepository mockRepository;
  late MemberEventViewModel viewModel;
  late StreamController<List<EventReport>> streamController;

  const currentUid = 'user-001';
  final testReportMy = EventReport(
    id: 'report-001',
    eventId: 'event-001',
    userId: currentUid,
    status: 0, // sleeping
    updatedAt: DateTime.parse('2026-09-22T06:00:00Z'),
  );

  final testReportOther = EventReport(
    id: 'report-002',
    eventId: 'event-001',
    userId: 'user-002',
    status: 1, // awake
    updatedAt: DateTime.parse('2026-09-22T06:10:00Z'),
  );

  setUp(() {
    mockRepository = MockMemberEventRepository();
    streamController = StreamController<List<EventReport>>.broadcast();
    when(() => mockRepository.watchEventReports('event-001'))
        .thenAnswer((_) => streamController.stream);

    viewModel = MemberEventViewModel(mockRepository, currentUserId: currentUid);
  });

  tearDown(() {
    streamController.close();
    viewModel.dispose();
  });

  group('MemberEventViewModel - リアルタイム監視テスト', () {
    test('init 実行後、Stream からレポートが配信された際に myReport と allReports が同期されること', () async {
      viewModel.init('event-001');

      streamController.add([testReportMy, testReportOther]);
      await pumpEventQueue();

      expect(viewModel.state.allReports.length, equals(2));
      expect(viewModel.state.myReport?.userId, equals(currentUid));
      expect(viewModel.state.myReport?.status, equals(0));
      expect(viewModel.state.isLoading, isFalse);
    });
  });

  group('MemberEventViewModel - 各種当日アクションテスト', () {
    test('reportWakeUp 成功時: message が設定され true が返ること', () async {
      when(() => mockRepository.reportWakeUp('event-001'))
          .thenAnswer((_) async => {'success': true, 'status': 1});

      final result = await viewModel.reportWakeUp('event-001');

      expect(result, isTrue);
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.errorMessage, isNull);
    });

    test('checkInWithQr 不正コード時: false が返りエラーメッセージが設定されること', () async {
      when(() => mockRepository.checkInWithQr('event-001', 'INVALID_QR'))
          .thenThrow(Exception('Invalid QR Code'));

      final result = await viewModel.checkInWithQr('event-001', 'INVALID_QR');

      expect(result, isFalse);
      expect(viewModel.state.errorMessage, contains('Invalid QR Code'));
    });

    test('submitLateReport 成功時: 完了メッセージが設定されること', () async {
      when(() => mockRepository.submitLateReport(
            eventId: 'event-001',
            reason: '二度寝してしまいました',
            photoUrl: any(named: 'photoUrl'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          )).thenAnswer((_) async {});

      final result = await viewModel.submitLateReport(
        eventId: 'event-001',
        reason: '二度寝してしまいました',
      );

      expect(result, isTrue);
      expect(viewModel.state.message, equals('遅刻レポートを投稿しました'));
    });
  });
}