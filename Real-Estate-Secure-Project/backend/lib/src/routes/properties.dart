import 'package:shelf/shelf.dart';

import '../core/http.dart';
import '../core/result.dart';
import '../repositories/property_repository.dart';

Future<Response> listPropertiesHandler(
  Request request,
  PropertyRepository repository,
) async {
  final query = request.url.queryParameters;

  final propertyType = _trimOrNull(query['property_type']);
  final listingType = _trimOrNull(query['listing_type']);
  final region = _trimOrNull(query['region']);
  final city = _trimOrNull(query['city']);
  final minPrice = _parseNum(query['min_price']);
  final maxPrice = _parseNum(query['max_price']);
  final featured = _parseBool(query['featured']);
  final limit = _parseInt(query['limit'], defaultValue: 20, max: 100);
  final offset = _parseInt(query['offset'], defaultValue: 0);

  final result = await repository.listActive(
    propertyType: propertyType,
    listingType: listingType,
    region: region,
    city: city,
    minPrice: minPrice,
    maxPrice: maxPrice,
    featured: featured,
    limit: limit,
    offset: offset,
  );

  return result.when(
    ok: (properties) {
      final data = properties
          .map((property) => property.toJson())
          .toList(growable: false);
      return jsonResponse({'data': data});
    },
    err: (error) => throw error,
  );
}

String? _trimOrNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

int _parseInt(String? raw, {required int defaultValue, int? max}) {
  if (raw == null || raw.isEmpty) {
    return defaultValue;
  }
  final value = int.tryParse(raw);
  if (value == null || value < 0) {
    throw const ValidationError('Invalid integer query parameter.');
  }
  if (max != null && value > max) {
    return max;
  }
  return value;
}

num? _parseNum(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }
  final value = num.tryParse(raw);
  if (value == null) {
    throw const ValidationError('Invalid numeric query parameter.');
  }
  return value;
}

bool? _parseBool(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }
  final normalized = raw.toLowerCase();
  if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
    return true;
  }
  if (normalized == 'false' || normalized == '0' || normalized == 'no') {
    return false;
  }
  throw const ValidationError('Invalid boolean query parameter.');
}
