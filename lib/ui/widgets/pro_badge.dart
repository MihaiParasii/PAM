import 'package:flutter/material.dart';

import 'package:lab_3/core/theme/app_colors.dart';

import 'network_svg_icon.dart';

/// Light green "Pro" pill shown on premium workout programs.
class ProBadge extends StatelessWidget {
  const ProBadge({super.key, this.iconUrl});

  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          NetworkSvgIcon(
            url: iconUrl,
            fallback: Icons.workspace_premium_outlined,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          const Text(
            'Pro',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
