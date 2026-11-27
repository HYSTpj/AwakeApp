import 'package:flutter/foundation.dart';
import 'event_report.dart';
import 'profile.dart';

@immutable
class EventMemberStatus {
  final Profile profile;
  final EventReport? report;

  const EventMemberStatus({required this.profile, this.report});

  /// レポート未提出時は 0（sleeping）を返す
  static const int sleepingStatus = 0;

  int get currentStatus => report?.status ?? sleepingStatus;

  factory EventMemberStatus.fromJson(Map<String, dynamic> json) {
    final profileData = json['profiles'] as Map<String, dynamic>? ?? json;
    final profile = Profile.fromJson(profileData);

    final reportData =
        json['event_reports'] as Map<String, dynamic>? ??
        (json.containsKey('status') ? json : null);
    final report = reportData != null ? EventReport.fromJson(reportData) : null;

    return EventMemberStatus(profile: profile, report: report);
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
