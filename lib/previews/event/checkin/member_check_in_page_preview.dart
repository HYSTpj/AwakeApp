import 'package:flutter/widget_previews.dart';

import '../../../presentation/views/event/checkin/member_check_in_page.dart';
import '../../support/mock_data.dart';
import '../../support/preview_bootstrap.dart';

// 注意: MemberCheckInViewModel は Supabase を直接呼び出す実装のため、
// 未ログイン状態では読み込み直後に「ログインが必要です」という
// SnackBar を出して Navigator.pop() する（PreviewWithBackStack で
// クラッシュせず戻れるようにしている）。実データでの動作確認は
// 別途ログイン状態を伴う環境で行うこと。
@Preview(name: 'MemberCheckInPage')
PreviewApp memberCheckInPagePreview() {
  return PreviewApp(
    child: PreviewWithBackStack(
      child: MemberCheckInPage(
        eventId: previewEvents[0].id,
        eventTitle: previewEvents[0].title,
        groupId: previewGroups[0].id,
        groupName: previewGroups[0].groupName,
        myRole: 1,
      ),
    ),
  );
}
