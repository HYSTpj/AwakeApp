import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/group.dart';

abstract class GroupRepository {
  Future<List<Group>> getGroups();
  Future<int?> getRole(String groupId);
  Future<Group> createGroup(String groupName);
  Future<bool> joinGroupByCode(String invitationCode);
  Future<void> leaveOrDeleteGroup(String groupId);
}

class SupabaseGroupRepository implements GroupRepository {
  final SupabaseClient _client;

  SupabaseGroupRepository(this._client);

  String? get _currentUserId => _client.auth.currentUser?.id;

  @override
  Future<List<Group>> getGroups() async {
    final uid = _currentUserId;
    if (uid == null) return [];

    // 所属グループおよび自身の role を JOIN して取得
    final response = await _client
        .from('groups_memberships')
        .select('role, groups ( id, group_name, invitation_code, created_at )')
        .eq('user_id', uid);

    final list = <Group>[];
    for (final item in response) {
      final groupData = item['groups'] as Map<String, dynamic>?;
      if (groupData != null) {
        list.add(Group.fromJson(groupData, role: item['role'] as int?));
      }
    }
    return list;
  }

  @override
  Future<int?> getRole(String groupId) async {
    final uid = _currentUserId;
    if (uid == null) return null;

    final data = await _client
        .from('groups_memberships')
        .select('role')
        .eq('group_id', groupId)
        .eq('user_id', uid)
        .maybeSingle();

    return data?['role'] as int?;
  }

  @override
  Future<Group> createGroup(String groupName) async {
    final uid = _currentUserId;
    if (uid == null) throw const AuthException('Not authenticated');

    final code = _generateInvitationCode();

    // RPC (create_group_with_admin) を呼び出してグループ作成とAdmin登録をアトミックに実行
    final res = await _client.rpc(
      'create_group_with_admin',
      params: {
        'p_group_name': groupName,
        'p_invitation_code': code,
      },
    );

    if (res is! Map<String, dynamic> || res['success'] != true) {
      throw const PostgrestException(message: 'Failed to create group via RPC');
    }

    // RPCから返ってきた group オブジェクトを利用
    final groupData = Map<String, dynamic>.from(res['group'] as Map);
    return Group.fromJson(groupData, role: 0);
  }

  @override
  Future<bool> joinGroupByCode(String invitationCode) async {
    final res = await _client.rpc(
      'join_group_by_code',
      params: {'p_invitation_code': invitationCode.trim()},
    );

    if (res is Map<String, dynamic> && res['success'] == true) {
      return true;
    }
    return false;
  }

  @override
  Future<void> leaveOrDeleteGroup(String invitationCode) async {
    final uid = _currentUserId;
    if (uid == null) throw const AuthException('Not authenticated');

    final code = invitationCode.trim();

    // 招待コードからグループを特定
    final groupRecord = await _client
        .from('groups')
        .select('id')
        .eq('invitation_code', code)
        .maybeSingle();

    if (groupRecord == null) {
      throw const PostgrestException(message: '該当するグループが見つかりません');
    }

    final targetGroupId = groupRecord['id'] as String;
    final role = await getRole(targetGroupId);

    if (role == 0) {
      // 管理者ならグループごと削除
      await _client.from('groups').delete().eq('id', targetGroupId);
    } else {
      // メンバーなら脱退
      await _client
          .from('groups_memberships')
          .delete()
          .eq('group_id', targetGroupId)
          .eq('user_id', uid);
    }
  }

  // 暗号学的に安全な乱数生成器を使用し長さを8桁に強化
  String _generateInvitationCode({int length = 8}) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }
}