import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibration/vibration.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('vibration');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      calls.add(call);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  // vibration 3.2.1 へのアップグレード（1.9.0 から）で main.dart の
  // `await Vibration.hasAmplitudeControl() ?? false` から `?? false` を除去した。
  // hasAmplitudeControl() が非null許容の bool を返し続けることを保証する回帰テスト。
  group('vibrationパッケージ 3.2.1 互換性', () {
    test('hasAmplitudeControl() は非nullのboolを返す', () async {
      final result = await Vibration.hasAmplitudeControl();

      expect(result, isA<bool>());
    });

    test('vibrate() はamplitude指定時にネイティブへ正しい引数を渡す', () async {
      await Vibration.vibrate(duration: 1000, amplitude: 150);

      expect(calls, hasLength(1));
      expect(calls.single.method, 'vibrate');
      expect(calls.single.arguments['duration'], 1000);
      expect(calls.single.arguments['amplitude'], 150);
    });

    test('vibrate() はamplitude未指定時デフォルト値(-1)を渡す', () async {
      await Vibration.vibrate(duration: 1000);

      expect(calls.single.arguments['duration'], 1000);
      expect(calls.single.arguments['amplitude'], -1);
    });

    test('cancel() はネイティブのcancelメソッドを呼び出す', () async {
      await Vibration.cancel();

      expect(calls, hasLength(1));
      expect(calls.single.method, 'cancel');
    });
  });
}
