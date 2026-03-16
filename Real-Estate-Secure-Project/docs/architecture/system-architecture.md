# Real Estate Secure - System Architecture

## Executive Summary

Real Estate Secure is a legally verified, escrow-protected real estate platform for Cameroon. The system is designed for compliance, auditability, and secure transfers by combining document verification, lawyer workflows, escrow management, and location validation.

## Architecture Overview

The platform uses a modular architecture with a Dart backend, a PostgreSQL data layer, and a Flutter mobile app. The backend exposes REST APIs for authentication, listings, verification, transactions, messaging, and compliance. The database enforces strong constraints, audit trails, and immutable histories for critical entities.

```
Clients (Flutter, Web, Admin)
        |
        v
   Dart API Gateway (Shelf)
        |
        v
PostgreSQL + Object Storage + Observability
```

## Core Services

- **Identity & Access**: registration, MFA, KYC, role-based authorization.
- **Property Management**: listings, location data, media, and verification status.
- **Legal Verification**: lawyer review workflows, document audit logs, dispute handling.
- **Transactions & Escrow**: escrow accounts, ledger entries, approvals, and releases.
- **Messaging**: verified buyer/seller/lawyer communication with audit trails.

## Data Layer

PostgreSQL is the primary source of truth. It stores users, property records, documents metadata, escrow transactions, and immutable audit logs. Seed data includes currencies and subscription plans. The schema is designed for high integrity using strict foreign keys, checks, and unique constraints.

## Security & Compliance

- Encrypted secrets and environment-based configuration.
- Strong audit logging for every state-changing action.
- Document verification history and role-based approvals.
- IP tracking for login attempts and sensitive workflows.

## Technology Stack

- **Backend**: Dart (Shelf, shelf_router, postgres).
- **Database**: PostgreSQL with typed enums and strict constraints.
- **Mobile**: Flutter (Android first, iOS-ready).
- **Infrastructure**: container-ready structure with environment-driven configuration.
