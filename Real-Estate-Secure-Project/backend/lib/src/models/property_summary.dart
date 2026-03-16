class PropertySummary {
  final int id;
  final String uuid;
  final String title;
  final String propertyType;
  final String listingType;
  final String price;
  final String currency;
  final String propertyStatus;
  final String verificationStatus;
  final bool isFeatured;
  final DateTime? featuredUntil;
  final String? region;
  final String? city;
  final String? latitude;
  final String? longitude;
  final DateTime createdAt;

  const PropertySummary({
    required this.id,
    required this.uuid,
    required this.title,
    required this.propertyType,
    required this.listingType,
    required this.price,
    required this.currency,
    required this.propertyStatus,
    required this.verificationStatus,
    required this.isFeatured,
    required this.featuredUntil,
    required this.region,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  factory PropertySummary.fromRow(dynamic row) {
    return PropertySummary(
      id: _asInt(row[0]),
      uuid: row[1].toString(),
      title: row[2].toString(),
      propertyType: row[3].toString(),
      listingType: row[4].toString(),
      price: row[5].toString(),
      currency: row[6].toString(),
      propertyStatus: row[7].toString(),
      verificationStatus: row[8].toString(),
      isFeatured: _asBool(row[9]),
      featuredUntil: row[10] as DateTime?,
      createdAt: row[11] as DateTime,
      region: row[12]?.toString(),
      city: row[13]?.toString(),
      latitude: row[14]?.toString(),
      longitude: row[15]?.toString(),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'title': title,
      'property_type': propertyType,
      'listing_type': listingType,
      'price': price,
      'currency': currency,
      'property_status': propertyStatus,
      'verification_status': verificationStatus,
      'is_featured': isFeatured,
      'featured_until': featuredUntil?.toUtc().toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
      'region': region,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

int _asInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _asBool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  final normalized = value?.toString().toLowerCase();
  return normalized == 'true' || normalized == 't' || normalized == '1';
}
