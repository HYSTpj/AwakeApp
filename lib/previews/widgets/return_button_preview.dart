import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../widgets/return_button.dart';

@Preview(name: 'ReturnButton')
Widget returnButtonPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: ReturnButton(onTap: () {}),
      ),
    ),
  );
}
