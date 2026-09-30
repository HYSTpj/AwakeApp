import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/services/gradual_vibration_controller.dart';
import 'package:flutter_application_1/services/vibration_service.dart';

class FakeVibrationService implements VibrationService {
  FakeVibrationService(this._hasAmplitudeControl, {Future<void> Function()? cancel})
      : _cancel = cancel;

  final Future<bool> Function() _hasAmplitudeControl;
  // 省略時はテストのデフォルト動作として即座に完了する。
  // cancel()の完了タイミング自体を制御したいテスト（1箇所目の世代チェックの
  // 検証など）のためにオーバーライド可能にしている。
  final Future<void> Function()? _cancel;
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
    if (_cancel != null) {
      await _cancel();
    }
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
        // フレッシュなコントローラーの最初のstart()は_hasEverStartedがfalseのため
        // _cancelVibration()自体を呼ばず、1箇所目の世代チェックを素通りして直接
        // hasAmplitudeControl()に到達する。そのため、このテストのように
        // 「フレッシュなコントローラーでの最初のstart()」を使うテストは、
        // 実質的にすべて2箇所目の世代チェックだけを検証していることになる
        // （1箇所目の世代チェックの検証は、下の別テストを参照）。
        final hasAmplitudeCompleter = Completer<bool>();
        final invoked = Completer<void>();
        final service = FakeVibrationService(() {
          invoked.complete();
          return hasAmplitudeCompleter.future;
        });
        final controller = GradualVibrationController(vibrationService: service);

        final startFuture = controller.start();

        // start()が実際にhasAmplitudeControl()を呼び出すまで待つ。
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

    test(
      '2回目以降のstart()のcancel()待機中にstop()が呼ばれた場合、解決後もタイマーを開始しない'
      '(1箇所目の世代チェック)',
      () async {
        // 1箇所目の世代チェック（_cancelVibration()完了直後のもの）は
        // _hasEverStartedがtrueの場合、つまり2回目以降のstart()でしか
        // 到達しない。さらに、#9のキャッシュが埋まっていると2回目以降の
        // start()はhasAmplitudeControl()を待たずに1箇所目のチェックの
        // 直後に2箇所目のチェックへ素通りしてしまい、1箇所目が正しく
        // 早期returnしなくても2箇所目が拾ってしまうため区別できない。
        // そこで、hasAmplitudeControl()を常に失敗させてキャッシュを
        // 埋まらないようにし、1箇所目のチェックが機能していなければ
        // hasAmplitudeControl()が余分にもう一度呼ばれることを検知する。
        var hasAmplitudeCallCount = 0;
        final cancelCompleter = Completer<void>();
        var cancelCallCount = 0;
        final service = FakeVibrationService(
          () {
            hasAmplitudeCallCount++;
            return Future<bool>.error('検証用: 常に失敗させてキャッシュを埋めない');
          },
          cancel: () {
            cancelCallCount++;
            // 1回目のstart()自体はcancel()を呼ばない（_hasEverStartedが
            // まだfalseのため）ので、ここでのcancel()は2回目のstart()に
            // よるものだけのはず。
            return cancelCallCount == 1 ? cancelCompleter.future : Future.value();
          },
        );
        final controller = GradualVibrationController(vibrationService: service);

        // 1回目のstart(): cancel()は呼ばれない（_hasEverStartedがまだ
        // falseのため）。hasAmplitudeControl()は失敗するが捕捉され、
        // _hasEverStartedはtrueになる（キャッシュは埋まらない）。
        await controller.start();
        expect(controller.isRunning, isTrue);
        expect(hasAmplitudeCallCount, 1);
        expect(cancelCallCount, 0);

        // 2回目のstart(): 今度は_hasEverStartedがtrueなのでcancel()が
        // 呼ばれるが、まだ解決していない（cancelCompleterが未完了のため）。
        final secondStart = controller.start();

        // cancel()がまだ解決していない間に、別のstop()で世代を進める。
        controller.stop();

        // ここでようやく2回目のstart()のcancel()を解決させる。
        cancelCompleter.complete();
        await secondStart;

        // 1箇所目の世代チェックが機能していれば、cancel()解決直後に
        // 早期returnし、hasAmplitudeControl()が再度呼ばれることはない
        // （キャッシュも埋まっていないため、チェックが機能していなければ
        // 素通りしてもう一度呼ばれてしまうはず）。
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

      // 1回目のstart()は何も鳴っていない状態からの開始なのでcancel()は呼ばれない
      // （#8: 一度も開始していない場合はネイティブ側へのcancel()呼び出しを省略する）。
      await controller.start();
      expect(service.cancelCallCount, 0);

      // 2回目のstart()は、1回目で鳴り始めたバイブレーションを止める必要があるため
      // cancel()が呼ばれる。
      await controller.start();
      expect(service.cancelCallCount, greaterThanOrEqualTo(1));

      controller.stop();
    });

    test(
      '一度も開始していないコントローラーをstop()してもcancel()は呼ばれない(#8)',
      () async {
        final service = FakeVibrationService(() async => true);
        final controller = GradualVibrationController(vibrationService: service);

        await controller.stop();

        expect(service.cancelCallCount, 0);
      },
    );

    test(
      '一度停止した後、何も鳴っていない状態でもう一度stop()を呼んでもcancel()は増えない(#8)',
      () async {
        final service = FakeVibrationService(() async => true);
        final controller = GradualVibrationController(vibrationService: service);

        await controller.start();
        await controller.stop();
        final cancelCallCountAfterFirstStop = service.cancelCallCount;

        // 既に停止済みの状態で、通知経由の停止検知とダイアログのストップ
        // ボタンなど複数箇所から冗長にstop()が呼ばれるケースを想定。
        await controller.stop();

        expect(service.cancelCallCount, cancelCallCountAfterFirstStop);
      },
    );

    test(
      'hasAmplitudeControl()の結果はキャッシュされ、2回目以降のstart()では問い合わせない(#9)',
      () async {
        var hasAmplitudeControlCallCount = 0;
        final service = FakeVibrationService(() {
          hasAmplitudeControlCallCount++;
          return Future.value(true);
        });
        final controller = GradualVibrationController(vibrationService: service);

        await controller.start();
        await controller.start();
        await controller.start();

        expect(hasAmplitudeControlCallCount, 1);

        controller.stop();
      },
    );
  });
}
