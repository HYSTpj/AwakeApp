import 'package:flutter/material.dart';
import '../../common_layout.dart';

class MemberSetTimeViewData {
  final String memberName;
  final TimeOfDay wakeUpTime;
  final TimeOfDay leaveHomeTime;
  final TimeOfDay arrivalGoalTime;

  const MemberSetTimeViewData({
    required this.memberName,
    required this.wakeUpTime,
    required this.leaveHomeTime,
    required this.arrivalGoalTime,
  });

  MemberSetTimeViewData copyWith({
    String? memberName,
    TimeOfDay? wakeUpTime,
    TimeOfDay? leaveHomeTime,
    TimeOfDay? arrivalGoalTime,
  }) {
    return MemberSetTimeViewData(
      memberName: memberName ?? this.memberName,
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
      leaveHomeTime: leaveHomeTime ?? this.leaveHomeTime,
      arrivalGoalTime: arrivalGoalTime ?? this.arrivalGoalTime,
    );
  }
}

class MemberSetTimePage extends StatefulWidget {
  final List<MemberSetTimeViewData> initialMembers;

  const MemberSetTimePage({
    super.key,
    required this.initialMembers,
  });

  factory MemberSetTimePage.withDummyData({Key? key}) {
    return MemberSetTimePage(
      key: key,
      initialMembers: const [
        MemberSetTimeViewData(
          memberName: 'Sora Tanaka',
          wakeUpTime: TimeOfDay(hour: 6, minute: 10),
          leaveHomeTime: TimeOfDay(hour: 7, minute: 5),
          arrivalGoalTime: TimeOfDay(hour: 8, minute: 0),
        ),
        MemberSetTimeViewData(
          memberName: 'Yui Sato',
          wakeUpTime: TimeOfDay(hour: 6, minute: 30),
          leaveHomeTime: TimeOfDay(hour: 7, minute: 20),
          arrivalGoalTime: TimeOfDay(hour: 8, minute: 0),
        ),
        MemberSetTimeViewData(
          memberName: 'Ren Kato',
          wakeUpTime: TimeOfDay(hour: 5, minute: 50),
          leaveHomeTime: TimeOfDay(hour: 6, minute: 55),
          arrivalGoalTime: TimeOfDay(hour: 8, minute: 0),
        ),
      ],
    );
  }

  @override
  State<MemberSetTimePage> createState() => _MemberSetTimePageState();
}

class _MemberSetTimePageState extends State<MemberSetTimePage> {
  late List<MemberSetTimeViewData> _members;
  int _selectedMemberIndex = 0;

  @override
  void initState() {
    super.initState();
    _members = List<MemberSetTimeViewData>.from(widget.initialMembers);
  }

  Future<void> _pickTime({
    required String field,
    required TimeOfDay current,
  }) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF5C00),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (!mounted || picked == null) return;

    setState(() {
      final MemberSetTimeViewData member = _members[_selectedMemberIndex];

      switch (field) {
        case 'wakeup':
          _members[_selectedMemberIndex] = member.copyWith(wakeUpTime: picked);
          break;
        case 'leave':
          _members[_selectedMemberIndex] = member.copyWith(
            leaveHomeTime: picked,
          );
          break;
        case 'arrival':
          _members[_selectedMemberIndex] = member.copyWith(
            arrivalGoalTime: picked,
          );
          break;
      }
    });
  }

  String _timeLabel(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final MemberSetTimeViewData selected = _members[_selectedMemberIndex];

    return CommonLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMemberDropdown(),
            const SizedBox(height: 24),
            const Text(
              'My Schedule',
              style: TextStyle(
                fontSize: 54,
                height: 0.9,
                fontWeight: FontWeight.w800,
                color: Color(0xFF202228),
              ),
            ),
            Container(
              width: 80,
              height: 5,
              margin: const EdgeInsets.only(top: 6, bottom: 14),
              color: const Color(0xFFFF5C00),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF1A1C1C), width: 4),
              ),
              child: Column(
                children: [
                  _ScheduleRow(
                    icon: Icons.alarm,
                    title: 'Wake-up Time',
                    timeLabel: _timeLabel(selected.wakeUpTime),
                    onTap: () => _pickTime(
                      field: 'wakeup',
                      current: selected.wakeUpTime,
                    ),
                  ),
                  const Divider(height: 0, thickness: 4),
                  _ScheduleRow(
                    icon: Icons.directions_car,
                    title: 'Departure Time',
                    timeLabel: _timeLabel(selected.leaveHomeTime),
                    onTap: () => _pickTime(
                      field: 'leave',
                      current: selected.leaveHomeTime,
                    ),
                  ),
                  const Divider(height: 0, thickness: 4),
                  _ScheduleRow(
                    icon: Icons.calendar_month,
                    title: 'Arrival Goal',
                    timeLabel: _timeLabel(selected.arrivalGoalTime),
                    onTap: () => _pickTime(
                      field: 'arrival',
                      current: selected.arrivalGoalTime,
                    ),
                    highlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 44),
            _ActionCardButton(
              label: 'SMART\nCALCULATOR',
              icon: Icons.rocket_launch,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dummy UI: calculator action.')),
                );
              },
            ),
            const SizedBox(height: 36),
            _SaveChangesButton(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dummy UI: save action.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A1C1C), width: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedMemberIndex,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 28),
          items: List<DropdownMenuItem<int>>.generate(
            _members.length,
            (int index) => DropdownMenuItem<int>(
              value: index,
              child: Text(
                _members[index].memberName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1C1C),
                ),
              ),
            ),
          ),
          onChanged: (int? nextIndex) {
            if (nextIndex == null) return;
            setState(() {
              _selectedMemberIndex = nextIndex;
            });
          },
        ),
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String timeLabel;
  final VoidCallback onTap;
  final bool highlight;

  const _ScheduleRow({
    required this.icon,
    required this.title,
    required this.timeLabel,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: highlight ? const Color(0xFFFF5C00) : const Color(0xFFE5E5E5),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: highlight ? const Color(0xFF1A1C1C) : const Color(0xFFFF5C00),
                border: Border.all(color: const Color(0xFF1A1C1C), width: 3),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 38,
                  height: 1.05,
                  fontWeight: FontWeight.w700,
                  color: highlight ? Colors.white : const Color(0xFF202228),
                ),
              ),
            ),
            InkWell(
              onTap: onTap,
              child: Container(
                width: 104,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF9CA3AF), width: 2),
                ),
                child: Text(
                  timeLabel,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2F3137),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCardButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCardButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFFF5C00),
          border: Border.all(color: const Color(0xFF1A1C1C), width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 44,
                  height: 1.1,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 34, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _SaveChangesButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SaveChangesButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: Offset(8, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            color: const Color(0xFFFF5C00),
            border: Border.all(color: const Color(0xFF1A1C1C), width: 4),
          ),
          child: const Text(
            'SAVE CHANGES',
            style: TextStyle(
              fontSize: 40,
              letterSpacing: 3,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}