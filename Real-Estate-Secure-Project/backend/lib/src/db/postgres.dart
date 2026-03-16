import 'dart:async';

import 'package:postgres/postgres.dart';

import '../config.dart';
import '../core/result.dart';

class DbPool {
  final DatabaseConfig config;
  Connection? _connection;
  bool _isOpen = false;

  DbPool(this.config);

  Future<Connection> _open() async {
    final existing = _connection;
    if (existing != null && _isOpen) {
      return existing;
    }

    final endpoint = Endpoint(
      host: config.host,
      port: config.port,
      database: config.name,
      username: config.user,
      password: config.password,
    );

    final settings = ConnectionSettings(
      sslMode: config.useSsl ? SslMode.require : SslMode.disable,
    );

    final connection = await Connection.open(endpoint, settings: settings);
    _connection = connection;
    _isOpen = true;
    return connection;
  }

  Future<Connection> connect() => _open();

  Future<AppResult<void>> ping({Duration timeout = const Duration(seconds: 2)}) async {
    try {
      final connection = await _open();
      await connection.execute('SELECT 1').timeout(timeout);
      return const Ok(null);
    } on TimeoutException {
      return const Err(DatabaseError('Database ping timed out.'));
    } catch (error) {
      return Err(DatabaseError('Database ping failed: $error'));
    }
  }

  Future<void> close() async {
    final connection = _connection;
    if (connection == null) {
      return;
    }

    await connection.close();
    _connection = null;
    _isOpen = false;
  }
}
