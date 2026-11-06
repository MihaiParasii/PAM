import 'package:flutter/material.dart';

import 'app.dart';
import 'data/repositories/favorites_repository.dart';
import 'data/repositories/fitness_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    FitnessApp(
      fitnessRepository: FitnessRepository(),
      favoritesRepository: FavoritesRepository(),
    ),
  );
}
