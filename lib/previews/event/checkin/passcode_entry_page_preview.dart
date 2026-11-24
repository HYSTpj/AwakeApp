import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../presentation/views/event/checkin/passcode_entry_page.dart';
import '../../support/mock_data.dart';
import '../../support/preview_bootstrap.dart';

@Preview(name: 'PasscodeEntryPage')
Widget passcodeEntryPagePreview() {
  return PreviewApp(
    child: PasscodeEntryPage(
      groupId: previewGroups[0].id,
      eventId: previewEvents[0].id,
      eventTitle: previewEvents[0].title,
      myRole: 1,
    ),
  );
}
