import 'package:equatable/equatable.dart';

import 'json_map.dart';
import 'workout_filter.dart';

class WorkoutProgram extends Equatable {
  const WorkoutProgram({
    required this.id,
    required this.title,
    required this.calories,
    required this.durationMinutes,
    required this.isPro,
    required this.imageUrl,
    this.caloriesIconUrl,
    this.durationIconUrl,
    this.proIconUrl,
  });

  factory WorkoutProgram.fromJson(JsonMap json) {
    final icons = json['icons'] as JsonMap?;
    return WorkoutProgram(
      id: json['id'] as String,
      title: json['title'] as String,
      calories: (json['calories'] as num).toInt(),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      isPro: json['isPro'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String,
      caloriesIconUrl: icons?['caloriesIconUrl'] as String?,
      durationIconUrl: icons?['durationIconUrl'] as String?,
      proIconUrl: icons?['proIconUrl'] as String?,
    );
  }

  final String id;
  final String title;
  final int calories;
  final int durationMinutes;
  final bool isPro;
  final String imageUrl;
  final String? caloriesIconUrl;
  final String? durationIconUrl;
  final String? proIconUrl;

  /// The data has no explicit category field, so a program belongs to a
  /// workout type when its title mentions that type ("Cardio Training" ->
  /// Cardio, "Yoga" -> Yoga). "All Type" matches everything.
  bool matchesFilter(WorkoutFilter filter) {
    if (filter.isAll) return true;
    final title = this.title.toLowerCase();
    return title.contains(filter.name.toLowerCase()) ||
        title.contains(filter.id.toLowerCase());
  }

  /// Case-insensitive search on the title.
  bool matchesQuery(String query) {
    final normalized = query.trim().toLowerCase();
    return normalized.isEmpty || title.toLowerCase().contains(normalized);
  }

  @override
  List<Object?> get props => [
    id,
    title,
    calories,
    durationMinutes,
    isPro,
    imageUrl,
    caloriesIconUrl,
    durationIconUrl,
    proIconUrl,
  ];
}
