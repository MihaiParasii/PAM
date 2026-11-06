import 'package:equatable/equatable.dart';

import '../../data/models/gym_details.dart';

enum GymDetailsStatus { initial, loading, success, error }

enum ReservationStatus { idle, inProgress, success, failure }

class GymDetailsState extends Equatable {
  const GymDetailsState({
    this.status = GymDetailsStatus.initial,
    this.details,
    this.descriptionExpanded = false,
    this.reservationStatus = ReservationStatus.idle,
    this.errorMessage,
  });

  final GymDetailsStatus status;
  final GymDetails? details;
  final bool descriptionExpanded;
  final ReservationStatus reservationStatus;
  final String? errorMessage;

  bool get isLoading =>
      status == GymDetailsStatus.initial || status == GymDetailsStatus.loading;

  bool get canReserve =>
      details != null &&
      details!.actions.reserveEnabled &&
      reservationStatus != ReservationStatus.inProgress &&
      reservationStatus != ReservationStatus.success;

  GymDetailsState copyWith({
    GymDetailsStatus? status,
    GymDetails? details,
    bool? descriptionExpanded,
    ReservationStatus? reservationStatus,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GymDetailsState(
      status: status ?? this.status,
      details: details ?? this.details,
      descriptionExpanded: descriptionExpanded ?? this.descriptionExpanded,
      reservationStatus: reservationStatus ?? this.reservationStatus,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    details,
    descriptionExpanded,
    reservationStatus,
    errorMessage,
  ];
}
