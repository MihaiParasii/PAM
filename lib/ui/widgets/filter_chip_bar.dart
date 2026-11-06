import 'package:flutter/material.dart';

import 'package:lab_3/core/theme/app_colors.dart';

import 'network_svg_icon.dart';

/// Data needed to draw one pill in a [FilterChipBar].
class FilterChipItem {
  const FilterChipItem({required this.id, required this.label, this.iconUrl});

  final String id;
  final String label;
  final String? iconUrl;
}

/// A single selectable pill ("All Type", "Pilates", ...).
class SelectablePill extends StatelessWidget {
  const SelectablePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.iconUrl,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : AppColors.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconUrl != null) ...[
                NetworkSvgIcon(
                  url: iconUrl,
                  fallback: Icons.fitness_center,
                  size: 16,
                  color: foreground,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontally scrollable row of [SelectablePill]s.
class FilterChipBar extends StatelessWidget {
  const FilterChipBar({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  });

  final List<FilterChipItem> items;
  final String selectedId;
  final ValueChanged<String> onSelected;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return SelectablePill(
            label: item.label,
            iconUrl: item.iconUrl,
            selected: item.id == selectedId,
            onTap: () => onSelected(item.id),
          );
        },
      ),
    );
  }
}
