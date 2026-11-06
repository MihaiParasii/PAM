import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/gym_details.dart';
import '../../../data/repositories/fitness_repository.dart';
import '../../../logic/gym_details/gym_details_cubit.dart';
import '../../../logic/gym_details/gym_details_state.dart';
import '../../widgets/amenity_tile.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/circle_icon_button.dart';
import '../../widgets/expandable_description.dart';
import '../../widgets/network_svg_icon.dart';
import '../../widgets/price_bottom_bar.dart';
import '../../widgets/rating_row.dart';
import '../../widgets/state_views.dart';

/// "30. Fitness" gym details screen, driven by [GymDetailsCubit].
class GymDetailsScreen extends StatelessWidget {
  const GymDetailsScreen({super.key});

  /// Route that creates the cubit and starts loading the details.
  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (context) => BlocProvider(
        create: (context) => GymDetailsCubit(
          fitnessRepository: context.read<FitnessRepository>(),
        )..load(),
        child: const GymDetailsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GymDetailsCubit, GymDetailsState>(
      listenWhen: (previous, current) =>
          previous.reservationStatus != current.reservationStatus,
      listener: _onReservationChanged,
      builder: (context, state) {
        switch (state.status) {
          case GymDetailsStatus.initial:
          case GymDetailsStatus.loading:
            return const _PlainScaffold(
              child: LoadingView(message: 'Loading gym details...'),
            );
          case GymDetailsStatus.error:
            return _PlainScaffold(
              child: ErrorView(
                message: state.errorMessage ?? 'Could not load the details.',
                onRetry: () => context.read<GymDetailsCubit>().load(),
              ),
            );
          case GymDetailsStatus.success:
            return _GymDetailsContent(state: state, details: state.details!);
        }
      },
    );
  }

  static void _onReservationChanged(
    BuildContext context,
    GymDetailsState state,
  ) {
    final String message;
    switch (state.reservationStatus) {
      case ReservationStatus.success:
        final gym = state.details!.gym;
        message =
            'Reserved ${gym.name} for '
            '${gym.pricing.amountLabel} ${gym.pricing.periodLabel}';
      case ReservationStatus.failure:
        message = 'Reservation failed. Please try again.';
      case ReservationStatus.idle:
      case ReservationStatus.inProgress:
        return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Scaffold with a regular app bar, used while loading or on error so the
/// user can always go back.
class _PlainScaffold extends StatelessWidget {
  const _PlainScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: child,
      ),
    );
  }
}

enum _MoreAction { refresh }

class _GymDetailsContent extends StatelessWidget {
  const _GymDetailsContent({required this.state, required this.details});

  final GymDetailsState state;
  final GymDetails details;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GymDetailsCubit>();
    final gym = details.gym;
    final actions = details.actions;
    final topInset = MediaQuery.paddingOf(context).top;
    final heroHeight = MediaQuery.sizeOf(context).height * 0.42;
    final reserved = state.reservationStatus == ReservationStatus.success;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        bottomNavigationBar: PriceBottomBar(
          price: gym.pricing.amountLabel,
          period: gym.pricing.periodLabel,
          actionLabel: reserved ? 'Reserved' : actions.reserveLabel,
          isLoading: state.reservationStatus == ReservationStatus.inProgress,
          onAction: state.canReserve ? cubit.reserve : null,
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: heroHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(url: gym.heroImageUrl),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [Color(0x66000000), Colors.transparent],
                        ),
                      ),
                    ),
                    Positioned(
                      top: topInset + 12,
                      left: 24,
                      child: CircleIconButton(
                        tooltip: 'Back',
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        onTap: () => Navigator.of(context).maybePop(),
                        child: NetworkSvgIcon(
                          url: actions.backIconUrl,
                          fallback: Icons.arrow_back,
                          size: 24,
                          fallbackColor: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      top: topInset + 16,
                      right: 12,
                      child: PopupMenuButton<_MoreAction>(
                        tooltip: 'More',
                        icon: NetworkSvgIcon(
                          url: actions.moreIconUrl,
                          fallback: Icons.more_vert,
                          size: 26,
                          fallbackColor: Colors.white,
                        ),
                        onSelected: (action) {
                          switch (action) {
                            case _MoreAction.refresh:
                              cubit.load();
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: _MoreAction.refresh,
                            child: Text('Refresh details'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList.list(
                children: [
                  RatingRow(
                    rating: gym.rating,
                    reviewCount: gym.reviewCount,
                    iconUrl: actions.ratingIconUrl,
                  ),
                  const SizedBox(height: 12),
                  Text(gym.name, style: AppTextStyles.pageTitle),
                  const SizedBox(height: 12),
                  Text(
                    gym.location,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  if (gym.description.isNotEmpty) ...[
                    ExpandableDescription(
                      text: gym.description,
                      expanded: state.descriptionExpanded,
                      onToggle: cubit.toggleDescription,
                    ),
                    const SizedBox(height: 24),
                  ],
                  const Text('Amenities', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 16),
                  if (gym.amenities.isEmpty)
                    const Text(
                      'No amenities listed for this gym.',
                      style: AppTextStyles.caption,
                    )
                  else
                    TwoColumnGrid(
                      children: [
                        for (final amenity in gym.amenities)
                          AmenityTile(
                            key: ValueKey(amenity.id),
                            icon: NetworkSvgIcon(
                              url: amenity.iconUrl,
                              fallback: Icons.check_circle_outline,
                              size: 22,
                              fallbackColor: AppColors.textSecondary,
                            ),
                            label: amenity.name,
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
