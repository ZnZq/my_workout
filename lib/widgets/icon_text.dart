import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final double iconSize;
  final double gap;
  final double endGap;

  const IconText({
    super.key,
    required this.icon,
    required this.text,
    required this.iconColor,
    this.iconSize = 16,
    this.gap = 4,
    this.endGap = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: iconSize),
        SizedBox(width: gap),
        Text(text),
        if (endGap > 0) SizedBox(width: endGap),
      ],
    );
  }
}
