import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../presentation/views/common/app_mode.dart';
import '../../presentation/views/common/common_footer.dart';

@Preview(name: 'CommonFooter - Admin')
Widget commonFooterAdminPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: Color(0xFFF8F6F6),
      bottomNavigationBar: SafeArea(child: CommonFooter(mode: AppMode.admin)),
    ),
  );
}

@Preview(name: 'CommonFooter - Member')
Widget commonFooterMemberPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: Color(0xFFF8F6F6),
      bottomNavigationBar:
          SafeArea(child: CommonFooter(mode: AppMode.member)),
    ),
  );
}
