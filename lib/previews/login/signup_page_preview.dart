import 'package:flutter/widget_previews.dart';

import '../../presentation/views/login/signup_page.dart';
import '../support/preview_bootstrap.dart';

@Preview(name: 'CreateAccountPage (signup)')
PreviewApp signupPagePreview() {
  return PreviewApp(
    providers: previewProviders(),
    child: const CreateAccountPage(),
  );
}
