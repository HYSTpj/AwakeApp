import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../presentation/views/event/schedule/save_changes_page.dart';
import '../../support/mock_data.dart';
import '../../support/preview_bootstrap.dart';

@Preview(name: 'SaveChangesPage')
Widget saveChangesPagePreview() {
  final arrival = previewEvents[0].arrivalTime;
  return PreviewApp(
    child: SaveChangesPage(
      eventId: previewEvents[0].id,
      wakeupTime: arrival.subtract(const Duration(hours: 1)),
      departureTime: arrival.subtract(const Duration(minutes: 30)),
      arrivalTime: arrival,
    ),
  );
}
