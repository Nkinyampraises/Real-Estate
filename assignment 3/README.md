# Assignment 3 - Complex Data Processing (Dart Console App)

This project is a Dart console application that:

1. Filters people whose names start with `A` or `B`
2. Extracts their ages
3. Calculates the average age
4. Prints the result rounded to one decimal place

It also prints the filtered people (`name - age`) in the terminal.

## Data Model

```dart
class Person {
  final String name;
  final int age;

  const Person(this.name, this.age);
}
```

## Sample Data

- Alice, 25
- Bob, 30
- Charlie, 35
- Anna, 22
- Ben, 28

## Requirements

- Dart SDK 3.0.0 or higher

## Run the App

From the project root:

```bash
dart run
```

You can also run the entry file directly:

```bash
dart run bin/main.dart
```

## Expected Output

```text
People (names starting with A or B):
Alice - 25
Bob - 30
Anna - 22
Ben - 28
Average age (names starting with A or B): 26.3
```

## Project Structure

```text
assignment 3/
|- bin/
|  |- main.dart
|  |- assignment_3.dart
|- pubspec.yaml
|- README.md
```
