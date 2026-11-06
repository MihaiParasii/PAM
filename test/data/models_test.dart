import 'package:flutter_test/flutter_test.dart';
import 'package:lab_3/core/utils/formatters.dart';
import 'package:lab_3/data/models/gym_details.dart';
import 'package:lab_3/data/models/workout_filter.dart';
import 'package:lab_3/data/models/workout_program.dart';

void main() {
  const yoga = WorkoutProgram(
    id: '1',
    title: 'Yoga',
    calories: 210,
    durationMinutes: 120,
    isPro: false,
    imageUrl: 'x',
  );
  const cardio = WorkoutProgram(
    id: '2',
    title: 'Cardio Training',
    calories: 260,
    durationMinutes: 45,
    isPro: false,
    imageUrl: 'x',
  );

  test('a program matches the workout type mentioned in its title', () {
    const all = WorkoutFilter(id: 'all', name: 'All Type');
    const cardioFilter = WorkoutFilter(id: 'cardio', name: 'Cardio');
    const yogaFilter = WorkoutFilter(id: 'yoga', name: 'Yoga');
    const boxing = WorkoutFilter(id: 'boxing', name: 'Boxing');

    expect(yoga.matchesFilter(all), isTrue);
    expect(yoga.matchesFilter(yogaFilter), isTrue);
    expect(yoga.matchesFilter(cardioFilter), isFalse);
    expect(cardio.matchesFilter(cardioFilter), isTrue);
    expect(cardio.matchesFilter(boxing), isFalse);
  });

  test('search is case-insensitive and ignores surrounding spaces', () {
    expect(cardio.matchesQuery('  TRAIN '), isTrue);
    expect(cardio.matchesQuery(''), isTrue);
    expect(cardio.matchesQuery('yoga'), isFalse);
  });

  test('pricing labels', () {
    const usd = Pricing(amount: 69, currency: 'USD', period: 'week');
    const unknown = Pricing(amount: 5.5, currency: 'XYZ', period: 'day');
    expect(usd.amountLabel, r'$69.00');
    expect(usd.periodLabel, '/week');
    expect(unknown.amountLabel, '5.50 XYZ');
  });

  test('formatThousands', () {
    expect(formatThousands(0), '0');
    expect(formatThousands(999), '999');
    expect(formatThousands(1232), '1,232');
    expect(formatThousands(1234567), '1,234,567');
    expect(formatThousands(-1000), '-1,000');
  });
}
