import 'dart:convert';

import 'package:shelf/shelf.dart';

Response jsonResponse(
  Object body, {
  int statusCode = 200,
  Map<String, String> headers = const {},
}) {
  final mergedHeaders = {
    'content-type': 'application/json',
    ...headers,
  };

  return Response(statusCode, body: jsonEncode(body), headers: mergedHeaders);
}
