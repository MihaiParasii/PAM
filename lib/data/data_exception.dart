/// Thrown by the data layer when content cannot be read or parsed.
class DataException implements Exception {
  const DataException(this.message, [this.cause]);

  /// Human readable message, safe to show in the UI.
  final String message;

  /// Underlying error, kept for debugging.
  final Object? cause;

  @override
  String toString() => cause == null
      ? 'DataException: $message'
      : 'DataException: $message ($cause)';
}
