import 'package:flutter/material.dart';

import 'package:lab_3/core/theme/app_colors.dart';

import 'progress_ring.dart';

/// Dark "Today's Challenge" card with a progress ring.
class ChallengeCard extends StatelessWidget {
  const ChallengeCard({
    super.key,
    required this.title,
    required this.activity,
    required this.completed,
    required this.total,
    required this.progress,
  });

  final String title;
  final String activity;
  final int completed;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFB4B6BE),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  activity,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ProgressRing(progress: progress, label: '$completed/$total'),
        ],
      ),
    );
  }
}
