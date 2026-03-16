import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import 'config.dart';
import 'middleware/error_handler.dart';
import 'middleware/request_context.dart';
import 'middleware/security_headers.dart';
import 'routes/router.dart';

Handler buildHandler(AppConfig config, Logger logger) {
  final router = buildApiRouter();

  return Pipeline()
      .addMiddleware(requestContextMiddleware())
      .addMiddleware(errorHandler(logger))
      .addMiddleware(_requestLogger(logger))
      .addMiddleware(securityHeaders())
      .addMiddleware(corsHeaders())
      .addHandler(router);
}

Middleware _requestLogger(Logger logger) {
  return (Handler innerHandler) {
    return (Request request) async {
      final stopwatch = Stopwatch()..start();
      final response = await innerHandler(request);
      stopwatch.stop();

      logger.info(
        '${request.method} ${request.requestedUri.path} '
        '${response.statusCode} ${stopwatch.elapsedMilliseconds}ms '
        'request_id=${request.requestId ?? 'unknown'}',
      );

      return response;
    };
  };
}
