import 'package:flutter/widget_previews.dart';

import '../../presentation/views/login/login_page.dart';
import '../support/preview_bootstrap.dart';

@Preview(name: 'LoginPage')
PreviewApp loginPagePreview() {
  return PreviewApp(
    providers: previewProviders(),
    child: const LoginPage(),
  );
}
