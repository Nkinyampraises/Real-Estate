import 'package:real_estate_secure_backend/src/core/request.dart';
import 'package:real_estate_secure_backend/src/core/result.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('readJsonMap', () {
    test('returns ValidationError when body is empty', () async {
      final request =
          Request('POST', Uri.parse('https://example.test/auth/login'));
      final result = await readJsonMap(request);

      final message = result.fold(
        onSuccess: (_) => null,
        onFailure: (error) => error.message,
      );

      expect(message, 'Request body is required.');
    });

    test('returns ValidationError when JSON is invalid', () async {
      final request = Request(
        'POST',
        Uri.parse('https://example.test/auth/login'),
        body: '{"email": ',
      );
      final result = await readJsonMap(request);

      final message = result.fold(
        onSuccess: (_) => null,
        onFailure: (error) => error.message,
      );

      expect(message, 'Invalid JSON payload.');
    });

    test('returns ValidationError when decoded JSON is not a map', () async {
      final request = Request(
        'POST',
        Uri.parse('https://example.test/auth/login'),
        body: '[1,2,3]',
      );
      final result = await readJsonMap(request);

      final failure = result.fold(
        onSuccess: (_) => null,
        onFailure: (error) => error,
      );

      expect(failure, isA<ValidationError>());
      expect(failure?.message, 'JSON object expected.');
    });

    test('returns parsed map on success', () async {
      final request = Request(
        'POST',
        Uri.parse('https://example.test/auth/login'),
        body: '{"email":"user@example.com"}',
      );
      final result = await readJsonMap(request);

      final parsed = result.fold(
        onSuccess: (payload) => payload,
        onFailure: (_) => <String, dynamic>{},
      );

      expect(parsed, {'email': 'user@example.com'});
    });
  });

  group('typed readers', () {
    test('readString returns string values and null otherwise', () {
      expect(readString({'name': 'Amina'}, 'name'), 'Amina');
      expect(readString({'name': 100}, 'name'), isNull);
      expect(readString({}, 'name'), isNull);
    });

    test('readInt reads int and numeric string values', () {
      expect(readInt({'count': 12}, 'count'), 12);
      expect(readInt({'count': '34'}, 'count'), 34);
      expect(readInt({'count': 'x'}, 'count'), isNull);
      expect(readInt({'count': 3.14}, 'count'), isNull);
    });

    test('readDouble reads numeric and parseable string values', () {
      expect(readDouble({'price': 12}, 'price'), 12.0);
      expect(readDouble({'price': 2.75}, 'price'), 2.75);
      expect(readDouble({'price': '19.5'}, 'price'), 19.5);
      expect(readDouble({'price': 'x'}, 'price'), isNull);
      expect(readDouble({}, 'price'), isNull);
    });
  });
}
