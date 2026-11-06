import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/favorites_repository.dart';
import 'data/repositories/fitness_repository.dart';
import 'logic/home/home_cubit.dart';
import 'ui/screens/home/home_screen.dart';

/// Root widget: provides the repositories and the [HomeCubit].
class FitnessApp extends StatelessWidget {
  const FitnessApp({
    super.key,
    required this.fitnessRepository,
    required this.favoritesRepository,
  });

  final FitnessRepository fitnessRepository;
  final FavoritesRepository favoritesRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: fitnessRepository),
        RepositoryProvider.value(value: favoritesRepository),
      ],
      child: BlocProvider(
        create: (_) => HomeCubit(
          fitnessRepository: fitnessRepository,
          favoritesRepository: favoritesRepository,
        )..load(),
        child: MaterialApp(
          title: 'Fitness',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
