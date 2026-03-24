import 'package:real_estate_secure_backend/src/routes/auth.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('Auth routes', () {
    final router = buildAuthRouter();

    test('POST /register returns 201 for valid payload', () async {
      final response = await router(
        requestFor(
          'POST',
          '/register',
          body: const {
            'email': 'user@example.com',
            'password': 'strongpass',
            'first_name': 'Amina',
            'last_name': 'Ndi',
          },
          context: const {'requestId': 'req-auth-1'},
        ),
      );

      final json = await readJsonObject(response);

      expect(response.statusCode, 201);
      expect(json['status'], 'ok');
      expect(json['data'], {'message': 'registered'});
      expect(json['request_id'], 'req-auth-1');
    });

    test('POST /register returns 422 when password is too short', () async {
      final response = await router(
        requestFor(
          'POST',
          '/register',
          body: const {
            'email': 'user@example.com',
            'password': 'short',
            'first_name': 'Amina',
            'last_name': 'Ndi',
          },
        ),
      );

      final json = await readJsonObject(response);

      expect(response.statusCode, 422);
      expect(json['status'], 'error');
      expect(json['error']['code'], 'VALIDATION_ERROR');
      expect(json['error']['message'], 'Password must be 8+ characters.');
    });

    test('POST /login returns 422 when fields are missing', () async {
      final response = await router(
        requestFor(
          'POST',
          '/login',
          body: const {'email': 'user@example.com'},
        ),
      );

      final json = await readJsonObject(response);

      expect(response.statusCode, 422);
      expect(json['error']['code'], 'VALIDATION_ERROR');
      expect(json['error']['message'], 'Email and password are required.');
    });

    test('POST /verify-email returns 422 when token is missing', () async {
      final response = await router(
        requestFor('POST', '/verify-email', body: const {'foo': 'bar'}),
      );

      final json = await readJsonObject(response);

      expect(response.statusCode, 422);
      expect(json['error']['message'], 'Missing required fields: token.');
    });

    test('POST /register returns 400 when body is invalid json', () async {
      final response = await router(
        Request(
          'POST',
          Uri.parse('https://example.test/register'),
          headers: const {'content-type': 'application/json'},
          body: '{"email": ',
        ),
      );

      final json = await readJsonObject(response);

      expect(response.statusCode, 400);
      expect(json['error']['code'], 'INVALID_REQUEST');
      expect(json['error']['message'], 'Invalid JSON payload.');
    });
  });
}
