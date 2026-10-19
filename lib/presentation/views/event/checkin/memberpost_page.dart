import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../common_layout.dart';
import '../../../../models/event_report.dart';
import '../../../../models/profile.dart';
import '../../../../widgets/return_button.dart';

class MemberPostPage extends StatelessWidget {
  final Profile profile;
  final EventReport report;
  final String groupId;
  final String eventId;
  final String eventTitle;
  final int myRole;

  const MemberPostPage({
    super.key,
    required this.profile,
    required this.report,
    required this.groupId,
    required this.eventId,
    required this.eventTitle,
    required this.myRole,
  });

  String _formatLocation(double? lat, double? lng) {
    if (lat == null || lng == null) return 'Unknown';
    return '${lat.toStringAsFixed(1)}, ${lng.toStringAsFixed(1)}';
  }

  String _formatTime(DateTime? time) {
    if (time != null) {
      return DateFormat('M/dd HH:mm').format(time);
    }
    return '--:--';
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = report.photoUrl;
    final lateReason = report.lateReason;
    final displayTime = _formatTime(report.actualWakeupTime);
    final displayLocation = _formatLocation(report.latitude, report.longitude);
    final avatarUrl = profile.avatarUrl;
    final nickname = profile.nickname.isNotEmpty ? profile.nickname : 'No name';

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
            ReturnButton(
              onTap: () {
                Navigator.pop(context);
                debugPrint('1画面戻る');
              },
            ),
            const SizedBox(height: 10),

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
                        return const Center(child: CircularProgressIndicator());
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoTag(Icons.location_on, displayLocation),
                _infoTag(Icons.alarm, 'WAKE-UP: $displayTime'),
              ],
            ),
            const SizedBox(height: 20),

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
