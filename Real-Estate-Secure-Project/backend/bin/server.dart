import 'dart:io';

import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:real_estate_secure_backend/src/app.dart';
import 'package:real_estate_secure_backend/src/config.dart';
import 'package:real_estate_secure_backend/src/db/postgres.dart';

Future<void> main(List<String> args) async {
  dotenv.load();

  final config = AppConfig.fromEnv(dotenv.env);
  final db = DbPool(config.database);
  final handler = await createApp(config, db);

  final server = await shelf_io.serve(
    handler,
    InternetAddress.anyIPv4,
    config.port,
  );

  stdout.writeln(
    'Real Estate Secure API listening on '
    'http://${server.address.host}:${server.port} (${config.environment})',
  );

  _registerShutdownHooks(server, db);
}

void _registerShutdownHooks(HttpServer server, DbPool db) {
  Future<void> shutdown(String signal) async {
    stdout.writeln('Shutting down ($signal)...');
    await db.close();
    await server.close(force: true);
  }

  for (final signal in [ProcessSignal.sigint, ProcessSignal.sigterm]) {
    signal.watch().listen((_) => shutdown(signal.toString()));
  }
}
