import 'package:shared_preferences/shared_preferences.dart';

import '../data_exception.dart';

/// Persists the ids of the workout programs marked as favourite.
class FavoritesRepository {
  static const String _storageKey = 'favorite_program_ids';

  Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_storageKey) ?? const <String>[]).toSet();
  }

  Future<void> save(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setStringList(_storageKey, ids.toList()..sort());
    if (!saved) {
      throw const DataException('Could not save your favourites.');
    }
  }
}
