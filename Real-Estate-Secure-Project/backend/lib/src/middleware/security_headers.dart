import 'package:shelf/shelf.dart';

Middleware securityHeaders() {
  return (Handler innerHandler) {
    return (Request request) async {
      final response = await innerHandler(request);
      return response.change(
        headers: {
          'x-content-type-options': 'nosniff',
          'x-frame-options': 'DENY',
          'referrer-policy': 'no-referrer',
        },
      );
    };
  };
}
