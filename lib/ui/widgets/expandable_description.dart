import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:lab_3/core/theme/app_text_styles.dart';

/// Paragraph with an inline "Read more" / "Read less" toggle.
class ExpandableDescription extends StatefulWidget {
  const ExpandableDescription({
    super.key,
    required this.text,
    required this.expanded,
    required this.onToggle,
    this.collapsedLength = 120,
  });

  final String text;
  final bool expanded;
  final VoidCallback onToggle;

  /// Number of characters shown while collapsed.
  final int collapsedLength;

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  late final TapGestureRecognizer _recognizer = TapGestureRecognizer()
    ..onTap = () => widget.onToggle();

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _stripEllipsis(widget.text);
    final canCollapse = text.length > widget.collapsedLength;
    final showFull = widget.expanded || !canCollapse;

    final visible = showFull
        ? text
        : '${text.substring(0, widget.collapsedLength).trimRight()}...';

    return Text.rich(
      TextSpan(
        style: AppTextStyles.body,
        children: [
          TextSpan(text: visible),
          if (canCollapse)
            TextSpan(
              text: widget.expanded ? ' Read less' : ' Read more',
              style: AppTextStyles.link.copyWith(fontSize: 14),
              recognizer: _recognizer,
            ),
        ],
      ),
    );
  }

  static String _stripEllipsis(String value) {
    var result = value.trim();
    while (result.endsWith('...')) {
      result = result.substring(0, result.length - 3).trimRight();
    }
    return result;
  }
}
