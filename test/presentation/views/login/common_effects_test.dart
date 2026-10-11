import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/presentation/views/login/common_effects.dart';

void main() {
  test('kBrandOrangeはログイン画面で使われているブランドカラーと一致する', () {
    expect(kBrandOrange, const Color(0xFFEC5B13));
  });

  group('hardShadowDecoration', () {
    test('常に黒・オフセット(4,4)のBoxShadowが設定される', () {
      final decoration = hardShadowDecoration();

      expect(
        decoration.boxShadow,
        const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
      );
    });

    test('デフォルトでは黒・幅1の枠線が設定される', () {
      final decoration = hardShadowDecoration();

      expect(decoration.border, Border.all(color: Colors.black, width: 1));
    });

    test('borderColorを指定するとその色の枠線になる', () {
      final decoration = hardShadowDecoration(
        borderColor: const Color(0xFF6B7280),
      );

      expect(
        decoration.border,
        Border.all(color: const Color(0xFF6B7280), width: 1),
      );
    });

    test('showBorderをfalseにすると枠線は設定されない', () {
      final decoration = hardShadowDecoration(showBorder: false);

      expect(decoration.border, isNull);
    });

    test('colorを指定すると背景色が設定される', () {
      final decoration = hardShadowDecoration(color: Colors.white);

      expect(decoration.color, Colors.white);
    });

    test('colorを指定しない場合は背景色は設定されない', () {
      final decoration = hardShadowDecoration();

      expect(decoration.color, isNull);
    });
  });
}
