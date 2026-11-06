import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/data_exception.dart';
import '../../data/models/workout_program.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/fitness_repository.dart';
import 'home_state.dart';
import 'program_sort.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.fitnessRepository,
    required this.favoritesRepository,
  }) : super(const HomeState());

  final FitnessRepository fitnessRepository;
  final FavoritesRepository favoritesRepository;

  /// Loads the home content, showing the full-screen loading state.
  Future<void> load() async {
    if (state.status == HomeStatus.loading) return;
    emit(state.copyWith(status: HomeStatus.loading, clearError: true));
    await _fetch();
  }

  /// Reloads the content while keeping the current one on screen
  /// (pull-to-refresh).
  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    try {
      final home = await fitnessRepository.fetchHome();
      final favorites = await _loadFavorites();
      if (isClosed) return;

      final keepFilter =
          state.home != null && home.filterById(state.selectedFilterId) != null;
      emit(
        _withVisiblePrograms(
          state.copyWith(
            home: home,
            favoriteIds: favorites,
            selectedFilterId: keepFilter
                ? state.selectedFilterId
                : home.defaultFilterId,
            clearError: true,
          ),
          loaded: true,
        ),
      );
    } on DataException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(status: HomeStatus.error, errorMessage: error.message),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: HomeStatus.error,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  /// Favourites are a convenience: failing to read them must not prevent
  /// the home page from loading.
  Future<Set<String>> _loadFavorites() async {
    try {
      return await favoritesRepository.load();
    } catch (_) {
      return state.favoriteIds;
    }
  }

  void searchChanged(String query) {
    if (query == state.query) return;
    _update(state.copyWith(query: query));
  }

  void filterSelected(String filterId) {
    if (filterId == state.selectedFilterId) return;
    _update(state.copyWith(selectedFilterId: filterId));
  }

  void sortChanged(ProgramSort sort) {
    if (sort == state.sort) return;
    _update(state.copyWith(sort: sort));
  }

  void favoritesOnlyToggled() {
    _update(state.copyWith(favoritesOnly: !state.favoritesOnly));
  }

  /// Resets search, workout type and the favourites-only switch.
  void clearCriteria() {
    final home = state.home;
    _update(
      state.copyWith(
        query: '',
        favoritesOnly: false,
        selectedFilterId: home?.allFilterId,
      ),
    );
  }

  Future<void> toggleFavorite(String programId) async {
    _update(
      state.copyWith(favoriteIds: _toggled(state.favoriteIds, programId)),
    );
    try {
      await favoritesRepository.save(state.favoriteIds);
    } catch (_) {
      // Roll back only this change, keeping any toggles made meanwhile.
      if (isClosed) return;
      _update(
        state.copyWith(favoriteIds: _toggled(state.favoriteIds, programId)),
      );
    }
  }

  static Set<String> _toggled(Set<String> ids, String id) {
    final updated = {...ids};
    if (!updated.remove(id)) updated.add(id);
    return updated;
  }

  void _update(HomeState next) => emit(_withVisiblePrograms(next));

  /// Applies search, workout type, favourites and sort to the loaded
  /// programs and derives the success / empty status from the result.
  /// [loaded] is true right after a successful fetch.
  HomeState _withVisiblePrograms(HomeState next, {bool loaded = false}) {
    final home = next.home;
    if (home == null) return next;

    final filter = home.filterById(next.selectedFilterId);
    final programs = home.programs;
    final visible = <WorkoutProgram>[
      for (final program in programs)
        if ((filter == null || program.matchesFilter(filter)) &&
            program.matchesQuery(next.query) &&
            (!next.favoritesOnly || next.favoriteIds.contains(program.id)))
          program,
    ];

    // Dart's sort is not stable, so ties fall back to the data order.
    final order = {for (final (i, p) in programs.indexed) p.id: i};
    visible.sort((a, b) {
      final result = next.sort.compare(a, b);
      return result != 0 ? result : order[a.id]!.compareTo(order[b.id]!);
    });

    final resolveStatus =
        loaded ||
        next.status == HomeStatus.success ||
        next.status == HomeStatus.empty;

    return next.copyWith(
      visiblePrograms: List.unmodifiable(visible),
      status: resolveStatus
          ? (visible.isEmpty ? HomeStatus.empty : HomeStatus.success)
          : null,
    );
  }
}
