import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_3/logic/gym_details/gym_details_cubit.dart';
import 'package:lab_3/logic/gym_details/gym_details_state.dart';

import '../helpers/fakes.dart';

void main() {
  GymDetailsCubit buildCubit([String? json]) =>
      GymDetailsCubit(fitnessRepository: repositoryWith(json ?? realJson()));

  blocTest<GymDetailsCubit, GymDetailsState>(
    'load emits loading then success',
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<GymDetailsState>().having(
        (s) => s.status,
        'status',
        GymDetailsStatus.loading,
      ),
      isA<GymDetailsState>()
          .having((s) => s.status, 'status', GymDetailsStatus.success)
          .having((s) => s.details?.gym.name, 'name', 'Mid City Gym Training')
          .having((s) => s.descriptionExpanded, 'expanded', isFalse),
    ],
  );

  blocTest<GymDetailsCubit, GymDetailsState>(
    'load emits error when the data is invalid',
    build: () => buildCubit('oops'),
    act: (cubit) => cubit.load(),
    skip: 1,
    expect: () => [
      isA<GymDetailsState>().having(
        (s) => s.status,
        'status',
        GymDetailsStatus.error,
      ),
    ],
  );

  test('description toggles', () async {
    final cubit = buildCubit();
    await cubit.load();
    cubit.toggleDescription();
    expect(cubit.state.descriptionExpanded, isTrue);
    cubit.toggleDescription();
    expect(cubit.state.descriptionExpanded, isFalse);
    await cubit.close();
  });

  test('reserve goes through in progress to success once', () async {
    final cubit = buildCubit();
    await cubit.load();
    expect(cubit.state.canReserve, isTrue);

    final future = cubit.reserve();
    expect(cubit.state.reservationStatus, ReservationStatus.inProgress);
    expect(cubit.state.canReserve, isFalse);
    await future;
    expect(cubit.state.reservationStatus, ReservationStatus.success);
    expect(cubit.state.canReserve, isFalse);
    await cubit.close();
  });

  test('reserve is ignored when disabled in the data', () async {
    final cubit = buildCubit(
      editedJson((json) {
        final page = json['fitnessGymDetailsPage'] as Map<String, dynamic>;
        final actions = page['actions'] as Map<String, dynamic>;
        (actions['reserve'] as Map<String, dynamic>)['enabled'] = false;
      }),
    );
    await cubit.load();
    await cubit.reserve();
    expect(cubit.state.reservationStatus, ReservationStatus.idle);
    await cubit.close();
  });
}
