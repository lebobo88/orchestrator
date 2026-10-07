# Lizbeth Spanish production Stage D receipt, 2026-10-07

Project `gvobtuhbpqvfhjljjcye`. No `--linked`. No secrets in this file. No Netlify action. Earlier receipts: Phase P (`lizbeth-spanish-issue173-phase-p-apply-20261006.md`), Stage A, B, C (`lizbeth-spanish-prod-stage{A,B,C}-2026100*.md`).

## Status

| Item | Status |
|---|---|
| 1. Newer instructor decks uploaded (78 objects) | DONE, verified |
| 2. Anonymous EXECUTE fix (migration `202610070001`, PR #220 merged, applied to hosted) | DONE, verified |
| 3a. Evidence committed in the orchestrator repo | DONE (local commit; see below) |
| 3b. G173 evidence in the lizbeth_spanish repo (PR #221 merged) | DONE |
| 4. Final read-only smoke | PASS |

## 1. Instructor decks

- Confirmed before writing: the 78 hosted `*-instructor.pptx` objects were the old versions. Their bytes equal the `da6f05c` decks (78 of 78), and the `origin/main` seed decks differ from all 78 hosted objects (dry-run: replace 78).
- Local first (isolated stack, shifted ports): old decks loaded, tool dry-run (78), apply (78 replaced, 390 other objects untouched), idempotent re-run (0 to replace), rollback restored 78.
- Hosted apply with the same re-provision tool (decks-only mode): byte backup of the 78 originals first in `H:\CommandCenter\backups\StageD-decks-20261007T120057Z`, written with `application/vnd.openxmlformats-officedocument.presentationml.presentation` and the original cache-control `max-age=3600`, hash-verified through fresh signed-URL reads with polling, abort on mismatch. Result: replaced 78; post-run check: 78 artifacts equal the seed, the other 390 objects unchanged (etag, type, cache-control).
- After: `check:asset-content-types` on hosted: 468 objects, 0 mismatches, PASS. Decks still owner-only: policy `owner_read_instructor_deck_objects` (owner role, pptx only) is present and `students_read_unlocked_lesson_assets` still excludes pptx (policy check, no logins).

## 2. Anonymous EXECUTE audit and fix

Read-only audit of hosted: of 94 functions in `public`, 31 were executable by anon through the default PUBLIC grant. No call to any of them exists in `src/` or `supabase/functions/`.

| Group | Functions | Action |
|---|---|---|
| Kept anon-executable on purpose | `is_account_active(uuid)`, `user_requires_password_change()` | None: RLS policies that apply to PUBLIC evaluate them |
| Mutating or owner-side SECURITY DEFINER (20) | `apply_enrollment_reconciliation`, `apply_version_migration`, `approve_enrollment_request`, `clone_course_version`, `create_course_with_version`, `finalize_publish_job`, `grant_enrollment_entitlements_with_prerequisites`, `invite_cohort_member`, `materialize_enrollment_entitlements`, `orphan_publish_jobs`, `recalculate_band_progress` (trigger), `recalculate_course_version_completion`, `record_activity_event`, `record_activity_event_with_actor`, `request_cohort_enrollment`, `retry_publish_job`, `save_outline`, `set_lesson_access_state`, `stage_publish_job`, `update_course_settings` | anon and PUBLIC revoked |
| Read-only helpers and others (8) | `assert_course_prerequisite`, `course_version_completion_ratio`, `get_lesson_progress_evidence`, `has_completed_course_version`, `list_migration_enrollments`, `preview_enrollment_reconciliation`, `resolve_entitlement_anchor`, `reject_asset_mutation` (trigger) | anon and PUBLIC revoked |
| `recalculate_progress_completion(uuid)` | internal helper, only called by other SECURITY DEFINER functions | anon, PUBLIC and authenticated revoked; service_role only |

(20 + 8 = 28 functions revoked from anon and PUBLIC, plus `recalculate_progress_completion` = 29 changed; with the 2 kept helpers that is the 31 found.)

- Done test-first on a new branch and worktree (`fix/anon-execute-grants`, worktree `lizbeth_spanish-anon`): new test `anonFunctionExecuteGrants.test.ts` failed 4 of 5 before the migration. Writing it also exposed that, on a local project, authenticated and service_role only had access through PUBLIC, so the migration grants `authenticated, service_role` explicitly (no behaviour change for them).
- Local: fresh `db reset` (49 migrations), the new test (5 of 5) and 119 related files (1636 tests: #174 to #180, RLS, entitlements, course, Edge live suites) pass; `tsc` clean.
- Rollback prepared, not applied: `supabase/rollbacks/revoke_anon_execute_internal_functions_rollback.sql`.
- PR #220 (`Refs #172`, no closing keyword): checks passed (Netlify deploy preview only), squash-merged as `f8ee2072adaa41e1689bdc23b29da8e19feaa600`. The change touches only SQL, the rollback file and one test, so it did not change the client.
- Hosted apply: recorded in `schema_migrations` (now 49 versions, latest `202610070001`). Read-only grant check afterwards: anon can execute exactly `is_account_active` and `user_requires_password_change`; `recalculate_progress_completion` is anon false, authenticated false, service_role true; no authenticated or service_role grant changed on any other function.
- Follow-up, not done: the same 28 functions remain executable by authenticated. Several are owner-side and the app does not call them directly, so each should be reviewed for in-function authorization and, where unused, restricted to service_role in a later change.

## 3. Evidence commits

- lizbeth_spanish repo: PR #221 `docs/g173-cutover-evidence`, squash-merged as `914ba4f4b7e790764be88bb38ce0b5cff4653a9d`: 36 `G173-*` files (about 1.2 MB, each with a sha256 sidecar). Scanned for JWTs, `sb_secret`, `sbp_`, `token=`, `apikey` and `Bearer`: none. No lesson bytes. On Windows the checkout may convert line endings, which changes the file bytes against the sidecar digests; the digests were computed on the files as written.
- orchestrator repo: this rollout's files under `docs/evidence/` committed on its current branch; see the commit hash in the hand-off message. The repo has an `origin` remote (`git@github.com:lebobo88/orchestrator.git`) and the branch tracks `origin/main`, but nothing was pushed, per your rule.

## 4. Final smoke

All 8 routes HTTP 200, `public_site_content` 200, 0 console errors, 0 page errors, 0 failed requests (`lizbeth-spanish-prod-stageD-smoke-after-assets/`).

## Backups to keep until you confirm

`H:\CommandCenter\backups\`: `G173-*`, `StageA-*`, `StageB-*`, `StageB-reprovision-*` (the complete original content set), `StageB-reprovision2-*`, `StageB-reprovision3-*`, `StageD-decks-20261007T120057Z` (original decks).

## Remaining

1. Owner spot-check of at least 5 weekly recaps and the Workspace practice text; one student-authenticated end-to-end pass (task form, quiz, mark then review then quiz completion). Not possible without logins.
2. Optional follow-up issue: review authenticated EXECUTE on the 28 internal functions.
3. Housekeeping: worktrees `lizbeth_spanish-173b`, `lizbeth_spanish-anon` and `lizbeth_spanish-evidence` remain; the local scratch stack `lizbeth_stagea` is running or stopped with kept volumes (scratch only).
