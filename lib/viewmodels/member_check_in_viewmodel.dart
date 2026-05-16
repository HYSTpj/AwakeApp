import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/event_repository.dart';
import '../widgets/statusbutton.dart';

class MemberCheckInViewModel extends ChangeNotifier {
  final String eventId;
  String groupId;
  final EventRepository _eventRepository;

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
    EventRepository? eventRepository,
  }) : _eventRepository = eventRepository ?? EventRepository();

  // 初期データおよび更新用データの取得
  Future<String?> loadData() async {
    _userId = FirebaseAuth.instance.currentUser?.uid;
    if (_userId == null) {
      errorMessage = 'ログイン情報が見つかりません。再度ログインしてください。';
      notifyListeners();
      return errorMessage;
    }

    try {
      final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
      if (groupDoc.exists) {
        groupName = groupDoc.data()?['group_name'] ?? 'Unknown Group';
      }
    } catch (e) {
      groupName = 'Error';
    }
    // ここで一旦ビューを更新
    notifyListeners();

    var report = await _eventRepository.getEventReport(eventId, _userId!);
    if (report == null) {
      _reportId = await _eventRepository.createReportIfNotExist(eventId, _userId!);
      report = await _eventRepository.getEventReport(eventId, _userId!);
    } else {
      _reportId = report['report_id'];
    }

    if (report != null) {
      // ---- 新しいOverslept判定ロジック（Copilotのレビュー解決） ----
      int currentStatus = report['status'] as int? ?? 0;

      // 起床予定時間を過ぎているのにSleepingのままであればOversleptに変更する
      if (currentStatus == 0) {
        final plannedWakeup = report['planned_wakeup_time'];
        if (plannedWakeup != null && plannedWakeup is Timestamp) {
          if (DateTime.now().isAfter(plannedWakeup.toDate())) {
            if (_reportId != null) {
              try {
                await _eventRepository.updateOversleptStatus(_reportId!);
                currentStatus = 2; // 更新成功ならローカル変数も書き換える
              } catch (e) {
                debugPrint('寝坊ステータス更新失敗: $e');
              }
            }
          }
        }
      }

      // ---- 以降は安全に同期的な変数更新を行う部分 ----
      isWakeUpPressed = report['actual_wakeup_time'] != null;
      isDeparturePressed = report['actual_departure_time'] != null;
      isCheckInPressed = (currentStatus >= 4);

      if (currentStatus == 1) {
        selectedStatus = StatusButtonType.awake;
      } else if (currentStatus == 0) {
        selectedStatus = StatusButtonType.sleeping;
      } else if (currentStatus == 2) {
        selectedStatus = StatusButtonType.overslept;
      } else if (currentStatus == 3) {
        selectedStatus = StatusButtonType.moving;
      } else if (currentStatus >= 4) {
        selectedStatus = StatusButtonType.arrived;
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
    notifyListeners(); // まずUIだけ反応させる
    
    await _eventRepository.updateWakeupTime(_reportId!);
    await loadData();
  }

  // 出発ボタンのトグル
  Future<void> toggleDeparture() async {
    if (_reportId == null || isDeparturePressed) return;
    isDeparturePressed = true;
    notifyListeners(); // まずUIだけ反応させる
    
    await _eventRepository.updateDepartureTime(_reportId!);
    await loadData();
  }

  // チェックイン承認とトグル
  // 成功したらtrue、失敗したらfalseを返す（View側でSnackBarを出すため）
  Future<bool> verifyAndCheckIn(String type, String value) async {
    if (_reportId == null || isCheckInPressed) return false;

    bool isValid = false;
    if (type == 'qrcode') {
      isValid = await _eventRepository.verifyEventQRCode(eventId, value);
    } else if (type == 'passcode') {
      isValid = await _eventRepository.verifyEventPassword(eventId, value);
    }

    if (isValid) {
      isCheckInPressed = true;
      notifyListeners();
      await _eventRepository.updateCheckInStatus(_reportId!);
      await loadData();
      return true;
    }
    return false;
  }
  
  Future<void> updateGroupId(String newGroupId) async {
    groupId = newGroupId;
    await loadData();
  }
}
