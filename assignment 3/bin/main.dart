class Person {
  final String name;
  final int age;

  const Person(this.name, this.age);
}

void main() {
  // Source data.
  final people = <Person>[
    const Person('Alice', 25),
    const Person('Bob', 30),
    const Person('Charlie', 35),
    const Person('Anna', 22),
    const Person('Ben', 28),
  ];

  // Keep only people whose names start with A or B.
  final filteredPeople = people
      .where((person) {
        // Normalize spacing and letter case before checking the first letter.
        final name = person.name.trim().toUpperCase();
        return name.startsWith('A') || name.startsWith('B');
      })
      .toList();

  // Display only the filtered people in the terminal.
  print('People (names starting with A or B):');
  for (final person in filteredPeople) {
    print('${person.name} - ${person.age}');
  }

  // Extract ages from the filtered list.
  final ages = filteredPeople.map((person) => person.age).toList();
  // Compute average age safely (0.0 if there are no matching people).
  final averageAge =
      ages.isEmpty ? 0.0 : ages.reduce((a, b) => a + b) / ages.length;

  // Print the average rounded to one decimal place.
  print('Average age (names starting with A or B): ${averageAge.toStringAsFixed(1)}');
}
