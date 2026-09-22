import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/event_report.dart';

abstract class MemberEventRepository {
  Future<EventReport?> getMyReport(String eventId);
  Stream<List<EventReport>> watchEventReports(String eventId);
  Future<void> setPlannedTimes({
    required String eventId,
    required DateTime wakeupTime,
    required DateTime departureTime,
  });
  Future<Map<String, dynamic>> reportWakeUp(String eventId);
  Future<Map<String, dynamic>> reportDeparture(String eventId);
  Future<Map<String, dynamic>> checkInWithQr(String eventId, String qrCode);
  Future<Map<String, dynamic>> checkInWithPasscode(String eventId, String passcode);
  Future<void> submitLateReport({
    required String eventId,
    required String reason,
    String? photoUrl,
    double? latitude,
    double? longitude,
  });
}

class SupabaseMemberEventRepository implements MemberEventRepository {
  final SupabaseClient _client;

  SupabaseMemberEventRepository(this._client);

  String? get _currentUserId => _client.auth.currentUser?.id;

  @override
  Future<EventReport?> getMyReport(String eventId) async {
    final uid = _currentUserId;
    if (uid == null) return null;

    final data = await _client
        .from('event_reports')
        .select()
        .eq('event_id', eventId)
        .eq('user_id', uid)
        .maybeSingle();

    if (data == null) return null;
    return EventReport.fromJson(data);
  }

  @override
  Stream<List<EventReport>> watchEventReports(String eventId) {
    // Supabase Realtime Stream 経由で対象イベントの全レポートを監視
    return _client
        .from('event_reports')
        .stream(primaryKey: ['id'])
        .eq('event_id', eventId)
        .map((rows) => rows.map((e) => EventReport.fromJson(e)).toList());
  }

  @override
  Future<void> setPlannedTimes({
    required String eventId,
    required DateTime wakeupTime,
    required DateTime departureTime,
  }) async {
    final uid = _currentUserId;
    if (uid == null) throw const AuthException('Not authenticated');

    await _client.from('event_reports').update({
      'planned_wakeup_time': wakeupTime.toIso8601String(),
      'planned_departure_time': departureTime.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('event_id', eventId).eq('user_id', uid);
  }

  @override
  Future<Map<String, dynamic>> reportWakeUp(String eventId) async {
    final res = await _client.rpc('report_wake_up', params: {
      'p_event_id': eventId,
    });
    return Map<String, dynamic>.from(res as Map);
  }

  @override
  Future<Map<String, dynamic>> reportDeparture(String eventId) async {
    final res = await _client.rpc('report_departure', params: {
      'p_event_id': eventId,
    });
    return Map<String, dynamic>.from(res as Map);
  }

  @override
  Future<Map<String, dynamic>> checkInWithQr(String eventId, String qrCode) async {
    final res = await _client.rpc('check_in_by_qr', params: {
      'p_event_id': eventId,
      'p_qrcode': qrCode,
    });
    return Map<String, dynamic>.from(res as Map);
  }

  @override
  Future<Map<String, dynamic>> checkInWithPasscode(String eventId, String passcode) async {
    final res = await _client.rpc('check_in_by_passcode', params: {
      'p_event_id': eventId,
      'p_passcode': passcode,
    });
    return Map<String, dynamic>.from(res as Map);
  }

  @override
  Future<void> submitLateReport({
    required String eventId,
    required String reason,
    String? photoUrl,
    double? latitude,
    double? longitude,
  }) async {
    final uid = _currentUserId;
    if (uid == null) throw const AuthException('Not authenticated');

    final updateData = <String, dynamic>{
      'late_reason': reason,
      'photo_url': photoUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (latitude != null && longitude != null) {
      updateData['location'] = '($latitude,$longitude)';
    }

    await _client
        .from('event_reports')
        .update(updateData)
        .eq('event_id', eventId)
        .eq('user_id', uid);
  }
}