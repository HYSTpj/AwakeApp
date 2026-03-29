import 'package:flutter/material.dart';

import 'common_layout.dart';

class MemberCheckInPage extends StatelessWidget {
  const MemberCheckInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CheckInButton(
              isPressed: false,
              onTap: () {
                // TODO: CHECK-INボタンがタップされたときの処理を実装する
              },
            ),
            const SizedBox(height: 16),
            CheckInButton(
              isPressed: true,
              onTap: () {
                // TODO: チェックイン済みボタンがタップされたときの処理を実装する
              },
            ),
          ],
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
