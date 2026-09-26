import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/event.dart';
import '../../models/profile.dart';

abstract class AdminEventRepository {
  Future<List<Event>> getEvents(String groupId);
  Future<List<Profile>> getGroupMembers(String groupId);
  Future<String> createEventWithParticipants({
    required String groupId,
    required String title,
    required String destinationName,
    double? latitude,
    double? longitude,
    required String qrcodeId,
    required String password,
    required DateTime arrivalTime,
    required List<String> participantUserIds,
  });
}

class SupabaseAdminEventRepository implements AdminEventRepository {
  final SupabaseClient _client;

  SupabaseAdminEventRepository(this._client);

  @override
  Future<List<Event>> getEvents(String groupId) async {
    // 管理者専用RPC経由で qrcode_id / password を含めて安全に取得
    final res = await _client.rpc(
      'get_admin_events',
      params: {'p_group_id': groupId},
    );

    if (res is List<dynamic>) {
      return res
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<List<Profile>> getGroupMembers(String groupId) async {
    // groups_memberships 経由で対象グループのメンバー Profiles を JOIN 取得
    final data = await _client
        .from('groups_memberships')
        .select('profiles ( id, nickname, avatar_url, sleep_past_count, late_count, created_at, updated_at )')
        .eq('group_id', groupId);

    final members = <Profile>[];
    for (final item in data) {
      final p = item['profiles'] as Map<String, dynamic>?;
      if (p != null) {
        members.add(Profile.fromJson(p));
      }
    }
    return members;
  }

  @override
  Future<String> createEventWithParticipants({
    required String groupId,
    required String title,
    required String destinationName,
    double? latitude,
    double? longitude,
    required String qrcodeId,
    required String password,
    required DateTime arrivalTime,
    required List<String> participantUserIds,
  }) async {
    // イベント作成と参加者の初期レポート生成 (status: sleeping) を一括で行う RPC を実行
    final res = await _client.rpc('create_event_with_participants', params: {
      'p_group_id': groupId,
      'p_title': title,
      'p_destination_name': destinationName,
      'p_latitude': latitude,
      'p_longitude': longitude,
      'p_qrcode_id': qrcodeId,
      'p_password': password,
      'p_arrival_time': arrivalTime.toIso8601String(),
      'p_participant_ids': participantUserIds,
    });

    if (res is Map<String, dynamic> && res['success'] == true) {
      return res['event_id'] as String;
    }
    throw const PostgrestException(message: 'Failed to create event');
  }
}