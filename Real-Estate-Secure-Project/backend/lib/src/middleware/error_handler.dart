import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';

import '../core/http.dart';
import 'request_context.dart';

Middleware errorHandler(Logger logger) {
  return (Handler innerHandler) {
    return (Request request) async {
      try {
        return await innerHandler(request);
      } catch (error, stackTrace) {
        logger.severe('Unhandled error', error, stackTrace);
        return errorResponse(
          'Unexpected server error',
          statusCode: 500,
          requestId: request.requestId,
        );
      }
    };
  };
}
