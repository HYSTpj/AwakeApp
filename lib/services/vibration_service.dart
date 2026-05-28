import 'package:vibration/vibration.dart';

abstract class VibrationService {
  Future<bool?> hasAmplitudeControl();
  Future<void> vibrate({int? duration, int? amplitude});
  Future<void> cancel();
}

class RealVibrationService implements VibrationService {
  @override
  Future<bool?> hasAmplitudeControl() async {
    return await Vibration.hasAmplitudeControl();
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
