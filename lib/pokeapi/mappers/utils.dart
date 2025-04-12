T? handleNullField<T>(
  dynamic field,
  T Function(Map<String, dynamic>) callback,
) {
  return field == null ? null : callback(field);
}
