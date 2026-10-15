import 'package:flutter/material.dart';

// ボタンの中身を「ラベル文字」と「ローディングスピナー」で切り替える共通ウィジェット。
// login_body.dart / signup_body.dart / create_account_body.dart の送信ボタンで共通して使う。
class LoadingButtonLabel extends StatelessWidget {
  final bool isLoading;
  final String label;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;

  const LoadingButtonLabel({
    super.key,
    required this.isLoading,
    required this.label,
    this.color = Colors.white,
    this.fontSize = 18,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      );
    }
    return Text(
      label,
      style: TextStyle(color: color, fontWeight: fontWeight, fontSize: fontSize),
    );
  }
}
