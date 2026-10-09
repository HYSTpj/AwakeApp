import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/utils/vibration_intensity.dart';

void main() {
  group('nextVibrationIntensity', () {
    test('初期強度50から50ずつ上昇する', () {
      expect(nextVibrationIntensity(50), 100);
      expect(nextVibrationIntensity(100), 150);
      expect(nextVibrationIntensity(150), 200);
    });

    test('255を超えないようクランプされる', () {
      expect(nextVibrationIntensity(200), 250);
      expect(nextVibrationIntensity(250), 255);
    });

    test('すでに255に達している場合はそのまま255を維持する', () {
      expect(nextVibrationIntensity(255), 255);
    });

    test('stepとmaxを指定して段階を変えられる', () {
      expect(nextVibrationIntensity(10, step: 20, max: 40), 30);
      expect(nextVibrationIntensity(30, step: 20, max: 40), 40);
      expect(nextVibrationIntensity(40, step: 20, max: 40), 40);
    });
  });
}
