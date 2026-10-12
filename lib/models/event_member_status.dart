import 'package:flutter/foundation.dart';
import 'event_report.dart';
import 'profile.dart'; // 既存の Profile モデルを再利用

@immutable
class EventMemberStatus {
  final Profile profile;
  final EventReport? report;

  const EventMemberStatus({
    required this.profile,
    this.report,
  });

  /// レポートがない場合のステータスは 0: sleeping 扱い
  int get currentStatus => report?.status ?? 0;

  factory EventMemberStatus.fromJson(Map<String, dynamic> json) {
    // profiles テーブルの結合結果をパース
    final profileData = json['profiles'] as Map<String, dynamic>? ?? json;
    final profile = Profile.fromJson(profileData);

    // event_reports テーブルの結合結果をパース
    final reportData = json['event_reports'] as Map<String, dynamic>? ??
        (json.containsKey('status') ? json : null);
    final report = reportData != null ? EventReport.fromJson(reportData) : null;

    return EventMemberStatus(
      profile: profile,
      report: report,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventMemberStatus &&
          runtimeType == other.runtimeType &&
          profile.id == other.profile.id &&
          report == other.report;

  @override
  int get hashCode => Object.hash(profile.id, report);
}