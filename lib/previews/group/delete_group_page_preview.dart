import 'package:flutter/widget_previews.dart';

import '../../presentation/views/group/delete_group_page.dart';
import '../support/preview_bootstrap.dart';

@Preview(name: 'DeleteGroupPage')
PreviewApp deleteGroupPagePreview() {
  return PreviewApp(
    providers: previewProviders(),
    child: const DeleteGroupPage(),
  );
}
