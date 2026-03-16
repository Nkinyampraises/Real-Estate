import '../core/types.dart';
import 'entity.dart';

sealed class PaymentMethodInfo extends Entity implements JsonEncodable {
  const PaymentMethodInfo({
    required super.id,
    required this.type,
    required this.isDefault,
  });

  final String type;
  final bool isDefault;
}

class MobileMoneyMethod extends PaymentMethodInfo {
  const MobileMoneyMethod({
    required super.id,
    required super.isDefault,
    required this.provider,
    required this.phoneNumber,
  }) : super(type: 'momo');

  final String provider;
  final String phoneNumber;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'provider': provider,
        'phone_number': phoneNumber,
        'is_default': isDefault,
      };
}

class CardMethod extends PaymentMethodInfo {
  const CardMethod({
    required super.id,
    required super.isDefault,
    required this.provider,
    required this.lastFour,
    required this.expiryMonth,
    required this.expiryYear,
  }) : super(type: 'card');

  final String provider;
  final String lastFour;
  final int expiryMonth;
  final int expiryYear;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'provider': provider,
        'last_four': lastFour,
        'expiry_month': expiryMonth,
        'expiry_year': expiryYear,
        'is_default': isDefault,
      };
}

class BankTransferMethod extends PaymentMethodInfo {
  const BankTransferMethod({
    required super.id,
    required super.isDefault,
    required this.bankName,
    required this.accountName,
  }) : super(type: 'bank_transfer');

  final String bankName;
  final String accountName;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'bank_name': bankName,
        'account_name': accountName,
        'is_default': isDefault,
      };
}
