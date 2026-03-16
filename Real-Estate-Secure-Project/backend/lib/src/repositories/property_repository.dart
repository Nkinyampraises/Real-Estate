import 'package:postgres/postgres.dart';

import '../core/result.dart';
import '../db/postgres.dart';
import '../models/property_summary.dart';

class PropertyRepository {
  final DbPool db;

  PropertyRepository(this.db);

  Future<AppResult<List<PropertySummary>>> listActive({
    String? propertyType,
    String? listingType,
    String? region,
    String? city,
    num? minPrice,
    num? maxPrice,
    bool? featured,
    int limit = 20,
    int offset = 0,
  }) async {
    final buffer = StringBuffer('''
SELECT
  p.id,
  p.uuid,
  p.title,
  p.property_type,
  p.listing_type,
  p.price,
  p.currency,
  p.property_status,
  p.verification_status,
  p.is_featured,
  p.featured_until,
  p.created_at,
  l.region,
  l.city,
  l.latitude,
  l.longitude
FROM properties p
LEFT JOIN property_locations l
  ON l.property_id = p.id AND l.location_type = 'primary'
WHERE p.deleted_at IS NULL
  AND p.property_status = 'active'
''');

    final parameters = <String, Object?>{
      'limit': limit,
      'offset': offset,
    };

    void addFilter(String clause, String key, Object? value) {
      if (value == null) {
        return;
      }
      buffer.writeln(clause);
      parameters[key] = value;
    }

    addFilter('AND p.property_type = @property_type', 'property_type', propertyType);
    addFilter('AND p.listing_type = @listing_type', 'listing_type', listingType);
    addFilter('AND p.price >= @min_price', 'min_price', minPrice);
    addFilter('AND p.price <= @max_price', 'max_price', maxPrice);
    addFilter('AND l.region = @region', 'region', region);
    addFilter('AND l.city = @city', 'city', city);

    if (featured != null) {
      buffer.writeln('AND p.is_featured = @featured');
      parameters['featured'] = featured;
    }

    buffer.writeln('ORDER BY p.is_featured DESC, p.created_at DESC');
    buffer.writeln('LIMIT @limit OFFSET @offset');

    try {
      final connection = await db.connect();
      final result = await connection.execute(
        Sql.named(buffer.toString()),
        parameters: parameters,
      );
      final properties = result
          .map(PropertySummary.fromRow)
          .toList(growable: false);
      return Ok(properties);
    } catch (error) {
      return Err(DatabaseError('Failed to load properties: $error'));
    }
  }
}
