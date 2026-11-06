# Lab 3 – Fitness app with Cubit state management

The Lab 2 design (Home + Gym details), driven by real data from
`assets/data/fitness_data.json` (the variant JSON from the course Drive).

## Structure
- `lib/data` – models (`fromJson`), `FitnessRepository` (async asset loading with simulated latency), `FavoritesRepository` (shared_preferences), `DataException`.
- `lib/logic` – `HomeCubit` / `HomeState` (Loading, Success, Empty, Error + search, type filter, sort, favourites), `GymDetailsCubit` / `GymDetailsState` (details loading, Read more, reservation).
- `lib/ui/screens` – Home, Gym details, Featured plans ("See All").
- `lib/ui/widgets` – reusable components (cards, pills, search field, state views, ...).

## Features
- Loading / Success / Empty / Error states, with retry and pull-to-refresh.
- Search by title, workout-type filter (matched against the title, since the JSON has no category field), 7 sort orders.
- Favourites (heart on each card), persisted, plus a "favourites only" toggle.
- Navigation to the details page and the Featured Plans list; Reserve with an async progress state.

## Run
```
flutter pub get
flutter run
flutter test
```
