# Backend

Production-grade Dart backend for the Real-Estate-Secure platform.

## Local setup

1. Copy `.env.example` to `.env` and update credentials.
2. Install dependencies:
   `dart pub get`
3. Run the API:
   `dart run bin/server.dart`

## Structure

- `bin/` entrypoint
- `lib/src/` application code
- `lib/src/routes/` HTTP routes
- `lib/src/db/` database access
- `lib/src/models/` domain models

## API surface (v1)

Base path: `/v1`

- Auth: `/auth/register`, `/auth/login`, `/auth/refresh`, `/auth/logout`
- Users: `/users/profile`, `/users/kyc/upload`, `/users/kyc/status`
- Properties: `/properties`, `/properties/search`, `/properties/map`
- Transactions: `/transactions`, `/transactions/initiate`, `/transactions/{id}/deposit`
- Lawyers: `/lawyers`, `/lawyers/{id}`, `/lawyers/pending`
- Messaging: `/messaging/conversations`, `/messaging/conversations/{id}/messages`
- Payments: `/payments/methods`, `/payments/history`, `/payments/withdraw`
- Subscriptions: `/subscriptions/plans`, `/subscriptions/current`
- Disputes: `/disputes`, `/disputes/{id}`
