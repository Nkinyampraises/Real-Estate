import '../core/types.dart';

class SubscriptionPlan implements JsonEncodable {
  const SubscriptionPlan({
    required this.code,
    required this.name,
    required this.priceMonthly,
    required this.transactionFee,
    required this.maxListings,
    required this.features,
  });

  final String code;
  final String name;
  final int priceMonthly;
  final double transactionFee;
  final int maxListings;
  final List<String> features;

  @override
  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'price_monthly': priceMonthly,
        'transaction_fee_percentage': transactionFee,
        'max_listings': maxListings,
        'features': features,
      };
}

const List<SubscriptionPlan> defaultPlans = [
  SubscriptionPlan(
    code: 'free',
    name: 'Free',
    priceMonthly: 0,
    transactionFee: 5.0,
    maxListings: 1,
    features: ['Basic listing', 'Standard support'],
  ),
  SubscriptionPlan(
    code: 'basic',
    name: 'Basic',
    priceMonthly: 5000,
    transactionFee: 4.5,
    maxListings: 3,
    features: ['Priority verification queue', 'Email support'],
  ),
  SubscriptionPlan(
    code: 'standard',
    name: 'Standard',
    priceMonthly: 10000,
    transactionFee: 4.0,
    maxListings: 6,
    features: ['Analytics dashboard', 'Featured listing credits'],
  ),
  SubscriptionPlan(
    code: 'pro',
    name: 'Pro',
    priceMonthly: 20000,
    transactionFee: 3.5,
    maxListings: 12,
    features: ['API access', 'Dedicated success manager'],
  ),
];
