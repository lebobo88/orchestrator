# Issue #222 receipt: least-privilege EXECUTE for internal public functions, 2026-10-07

Project `gvobtuhbpqvfhjljjcye`. No `--linked`. No secrets. No data changed; grants only. No Netlify action. Follows `lizbeth-spanish-prod-stageD-20261007.md` (anon fix, PR #220).

## Result

| Item | Status |
|---|---|
| Caller analysis (28 functions) | Done |
| Migration `202610070002_revoke_authenticated_execute_internal_functions` | Test-first, PR #223 merged (`88b43fd37f04af90860fc93b5f3c8e4d696a48f9`), applied to hosted, recorded (50 versions) |
| Hosted grant verification (read-only) | PASS |
| Read-only anonymous smoke and Edge probes | PASS |

## Caller analysis

| Check | Finding |
|---|---|
| Client `src/` RPC calls | Only student RPCs: `get_enrollment_lesson_completion`, `get_lesson_quiz`, `get_lesson_quiz_summaries`, `get_lesson_task`, `get_lesson_task_summaries`, `get_student_lesson_assets`, `mark_lesson_quiz_results_seen`, `mark_lesson_task_feedback_seen`, `record_lesson_completion`, `record_lesson_progress`, `request_version_enrollment`, `reveal_lesson_quiz`, `save_lesson_task_draft`, `submit_lesson_quiz_attempt`, `submit_lesson_task`, `get_student_learn_index`, `get_student_learn_course`, `resolve_student_course_asset`. None is in the 28. |
| Edge functions | `course-authoring` calls 15 of the 28 (create/update/clone/save/stage/finalize/retry, migration, enrollment and access-state actions) through its service-role client after its own owner check; its only user-JWT RPCs are `get_student_learn_index`, `get_student_learn_course`, `resolve_student_course_asset`. `admin-student-operations`, `owner-settings` and `site-content` make no user-JWT RPC calls. |
| SQL callers | Every database function that mentions these names (27 found, including some of the 28 themselves) is SECURITY DEFINER (run as owner), so callees need no authenticated grant. |
| Policies, views, column defaults, check constraints | None reference any of the 28. |
| Triggers | `recalculate_band_progress` (lessons) and `reject_asset_mutation` (course_assets) are trigger functions; EXECUTE is not checked when a trigger fires. |
| Original grants | All migrations granted these to service_role only, except `request_cohort_enrollment` (authenticated). The authenticated access came from the PUBLIC default. |

Classification: 27 revoked from authenticated (service_role only). Kept for authenticated: `request_cohort_enrollment(uuid, text)` (its original grant; shared entry point behind `request_version_enrollment`, which is SECURITY DEFINER and carries the entry guards). Uncertain-keeps: none beyond that one; the in-function owner checks were left untouched.

## Local verification

Fresh `supabase db reset` (50 migrations) on an isolated stack. New test `authenticatedFunctionExecuteGrants.test.ts`: 3 of 6 failed before the migration; 6 of 6 pass after. Whole `src/__tests__` run against the stack, including the live Edge, RLS, entitlement, task, quiz and completion suites: 4779 passed, 4 skipped; one file failed (`fieldJournalTokens`, which needs a parent-directory config present only in the full checkout; unrelated). `tsc` clean. The intermediate assertion in the anon test (authenticated keeps grants) was updated, since #222 supersedes it.

## Hosted verification (read-only, after apply)

- `schema_migrations`: 50 versions, latest `202610070002`.
- authenticated can execute exactly 22 functions, matching the allowlist: `get_enrollment_lesson_completion`, `get_lesson_quiz`, `get_lesson_quiz_summaries`, `get_lesson_task`, `get_lesson_task_summaries`, `get_student_learn_course`, `get_student_learn_index`, `get_student_lesson_assets`, `is_account_active`, `mark_lesson_quiz_results_seen`, `mark_lesson_task_feedback_seen`, `owns_lesson_asset_path`, `record_lesson_completion`, `record_lesson_progress`, `request_cohort_enrollment`, `request_version_enrollment`, `resolve_student_course_asset`, `reveal_lesson_quiz`, `save_lesson_task_draft`, `submit_lesson_quiz_attempt`, `submit_lesson_task`, `user_requires_password_change`.
- anon: only `is_account_active(uuid)` and `user_requires_password_change()`.
- Changes versus before: 27 authenticated grants removed, 0 anon changes, 0 service_role changes. All 27 revoked functions keep service_role.
- Note: 8 student-only functions (`get_lesson_quiz`, `get_lesson_quiz_summaries`, `get_student_lesson_assets`, `mark_lesson_quiz_results_seen`, `resolve_student_course_asset`, `reveal_lesson_quiz`, `submit_lesson_quiz_attempt`, `submit_quiz_attempt` (legacy, retired)) have no service_role grant. That is how they were created and was not changed.
- Edge probes: no-JWT POST 401 on `admin-student-operations` and `course-authoring`, `owner-settings` and `site-content` respond (401 or 405), none 404. Live anonymous smoke: 8 of 8 routes 200, 0 console errors, 0 failed requests (`lizbeth-spanish-prod-issue222-smoke-after-assets/`).
- Grant listing before and after: `lizbeth-spanish-prod-issue222-grants-after.json`.

## Rollback

`supabase/rollbacks/revoke_authenticated_execute_internal_functions_rollback.sql` (prepared, not applied): re-grants authenticated EXECUTE on the 27 functions.
