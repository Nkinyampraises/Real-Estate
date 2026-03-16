import '../core/types.dart';
import 'entity.dart';

enum TransactionStatus {
  initiated,
  pendingDeposit,
  deposited,
  documentsPending,
  documentsVerified,
  inspectionPeriod,
  lawyerApproval,
  completed,
  disputed,
  cancelled,
  refunded,
}

extension TransactionStatusApi on TransactionStatus {
  String get apiValue => switch (this) {
        TransactionStatus.pendingDeposit => 'pending_deposit',
        TransactionStatus.documentsPending => 'documents_pending',
        TransactionStatus.documentsVerified => 'documents_verified',
        TransactionStatus.inspectionPeriod => 'inspection_period',
        TransactionStatus.lawyerApproval => 'lawyer_approval',
        _ => name,
      };
}

class TransactionSummary extends Entity implements JsonEncodable {
  const TransactionSummary({
    required super.id,
    required this.propertyId,
    required this.buyerId,
    required this.sellerId,
    required this.amountXaf,
    required this.status,
    required this.createdAt,
  });

  final String propertyId;
  final String buyerId;
  final String sellerId;
  final double amountXaf;
  final TransactionStatus status;
  final DateTime createdAt;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'property_id': propertyId,
        'buyer_id': buyerId,
        'seller_id': sellerId,
        'amount_xaf': amountXaf,
        'status': status.apiValue,
        'created_at': createdAt.toIso8601String(),
      };
}
