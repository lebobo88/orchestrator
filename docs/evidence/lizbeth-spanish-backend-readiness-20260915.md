# Lizbeth Spanish backend readiness receipt — 2026-09-15

## Scope and outcome

The three authorized Supabase Edge Functions were deployed to the user-confirmed production project `gvobtuhbpqvfhjljjcye` (cultural-spanish). No migration, seed, config push, secret update, identity action, data backfill, Netlify action, or unrelated function deployment was performed. Frontend publish remains held.

Deployment is accepted as `DEPLOYED_WITH_LIMITS`; this is not a frontend release approval.

## Provenance

- Git branch: `release/fjds-course-management-20260915`
- Git HEAD: `365153d49530c345abab04a04fa52074bf6604cc`
- Worktree: intentionally dirty pre-existing reviewed work; no source was staged, committed, or reformatted.
- Native Supabase link: `gvobtuhbpqvfhjljjcye`; CLI `2.111.0`.
- External runtime dependency: `https://esm.sh/@supabase/supabase-js@2.110.7`
- `course-authoring/index.ts`: `f92ee6c30c54418a5594c145c5f8620ac5fbb2fbe3790203b7d92135f4cec6c4`
- `admin-student-operations/index.ts`: `d5c1f366ec4d3620e06e71eac93b0ab0e3c41b61bb7dc178567767eede30a`
- `owner-settings/index.ts`: `013bff21af45fcf023c51313a8383f26828379d733274e5e3f53c62b59706ade`
- `supabase/config.toml`: `ca769af3bac928ba012ec143d780a0bda9cdf59ad77b3e5e831b4209f3d38154`
- `package-lock.json`: `f20b14e1063ece0428b33a1403595eaa705b20966285511ed618b5bf46b07921`
- Imported local authorization/error/password helper hashes were captured in the execution handoff; no credentials or raw auth files were recorded.

## Hosted deployment

Each command used the explicit project ref and the default JWT verification setting (no `--no-verify-jwt`):

```text
supabase functions deploy course-authoring --project-ref gvobtuhbpqvfhjljjcye
supabase functions deploy admin-student-operations --project-ref gvobtuhbpqvfhjljjcye
supabase functions deploy owner-settings --project-ref gvobtuhbpqvfhjljjcye
```

| Function | Hosted ID | Version | Status | verify_jwt | Hosted bundle SHA256 |
|---|---|---:|---|---|---|
| course-authoring | `d12e59cf-ddc6-4af8-a0b0-73f01ed43db9` | 1 | ACTIVE | true | `2136389bebf08b7ce5dd357afead4a279acbb9ae426b0497e94c44367dac6c01` |
| admin-student-operations | `ea8d2471-1566-4141-ad06-ee1639ed504e` | 1 | ACTIVE | true | `c436ea854c833e4318f5e72219ccb70448420d43c8508ba06a21cc9fa1107b0d` |
| owner-settings | `4e75b773-332a-41d6-98d0-98f6dfcf6cc1` | 1 | ACTIVE | true | `751b827bcc0c94786fefa2c2f3fef381c2796b9fa2fbd7d4ef4498996feff38c` |

## Contract and safe verification

- `course-authoring`: POST/OPTIONS; handler-level anonymous `catalog` and `preview` reads, authenticated student `grade`/learn reads, and owner-gated authoring operations. Service-role access is constructed only after the relevant owner check.
- `admin-student-operations`: POST/OPTIONS; bearer token is revalidated with `auth.getUser`; `clear-password-change` is self-only, all other actions are owner-gated.
- `owner-settings`: PUT/OPTIONS; bearer token is revalidated and owner-gated; reads remain on the ordinary RLS path.
- All three retain platform JWT verification and use only platform-injected Supabase environment variables. No custom secret was invented or changed.
- OPTIONS returned HTTP 200 for all three. CORS methods were `POST, OPTIONS` for the first two and `PUT, OPTIONS` for owner-settings.
- With a target anon/publishable credential held only in process memory, `course-authoring` `{"action":"catalog"}` returned HTTP 200 and a nonexistent-UUID `preview` read returned HTTP 200. Response bodies were not recorded.
- Requests without Authorization returned HTTP 401 for protected admin, owner-settings, and non-public course-authoring paths.
- No mutation action, temporary account, owner/student account, invitation, enrollment, role change, or settings write was sent.

## Compatibility and ownership finding

The current migration source describes `course_versions` as a compatibility projection and explicitly creates an idempotent `backfill_legacy_courses()` procedure that projects legacy bands, lessons, and resources into courses, versions, revisions, `course_version_lessons`, and `course_assets`. The fresh target aggregate had 3 bands, 78 lessons, 390 resources, 3 courses, and 3 published versions, but zero `course_version_lessons`, `lesson_revisions`, `course_assets`, and `course_preview_lessons`. This is best treated as a missing/backfill-needed projection state, not merely expected legacy compatibility. No backfill was run.

The fresh target also had zero Auth users and zero `owner_settings` rows. The source backfill resolves an owner only from an Auth user with `app_metadata.role = 'owner'`; therefore the three legacy courses are expected to be unowned pending owner bootstrap, subject to direct owner-null aggregate confirmation in the next data handoff. No owner assignment was performed.

The direct post-deploy REST aggregate retry was not used as evidence because the CLI-fetched API credentials received HTTP 401; no credential values or response bodies were emitted. The compatibility conclusion above is based on the authoritative fresh aggregate preflight plus current migration/source review.

## Judge receipts

- Pre-deploy exact model `gemini-3.8-flash-medium`: `READY_TO_DEPLOY`. The review used only the sanitized manifest, auth/config excerpts, provenance, existing test evidence, and stated limits.
- Post-deploy exact model `gemini-3.8-flash-medium`: `DEPLOYED_WITH_LIMITS`. The review used only the sanitized hosted listing, probe statuses, provenance, compatibility analysis, rollback baseline, and remaining limits.
- Both judgments were successful text-only reviews with no judge access to tools, files, commands, network, credentials, or changes.

## Rollback and incomplete gates

The backend started empty of Edge Functions, so rollback is bounded: retain this receipt and function listing, and if needed remove or replace only these three function deployments through the same explicit project ref. No schema/data rollback is needed because no migration or data mutation was run. The frontend rollback baseline remains Netlify deploy `6a91c5a16bd89d0008ba7b80` (ready/locked); it was not changed.

Still blocked and out of this step:

1. Create/confirm the real owner Auth account, set server-only `app_metadata.role = 'owner'` through the guarded procedure, and initialize `owner_settings`.
2. Configure hosted Auth site URL and redirect allow-list for `https://lizbeth-spanish.netlify.app/`.
3. Run and verify the idempotent legacy projection/backfill, with a separate scoped data handoff and aggregate before/after checks.
4. Perform real authenticated owner/student smoke; no identities exist yet.
5. Decide the anonymous archived-preview policy.
6. Complete held candidate frontend build/smoke and rollback verification; do not publish until the root release gates clear.
