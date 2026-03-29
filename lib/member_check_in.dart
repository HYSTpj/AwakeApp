import 'package:flutter/material.dart';

import 'common_layout.dart';

class MemberCheckInPage extends StatefulWidget {
  const MemberCheckInPage({super.key});

  @override
  State<MemberCheckInPage> createState() => _MemberCheckInPageState();
}

class _MemberCheckInPageState extends State<MemberCheckInPage> {
  bool isDeparturePressed = false;
  bool isCheckInPressed = false;
  bool isWakeUpPressed = false;

  void _toggleDeparture() {
    setState(() {
      isDeparturePressed = !isDeparturePressed;
    });
    // TODO: 送信するデータをここで実装する
  }

  void _toggleCheckIn() {
    setState(() {
      isCheckInPressed = !isCheckInPressed;
    });
    // TODO: 送信するデータをここで実装する
  }

  void _toggleWakeUp() {
    setState(() {
      isWakeUpPressed = !isWakeUpPressed;
    });
    // TODO: 送信するデータをここで実装する
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DepartureButton(
              isSelected: isDeparturePressed,
              onTap: _toggleDeparture,
            ),
            const SizedBox(height: 16),
            CheckInButton(
              isPressed: isCheckInPressed,
              onTap: _toggleCheckIn,
            ),
            const SizedBox(height: 16),
            WakeUpButton(
              isPressed: isWakeUpPressed,
              onTap: _toggleWakeUp,
            ),
            const SizedBox(height: 16),
            ReportLateButton(
              onTap: () {
                // TODO: REPORT LATEボタンがタップされたときの処理を実装する
              },
            ),
          ],
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
                    child: Icon(
                      rightIcon,
                      color: Colors.black,
                      size: 18,
                    ),
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
    final backgroundColor = isPressed ? const Color(0xFFE2E2E2) : const Color(0xFFFF5C00);
    final iconColor = const Color(0xFF1A1C1C);
    final rightIcon = isPressed ? Icons.check : Icons.arrow_forward;

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
                    child: Icon(
                      rightIcon,
                      color: iconColor,
                      size: 18,
                    ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
                        child: Icon(
                          Icons.alarm,
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
                    child: Icon(
                      rightIcon,
                      color: iconColor,
                      size: 18,
                    ),
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

  const ReportLateButton({
    super.key,
    this.onTap,
    this.label = 'REPORT LATE',
  });

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
                        child: Icon(
                          Icons.alarm,
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
