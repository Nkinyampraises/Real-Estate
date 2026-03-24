import 'dart:convert';

import 'package:shelf/shelf.dart';

import 'result.dart';

Future<Result<Map<String, dynamic>>> readJsonMap(Request request) async {
  final body = await request.readAsString();
  if (body.trim().isEmpty) {
    return const Failure(ValidationError('Request body is required.'));
  }

  try {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return Success(decoded);
    }
    return const Failure(ValidationError('JSON object expected.'));
  } on FormatException {
    return const Failure(ValidationError('Invalid JSON payload.'));
  }
}

String? readString(Map<String, dynamic> payload, String key) {
  final value = payload[key];
  return value is String ? value : null;
}

int? readInt(Map<String, dynamic> payload, String key) {
  final value = payload[key];
  if (value is int) {
    return value;
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

double? readDouble(Map<String, dynamic> payload, String key) {
  final value = payload[key];
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}
