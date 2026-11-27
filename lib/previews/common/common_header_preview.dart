import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../presentation/views/common/app_mode.dart';
import '../../presentation/views/common/common_header.dart';
import '../support/preview_bootstrap.dart';

@Preview(name: 'CommonHeader - Admin')
PreviewApp commonHeaderAdminPreview() {
  return const PreviewApp(
    child: Scaffold(body: CommonHeader(mode: AppMode.admin)),
  );
}

@Preview(name: 'CommonHeader - Member')
PreviewApp commonHeaderMemberPreview() {
  return const PreviewApp(
    child: Scaffold(body: CommonHeader(mode: AppMode.member)),
  );
}
