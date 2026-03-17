import '../core/types.dart';

class PropertyLocation implements JsonEncodable {
  const PropertyLocation({
    required this.id,
    required this.propertyId,
    required this.city,
    required this.region,
    required this.latitude,
    required this.longitude,
    this.isPublic = false,
  });

  final String id;
  final String propertyId;
  final String city;
  final String region;
  final double latitude;
  final double longitude;
  final bool isPublic;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'property_id': propertyId,
        'city': city,
        'region': region,
        'latitude': latitude,
        'longitude': longitude,
        'is_public': isPublic,
      };
}
