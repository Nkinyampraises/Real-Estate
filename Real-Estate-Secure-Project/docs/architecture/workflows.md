# Real Estate Secure - System Workflows

## Overview

These workflows capture the key business flows for Real Estate Secure. Each flow emphasizes legal verification, escrow protection, and compliance with Cameroonian real estate regulations.

## User Onboarding Flow

```
Register -> Verify Email/Phone -> KYC Upload -> Role Assignment -> Dashboard
```

Key steps:

- Collect legal profile data and consent.
- Perform identity verification.
- Assign primary role (buyer/seller/landlord/agent).
- Enforce MFA for high-risk actions.

## Seller Listing Flow

```
Create Listing -> Add Location -> Upload Documents -> Submit for Verification -> Publish
```

Highlights:

- Mandatory legal documents before publication.
- Location data includes GPS coordinates and cadastral references.
- Listings remain `pending` until legal verification completes.

## Buyer Purchase Flow

```
Discover Listing -> Offer -> Escrow Deposit -> Legal Review -> Inspection -> Release Funds
```

Highlights:

- Escrow protects both buyer and seller.
- Lawyer approval required before release.
- Transaction timeline stored for full auditability.

## Lawyer Verification Flow

```
Assign Case -> Review Documents -> Approve or Reject -> Update Status -> Notify Parties
```

Highlights:

- Every verification action is logged.
- Rejections include structured reasons and appeal support.

## Dispute Resolution Flow

```
Open Dispute -> Evidence Review -> Mediation -> Resolution -> Audit Log
```

Highlights:

- Full traceability with dispute messages.
- Optional escalation and appeal handling.
