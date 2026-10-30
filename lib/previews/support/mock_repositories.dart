// Widget Preview 専用のリポジトリ実装。
// 実際の Supabase へは一切アクセスせず、mock_data.dart の固定サンプルを返す。
import 'dart:io';

import '../../data/repositories/admin_event_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/repositories/member_event_repository.dart';
import '../../data/repositories/ranking_repository.dart';
import '../../models/event.dart';
import '../../models/event_member_status.dart';
import '../../models/event_report.dart';
import '../../models/group.dart';
import '../../models/profile.dart';
import '../../models/ranking_user.dart';
import 'mock_data.dart';

class MockGroupRepository implements GroupRepository {
  @override
  Future<List<Group>> getGroups() async => previewGroups;

  @override
  Future<int?> getRole(String groupId) async =>
      previewGroups.firstWhere((g) => g.id == groupId, orElse: () => previewGroups.first).role;

  @override
  Future<Group> createGroup(String groupName) async => Group(
        id: 'preview-group-new',
        groupName: groupName,
        invitationCode: 'NEW00000',
        createdAt: DateTime.now(),
        role: 0,
      );

  @override
  Future<bool> joinGroupByCode(String invitationCode) async => true;

  @override
  Future<void> leaveOrDeleteGroup(String groupId) async {}
}

class MockAuthRepository implements AuthRepository {
  @override
  String? get currentUserId => previewProfiles.first.id;

  @override
  Future<Profile> signUp({required String email, required String password}) async =>
      previewProfiles.first;

  @override
  Future<Profile> signIn({required String email, required String password}) async =>
      previewProfiles.first;

  @override
  Future<void> signOut() async {}

  @override
  Future<Profile?> getCurrentProfile() async => previewProfiles.first;

  @override
  Future<void> resetPassword({required String email}) async {}

  @override
  Future<Profile> updateProfile({required String nickname, File? avatarImage}) async =>
      Profile(
        id: previewProfiles.first.id,
        nickname: nickname,
        avatarUrl: previewProfiles.first.avatarUrl,
        sleepPastCount: previewProfiles.first.sleepPastCount,
        lateCount: previewProfiles.first.lateCount,
        createdAt: previewProfiles.first.createdAt,
        updatedAt: DateTime.now(),
      );
}

class MockAdminEventRepository implements AdminEventRepository {
  @override
  Future<List<Event>> getEvents(String groupId) async => previewEvents;

  @override
  Future<List<Profile>> getGroupMembers(String groupId) async => previewProfiles;

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
  }) async => previewEvents.first.id;

  @override
  Future<List<EventMemberStatus>> getEventMemberStatuses(String eventId) async =>
      previewMemberStatuses;

  @override
  Future<EventReport?> getMemberReport({
    required String eventId,
    required String userId,
  }) async =>
      previewReports.firstWhere(
        (r) => r.userId == userId,
        orElse: () => previewReports.first,
      );
}

class MockMemberEventRepository implements MemberEventRepository {
  @override
  Future<EventReport?> getMyReport(String eventId) async => previewReports.first;

  @override
  Stream<List<EventReport>> watchEventReports(String eventId) =>
      Stream.value(previewReports);

  @override
  Future<void> setPlannedTimes({
    required String eventId,
    required DateTime wakeupTime,
    required DateTime departureTime,
  }) async {}

  @override
  Future<Map<String, dynamic>> reportWakeUp(String eventId) async =>
      {'success': true, 'message': '起床を記録しました（プレビュー）'};

  @override
  Future<Map<String, dynamic>> reportDeparture(String eventId) async =>
      {'success': true, 'message': '出発を記録しました（プレビュー）'};

  @override
  Future<Map<String, dynamic>> checkInWithQr(String eventId, String qrCode) async =>
      {'success': true, 'message': 'チェックインしました（プレビュー）'};

  @override
  Future<Map<String, dynamic>> checkInWithPasscode(String eventId, String passcode) async =>
      {'success': true, 'message': 'チェックインしました（プレビュー）'};

  @override
  Future<void> submitLateReport({
    required String eventId,
    required String reason,
    String? photoUrl,
    double? latitude,
    double? longitude,
  }) async {}
}

class MockRankingRepository implements RankingRepository {
  @override
  Future<void> completeEvent(String eventId) async {}

  @override
  Stream<String> watchEventStatus(String eventId) => Stream.value('active');

  @override
  Future<List<RankingUser>> getLateRankings(String groupId) async => previewRankingUsers;

  @override
  Future<List<RankingUser>> getOversleptRankings(String groupId) async =>
      previewRankingUsers.reversed.toList();
}
