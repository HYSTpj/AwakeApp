// Firestoreからデータベースを取得するためのパッケージ
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/group_entity.dart';

// groups ドキュメント
class GroupRepositoryImpl implements GroupRepository {
  final _db = FirebaseFirestore.instance;

  @override
  // グループ作成
  Future<String?> setGroup({
    required String userId,
    required String groupName
  }) async {
    final group = _db.collection('groups').doc();
    final String invitationCode = group.id; // 自動生成されたドキュメントid

    // 2.グループ作成
    await group.set({
      'group_name': groupName,
      'invitation_code': invitationCode,
      'created_at': FieldValue.serverTimestamp(), // Googleサーバーの正確な時間を取得
    });

    // groups_membershipsに管理者登録
    await _db.collection('groups_memberships').add({
      'group_id': group.id,
      'user_id': userId,
      'role': 0,
      'joined_at': FieldValue.serverTimestamp(),
    });
    return group.id;
  }
  // 3.グループ作成完了


  @override
  // グループ参加
  // 6.グループID存在するかチェック
  Future<void> addGroup({
    required String userId,
    required String groupId
  }) async {
    final group = await _db.collection("groups").doc(groupId).get();
    if (!group.exists) {
      throw StateError("Group does not exist: $groupId");
    }
    await _db.collection("groups_memberships").add({
      'group_id': groupId,
      'user_id': userId,
      'role': 1,
      'joined_at': FieldValue.serverTimestamp(),
    });
  }
  // 8.参加完了


  @override
  // グループ脱退
  Future<void> deleteGroup({
    required String userId,
    required String groupId
  }) async {
    final membership = await _db
      .collection("groups_memberships")
      .where("group_id", isEqualTo: groupId)
      .where("user_id", isEqualTo: userId)
      .get();

    if (membership.docs.isEmpty) {
      throw StateError("Membership not found for userId=$userId, groupId=$groupId");
    }
    final docId = membership.docs.first.id; // 上記で見つけた空出ないドキュメントidを指定
  
    await _db
      .collection("groups_memberships")
      .doc(docId)
      .delete();
  }


  @override
  // 所属グループ一覧
  Future<List<GroupEntity>> getGroups(String userId) async {
    final groups = await _db // membershipsから指定されたuidと同じものの中身を調べる
      .collection("groups_memberships")
      .where("user_id", isEqualTo: userId)
      .get();

    List<GroupEntity> myGroups = [];
    for (var doc in groups.docs) {
      final groupId = doc.data()['group_id']; // groups_membership内に自分のuser_idが存在するgroup_idを取得
      final groupDoc = await _db.collection('groups').doc(groupId).get(); // groups内のgroup_idが一致するものの中身を調べる

      if (groupDoc.exists) {
        final data = groupDoc.data()!;  // 中身が絶対あるgroupのデータ取得

        // APIデータをEntityに変換
        myGroups.add(GroupEntity(
          groupId: groupDoc.id,
          groupName: data['group_name'] ?? 'No Name',
        ));
      }
    }
    return myGroups;
  }
}