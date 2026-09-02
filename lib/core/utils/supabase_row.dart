/// Coercion helpers for rows coming back from Supabase.
///
/// PostgREST returns JSON, so a Postgres `integer` can arrive as an `int`, a
/// `numeric` as a `double`, and either can arrive as a `String` depending on
/// the column type and client version. These helpers keep that ambiguity out
/// of the model constructors.
library;

/// Reads [value] as an int, or null if it is absent or not numeric.
int? asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

/// Reads [value] as a bool, falling back to [orElse] when absent.
bool asBool(dynamic value, {bool orElse = false}) {
  if (value is bool) return value;
  if (value is String) {
    if (value == 'true' || value == 't') return true;
    if (value == 'false' || value == 'f') return false;
  }
  return orElse;
}

/// Reads a jsonb array as a list of strings. Returns an empty list when the
/// column is null or not an array.
List<String> asStringList(dynamic value) {
  if (value is List) {
    return value.where((e) => e != null).map((e) => e.toString()).toList();
  }
  return const [];
}
