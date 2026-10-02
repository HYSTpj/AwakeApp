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

/// hasAmplitudeControl()の解決タイミングをテスト側から制御するための
/// コントローラー/フェイクのセットを組み立てる。停止レース系のテストで
/// 同じ組み立てコードが重複していたため共通化した。
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
    // 振幅制御ありの端末を想定した、最もよく使うデフォルトのフェイク/
    // コントローラー。個別の挙動（振幅制御なし・例外・タイミング制御など）
    // が必要なテストはローカルで独自に組み立てる。
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

      // 50スタート・step 50・上限255なので、15tickごとの5回目のエスカレーション
      // (50→100→150→200→250→255)で頭打ちに達する。15*5回で必要十分。
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
      // フレッシュなコントローラーでは_hasEverStartedがfalseのため、
      // 1つ目・2つ目のstart()はどちらも_cancelVibration()を呼ばずに
      // hasAmplitudeControl()へ直接到達する（callCountは2まで増える）。
      // 1つ目のstart()は、2つ目のstart()が世代を進めた後、
      // hasAmplitudeControl()解決後の2箇所目の世代チェックで早期returnする。
      // （「1箇所目の世代チェック」の検証は、別の専用テストを参照）。
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
        // 到達しない。hasAmplitudeControl()の呼び出し回数を数えておき、
        // 1箇所目のチェックが機能していれば2回目のstart()はcancel()解決
        // 直後に早期returnしてhasAmplitudeControl()を呼ばないはず
        // （機能していなければ素通りしてもう一度呼ばれてしまう）。
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
            // 1回目のstart()自体はcancel()を呼ばない（_hasEverStartedが
            // まだfalseのため）ので、ここでのcancel()は2回目のstart()に
            // よるものだけのはず。
            return cancelCallCount == 1 ? cancelCompleter.future : Future.value();
          },
        );
        final controller = GradualVibrationController(vibrationService: service);

        // 1回目のstart(): cancel()は呼ばれない（_hasEverStartedがまだ
        // falseのため）。hasAmplitudeControl()が成功し、_hasEverStarted
        // がtrueになる。
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
        // 早期returnし、hasAmplitudeControl()が再度呼ばれることはない。
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

      // amplitudeなしとして扱われていることを、実際にtick()させて
      // vibrateCallsのamplitudeがnullであることまで確認する
      // （isRunningだけではこの分岐の正しさを検証できない）。
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

        // 既に停止済みの状態で、通知経由の停止検知とダイアログのストップ
        // ボタンなど複数箇所から冗長にstop()が呼ばれるケースを想定。
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
  });
}
