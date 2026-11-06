import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_3/app.dart';
import 'package:lab_3/data/repositories/fitness_repository.dart';
import 'package:lab_3/ui/widgets/filter_chip_bar.dart';
import 'package:lab_3/ui/widgets/state_views.dart';
import 'package:lab_3/ui/widgets/workout_program_card.dart';

import '../helpers/fakes.dart';

void main() {
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1170, 2532);
    view.devicePixelRatio = 3;
  });

  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  final verticalScrollable = find.byWidgetPredicate(
    (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
  );

  Future<InMemoryFavoritesRepository> pumpApp(
    WidgetTester tester, {
    FitnessRepository? repository,
  }) async {
    final favorites = InMemoryFavoritesRepository();
    await tester.pumpWidget(
      FitnessApp(
        fitnessRepository: repository ?? repositoryWith(realJson()),
        favoritesRepository: favorites,
      ),
    );
    await tester.pumpAndSettle();
    return favorites;
  }

  testWidgets('shows the loading state, then the data from the JSON', (
    tester,
  ) async {
    await tester.pumpWidget(
      FitnessApp(
        fitnessRepository: FitnessRepository(
          bundle: FakeAssetBundle({
            FitnessRepository.defaultAssetPath: realJson(),
          }),
          latency: const Duration(milliseconds: 500),
        ),
        favoritesRepository: InMemoryFavoritesRepository(),
      ),
    );
    expect(find.byType(LoadingView), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.byType(LoadingView), findsNothing);
    expect(find.text('Friday, 20 May'), findsOneWidget);
    expect(find.text('Good Morning'), findsOneWidget);
    expect(find.text('Running'), findsOneWidget);
    expect(find.text('15/20'), findsOneWidget);
    expect(find.text('Massive Upper Body'), findsOneWidget);
    expect(find.byType(WorkoutProgramCard), findsNWidgets(2));
  });

  testWidgets('shows the error state and retries', (tester) async {
    final bundle = FakeAssetBundle({});
    await pumpApp(
      tester,
      repository: FitnessRepository(bundle: bundle, latency: Duration.zero),
    );

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('Could not read the fitness data.'), findsOneWidget);

    bundle.contents[FitnessRepository.defaultAssetPath] = realJson();
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsNothing);
    expect(find.text('Good Morning'), findsOneWidget);
  });

  testWidgets('search narrows the list and shows the empty state', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField), 'cardio');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byType(WorkoutProgramCard),
      200,
      scrollable: verticalScrollable,
    );
    expect(find.byType(WorkoutProgramCard), findsOneWidget);
    expect(find.text('Cardio Training'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zumba');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('No programs found'),
      200,
      scrollable: verticalScrollable,
    );
    expect(find.byType(WorkoutProgramCard), findsNothing);

    await tester.ensureVisible(find.text('Clear filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(find.text('No programs found'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
  });

  testWidgets('workout type filter selects the pill and filters', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Pilates'));
    await tester.pumpAndSettle();

    final pill = tester.widget<SelectablePill>(
      find.widgetWithText(SelectablePill, 'Pilates'),
    );
    expect(pill.selected, isTrue);
    await tester.scrollUntilVisible(
      find.text('No programs found'),
      200,
      scrollable: verticalScrollable,
    );
  });

  testWidgets('favourite toggle is saved', (tester) async {
    final favorites = await pumpApp(tester);

    await tester.scrollUntilVisible(
      find.byTooltip('Add to favourites').first,
      200,
      scrollable: verticalScrollable,
    );
    await tester.tap(find.byTooltip('Add to favourites').first);
    await tester.pumpAndSettle();

    expect(favorites.stored, {'wp001'});
    expect(find.byTooltip('Remove from favourites'), findsOneWidget);
  });

  testWidgets('opens the gym details from the JSON and reserves', (
    tester,
  ) async {
    await pumpApp(tester);

    final card = find.widgetWithText(WorkoutProgramCard, 'Yoga');
    await tester.scrollUntilVisible(card, 200, scrollable: verticalScrollable);
    await tester.tap(card);
    await tester.pumpAndSettle();

    expect(find.text('Mid City Gym Training'), findsOneWidget);
    expect(find.text('California, New York'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Showers'),
      200,
      scrollable: verticalScrollable,
    );
    expect(find.text('Showers'), findsOneWidget);
    expect(find.text('Lockers'), findsOneWidget);
    expect(find.text(r'$69.00 /week', findRichText: true), findsOneWidget);

    await tester.tap(find.text('Reserve'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Reserved'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Mid City Gym Training'), findsNothing);
    expect(find.text('Workout Programs'), findsOneWidget);
  });
}
