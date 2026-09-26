import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/viewmodels/set_time_viewmodel.dart';

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
}
