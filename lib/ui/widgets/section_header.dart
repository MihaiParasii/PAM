import 'package:flutter/material.dart';

import 'package:lab_3/core/theme/app_text_styles.dart';

/// Section title with an optional trailing action ("See All").
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel = 'See All',
    this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: Text(title, style: AppTextStyles.sectionTitle)),
        if (onAction != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Text(actionLabel, style: AppTextStyles.link),
          ),
      ],
    );
  }
}
