import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../presentation/views/event/checkin/memberpost_page.dart';
import '../../support/mock_data.dart';
import '../../support/preview_bootstrap.dart';

@Preview(name: 'MemberPostPage - late report')
Widget memberPostPagePreview() {
  return PreviewApp(
    child: MemberPostPage(
      profile: previewProfiles[1],
      report: previewReports[1],
      groupId: previewGroups[0].id,
      eventId: previewEvents[0].id,
      eventTitle: previewEvents[0].title,
      myRole: 0,
    ),
  );
}
