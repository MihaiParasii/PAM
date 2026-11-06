import 'package:equatable/equatable.dart';

import '../../data/models/fitness_home.dart';
import '../../data/models/workout_filter.dart';
import '../../data/models/workout_program.dart';
import 'program_sort.dart';

enum HomeStatus {
  /// Nothing requested yet.
  initial,

  /// Data is being loaded.
  loading,

  /// Data loaded and at least one program matches the current criteria.
  success,

  /// Data loaded but no program matches (or the data has no programs).
  empty,

  /// Loading failed; [HomeState.errorMessage] says why.
  error,
}

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.home,
    this.selectedFilterId = WorkoutFilter.allId,
    this.query = '',
    this.sort = ProgramSort.recommended,
    this.favoriteIds = const <String>{},
    this.favoritesOnly = false,
    this.visiblePrograms = const <WorkoutProgram>[],
    this.errorMessage,
  });

  final HomeStatus status;

  /// Loaded content; null until the first successful load.
  final FitnessHome? home;
  final String selectedFilterId;
  final String query;
  final ProgramSort sort;
  final Set<String> favoriteIds;
  final bool favoritesOnly;

  /// Programs after search, filter, favourites and sort are applied.
  final List<WorkoutProgram> visiblePrograms;
  final String? errorMessage;

  bool get isLoading =>
      status == HomeStatus.loading || status == HomeStatus.initial;

  /// Whether the user narrowed the list (search, type or favourites).
  bool get hasActiveCriteria =>
      query.trim().isNotEmpty ||
      favoritesOnly ||
      (home != null && selectedFilterId != home!.allFilterId);

  bool isFavorite(String programId) => favoriteIds.contains(programId);

  HomeState copyWith({
    HomeStatus? status,
    FitnessHome? home,
    String? selectedFilterId,
    String? query,
    ProgramSort? sort,
    Set<String>? favoriteIds,
    bool? favoritesOnly,
    List<WorkoutProgram>? visiblePrograms,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      home: home ?? this.home,
      selectedFilterId: selectedFilterId ?? this.selectedFilterId,
      query: query ?? this.query,
      sort: sort ?? this.sort,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      visiblePrograms: visiblePrograms ?? this.visiblePrograms,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    home,
    selectedFilterId,
    query,
    sort,
    favoriteIds,
    favoritesOnly,
    visiblePrograms,
    errorMessage,
  ];
}
