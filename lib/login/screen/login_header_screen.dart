import 'package:flutter/material.dart';

Widget myHeader() {
  return Container(
    // 💡 背景色をオレンジにするならここで指定
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 20), // 文字の上下に隙間を作る
    decoration: const BoxDecoration(
      color: Color(0xFFEC5B13), // オレンジ背景
      border: Border(
        bottom: BorderSide(color: Colors.black, width: 2), // 下に黒い線を引く
      ),
    ),
    child: const Text(
      'APPNAME',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 16,
        fontFamily: 'Noto Sans JP',
        fontWeight: FontWeight.w900,
        height: 1.25,
        letterSpacing: -0.40,
      ),
    ),
  );
}