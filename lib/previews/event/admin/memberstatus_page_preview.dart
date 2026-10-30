import 'package:flutter/widget_previews.dart';

import '../../../presentation/views/event/admin/memberstatus_page.dart';
import '../../support/mock_data.dart';
import '../../support/preview_bootstrap.dart';

@Preview(name: 'MemberStatusPage')
PreviewApp memberStatusPagePreview() {
  return PreviewApp(
    providers: previewProviders(),
    child: MemberStatusPage(
      groupId: previewGroups[0].id,
      eventId: previewEvents[0].id,
      eventTitle: previewEvents[0].title,
      myRole: 0,
      arrivalTime: '10/31 06:00',
      password: previewEvents[0].password ?? '',
      qrcodeId: previewEvents[0].qrcodeId ?? '',
    ),
  );
}
