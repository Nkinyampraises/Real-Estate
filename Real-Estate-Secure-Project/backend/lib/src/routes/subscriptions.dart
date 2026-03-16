import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../core/http.dart';
import '../core/request.dart';
import '../models/subscription_plan.dart';
import '../middleware/request_context.dart';

Router buildSubscriptionsRouter() {
  final router = Router();

  router.get('/plans', (Request request) {
    return okResponse(
      defaultPlans.map((plan) => plan.toJson()).toList(),
      requestId: request.requestId,
    );
  });

  router.post('/', (Request request) async {
    final payloadResult = await readJsonMap(request);
    return payloadResult.fold(
      onSuccess: (payload) {
        final planCode = readString(payload, 'plan_code') ?? 'free';
        final billingCycle = readString(payload, 'billing_cycle') ?? 'monthly';
        return okResponse(
          {
            'status': 'active',
            'plan_code': planCode,
            'billing_cycle': billingCycle,
          },
          statusCode: 201,
          requestId: request.requestId,
        );
      },
      onFailure: (error) => errorResponse(
        error.message,
        statusCode: 400,
        requestId: request.requestId,
        code: 'INVALID_REQUEST',
      ),
    );
  });

  router.get('/current', (Request request) {
    return okResponse(
      {
        'plan_code': 'standard',
        'status': 'active',
        'next_billing_date': DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String(),
      },
      requestId: request.requestId,
    );
  });

  router.put('/cancel', (Request request) {
    return messageResponse('subscription cancelled', requestId: request.requestId);
  });

  router.put('/upgrade', (Request request) async {
    final payloadResult = await readJsonMap(request);
    return payloadResult.fold(
      onSuccess: (payload) {
        final planCode = readString(payload, 'plan_code') ?? 'pro';
        return okResponse(
          {
            'status': 'upgraded',
            'plan_code': planCode,
          },
          requestId: request.requestId,
        );
      },
      onFailure: (error) => errorResponse(
        error.message,
        statusCode: 400,
        requestId: request.requestId,
        code: 'INVALID_REQUEST',
      ),
    );
  });

  return router;
}
