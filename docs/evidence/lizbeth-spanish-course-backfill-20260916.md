# Lizbeth Spanish course backfill receipt — 2026-09-16

Scope: one approved backfill on Supabase project `gvobtuhbpqvfhjljjcye` only; exact owner `thereallizbeth@gmail.com`. No old-project, seed, reset, identity, enrollment, Netlify, frontend publication, or configuration action was performed.

## Gate and execution

- Fresh precheck passed: 3 bands, 78 lessons, 390 resources; 3 ownerless legacy courses; 0 authored versions/revisions; 0 projection links/assets; 0 enrollments; 468 `lesson-assets` storage objects; owner/settings/users invariant present; client execute denied.
- Backup pair: `lizbeth_spanish/docs/cutover-evidence/G9b-schema-20260916T125447Z-gvobtuhbpqvfhjljjcye.sql` (230135 bytes, SHA-256 `ac03271bad909c9cabe75120b8842eab1e88c8c0732479a4f3f08e32e7d18d72`) and `lizbeth_spanish/docs/cutover-evidence/G9b-data-20260916T125447Z-gvobtuhbpqvfhjljjcye.sql` (369529 bytes, SHA-256 `07ae7ca35c19fe906aa524f58812c54edabe3d78102bf88fb73d0c8afe6c167d`). Companions matched; `require-backup.js --gate G9b` passed. Data dump emitted the expected circular-FK warning.
- AGY pre-review: conversation `aafa7767-3375-4a86-86c6-6b08f1b61e1c`, terminal `SUCCESS`, model `gemini-3.8-flash-medium`, verdict `APPROVE`.
- Exact native privileged write executed once: `BEGIN; SELECT public.backfill_legacy_courses(); COMMIT;` Result returned without error; no retry or additional write occurred.

## Postcheck

- 3/3 legacy courses owned by the selected owner; 0 nonselected owners; legacy field mismatches 0.
- 3 published v1 versions; `is_current=true` count 0 as expected; 78 revisions; 78 version links; 0 bad revision/link joins or lesson-field mismatches.
- 390 assets; all `unverified_legacy` with null SHA as expected; 0 bad asset joins/paths; 0 resources without matching assets.
- Legacy counts unchanged: 3 bands, 78 lessons, 390 resources. Storage unchanged: 468 objects in `lesson-assets`. Users=1, owner role distribution unchanged, owner settings=1, dashboard settings=0, enrollments=0.
- ACL fingerprint unchanged at `5d5c3f62b85103c230c06f2e8e320ee2`; anon/authenticated backfill execute remained denied, service role allowed. Migrations remained 33 through `202609150002`.
- Deployed function fingerprint remained `b0c5c6194c8cd8d167aa51a618496ce8`; normalized local/deployed body fingerprint remained `dcaa2498de2406a9db87421922fd6918`.
- Previews remain 0 and `is_preview=0` remains expected. Preview/current activation is a separate decision and was not performed.
- AGY post-review: conversation `05586510-e919-469f-be0a-3dbba301db21`, terminal `SUCCESS`, model `gemini-3.8-flash-medium`, verdict `ACCEPT`.

Limitations: legacy assets are metadata-only and remain unverified with null SHA; no frontend publication, Netlify verification, hosted owner/student browser proof, or end-to-end runtime test was performed. This receipt records bounded evidence, not absolute operational certainty.
