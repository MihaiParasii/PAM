import 'package:flutter/material.dart';

/// Small icon followed by a text label (e.g. "🔥 210 kcl").
class IconLabel extends StatelessWidget {
  const IconLabel({
    super.key,
    required this.icon,
    required this.label,
    required this.style,
    this.spacing = 4,
  });

  final Widget icon;
  final String label;
  final TextStyle style;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        SizedBox(width: spacing),
        Text(label, style: style),
      ],
    );
  }
}
