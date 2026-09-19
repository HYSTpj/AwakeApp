import 'package:flutter/material.dart';
import '../data/event_data.dart'; // 💡 Implが定義されているファイルだけをインポート

class EditEventViewModel extends ChangeNotifier {
  // 👑 修正点：型を抽象クラスではなく「EventRepositoryImpl」に直接指定します！
  final EventRepositoryImpl _repository;
  
  bool isLoading = true;
  List<Map<String, dynamic>> allMembers = [];
  Set<String> selectedMembers = {};

  // 👑 これでも初期化エラーは100%綺麗に消えます！
  EditEventViewModel({EventRepositoryImpl? repository}) 
      : _repository = repository ?? EventRepositoryImpl();

  // Viewの代わりにデータをFirestoreから安全にロードする関数
  Future<void> loadInitialData(String groupId, String eventId) async {
    isLoading = true;
    notifyListeners();

    try {
      // 1. グループの全メンバーをリポジトリ経由でロード
      allMembers = await _repository.getGroupMembers(groupId);
      
      // 2. イベントドキュメントをリポジトリ経由でロード
      final eventData = await _repository.getEventById(eventId);
      final List<dynamic> participants = eventData?['participants'] ?? [];
      
      selectedMembers = participants.map((e) => e.toString()).toSet();
    } catch (e) {
      debugPrint('ViewModelデータ読込エラー: $e');
    } finally {
      isLoading = false;
      notifyListeners(); 
    }
  }

  // 参加者のトグル処理
  void toggleParticipant(String uid, bool isSelected) {
    if (isSelected) {
      selectedMembers.add(uid);
    } else {
      selectedMembers.remove(uid);
    }
    notifyListeners();
  }
}