import 'package:real_estate_secure_backend/src/middleware/security_headers.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  test('securityHeaders adds expected security response headers', () async {
    final handler = const Pipeline()
        .addMiddleware(securityHeaders())
        .addHandler((_) => Response.ok('ok'));

    final response = await handler(
      Request('GET', Uri.parse('https://example.test/v1/health')),
    );

    expect(response.headers['x-content-type-options'], 'nosniff');
    expect(response.headers['x-frame-options'], 'DENY');
    expect(response.headers['referrer-policy'], 'no-referrer');
  });
}
