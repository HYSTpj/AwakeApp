import 'package:flutter/material.dart';

import 'game_style_box.dart';

/// ログイン画面系と同じネオブルータリズム風（角丸＋黒枠線＋黒いハードシャドウ）のボタン。
class GameStyleButton extends StatelessWidget {
  const GameStyleButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    this.width = 400,
    this.height = 100,
    this.isLoading = false,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final size = Size(width, height);
    final radius = BorderRadius.circular(16);

    return GameStyleBox(
      width: size.width,
      height: size.height,
      color: backgroundColor,
      borderRadius: radius,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: size,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
        child: isLoading
            ? const CircularProgressIndicator()
            : Text(
                label,
                style: TextStyle(fontSize: 24, color: textColor, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
