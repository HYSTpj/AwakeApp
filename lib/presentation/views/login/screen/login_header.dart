import 'package:flutter/material.dart';

Widget myHeader(BuildContext context) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.only(
      top: MediaQuery.of(context).padding.top,
      bottom: 12,
    ),
    decoration: const BoxDecoration(
      color: Color(0xFFEC5B13),
      border: Border(
        bottom: BorderSide(
          color: Colors.black,
          width: 2,
        ),
      ),
    ),
    child: const Text(
      'AWAKE',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 16,
        fontFamily: 'Noto Sans JP',
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}