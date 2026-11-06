import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_3/logic/home/home_cubit.dart';
import 'package:lab_3/logic/home/home_state.dart';
import 'package:lab_3/logic/home/program_sort.dart';

import '../helpers/fakes.dart';

List<String> _titles(HomeState state) =>
    state.visiblePrograms.map((p) => p.title).toList();

void main() {
  late InMemoryFavoritesRepository favorites;

  setUp(() => favorites = InMemoryFavoritesRepository());

  HomeCubit buildCubit([String? json]) => HomeCubit(
    fitnessRepository: repositoryWith(json ?? realJson()),
    favoritesRepository: favorites,
  );

  Future<HomeCubit> loadedCubit([String? json]) async {
    final cubit = buildCubit(json);
    await cubit.load();
    return cubit;
  }

  test('initial state', () {
    final cubit = buildCubit();
    expect(cubit.state.status, HomeStatus.initial);
    expect(cubit.state.home, isNull);
    cubit.close();
  });

  blocTest<HomeCubit, HomeState>(
    'load emits loading then success with every program',
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<HomeState>().having((s) => s.status, 'status', HomeStatus.loading),
      isA<HomeState>()
          .having((s) => s.status, 'status', HomeStatus.success)
          .having(_titles, 'titles', [
            'Yoga',
            'Arm Strengthening',
            'Cardio Training',
          ])
          .having((s) => s.selectedFilterId, 'filter', 'all'),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'load emits error when the data cannot be read',
    build: () => HomeCubit(
      fitnessRepository: repositoryWith(null),
      favoritesRepository: favorites,
    ),
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<HomeState>().having((s) => s.status, 'status', HomeStatus.loading),
      isA<HomeState>()
          .having((s) => s.status, 'status', HomeStatus.error)
          .having((s) => s.errorMessage, 'message', isNotEmpty),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'load emits empty when the data has no programs',
    build: () => buildCubit(
      editedJson((json) {
        final home = json['fitnessHomePage'] as Map<String, dynamic>;
        (home['workoutPrograms'] as Map<String, dynamic>)['items'] = [];
      }),
    ),
    act: (cubit) => cubit.load(),
    skip: 1,
    expect: () => [
      isA<HomeState>()
          .having((s) => s.status, 'status', HomeStatus.empty)
          .having((s) => s.hasActiveCriteria, 'criteria', isFalse),
    ],
  );

  test('retry after an error recovers', () async {
    final cubit = HomeCubit(
      fitnessRepository: repositoryWith(null),
      favoritesRepository: favorites,
    );
    await cubit.load();
    expect(cubit.state.status, HomeStatus.error);
    await cubit.close();

    final recovered = await loadedCubit();
    expect(recovered.state.status, HomeStatus.success);
    await recovered.close();
  });

  test('search filters by title and can become empty', () async {
    final cubit = await loadedCubit();

    cubit.searchChanged('arm');
    expect(_titles(cubit.state), ['Arm Strengthening']);
    expect(cubit.state.status, HomeStatus.success);

    cubit.searchChanged('zumba');
    expect(cubit.state.visiblePrograms, isEmpty);
    expect(cubit.state.status, HomeStatus.empty);
    expect(cubit.state.hasActiveCriteria, isTrue);

    cubit.searchChanged('');
    expect(cubit.state.visiblePrograms, hasLength(3));
    expect(cubit.state.status, HomeStatus.success);
    await cubit.close();
  });

  test('workout type filter', () async {
    final cubit = await loadedCubit();

    cubit.filterSelected('cardio');
    expect(_titles(cubit.state), ['Cardio Training']);

    cubit.filterSelected('yoga');
    expect(_titles(cubit.state), ['Yoga']);

    cubit.filterSelected('boxing');
    expect(cubit.state.status, HomeStatus.empty);

    cubit.filterSelected('all');
    expect(cubit.state.visiblePrograms, hasLength(3));
    await cubit.close();
  });

  test('sorting', () async {
    final cubit = await loadedCubit();

    cubit.sortChanged(ProgramSort.nameDesc);
    expect(_titles(cubit.state), [
      'Yoga',
      'Cardio Training',
      'Arm Strengthening',
    ]);

    cubit.sortChanged(ProgramSort.nameAsc);
    expect(_titles(cubit.state), [
      'Arm Strengthening',
      'Cardio Training',
      'Yoga',
    ]);

    cubit.sortChanged(ProgramSort.caloriesDesc);
    // Ties (210 kcal) keep the data order.
    expect(_titles(cubit.state), [
      'Cardio Training',
      'Yoga',
      'Arm Strengthening',
    ]);

    cubit.sortChanged(ProgramSort.durationAsc);
    expect(_titles(cubit.state), [
      'Cardio Training',
      'Yoga',
      'Arm Strengthening',
    ]);

    cubit.sortChanged(ProgramSort.recommended);
    expect(_titles(cubit.state), [
      'Yoga',
      'Arm Strengthening',
      'Cardio Training',
    ]);
    await cubit.close();
  });

  test('favourites are toggled, persisted and filterable', () async {
    final cubit = await loadedCubit();

    await cubit.toggleFavorite('wp002');
    expect(cubit.state.isFavorite('wp002'), isTrue);
    expect(favorites.stored, {'wp002'});

    cubit.favoritesOnlyToggled();
    expect(_titles(cubit.state), ['Arm Strengthening']);

    await cubit.toggleFavorite('wp002');
    expect(favorites.stored, isEmpty);
    expect(cubit.state.status, HomeStatus.empty);

    cubit.favoritesOnlyToggled();
    expect(cubit.state.visiblePrograms, hasLength(3));
    await cubit.close();
  });

  test('saved favourites are restored on load', () async {
    favorites.stored = {'wp003'};
    final cubit = await loadedCubit();
    expect(cubit.state.isFavorite('wp003'), isTrue);
    await cubit.close();
  });

  test('a failed save rolls the favourite back', () async {
    final cubit = await loadedCubit();
    favorites.failOnSave = true;

    await cubit.toggleFavorite('wp001');
    expect(cubit.state.isFavorite('wp001'), isFalse);
    await cubit.close();
  });

  test('clearCriteria resets search, type and favourites-only', () async {
    final cubit = await loadedCubit();
    cubit
      ..searchChanged('x')
      ..filterSelected('boxing')
      ..favoritesOnlyToggled()
      ..sortChanged(ProgramSort.nameAsc);
    expect(cubit.state.status, HomeStatus.empty);

    cubit.clearCriteria();
    expect(cubit.state.query, '');
    expect(cubit.state.selectedFilterId, 'all');
    expect(cubit.state.favoritesOnly, isFalse);
    expect(cubit.state.sort, ProgramSort.nameAsc);
    expect(cubit.state.status, HomeStatus.success);
    expect(cubit.state.hasActiveCriteria, isFalse);
    await cubit.close();
  });

  test('refresh keeps the selected filter and search', () async {
    final cubit = await loadedCubit();
    cubit
      ..filterSelected('cardio')
      ..searchChanged('card');

    await cubit.refresh();
    expect(cubit.state.selectedFilterId, 'cardio');
    expect(cubit.state.query, 'card');
    expect(_titles(cubit.state), ['Cardio Training']);
    await cubit.close();
  });
}
