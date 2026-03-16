import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../core/http.dart';
import '../models/currency.dart';
import '../middleware/request_context.dart';

Router buildCurrenciesRouter() {
  final router = Router();

  router.get('/', (Request request) {
    return okResponse(
      defaultCurrencies.map((currency) => currency.toJson()).toList(),
      requestId: request.requestId,
    );
  });

  router.get('/rates', (Request request) {
    return okResponse(
      [
        {
          'base': 'XAF',
          'quote': 'USD',
          'rate': 0.0017,
          'effective_date': DateTime.now().toIso8601String(),
        },
        {
          'base': 'XAF',
          'quote': 'EUR',
          'rate': 0.0015,
          'effective_date': DateTime.now().toIso8601String(),
        },
      ],
      requestId: request.requestId,
    );
  });

  return router;
}
