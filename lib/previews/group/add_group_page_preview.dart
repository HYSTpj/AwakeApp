import 'package:flutter/widget_previews.dart';

import '../../presentation/views/group/add_group_page.dart';
import '../support/preview_bootstrap.dart';

@Preview(name: 'AddGroupPage')
PreviewApp addGroupPagePreview() {
  return PreviewApp(
    providers: previewProviders(),
    child: const AddGroupPage(),
  );
}
