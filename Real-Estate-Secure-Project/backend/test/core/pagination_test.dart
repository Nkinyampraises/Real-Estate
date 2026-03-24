import 'package:real_estate_secure_backend/src/core/pagination.dart';
import 'package:test/test.dart';

void main() {
  group('PageRequest', () {
    test('computes offset from page and limit', () {
      const pageRequest = PageRequest(page: 3, limit: 25);
      expect(pageRequest.offset, 50);
    });

    test('clamp enforces minimum page and limit', () {
      const pageRequest = PageRequest(page: 0, limit: -2);
      final clamped = pageRequest.clamp();

      expect(clamped.page, 1);
      expect(clamped.limit, 1);
    });

    test('clamp enforces maximum limit', () {
      const pageRequest = PageRequest(page: 2, limit: 1000);
      final clamped = pageRequest.clamp(maxLimit: 50);

      expect(clamped.page, 2);
      expect(clamped.limit, 50);
    });

    test('fromQuery parses and clamps invalid values', () {
      final parsed = PageRequest.fromQuery(
        {'page': '-3', 'limit': '999'},
        defaultPage: 4,
        defaultLimit: 10,
      );

      expect(parsed.page, 1);
      expect(parsed.limit, 100);
    });

    test('fromQuery falls back to defaults when parse fails', () {
      final parsed = PageRequest.fromQuery(
        {'page': 'abc', 'limit': 'xyz'},
        defaultPage: 4,
        defaultLimit: 10,
      );

      expect(parsed.page, 4);
      expect(parsed.limit, 10);
    });
  });

  group('Page', () {
    test('totalPages is zero when totalItems is zero', () {
      const page = Page<int>(items: [], page: 1, limit: 20, totalItems: 0);
      expect(page.totalPages, 0);
    });

    test('totalPages rounds up for remaining items', () {
      const page = Page<int>(
        items: [1, 2, 3],
        page: 1,
        limit: 2,
        totalItems: 3,
      );
      expect(page.totalPages, 2);
    });

    test('toJson applies encoder for items', () {
      const page = Page<int>(
        items: [4, 8],
        page: 2,
        limit: 2,
        totalItems: 5,
      );

      final json = page.toJson((value) => {'value': value});
      expect(json['items'], [
        {'value': 4},
        {'value': 8},
      ]);
      expect(json['page'], 2);
      expect(json['limit'], 2);
      expect(json['total_items'], 5);
      expect(json['total_pages'], 3);
    });
  });
}
