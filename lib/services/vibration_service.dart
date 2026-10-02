import 'package:vibration/vibration.dart';

abstract class VibrationService {
  Future<bool> hasAmplitudeControl();
  Future<void> vibrate({int? duration, int? amplitude});
  Future<void> cancel();
}

class RealVibrationService implements VibrationService {
  RealVibrationService._();

  // キャッシュ（特に振幅制御問い合わせの結果）をアラーム間で確実に共有
  // できるよう、インスタンスはアプリ全体で1つだけに制限する。
  // コンストラクタをprivateにしているため、`RealVibrationService()`と
  // 誤って新規作成することはコンパイルエラーになり、必ずこの
  // `instance`経由で同じインスタンスを使うことが型レベルで保証される。
  static final RealVibrationService instance = RealVibrationService._();

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

  // 結果が確定する前に複数のアラームがほぼ同時に問い合わせた場合、
  // 全員が「キャッシュはまだ空だ」と判断してそれぞれ個別に問い合わせて
  // しまう（キャッシュスタンピード）のを防ぐため、進行中の問い合わせ自体
  // （Future）も保持しておき、後から来た呼び出しはその完了を一緒に待つ。
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
