import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/statusbutton.dart';
import '../../utils/alarm_id.dart';
import 'package:alarm/alarm.dart';

class MemberCheckInViewModel extends ChangeNotifier {
  final String eventId;
  String groupId;
  final SupabaseClient _supabase;

  List<Map<String, dynamic>> myGroups = [];

  String? _userId;
  String? _reportId;

  // Viewに公開する状態データたち
  String groupName = "Loading...";
  bool isWakeUpPressed = false;
  bool isDeparturePressed = false;
  bool isCheckInPressed = false;
  StatusButtonType selectedStatus = StatusButtonType.sleeping;
  String? errorMessage;

  MemberCheckInViewModel({
    required this.eventId,
    required this.groupId,
    SupabaseClient? supabaseClient,
  }) : _supabase = supabaseClient ?? Supabase.instance.client;

  // 初期データおよび更新用データの取得
  Future<String?> loadData() async {
    _userId = _supabase.auth.currentUser?.id;
    if (_userId == null) {
      errorMessage = 'ログイン情報が見つかりません。再度ログインしてください。';
      notifyListeners();
      return errorMessage;
    }

    // 1. ユーザーが所属するグループ一覧を取得
    try {
      final groupsResponse = await _supabase
          .from('group_members')
          .select('group_id, groups ( id, name )')
          .eq('user_id', _userId!);

      myGroups = (groupsResponse as List<dynamic>).map((item) {
        final g = item['groups'] as Map<String, dynamic>? ?? {};
        return {
          'group_id': item['group_id'] as String,
          'group_name': (g['name'] ?? 'Unnamed Group') as String,
        };
      }).toList();
    } catch (e) {
      debugPrint('Group load error: $e');
    }

    // 2. 現在選択されているグループ名を取得
    try {
      final groupData = await _supabase
          .from('groups')
          .select('name')
          .eq('id', groupId)
          .maybeSingle();

      if (groupData != null) {
        groupName = groupData['name'] ?? 'Unknown Group';
      }
    } catch (e) {
      groupName = 'Error';
    }
    // ここで一旦ビューを更新
    notifyListeners();

    // 3. 自分のイベントレポートを取得（なければ自動作成）
    Map<String, dynamic>? report;
    try {
      final existing = await _supabase
          .from('event_reports')
          .select()
          .eq('event_id', eventId)
          .eq('user_id', _userId!)
          .maybeSingle();

      if (existing == null) {
        final inserted = await _supabase
            .from('event_reports')
            .insert({
              'event_id': eventId,
              'user_id': _userId!,
              'status': 'sleeping',
            })
            .select()
            .single();
        report = Map<String, dynamic>.from(inserted);
      } else {
        report = Map<String, dynamic>.from(existing);
      }
      _reportId = report['id']?.toString() ?? report['report_id']?.toString();
    } catch (e) {
      debugPrint('レポート取得/作成エラー: $e');
    }

    if (report != null) {
      // ---- 新しいOverslept判定ロジック（Copilotのレビュー解決） ----
      String currentStatus = (report['status'] ?? 'sleeping').toString().toLowerCase();

      // 起床予定時間を過ぎているのに sleeping のままであれば overslept に変更する
      if (currentStatus == 'sleeping' && report['planned_wakeup_time'] != null) {
        try {
          final plannedWakeup = DateTime.parse(report['planned_wakeup_time'].toString());
          if (DateTime.now().isAfter(plannedWakeup) && _reportId != null) {
            await _supabase
                .from('event_reports')
                .update({'status': 'overslept'})
                .eq('id', _reportId!);
            currentStatus = 'overslept';
          }
        } catch (e) {
          debugPrint('寝坊ステータス更新失敗: $e');
        }
      }

      // ---- 以降は安全に同期的な変数更新を行う部分 ----
      isWakeUpPressed = report['actual_wakeup_time'] != null;
      isDeparturePressed = report['actual_departure_time'] != null;
      isCheckInPressed = (currentStatus == 'arrived');

      // StatusButtonType にマッピング
      switch (currentStatus) {
        case 'awake':
          selectedStatus = StatusButtonType.awake;
          break;
        case 'overslept':
        case 'late':
          selectedStatus = StatusButtonType.overslept;
          break;
        case 'moving':
          selectedStatus = StatusButtonType.moving;
          break;
        case 'arrived':
          selectedStatus = StatusButtonType.arrived;
          break;
        case 'sleeping':
        default:
          selectedStatus = StatusButtonType.sleeping;
          break;
      }

      // Viewへ変更を通知する（これがsetStateの代わりになる）
      notifyListeners();
    }
    return null;
  }

  // 起床ボタンのトグル
  Future<void> toggleWakeUp() async {
    if (_reportId == null || isWakeUpPressed) return;
    isWakeUpPressed = true;

    // 起床アラームを停止
    try {
      await Alarm.stop(getAlarmId(eventId, 'wakeup'));
    } catch (e) {
      debugPrint('Alarm stop error: $e');
    }

    try {
      await _supabase.from('event_reports').update({
        'actual_wakeup_time': DateTime.now().toIso8601String(),
        'status': 'awake',
      }).eq('id', _reportId!);
    } catch (e) {
      debugPrint('起床記録エラー: $e');
    }

    notifyListeners();
    await loadData();
  }

  // 出発ボタンのトグル
  Future<void> toggleDeparture() async {
    if (_reportId == null || isDeparturePressed) return;
    isDeparturePressed = true;

    // 出発アラームを停止
    try {
      await Alarm.stop(getAlarmId(eventId, 'departure'));
    } catch (e) {
      debugPrint('Alarm stop error: $e');
    }

    try {
      await _supabase.from('event_reports').update({
        'actual_departure_time': DateTime.now().toIso8601String(),
        'status': 'moving',
      }).eq('id', _reportId!);
    } catch (e) {
      debugPrint('出発記録エラー: $e');
    }

    notifyListeners(); // まずUIだけ反応させる
    await loadData();
  }

  // チェックイン承認とトグル
  // 成功したらtrue、失敗したらfalseを返す（View側でSnackBarを出すため）
  Future<bool> verifyAndCheckIn(String type, String value) async {
    if (_reportId == null || isCheckInPressed) return false;

    bool isValid = false;
    try {
      final eventData = await _supabase
          .from('events')
          .select('id, password, qrcode_id')
          .eq('id', eventId)
          .maybeSingle();

      if (eventData != null) {
        if (type == 'qrcode') {
          // QRには eventId または qrcode_id が格納されている想定
          isValid = (value == eventData['id'] || value == eventData['qrcode_id']);
        } else if (type == 'passcode') {
          isValid = (value.trim() == (eventData['password']?.toString().trim()));
        }
      }
    } catch (e) {
      debugPrint('チェックイン検証エラー: $e');
    }

    if (isValid) {
      isCheckInPressed = true;
      notifyListeners();

      try {
        await _supabase.from('event_reports').update({
          'actual_arrival_time': DateTime.now().toIso8601String(),
          'status': 'arrived',
        }).eq('id', _reportId!);
      } catch (e) {
        debugPrint('チェックインステータス更新エラー: $e');
      }

      await loadData();
      return true;
    }
    return false;
  }
  // 遅刻報告用のreportIdを取得または新規生成する（View側のRepository直接呼び出しを回避するためのMVVM移行）
  Future<String?> getOrCreateReportId() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return null;

    if (_reportId != null) return _reportId;

    try {
      final existing = await _supabase
          .from('event_reports')
          .select('id')
          .eq('event_id', eventId)
          .eq('user_id', uid)
          .maybeSingle();

      if (existing != null) {
        _reportId = existing['id'].toString();
        return _reportId;
      }

      final inserted = await _supabase
          .from('event_reports')
          .insert({
            'event_id': eventId,
            'user_id': uid,
            'status': 'sleeping',
          })
          .select('id')
          .single();

      _reportId = inserted['id'].toString();
      return _reportId;
    } catch (e) {
      debugPrint('ReportId取得エラー: $e');
      return null;
    }
  }

  Future<void> updateGroupId(String newGroupId) async {
    groupId = newGroupId;
    await loadData();
  }
}

