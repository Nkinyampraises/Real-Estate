import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../core/health.dart';
import '../core/http.dart';
import '../middleware/request_context.dart';

Router buildHealthRouter({String version = '0.1.0'}) {
  final router = Router();

  router.get('/', (Request request) {
    final report = HealthReport(
      status: HealthStatus.ok,
      timestamp: DateTime.now(),
      version: version,
      dependencies: const {
        'database': 'unknown',
        'cache': 'unknown',
        'queue': 'unknown',
      },
    );
    return okResponse(report.toJson(), requestId: request.requestId);
  });

  return router;
}
