import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'qrcode_page.dart';
import '../checkin/memberpost_page.dart';
import '../../../../models/event_member_status.dart';
import '../../../../presentation/viewmodels/admin_event_view_model.dart';

class MemberStatusPage extends StatefulWidget {
  final String groupId;
  final String eventId;
  final String eventTitle;
  final int myRole;
  final String arrivalTime;
  final String password;
  final String qrcodeId;

  const MemberStatusPage({
    super.key,
    required this.groupId,
    required this.eventId,
    required this.eventTitle,
    required this.myRole,
    required this.arrivalTime,
    required this.password,
    required this.qrcodeId,
  });

  @override
  State<MemberStatusPage> createState() => _MemberStatusPageState();
}

class _MemberStatusPageState extends State<MemberStatusPage> {
  int? selectedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminEventViewModel>().loadEventMemberStatuses(
        widget.eventId,
      );
    });
  }

  @override
  void didUpdateWidget(MemberStatusPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.eventId != widget.eventId) {
      setState(() {
        selectedFilter = null;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AdminEventViewModel>().loadEventMemberStatuses(
          widget.eventId,
        );
      });
    }
  }

  Widget _statusButton(
    String label,
    IconData icon,
    Color iconColor,
    int? filterValue,
  ) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: SizedBox(
        height: 40,
        width: 126,
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              selectedFilter = filterValue;
            });
            debugPrint('$labelを表示');
          },
          icon: Icon(icon, color: iconColor, size: 10),
          label: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
              side: const BorderSide(color: Colors.black, width: 1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberList(AdminEventState state) {
    if (state.statusesError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
            const SizedBox(height: 8),
            Text(
              '参加状況の取得に失敗しました\n${state.statusesError}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                context.read<AdminEventViewModel>().loadEventMemberStatuses(
                  widget.eventId,
                );
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('再試行'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5C00),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    final List<EventMemberStatus> eventMembers = state.memberStatuses;

    final List<EventMemberStatus> filterMembers = selectedFilter == null
        ? eventMembers
        : eventMembers.where((m) => m.currentStatus == selectedFilter).toList();

    if (filterMembers.isEmpty) {
      return const Center(child: Text('No members match this status.'));
    }

    return ListView.builder(
      key: ValueKey(selectedFilter),
      itemCount: filterMembers.length,
      itemBuilder: (context, index) {
        final memberStatus = filterMembers[index];
        final profile = memberStatus.profile;
        final int status = memberStatus.currentStatus;

        Color statusColor;
        String statusText;

        switch (status) {
          case 0:
            statusColor = Colors.grey;
            statusText = 'SLEEPING';
            break;
          case 1:
            statusColor = Colors.greenAccent;
            statusText = 'AWAKE';
            break;
          case 2:
            statusColor = Colors.pinkAccent;
            statusText = 'OVERSLEPT';
            break;
          case 3:
            statusColor = Colors.lightBlueAccent;
            statusText = 'MOVING';
            break;
          case 4:
            statusColor = Colors.orangeAccent;
            statusText = 'ARRIVED';
            break;
          case 5:
            statusColor = Colors.redAccent;
            statusText = 'ARRIVED (LATE)';
            break;
          default:
            statusColor = Colors.grey;
            statusText = 'SLEEPING';
            break;
        }

        return GestureDetector(
          onTap: state.isLoadingMemberReport
              ? null
              : () async {
                  final String memberId = profile.id;
                  final viewModel = context.read<AdminEventViewModel>();
                  // 非同期処理の前に Navigator と ScaffoldMessenger を退避
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  try {
                    await viewModel.loadMemberReport(
                      eventId: widget.eventId,
                      userId: memberId,
                    );

                    if (!mounted) return;

                    final currentState = viewModel.state;

                    if (currentState.memberReportError != null) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            'レポート取得に失敗しました: ${currentState.memberReportError}',
                          ),
                        ),
                      );
                      return;
                    }

                    final isTargetState =
                        currentState.selectedReportEventId == widget.eventId &&
                        currentState.selectedReportUserId == memberId;

                    final latestReport = currentState.selectedMemberReport;

                    final isValidReportData =
                        latestReport != null &&
                        latestReport.eventId == widget.eventId &&
                        latestReport.userId == memberId;

                    if (isTargetState && isValidReportData) {
                      navigator.push(
                        MaterialPageRoute(
                          builder: (_) => MemberPostPage(
                            profile: profile,
                            report: latestReport,
                            groupId: widget.groupId,
                            eventId: widget.eventId,
                            eventTitle: widget.eventTitle,
                            myRole: widget.myRole,
                          ),
                        ),
                      );
                      debugPrint('ポスト画面へ移動');
                    } else if (isTargetState && latestReport == null) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('There are no posts yet.'),
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint('個別レポート取得エラー: $e');
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text('レポート取得中にエラーが発生しました: $e')),
                      );
                    }
                  }
                },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              color: Colors.white,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage:
                      (profile.avatarUrl != null &&
                          profile.avatarUrl!.isNotEmpty)
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
                  child:
                      (profile.avatarUrl == null || profile.avatarUrl!.isEmpty)
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    profile.nickname.isNotEmpty ? profile.nickname : 'No name',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        color: statusColor,
                      ),
                      child: Text(
                        statusText,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminEventViewModel>();
    final state = viewModel.state;

    // 画面整合性ガード：選択中イベントIDが一致し、読み込み中でない場合のみ表示
    final isMatchingEvent = state.selectedEventId == widget.eventId;
    final isLoading = state.isLoadingStatuses || !isMatchingEvent;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<EventMemberStatus> eventMembers = state.memberStatuses;
    final int all = eventMembers.length;
    final int arrived = eventMembers
        .where((m) => m.currentStatus == 4 || m.currentStatus == 5)
        .length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: SizedBox(
            height: 80,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QrcodePage(
                      groupId: widget.groupId,
                      eventId: widget.eventId,
                      eventTitle: widget.eventTitle,
                      myRole: widget.myRole,
                      arrivalTime: widget.arrivalTime,
                      password: widget.password,
                      qrcodeId: widget.qrcodeId,
                    ),
                  ),
                );
                debugPrint('QRコード表示ページへ移動');
              },
              icon: const Icon(Icons.qr_code_2, color: Colors.black, size: 25),
              label: const Text(
                'SHOW QR CODE',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                  side: const BorderSide(color: Colors.black, width: 3),
                ),
              ),
            ),
          ),
        ),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              _statusButton(
                'ALL MEMBERS',
                Icons.filter_list,
                Colors.deepOrangeAccent,
                null,
              ),
              _statusButton('0: SLEEPING', Icons.circle, Colors.grey, 0),
              _statusButton('1: AWAKE', Icons.circle, Colors.greenAccent, 1),
              _statusButton('2: OVERSLEPT', Icons.circle, Colors.pinkAccent, 2),
              _statusButton(
                '3: MOVING',
                Icons.circle,
                Colors.lightBlueAccent,
                3,
              ),
              _statusButton('4: ARRIVED', Icons.circle, Colors.orangeAccent, 4),
              _statusButton(
                '5: LATE ARRIVED',
                Icons.circle,
                Colors.redAccent,
                5,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              const Text(
                "MEMBER'S STATUS",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.deepOrangeAccent,
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Text(
                  '$arrived / $all arrived',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(child: _buildMemberList(state)),
      ],
    );
  }
}
