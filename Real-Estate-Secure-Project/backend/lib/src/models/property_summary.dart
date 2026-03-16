import '../core/types.dart';
import 'entity.dart';

enum PropertyType { land, house, apartment, commercial, industrial, agricultural }

enum ListingType { sale, rent, lease }

class PropertySummary extends Entity implements JsonEncodable {
  const PropertySummary({
    required super.id,
    required this.title,
    required this.city,
    required this.region,
    required this.priceXaf,
    required this.type,
    required this.listingType,
    this.isFeatured = false,
  });

  final String title;
  final String city;
  final String region;
  final double priceXaf;
  final PropertyType type;
  final ListingType listingType;
  final bool isFeatured;

  @override
  Map<String, dynamic> toJson() => {
        'id': super.id,
        'title': title,
        'city': city,
        'region': region,
        'price_xaf': priceXaf,
        'type': type.name,
        'listing_type': listingType.name,
        'is_featured': isFeatured,
      };
}
