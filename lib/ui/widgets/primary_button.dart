import 'package:flutter/material.dart';

import 'package:lab_3/core/theme/app_colors.dart';
import 'package:lab_3/core/theme/app_text_styles.dart';

/// Green filled button used for "Start Now" and "Reserve".
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 52,
    this.borderRadius = 8,
    this.textStyle = AppTextStyles.button,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;
  final TextStyle textStyle;
  final EdgeInsetsGeometry padding;

  /// Shows a spinner instead of the label and ignores taps.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(
            alpha: isLoading ? 1 : 0.4,
          ),
          disabledForegroundColor: Colors.white,
          padding: padding,
          minimumSize: Size(0, height),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: textStyle,
        ),
        child: isLoading
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}
