# Database

Production-grade PostgreSQL schema and migrations for Real Estate Secure.

## Structure
- `migrations/` versioned migrations (start here)
- `schema/` ERD exports or reference schemas
- `seeds/` seed data for local/dev

## Current Schema
- `database/migrations/0001_init.sql` (full baseline schema)

## Seeds
- `database/seeds/0000_currencies.sql`
- `database/seeds/0001_subscription_plans.sql`
- `database/seeds/0002_exchange_rates.sql`

## Running Migrations
- PowerShell: `scripts/db-migrate.ps1`
- Bash: `scripts/db-migrate.sh`
