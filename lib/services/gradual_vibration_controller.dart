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
  // start()/stop()のたびに増え、古い世代の待機を無効化するトークン。
  int _generation = 0;
  // 一度も開始していなければcancel()呼び出しを省略するためのフラグ。
  bool _hasEverStarted = false;
  // 直前のvibrate()完了を待ってからcancel()するためのFuture（順序逆転によるレース防止）。
  Future<void>? _pendingVibrate;

  // 専用フラグによる食い違いを避けるため、_timerの有無で鳴動中かを判定する。
  bool get isRunning => _timer != null;
  int get currentIntensity => _currentIntensity;

  /// バイブレーションを開始する。既存の鳴動があれば先に止める。
  ///
  /// [isCancelled] はamplitude制御問い合わせ中の停止判定用（世代番号による無効化も併用）。
  ///
  /// 世代番号はawaitを挟まず同期的に更新する（挟むとstop()との競合を検知できなくなるため）。
  Future<void> start({bool Function()? isCancelled}) async {
    final myGeneration = ++_generation;
    _timer?.cancel();
    _timer = null;

    // 未開始ならcancel()を省略。開始済みなら前回の停止完了を待ってから次を開始する（命令の入れ替わり防止）。
    if (_hasEverStarted) {
      await _cancelVibration();

      if (myGeneration != _generation) {
        return;
      }
    }

    _currentIntensity = _initialIntensity;
    _elapsedSinceEscalation = Duration.zero;

    // 振幅制御対応のキャッシュは_vibrationService側の責務（本クラスはアラームごとの使い捨てのため）。
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
    _hasEverStarted = true;
    _timer = Timer.periodic(_tickInterval, (_) => tick());
  }

  /// [tickInterval] 経過ごとの1回分の処理。
  void tick() {
    final vibrateFuture = _vibrationService
        .vibrate(
          duration: 1000,
          amplitude: _hasAmplitude ? _currentIntensity : null,
        )
        .catchError((e) => debugPrint('バイブレーションに失敗しました: $e'));
    _pendingVibrate = vibrateFuture;
    unawaited(vibrateFuture);

    if (_hasAmplitude) {
      _elapsedSinceEscalation += _tickInterval;
      if (_elapsedSinceEscalation >= _escalationInterval) {
        _elapsedSinceEscalation = Duration.zero;
        _currentIntensity = nextVibrationIntensity(
          _currentIntensity,
          step: _step,
          max: _maxIntensity,
        );
      }
    }
  }

  /// バイブレーションとタイマーを止める（[dispose]など結果が不要な場合は待たなくてよい）。
  ///
  /// [cancelVibration] を`false`にするとタイマー停止のみ行う。[_vibrationService]はアラーム間で
  /// 共有されるため、他のアラームが鳴動中は`true`を渡さないこと（巻き込んで止めてしまう）。
  Future<void> stop({bool cancelVibration = true}) async {
    _generation++;
    // 振動中かどうかに関わらずstart()無効化のため必ず更新する（wasActiveはcancel()省略の判定専用）。
    final wasActive = isRunning;
    _timer?.cancel();
    _timer = null;

    // 未開始または鳴っていなければキャンセル対象がないためcancel()を省略する。
    if (_hasEverStarted && wasActive && cancelVibration) {
      await _cancelVibration();
    }
  }

  Future<void> _cancelVibration() async {
    final pendingVibrate = _pendingVibrate;
    _pendingVibrate = null;
    if (pendingVibrate != null) {
      await pendingVibrate;
    }

    try {
      await _vibrationService.cancel();
    } catch (e) {
      debugPrint('バイブレーション停止に失敗しました: $e');
    }
  }
}
