import 'package:flutter/widget_previews.dart';

import '../../presentation/views/group/group_list_page.dart';
import '../support/preview_bootstrap.dart';

@Preview(name: 'GroupListPage')
PreviewApp groupListPagePreview() {
  return PreviewApp(
    providers: previewProviders(),
    child: const GroupListPage(),
  );
}
