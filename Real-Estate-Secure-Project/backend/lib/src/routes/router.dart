import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../config.dart';
import '../db/postgres.dart';
import '../repositories/currency_repository.dart';
import '../repositories/property_repository.dart';
import '../repositories/subscription_repository.dart';
import 'currencies.dart';
import 'health.dart';
import 'properties.dart';
import 'subscriptions.dart';

Router buildRouter(AppConfig config, DbPool db) {
  final router = Router();
  final subscriptionRepository = SubscriptionRepository(db);
  final currencyRepository = CurrencyRepository(db);
  final propertyRepository = PropertyRepository(db);

  router.get('/v1', (Request request) {
    return Response.ok('Real Estate Secure API');
  });

  router.get('/v1/health', (Request request) => healthHandler(request, config));

  router.get('/v1/ready', (Request request) => readyHandler(request, config, db));
  router.get(
    '/v1/subscriptions/plans',
    (Request request) => listSubscriptionPlansHandler(request, subscriptionRepository),
  );
  router.get(
    '/v1/currencies',
    (Request request) => listCurrenciesHandler(request, currencyRepository),
  );
  router.get(
    '/v1/currencies/<code>/rates',
    (Request request, String code) => listExchangeRatesHandler(
      request,
      currencyRepository,
      code,
    ),
  );
  router.get(
    '/v1/properties',
    (Request request) => listPropertiesHandler(request, propertyRepository),
  );

  return router;
}
