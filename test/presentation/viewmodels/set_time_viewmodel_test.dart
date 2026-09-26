import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/presentation/viewmodels/set_time_viewmodel.dart';
import 'package:flutter_application_1/data/repositories/member_event_repository.dart';
import 'package:flutter_application_1/models/event_report.dart';
import 'package:flutter_application_1/services/alarm_service.dart';
import 'package:alarm/alarm.dart';

// DB通信をモック化
class FakeMemberEventRepository implements MemberEventRepository {
  DateTime? savedWakeupTime;
  DateTime? savedDepartureTime;

  @override
  Future<EventReport?> getMyReport(String eventId) async => null;

  @override
  Stream<List<EventReport>> watchEventReports(String eventId) => const Stream.empty();

  @override
  Future<void> setPlannedTimes({
    required String eventId,
    required DateTime wakeupTime,
    required DateTime departureTime,
  }) async {
    savedWakeupTime = wakeupTime;
    savedDepartureTime = departureTime;
  }

  @override
  Future<Map<String, dynamic>> reportWakeUp(String eventId) async => {'success': true};

  @override
  Future<Map<String, dynamic>> reportDeparture(String eventId) async => {'success': true};

  @override
  Future<Map<String, dynamic>> checkInWithQr(String eventId, String qrCode) async => {'success': true};

  @override
  Future<Map<String, dynamic>> checkInWithPasscode(String eventId, String passcode) async => {'success': true};

  @override
  Future<void> submitLateReport({
    required String eventId,
    required String reason,
    String? photoUrl,
    double? latitude,
    double? longitude,
  }) async {}
}

// ネイティブアラーム呼び出しを安全に回避
class FakeAlarmService extends RealAlarmService {
  @override
  Future<void> setAlarm({required AlarmSettings alarmSettings}) async {}

  @override
  Future<void> stop(int id) async {}
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
}