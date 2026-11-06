import '../../data/models/workout_program.dart';

/// Sort orders available for the workout programs grid.
enum ProgramSort {
  recommended('Recommended'),
  nameAsc('Name (A–Z)'),
  nameDesc('Name (Z–A)'),
  caloriesDesc('Calories (high to low)'),
  caloriesAsc('Calories (low to high)'),
  durationAsc('Duration (short to long)'),
  durationDesc('Duration (long to short)');

  const ProgramSort(this.label);

  final String label;

  /// Compares two programs; returns 0 when this order does not distinguish
  /// them (the caller then keeps the original data order).
  int compare(WorkoutProgram a, WorkoutProgram b) {
    switch (this) {
      case ProgramSort.recommended:
        return 0;
      case ProgramSort.nameAsc:
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      case ProgramSort.nameDesc:
        return b.title.toLowerCase().compareTo(a.title.toLowerCase());
      case ProgramSort.caloriesDesc:
        return b.calories.compareTo(a.calories);
      case ProgramSort.caloriesAsc:
        return a.calories.compareTo(b.calories);
      case ProgramSort.durationAsc:
        return a.durationMinutes.compareTo(b.durationMinutes);
      case ProgramSort.durationDesc:
        return b.durationMinutes.compareTo(a.durationMinutes);
    }
  }
}
