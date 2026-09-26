import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alarm/alarm.dart';

import '../../widgets/statusbutton.dart';
import '../../utils/alarm_id.dart';

// エラー種別を型安全に管理するEnum
enum CheckInLoadError {
  notLoggedIn,     // 未ログイン
  notParticipant,  // 未参加メンバー
  fetchFailed,     // ネットワーク・RPC等の取得失敗
}

class MemberCheckInViewModel extends ChangeNotifier {
  final String eventId;
  String groupId;
  final SupabaseClient _supabase;

  List<Map<String, dynamic>> myGroups = [];

  String? _userId;
  String? _reportId;

  // Viewに公開する状態データたち
  String groupName = "Loading...";
  bool isParticipant = false; // 未選択ユーザーの操作制御フラグ
  bool isWakeUpPressed = false;
  bool isDeparturePressed = false;
  bool isCheckInPressed = false;
  StatusButtonType selectedStatus = StatusButtonType.sleeping;
  
  CheckInLoadError? loadError;
  String? errorMessage; // 1箇所に集約

  MemberCheckInViewModel({
    required this.eventId,
    required this.groupId,
    SupabaseClient? supabaseClient,
  }) : _supabase = supabaseClient ?? Supabase.instance.client;

  // 初期データおよび更新用データの取得
  Future<CheckInLoadError?> loadData() async {
    loadError = null;
    errorMessage = null;

    _userId = _supabase.auth.currentUser?.id;
    if (_userId == null) {
      loadError = CheckInLoadError.notLoggedIn;
      errorMessage = 'ログイン情報が見つかりません。再度ログインしてください。';
      notifyListeners();
      return loadError;
    }

    // 1. グループ一覧取得
    try {
      final groupsResponse = await _supabase
          .from('groups_memberships')
          .select('group_id, groups ( id, group_name )')
          .eq('user_id', _userId!);

      myGroups = (groupsResponse as List<dynamic>).map((item) {
        final g = item['groups'] as Map<String, dynamic>? ?? {};
        return {
          'group_id': item['group_id'] as String,
          'group_name': (g['group_name'] ?? 'Unnamed Group') as String,
        };
      }).toList();
    } catch (e) {
      debugPrint('Group load error: $e');
    }

    // 2. 選択グループ名取得
    try {
      final groupData = await _supabase
          .from('groups')
          .select('group_name')
          .eq('id', groupId)
          .maybeSingle();

      if (groupData != null) {
        groupName = groupData['group_name'] ?? 'Unknown Group';
      }
    } catch (e) {
      groupName = 'Error';
    }

    // 3. 自分のイベントレポートを取得
    Map<String, dynamic>? report;
    try {
      final res = await _supabase.rpc(
        'get_my_event_report',
        params: {'p_event_id': eventId},
      );
      if (res != null && res is Map<String, dynamic>) {
        report = Map<String, dynamic>.from(res);
        _reportId = report['id']?.toString();
        isParticipant = true;
      } else {
        // 未参加メンバー
        isParticipant = false;
        loadError = CheckInLoadError.notParticipant;
        errorMessage = 'あなたはこのイベントの参加者として登録されていません。';
      }
    } catch (e) {
      isParticipant = false;
      loadError = CheckInLoadError.fetchFailed;
      errorMessage = 'レポートの取得に失敗しました。';
      debugPrint('レポート取得エラー: $e');
    }

    if (report != null) {
      int currentStatus = (report['status'] as num?)?.toInt() ?? 0;

      isWakeUpPressed = report['actual_wakeup_time'] != null;
      isDeparturePressed = report['actual_departure_time'] != null;
      isCheckInPressed = (currentStatus == 4 || currentStatus == 5);

      switch (currentStatus) {
        case 1:
          selectedStatus = StatusButtonType.awake;
          break;
        case 2:
          selectedStatus = StatusButtonType.overslept;
          break;
        case 3:
          selectedStatus = StatusButtonType.moving;
          break;
        case 4:
        case 5:
          selectedStatus = StatusButtonType.arrived;
          break;
        case 0:
        default:
          selectedStatus = StatusButtonType.sleeping;
          break;
      }
    }

    notifyListeners();
    return loadError;
  }

  // 起床ボタン（RPC 経由で実行）
  Future<void> toggleWakeUp() async {
    if (!isParticipant || isWakeUpPressed) return;

    try {
      await Alarm.stop(getAlarmId(eventId, 'wakeup'));
    } catch (e) {
      debugPrint('Alarm stop error: $e');
    }

    try {
      final res = await _supabase.rpc(
        'report_wake_up',
        params: {'p_event_id': eventId},
      );

      if (res is Map<String, dynamic> && res['success'] == true) {
        isWakeUpPressed = true;
        notifyListeners();
        await loadData();
      }
    } catch (e) {
      debugPrint('起床記録RPCエラー: $e');
    }
  }

  // 出発ボタン（RPC 経由で実行）
  Future<void> toggleDeparture() async {
    if (!isParticipant || isDeparturePressed) return;

    try {
      await Alarm.stop(getAlarmId(eventId, 'departure'));
    } catch (e) {
      debugPrint('Alarm stop error: $e');
    }

    try {
      final res = await _supabase.rpc(
        'report_departure',
        params: {'p_event_id': eventId},
      );

      if (res is Map<String, dynamic> && res['success'] == true) {
        isDeparturePressed = true;
        notifyListeners();
        await loadData();
      }
    } catch (e) {
      debugPrint('出発記録RPCエラー: $e');
    }
  }

  // チェックイン承認（RPC 経由で実行）
  Future<bool> verifyAndCheckIn(String type, String value) async {
    if (!isParticipant || isCheckInPressed) return false;

    try {
      final functionName = (type == 'qrcode') ? 'check_in_by_qr' : 'check_in_by_passcode';
      final paramKey = (type == 'qrcode') ? 'p_qrcode' : 'p_passcode';

      final res = await _supabase.rpc(
        functionName,
        params: {
          'p_event_id': eventId,
          paramKey: value.trim(),
        },
      );

      if (res is Map<String, dynamic> && res['success'] == true) {
        isCheckInPressed = true;
        notifyListeners();
        await loadData();
        return true;
      }
    } catch (e) {
      debugPrint('チェックインRPCエラー: $e');
    }
    return false;
  }

  // レポートIDの取得（RPC経由）
  Future<String?> getOrCreateReportId() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return null;

    if (_reportId != null) return _reportId;

    try {
      final res = await _supabase.rpc(
        'get_my_event_report',
        params: {'p_event_id': eventId},
      );
      if (res != null && res is Map<String, dynamic>) {
        _reportId = res['id']?.toString();
        isParticipant = true;
        return _reportId;
      }
    } catch (e) {
      debugPrint('ReportId取得エラー: $e');
    }
    return null;
  }

  Future<void> updateGroupId(String newGroupId) async {
    groupId = newGroupId;
    await loadData();
  }
}
