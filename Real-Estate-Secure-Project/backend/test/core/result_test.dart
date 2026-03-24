import 'package:real_estate_secure_backend/src/core/result.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('map transforms success values', () {
      const result = Success<int>(5);

      final mapped = result.map((value) => value * 2);
      final mappedValue = mapped.fold(
        onSuccess: (value) => value,
        onFailure: (_) => -1,
      );

      expect(mappedValue, 10);
    });

    test('map keeps failure unchanged', () {
      const error = ValidationError('bad input');
      const result = Failure<int>(error);

      final mapped = result.map((value) => value * 2);
      final mappedError = mapped.fold(
        onSuccess: (_) => null,
        onFailure: (appError) => appError,
      );

      expect(mappedError, same(error));
      expect(mappedError, isA<ValidationError>());
      expect(mappedError?.message, 'bad input');
    });

    test('fold calls success branch for Success', () {
      const result = Success<String>('ok');

      final value = result.fold(
        onSuccess: (text) => text.toUpperCase(),
        onFailure: (_) => 'FAIL',
      );

      expect(value, 'OK');
    });

    test('fold calls failure branch for Failure', () {
      const result = Failure<String>(NotFoundError('missing'));

      final value = result.fold(
        onSuccess: (_) => 'OK',
        onFailure: (error) => error.message,
      );

      expect(value, 'missing');
    });
  });
}
