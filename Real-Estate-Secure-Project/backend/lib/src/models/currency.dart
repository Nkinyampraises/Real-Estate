import '../core/types.dart';

class Currency implements JsonEncodable {
  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    this.isActive = true,
  });

  final String code;
  final String name;
  final String symbol;
  final bool isActive;

  @override
  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'symbol': symbol,
        'is_active': isActive,
      };
}

const List<Currency> defaultCurrencies = [
  Currency(code: 'XAF', name: 'Central African CFA franc', symbol: 'FCFA'),
  Currency(code: 'USD', name: 'United States Dollar', symbol: '\$'),
  Currency(code: 'EUR', name: 'Euro', symbol: 'EUR'),
  Currency(code: 'GBP', name: 'British Pound', symbol: 'GBP'),
];
