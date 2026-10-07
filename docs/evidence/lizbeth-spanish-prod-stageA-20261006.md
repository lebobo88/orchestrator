# Lizbeth Spanish production Stage A rollout, 2026-10-06

Project `gvobtuhbpqvfhjljjcye`. Source: `origin/main` `8e89737`. No `--linked`. No secrets in this file. No Netlify action. Nothing committed.

## Status summary

| Step | Status |
|---|---|
| 1. Local functional verification (isolated stack) | PASS |
| 2. Hosted backup + rollback files | DONE |
| 3. Five migrations applied one at a time, verified | DONE, all verified |
| 4. Edge deploy | PARTIAL: `owner-settings` and `site-content` deployed; `admin-student-operations` and `course-authoring` NOT deployed (blocking finding below) |
| 5. Anonymous smoke re-run | PASS (`public_site_content` 404 gone, 0 console errors) |
| 6. Evidence | this file and sidecars |

## BLOCKING FINDING: two Edge functions held back

The `admin-student-operations` and `course-authoring` sources at `8e89737` read `lesson_task_submissions`, `quiz_attempts` (and call `grade_lesson_quiz_attempt`, `review_lesson_task_submission` and similar). Those tables and RPCs come from the #179/#180 migrations (`202610040003` to `202610050005`), which are out of Stage A scope and not applied. In the existing handlers, a missing relation returns an error:
- `admin-student-operations` `dashboard` (lines about 761 to 773) and `student-detail` (about 901 to 912) return `classifiedErrorResponse` if the task or quiz query errors.
- `course-authoring` `list_progress` (about 608 to 616) returns 422 "Roster entitlements unavailable." on a task or quiz query error.

Deploying those two functions now would therefore break the owner dashboard, roster, student detail and Course Workspace progress in production. I stopped before deploying them. They stay at the current v1. Both new actions (`sign_student_course_asset` for #174 and `get_owner_resource_text` for #175) live in `course-authoring`, so #174 handout signing and #175 owner recap preview are not live yet.

Decision needed: either (a) approve the #179/#180 migrations too (then deploy both functions), or (b) approve a function build that tolerates missing #179/#180 relations (a code change, not done here).

## 1. Local verification (isolated stack, project id `lizbeth_stagea`, ports 54421 and up)

A second local stack on shifted ports was built from a clean `git archive 8e89737` (scratch config only; the other worktrees' stack was not touched and is still running). Test ports and container names in the scratch copy were rewritten to the shifted ports.

- Full chain: 48 migrations applied by `supabase start`. Vitest, 39 files (#176, #177, #174, #175, completion data, handout, site content, owner settings, RLS, entitlements, vocabulary): 38 passed, 1 skipped, 539 tests passed. A second run with `HANDOUT_COVERAGE_LIVE=1` of the four live Edge suites, the live handout coverage test and the #176 SQL suite: 7 files, 84 tests passed. The four functions were exercised live: `admin-student-operations` and `course-authoring` (#176 dashboard, student detail, `list_progress`), `sign_student_course_asset` (20 tests), `get_owner_resource_text` (11 tests, all 78 recaps parse and render), `site-content` (8 tests), `owner-settings` singleton write (4 tests).
- Backfill semantics: on the seeded local data, the audit before re-running the backfill showed `(d.1) entitlement missing 74`. After re-running `202610030002` (idempotent) the audit showed (a)=0, (d.1)=0, (d.2)=0, (d.3)=0, (f)=0, (g)=0, `completed_at` never cleared (would_clear 0). One local fixture enrollment keeps zero entitlements after materialization (local seed oddity; hosted shows 0 such enrollments).
- Subset rehearsal: `supabase db reset --version 202610040002` (exactly the Stage A chain) applied cleanly with seeds; the #176/#177/#174 SQL suites passed (86 of 87 tests). The one failure, `A5: owner reset ... records the activity event`, expects an extra event payload field added by #179 migration `202610040005`, which is outside Stage A.
- Evidence: `lizbeth-spanish-prod-stageA-local-vitest-summary.txt`, `lizbeth-spanish-prod-stageA-local-audit-post-backfill.txt`.

## 2. Hosted backup and rollback files

- Data backup (read-only Management API queries, JSON + sha256 per table) in `H:\CommandCenter\backups\StageA-20261006T160131Z-gvobtuhbpqvfhjljjcye\`: `student_enrollments` (2 rows), `enrollment_lesson_entitlements` (0), `student_lesson_progress` (1), `owner_settings` (1), `owner_dashboard_settings` (0), `lessons` (78), `lesson_revisions` (78), `course_versions` (3), `courses` (3), `course_version_lessons` (78), `resources` (390), `activity_events` (0), `feedback_submissions` (1), `schema_migrations` (33), `function_defs` (the 6 pre-change function definitions), `policies`.
- Rollback files in `supabase/rollbacks/` at `8e89737`: `issue176_single_completion_record_rollback.sql` (also covers the 176 backfill additions, which are additive and intentionally left), `issue177_owner_settings_singleton_rollback.sql`, `issue177_site_content_rollback.sql`, `issue174_student_course_assets_rollback.sql`. Not applied.
- No PITR marker was taken (not available through the read-only path); the data backups above and the previously retained Phase P backups stand in.

## 3. Hosted migrations, one at a time (Management API `database/query`, explicit ref, one transaction per migration)

Each migration ran with an inserted `supabase_migrations.schema_migrations` row (`version`, `name`, `statements`; `statements` holds the whole file as one element rather than the CLI's per-statement split).

| # | Version | Result | Verification |
|---|---|---|---|
| 1 | 202610030001_issue176_single_completion_record | applied | 11 functions present, all SECURITY DEFINER; `get_enrollment_lesson_completion` executable only by authenticated and service_role; new internal functions only service_role; both triggers present |
| 2 | 202610030002_issue176_band_enrollment_backfill | applied | audit post-apply: (a) null `course_version_id` = 0; (b) 0; (c) 2 enrollments with 26 entitlement rows each (52 total, 1 completed); (d.1) entitlement missing 0, incomplete 0; (d.2) 0; (d.3) 0; (e) would_set 0, would_clear 0; (f) 0; (g) 0 |
| 3 | 202610030003_issue177_owner_settings_singleton | applied | 1 row, `singleton` NOT NULL with check constraint, `owner_id` nullable and unique |
| 4 | 202610040001_issue177_site_content | applied | table RLS on, only a service_role policy; `public_site_content`: anon select yes, anon insert no; base table: anon and authenticated no access, service_role insert yes; view returns 0 rows |
| 5 | 202610040002_issue174_student_course_assets | applied | `get_student_lesson_assets` and `resolve_student_course_asset` present, SECURITY DEFINER, executable only by authenticated (matches local) |

Final state: 38 migrations recorded (33 plus these 5); owner_settings still 1 row. Pending and untouched: the 10 migrations `202610040003` to `202610050005` (#179/#180).

Observation (pre-existing, unchanged by this rollout): `recalculate_progress_completion(uuid)` is executable by anon and authenticated, the same as local and before the migration (the migration keeps its grants unchanged). Worth a separate review.

## 4. Edge functions

| Function | Action | Result |
|---|---|---|
| `owner-settings` | deployed (from 8e89737, verify_jwt true as before) | no-JWT POST 401; anon-key POST 405 (method not allowed, i.e. reached the function) |
| `site-content` | deployed (new, verify_jwt true) | no-JWT POST 401; anon-key POST 405; OPTIONS 200 |
| `admin-student-operations` | NOT deployed (see blocking finding) | still v1; no-JWT 401 |
| `course-authoring` | NOT deployed (see blocking finding) | still v1; no-JWT 401 |

New hosted RPCs were confirmed through read-only catalog queries (the anonymous REST probe returns PGRST202 for any parameterised function called with an empty body, so it cannot prove existence). Hosted storage CORS: the preflight with `Access-Control-Request-Headers: range` returns 200 with `Access-Control-Allow-Headers: range` and `Allow-Origin: *`, so Range reads for #175 are allowed. Optional `scripts/check-hosted-handout-coverage.sql` (read-only, run statement by statement): 78 of 78 `OK`, 0 stray objects, summary verdict `PASS` (78 structurally OK, 78 with `application/pdf`, 0 pending Phase P). #177: I created no test keys, so nothing to reset; `site_content` is empty (defaults).

## 5. Anonymous live smoke after the rollout

Same routes as the pre-rollout run. Result: all 8 routes HTTP 200, `public_site_content` now 200 on every route, 0 console errors, 0 page errors, 0 failed requests, `/courses` still loads the catalog. Raw: `lizbeth-spanish-prod-stageA-smoke-after-assets/` (`smoke.json` + sha256 + screenshots). Pre-rollout comparison: `lizbeth-spanish-prod-smoke-20261006.md`.

## 6. Follow-ups for the user

- Owner (Lizbeth Spanish) spot-check, requested for #175: open at least 5 weekly recaps in the in-app vocabulary review, across all three bands, once `get_owner_resource_text` is live (it is not live yet; it ships with the held `course-authoring` deploy). Locally all 78 parse and render clean, but production recaps still hold the pre-#178/#179/#180 content.
- Decide the two held Edge functions (blocking finding above).
- Student handout signing (#174) also waits on the `course-authoring` deploy.

Data and probe results: `lizbeth-spanish-prod-stageA-data-20261006.json` (+ sha256).
