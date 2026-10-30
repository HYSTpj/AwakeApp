import 'package:flutter/widget_previews.dart';

import '../../../presentation/views/event/admin/select_participants_page.dart';
import '../../support/mock_data.dart';
import '../../support/preview_bootstrap.dart';

@Preview(name: 'SelectParticipantsPage')
PreviewApp selectParticipantsPagePreview() {
  final event = previewEvents[0];
  return PreviewApp(
    providers: previewProviders(),
    child: SelectParticipantsPage(
      groupId: previewGroups[0].id,
      title: event.title,
      destinationName: event.destinationName,
      latitude: event.latitude,
      longitude: event.longitude,
      arrivalTime: event.arrivalTime,
      password: event.password ?? '',
      myRole: 0,
    ),
  );
}
