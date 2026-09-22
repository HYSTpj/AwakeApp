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

    // 1. groups 作成
    final groupData = await _client
        .from('groups')
        .insert({
          'group_name': groupName,
          'invitation_code': code,
        })
        .select()
        .single();

    final newGroup = Group.fromJson(groupData, role: 0);

    // 2. 作成者を管理者 (role = 0) としてメンバーシップに追加
    await _client.from('groups_memberships').insert({
      'group_id': newGroup.id,
      'user_id': uid,
      'role': 0, // Admin
    });

    return newGroup;
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
  Future<void> leaveOrDeleteGroup(String groupId) async {
    final uid = _currentUserId;
    if (uid == null) throw const AuthException('Not authenticated');

    final role = await getRole(groupId);

    if (role == 0) {
      // 管理者の場合はグループ自体を削除（CASCADEにより全関連データ削除）
      await _client.from('groups').delete().eq('id', groupId);
    } else {
      // 一般メンバーの場合は自身の所属レコードを削除（脱退）
      await _client
          .from('groups_memberships')
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', uid);
    }
  }

  String _generateInvitationCode({int length = 6}) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // 誤読しやすい0/O, 1/Iを除外
    final rand = Random();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }
}