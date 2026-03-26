// Firestoreからデータベースを取得するためのパッケージ
import 'package:cloud_firestore/cloud_firestore.dart';

// groups ドキュメント
class GroupRepository {
  final _db = FirebaseFirestore.instance;

  // グループ作成
  Future<String?> setGroup({
    required String id,
    required String group_name
  }) async {
    final group = _db.collection('groups').doc();
    final String invitationCode = group.id; // 自動生成されたドキュメントid

    // 2.グループ作成
    await group.set({
      'group_name': group_name,
      'invitation_code': invitationCode,
      'created_at': FieldValue.serverTimestamp(), // Googleサーバーの正確な時間を取得
    });

    // groups_membershipsに管理者登録
    await _db.collection('groups_memberships').add({
      'group_id': group.id,
      'user_id': id,
      'role': 0,
      'joined_at': FieldValue.serverTimestamp(),
    });
    return group.id;
  }
  // 3.グループ作成完了


  // グループ参加
  // 6.グループID存在するかチェック
  Future<void> addGroup({
    required String id,
    required String group_id
  }) async {
    final group = await _db.collection("groups").doc(group_id).get();
    if (group.exists) {
      await _db.collection("groups_memberships").add({
        'group_id': group.id,
        'user_id': id,
        'role': 1,
        'joined_at': FieldValue.serverTimestamp(),
      });
    }
  }
  // 8.参加完了


  // 管理者に招待
  // 11.メンバーリストの取得
  Future<List<Map<String, dynamic>>> getMembers(String group_id) async {
    final members = await _db // membershipsから指定されたgroup_idと同じものの中身を調べる
      .collection("groups_memberships")
      .where("group_id", isEqualTo: group_id)
      .get();
    
    List<Map<String, dynamic>> ourMembers = [];
    for (var doc in members.docs) {
      final userId = doc.data()['user_id'];
      final userDoc = await _db.collection('profiles').doc(userId).get(); // prifiles内のuser_idが一致するものの中身を調べる

      if (userDoc.exists) {
        final data = userDoc.data()!;  // 中身が絶対あるprofilesのデータ取得
        ourMembers.add(data);
      }
    }
    return ourMembers;
  }

  // 14.管理者リストに追加
  Future<void> changeRole({
    required String id,
    required String group_id,
    required int role
  }) async {
    final role = await _db
      .collection("groups_memberships")
      .where("group_id", isEqualTo: group_id)
      .where("user_id", isEqualTo: id)
      .get();

    if (role.docs.isNotEmpty) {
      final docId = role.docs.first.id; // 上記で見つけた空出ないドキュメントidを指定
    
      await _db
        .collection("groups_memberships")
        .doc(docId)
        .update({
          "role": role,
        });
    }
  }


  // 所属グループ一覧
  Future<List<Map<String, dynamic>>> getGroups(String user_id) async {
    final groups = await _db // membershipsから指定されたuidと同じものの中身を調べる
      .collection("groups_memberships")
      .where("user_id", isEqualTo: user_id)
      .get();

    List<Map<String, dynamic>> myGroups = [];
    for (var doc in groups.docs) {
      final groupId = doc.data()['group_id']; // groups_membership内に自分のuser_idが存在するgroup_idを取得
      final groupDoc = await _db.collection('groups').doc(groupId).get(); // groups内のgroup_idが一致するものの中身を調べる

      if (groupDoc.exists) {
        final data = groupDoc.data()!;  // 中身が絶対あるgroupのデータ取得
        myGroups.add(data);
      }
    }
    return myGroups;
  }


  // グループ脱退
  Future<void> deleteGroup({
    required String id,
    required String group_id
  }) async {
    final membership = await _db
      .collection("groups_memberships")
      .where("group_id", isEqualTo: group_id)
      .where("user_id", isEqualTo: id)
      .get();

    if (membership.docs.isNotEmpty) {
      final docId = membership.docs.first.id; // 上記で見つけた空出ないドキュメントidを指定
    
      await _db
        .collection("groups_memberships")
        .doc(docId)
        .delete();
    }
  }
}
