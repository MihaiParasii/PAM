import 'package:flutter/material.dart';

import 'package:lab_3/core/theme/app_colors.dart';
import 'package:lab_3/core/theme/app_text_styles.dart';

import 'app_network_image.dart';
import 'icon_label.dart';
import 'network_svg_icon.dart';
import 'primary_button.dart';

/// Dark card from the "Featured Plan" carousel.
class FeaturedPlanCard extends StatelessWidget {
  const FeaturedPlanCard({
    super.key,
    required this.title,
    required this.duration,
    required this.frequency,
    required this.actionLabel,
    required this.imageUrl,
    this.durationIconUrl,
    this.frequencyIconUrl,
    this.width,
    this.height = 146,
    this.onAction,
    this.onTap,
  });

  final String title;
  final String duration;
  final String frequency;
  final String actionLabel;
  final String imageUrl;
  final String? durationIconUrl;
  final String? frequencyIconUrl;
  final double? width;
  final double height;
  final VoidCallback? onAction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final metaStyle = AppTextStyles.cardMeta.copyWith(fontSize: 13);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.dark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AppNetworkImage(
                url: imageUrl,
                alignment: Alignment.centerRight,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.dark.withValues(alpha: 0.96),
                      AppColors.dark.withValues(alpha: 0.75),
                      AppColors.dark.withValues(alpha: 0.05),
                    ],
                    stops: const [0, 0.5, 1],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      IconLabel(
                        icon: NetworkSvgIcon(
                          url: durationIconUrl,
                          fallback: Icons.calendar_view_week_outlined,
                          size: 16,
                          fallbackColor: Colors.white,
                        ),
                        label: duration,
                        style: metaStyle,
                      ),
                      Text('•', style: metaStyle),
                      IconLabel(
                        icon: NetworkSvgIcon(
                          url: frequencyIconUrl,
                          fallback: Icons.fitness_center,
                          size: 16,
                          fallbackColor: Colors.white,
                        ),
                        label: frequency,
                        style: metaStyle,
                      ),
                    ],
                  ),
                  const Spacer(),
                  PrimaryButton(
                    label: actionLabel,
                    onPressed: onAction,
                    height: 34,
                    borderRadius: 6,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    textStyle: AppTextStyles.button.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
