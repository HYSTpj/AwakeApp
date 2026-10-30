import 'package:flutter/material.dart';

/// ログイン関連画面で使われているブランドカラー（オレンジ）。
const kBrandOrange = Color(0xFFEC5B13);

/// 退会・削除など破壊的な操作であることを示すボタン背景色。
const kDangerRed = Color(0xFFF26A63);

/// ログイン関連画面で使われているネオブルータリズム風の装飾
/// （白/色背景 + 黒枠線 + 右下4,4オフセットの黒いBoxShadow）を共通化する。
BoxDecoration hardShadowDecoration({
  Color? color,
  Color borderColor = Colors.black,
  double borderWidth = 1,
  bool showBorder = true,
  BorderRadius borderRadius = BorderRadius.zero,
  double shadowOffset = 4,
}) {
  return BoxDecoration(
    color: color,
    border: showBorder ? Border.all(color: borderColor, width: borderWidth) : null,
    borderRadius: borderRadius,
    boxShadow: [
      BoxShadow(color: Colors.black, offset: Offset(shadowOffset, shadowOffset)),
    ],
  );
}
