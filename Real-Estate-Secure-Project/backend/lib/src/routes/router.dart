import 'package:shelf_router/shelf_router.dart';

import 'auth.dart';
import 'currencies.dart';
import 'disputes.dart';
import 'health.dart';
import 'lawyers.dart';
import 'messaging.dart';
import 'payments.dart';
import 'properties.dart';
import 'subscriptions.dart';
import 'transactions.dart';
import 'users.dart';

Router buildApiRouter() {
  final router = Router();

  final v1 = Router();
  _mountRoutes(v1);
  router.mount('/v1/', v1);

  _mountRoutes(router);
  return router;
}

void _mountRoutes(Router router) {
  router.mount('/health/', buildHealthRouter());
  router.mount('/auth/', buildAuthRouter());
  router.mount('/users/', buildUsersRouter());
  router.mount('/properties/', buildPropertiesRouter());
  router.mount('/transactions/', buildTransactionsRouter());
  router.mount('/lawyers/', buildLawyersRouter());
  router.mount('/messaging/', buildMessagingRouter());
  router.mount('/payments/', buildPaymentsRouter());
  router.mount('/subscriptions/', buildSubscriptionsRouter());
  router.mount('/currencies/', buildCurrenciesRouter());
  router.mount('/disputes/', buildDisputesRouter());
}
