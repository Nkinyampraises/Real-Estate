import 'package:postgres/postgres.dart';

import '../core/result.dart';
import '../db/postgres.dart';
import '../models/currency.dart';

class CurrencyRepository {
  final DbPool db;

  CurrencyRepository(this.db);

  Future<AppResult<List<Currency>>> listActive() async {
    const sql = '''
SELECT code, name, symbol, decimals, is_active
FROM currencies
WHERE is_active = TRUE
ORDER BY code ASC;
''';

    try {
      final connection = await db.connect();
      final result = await connection.execute(sql);
      final currencies = result
          .map(Currency.fromRow)
          .toList(growable: false);
      return Ok(currencies);
    } catch (error) {
      return Err(DatabaseError('Failed to load currencies: $error'));
    }
  }

  Future<AppResult<List<ExchangeRate>>> listRates({
    required String baseCurrency,
    String? quoteCurrency,
    int limit = 50,
  }) async {
    final buffer = StringBuffer('''
SELECT base_currency, quote_currency, rate, provider, effective_at
FROM currency_exchange_rates
WHERE base_currency = @base
''');

    final parameters = <String, Object?>{
      'base': baseCurrency,
      'limit': limit,
    };

    if (quoteCurrency != null && quoteCurrency.isNotEmpty) {
      buffer.writeln('AND quote_currency = @quote');
      parameters['quote'] = quoteCurrency;
    }

    buffer.writeln('ORDER BY effective_at DESC');
    buffer.writeln('LIMIT @limit');

    try {
      final connection = await db.connect();
      final result = await connection.execute(
        Sql.named(buffer.toString()),
        parameters: parameters,
      );
      final rates = result
          .map(ExchangeRate.fromRow)
          .toList(growable: false);
      return Ok(rates);
    } catch (error) {
      return Err(DatabaseError('Failed to load exchange rates: $error'));
    }
  }
}
