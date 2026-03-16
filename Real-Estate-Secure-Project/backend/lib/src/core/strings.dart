extension StringOps on String {
  bool hasAnyPrefix(Iterable<String> prefixes) =>
      prefixes.any((prefix) => startsWith(prefix));

  String operator |(String other) => '$this $other';
}
