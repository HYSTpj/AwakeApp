import 'package:flutter/widget_previews.dart';

import '../../../presentation/viewmodels/set_time_viewmodel.dart';
import '../../../presentation/views/event/schedule/set_time_page.dart';
import '../../support/mock_data.dart';
import '../../support/mock_repositories.dart';
import '../../support/preview_bootstrap.dart';

@Preview(name: 'SetTimePage (schedule)')
PreviewApp setTimePagePreview() {
  // viewModel を直接注入し、Supabase への実アクセス（loadTime 等）を避ける。
  final viewModel = SetTimeViewModel(
    eventId: previewEvents[0].id,
    repository: MockMemberEventRepository(),
  )
    ..setWakeupTime(previewEvents[0].arrivalTime.subtract(const Duration(hours: 1)))
    ..setDepartureTime(previewEvents[0].arrivalTime.subtract(const Duration(minutes: 30)));

  return PreviewApp(
    child: SetTimePage(
      groupId: previewGroups[0].id,
      eventId: previewEvents[0].id,
      eventTitle: previewEvents[0].title,
      myRole: 1,
      arrivalTime: previewEvents[0].arrivalTime,
      viewModel: viewModel,
    ),
  );
}
