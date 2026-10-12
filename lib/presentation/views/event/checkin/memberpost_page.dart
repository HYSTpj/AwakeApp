import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../common_layout.dart';
import '../../../../models/event_report.dart';
import '../../../../widgets/return_button.dart';

class MemberPostPage extends StatelessWidget {
  final Map<String, dynamic> member;
  final dynamic report; // EventReport インスタンス または Map<String, dynamic> の両方を受け入れ可能
  final String groupId;
  final String eventId;
  final String eventTitle;
  final int myRole;

  const MemberPostPage({
    super.key,
    required this.member,
    required this.report,
    required this.groupId,
    required this.eventId,
    required this.eventTitle,
    required this.myRole,
  });

  EventReport? get _parsedReport {
    if (report is EventReport) {
      return report as EventReport;
    }
    if (report is Map<String, dynamic>) {
      try {
        return EventReport.fromJson(report as Map<String, dynamic>);
      } catch (e) {
        debugPrint('EventReportパースエラー: $e');
      }
    }
    return null;
  }

  String _formatLocation(dynamic location) {
    if (location == null) return 'Unknown';

    try {
      if (location is String) {
        final clean = location.replaceAll('(', '').replaceAll(')', '').trim();
        final parts = clean.split(',');
        if (parts.length == 2) {
          final lat = double.tryParse(parts[0].trim());
          final lng = double.tryParse(parts[1].trim());
          if (lat != null && lng != null) {
            return '${lat.toStringAsFixed(1)}, ${lng.toStringAsFixed(1)}';
          }
        }
        return location;
      }
    } catch (e) {
      debugPrint('位置情報変換エラー: $e');
    }
    return location.toString();
  }

  String _formatTime(DateTime? time, dynamic rawFallback) {
    if (time != null) {
      return DateFormat('M/dd HH:mm').format(time);
    }
    if (rawFallback is String) {
      final parsed = DateTime.tryParse(rawFallback);
      if (parsed != null) {
        return DateFormat('M/dd HH:mm').format(parsed);
      }
    }
    return '--:--';
  }

  @override
  Widget build(BuildContext context) {
    final parsed = _parsedReport;

    // EventReport がある場合はそこから、ない場合は Map から取得
    final String? photoUrl = parsed?.photoUrl ?? (report is Map ? report['photo_url'] : null);
    final String? lateReason = parsed?.lateReason ?? (report is Map ? report['late_reason'] : null);
    final dynamic rawLocation = report is Map ? report['location'] : null;
    final DateTime? wakeupTime = parsed?.actualWakeupTime;
    final dynamic rawWakeupTime = report is Map ? report['actual_wakeup_time'] : null;

    final displayTime = _formatTime(wakeupTime, rawWakeupTime);

    final avatarUrl = member['avatar_url'] as String?;
    final nickname = member['nickname'] as String? ?? 'No name';

    return CommonLayout(
      groupId: groupId,
      eventId: eventId,
      eventTitle: eventTitle,
      myRole: myRole,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // 戻るボタン
            ReturnButton(
              onTap: () {
                Navigator.pop(context);
                debugPrint('1画面戻る');
              },
            ),

            const SizedBox(height: 10),
            // ユーザー情報（アイコンと名前）
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 15),
                Text(
                  nickname,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 証拠写真
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                color: Colors.white,
              ),
              child: (photoUrl != null && photoUrl.isNotEmpty)
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.error));
                      },
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'No Image',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            // 起きた時間と場所
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoTag(
                  Icons.location_on,
                  _formatLocation(rawLocation),
                ),
                _infoTag(Icons.alarm, 'WAKE-UP: $displayTime'),
              ],
            ),
            const SizedBox(height: 20),

            // 遅刻理由（LATE REASON）
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LATE REASON',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    (lateReason != null && lateReason.isNotEmpty)
                        ? lateReason
                        : 'The reason is not entered.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(0),
        color: Colors.grey[300],
      ),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}