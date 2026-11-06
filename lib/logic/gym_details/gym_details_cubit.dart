import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/data_exception.dart';
import '../../data/repositories/fitness_repository.dart';
import 'gym_details_state.dart';

class GymDetailsCubit extends Cubit<GymDetailsState> {
  GymDetailsCubit({required this.fitnessRepository})
    : super(const GymDetailsState());

  final FitnessRepository fitnessRepository;

  Future<void> load() async {
    if (state.status == GymDetailsStatus.loading) return;
    emit(state.copyWith(status: GymDetailsStatus.loading, clearError: true));
    try {
      final details = await fitnessRepository.fetchGymDetails();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: GymDetailsStatus.success,
          details: details,
          descriptionExpanded: details.gym.descriptionExpanded,
        ),
      );
    } on DataException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: GymDetailsStatus.error,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: GymDetailsStatus.error,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  void toggleDescription() {
    emit(state.copyWith(descriptionExpanded: !state.descriptionExpanded));
  }

  Future<void> reserve() async {
    final details = state.details;
    if (details == null || !state.canReserve) return;

    emit(state.copyWith(reservationStatus: ReservationStatus.inProgress));
    try {
      await fitnessRepository.reserve(details.gym.id);
      if (isClosed) return;
      emit(state.copyWith(reservationStatus: ReservationStatus.success));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(reservationStatus: ReservationStatus.failure));
    }
  }
}
