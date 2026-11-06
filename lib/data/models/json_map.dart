typedef JsonMap = Map<String, dynamic>;

/// Casts a JSON list into a list of models, skipping nothing: a malformed
/// element throws a [TypeError] which the repository reports as a data error.
List<T> parseList<T>(Object? json, T Function(JsonMap json) fromJson) {
  if (json == null) return const [];
  return (json as List<dynamic>)
      .map((item) => fromJson(item as JsonMap))
      .toList(growable: false);
}
