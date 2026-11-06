import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/home/home_cubit.dart';
import '../../widgets/featured_plan_card.dart';
import '../../widgets/state_views.dart';
import '../gym_details/gym_details_screen.dart';

/// "See All" for the Featured Plan section.
class FeaturedPlansScreen extends StatelessWidget {
  const FeaturedPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plans = context.select(
      (HomeCubit cubit) => cubit.state.home?.featuredPlans ?? const [],
    );

    void openDetails() => Navigator.of(context).push(GymDetailsScreen.route());

    return Scaffold(
      appBar: AppBar(title: const Text('Featured Plans')),
      body: plans.isEmpty
          ? const EmptyView(
              title: 'No featured plans',
              message: 'Check back later for new plans.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: plans.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final plan = plans[index];
                return FeaturedPlanCard(
                  key: ValueKey(plan.id),
                  title: plan.title,
                  duration: plan.duration,
                  frequency: plan.frequency,
                  actionLabel: plan.actionLabel,
                  imageUrl: plan.imageUrl,
                  durationIconUrl: plan.durationIconUrl,
                  frequencyIconUrl: plan.frequencyIconUrl,
                  onAction: openDetails,
                  onTap: openDetails,
                );
              },
            ),
    );
  }
}
