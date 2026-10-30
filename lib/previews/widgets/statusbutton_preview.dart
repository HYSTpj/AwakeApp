import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../widgets/statusbutton.dart';

@Preview(name: 'StatusButton - all types')
Widget statusButtonPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: StatusButtonType.values
                .map(
                  (type) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: StatusButton(
                      type: type,
                      isSelected: type == StatusButtonType.awake,
                      onTap: () {},
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    ),
  );
}
