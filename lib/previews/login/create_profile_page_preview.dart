import 'package:flutter/widget_previews.dart';

import '../../presentation/views/login/create_profile_page.dart';
import '../support/preview_bootstrap.dart';

@Preview(name: 'CreateAccountProfile')
PreviewApp createAccountProfilePreview() {
  return PreviewApp(
    providers: previewProviders(),
    child: const CreateAccountProfile(),
  );
}
