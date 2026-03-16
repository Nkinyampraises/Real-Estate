BEGIN;

INSERT INTO currencies (code, name, symbol, decimals, is_active)
VALUES
  ('XAF', 'Central African CFA franc', 'FCFA', 0, TRUE),
  ('USD', 'United States dollar', '$', 2, TRUE),
  ('EUR', 'Euro', 'EUR', 2, TRUE);

COMMIT;
