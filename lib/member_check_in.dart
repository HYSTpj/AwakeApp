import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'common_layout.dart';
import 'widgets/statusbutton.dart';
import 'data/event_repository.dart';
import 'qr_scanner_page.dart';

class MemberCheckInPage extends StatefulWidget {
  const MemberCheckInPage({super.key});

  @override
  State<MemberCheckInPage> createState() => _MemberCheckInPageState();
}

class _MemberCheckInPageState extends State<MemberCheckInPage> {
  final String _dummyEventId = "DUMMY_EVENT_ID_123";
  final EventRepository _eventRepository = EventRepository();
  String? _userId;
  String? _reportId;

  bool isDeparturePressed = false;
  bool isCheckInPressed = false;
  bool isWakeUpPressed = false;
  StatusButtonType selectedStatus = StatusButtonType.sleeping;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _userId = FirebaseAuth.instance.currentUser?.uid ?? "DUMMY_USER_ID_123";

    var report = await _eventRepository.getEventReport(_dummyEventId, _userId!);
    
    if (report == null) {
      _reportId = await _eventRepository.createDummyReportIfNotExist(_dummyEventId, _userId!);
      report = await _eventRepository.getEventReport(_dummyEventId, _userId!);
    } else {
      _reportId = report['report_id'];
    }

    if (report != null && mounted) {
      final repoData = report;
      setState(() {
        isWakeUpPressed = repoData['actual_wakeup_time'] != null;
        isDeparturePressed = repoData['actual_departure_time'] != null;
        
        final statusInt = repoData['status'] as int? ?? 0;
        isCheckInPressed = (statusInt >= 4);

        if (statusInt == 1) {
          selectedStatus = StatusButtonType.awake;
        } else if (statusInt == 0) {
          selectedStatus = StatusButtonType.sleeping;
        } else if (statusInt == 2) {
          selectedStatus = StatusButtonType.overslept;
        } else if (statusInt == 3) {
          selectedStatus = StatusButtonType.moving;
        } else if (statusInt >= 4) {
          selectedStatus = StatusButtonType.arrived;
        }
      });
    }
  }

  Future<void> _toggleDeparture() async {
    if (_reportId == null || isDeparturePressed) return;
    setState(() {
      isDeparturePressed = true;
    });
    await _eventRepository.updateDepartureTime(_reportId!);
    _loadData();
  }

  Future<void> _toggleCheckIn() async {
    if (_reportId == null || isCheckInPressed) return;

    // QRスキャナーまたはパスコード画面へ遷移して結果を受け取る
    final scannedResult = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerPage(),
      ),
    );

    if (scannedResult != null) {
      final type = scannedResult['type'];
      final value = scannedResult['value'];
      
      if (type == null || value == null) return;

      bool isValid = false;
      if (type == 'qrcode') {
        // データベースのeventsのqrcode_idと照合
        isValid = await _eventRepository.verifyEventQRCode(_dummyEventId, value);
      } else if (type == 'passcode') {
        // データベースのeventsのpasswordと照合
        isValid = await _eventRepository.verifyEventPassword(_dummyEventId, value);
      }

      if (isValid) {
        setState(() {
          isCheckInPressed = true;
        });
        await _eventRepository.updateCheckInStatus(_reportId!);
        _loadData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('チェックインが完了しました！', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          final errorMsg = type == 'qrcode' ? '無効なQRコードです。' : 'パスコードが間違っています。';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleWakeUp() async {
    if (_reportId == null || isWakeUpPressed) return;
    setState(() {
      isWakeUpPressed = true;
    });
    await _eventRepository.updateWakeupTime(_reportId!);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const GroupNameDropdown(),
              const SizedBox(height: 24),
              CurrentStatusPanel(status: selectedStatus),
              const SizedBox(height: 16),
              WakeUpButton(isPressed: isWakeUpPressed, onTap: _toggleWakeUp),
              const SizedBox(height: 16),
              DepartureButton(
                isSelected: isDeparturePressed,
                onTap: _toggleDeparture,
              ),
              const SizedBox(height: 16),
              CheckInButton(isPressed: isCheckInPressed, onTap: _toggleCheckIn),
              const SizedBox(height: 16),
              ReportLateButton(
                onTap: () {
                  // TODO: REPORT LATEボタンがタップされたときの処理を実装する
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GroupNameDropdown extends StatelessWidget {
  const GroupNameDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF1A1C1C);
    
    return Container(
      width: 362,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 4),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'GROUP NAME',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: borderColor,
              letterSpacing: 0.5,
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: borderColor, size: 28),
        ],
      ),
    );
  }
}


class CurrentStatusPanel extends StatelessWidget {
  const CurrentStatusPanel({super.key, required this.status});

  final StatusButtonType status;

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF1A1C1C);

    return SizedBox(
      width: 362,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          border: Border.all(color: borderColor, width: 4),
        ),
        padding: const EdgeInsets.all(14),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: borderColor, width: 4)),
          ),
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CURRENT\nSTATUS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  color: borderColor,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: borderColor, width: 2),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10.5,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColorOf(status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${statusOrderOf(status)}: ${statusLabelOf(status)}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: borderColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DepartureButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback? onTap;
  final String label;

  const DepartureButton({
    super.key,
    this.isSelected = false,
    this.onTap,
    this.label = 'DEPARTURE',
  });

  @override
  Widget build(BuildContext context) {
    const buttonWidth = 362.0;
    const buttonHeight = 90.0;
    const borderColor = Color(0xFF1A1C1C);
    final backgroundColor = isSelected ? Colors.white : const Color(0xFFFF5C00);
    final iconAreaColor = isSelected ? Colors.white : const Color(0xFFFF7A00);
    final rightIcon = isSelected ? Icons.check : Icons.arrow_forward;

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: borderColor, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(8, 8),
                  blurRadius: 0,
                ),
              ],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50.5,
                      height: 48,
                      decoration: BoxDecoration(
                        color: iconAreaColor,
                        border: Border.all(color: borderColor, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.directions_car,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1C1C),
                        letterSpacing: -1.2,
                        height: 1.333,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 24.5,
                  height: 24.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Icon(rightIcon, color: Colors.black, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CheckInButton extends StatelessWidget {
  final bool isPressed;
  final VoidCallback? onTap;
  final String label;

  const CheckInButton({
    super.key,
    this.isPressed = false,
    this.onTap,
    this.label = 'CHECK-IN',
  });

  @override
  Widget build(BuildContext context) {
    const buttonWidth = 362.0;
    const buttonHeight = 90.0;
    const borderColor = Color(0xFF1A1C1C);
    final backgroundColor = isPressed
        ? const Color(0xFFE2E2E2)
        : const Color(0xFFFF5C00);
    final iconColor = const Color(0xFF1A1C1C);
    final rightIcon = isPressed ? Icons.check : Icons.arrow_forward;

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: borderColor, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(8, 8),
                  blurRadius: 0,
                ),
              ],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 53,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: borderColor, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.location_on,
                          color: iconColor,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1C1C),
                        letterSpacing: -1.2,
                        height: 1.333,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 24.5,
                  height: 24.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Icon(rightIcon, color: iconColor, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WakeUpButton extends StatelessWidget {
  final bool isPressed;
  final VoidCallback? onTap;
  final String label;

  const WakeUpButton({
    super.key,
    this.isPressed = false,
    this.onTap,
    this.label = 'WAKE UP',
  });

  @override
  Widget build(BuildContext context) {
    const buttonWidth = 362.0;
    const buttonHeight = 90.0;
    const borderColor = Color(0xFF1A1C1C);
    final backgroundColor = isPressed ? Colors.white : const Color(0xFFE2E2E2);
    final iconAreaColor = isPressed ? const Color(0xFFFF5C00) : Colors.white;
    final iconColor = const Color(0xFF1A1C1C);
    final rightIcon = isPressed ? Icons.check : Icons.arrow_forward;

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: borderColor, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(8, 8),
                  blurRadius: 0,
                ),
              ],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 54.5,
                      height: 52.6,
                      decoration: BoxDecoration(
                        color: iconAreaColor,
                        border: Border.all(color: borderColor, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(Icons.alarm, color: iconColor, size: 28),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1C1C),
                        letterSpacing: -1.2,
                        height: 1.333,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 24.5,
                  height: 24.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Icon(rightIcon, color: iconColor, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReportLateButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;

  const ReportLateButton({super.key, this.onTap, this.label = 'REPORT LATE'});

  @override
  Widget build(BuildContext context) {
    const buttonWidth = 362.0;
    const buttonHeight = 90.0;
    const borderColor = Color(0xFF1A1C1C);
    const buttonColor = Color(0xFFFFDAD6);
    const iconBackgroundColor = Color(0xFF93000A);
    const iconColor = Colors.white;

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: buttonColor,
              border: Border.all(color: borderColor, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(8, 8),
                  blurRadius: 0,
                ),
              ],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 54.6,
                      height: 53,
                      decoration: BoxDecoration(
                        color: iconBackgroundColor,
                        border: Border.all(color: borderColor, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.alarm, color: iconColor, size: 28),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF93000A),
                        letterSpacing: -1.2,
                        height: 1.333,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFF93000A),
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
