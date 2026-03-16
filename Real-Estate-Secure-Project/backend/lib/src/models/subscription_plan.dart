import 'dart:convert';

class SubscriptionPlan {
  final int id;
  final String planName;
  final String planCode;
  final String priceMonthly;
  final String? priceYearly;
  final String currency;
  final int maxListings;
  final int maxPhotosPerListing;
  final int maxVideosPerListing;
  final int featuredListingsIncluded;
  final String transactionFeePercentage;
  final bool prioritySupport;
  final bool analyticsAccess;
  final bool apiAccess;
  final bool bulkListingTools;
  final bool companyProfile;
  final String? badgeDisplay;
  final bool isActive;
  final int sortOrder;
  final String description;
  final List<String> features;

  const SubscriptionPlan({
    required this.id,
    required this.planName,
    required this.planCode,
    required this.priceMonthly,
    required this.priceYearly,
    required this.currency,
    required this.maxListings,
    required this.maxPhotosPerListing,
    required this.maxVideosPerListing,
    required this.featuredListingsIncluded,
    required this.transactionFeePercentage,
    required this.prioritySupport,
    required this.analyticsAccess,
    required this.apiAccess,
    required this.bulkListingTools,
    required this.companyProfile,
    required this.badgeDisplay,
    required this.isActive,
    required this.sortOrder,
    required this.description,
    required this.features,
  });

  factory SubscriptionPlan.fromRow(dynamic row) {
    return SubscriptionPlan(
      id: _asInt(row[0]),
      planName: row[1].toString(),
      planCode: row[2].toString(),
      priceMonthly: row[3].toString(),
      priceYearly: row[4]?.toString(),
      currency: row[5].toString(),
      maxListings: _asInt(row[6]),
      maxPhotosPerListing: _asInt(row[7]),
      maxVideosPerListing: _asInt(row[8]),
      featuredListingsIncluded: _asInt(row[9]),
      transactionFeePercentage: row[10].toString(),
      prioritySupport: _asBool(row[11]),
      analyticsAccess: _asBool(row[12]),
      apiAccess: _asBool(row[13]),
      bulkListingTools: _asBool(row[14]),
      companyProfile: _asBool(row[15]),
      badgeDisplay: row[16]?.toString(),
      isActive: _asBool(row[17]),
      sortOrder: _asInt(row[18]),
      description: row[19].toString(),
      features: _parseFeatures(row[20]),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'plan_name': planName,
      'plan_code': planCode,
      'price_monthly': priceMonthly,
      'price_yearly': priceYearly,
      'currency': currency,
      'max_listings': maxListings,
      'max_photos_per_listing': maxPhotosPerListing,
      'max_videos_per_listing': maxVideosPerListing,
      'featured_listings_included': featuredListingsIncluded,
      'transaction_fee_percentage': transactionFeePercentage,
      'priority_support': prioritySupport,
      'analytics_access': analyticsAccess,
      'api_access': apiAccess,
      'bulk_listing_tools': bulkListingTools,
      'company_profile': companyProfile,
      'badge_display': badgeDisplay,
      'is_active': isActive,
      'sort_order': sortOrder,
      'description': description,
      'features': features,
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

List<String> _parseFeatures(Object? value) {
  if (value is List) {
    return value
        .map((item) => item.toString())
        .where((item) => item.trim().isNotEmpty)
        .toList(growable: false);
  }

  if (value is String) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return decoded
            .map((item) => item.toString())
            .where((item) => item.trim().isNotEmpty)
            .toList(growable: false);
      }
    } catch (_) {
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
  }

  return const [];
}
