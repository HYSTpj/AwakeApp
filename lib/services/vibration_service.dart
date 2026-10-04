import 'package:vibration/vibration.dart';

abstract class VibrationService {
  Future<bool> hasAmplitudeControl();
  Future<void> vibrate({int? duration, int? amplitude});
  Future<void> cancel();
}

class RealVibrationService implements VibrationService {
  RealVibrationService._();

  // キャッシュをアラーム間で共有するため、インスタンスをアプリ全体で1つに制限する（privateコンストラクタで強制）。
  static final RealVibrationService instance = RealVibrationService._();

  // 振幅制御対応は起動中不変のため最初の問い合わせ結果をキャッシュする（失敗時はキャッシュせず再試行）。
  // 注: flutter test環境ではPlatform判定により常にfalseが返るため、この挙動は直接検証できない。
  bool? _hasAmplitudeControlCache;

  // 確定前に複数アラームが同時に問い合わせるキャッシュスタンピードを防ぐため、進行中のFutureも共有する。
  Future<bool>? _hasAmplitudeControlInFlight;

  @override
  Future<bool> hasAmplitudeControl() async {
    final cached = _hasAmplitudeControlCache;
    if (cached != null) {
      return cached;
    }

    final inFlight = _hasAmplitudeControlInFlight;
    if (inFlight != null) {
      return inFlight;
    }

    final future = Vibration.hasAmplitudeControl();
    _hasAmplitudeControlInFlight = future;
    try {
      final result = await future;
      _hasAmplitudeControlCache = result;
      return result;
    } finally {
      _hasAmplitudeControlInFlight = null;
    }
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
