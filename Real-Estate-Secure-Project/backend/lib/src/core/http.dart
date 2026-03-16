import 'dart:convert';

import 'package:shelf/shelf.dart';

Response jsonResponse(
  Object body, {
  int statusCode = 200,
  Map<String, String>? headers,
}) {
  final jsonBody = jsonEncode(body);
  return Response(
    statusCode,
    body: jsonBody,
    headers: {
      'content-type': 'application/json; charset=utf-8',
      if (headers != null) ...headers,
    },
  );
}

Response okResponse(
  Object? data, {
  int statusCode = 200,
  String? requestId,
  Map<String, Object?>? meta,
}) {
  return jsonResponse(
    {
      'status': 'ok',
      'data': data,
      if (meta != null) 'meta': meta,
      if (requestId != null) 'request_id': requestId,
    },
    statusCode: statusCode,
  );
}

Response messageResponse(
  String message, {
  int statusCode = 200,
  String? requestId,
  Map<String, Object?>? meta,
}) =>
    okResponse(
      {'message': message},
      statusCode: statusCode,
      requestId: requestId,
      meta: meta,
    );

Response errorResponse(
  String message, {
  int statusCode = 400,
  String? requestId,
  String? code,
  Map<String, Object?>? details,
}) {
  final payload = {
    'status': 'error',
    'error': {
      'message': message,
      if (code != null) 'code': code,
      if (details != null) 'details': details,
    },
    if (requestId != null) 'request_id': requestId,
  };
  return jsonResponse(payload, statusCode: statusCode);
}
