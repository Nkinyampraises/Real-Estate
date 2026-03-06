# Assignment 2 - Word Length Map (Dart Console App)

This project demonstrates transforming a collection in Dart:

- Start with a `List<String>`
- Convert it to a `Map<String, int>` where:
  - key = word
  - value = word length
- Filter and print only entries with length greater than `4`

## Task

Given a list of strings, create a map where the keys are the strings and the values are their lengths.  
Then print only the entries where the length is greater than 4.

## Project Structure

- `bin/main.dart` - Main logic for map transformation and filtering
- `bin/assignment_2.dart` - Package entrypoint that forwards to `main.dart`
- `pubspec.yaml` - Dart package configuration

## Requirements

- Dart SDK `^3.11.0`

## Run

From the project root:

```powershell
dart run
```

Or run the main file directly:

```powershell
dart bin/main.dart
```

## Example Output

```text
bananas: 7
orange: 6
planet: 6
```

## Code Highlight

The map is created with a custom `associateWith` extension:

```dart
final wordLengths = words.associateWith((word) => word.length);
```

Then filtered with:

```dart
wordLengths.entries
    .where((entry) => entry.value > 4)
    .forEach((entry) => print('${entry.key}: ${entry.value}'));
```
