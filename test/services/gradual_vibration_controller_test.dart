import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/services/gradual_vibration_controller.dart';
import 'package:flutter_application_1/services/vibration_service.dart';

class FakeVibrationService implements VibrationService {
  FakeVibrationService(this._hasAmplitudeControl);

  final Future<bool> Function() _hasAmplitudeControl;
  final List<({int? duration, int? amplitude})> vibrateCalls = [];
  int cancelCallCount = 0;

  @override
  Future<bool> hasAmplitudeControl() => _hasAmplitudeControl();

  @override
  Future<void> vibrate({int? duration, int? amplitude}) async {
    vibrateCalls.add((duration: duration, amplitude: amplitude));
  }

  @override
  Future<void> cancel() async {
    cancelCallCount++;
  }
}

void main() {
  group('GradualVibrationController', () {
    test('振幅制御ありの場合、tick()ごとに現在の強度でバイブレーションする', () async {
      final service = FakeVibrationService(() async => true);
      final controller = GradualVibrationController(vibrationService: service);

      await controller.start();
      controller.tick();
      controller.stop();

      expect(service.vibrateCalls.last.duration, 1000);
      expect(service.vibrateCalls.last.amplitude, 50);
    });

    test('振幅制御ありの場合、30秒(15tick)ごとに強度が50ずつ上昇する', () async {
      final service = FakeVibrationService(() async => true);
      final controller = GradualVibrationController(vibrationService: service);

      await controller.start();

      for (var i = 0; i < 14; i++) {
        controller.tick();
      }
      expect(controller.currentIntensity, 50);

      controller.tick(); // 15回目 = 30秒経過
      expect(controller.currentIntensity, 100);

      for (var i = 0; i < 15; i++) {
        controller.tick();
      }
      expect(controller.currentIntensity, 150);

      controller.stop();
    });

    test('強度は255で頭打ちになる', () async {
      final service = FakeVibrationService(() async => true);
      final controller = GradualVibrationController(vibrationService: service);

      await controller.start();

      for (var i = 0; i < 15 * 10; i++) {
        controller.tick();
      }

      expect(controller.currentIntensity, 255);

      controller.stop();
    });

    test('振幅制御なしの場合、amplitudeを指定せずdurationのみでバイブレーションする', () async {
      final service = FakeVibrationService(() async => false);
      final controller = GradualVibrationController(vibrationService: service);

      await controller.start();
      controller.tick();
      controller.tick();
      controller.stop();

      expect(service.vibrateCalls, hasLength(2));
      for (final call in service.vibrateCalls) {
        expect(call.duration, 1000);
        expect(call.amplitude, isNull);
      }
    });

    test('isCancelledがtrueの場合、hasAmplitudeControl()解決後もタイマーを開始しない(停止レース)', () async {
      final completer = Completer<bool>();
      final service = FakeVibrationService(() => completer.future);
      final controller = GradualVibrationController(vibrationService: service);

      final startFuture = controller.start(isCancelled: () => true);
      completer.complete(true);
      await startFuture;

      expect(controller.isRunning, isFalse);
      expect(service.vibrateCalls, isEmpty);
    });

    test('isCancelledがfalseの場合は通常通りタイマーが開始される', () async {
      final completer = Completer<bool>();
      final service = FakeVibrationService(() => completer.future);
      final controller = GradualVibrationController(vibrationService: service);

      final startFuture = controller.start(isCancelled: () => false);
      completer.complete(true);
      await startFuture;

      expect(controller.isRunning, isTrue);

      controller.stop();
    });

    test('isCancelledを渡さなくても、待機中にstop()が呼ばれればタイマーを開始しない(世代の不一致による無効化)', () async {
      final completer = Completer<bool>();
      final service = FakeVibrationService(() => completer.future);
      final controller = GradualVibrationController(vibrationService: service);

      final startFuture = controller.start();
      controller.stop();
      completer.complete(true);
      await startFuture;

      expect(controller.isRunning, isFalse);
      expect(service.vibrateCalls, isEmpty);
    });

    test('待機中に別のstart()が呼ばれた場合、最後に呼ばれたstart()だけがタイマーを開始する', () async {
      // 2つ目のstart()が1つ目のstart()冒頭のstop()相当処理を経て世代を進めるため、
      // 1つ目のstart()は_cancelVibration()完了直後の最初の世代チェックで早期returnし、
      // hasAmplitudeControl()には到達しない（callCountは2つ目のstart()の分しか増えない）。
      final firstCompleter = Completer<bool>();
      var callCount = 0;
      final service = FakeVibrationService(() {
        callCount++;
        return callCount == 1 ? firstCompleter.future : Future.value(true);
      });
      final controller = GradualVibrationController(vibrationService: service);

      final firstStart = controller.start();
      final secondStart = controller.start();
      firstCompleter.complete(true);
      await Future.wait([firstStart, secondStart]);

      expect(controller.isRunning, isTrue);

      controller.stop();
    });

    test(
      'hasAmplitudeControl()の待機中にstop()が呼ばれた場合、解決後もタイマーを開始しない'
      '(2箇所目の世代チェック)',
      () async {
        // 上のテストは _cancelVibration() 完了直後（1箇所目の世代チェック）で
        // 早期returnするケースしか検証できていなかった。ここでは
        // hasAmplitudeControl()の呼び出しが実際に行われた後で世代が
        // 変わるケース（2箇所目の世代チェック）を、hasAmplitudeControl()の
        // 呼び出しタイミングを合図するCompleterで確実に再現する。
        final hasAmplitudeCompleter = Completer<bool>();
        final invoked = Completer<void>();
        final service = FakeVibrationService(() {
          invoked.complete();
          return hasAmplitudeCompleter.future;
        });
        final controller = GradualVibrationController(vibrationService: service);

        final startFuture = controller.start();

        // start()が実際にhasAmplitudeControl()を呼び出すまで待つ
        // （_cancelVibration()完了・1箇所目の世代チェック通過を保証する）。
        await invoked.future;

        // hasAmplitudeControl()がまだ解決していない間に世代を進める。
        controller.stop();

        // ここでようやくhasAmplitudeControl()を解決させる。
        hasAmplitudeCompleter.complete(true);
        await startFuture;

        expect(controller.isRunning, isFalse);
        expect(service.vibrateCalls, isEmpty);
      },
    );

    test('hasAmplitudeControl()が例外を投げても、未捕捉のまま伝播せずamplitudeなしとして扱う', () async {
      final service = FakeVibrationService(
        () => Future<bool>.error('プラットフォームエラー'),
      );
      final controller = GradualVibrationController(vibrationService: service);

      await controller.start();

      expect(controller.isRunning, isTrue);

      controller.stop();
    });

    test('stop()でタイマーが止まりcancel()が呼ばれる', () async {
      final service = FakeVibrationService(() async => true);
      final controller = GradualVibrationController(vibrationService: service);

      await controller.start();
      expect(controller.isRunning, isTrue);

      controller.stop();

      expect(controller.isRunning, isFalse);
      expect(service.cancelCallCount, greaterThanOrEqualTo(1));
    });

    test('start()は開始時に既存のバイブレーションをキャンセルしてからやり直す', () async {
      final service = FakeVibrationService(() async => true);
      final controller = GradualVibrationController(vibrationService: service);

      await controller.start();
      await controller.start();

      expect(service.cancelCallCount, greaterThanOrEqualTo(2));

      controller.stop();
    });
  });
}
