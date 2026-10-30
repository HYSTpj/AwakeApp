import 'package:flutter/widget_previews.dart';

import '../../presentation/views/event/event_selection_home_page.dart';
import '../support/mock_data.dart';
import '../support/preview_bootstrap.dart';

// 注意: このページは Supabase を直接呼び出す実装のため、プレビューは
// 未ログイン状態の初期表示のみとなる（グループ一覧・イベント一覧は
// 実データ取得に失敗し空/エラー状態で表示される）。
@Preview(name: 'EventSelectionHome')
PreviewApp eventSelectionHomePreview() {
  return PreviewApp(
    child: EventSelectionHome(
      groupId: previewGroups[0].id,
      groupName: previewGroups[0].groupName,
      myRole: 0,
    ),
  );
}
