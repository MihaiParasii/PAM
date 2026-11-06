import 'package:equatable/equatable.dart';

import 'json_map.dart';

class FeaturedPlan extends Equatable {
  const FeaturedPlan({
    required this.id,
    required this.title,
    required this.duration,
    required this.frequency,
    required this.actionLabel,
    required this.imageUrl,
    this.durationIconUrl,
    this.frequencyIconUrl,
  });

  factory FeaturedPlan.fromJson(JsonMap json) {
    final icons = json['metaIcons'] as JsonMap?;
    return FeaturedPlan(
      id: json['id'] as String,
      title: json['title'] as String,
      duration: json['duration'] as String,
      frequency: json['frequency'] as String,
      actionLabel: json['actionLabel'] as String? ?? 'Start Now',
      imageUrl: json['imageUrl'] as String,
      durationIconUrl: icons?['durationIconUrl'] as String?,
      frequencyIconUrl: icons?['frequencyIconUrl'] as String?,
    );
  }

  final String id;
  final String title;
  final String duration;
  final String frequency;
  final String actionLabel;
  final String imageUrl;
  final String? durationIconUrl;
  final String? frequencyIconUrl;

  @override
  List<Object?> get props => [
    id,
    title,
    duration,
    frequency,
    actionLabel,
    imageUrl,
    durationIconUrl,
    frequencyIconUrl,
  ];
}
