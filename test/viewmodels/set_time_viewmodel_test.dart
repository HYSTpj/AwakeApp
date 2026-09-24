import 'package:flutter_test/flutter_test.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:flutter_application_1/viewmodels/set_time_viewmodel.dart';
import 'package:flutter_application_1/services/alarm_service.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/domain/entities/event_report.dart';
import 'package:flutter_application_1/domain/repositories/i_event_report_repository.dart';

class FakeAuthService implements AuthService {
  FakeAuthService({this.currentUserId});

  @override
  String? currentUserId;
}

class FakeAlarmService implements AlarmService {
  final List<AlarmSettings> setAlarmCalls = [];
  final List<int> stopCalls = [];
  bool shouldFailSetAlarm = false;

  @override
  Stream<AlarmSet> get ringing => const Stream.empty();

  @override
  Future<void> init() async {}

  @override
  Future<void> setAlarm({required AlarmSettings alarmSettings}) async {
    if (shouldFailSetAlarm) {
      throw Exception('setAlarm failed');
    }
    setAlarmCalls.add(alarmSettings);
  }

  @override
  Future<void> stop(int id) async {
    stopCalls.add(id);
  }
}

class FakeEventReportRepository implements IEventReportRepository {
  EventReport? reportToReturn;
  String? reportIdToReturn = 'report-1';
  bool shouldFailSetReport = false;
  final List<({String eventId, String userId, DateTime wakeupTime, DateTime departureTime})>
      setReportCalls = [];

  @override
  Future<EventReport?> getEventReport(String eventId, String userId) async {
    return reportToReturn;
  }

  @override
  Future<String?> setReport({
    required String eventId,
    required String userId,
    required DateTime wakeupTime,
    required DateTime departureTime,
  }) async {
    if (shouldFailSetReport) {
      throw Exception('setReport failed');
    }
    setReportCalls.add((
      eventId: eventId,
      userId: userId,
      wakeupTime: wakeupTime,
      departureTime: departureTime,
    ));
    return reportIdToReturn;
  }
}

void main() {
  group('SetTimeViewModel テスト', () {
    late SetTimeViewModel viewModel;

    setUp(() {
      viewModel = SetTimeViewModel(eventId: 'test-event-1');
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('初期化時、wakeupTime と departureTime は null', () {
      expect(viewModel.wakeupTime, isNull);
      expect(viewModel.departureTime, isNull);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isSaving, isFalse);
    });

    test('setWakeupTime() で起床時間が正しく設定される', () {
      final testTime = DateTime(2026, 5, 14, 6, 30);

      viewModel.setWakeupTime(testTime);

      expect(viewModel.wakeupTime, equals(testTime));
      expect(viewModel.wakeupTime?.hour, equals(6));
      expect(viewModel.wakeupTime?.minute, equals(30));
    });

    test('setDepartureTime() で出発時刻が正しく設定される', () {
      final testTime = DateTime(2026, 5, 14, 7, 15);

      viewModel.setDepartureTime(testTime);

      expect(viewModel.departureTime, equals(testTime));
      expect(viewModel.departureTime?.hour, equals(7));
      expect(viewModel.departureTime?.minute, equals(15));
    });

    test('起床時間と出発時刻を連続で設定できる', () {
      final wakeupTime = DateTime(2026, 5, 14, 6, 30);
      final departureTime = DateTime(2026, 5, 14, 7, 15);

      viewModel.setWakeupTime(wakeupTime);
      viewModel.setDepartureTime(departureTime);

      expect(viewModel.wakeupTime, equals(wakeupTime));
      expect(viewModel.departureTime, equals(departureTime));
      expect(viewModel.wakeupTime!.isBefore(viewModel.departureTime!), isTrue);
    });

    test('時刻が正しい日付オブジェクトとして格納される', () {
      final testTime = DateTime(2026, 5, 14, 6, 30, 45);

      viewModel.setWakeupTime(testTime);

      expect(viewModel.wakeupTime?.year, equals(2026));
      expect(viewModel.wakeupTime?.month, equals(5));
      expect(viewModel.wakeupTime?.day, equals(14));
      expect(viewModel.wakeupTime?.hour, equals(6));
      expect(viewModel.wakeupTime?.minute, equals(30));
      expect(viewModel.wakeupTime?.second, equals(45));
    });

    test('同じ時刻を複数回設定しても正しく更新される', () {
      final time1 = DateTime(2026, 5, 14, 6, 30);
      final time2 = DateTime(2026, 5, 14, 6, 45);

      viewModel.setWakeupTime(time1);
      expect(viewModel.wakeupTime, equals(time1));

      viewModel.setWakeupTime(time2);
      expect(viewModel.wakeupTime, equals(time2));
      expect(viewModel.wakeupTime, isNot(equals(time1)));
    });
  });

  group('SetTimeViewModel loadTime/saveChanges テスト（認証・アラーム・保存をfakeで注入）', () {
    late FakeAuthService authService;
    late FakeAlarmService alarmService;
    late FakeEventReportRepository repository;
    late SetTimeViewModel viewModel;

    SetTimeViewModel buildViewModel() {
      return SetTimeViewModel(
        eventId: 'event-1',
        authService: authService,
        alarmService: alarmService,
        repository: repository,
      );
    }

    setUp(() {
      authService = FakeAuthService(currentUserId: 'user-1');
      alarmService = FakeAlarmService();
      repository = FakeEventReportRepository();
      viewModel = buildViewModel();
    });

    test('未ログインの場合、loadTime()はエラーメッセージを設定しリポジトリを呼ばない', () async {
      authService.currentUserId = null;

      await viewModel.loadTime();

      expect(viewModel.errorMessage, 'ユーザーがログインしていません。');
      expect(viewModel.wakeupTime, isNull);
    });

    test('ログイン済みの場合、loadTime()はリポジトリの値を反映する', () async {
      repository.reportToReturn = EventReport(
        eventId: 'event-1',
        userId: 'user-1',
        plannedWakeupTime: DateTime(2026, 5, 14, 6, 30),
        plannedDepartureTime: DateTime(2026, 5, 14, 7, 15),
      );

      await viewModel.loadTime();

      expect(viewModel.wakeupTime, DateTime(2026, 5, 14, 6, 30));
      expect(viewModel.departureTime, DateTime(2026, 5, 14, 7, 15));
    });

    test('未ログインの場合、saveChanges()はfalseを返しアラームを登録しない', () async {
      authService.currentUserId = null;
      viewModel.setWakeupTime(DateTime(2026, 5, 14, 6, 30));
      viewModel.setDepartureTime(DateTime(2026, 5, 14, 7, 15));

      final result = await viewModel.saveChanges(DateTime(2026, 5, 14, 8, 0));

      expect(result, isFalse);
      expect(viewModel.errorMessage, '起床時刻と出発時刻を入力してください。');
      expect(alarmService.setAlarmCalls, isEmpty);
    });

    test('起床・出発時刻が未設定の場合、saveChanges()はfalseを返す', () async {
      final result = await viewModel.saveChanges(DateTime(2026, 5, 14, 8, 0));

      expect(result, isFalse);
      expect(viewModel.errorMessage, '起床時刻と出発時刻を入力してください。');
      expect(alarmService.setAlarmCalls, isEmpty);
    });

    test('正常系: アラーム登録とレポート保存が両方成功しtrueを返す', () async {
      viewModel.setWakeupTime(DateTime(2026, 5, 14, 6, 30));
      viewModel.setDepartureTime(DateTime(2026, 5, 14, 7, 15));

      final result = await viewModel.saveChanges(DateTime(2026, 5, 14, 8, 0));

      expect(result, isTrue);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isSaving, isFalse);
      expect(alarmService.setAlarmCalls, hasLength(2));
      expect(repository.setReportCalls, hasLength(1));
      expect(repository.setReportCalls.single.userId, 'user-1');
    });

    test('アラーム登録に失敗した場合、falseを返しレポートは保存されない', () async {
      alarmService.shouldFailSetAlarm = true;
      viewModel.setWakeupTime(DateTime(2026, 5, 14, 6, 30));
      viewModel.setDepartureTime(DateTime(2026, 5, 14, 7, 15));

      final result = await viewModel.saveChanges(DateTime(2026, 5, 14, 8, 0));

      expect(result, isFalse);
      expect(viewModel.errorMessage, 'アラームの登録に失敗しました。');
      expect(viewModel.isSaving, isFalse);
      expect(repository.setReportCalls, isEmpty);
    });

    test('レポート保存に失敗した場合、登録済みアラームをロールバックしfalseを返す', () async {
      repository.shouldFailSetReport = true;
      viewModel.setWakeupTime(DateTime(2026, 5, 14, 6, 30));
      viewModel.setDepartureTime(DateTime(2026, 5, 14, 7, 15));

      final result = await viewModel.saveChanges(DateTime(2026, 5, 14, 8, 0));

      expect(result, isFalse);
      expect(viewModel.errorMessage, '保存に失敗しました。');
      expect(viewModel.isSaving, isFalse);
      expect(alarmService.setAlarmCalls, hasLength(2));
      expect(alarmService.stopCalls, hasLength(2));
    });
  });
}
