import 'package:logging/logging.dart';
import 'package:real_estate_secure_backend/src/middleware/error_handler.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('errorHandler', () {
    test('passes through successful responses', () async {
      final logger = Logger('error_handler_test_success');
      final handler = const Pipeline()
          .addMiddleware(errorHandler(logger))
          .addHandler((_) => Response.ok('ok'));

      final response = await handler(
        Request('GET', Uri.parse('https://example.test/v1/health')),
      );

      expect(response.statusCode, 200);
      expect(await response.readAsString(), 'ok');
    });

    test('returns 500 json error when inner handler throws', () async {
      final logger = Logger('error_handler_test_failure');
      final handler = const Pipeline()
          .addMiddleware(errorHandler(logger))
          .addHandler((_) => throw StateError('boom'));

      final response = await handler(
        Request(
          'GET',
          Uri.parse('https://example.test/v1/health'),
          context: const {'requestId': 'req-500'},
        ),
      );

      final json = await readJsonObject(response);

      expect(response.statusCode, 500);
      expect(json['status'], 'error');
      expect(json['error'], {'message': 'Unexpected server error'});
      expect(json['request_id'], 'req-500');
    });
  });
}
