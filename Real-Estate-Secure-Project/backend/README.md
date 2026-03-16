# Backend (Dart)

Production-grade Dart backend for Real Estate Secure. The initial layout is a
modular monolith using `shelf`, designed to evolve into services when scale
demands it.

## Stack
- Dart 3
- Shelf + Shelf Router (HTTP)
- PostgreSQL (primary data store)
- Redis (cache/session) planned
- S3/MinIO (document storage) planned

## Quick Start
1. Copy `backend/.env.example` to `backend/.env` and update values.
2. Run the server:
   `dart run bin/server.dart`

## Endpoints
- `GET /v1` service banner
- `GET /v1/health` liveness probe
- `GET /v1/ready` readiness probe (checks database)
- `GET /v1/subscriptions/plans` active subscription plans
- `GET /v1/currencies` active currencies
- `GET /v1/currencies/{code}/rates` exchange rates for base currency
- `GET /v1/properties` list active properties with filters

## Structure
- `bin/` entrypoints
- `lib/src/` application code
  - `core/` shared primitives and utilities
  - `routes/` HTTP routing
  - `middleware/` cross-cutting HTTP middleware
