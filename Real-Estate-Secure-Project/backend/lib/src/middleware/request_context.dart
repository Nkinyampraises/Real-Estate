import 'dart:math';

import 'package:shelf/shelf.dart';

const _requestIdKey = 'request_id';
const _requestStartKey = 'request_start';
const _requestIdHeader = 'x-request-id';

Middleware requestContextMiddleware({int idBytes = 16}) {
  return (Handler innerHandler) {
    return (Request request) async {
      final existingId = request.headers[_requestIdHeader];
      final requestId = existingId?.trim().isNotEmpty == true
          ? existingId!.trim()
          : _generateRequestId(bytes: idBytes);
      final updatedRequest = request.change(context: {
        _requestIdKey: requestId,
        _requestStartKey: DateTime.now().toUtc(),
      });

      final response = await innerHandler(updatedRequest);
      return response.change(headers: {
        _requestIdHeader: requestId,
      });
    };
  };
}

String _generateRequestId({int bytes = 16}) {
  final random = Random.secure();
  final values = List<int>.generate(bytes, (_) => random.nextInt(256));
  return values.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
}

extension RequestContextX on Request {
  String get requestId => (context[_requestIdKey] as String?) ?? '';

  DateTime? get requestStart => context[_requestStartKey] as DateTime?;
}
