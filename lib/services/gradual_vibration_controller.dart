import 'dart:async';

import 'package:flutter/foundation.dart';

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
  // start()/stop()が呼ばれるたびに増える世代番号。
  // hasAmplitudeControl()の待機中にstop()（または別のstart()）が呼ばれても、
  // 古い世代の待機はタイマーを作らないようにするための無効化トークン。
  int _generation = 0;

  bool get isRunning => _isRunning;
  int get currentIntensity => _currentIntensity;

  /// バイブレーションを開始する。既存の鳴動があれば先に止める。
  ///
  /// [isCancelled] は amplitude 制御の有無を問い合わせている間にアラームが
  /// 停止された場合、タイマー開始を取りやめるための判定に使う。
  /// これに加えて、待機中に[stop]（または新たな[start]）が呼ばれた場合も
  /// 世代番号の不一致により自動的に無効化される。
  ///
  /// 世代番号の更新は（[_cancelVibration]のawaitを挟まず）同期的に行う。
  /// 先にawaitを挟んでしまうと、その間に外部から[stop]が呼ばれても
  /// 世代の不一致を検知できないレースが生まれるため。
  Future<void> start({bool Function()? isCancelled}) async {
    final myGeneration = ++_generation;
    _isRunning = false;
    _timer?.cancel();
    _timer = null;

    // 前回分の停止命令(cancel())の完了を待ってから次の振動を開始することで、
    // 停止と開始の命令がプラットフォーム側で入れ替わって届くのを防ぐ。
    await _cancelVibration();

    if (myGeneration != _generation) {
      return;
    }

    _currentIntensity = _initialIntensity;
    _elapsedSinceEscalation = Duration.zero;

    var hasAmplitude = false;
    try {
      hasAmplitude = await _vibrationService.hasAmplitudeControl();
    } catch (e) {
      debugPrint('バイブレーション制御の確認に失敗しました: $e');
    }

    if (myGeneration != _generation || (isCancelled?.call() ?? false)) {
      return;
    }

    _hasAmplitude = hasAmplitude;
    _isRunning = true;
    _timer = Timer.periodic(_tickInterval, (_) => tick());
  }

  /// [tickInterval] 経過ごとの1回分の処理。
  void tick() {
    if (_hasAmplitude) {
      unawaited(
        _vibrationService
            .vibrate(duration: 1000, amplitude: _currentIntensity)
            .catchError((e) => debugPrint('バイブレーションに失敗しました: $e')),
      );

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
      unawaited(
        _vibrationService
            .vibrate(duration: 1000)
            .catchError((e) => debugPrint('バイブレーションに失敗しました: $e')),
      );
    }
  }

  /// バイブレーションとタイマーを止める。
  ///
  /// `cancel()`の完了を待つため`Future`を返すが、呼び出し元が結果を
  /// 必要としない場合（[dispose]など）は待たずに呼び出してよい。
  Future<void> stop() async {
    _generation++;
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    await _cancelVibration();
  }

  Future<void> _cancelVibration() async {
    try {
      await _vibrationService.cancel();
    } catch (e) {
      debugPrint('バイブレーション停止に失敗しました: $e');
    }
  }
}
