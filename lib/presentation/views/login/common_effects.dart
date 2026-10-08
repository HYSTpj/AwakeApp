import 'package:flutter/material.dart';

/// ログイン関連画面で使われているブランドカラー（オレンジ）。
const kBrandOrange = Color(0xFFEC5B13);

/// ログイン関連画面で使われているネオブルータリズム風の装飾
/// （白/色背景 + 黒枠線 + 右下4,4オフセットの黒いBoxShadow）を共通化する。
BoxDecoration hardShadowDecoration({
  Color? color,
  Color borderColor = Colors.black,
  double borderWidth = 1,
  bool showBorder = true,
}) {
  return BoxDecoration(
    color: color,
    border: showBorder ? Border.all(color: borderColor, width: borderWidth) : null,
    boxShadow: const [
      BoxShadow(color: Colors.black, offset: Offset(4, 4)),
    ],
  );
}
