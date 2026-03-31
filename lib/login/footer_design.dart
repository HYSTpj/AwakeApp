import 'package:flutter/material.dart';

Widget myFooter() {

  // footer背景
  return Container(
    height: 75,
    padding: const EdgeInsets.only(top: 24, right: 10, bottom: 24),
    decoration: ShapeDecoration(
      color: const Color(0xFFEC5B13),
      shape: RoundedRectangleBorder(side: BorderSide(width: 3)),
    ),

    
  
    // footer文字
    child: const Text(
      'APPNAME',
      style: TextStyle(
        color: const Color(0xFF0F172A),
        fontSize: 16,
        fontFamily: 'Noto Sans JP',
        fontWeight: FontWeight.w900,
        height: 1.50,
        letterSpacing: -0.40,
      ),
    ),

  );

}