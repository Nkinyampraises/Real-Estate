import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../core/http.dart';
import '../core/request.dart';
import '../middleware/request_context.dart';
import '../models/payment_method.dart';

const List<PaymentMethodInfo> _sampleMethods = [
  MobileMoneyMethod(
    id: 'pay-001',
    provider: 'mtn',
    phoneNumber: '+237690000001',
    isDefault: true,
  ),
  CardMethod(
    id: 'pay-002',
    provider: 'visa',
    lastFour: '4242',
    expiryMonth: 12,
    expiryYear: 2027,
    isDefault: false,
  ),
  BankTransferMethod(
    id: 'pay-003',
    bankName: 'Ecobank',
    accountName: 'Amina Essomba',
    isDefault: false,
  ),
];

Router buildPaymentsRouter() {
  final router = Router();

  router.get('/methods', (Request request) {
    return okResponse(
      _sampleMethods.map((method) => method.toJson()).toList(),
      requestId: request.requestId,
    );
  });

  router.post('/methods', (Request request) async {
    final payloadResult = await readJsonMap(request);
    return payloadResult.fold(
      onSuccess: (payload) => okResponse(
        {
          'id': 'pay-new',
          'type': readString(payload, 'type'),
          'status': 'created',
        },
        statusCode: 201,
        requestId: request.requestId,
      ),
      onFailure: (error) => errorResponse(
        error.message,
        statusCode: 400,
        requestId: request.requestId,
        code: 'INVALID_REQUEST',
      ),
    );
  });

  router.delete('/methods/<id>', (Request request, String id) {
    return messageResponse(
      'payment method removed',
      requestId: request.requestId,
      meta: {'payment_method_id': id},
    );
  });

  router.get('/history', (Request request) {
    return okResponse(
      [
        {
          'id': 'pay-hist-001',
          'amount_xaf': 500000,
          'status': 'completed',
          'created_at': DateTime.now().toIso8601String(),
        },
      ],
      requestId: request.requestId,
    );
  });

  router.post('/withdraw', (Request request) async {
    final payloadResult = await readJsonMap(request);
    return payloadResult.fold(
      onSuccess: (payload) => okResponse(
        {
          'amount_xaf': readDouble(payload, 'amount_xaf'),
          'status': 'processing',
        },
        statusCode: 202,
        requestId: request.requestId,
      ),
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
