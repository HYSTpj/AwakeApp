import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../presentation/views/member_settime_page.dart';
import 'support/mock_data.dart';
import 'support/preview_bootstrap.dart';

@Preview(name: 'SetTimePage (member_settime_page)')
Widget memberSetTimePagePreview() {
  return PreviewApp(
    child: SetTimePage(
      groupId: previewGroups[0].id,
      eventId: previewEvents[0].id,
      eventTitle: previewEvents[0].title,
      myRole: 0,
      arrivalTime: previewEvents[0].arrivalTime,
      initialMembers: [
        MemberSetTimeViewData(
          memberName: previewProfiles[0].nickname,
          wakeUpTime: const TimeOfDay(hour: 5, minute: 0),
          leaveHomeTime: const TimeOfDay(hour: 5, minute: 30),
          arrivalTime: const TimeOfDay(hour: 6, minute: 0),
        ),
        MemberSetTimeViewData(
          memberName: previewProfiles[1].nickname,
          wakeUpTime: const TimeOfDay(hour: 5, minute: 15),
          leaveHomeTime: const TimeOfDay(hour: 5, minute: 45),
          arrivalTime: const TimeOfDay(hour: 6, minute: 0),
        ),
      ],
    ),
  );
}
