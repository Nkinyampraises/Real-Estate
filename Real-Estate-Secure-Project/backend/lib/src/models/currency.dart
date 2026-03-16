class Currency {
  final String code;
  final String name;
  final String? symbol;
  final int decimals;
  final bool isActive;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.decimals,
    required this.isActive,
  });

  factory Currency.fromRow(dynamic row) {
    return Currency(
      code: row[0].toString(),
      name: row[1].toString(),
      symbol: row[2]?.toString(),
      decimals: _asInt(row[3]),
      isActive: _asBool(row[4]),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
      'decimals': decimals,
      'is_active': isActive,
    };
  }
}

class ExchangeRate {
  final String baseCurrency;
  final String quoteCurrency;
  final String rate;
  final String? provider;
  final DateTime effectiveAt;

  const ExchangeRate({
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.rate,
    required this.provider,
    required this.effectiveAt,
  });

  factory ExchangeRate.fromRow(dynamic row) {
    return ExchangeRate(
      baseCurrency: row[0].toString(),
      quoteCurrency: row[1].toString(),
      rate: row[2].toString(),
      provider: row[3]?.toString(),
      effectiveAt: row[4] as DateTime,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'base_currency': baseCurrency,
      'quote_currency': quoteCurrency,
      'rate': rate,
      'provider': provider,
      'effective_at': effectiveAt.toUtc().toIso8601String(),
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
