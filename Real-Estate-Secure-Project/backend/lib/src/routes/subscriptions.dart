import 'package:shelf/shelf.dart';

import '../core/http.dart';
import '../core/result.dart';
import '../repositories/subscription_repository.dart';

Future<Response> listSubscriptionPlansHandler(
  Request request,
  SubscriptionRepository repository,
) async {
  final result = await repository.listActive();

  return result.when(
    ok: (plans) {
      final data = plans.map((plan) => plan.toJson()).toList(growable: false);
      return jsonResponse({'data': data});
    },
    err: (error) => throw error,
  );
}
