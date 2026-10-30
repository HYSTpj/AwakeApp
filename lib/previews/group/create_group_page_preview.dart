import 'package:flutter/widget_previews.dart';

import '../../presentation/views/group/create_group_page.dart';
import '../support/preview_bootstrap.dart';

@Preview(name: 'CreateGroupPage')
PreviewApp createGroupPagePreview() {
  return PreviewApp(
    providers: previewProviders(),
    child: const CreateGroupPage(),
  );
}
