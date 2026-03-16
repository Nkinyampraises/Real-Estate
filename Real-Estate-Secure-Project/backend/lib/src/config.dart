import 'core/functional.dart';

class AppConfig {
  final String environment;
  final int port;
  final String corsAllowOrigin;
  final DatabaseConfig database;
  final List<String> serviceTags;

  const AppConfig({
    required this.environment,
    required this.port,
    required this.corsAllowOrigin,
    required this.database,
    this.serviceTags = const [],
  });

  factory AppConfig.fromEnv(Map<String, String> env) {
    final tags = parseCsv(env['SERVICE_TAGS'] ?? '').toImmutable();

    return AppConfig(
      environment: env['APP_ENV'] ?? 'development',
      port: int.tryParse(env['APP_PORT'] ?? '') ?? 8080,
      corsAllowOrigin: env['CORS_ALLOW_ORIGIN'] ?? '*',
      database: DatabaseConfig.fromEnv(env),
      serviceTags: tags,
    );
  }

  AppConfig copyWith({
    String? environment,
    int? port,
    String? corsAllowOrigin,
    DatabaseConfig? database,
    List<String>? serviceTags,
  }) {
    return AppConfig(
      environment: environment ?? this.environment,
      port: port ?? this.port,
      corsAllowOrigin: corsAllowOrigin ?? this.corsAllowOrigin,
      database: database ?? this.database,
      serviceTags: serviceTags ?? this.serviceTags,
    );
  }
}

class DatabaseConfig {
  final String host;
  final int port;
  final String name;
  final String user;
  final String password;
  final bool useSsl;

  const DatabaseConfig({
    required this.host,
    required this.port,
    required this.name,
    required this.user,
    required this.password,
    required this.useSsl,
  });

  factory DatabaseConfig.fromEnv(Map<String, String> env) {
    return DatabaseConfig(
      host: env['DATABASE_HOST'] ?? 'localhost',
      port: int.tryParse(env['DATABASE_PORT'] ?? '') ?? 5432,
      name: env['DATABASE_NAME'] ?? 'real_estate_secure',
      user: env['DATABASE_USER'] ?? 'postgres',
      password: env['DATABASE_PASSWORD'] ?? '',
      useSsl: (env['DATABASE_SSL'] ?? 'false').toLowerCase() == 'true',
    );
  }
}
