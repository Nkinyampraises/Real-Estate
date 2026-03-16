import 'package:shelf/shelf.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import 'config.dart';
import 'db/postgres.dart';
import 'middleware/error_handler.dart';
import 'middleware/request_context.dart';
import 'routes/router.dart';

Future<Handler> createApp(AppConfig config, DbPool db) async {
  final router = buildRouter(config, db);

  final pipeline = const Pipeline()
      .addMiddleware(requestContextMiddleware())
      .addMiddleware(errorHandlerMiddleware())
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders(headers: {
        ACCESS_CONTROL_ALLOW_ORIGIN: config.corsAllowOrigin,
        'Access-Control-Allow-Methods': 'GET,POST,PUT,PATCH,DELETE,OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
      }));

  return pipeline.addHandler(router);
}
