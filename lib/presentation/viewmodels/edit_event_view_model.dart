import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/admin_event_repository.dart';
import '../../models/profile.dart';

class EditEventViewModel extends ChangeNotifier {
  final AdminEventRepository _repository;

  bool isLoading = true;
  List<Profile> allMembers = [];
  Set<String> selectedMembers = {};
  bool hasError = false;

  EditEventViewModel({AdminEventRepository? repository})
      : _repository = repository ??
            SupabaseAdminEventRepository(Supabase.instance.client);

  // 初期データ読み込み
  Future<void> loadInitialData(String groupId, String eventId) async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      allMembers = await _repository.getGroupMembers(groupId);
      final participantIds = await _repository.getEventParticipantIds(eventId);
      selectedMembers = participantIds.toSet();
    } catch (e) {
      debugPrint('ViewModelデータ読込エラー: $e');
      hasError = true; // 💡 エラー状態を記録
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 参加者の選択/解除トグル
  void toggleParticipant(String uid, bool isSelected) {
    if (isSelected) {
      selectedMembers.add(uid);
    } else {
      selectedMembers.remove(uid);
    }
    notifyListeners();
  }

  // イベント更新処理
  Future<void> updateEvent({
    required String eventId,
    required String title,
    required String destinationName,
    required DateTime arrivalTime,
  }) async {
    if (hasError) {
      throw Exception('データの読み込みに失敗しているため保存できません');
    }
    await _repository.updateEventDetails(
      eventId: eventId,
      title: title,
      destinationName: destinationName,
      arrivalTime: arrivalTime,
      participantUserIds: selectedMembers.toList(),
    );
  }
}