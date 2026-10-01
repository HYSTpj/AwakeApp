import 'package:vibration/vibration.dart';

abstract class VibrationService {
  Future<bool> hasAmplitudeControl();
  Future<void> vibrate({int? duration, int? amplitude});
  Future<void> cancel();
}

class RealVibrationService implements VibrationService {
  // 端末が振幅制御に対応しているかはアプリの起動中に変わることがない
  // 静的な情報のため、このインスタンス内では最初に問い合わせた結果を
  // キャッシュして毎回の問い合わせを省く。問い合わせに失敗した場合は
  // キャッシュせず、次回呼び出し時に再試行する。
  //
  // 注: この挙動はユニットテストでは直接検証できない。vibrationパッケージの
  // hasAmplitudeControl()はPlatform.isAndroid/isIOSの判定を最初に行っており、
  // `flutter test`実行環境（ホストOS）ではどちらもfalseになるため、
  // ネイティブのメソッドチャンネル自体に到達せず常にfalseが返る
  // （vibrationパッケージ自身のテストも同じ制約を受けている）。
  bool? _hasAmplitudeControlCache;

  @override
  Future<bool> hasAmplitudeControl() async {
    final cached = _hasAmplitudeControlCache;
    if (cached != null) {
      return cached;
    }
    final result = await Vibration.hasAmplitudeControl();
    _hasAmplitudeControlCache = result;
    return result;
  }

  @override
  Future<void> vibrate({int? duration, int? amplitude}) async {
    if (amplitude != null) {
      await Vibration.vibrate(duration: duration ?? 1000, amplitude: amplitude);
    } else {
      await Vibration.vibrate(duration: duration ?? 1000);
    }
  }

  @override
  Future<void> cancel() async {
    await Vibration.cancel();
  }
}
