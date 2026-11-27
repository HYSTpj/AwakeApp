import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/ranking_user.dart';

abstract class RankingRepository {
  Future<void> completeEvent(String eventId);
  Stream<String> watchEventStatus(String eventId);
  Future<List<RankingUser>> getGroupRankings(String groupId);
}

class SupabaseRankingRepository implements RankingRepository {
  final SupabaseClient _client;

  SupabaseRankingRepository(this._client);

  @override
  Future<void> completeEvent(String eventId) async {
    final updatedRows = await _client
        .from('events')
        .update({
          'status': 'completed',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', eventId)
        .select('id');

    if (updatedRows.isEmpty) {
      throw StateError('Event not found or permission denied: $eventId');
    }
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
  Future<List<RankingUser>> getGroupRankings(String groupId) async {
    final data = await _client.rpc(
      'get_group_rankings',
      params: {'p_group_id': groupId},
    );

    if (data is! List) {
      throw const FormatException('Invalid group ranking response');
    }

    final users = data.map((row) {
      if (row is! Map) {
        throw const FormatException('Invalid group ranking row');
      }
      return RankingUser.fromJson(Map<String, dynamic>.from(row));
    }).toList();

    users.sort((a, b) {
      final delayOrder = b.totalDelayMinutes.compareTo(a.totalDelayMinutes);
      return delayOrder != 0
          ? delayOrder
          : a.nickname.toLowerCase().compareTo(b.nickname.toLowerCase());
    });
    return users;
  }
}
