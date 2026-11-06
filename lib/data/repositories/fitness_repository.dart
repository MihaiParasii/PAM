import 'dart:convert';

import 'package:flutter/services.dart';

import '../data_exception.dart';
import '../models/fitness_home.dart';
import '../models/gym_details.dart';
import '../models/json_map.dart';

/// Loads the app content from the JSON file bundled in `assets/data`.
///
/// Every call reads the asset asynchronously and waits [latency] first so
/// the loading states are visible, the same way a network call would be.
class FitnessRepository {
  FitnessRepository({
    AssetBundle? bundle,
    this.assetPath = defaultAssetPath,
    this.latency = const Duration(milliseconds: 800),
  }) : _bundle = bundle ?? rootBundle;

  static const String defaultAssetPath = 'assets/data/fitness_data.json';

  final AssetBundle _bundle;
  final String assetPath;
  final Duration latency;

  Future<FitnessHome> fetchHome() async {
    final json = await _loadJson();
    return _parse(
      () => FitnessHome.fromJson(json['fitnessHomePage'] as JsonMap),
    );
  }

  Future<GymDetails> fetchGymDetails() async {
    final json = await _loadJson();
    return _parse(
      () => GymDetails.fromJson(json['fitnessGymDetailsPage'] as JsonMap),
    );
  }

  /// Simulates sending a reservation for [gymId].
  Future<void> reserve(String gymId) async {
    await Future<void>.delayed(latency);
  }

  Future<JsonMap> _loadJson() async {
    if (latency > Duration.zero) {
      await Future<void>.delayed(latency);
    }

    final String raw;
    try {
      raw = await _bundle.loadString(assetPath, cache: false);
    } catch (error) {
      throw DataException('Could not read the fitness data.', error);
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! JsonMap) {
        throw const FormatException('The root element must be an object.');
      }
      return decoded;
    } on FormatException catch (error) {
      throw DataException('The fitness data is not valid JSON.', error);
    }
  }

  T _parse<T>(T Function() parse) {
    try {
      return parse();
    } on TypeError catch (error) {
      throw DataException('The fitness data has an unexpected format.', error);
    }
  }
}
