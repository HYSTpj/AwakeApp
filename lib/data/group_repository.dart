// Firestoreからデータベースを取得するためのパッケージ
import 'package:cloud_firestore/cloud_firestore.dart';

// groups ドキュメント
class GroupRepository {
  final _db = FirebaseFirestore.instance;

  // グループ作成
  Future<String?> setGroup({
    required String uid,
    required String groupName
  }) async {
    final invitationCode = "123456";  // 一旦適当におく
    final group = _db.collection('groups').doc();

    // 2.グループ作成
    await group.set({
      'group_name': groupName,
      'invitation_code': invitationCode,
      'created_at': FieldValue.serverTimestamp(), // Googleサーバーの正確な時間を取得
    });

    // groups_membershipsに管理者登録
    await _db.collection('groups_memberships').add({
      'group_id': group.id,
      'user_id': uid,
      'role': 0,
      'joined_at': FieldValue.serverTimestamp(),
    });
    return group.id;
  }
  // 3.グループ作成完了


  // グループ参加
  // 6.グループID存在するかチェック
  Future<void> addGroup({
    required String uid,
    required String groupId
  }) async {
    final group = await _db.collection("groups").doc(groupId).get();
    if (group.exists) {
      await _db.collection("groups_memberships").add({
        'group_id': group.id,
        'user_id': uid,
        'role': 1,
        'joined_at': FieldValue.serverTimestamp(),
      });
    }
  }
  // 8.参加完了


  // 管理者に招待
  // 11.メンバーリストの取得
  Future<List<Map<String, dynamic>>> getMembers(String groupId) async {
    final members = await _db // membershipsから指定されたgroup_idと同じものの中身を調べる
      .collection("groups_memberships")
      .where("group_id", isEqualTo: groupId)
      .get();
    
    return members.docs.map((doc) => doc.data()).toList();  // map => 1つずつ取り出して形を変える
    /*
    [
      {"user_id": "userA", "role": 0, "joined_at": ...},
      {"user_id": "userB", "role": 1, "joined_at": ...},
    ]
    というようなリストの戻り値となるから，user_idリストを取り出したい場合は

    final members = await GroupRepository().getMembers("グループID");
    // 1番目の人のIDを取り出す場合
      String id = members[0]["user_id"];
    // 全員のIDを画面に出す場合
      for (var m in members) {
        print(m["user_id"]);
      }
    */
  }

  // 14.管理者リストに追加
  Future<void> changeRole({
    required String uid,
    required String groupId,
    required String newRole
  }) async {
    final role = await _db
      .collection("groups_memberships")
      .where("group_id", isEqualTo: groupId)
      .where("user_id", isEqualTo: uid)
      .get();

    if (role.docs.isNotEmpty) {
      final docId = role.docs.first.id; // 上記で見つけた空出ないドキュメントidを指定
    
      await _db
        .collection("groups_memberships")
        .doc(docId)
        .update({
          "role": newRole,
        });
    }
  }
}
