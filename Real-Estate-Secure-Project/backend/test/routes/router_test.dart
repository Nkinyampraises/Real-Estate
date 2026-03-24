import 'package:real_estate_secure_backend/src/routes/router.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('API router', () {
    final router = buildApiRouter();

    test('serves health endpoint at root namespace', () async {
      final response = await router(requestFor('GET', '/health/'));
      final json = await readJsonObject(response);

      expect(response.statusCode, 200);
      expect(json['status'], 'ok');
      expect(json['data']['status'], 'ok');
      expect(json['data']['version'], '0.1.0');
    });

    test('serves health endpoint at /v1 namespace', () async {
      final response = await router(requestFor('GET', '/v1/health/'));
      final json = await readJsonObject(response);

      expect(response.statusCode, 200);
      expect(json['status'], 'ok');
      expect(json['data']['status'], 'ok');
    });

    test('returns 404 for unknown route', () async {
      final response = await router(requestFor('GET', '/v1/nope'));
      expect(response.statusCode, 404);
    });
  });
}
