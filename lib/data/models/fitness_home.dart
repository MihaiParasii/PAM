import 'package:equatable/equatable.dart';

import 'featured_plan.dart';
import 'home_header_info.dart';
import 'json_map.dart';
import 'todays_challenge.dart';
import 'workout_filter.dart';
import 'workout_program.dart';

/// Everything shown on the home page (`fitnessHomePage` in the JSON).
class FitnessHome extends Equatable {
  const FitnessHome({
    required this.header,
    required this.challenge,
    required this.featuredPlans,
    required this.filters,
    required this.programs,
  });

  factory FitnessHome.fromJson(JsonMap json) {
    final workoutPrograms = json['workoutPrograms'] as JsonMap;
    final filterIcons =
        workoutPrograms['filterIconUrls'] as JsonMap? ??
        const <String, dynamic>{};

    return FitnessHome(
      header: HomeHeaderInfo.fromJson(json['header'] as JsonMap),
      challenge: TodaysChallenge.fromJson(json['todaysChallenge'] as JsonMap),
      featuredPlans: parseList(json['featuredPlans'], FeaturedPlan.fromJson),
      filters: parseList(
        workoutPrograms['filters'],
        (item) => WorkoutFilter.fromJson(
          item,
          iconUrl: filterIcons[item['id']] as String?,
        ),
      ),
      programs: parseList(workoutPrograms['items'], WorkoutProgram.fromJson),
    );
  }

  final HomeHeaderInfo header;
  final TodaysChallenge challenge;
  final List<FeaturedPlan> featuredPlans;
  final List<WorkoutFilter> filters;
  final List<WorkoutProgram> programs;

  /// Filter selected by default: the one flagged in the data, otherwise
  /// "All Type", otherwise the first one.
  String get defaultFilterId {
    for (final filter in filters) {
      if (filter.selected) return filter.id;
    }
    return allFilterId;
  }

  /// Id of the filter that shows every program.
  String get allFilterId {
    for (final filter in filters) {
      if (filter.isAll) return filter.id;
    }
    return filters.isEmpty ? WorkoutFilter.allId : filters.first.id;
  }

  WorkoutFilter? filterById(String id) {
    for (final filter in filters) {
      if (filter.id == id) return filter;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    header,
    challenge,
    featuredPlans,
    filters,
    programs,
  ];
}
