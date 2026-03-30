import 'package:flutter/material.dart';

enum StatusButtonType {
  sleeping(0, 'SLEEPING', Color(0xFFA1A1AA)),
  awake(1, 'AWAKE', Color(0xFF53D96E)),
  overslept(2, 'OVERSLEPT', Color(0xFFF26A63)),
  moving(3, 'MOVING', Color(0xFF4EA9FF)),
  arrived(4, 'ARRIVED', Color(0xFFFF8B16));

  final int order;
  final String label;
  final Color color;

  const StatusButtonType(this.order, this.label, this.color);
}

int statusOrderOf(StatusButtonType type) => type.order;
String statusLabelOf(StatusButtonType type) => type.label;
Color statusColorOf(StatusButtonType type) => type.color;

class StatusButton extends StatelessWidget {
  const StatusButton({
    super.key,
    required this.type,
    this.isSelected = false,
    this.onTap,
  });

  final StatusButtonType type;
  final bool isSelected;
  final VoidCallback? onTap;

  Color get _foregroundColor =>
      type.color.computeLuminance() > 0.5 ? Colors.black : Colors.white;

  @override
  Widget build(BuildContext context) {
    const buttonWidth = 362.0;
    const buttonHeight = 90.0;
    const borderColor = Color(0xFF1A1C1C);

    final backgroundColor = isSelected ? type.color : Colors.white;
    final textColor = isSelected ? _foregroundColor : borderColor;
    final badgeColor = type.color;

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
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${type.order}: ${type.label}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: -1.2,
                    height: 1.333,
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
