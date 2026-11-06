import 'package:equatable/equatable.dart';

import 'json_map.dart';

class TodaysChallenge extends Equatable {
  const TodaysChallenge({
    required this.title,
    required this.activity,
    required this.completed,
    required this.total,
    required this.progress,
    this.iconUrl,
  });

  factory TodaysChallenge.fromJson(JsonMap json) {
    final completed = (json['completed'] as num).toInt();
    final total = (json['total'] as num).toInt();
    final progress = json['progress'] as num?;
    return TodaysChallenge(
      title: json['title'] as String,
      activity: json['activity'] as String,
      completed: completed,
      total: total,
      progress: progress?.toDouble() ?? (total == 0 ? 0 : completed / total),
      iconUrl: json['iconUrl'] as String?,
    );
  }

  final String title;
  final String activity;
  final int completed;
  final int total;

  /// Completion ratio between 0 and 1.
  final double progress;
  final String? iconUrl;

  @override
  List<Object?> get props => [
    title,
    activity,
    completed,
    total,
    progress,
    iconUrl,
  ];
}
