import 'package:flutter/material.dart';

import 'package:lab_3/core/theme/app_colors.dart';
import 'package:lab_3/logic/home/program_sort.dart';

import 'toolbar_icon_button.dart';

/// Opens a bottom sheet with the available [ProgramSort] options.
class SortMenuButton extends StatelessWidget {
  const SortMenuButton({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ProgramSort selected;
  final ValueChanged<ProgramSort> onSelected;

  Future<void> _openSheet(BuildContext context) async {
    final choice = await showModalBottomSheet<ProgramSort>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  'Sort by',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              for (final sort in ProgramSort.values)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text(sort.label),
                  trailing: sort == selected
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                        )
                      : null,
                  selected: sort == selected,
                  selectedColor: AppColors.primary,
                  onTap: () => Navigator.of(context).pop(sort),
                ),
            ],
          ),
        ),
      ),
    );
    if (choice != null) onSelected(choice);
  }

  @override
  Widget build(BuildContext context) {
    return ToolbarIconButton(
      icon: Icons.swap_vert_rounded,
      tooltip: 'Sort: ${selected.label}',
      active: selected != ProgramSort.recommended,
      onPressed: () => _openSheet(context),
    );
  }
}
