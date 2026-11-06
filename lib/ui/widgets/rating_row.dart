import 'package:flutter/material.dart';

import 'package:lab_3/core/theme/app_colors.dart';
import 'package:lab_3/core/utils/formatters.dart';

import 'network_svg_icon.dart';

/// "★ 4.5 (1,232 reviews)".
class RatingRow extends StatelessWidget {
  const RatingRow({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.iconUrl,
  });

  final double rating;
  final int reviewCount;
  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NetworkSvgIcon(
          url: iconUrl,
          fallback: Icons.star_rounded,
          size: 22,
          fallbackColor: AppColors.star,
        ),
        const SizedBox(width: 6),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              TextSpan(
                text: ' (${formatThousands(reviewCount)} reviews)',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}
