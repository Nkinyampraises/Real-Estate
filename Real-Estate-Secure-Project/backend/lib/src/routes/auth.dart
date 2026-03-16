import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../core/http.dart';
import '../core/request.dart';
import '../core/result.dart';
import '../middleware/request_context.dart';

Router buildAuthRouter() {
  final router = Router();

  router.post('/register', (Request request) async {
    final payloadResult = await readJsonMap(request);
    return payloadResult.fold(
      onSuccess: (payload) {
        final result = _validateRegistration(
          email: readString(payload, 'email'),
          password: readString(payload, 'password'),
          firstName: readString(payload, 'first_name'),
          lastName: readString(payload, 'last_name'),
        );

        return result.fold(
          onSuccess: (_) => messageResponse(
            'registered',
            statusCode: 201,
            requestId: request.requestId,
          ),
          onFailure: (error) => errorResponse(
            error.message,
            statusCode: 422,
            requestId: request.requestId,
            code: 'VALIDATION_ERROR',
          ),
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

  router.post('/login', (Request request) async {
    final payloadResult = await readJsonMap(request);
    return payloadResult.fold(
      onSuccess: (payload) {
        final email = readString(payload, 'email');
        final password = readString(payload, 'password');

        if (email == null || password == null) {
          return errorResponse(
            'Email and password are required.',
            statusCode: 422,
            requestId: request.requestId,
            code: 'VALIDATION_ERROR',
          );
        }

        return okResponse(
          {
            'token': 'placeholder-token',
            'refresh_token': 'placeholder-refresh-token',
            'expires_in': 3600,
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

  router.post('/refresh', (Request request) async {
    final payloadResult = await readJsonMap(request);
    return payloadResult.fold(
      onSuccess: (payload) {
        final token = readString(payload, 'refresh_token');
        if (token == null) {
          return errorResponse(
            'Refresh token is required.',
            statusCode: 422,
            requestId: request.requestId,
            code: 'VALIDATION_ERROR',
          );
        }
        return okResponse(
          {
            'token': 'placeholder-token',
            'expires_in': 3600,
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

  router.post('/logout', (Request request) {
    return messageResponse('logged out', requestId: request.requestId);
  });

  router.post('/verify-email', (Request request) async {
    final payloadResult = await readJsonMap(request);
    return _ackFromPayload(
      request,
      payloadResult,
      requiredKeys: const ['token'],
      message: 'email verified',
    );
  });

  router.post('/verify-phone', (Request request) async {
    final payloadResult = await readJsonMap(request);
    return _ackFromPayload(
      request,
      payloadResult,
      requiredKeys: const ['code'],
      message: 'phone verified',
    );
  });

  router.post('/forgot-password', (Request request) async {
    final payloadResult = await readJsonMap(request);
    return _ackFromPayload(
      request,
      payloadResult,
      requiredKeys: const ['email'],
      message: 'reset link sent',
    );
  });

  router.post('/reset-password', (Request request) async {
    final payloadResult = await readJsonMap(request);
    return _ackFromPayload(
      request,
      payloadResult,
      requiredKeys: const ['token', 'password'],
      message: 'password reset',
    );
  });

  router.post('/2fa/enable', (Request request) {
    return okResponse(
      {
        'secret': 'placeholder-secret',
        'qr_code_url': 'otpauth://totp/real-estate-secure',
      },
      requestId: request.requestId,
    );
  });

  router.post('/2fa/verify', (Request request) async {
    final payloadResult = await readJsonMap(request);
    return _ackFromPayload(
      request,
      payloadResult,
      requiredKeys: const ['code'],
      message: '2fa verified',
    );
  });

  router.post('/biometric/register', (Request request) async {
    final payloadResult = await readJsonMap(request);
    return _ackFromPayload(
      request,
      payloadResult,
      requiredKeys: const ['credential_id', 'public_key'],
      message: 'biometric registered',
      statusCode: 201,
    );
  });

  router.post('/biometric/verify', (Request request) async {
    final payloadResult = await readJsonMap(request);
    return _ackFromPayload(
      request,
      payloadResult,
      requiredKeys: const ['credential_id', 'signature'],
      message: 'biometric verified',
    );
  });

  return router;
}

Result<void> _validateRegistration({
  required String? email,
  required String? password,
  required String? firstName,
  required String? lastName,
}) {
  if (email == null || !email.contains('@')) {
    return const Failure(ValidationError('Valid email is required.'));
  }
  if (password == null || password.length < 8) {
    return const Failure(ValidationError('Password must be 8+ characters.'));
  }
  if (firstName == null || lastName == null) {
    return const Failure(ValidationError('First and last name are required.'));
  }

  return const Success(null);
}

Response _ackFromPayload(
  Request request,
  Result<Map<String, dynamic>> payloadResult, {
  required List<String> requiredKeys,
  required String message,
  int statusCode = 200,
}) {
  return payloadResult.fold(
    onSuccess: (payload) {
      final missing = requiredKeys.where((key) => payload[key] == null).toList();
      if (missing.isNotEmpty) {
        return errorResponse(
          'Missing required fields: ${missing.join(', ')}.',
          statusCode: 422,
          requestId: request.requestId,
          code: 'VALIDATION_ERROR',
        );
      }
      return messageResponse(
        message,
        statusCode: statusCode,
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
}
