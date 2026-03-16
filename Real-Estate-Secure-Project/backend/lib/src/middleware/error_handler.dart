import 'package:shelf/shelf.dart';

import '../core/http.dart';
import '../core/result.dart';

Middleware errorHandlerMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      try {
        return await innerHandler(request);
      } on AppError catch (error) {
        return _errorResponse(error);
      } on FormatException catch (error) {
        return jsonResponse(
          {'error': 'invalid_request', 'message': error.message},
          statusCode: 400,
        );
      } catch (error) {
        return jsonResponse(
          {'error': 'internal_error', 'message': 'Unexpected error.'},
          statusCode: 500,
        );
      }
    };
  };
}

Response _errorResponse(AppError error) {
  final statusCode = switch (error) {
    ValidationError _ => 400,
    NotFoundError _ => 404,
    DatabaseError _ => 503,
    _ => 500,
  };

  return jsonResponse(
    {
      'error': error.runtimeType.toString(),
      'message': error.message,
    },
    statusCode: statusCode,
  );
}
