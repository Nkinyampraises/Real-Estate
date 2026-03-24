import 'package:real_estate_secure_backend/src/routes/properties.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('Properties routes', () {
    final router = buildPropertiesRouter();

    test('GET / returns seeded properties with meta', () async {
      final response = await router(requestFor('GET', '/'));
      final json = await readJsonObject(response);

      final data = json['data'] as List<dynamic>;
      final meta = json['meta'] as Map<String, dynamic>;

      expect(response.statusCode, 200);
      expect(data, hasLength(3));
      expect(meta['count'], 3);
      expect(meta['total_items'], 3);
    });

    test('GET / with featured=true filters to featured listings', () async {
      final response = await router(requestFor('GET', '/?featured=true'));
      final json = await readJsonObject(response);

      final data = json['data'] as List<dynamic>;
      expect(data, hasLength(1));
      expect(data.first['is_featured'], isTrue);
    });

    test('GET / with pagination returns requested page slice', () async {
      final response = await router(requestFor('GET', '/?page=2&limit=2'));
      final json = await readJsonObject(response);

      final data = json['data'] as List<dynamic>;
      final meta = json['meta'] as Map<String, dynamic>;

      expect(data, hasLength(1));
      expect(meta['page'], 2);
      expect(meta['limit'], 2);
      expect(meta['total_items'], 3);
    });

    test('GET /search returns title matches for query', () async {
      final response = await router(requestFor('GET', '/search?q=villa'));
      final json = await readJsonObject(response);

      final data = json['data'] as List<dynamic>;
      expect(data, hasLength(1));
      expect(data.first['title'], 'Bonapriso Villa');
    });

    test('GET /map returns only public locations', () async {
      final response = await router(requestFor('GET', '/map'));
      final json = await readJsonObject(response);

      final data = json['data'] as List<dynamic>;
      expect(data, hasLength(2));
      expect(
        data.every((location) => location['is_public'] == true),
        isTrue,
      );
    });

    test('GET /<id> returns 404 for unknown property', () async {
      final response = await router(requestFor('GET', '/does-not-exist'));
      final json = await readJsonObject(response);

      expect(response.statusCode, 404);
      expect(json['status'], 'error');
      expect(json['error']['code'], 'NOT_FOUND');
      expect(json['error']['message'], 'Property not found.');
    });

    test('POST / creates draft property from payload', () async {
      final response = await router(
        requestFor(
          'POST',
          '/',
          body: const {
            'title': 'New Site',
            'city': 'Douala',
            'region': 'Littoral',
            'price_xaf': 12345,
          },
        ),
      );
      final json = await readJsonObject(response);

      expect(response.statusCode, 201);
      expect(json['status'], 'ok');
      expect(json['data']['title'], 'New Site');
      expect(json['data']['status'], 'draft');
    });

    test('POST / returns 400 for empty body', () async {
      final response = await router(
        Request('POST', Uri.parse('https://example.test/')),
      );
      final json = await readJsonObject(response);

      expect(response.statusCode, 400);
      expect(json['status'], 'error');
      expect(json['error']['code'], 'INVALID_REQUEST');
      expect(json['error']['message'], 'Request body is required.');
    });
  });
}
