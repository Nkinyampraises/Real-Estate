import 'package:shelf/shelf.dart';

import '../config.dart';
import '../core/functional.dart';
import '../core/health.dart';
import '../core/http.dart';
import '../core/result.dart';
import '../db/postgres.dart';

Response healthHandler(Request request, AppConfig config) {
  final tagSummary = config.serviceTags
      .map((tag) => tag.normalized)
      .fold(<String>[], (acc, tag) => [...acc, tag])
      .toImmutable();

  final tagLine = tagSummary.isEmpty
      ? ''
      : joinWith(',', tagSummary.first, tagSummary.skip(1).toList());

  final version = 'v' & '1';

  final status = HealthStatus(
    status: 'ok',
    environment: config.environment,
    version: version,
    timestamp: DateTime.now(),
    tags: tagSummary,
    tagLine: tagLine,
  );

  return jsonResponse(status.toJson());
}

Future<Response> readyHandler(
  Request request,
  AppConfig config,
  DbPool db,
) async {
  final ping = await db.ping();
  final ready = ping is Ok<void>;
  final errorMessage = ping.when(
    ok: (_) => null,
    err: (error) => error.message,
  );

  final body = {
    'status': ready ? 'ready' : 'degraded',
    'environment': config.environment,
    'dependencies': {
      'database': ready ? 'ok' : 'down',
    },
    'error': errorMessage,
  };

  return jsonResponse(body, statusCode: ready ? 200 : 503);
}
