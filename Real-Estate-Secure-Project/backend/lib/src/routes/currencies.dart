import 'package:shelf/shelf.dart';

import '../core/http.dart';
import '../core/result.dart';
import '../repositories/currency_repository.dart';

Future<Response> listCurrenciesHandler(
  Request request,
  CurrencyRepository repository,
) async {
  final result = await repository.listActive();

  return result.when(
    ok: (currencies) {
      final data = currencies
          .map((currency) => currency.toJson())
          .toList(growable: false);
      return jsonResponse({'data': data});
    },
    err: (error) => throw error,
  );
}

Future<Response> listExchangeRatesHandler(
  Request request,
  CurrencyRepository repository,
  String baseCurrency,
) async {
  final query = request.url.queryParameters;
  final quote = query['quote']?.toUpperCase();
  final limit = _parseInt(query['limit'], defaultValue: 50, max: 200);

  final result = await repository.listRates(
    baseCurrency: baseCurrency.toUpperCase(),
    quoteCurrency: quote,
    limit: limit,
  );

  return result.when(
    ok: (rates) {
      final data = rates.map((rate) => rate.toJson()).toList(growable: false);
      return jsonResponse({'data': data});
    },
    err: (error) => throw error,
  );
}

int _parseInt(String? raw, {required int defaultValue, int? max}) {
  if (raw == null || raw.isEmpty) {
    return defaultValue;
  }
  final value = int.tryParse(raw);
  if (value == null || value < 0) {
    throw const ValidationError('Invalid integer query parameter.');
  }
  if (max != null && value > max) {
    return max;
  }
  return value;
}
