void main() {
  // Source collection.
  final words = <String>[
    'tree',
    'bananas',
    'sky',
    'orange',
    'pen',
    'planet',
  ];

  // Build a map: each word -> its length.
  final wordLengths = words.associateWith((word) => word.length);

  // Print only entries where the length is greater than 4.
  wordLengths.entries
      .where((entry) => entry.value > 4)
      .forEach((entry) => print('${entry.key}: ${entry.value}'));
}

extension AssociateWithExtension<K> on Iterable<K> {
  // Helper similar to Kotlin's associateWith.
  Map<K, V> associateWith<V>(V Function(K item) transform) {
    return {for (final item in this) item: transform(item)};
  }
}
