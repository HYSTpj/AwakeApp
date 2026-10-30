import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../presentation/views/event/checkin/qr_scanner_page.dart';
import '../../support/mock_data.dart';
import '../../support/preview_bootstrap.dart';

// 注意: mobile_scanner はカメラ権限/ネイティブカメラに依存するため、
// Widget Preview 環境（ブラウザ/デスクトップ）ではカメラ映像は表示されず
// エラー表示のままになる場合がある。レイアウト確認用として作成。
@Preview(name: 'QRScannerPage')
Widget qrScannerPagePreview() {
  return PreviewApp(
    child: QRScannerPage(
      groupId: previewGroups[0].id,
      eventId: previewEvents[0].id,
      eventTitle: previewEvents[0].title,
      myRole: 1,
    ),
  );
}
