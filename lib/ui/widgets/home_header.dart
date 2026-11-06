import 'package:flutter/material.dart';

import 'package:lab_3/core/theme/app_colors.dart';
import 'package:lab_3/core/theme/app_text_styles.dart';

import 'circle_icon_button.dart';
import 'network_svg_icon.dart';

/// "Friday, 20 May / Good Morning" header with the notification bell.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.date,
    required this.greeting,
    required this.hasUnreadNotifications,
    this.notificationIconUrl,
    this.onNotificationsTap,
  });

  final String date;
  final String greeting;
  final bool hasUnreadNotifications;
  final String? notificationIconUrl;
  final VoidCallback? onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: AppTextStyles.caption),
              const SizedBox(height: 6),
              Text(greeting, style: AppTextStyles.greeting),
            ],
          ),
        ),
        CircleIconButton(
          tooltip: 'Notifications',
          borderColor: AppColors.border,
          onTap: onNotificationsTap,
          child: SizedBox.square(
            dimension: 26,
            child: Stack(
              children: [
                NetworkSvgIcon(
                  url: notificationIconUrl,
                  fallback: Icons.notifications_none_rounded,
                  size: 26,
                  fallbackColor: AppColors.textPrimary,
                ),
                if (hasUnreadNotifications)
                  Positioned(
                    top: 2,
                    right: 3,
                    child: Container(
                      key: const ValueKey('unread-dot'),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.notificationDot,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
