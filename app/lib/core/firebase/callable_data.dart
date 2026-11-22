/// Normalizes Cloud Functions callable `data` into a string-keyed map.
///
/// FlutterFire often returns `Map<Object?, Object?>`; casting to
/// `Map<String, dynamic>` directly can throw at runtime.
Map<String, dynamic> callableDataMap(Object? data) {
  if (data == null) return const {};
  if (data is Map<String, dynamic>) return data;
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return const {};
}
