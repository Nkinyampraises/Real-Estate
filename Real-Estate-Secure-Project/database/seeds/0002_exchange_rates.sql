BEGIN;

INSERT INTO currency_exchange_rates (
  base_currency,
  quote_currency,
  rate,
  provider,
  effective_at
) VALUES
  ('XAF', 'USD', 0.0016, 'seed', NOW()),
  ('XAF', 'EUR', 0.0015, 'seed', NOW());

COMMIT;
