import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../presentation/views/profile/profile_page.dart';

@Preview(name: 'ProfilePage')
Widget profilePagePreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ProfilePage(),
  );
}
