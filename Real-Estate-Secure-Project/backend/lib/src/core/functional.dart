extension IterableX<T> on Iterable<T> {
  Iterable<R> mapNotNull<R>(R? Function(T value) transform) sync* {
    for (final item in this) {
      final result = transform(item);
      if (result != null) {
        yield result;
      }
    }
  }

  Map<K, List<T>> groupBy<K>(K Function(T value) keyOf) {
    return fold<Map<K, List<T>>>({}, (acc, item) {
      final key = keyOf(item);
      final bucket = acc[key] ?? <T>[];
      acc[key] = [...bucket, item];
      return acc;
    });
  }

  R foldIndexed<R>(R initial, R Function(R acc, int index, T item) combine) {
    var result = initial;
    var index = 0;
    for (final item in this) {
      result = combine(result, index, item);
      index += 1;
    }
    return result;
  }
}
