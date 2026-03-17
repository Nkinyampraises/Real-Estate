import '../core/types.dart';
import 'entity.dart';

enum DisputeStatus { open, investigating, resolved, escalated, closed }

class DisputeSummary extends Entity implements JsonEncodable {
  const DisputeSummary({
    required super.id,
    required this.transactionId,
    required this.raisedById,
    required this.status,
    required this.reason,
    required this.createdAt,
  });

  final String transactionId;
  final String raisedById;
  final DisputeStatus status;
  final String reason;
  final DateTime createdAt;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'transaction_id': transactionId,
        'raised_by_id': raisedById,
        'status': status.name,
        'reason': reason,
        'created_at': createdAt.toIso8601String(),
      };
}
