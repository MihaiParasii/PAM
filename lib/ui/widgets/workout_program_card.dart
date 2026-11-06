import 'package:flutter/material.dart';

import 'package:lab_3/core/theme/app_text_styles.dart';

import 'app_network_image.dart';
import 'favorite_button.dart';
import 'icon_label.dart';
import 'network_svg_icon.dart';
import 'pro_badge.dart';

/// Image card from the "Workout Programs" grid.
class WorkoutProgramCard extends StatelessWidget {
  const WorkoutProgramCard({
    super.key,
    required this.title,
    required this.calories,
    required this.durationMinutes,
    required this.imageUrl,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.isPro = false,
    this.caloriesIconUrl,
    this.durationIconUrl,
    this.proIconUrl,
    this.onTap,
  });

  final String title;
  final int calories;
  final int durationMinutes;
  final String imageUrl;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final bool isPro;
  final String? caloriesIconUrl;
  final String? durationIconUrl;
  final String? proIconUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const metaStyle = AppTextStyles.cardMeta;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(url: imageUrl),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x33000000),
                      Colors.transparent,
                      Color(0xD9000000),
                    ],
                    stops: [0, 0.3, 1],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: FavoriteButton(
                  isFavorite: isFavorite,
                  onPressed: onFavoriteToggle,
                ),
              ),
              if (isPro)
                Positioned(
                  top: 10,
                  right: 10,
                  child: ProBadge(iconUrl: proIconUrl),
                ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 17,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 14,
                      runSpacing: 4,
                      children: [
                        IconLabel(
                          icon: NetworkSvgIcon(
                            url: caloriesIconUrl,
                            fallback: Icons.local_fire_department_outlined,
                            size: 14,
                            fallbackColor: Colors.white,
                          ),
                          label: '$calories kcl',
                          style: metaStyle,
                        ),
                        IconLabel(
                          icon: NetworkSvgIcon(
                            url: durationIconUrl,
                            fallback: Icons.access_time,
                            size: 14,
                            fallbackColor: Colors.white,
                          ),
                          label: '$durationMinutes min',
                          style: metaStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
