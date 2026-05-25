// Entity: アプリ内で扱う純粋なデータモデル
class GroupEntity {
  final String groupId;
  final String groupName;

  GroupEntity({
    required this.groupId,
    required this.groupName
  });

  @override
  String toString() => 'GroupEntity(groupId: $groupId, groupName: $groupName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupEntity &&
          runtimeType == other.runtimeType &&
          groupId == other.groupId &&
          groupName == other.groupName;

  @override
  int get hashCode => groupId.hashCode ^ groupName.hashCode;
}

// Interface: データの取得方法は知らず，何を取得するかだけを定義
abstract class GroupRepository{

  // dataファイルで設定した関数を取得
  /// グループを作成し、管理者を追加する
  Future<String?> setGroup({
    required String userId,
    required String groupName
  });

  /// ユーザーを既存のグループに追加する
  Future<void> addGroup({
    required String userId,
    required String groupId
  });

  /// ユーザーをグループから削除する
  Future<void> deleteGroup({
    required String userId,
    required String groupId
  });

  /// ユーザーが所属するグループの一覧を取得する
  Future<List<GroupEntity>> getGroups(String userId);

  /// グループ名が存在するか確認する
  Future<bool> isGroupNameExists(String groupName);
}