import 'package:flutter/material.dart';

/// 戻るボタンウィジェット
class ReturnButton extends StatelessWidget {
  final VoidCallback? onTap;
  const ReturnButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF1A1C1C);

    return GestureDetector(
      onTap: onTap ?? () => Navigator.pop(context),
      child: Stack( // 影をきれいに見せるためにStackを使用
        children: [
          // 背面の黒い影（板）
          Container(
            width: 45, // ボタン本体より少し小さく見えるよう調整
            height: 45,
            margin: const EdgeInsets.only(left: 4, top: 4), // 影のズレ分
            decoration: BoxDecoration(
              color: borderColor,
              border: Border.all(color: borderColor, width: 2),
            ),
          ),
          // 前面の白いボタン本体
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: borderColor, width: 2),
            ),
            child: const Center(
              child: Icon(
                Icons.arrow_back,
                color: borderColor,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}