import 'dart:async';

import '../utils/vibration_intensity.dart';
import 'vibration_service.dart';

/// アラーム鳴動中、時間の経過とともにバイブレーション強度を段階的に引き上げる。
///
/// [tick] を外部（[Timer.periodic] または単体テスト）から呼び出すことで
/// 実時間を待たずに経過をシミュレートできる。
class GradualVibrationController {
  GradualVibrationController({
    required VibrationService vibrationService,
    Duration tickInterval = const Duration(seconds: 2),
    Duration escalationInterval = const Duration(seconds: 30),
    int initialIntensity = 50,
    int step = 50,
    int maxIntensity = 255,
  })  : _vibrationService = vibrationService,
        _tickInterval = tickInterval,
        _escalationInterval = escalationInterval,
        _initialIntensity = initialIntensity,
        _step = step,
        _maxIntensity = maxIntensity;

  final VibrationService _vibrationService;
  final Duration _tickInterval;
  final Duration _escalationInterval;
  final int _initialIntensity;
  final int _step;
  final int _maxIntensity;

  Timer? _timer;
  bool _hasAmplitude = false;
  int _currentIntensity = 0;
  Duration _elapsedSinceEscalation = Duration.zero;
  bool _isRunning = false;

  bool get isRunning => _isRunning;
  int get currentIntensity => _currentIntensity;

  /// バイブレーションを開始する。既存の鳴動があれば先に止める。
  ///
  /// [isCancelled] は amplitude 制御の有無を問い合わせている間にアラームが
  /// 停止された場合、タイマー開始を取りやめるための判定に使う。
  Future<void> start({bool Function()? isCancelled}) async {
    stop();

    _currentIntensity = _initialIntensity;
    _elapsedSinceEscalation = Duration.zero;

    final hasAmplitude = await _vibrationService.hasAmplitudeControl();

    if (isCancelled?.call() ?? false) {
      return;
    }

    _hasAmplitude = hasAmplitude;
    _isRunning = true;
    _timer = Timer.periodic(_tickInterval, (_) => tick());
  }

  /// [tickInterval] 経過ごとの1回分の処理。
  void tick() {
    if (_hasAmplitude) {
      _vibrationService.vibrate(duration: 1000, amplitude: _currentIntensity);

      _elapsedSinceEscalation += _tickInterval;
      if (_elapsedSinceEscalation >= _escalationInterval) {
        _elapsedSinceEscalation = Duration.zero;
        _currentIntensity = nextVibrationIntensity(
          _currentIntensity,
          step: _step,
          max: _maxIntensity,
        );
      }
    } else {
      _vibrationService.vibrate(duration: 1000);
    }
  }

  /// バイブレーションとタイマーを止める。
  void stop() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    _vibrationService.cancel();
  }
}
