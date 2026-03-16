import 'package:postgres/postgres.dart';

class Database {
  Database(this._connection);

  final Connection _connection;

  static Future<Database> connect(String databaseUrl) async {
    final endpoint = Endpoint.parse(databaseUrl);
    final connection = await Connection.open(
      endpoint,
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
    return Database(connection);
  }

  Future<T> withConnection<T>(Future<T> Function(Connection connection) run) =>
      run(_connection);

  Future<void> close() => _connection.close();
}
