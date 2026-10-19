# Lizbeth Spanish owner-assignment audit receipt

Receipt date: 2026-09-15  
Backend: `cultural-spanish` (`gvobtuhbpqvfhjljjcye`)  
Evidence basis: the assignment execution and independent live post-write verification below are reported by the Luna `owner_assign` agent. This receipt author did not rerun the assignment or query the live system.

## Reported assignment

- User-chosen email: `thereallizbeth@gmail.com`
- Account precondition: account existed; exact email match count was `1`; email-confirmed was `true`.
- Reported resulting role claim: `owner`.
- `owner_settings`: exactly one matching row; expected values were verified.
- Mutation exit code: `0`.

Scoped operations were limited to:

- merging `Auth` metadata `role=owner` while preserving existing `provider/providers`; and
- upserting the matching `owner_settings` row.

No accounts were created, invited, or deleted, and no backfill was run. The role metadata and settings did change. The report also states that no schema, Netlify settings, deployment, Git state, or unrelated identity was changed.

## Guard, judgment, and test receipts

- G9b backup gate: passed with fresh schema/data dumps and SHA-256 companions.
- Pre-judgment: AGY `SUCCESS`; model `gemini-3.8-flash-medium`; verdict `APPROVE`; conversation ID `0a3d0410-6bf9-4005-9af4-beefe583dae3`.
- Post-judgment: AGY `SUCCESS`; verdict `PASS`; conversation ID `b1111f0a-495e-44a1-9111-2cf6084e8ab1`.
- Focused guard/script suites: `106` tests passed.
- AGY limitation: judgments relied on sanitized receipts; the reported live post-write verification passed independently.

## Local backup-artifact check

This receipt author performed a native read-only check of the named artifacts. No dump contents or credentials were opened. The files were found under `lizbeth_spanish/docs/cutover-evidence`:

| Artifact | Bytes | SHA-256 |
|---|---:|---|
| `G9b-schema-20260916T020411Z.sql` | 197261 | `5c445c909982afea512cd0f7121afc11394be8ae5a5f9a0443ce4311cfa77b3a` |
| `G9b-data-20260916T020432Z.sql` | 368400 | `b3c2515d121af2cb0b68c30c891de18e39994f84c675d1c434c469a6ebc3b410` |

Both `.sha256` companion files were present, each 65 bytes, and their recorded hashes matched the corresponding dump. This is an artifact-existence/hash/size check only.

## Limits

The evidence establishes the reported schema/data dump gate, not full auth-backup coverage. No restore drill or restoration test was performed. Existing branch/PR and production-deployment state are context only; this receipt does not claim new security or hosted-environment results.
