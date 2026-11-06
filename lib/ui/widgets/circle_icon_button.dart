import 'package:flutter/material.dart';

/// Round tappable container used for the bell and the back button.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.child,
    this.onTap,
    this.size = 48,
    this.backgroundColor = Colors.white,
    this.borderColor,
    this.tooltip,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double size;
  final Color backgroundColor;
  final Color? borderColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: backgroundColor,
      shape: CircleBorder(
        side: borderColor == null
            ? BorderSide.none
            : BorderSide(color: borderColor!),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox.square(
          dimension: size,
          child: Center(child: child),
        ),
      ),
    );

    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}
