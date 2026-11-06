import 'package:equatable/equatable.dart';

import 'json_map.dart';

class Amenity extends Equatable {
  const Amenity({required this.id, required this.name, this.iconUrl});

  factory Amenity.fromJson(JsonMap json) => Amenity(
    id: json['id'] as String,
    name: json['name'] as String,
    iconUrl: json['iconUrl'] as String?,
  );

  final String id;
  final String name;
  final String? iconUrl;

  @override
  List<Object?> get props => [id, name, iconUrl];
}

class Pricing extends Equatable {
  const Pricing({
    required this.amount,
    required this.currency,
    required this.period,
  });

  factory Pricing.fromJson(JsonMap json) => Pricing(
    amount: (json['amount'] as num).toDouble(),
    currency: json['currency'] as String,
    period: json['period'] as String,
  );

  static const Map<String, String> _symbols = {
    'USD': r'$',
    'EUR': '€',
    'GBP': '£',
    'MDL': 'L ',
  };

  final double amount;
  final String currency;
  final String period;

  /// "$69.00"
  String get amountLabel {
    final symbol = _symbols[currency.toUpperCase()];
    final value = amount.toStringAsFixed(2);
    return symbol == null ? '$value $currency' : '$symbol$value';
  }

  /// "/week"
  String get periodLabel => '/$period';

  @override
  List<Object?> get props => [amount, currency, period];
}

class Gym extends Equatable {
  const Gym({
    required this.id,
    required this.name,
    required this.location,
    required this.heroImageUrl,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.descriptionExpanded,
    required this.amenities,
    required this.pricing,
  });

  factory Gym.fromJson(JsonMap json) => Gym(
    id: json['id'] as String,
    name: json['name'] as String,
    location: json['location'] as String,
    heroImageUrl: json['heroImageUrl'] as String,
    rating: (json['rating'] as num).toDouble(),
    reviewCount: (json['reviewCount'] as num).toInt(),
    description: json['description'] as String? ?? '',
    descriptionExpanded: json['descriptionExpanded'] as bool? ?? false,
    amenities: parseList(json['amenities'], Amenity.fromJson),
    pricing: Pricing.fromJson(json['pricing'] as JsonMap),
  );

  final String id;
  final String name;
  final String location;
  final String heroImageUrl;
  final double rating;
  final int reviewCount;
  final String description;
  final bool descriptionExpanded;
  final List<Amenity> amenities;
  final Pricing pricing;

  @override
  List<Object?> get props => [
    id,
    name,
    location,
    heroImageUrl,
    rating,
    reviewCount,
    description,
    descriptionExpanded,
    amenities,
    pricing,
  ];
}

class GymDetailsActions extends Equatable {
  const GymDetailsActions({
    required this.reserveLabel,
    required this.reserveEnabled,
    this.backIconUrl,
    this.moreIconUrl,
    this.ratingIconUrl,
  });

  factory GymDetailsActions.fromJson(JsonMap json) {
    final reserve = json['reserve'] as JsonMap?;
    return GymDetailsActions(
      reserveLabel: reserve?['label'] as String? ?? 'Reserve',
      reserveEnabled: reserve?['enabled'] as bool? ?? true,
      backIconUrl: json['backIconUrl'] as String?,
      moreIconUrl: json['moreIconUrl'] as String?,
      ratingIconUrl: json['ratingIconUrl'] as String?,
    );
  }

  final String reserveLabel;
  final bool reserveEnabled;
  final String? backIconUrl;
  final String? moreIconUrl;
  final String? ratingIconUrl;

  @override
  List<Object?> get props => [
    reserveLabel,
    reserveEnabled,
    backIconUrl,
    moreIconUrl,
    ratingIconUrl,
  ];
}

/// Everything shown on the gym details page (`fitnessGymDetailsPage`).
class GymDetails extends Equatable {
  const GymDetails({required this.gym, required this.actions});

  factory GymDetails.fromJson(JsonMap json) => GymDetails(
    gym: Gym.fromJson(json['gym'] as JsonMap),
    actions: GymDetailsActions.fromJson(
      json['actions'] as JsonMap? ?? const <String, dynamic>{},
    ),
  );

  final Gym gym;
  final GymDetailsActions actions;

  @override
  List<Object?> get props => [gym, actions];
}
