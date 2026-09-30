import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/presentation/viewmodels/set_time_viewmodel.dart';
import 'package:flutter_application_1/data/repositories/member_event_repository.dart';
import 'package:flutter_application_1/models/event_report.dart';
import 'package:flutter_application_1/services/alarm_service.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';

// DB通信をモック化
class FakeMemberEventRepository implements MemberEventRepository {
  EventReport? reportToReturn;
  bool shouldFailSetReport = false;
  bool shouldFailReportWakeUp = false;
  bool shouldFailReportDeparture = false;
  bool shouldFailCheckIn = false;
  DateTime? savedWakeupTime;
  DateTime? savedDepartureTime;

  @override
  Future<EventReport?> getMyReport(String eventId) async => reportToReturn;

  @override
  Stream<List<EventReport>> watchEventReports(String eventId) => const Stream.empty();

  @override
  Future<void> setPlannedTimes({
    required String eventId,
    required DateTime wakeupTime,
    required DateTime departureTime,
  }) async {
    if (shouldFailSetReport) {
      throw Exception('setReport failed');
    }
    savedWakeupTime = wakeupTime;
    savedDepartureTime = departureTime;
  }

  @override
  Future<Map<String, dynamic>> reportWakeUp(String eventId) async =>
      {'success': !shouldFailReportWakeUp};

  @override
  Future<Map<String, dynamic>> reportDeparture(String eventId) async =>
      {'success': !shouldFailReportDeparture};

  @override
  Future<Map<String, dynamic>> checkInWithQr(String eventId, String qrCode) async =>
      {'success': !shouldFailCheckIn};

  @override
  Future<Map<String, dynamic>> checkInWithPasscode(String eventId, String passcode) async =>
      {'success': !shouldFailCheckIn};

  @override
  Future<void> submitLateReport({
    required String eventId,
    required String reason,
    String? photoUrl,
    double? latitude,
    double? longitude,
  }) async {}
}

// ネイティブアラーム呼び出しを安全に回避。
// AlarmServiceを直接implementsすることで、将来インターフェースに
// メソッドが追加された際にコンパイルエラーで気づけるようにしている
// （RealAlarmServiceをextendsすると、未オーバーライドのメンバーが
// 実プラットフォームのメソッドチャンネルを呼び出す実装のまま残ってしまう）。
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

void main() {
  group('SetTimeViewModel テスト', () {
    late SetTimeViewModel viewModel;
    late FakeMemberEventRepository fakeRepository;
    late FakeAlarmService fakeAlarmService;

    setUp(() {
      fakeRepository = FakeMemberEventRepository();
      fakeAlarmService = FakeAlarmService();
      viewModel = SetTimeViewModel(
        eventId: 'test-event-1',
        repository: fakeRepository,
        alarmService: fakeAlarmService,
      );
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

  group('SetTimeViewModel loadTime/saveChanges テスト（アラーム・保存をfakeで注入）', () {
    late FakeAlarmService alarmService;
    late FakeMemberEventRepository repository;
    late SetTimeViewModel viewModel;

    SetTimeViewModel buildViewModel() {
      return SetTimeViewModel(
        eventId: 'event-1',
        alarmService: alarmService,
        repository: repository,
      );
    }

    setUp(() {
      alarmService = FakeAlarmService();
      repository = FakeMemberEventRepository();
      viewModel = buildViewModel();
    });

    test('リポジトリに保存済みの値がある場合、loadTime()はその値を反映する', () async {
      repository.reportToReturn = EventReport(
        id: 'report-1',
        eventId: 'event-1',
        userId: 'user-1',
        plannedWakeupTime: DateTime(2026, 5, 14, 6, 30),
        plannedDepartureTime: DateTime(2026, 5, 14, 7, 15),
        status: 0,
        updatedAt: DateTime(2026, 5, 14),
      );

      await viewModel.loadTime();

      expect(viewModel.wakeupTime, DateTime(2026, 5, 14, 6, 30));
      expect(viewModel.departureTime, DateTime(2026, 5, 14, 7, 15));
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
      expect(repository.savedWakeupTime, isNotNull);
      expect(repository.savedDepartureTime, isNotNull);
    });

    test('アラーム登録に失敗した場合、falseを返しレポートは保存されない', () async {
      alarmService.shouldFailSetAlarm = true;
      viewModel.setWakeupTime(DateTime(2026, 5, 14, 6, 30));
      viewModel.setDepartureTime(DateTime(2026, 5, 14, 7, 15));

      final result = await viewModel.saveChanges(DateTime(2026, 5, 14, 8, 0));

      expect(result, isFalse);
      expect(viewModel.errorMessage, 'アラームの登録に失敗しました。');
      expect(viewModel.isSaving, isFalse);
      expect(repository.savedWakeupTime, isNull);
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
