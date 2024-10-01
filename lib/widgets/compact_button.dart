import 'package:flutter/material.dart';

class CompactButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final void Function()? onPressed;

  const CompactButton({
    super.key,
    required this.text,
    this.backgroundColor = Colors.green,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return Opacity(
      opacity: isEnabled ? 1 : .5,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}
