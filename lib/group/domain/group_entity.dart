// Entity: アプリ内で扱う純粋なデータモデル
class GroupEntity {
  final String groupId;
  final String groupName;

  GroupEntity({
    required this.groupId,
    required this.groupName
  });
}

// Interface: データの取得方法は知らず，何を取得するかだけを定義
abstract class GroupRepository{

  // dataファイルで設定した関数を取得
  Future<String?> setGroup({
    required String userId,
    required String groupName
  });

  Future<void> addGroup({
    required String userId,
    required String groupId
  });

  Future<void> deleteGroup({
    required String userId,
    required String groupId
  });

  Future<List<GroupEntity>> getGroups(String userId);
}