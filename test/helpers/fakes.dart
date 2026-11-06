import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lab_3/data/repositories/favorites_repository.dart';
import 'package:lab_3/data/repositories/fitness_repository.dart';

/// The real data file shipped with the app.
String realJson() =>
    File(FitnessRepository.defaultAssetPath).readAsStringSync();

/// Asset bundle serving in-memory strings; missing keys throw like the real
/// bundle does.
class FakeAssetBundle extends CachingAssetBundle {
  FakeAssetBundle(this.contents);

  final Map<String, String> contents;

  @override
  Future<ByteData> load(String key) async {
    final value = contents[key];
    if (value == null) throw FlutterError('Unable to load asset: "$key".');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(value)));
  }
}

FitnessRepository repositoryWith(String? json) => FitnessRepository(
  bundle: FakeAssetBundle(
    json == null ? {} : {FitnessRepository.defaultAssetPath: json},
  ),
  latency: Duration.zero,
);

/// Returns the real JSON with [edit] applied to the decoded map.
String editedJson(void Function(Map<String, dynamic> json) edit) {
  final json = jsonDecode(realJson()) as Map<String, dynamic>;
  edit(json);
  return jsonEncode(json);
}

/// In-memory favourites, optionally failing on save.
class InMemoryFavoritesRepository extends FavoritesRepository {
  InMemoryFavoritesRepository({Set<String>? initial, this.failOnSave = false})
    : stored = {...?initial};

  Set<String> stored;
  bool failOnSave;

  @override
  Future<Set<String>> load() async => {...stored};

  @override
  Future<void> save(Set<String> ids) async {
    if (failOnSave) throw Exception('disk full');
    stored = {...ids};
  }
}
