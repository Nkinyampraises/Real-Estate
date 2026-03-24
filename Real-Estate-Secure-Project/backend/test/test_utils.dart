import 'dart:convert';

import 'package:shelf/shelf.dart';

Request requestFor(
  String method,
  String path, {
  Object? body,
  Map<String, String>? headers,
  Map<String, Object>? context,
}) {
  final resolvedHeaders = <String, String>{
    if (body != null) 'content-type': 'application/json',
    if (headers != null) ...headers,
  };

  return Request(
    method,
    Uri.parse('https://example.test$path'),
    headers: resolvedHeaders,
    context: context,
    body: body == null ? null : jsonEncode(body),
  );
}

Future<Map<String, dynamic>> readJsonObject(Response response) async {
  final raw = await response.readAsString();
  final decoded = jsonDecode(raw);
  return decoded as Map<String, dynamic>;
}
