import 'package:real_estate_secure_backend/src/middleware/request_context.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('requestContextMiddleware', () {
    test('uses incoming x-request-id and exposes it to handlers', () async {
      final handler =
          const Pipeline().addMiddleware(requestContextMiddleware()).addHandler(
                (request) => Response.ok(request.requestId ?? 'missing'),
              );

      final response = await handler(
        Request(
          'GET',
          Uri.parse('https://example.test/v1/health'),
          headers: const {'x-request-id': 'req-fixed-123'},
        ),
      );

      expect(response.headers['x-request-id'], 'req-fixed-123');
      expect(await response.readAsString(), 'req-fixed-123');
    });

    test('generates request id when one is not provided', () async {
      final handler =
          const Pipeline().addMiddleware(requestContextMiddleware()).addHandler(
                (request) => Response.ok(request.requestId ?? 'missing'),
              );

      final response = await handler(
        Request('GET', Uri.parse('https://example.test/v1/health')),
      );

      final generatedHeader = response.headers['x-request-id'];
      final body = await response.readAsString();

      expect(generatedHeader, isNotNull);
      expect(generatedHeader, isNotEmpty);
      expect(body, generatedHeader);
    });
  });
}
