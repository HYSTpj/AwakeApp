import 'package:flutter/material.dart';

import 'game_style_box.dart';

/// 戻るボタンウィジェット
class ReturnButton extends StatelessWidget {
  final VoidCallback? onTap;
  const ReturnButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF1A1C1C);

    return GestureDetector(
      onTap: onTap ?? () => Navigator.pop(context),
      child: GameStyleBox(
        width: 45,
        height: 45,
        color: Colors.white,
        borderColor: borderColor,
        borderRadius: BorderRadius.circular(12),
        shadowOffset: 4,
        child: const Center(
          child: Icon(
            Icons.arrow_back,
            color: borderColor,
            size: 24,
          ),
        ),
      ),
    );
  }
}