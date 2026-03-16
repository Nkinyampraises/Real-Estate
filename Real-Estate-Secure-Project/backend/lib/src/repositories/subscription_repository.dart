import '../core/result.dart';
import '../db/postgres.dart';
import '../models/subscription_plan.dart';

class SubscriptionRepository {
  final DbPool db;

  SubscriptionRepository(this.db);

  Future<AppResult<List<SubscriptionPlan>>> listActive() async {
    const sql = '''
SELECT
  id,
  plan_name,
  plan_code,
  price_monthly,
  price_yearly,
  currency,
  max_listings,
  max_photos_per_listing,
  max_videos_per_listing,
  featured_listings_included,
  transaction_fee_percentage,
  priority_support,
  analytics_access,
  api_access,
  bulk_listing_tools,
  company_profile,
  badge_display,
  is_active,
  sort_order,
  description,
  features
FROM subscription_plans
WHERE is_active = TRUE
ORDER BY sort_order ASC;
''';

    try {
      final connection = await db.connect();
      final result = await connection.execute(sql);
      final plans = result
          .map(SubscriptionPlan.fromRow)
          .toList(growable: false);
      return Ok(plans);
    } catch (error) {
      return Err(DatabaseError('Failed to load subscription plans: $error'));
    }
  }
}
