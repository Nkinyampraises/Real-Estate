/// Returns a new list containing only the values that match [predicate].
List<int> processList(List<int> numbers, bool Function(int) predicate) {
  final result = <int>[];
  for (final number in numbers) {
    if (predicate(number)) {
      result.add(number);
    }
  }
  return result;
}

/// Returns `true` if [number] is prime, otherwise `false`.
bool isPrime(int number) {
  if (number < 2) return false;
  for (var i = 2; i * i <= number; i++) {
    if (number % i == 0) return false;
  }
  return true;
}

/// Runs a console demo that prints even, odd, and prime numbers.
void main() {
  // Input values to filter with different predicates.
  final numbers = [1, 2, 3, 4, 5, 6];
  final evens = processList(numbers, (n) => n.isEven);
  final odds = processList(numbers, (n) => n.isOdd);
  final primes = processList(numbers, isPrime);

  print('Even numbers: $evens');
  print('Odd numbers: $odds');
  print('Prime numbers: $primes');
}
