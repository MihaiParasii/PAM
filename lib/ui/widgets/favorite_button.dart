import 'package:flutter/material.dart';

import 'package:lab_3/core/theme/app_colors.dart';

/// Small round heart toggle drawn on top of images.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
  });

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: isFavorite,
      child: Tooltip(
        message: isFavorite ? 'Remove from favourites' : 'Add to favourites',
        child: Material(
          color: Colors.black.withValues(alpha: 0.35),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox.square(
              dimension: 32,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  key: ValueKey(isFavorite),
                  size: 18,
                  color: isFavorite ? AppColors.notificationDot : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
