import 'package:flutter/material.dart';

import '../presentation/views/login/common_effects.dart';

/// ネオブルータリズム風（角丸＋黒枠線＋黒いハードシャドウ）の共通の箱。
/// [GameStyleButton] と [ReturnButton] はどちらもこれをベースにしている。
class GameStyleBox extends StatelessWidget {
  const GameStyleBox({
    super.key,
    required this.child,
    required this.color,
    this.width,
    this.height,
    this.borderColor = Colors.black,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.borderWidth = 3,
    this.shadowOffset = 8,
  });

  final Widget child;
  final Color color;
  final double? width;
  final double? height;
  final Color borderColor;
  final BorderRadius borderRadius;
  final double borderWidth;
  final double shadowOffset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: hardShadowDecoration(
        color: color,
        borderColor: borderColor,
        borderRadius: borderRadius,
        borderWidth: borderWidth,
        shadowOffset: shadowOffset,
      ),
      child: child,
    );
  }
}
