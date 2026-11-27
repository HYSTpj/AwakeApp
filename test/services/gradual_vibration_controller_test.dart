import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/services/gradual_vibration_controller.dart';
import 'package:flutter_application_1/services/vibration_service.dart';

class FakeVibrationService implements VibrationService {
  FakeVibrationService(
    this._hasAmplitudeControl, {
    Future<void> Function()? cancel,
    Future<void> Function()? vibrate,
  })  : _cancel = cancel,
        _vibrate = vibrate;

  final Future<bool> Function() _hasAmplitudeControl;
  // 省略時は即座に完了。cancel()の完了タイミングをテスト側から制御するためのオーバーライド。
  final Future<void> Function()? _cancel;
  // vibrate()の完了タイミングをテスト側から制御するためのオーバーライド（停止レース検証用）。
  final Future<void> Function()? _vibrate;
  final List<({int? duration, int? amplitude})> vibrateCalls = [];
  int cancelCallCount = 0;

  @override
  Future<bool> hasAmplitudeControl() => _hasAmplitudeControl();

  @override
  Future<void> vibrate({int? duration, int? amplitude}) async {
    vibrateCalls.add((duration: duration, amplitude: amplitude));
    if (_vibrate != null) {
      await _vibrate();
    }
  }

  @override
  Future<void> cancel() async {
    cancelCallCount++;
    if (_cancel != null) {
      await _cancel();
    }
  }
}

/// hasAmplitudeControl()の解決タイミングを制御するコントローラー/フェイクのセットを組み立てる。
({
  FakeVibrationService service,
  GradualVibrationController controller,
  Completer<bool> amplitudeCompleter,
})
_buildControllerWithPendingAmplitudeControl() {
  final amplitudeCompleter = Completer<bool>();
  final service = FakeVibrationService(() => amplitudeCompleter.future);
  final controller = GradualVibrationController(vibrationService: service);
  return (
    service: service,
    controller: controller,
    amplitudeCompleter: amplitudeCompleter,
  );
}

void main() {
  group('GradualVibrationController', () {
    // 振幅制御ありの端末を想定したデフォルトのフェイク/コントローラー（個別の挙動は各テストで組み立てる）。
    late FakeVibrationService service;
    late GradualVibrationController controller;

    setUp(() {
      service = FakeVibrationService(() async => true);
      controller = GradualVibrationController(vibrationService: service);
    });

    test('振幅制御ありの場合、tick()ごとに現在の強度でバイブレーションする', () async {
      await controller.start();
      controller.tick();
      controller.stop();

      expect(service.vibrateCalls.last.duration, 1000);
      expect(service.vibrateCalls.last.amplitude, 50);
    });

    test('振幅制御ありの場合、30秒(15tick)ごとに強度が50ずつ上昇する', () async {
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
      await controller.start();

      // 50スタート・step50・上限255なので、15tickごとの5回目のエスカレーションで頭打ちに達する。
      for (var i = 0; i < 15 * 5; i++) {
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
      final setup = _buildControllerWithPendingAmplitudeControl();

      final startFuture = setup.controller.start(isCancelled: () => true);
      setup.amplitudeCompleter.complete(true);
      await startFuture;

      expect(setup.controller.isRunning, isFalse);
      expect(setup.service.vibrateCalls, isEmpty);
    });

    test('isCancelledがfalseの場合は通常通りタイマーが開始される', () async {
      final setup = _buildControllerWithPendingAmplitudeControl();

      final startFuture = setup.controller.start(isCancelled: () => false);
      setup.amplitudeCompleter.complete(true);
      await startFuture;

      expect(setup.controller.isRunning, isTrue);

      setup.controller.stop();
    });

    test('isCancelledを渡さなくても、待機中にstop()が呼ばれればタイマーを開始しない(世代の不一致による無効化)', () async {
      final setup = _buildControllerWithPendingAmplitudeControl();

      final startFuture = setup.controller.start();
      setup.controller.stop();
      setup.amplitudeCompleter.complete(true);
      await startFuture;

      expect(setup.controller.isRunning, isFalse);
      expect(setup.service.vibrateCalls, isEmpty);
    });

    test('待機中に別のstart()が呼ばれた場合、最後に呼ばれたstart()だけがタイマーを開始する', () async {
      // 両方cancel()を経ずhasAmplitudeControl()に到達し、1つ目は世代の不一致で2箇所目のチェックで早期returnする。
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
        // 最初のstart()はcancel()を経ないため、ここでは2箇所目の世代チェックのみを検証する（1箇所目は別テスト参照）。
        final hasAmplitudeCompleter = Completer<bool>();
        final invoked = Completer<void>();
        final service = FakeVibrationService(() {
          invoked.complete();
          return hasAmplitudeCompleter.future;
        });
        final controller = GradualVibrationController(vibrationService: service);

        final startFuture = controller.start();

        await invoked.future; // start()がhasAmplitudeControl()を呼ぶまで待つ。
        controller.stop(); // 未解決の間に世代を進める。
        hasAmplitudeCompleter.complete(true); // ここで解決させる。
        await startFuture;

        expect(controller.isRunning, isFalse);
        expect(service.vibrateCalls, isEmpty);
      },
    );

    test(
      '2回目以降のstart()のcancel()待機中にstop()が呼ばれた場合、解決後もタイマーを開始しない'
      '(1箇所目の世代チェック)',
      () async {
        // 1箇所目の世代チェックが機能していれば2回目のstart()はcancel()解決直後に早期returnするはず（呼び出し回数で検証）。
        var hasAmplitudeCallCount = 0;
        final cancelCompleter = Completer<void>();
        var cancelCallCount = 0;
        final service = FakeVibrationService(
          () {
            hasAmplitudeCallCount++;
            return Future.value(true);
          },
          cancel: () {
            cancelCallCount++;
            // 1回目のstart()はcancel()を呼ばないので、ここでのcancel()は2回目のstart()によるものだけ。
            return cancelCallCount == 1 ? cancelCompleter.future : Future.value();
          },
        );
        final controller = GradualVibrationController(vibrationService: service);

        // 1回目のstart(): _hasEverStartedがfalseなのでcancel()は呼ばれず、_hasEverStartedがtrueになる。
        await controller.start();
        expect(controller.isRunning, isTrue);
        expect(hasAmplitudeCallCount, 1);
        expect(cancelCallCount, 0);

        // 2回目のstart(): cancel()が呼ばれるがまだ解決していない。
        final secondStart = controller.start();

        controller.stop(); // cancel()未解決の間に別のstop()で世代を進める。
        cancelCompleter.complete(); // ここで2回目のstart()のcancel()を解決させる。
        await secondStart;

        // 機能していればcancel()解決直後に早期returnしhasAmplitudeControl()は再呼されない。
        expect(hasAmplitudeCallCount, 1);
        expect(controller.isRunning, isFalse);
      },
    );

    test('hasAmplitudeControl()が例外を投げても、未捕捉のまま伝播せずamplitudeなしとして扱う', () async {
      final service = FakeVibrationService(
        () => Future<bool>.error('プラットフォームエラー'),
      );
      final controller = GradualVibrationController(vibrationService: service);

      await controller.start();

      expect(controller.isRunning, isTrue);

      // amplitudeなし扱いになっていることをtick()させて確認する（isRunningだけでは検証できない）。
      controller.tick();
      expect(service.vibrateCalls.last.amplitude, isNull);

      controller.stop();
    });

    test('stop()でタイマーが止まりcancel()が呼ばれる', () async {
      await controller.start();
      expect(controller.isRunning, isTrue);

      controller.stop();

      expect(controller.isRunning, isFalse);
      expect(service.cancelCallCount, greaterThanOrEqualTo(1));
    });

    test('start()は開始時に既存のバイブレーションをキャンセルしてからやり直す', () async {
      // 1回目のstart()は未開始状態からなのでcancel()は呼ばれない（#8）。
      await controller.start();
      expect(service.cancelCallCount, 0);

      // 2回目のstart()は1回目の振動を止める必要があるためcancel()が呼ばれる。
      await controller.start();
      expect(service.cancelCallCount, greaterThanOrEqualTo(1));

      controller.stop();
    });

    test(
      '一度も開始していないコントローラーをstop()してもcancel()は呼ばれない(#8)',
      () async {
        await controller.stop();

        expect(service.cancelCallCount, 0);
      },
    );

    test(
      '一度停止した後、何も鳴っていない状態でもう一度stop()を呼んでもcancel()は増えない(#8)',
      () async {
        await controller.start();
        await controller.stop();
        final cancelCallCountAfterFirstStop = service.cancelCallCount;

        // 通知経由の停止検知とダイアログのストップボタンなど複数箇所から冗長にstop()が呼ばれるケースを想定。
        await controller.stop();

        expect(service.cancelCallCount, cancelCallCountAfterFirstStop);
      },
    );

    test(
      'cancelVibration: falseの場合、タイマーは止まるがcancel()は呼ばれない'
      '(他のアラームが共有バイブレーターを使用中のケース)',
      () async {
        await controller.start();
        expect(controller.isRunning, isTrue);

        await controller.stop(cancelVibration: false);

        expect(controller.isRunning, isFalse);
        expect(service.cancelCallCount, 0);
      },
    );

    test(
      'tick()のvibrate()がまだ完了していない間にstop()が呼ばれても、'
      'cancel()はvibrate()の完了を待ってから呼ばれる'
      '(stop()直後に遅れて届いたvibrateで振動が1回だけ残るレースの防止)',
      () async {
        final vibrateCompleter = Completer<void>();
        final order = <String>[];
        final service = FakeVibrationService(
          () async => true,
          vibrate: () async {
            order.add('vibrate-dispatch');
            await vibrateCompleter.future;
            order.add('vibrate-done');
          },
          cancel: () async {
            order.add('cancel');
          },
        );
        final controller = GradualVibrationController(vibrationService: service);

        await controller.start();
        controller.tick();

        final stopFuture = controller.stop();

        // vibrate()がまだ完了していないので、cancel()はまだ呼ばれていないはず。
        expect(service.cancelCallCount, 0);

        vibrateCompleter.complete();
        await stopFuture;

        expect(order, ['vibrate-dispatch', 'vibrate-done', 'cancel']);
        expect(service.cancelCallCount, 1);
      },
    );
  });
}
