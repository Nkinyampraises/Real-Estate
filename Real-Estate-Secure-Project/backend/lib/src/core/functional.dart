List<String> parseCsv(
  String raw, {
  String separator = ',',
  bool trimValues = true,
}) {
  final parts = raw.split(separator);
  final normalized = trimValues
      ? parts.map((value) => value.trim())
      : parts.map((value) => value);
  return normalized.where((value) => value.isNotEmpty).toList(growable: false);
}

String joinWith(String separator, String first, [List<String> rest = const []]) =>
    ([first, ...rest]).join(separator);

extension StringX on String {
  String get normalized => trim().toLowerCase();

  String operator &(String other) => '$this$other';
}

extension IterableX<T> on Iterable<T> {
  List<T> toImmutable() => List.unmodifiable(this);

  int countWhere(bool Function(T item) predicate) =>
      fold(0, (count, item) => predicate(item) ? count + 1 : count);
}
