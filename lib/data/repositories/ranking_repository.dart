import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/ranking_user.dart';

abstract class RankingRepository {
  Future<void> completeEvent(String eventId);
  Stream<String> watchEventStatus(String eventId);
  Future<List<RankingUser>> getLateRankings(String groupId);
  Future<List<RankingUser>> getOversleptRankings(String groupId);
}

class SupabaseRankingRepository implements RankingRepository {
  final SupabaseClient _client;

  SupabaseRankingRepository(this._client);

  @override
  Future<void> completeEvent(String eventId) async {
    await _client.from('events').update({
      'status': 'completed',
      'update_at': DateTime.now().toIso8601String(),
    }).eq('id', eventId);
  }

  @override
  Stream<String> watchEventStatus(String eventId) {
    // events テーブルの Realtime 更新を購読して終了ステータスを即時検知
    return _client
        .from('events')
        .stream(primaryKey: ['id'])
        .eq('id', eventId)
        .map((rows) {
          if (rows.isEmpty) return 'active';
          return rows.first['status'] as String? ?? 'active';
        });
  }

  @override
  Future<List<RankingUser>> getLateRankings(String groupId) async {
    // グループ所属メンバーの profile を結合取得
    final data = await _client
        .from('groups_memberships')
        .select('profiles ( id, nickname, avatar_url, sleep_past_count, late_count )')
        .eq('group_id', groupId);

    final users = _mapProfiles(data);
    // JOIN 先テーブルに対する order() の制約を避けるため、クライアント側で降順ソート
    users.sort((a, b) => b.lateCount.compareTo(a.lateCount));
    return users;
  }

  @override
  Future<List<RankingUser>> getOversleptRankings(String groupId) async {
    final data = await _client
        .from('groups_memberships')
        .select('profiles ( id, nickname, avatar_url, sleep_past_count, late_count )')
        .eq('group_id', groupId);

    final users = _mapProfiles(data);
    users.sort((a, b) => b.sleepPastCount.compareTo(a.sleepPastCount));
    return users;
  }

  List<RankingUser> _mapProfiles(List<dynamic> data) {
    final list = <RankingUser>[];
    for (final item in data) {
      final p = item['profiles'] as Map<String, dynamic>?;
      if (p != null) {
        list.add(RankingUser.fromJson(p));
      }
    }
    return list;
  }
}