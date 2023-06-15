int nullableDateTimeCompare(
  DateTime? a,
  DateTime? b, {
  bool nullIsMin = false,
}) {
  if (a == null && b == null) {
    return 0;
  }
  if (a == null) {
    return nullIsMin ? -1 : 1;
  }
  if (b == null) {
    return nullIsMin ? 1 : -1;
  }
  return a.compareTo(b);
}
