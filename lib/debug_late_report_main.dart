// 遅刻投稿画面(LateReportPage)のUIを単体で確認するためのデバッグ用エントリーポイント。
// グループ作成〜チェックインの手順を踏まずに直接画面を開ける。
//
// 実行方法:
//   flutter run -t lib/debug_late_report_main.dart \
//     --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
//
// 「SUBMIT LATE REPORT」を実際に送信する場合は、下記の reportId/eventId を
// Supabase 上に実在する値に差し替え、かつログイン済みである必要がある。
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/env_config.dart';
import 'presentation/views/event/checkin/late_report_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    publishableKey: EnvConfig.supabaseAnonKey,
  );

  runApp(const DebugLateReportApp());
}

class DebugLateReportApp extends StatelessWidget {
  const DebugLateReportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LateReportPage(
        reportId: 'debug-report-id',
        eventId: 'debug-event-id',
      ),
    );
  }
}
