import 'package:flutter/widget_previews.dart';

import '../../../presentation/views/event/checkin/late_report_page.dart';
import '../../support/mock_data.dart';
import '../../support/preview_bootstrap.dart';

// 注意: LateReportViewModel は生成時に Geolocator で現在地を取得しようと
// するため、Widget Preview 環境では権限/プラグイン未対応により
// "LOCATION ERROR" 表示のまま初期状態が続く場合がある。
@Preview(name: 'LateReportPage')
PreviewApp lateReportPagePreview() {
  return PreviewApp(
    child: LateReportPage(
      reportId: previewReports[1].id,
      eventId: previewEvents[0].id,
    ),
  );
}
