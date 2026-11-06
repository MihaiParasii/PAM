import 'package:flutter/material.dart';

import 'package:lab_3/core/theme/app_colors.dart';

/// Network image that fills its (tight) constraints and shows a neutral
/// placeholder while loading or when the image cannot be fetched.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final String url;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      alignment: alignment,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const _ImagePlaceholder(),
      errorBuilder: (context, error, stackTrace) =>
          const _ImagePlaceholder(showIcon: true),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({this.showIcon = false});

  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.imagePlaceholder,
      child: SizedBox.expand(
        child: showIcon
            ? const Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.white38,
                ),
              )
            : null,
      ),
    );
  }
}
