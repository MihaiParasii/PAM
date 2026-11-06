import 'package:equatable/equatable.dart';

import 'json_map.dart';

/// A workout type from the filter row ("All Type", "Pilates", ...).
class WorkoutFilter extends Equatable {
  const WorkoutFilter({
    required this.id,
    required this.name,
    this.selected = false,
    this.iconUrl,
  });

  factory WorkoutFilter.fromJson(JsonMap json, {String? iconUrl}) {
    return WorkoutFilter(
      id: json['id'] as String,
      name: json['name'] as String,
      selected: json['selected'] as bool? ?? false,
      iconUrl: iconUrl,
    );
  }

  /// Id of the filter that matches every program.
  static const String allId = 'all';

  final String id;
  final String name;

  /// Whether the filter is selected by default (as delivered by the data).
  final bool selected;
  final String? iconUrl;

  bool get isAll => id == allId;

  @override
  List<Object?> get props => [id, name, selected, iconUrl];
}
