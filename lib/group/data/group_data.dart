// Firestoreからデータベースを取得するためのパッケージ
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/group_entity.dart';

// groups ドキュメント
class GroupRepositoryImpl implements GroupRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  // グループ作成
  Future<String?> setGroup({
    required String userId,
    required String groupName,
  }) async {
    // 処理前チェック
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    if (groupName.isEmpty) {
      throw ArgumentError('Group name cannot be empty');
    }

    try {
      final group = _db.collection('groups').doc();
      final String groupId = group.id; // 自動生成されたドキュメントid
      final String invitationCode = groupId;

      await group.set({
        'group_name': groupName,
        'invitation_code': invitationCode,
        'created_at': FieldValue.serverTimestamp(),
      });

      await _db.collection('groups_memberships').add({
        'group_id': groupId,
        'user_id': userId,
        'role': 0, // 管理者ロール
        'joined_at': FieldValue.serverTimestamp(),
      });
      return groupId;
    } catch (e) {
      throw Exception('Failed to create group: $e');
    }
  }

  @override
  // グループ参加
  Future<void> addGroup({
    required String userId,
    required String groupId,
  }) async {
    // 処理前チェック
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    if (groupId.isEmpty) {
      throw ArgumentError('Group ID cannot be empty');
    }

    try {
      final group = await _db.collection('groups').doc(groupId).get();
      if (!group.exists) {
        throw StateError('Group does not exist: $groupId');
      }

      await _db.collection('groups_memberships').add({
        'group_id': groupId,
        'user_id': userId,
        'role': 1, // メンバー
        'joined_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to join group: $e');
    }
  }

  @override
  // グループ脱退
  Future<void> deleteGroup({
    required String userId,
    required String groupId,
  }) async {
    // 処理前チェック
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    if (groupId.isEmpty) {
      throw ArgumentError('Group ID cannot be empty');
    }

    try {
      final membership = await _db
          .collection('groups_memberships')
          .where('group_id', isEqualTo: groupId)
          .where('user_id', isEqualTo: userId)
          .get();

      if (membership.docs.isEmpty) {
        throw StateError('Membership not found for userId=$userId, groupId=$groupId');
      }

      final docId = membership.docs.first.id;
      await _db.collection('groups_memberships').doc(docId).delete();
    } catch (e) {
      throw Exception('Failed to leave group: $e');
    }
  }

  @override
  // 所属グループ一覧
  Future<List<GroupEntity>> getGroups(String userId) async {
    // 処理前チェック
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    try {
      final groups = await _db
          .collection('groups_memberships')
          .where('user_id', isEqualTo: userId)
          .get();

      final groupIds = groups.docs.map((doc) => doc.data()['group_id'] as String).toList();

      if (groupIds.isEmpty) return [];

      final List<GroupEntity> result = [];
      for (int i = 0; i < groupIds.length; i += 10) {
        final end = (i + 10 < groupIds.length) ? i + 10 : groupIds.length;
        final batchIds = groupIds.sublist(i, end);

        final groupDocs = await _db
            .collection('groups')
            .where(FieldPath.documentId, whereIn: batchIds)
            .get();

        result.addAll(groupDocs.docs.map((doc) {
          final data = doc.data();
          return GroupEntity(
            groupId: doc.id,
            groupName: data['group_name'] ?? 'No Name',
          );
        }));
      }

      return result;
    } catch (e) {
      throw Exception('Failed to retrieve groups: $e');
    }
  }
}