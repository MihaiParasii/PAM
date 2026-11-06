import 'package:flutter_test/flutter_test.dart';
import 'package:lab_3/data/data_exception.dart';
import 'package:lab_3/data/models/workout_filter.dart';

import '../helpers/fakes.dart';

void main() {
  group('FitnessRepository with the real data file', () {
    final repository = repositoryWith(realJson());

    test('parses the home page', () async {
      final home = await repository.fetchHome();

      expect(home.header.date, 'Friday, 20 May');
      expect(home.header.greeting, 'Good Morning');
      expect(home.header.hasUnreadNotifications, isTrue);
      expect(home.challenge.activity, 'Running');
      expect(home.challenge.completed, 15);
      expect(home.challenge.total, 20);
      expect(home.challenge.progress, 0.75);
      expect(home.featuredPlans.map((p) => p.title), [
        'Massive Upper Body',
        'Strong & Fit',
      ]);
      expect(home.filters.map((f) => f.name), [
        'All Type',
        'Pilates',
        'Cardio',
        'Boxing',
        'Yoga',
      ]);
      expect(home.filters.first.iconUrl, contains('view-grid-outline'));
      expect(home.defaultFilterId, WorkoutFilter.allId);
      expect(home.programs.map((p) => p.id), ['wp001', 'wp002', 'wp003']);
      expect(home.programs[1].isPro, isTrue);
      expect(home.programs[1].proIconUrl, isNotNull);
      expect(home.programs[2].calories, 260);
      expect(home.programs[2].durationMinutes, 45);
    });

    test('parses the gym details page', () async {
      final details = await repository.fetchGymDetails();
      final gym = details.gym;

      expect(gym.name, 'Mid City Gym Training');
      expect(gym.location, 'California, New York');
      expect(gym.rating, 4.5);
      expect(gym.reviewCount, 1232);
      expect(gym.amenities.map((a) => a.name), ['Showers', 'Lockers']);
      expect(gym.pricing.amountLabel, r'$69.00');
      expect(gym.pricing.periodLabel, '/week');
      expect(details.actions.reserveLabel, 'Reserve');
      expect(details.actions.reserveEnabled, isTrue);
    });
  });

  group('FitnessRepository errors', () {
    test('missing file throws DataException', () {
      expect(repositoryWith(null).fetchHome(), throwsA(isA<DataException>()));
    });

    test('invalid JSON throws DataException', () {
      expect(
        repositoryWith('{ not json').fetchHome(),
        throwsA(isA<DataException>()),
      );
    });

    test('JSON with the wrong shape throws DataException', () {
      final json = editedJson((json) {
        (json['fitnessHomePage'] as Map<String, dynamic>).remove('header');
      });
      expect(repositoryWith(json).fetchHome(), throwsA(isA<DataException>()));
    });

    test('a root that is not an object throws DataException', () {
      expect(
        repositoryWith('[1, 2, 3]').fetchGymDetails(),
        throwsA(isA<DataException>()),
      );
    });
  });
}
