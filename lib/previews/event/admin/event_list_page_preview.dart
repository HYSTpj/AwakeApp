import 'package:flutter/widget_previews.dart';

import '../../../presentation/views/event/admin/event_list_page.dart';
import '../../support/mock_data.dart';
import '../../support/preview_bootstrap.dart';

@Preview(name: 'EventListPage - admin')
PreviewApp eventListPagePreview() {
  return PreviewApp(
    providers: previewProviders(),
    child: EventListPage(groupId: previewGroups[0].id, myRole: 0),
  );
}
