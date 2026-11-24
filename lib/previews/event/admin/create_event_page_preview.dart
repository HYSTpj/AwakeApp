import 'package:flutter/widget_previews.dart';

import '../../../presentation/views/event/admin/create_event_page.dart';
import '../../support/mock_data.dart';
import '../../support/preview_bootstrap.dart';

// 注意: GoogleMap は Web/デスクトップでは API キー未設定のため
// 地図タイルが表示されない場合がある。レイアウト確認用として作成。
@Preview(name: 'CreateEventPage')
PreviewApp createEventPagePreview() {
  return PreviewApp(
    child: CreateEventPage(groupId: previewGroups[0].id, myRole: 0),
  );
}
