import 'package:logging/logging.dart';
import 'package:real_estate_secure_backend/src/config.dart';
import 'package:test/test.dart';

void main() {
  group('AppConfig.fromEnv', () {
    test('uses defaults when env values are missing', () {
      final config = AppConfig.fromEnv((_) => null);

      expect(config.environment, 'development');
      expect(config.port, 8080);
      expect(config.databaseUrl, '');
      expect(config.jwtSecret, 'change-me');
      expect(config.logLevel, Level.INFO);
      expect(config.isProduction, isFalse);
    });

    test('parses explicit values from env', () {
      final values = <String, String>{
        'APP_ENV': 'production',
        'PORT': '9090',
        'DATABASE_URL': 'postgres://user:pass@localhost:5432/app',
        'JWT_SECRET': 'super-secret',
        'LOG_LEVEL': 'error',
      };

      final config = AppConfig.fromEnv((key) => values[key]);

      expect(config.environment, 'production');
      expect(config.port, 9090);
      expect(config.databaseUrl, 'postgres://user:pass@localhost:5432/app');
      expect(config.jwtSecret, 'super-secret');
      expect(config.logLevel, Level.SEVERE);
      expect(config.isProduction, isTrue);
    });

    test('falls back to info log level for unknown values', () {
      final config = AppConfig.fromEnv(
        (key) => key == 'LOG_LEVEL' ? 'trace-ish' : null,
      );

      expect(config.logLevel, Level.INFO);
    });
  });
}
