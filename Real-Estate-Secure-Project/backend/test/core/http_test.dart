import 'package:real_estate_secure_backend/src/core/http.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('jsonResponse', () {
    test('encodes body and applies content-type header', () async {
      final response = jsonResponse({'hello': 'world'}, statusCode: 201);

      expect(response.statusCode, 201);
      expect(
        response.headers['content-type'],
        'application/json; charset=utf-8',
      );
      expect(await readJsonObject(response), {'hello': 'world'});
    });
  });

  group('okResponse', () {
    test('contains status, data, meta and request id when provided', () async {
      final response = okResponse(
        {'id': 'abc'},
        requestId: 'req-1',
        meta: {'count': 1},
      );

      final json = await readJsonObject(response);

      expect(response.statusCode, 200);
      expect(json['status'], 'ok');
      expect(json['data'], {'id': 'abc'});
      expect(json['meta'], {'count': 1});
      expect(json['request_id'], 'req-1');
    });
  });

  group('messageResponse', () {
    test('wraps message in data object', () async {
      final response = messageResponse('saved', requestId: 'req-2');

      final json = await readJsonObject(response);

      expect(json['status'], 'ok');
      expect(json['data'], {'message': 'saved'});
      expect(json['request_id'], 'req-2');
    });
  });

  group('errorResponse', () {
    test('includes error block and optional fields', () async {
      final response = errorResponse(
        'Bad request',
        statusCode: 422,
        requestId: 'req-3',
        code: 'VALIDATION_ERROR',
        details: {'field': 'email'},
      );

      final json = await readJsonObject(response);

      expect(response.statusCode, 422);
      expect(json['status'], 'error');
      expect(json['error'], {
        'message': 'Bad request',
        'code': 'VALIDATION_ERROR',
        'details': {'field': 'email'},
      });
      expect(json['request_id'], 'req-3');
    });
  });
}
