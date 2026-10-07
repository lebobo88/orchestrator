# Lizbeth Spanish production read-only audit (#176 / #177), 2026-10-06

Project `gvobtuhbpqvfhjljjcye`. Strictly read-only: no writes, no `--linked`, no database password.

## Method
- SQL source: `scripts/audit/issue176-completion-audit.sql` from `origin/main` (8e89737), 9 statements (a, b, c, d.1, d.2, d.3, e, f, g), run one statement at a time. The file's own `begin read only` wrapper was stripped because each statement is its own request.
- Transport: Supabase Management API read-only endpoint `POST /v1/projects/gvobtuhbpqvfhjljjcye/database/query/read-only` with the explicit project ref. The token comes from the local Supabase CLI credential store, was kept in memory only and never printed or stored. The endpoint itself rejects writes.
- Also run read-only: `owner_settings` row count, `supabase_migrations.schema_migrations`, `to_regclass` and `pg_proc` presence checks, Edge Function list.
- Raw results (counts and one band id only): `lizbeth-spanish-prod-audit-176-177-20261006.json` (+ .sha256).

## Step 10 thresholds (pre-apply) and results

| Item | Result | Threshold | Verdict |
|---|---|---|---|
| (g) completed mirror rows with no mapped revision in the enrollment version | 0 (ALL) | must be fully explained by (f) | GO |
| (f) legacy lessons with no `lesson_revisions` row | 0 lessons, 0 bands | explains (g); 0 required post-apply | GO (already 0) |
| (b) bands with more than one published version | 0 | informational; version selection unambiguous | GO |
| (a) active/preserved enrollments with null `course_version_id` | 2 (both in band 7be70def-2b70-4989-a017-c493ef654d97) | informational pre-apply; must be 0 post-apply (backfill `202610030002`) | GO, expected to drop to 0 after apply |
| (c) entitlement rows per enrollment | 2 enrollments, 2 with zero rows, 0 with rows, 0 with a version but zero rows | informational | GO (no entitlements materialized yet; migration creates them) |
| (d.1) slp completed but entitlement missing or incomplete | missing 1, incomplete 0 | informational pre-apply; mapped diff must be 0 post-apply | GO (1 row to materialize via backfill); must be 0 after apply |
| (d.2) entitlement completed but slp missing or incomplete | 0, 0 | 0 post-apply | GO |
| (d.3) legacy lessons with no mapped revision in the enrollment's version | 0 pairs, 0 lessons | 0 | GO |
| (e) enrollments whose `completed_at` would change | would_set 0, would_clear 0, manual_untouched 0 | review only (backfill never clears) | GO |
| #177 `owner_settings` row count | 1 | STOP if more than 1 | GO |

Overall: GO on every Step 10 pre-apply threshold. Step 10 still requires the user's separate explicit approval, a fresh backup/PITR marker and snapshot exports before applying; none of that was done here.

## Migrations: hosted vs `origin/main`

- Applied in hosted: 33 (latest `202609150002_revoke_backfill_legacy_courses_execute`). In `origin/main`: 48. Applied but not in the repo: none.
- Pending (15), in order:

| # | Version | Issue |
|---|---|---|
| 1 | 202610030001_issue176_single_completion_record | #176 |
| 2 | 202610030002_issue176_band_enrollment_backfill | #176 |
| 3 | 202610030003_issue177_owner_settings_singleton | #177 |
| 4 | 202610040001_issue177_site_content | #177 |
| 5 | 202610040002_issue174_student_course_assets | #174 |
| 6 | 202610040003_issue179_lesson_tasks | #179 |
| 7 | 202610040004_issue179_seed_lesson_task_templates | #179 |
| 8 | 202610040005_issue179b_owner_event_attribution | #179b |
| 9 | 202610040006_issue179c_completion_gate | #179c |
| 10 | 202610040007_issue179c_draft_rate_limit | #179c |
| 11 | 202610050001_issue180_lesson_quizzes | #180 |
| 12 | 202610050002_issue180_seed_lesson_quiz_definitions | #180 |
| 13 | 202610050003_issue180c_owner_quiz_authorization | #180c |
| 14 | 202610050004_issue180d_quiz_completion_gate | #180d |
| 15 | 202610050005_issue180d_instructor_decks_owner_only | #180d |

Confirmed absent in hosted: tables `site_content`, `lesson_tasks`, `lesson_quizzes`, `student_course_assets`; view `public_site_content`; RPCs `get_enrollment_lesson_completion`, `resolve_band_course_version`, `sync_legacy_completion_to_entitlement`, `assign_band_enrollment`. The `owner_settings` table exists (1 row) although `202610030003` is not recorded as applied. Deployed Edge Functions: `course-authoring`, `admin-student-operations`, `owner-settings` (all v1); `site-content` is not deployed.

## Interaction to note
The live site (deploy `aa99662`) already runs the new client against this older backend; see the smoke report. The pending set is: the 15 migrations, the Edge Function redeploys (plus `site-content`), and a refresh of the lesson-assets storage content (production still holds the pre-#178/#179/#180 content that the Phase P overlay matched).
