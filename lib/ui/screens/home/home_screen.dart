import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/fitness_home.dart';
import '../../../logic/home/home_cubit.dart';
import '../../../logic/home/home_state.dart';
import '../../widgets/challenge_card.dart';
import '../../widgets/featured_plan_card.dart';
import '../../widgets/filter_chip_bar.dart';
import '../../widgets/home_header.dart';
import '../../widgets/search_field.dart';
import '../../widgets/section_header.dart';
import '../../widgets/sort_menu_button.dart';
import '../../widgets/state_views.dart';
import '../../widgets/toolbar_icon_button.dart';
import '../../widgets/workout_program_card.dart';
import '../featured_plans/featured_plans_screen.dart';
import '../gym_details/gym_details_screen.dart';

/// "21. Home v2" screen, driven by [HomeCubit].
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              switch (state.status) {
                case HomeStatus.initial:
                case HomeStatus.loading:
                  return const LoadingView(message: 'Loading your workouts...');
                case HomeStatus.error:
                  return ErrorView(
                    message: state.errorMessage ?? 'Could not load the data.',
                    onRetry: () => context.read<HomeCubit>().load(),
                  );
                case HomeStatus.success:
                case HomeStatus.empty:
                  return _HomeContent(state: state, home: state.home!);
              }
            },
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.state, required this.home});

  final HomeState state;
  final FitnessHome home;

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(GymDetailsScreen.route());
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    final cardWidth = (MediaQuery.sizeOf(context).width - 80).clamp(
      240.0,
      360.0,
    );

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: cubit.refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            sliver: SliverToBoxAdapter(
              child: HomeHeader(
                date: home.header.date,
                greeting: home.header.greeting,
                hasUnreadNotifications: home.header.hasUnreadNotifications,
                notificationIconUrl: home.header.notificationIconUrl,
                onNotificationsTap: () => _showSnack(
                  context,
                  home.header.hasUnreadNotifications
                      ? 'You have unread notifications'
                      : 'No new notifications',
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
            sliver: SliverToBoxAdapter(
              child: ChallengeCard(
                title: home.challenge.title,
                activity: home.challenge.activity,
                completed: home.challenge.completed,
                total: home.challenge.total,
                progress: home.challenge.progress,
              ),
            ),
          ),
          if (home.featuredPlans.isNotEmpty) ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              sliver: SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Featured Plan',
                  onAction: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const FeaturedPlansScreen(),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 146,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: home.featuredPlans.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final plan = home.featuredPlans[index];
                    return FeaturedPlanCard(
                      key: ValueKey(plan.id),
                      width: cardWidth,
                      title: plan.title,
                      duration: plan.duration,
                      frequency: plan.frequency,
                      actionLabel: plan.actionLabel,
                      imageUrl: plan.imageUrl,
                      durationIconUrl: plan.durationIconUrl,
                      frequencyIconUrl: plan.frequencyIconUrl,
                      onAction: () => _openDetails(context),
                      onTap: () => _openDetails(context),
                    );
                  },
                ),
              ),
            ),
          ],
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            sliver: SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Workout Programs',
                onAction: cubit.clearCriteria,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: SearchField(
                      value: state.query,
                      onChanged: cubit.searchChanged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ToolbarIconButton(
                    icon: state.favoritesOnly
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    tooltip: state.favoritesOnly
                        ? 'Show all programs'
                        : 'Show favourites only',
                    active: state.favoritesOnly,
                    onPressed: cubit.favoritesOnlyToggled,
                  ),
                  const SizedBox(width: 8),
                  SortMenuButton(
                    selected: state.sort,
                    onSelected: cubit.sortChanged,
                  ),
                ],
              ),
            ),
          ),
          if (home.filters.isNotEmpty)
            SliverToBoxAdapter(
              child: FilterChipBar(
                items: [
                  for (final filter in home.filters)
                    FilterChipItem(
                      id: filter.id,
                      label: filter.name,
                      iconUrl: filter.iconUrl,
                    ),
                ],
                selectedId: state.selectedFilterId,
                onSelected: cubit.filterSelected,
              ),
            ),
          if (state.status == HomeStatus.empty)
            SliverPadding(
              padding: const EdgeInsets.only(top: 16, bottom: 32),
              sliver: SliverToBoxAdapter(child: _ProgramsEmptyView(state)),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.84,
                ),
                itemCount: state.visiblePrograms.length,
                itemBuilder: (context, index) {
                  final program = state.visiblePrograms[index];
                  return WorkoutProgramCard(
                    key: ValueKey(program.id),
                    title: program.title,
                    calories: program.calories,
                    durationMinutes: program.durationMinutes,
                    imageUrl: program.imageUrl,
                    isPro: program.isPro,
                    caloriesIconUrl: program.caloriesIconUrl,
                    durationIconUrl: program.durationIconUrl,
                    proIconUrl: program.proIconUrl,
                    isFavorite: state.isFavorite(program.id),
                    onFavoriteToggle: () => cubit.toggleFavorite(program.id),
                    onTap: () => _openDetails(context),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  static void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ProgramsEmptyView extends StatelessWidget {
  const _ProgramsEmptyView(this.state);

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();

    if (state.favoritesOnly &&
        state.favoriteIds.isEmpty &&
        state.query.trim().isEmpty) {
      return EmptyView(
        title: 'No favourites yet',
        message: 'Tap the heart on a workout program to save it here.',
        actionLabel: 'Show all programs',
        onAction: cubit.clearCriteria,
      );
    }
    if (state.hasActiveCriteria) {
      return EmptyView(
        title: 'No programs found',
        message: 'Try a different search term or workout type.',
        actionLabel: 'Clear filters',
        onAction: cubit.clearCriteria,
      );
    }
    return EmptyView(
      title: 'No workout programs',
      message: 'There are no workout programs available right now.',
      actionLabel: 'Reload',
      onAction: cubit.load,
    );
  }
}
