import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';

const _requestIdKey = 'requestId';
const _requestIdHeader = 'x-request-id';

Middleware requestContextMiddleware() {
  final uuid = const Uuid();
  return (Handler innerHandler) {
    return (Request request) async {
      final requestId = request.headers[_requestIdHeader] ?? uuid.v4();
      final updatedRequest = request.change(
        context: {...request.context, _requestIdKey: requestId},
      );
      final response = await innerHandler(updatedRequest);
      return response.change(headers: {_requestIdHeader: requestId});
    };
  };
}

extension RequestContext on Request {
  String? get requestId => context[_requestIdKey] as String?;
}
