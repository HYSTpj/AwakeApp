// Widget Preview 専用のサンプルデータ。
// 実際の Supabase データを参照せず、全プレビューファイルから再利用する。
import '../../models/event.dart';
import '../../models/event_member_status.dart';
import '../../models/event_report.dart';
import '../../models/group.dart';
import '../../models/profile.dart';
import '../../models/ranking_user.dart';

final previewCreatedAt = DateTime(2026, 1, 1, 9, 0);

final previewGroups = <Group>[
  Group(
    id: 'preview-group-1',
    groupName: '朝活チームA',
    invitationCode: 'ABC12345',
    createdAt: previewCreatedAt,
    role: 0,
  ),
  Group(
    id: 'preview-group-2',
    groupName: '登山サークル',
    invitationCode: 'XYZ98765',
    createdAt: previewCreatedAt,
    role: 1,
  ),
  Group(
    id: 'preview-group-3',
    groupName: '通勤友の会',
    invitationCode: 'QWE24680',
    createdAt: previewCreatedAt,
    role: 1,
  ),
];

final previewProfiles = <Profile>[
  Profile(
    id: 'user-1',
    nickname: 'たろう',
    avatarUrl: null,
    sleepPastCount: 2,
    lateCount: 1,
    createdAt: previewCreatedAt,
    updatedAt: previewCreatedAt,
  ),
  Profile(
    id: 'user-2',
    nickname: 'はなこ',
    avatarUrl: null,
    sleepPastCount: 0,
    lateCount: 3,
    createdAt: previewCreatedAt,
    updatedAt: previewCreatedAt,
  ),
  Profile(
    id: 'user-3',
    nickname: 'けんじ',
    avatarUrl: null,
    sleepPastCount: 5,
    lateCount: 0,
    createdAt: previewCreatedAt,
    updatedAt: previewCreatedAt,
  ),
];

final previewEvents = <Event>[
  Event(
    id: 'preview-event-1',
    groupId: previewGroups[0].id,
    title: '早朝ハイキング',
    destinationName: '高尾山口駅',
    latitude: 35.6325,
    longitude: 139.2730,
    qrcodeId: 'preview-qr-token',
    password: '1234',
    arrivalTime: previewCreatedAt.add(const Duration(days: 1, hours: 6)),
    status: 'active',
    createdAt: previewCreatedAt,
    updatedAt: previewCreatedAt,
  ),
  Event(
    id: 'preview-event-2',
    groupId: previewGroups[0].id,
    title: '始発ミーティング',
    destinationName: '東京駅',
    latitude: 35.6812,
    longitude: 139.7671,
    qrcodeId: 'preview-qr-token-2',
    password: '5678',
    arrivalTime: previewCreatedAt.add(const Duration(days: 2, hours: 7)),
    status: 'active',
    createdAt: previewCreatedAt,
    updatedAt: previewCreatedAt,
  ),
];

final previewReports = <EventReport>[
  EventReport(
    id: 'preview-report-1',
    eventId: previewEvents[0].id,
    userId: previewProfiles[0].id,
    plannedWakeupTime: previewCreatedAt.add(const Duration(hours: 5)),
    plannedDepartureTime: previewCreatedAt.add(const Duration(hours: 5, minutes: 30)),
    actualWakeupTime: previewCreatedAt.add(const Duration(hours: 5, minutes: 5)),
    actualDepartureTime: null,
    status: EventReport.statusAwake,
    updatedAt: previewCreatedAt,
  ),
  EventReport(
    id: 'preview-report-2',
    eventId: previewEvents[0].id,
    userId: previewProfiles[1].id,
    status: EventReport.statusLate,
    lateReason: '電車が遅延しました',
    photoUrl: null,
    latitude: 35.6325,
    longitude: 139.2730,
    updatedAt: previewCreatedAt,
  ),
  EventReport(
    id: 'preview-report-3',
    eventId: previewEvents[0].id,
    userId: previewProfiles[2].id,
    status: EventReport.statusSleeping,
    updatedAt: previewCreatedAt,
  ),
];

final previewMemberStatuses = <EventMemberStatus>[
  EventMemberStatus(profile: previewProfiles[0], report: previewReports[0]),
  EventMemberStatus(profile: previewProfiles[1], report: previewReports[1]),
  EventMemberStatus(profile: previewProfiles[2], report: previewReports[2]),
];

final previewRankingUsers = <RankingUser>[
  RankingUser(
    id: previewProfiles[1].id,
    nickname: previewProfiles[1].nickname,
    sleepPastCount: previewProfiles[1].sleepPastCount,
    lateCount: previewProfiles[1].lateCount,
  ),
  RankingUser(
    id: previewProfiles[0].id,
    nickname: previewProfiles[0].nickname,
    sleepPastCount: previewProfiles[0].sleepPastCount,
    lateCount: previewProfiles[0].lateCount,
  ),
  RankingUser(
    id: previewProfiles[2].id,
    nickname: previewProfiles[2].nickname,
    sleepPastCount: previewProfiles[2].sleepPastCount,
    lateCount: previewProfiles[2].lateCount,
  ),
];
