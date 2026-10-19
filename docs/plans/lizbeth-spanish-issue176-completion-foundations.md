# Plan: lizbeth-spanish issue #176, single completion record and band course_version_id

## Status

APPROVED by the user on 2026-10-03 (all four approved together in the orchestrator session). Cleared for engineering per this plan. See the Approval record at the end of this document for the limits of that approval.

- plan_id: `lizbeth-spanish-issue176-completion-foundations`
- task_id: `lizbeth-spanish-issue176`
- route: engineering
- target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (separate git repository; default branch `main`)
- Planner verification date: 2026-10-03 (file-level)
- Approval gate: T1 does not start until the user explicitly approves this plan. Production application (Step 10) requires a separate explicit user go-ahead.
- Revision: one revision applied after `PLAN_DUCK` (verdict REVISE; findings J-001, J-002, J-003 accepted and remediated). Decisions D1-D5 are resolved. See "Judge findings and disposition" and "Resolved decisions".
- Remaining approvals: explicit user approval of this plan, and the separate production-apply approval (Step 10).

## Outcome and audience

Source: GitHub issue lebobo88/lizbeth-spanish#176 "Foundations: single completion record (entitlements) + course_version_id for band-assigned students" (epic #172).

Audience: students using Roadmap/WeekDetailPage and `/learn`, and the owner using the dashboard, student detail, and Course Workspace Progress/Roster.

Observable result:

1. A lesson completed on either student surface shows identical completion state on both surfaces and on every owner view.
2. Band-assigned students appear on `/learn` instead of "No enrolled courses yet".
3. `student_enrollments.completed_at` no longer flaps between two recalculation routines.

## Scope and non-goals

### User decisions (binding)

1. `public.enrollment_lesson_entitlements.completed_at` is the single source of truth for lesson completion.
2. Roadmap completion syncs into it via `lesson_revisions.legacy_lesson_id`.
3. All owner views read entitlement-derived data.
4. Band-assigned enrollments receive `course_version_id` on the assign path plus a forward-only backfill migration, so they appear on `/learn`.
5. Later features (#179 task form, #180 quizzes, #174/#175 resources) will be shared components rendered on both surfaces and must compute completion from entitlements. This plan only lays the shared completion data layer they consume.
6. Both surfaces stay live (the Phase 5 plan deprecates neither).

### In scope

- Forward-only SQL migrations.
- Changes to `record_lesson_progress`, `recalculate_progress_completion`, `reset_lesson_completion`, `record_lesson_completion`, `set_lesson_completion`.
- A student read RPC for Roadmap completion.
- The `admin-student-operations` assign, resume, dashboard, student-detail, and reset handlers.
- `course-authoring` `list_progress`.
- Client services and hook for Roadmap completion reads.
- `seed.sql` alignment.
- Tests.
- A read-only production audit script.
- A separately gated production migration step.

### Non-goals

- Building #179, #180, #174, or #175.
- Deprecating or redesigning either student surface.
- Any visual redesign.
- Removing the `student_lesson_progress` table or its open/activity timestamps.
- Changing prerequisite/threshold gate semantics. Gates keep computing live and never read the `student_enrollments.completed_at` cache (per `202608300002` lines 121-128).
- Applying anything to production without a separate explicit user go-ahead.
- Commits, pushes, or PRs unless the user explicitly authorizes them.

## Repository findings and evidence references

Verified at file level by Planner on 2026-10-03. Paths are relative to `lizbeth_spanish`.

### Two progress systems

- Roadmap path: `WeekDetailPage` -> `src/lib/useLessonCompletion.ts:83` `recordLessonProgress` -> `src/services/adminStudentData.ts:173-177` rpc `record_lesson_progress`. Hydration reads `student_lesson_progress` directly at `adminStudentData.ts:180-184` (`getLessonProgress`) and `199-214` (`getLessonProgressForEnrollment`, used by `BandRoadmap`).
- `record_lesson_progress` is defined at `supabase/migrations/202608270001_issue2_progress_dashboard.sql:47-79`. It applies a band-scoped lock rule (`enrollment_date + unlock_offset_days`) and calls legacy recalculation on `'complete'`.
- `/learn` path: `LearnDetailPage` -> `src/services/learnData.ts:139-156` `markLessonComplete` -> rpc `record_lesson_completion` (`202608300002_issue5_phase3_enforcement_sql_core.sql:373-403`). It is monotonic, refuses held, revoked, and not-yet-unlocked lessons, and calls `recalculate_course_version_completion`.
- `/learn` reads use `get_student_learn_index` and `get_student_learn_course` (`202608310002_issue5_phase5_student_learn_sql_core.sql`). They inner-join `course_versions` on `se.course_version_id` with `status='published'` (lines 146-159, 207-219), so an enrollment with null `course_version_id` is invisible on `/learn`.

### Recalculation conflict (flapping)

- Legacy `recalculate_progress_completion` (`202608270001:87-101`) counts band lessons in `student_lesson_progress` and clears `completed_at` when `auto_completed_from_progress` is set and not all lessons are done.
- `recalculate_course_version_completion` (`202608300002:331-356`) uses `course_version_completion_ratio` (`202608300002:137-159`) against `courses.completion_threshold` (default 1.0).
- Both write the same `student_enrollments.completed_at` / `auto_completed_from_progress` pair, so each can undo the other.
- Legacy recalculation is also invoked by `reset_lesson_completion` (`202608270001:103-117`) and by the lessons trigger `recalculate_band_progress` (`202608270001:119-135`).

### Owner views

- `supabase/functions/admin-student-operations/index.ts`:
  - `handleDashboard` (682-733): progress from `student_lesson_progress` at 688; completion counted only over "authored" legacy lessons that have a `lesson_content` resource and are unlocked.
  - `handleGetStudentDetail` (754-829): `recorded_completions` from `student_lesson_progress` at 789.
  - `handleResetLessonCompletion` (744-752): returns 404 if no `student_lesson_progress` row exists; calls rpc `reset_lesson_completion`.
- `course-authoring/index.ts`: `list_progress` (213-219) reads `student_lesson_progress`. `list_lesson_entitlements` (500-508) and the Roster in `src/pages/CourseWorkspacePage.tsx` (~512) already read entitlements. `get_progress_evidence` (494-498) reads entitlements.
- Owner `set_lesson_completion` (`202608300002:417-484`, service_role only) may set or clear and refuses marking held/revoked rows complete.

### Assign and resume paths

- `admin-student-operations/index.ts:484-493` inserts `{user_id, band_id, enrollment_date, status:'active'}` with no `course_version_id` and no entitlement materialization.
- The resume path (456-481) flips a preserved enrollment to active with no `course_version_id` or entitlement handling.

### Precedents that set course_version_id

- Cohort invite enrollment: `202608300005_cohort_invite_enrollment_grant.sql:129-143`.
- `approve_enrollment_request` and `request_cohort_enrollment`: `202608300001_issue5_phase2_cadence_sql_core.sql:375-420`, which call `materialize_enrollment_entitlements`.
- `backfill_legacy_courses` (`202608280003_issue5_course_authoring.sql:556-587`, service_role only per `202609150002`) already contains `update student_enrollments set course_version_id=cv.id from course_versions cv where cv.band_id=e.band_id and cv.status='published' and e.course_version_id is null` (line 579). It is non-deterministic if a band has more than one published version (`clone_course_version` copies `band_id`, `202608280003:332`), and it has not been re-run in production since band-assign enrollments were created.

### Materialization and mapping

- `materialize_enrollment_entitlements` current definition: `202608300001:50-65`. It anchors via `resolve_entitlement_anchor`, is idempotent, and inserts nothing when `course_version_id` is null or the version is not published.
- `lesson_revisions.legacy_lesson_id` (`202608280003:55-65`) maps v1 revisions to legacy lessons. `save_outline` creates new revisions without `legacy_lesson_id` (`202608300001:440`), so a later authored version of a legacy course may have unmapped revisions.

### Seed, RLS, tests, and local run

- The only existing sync is local-only: `supabase/seed.sql:527-537` copies `student_lesson_progress.completed_at` into entitlements. The seed deliberately leaves `fullaccess` with zero entitlement rows for `wp11-learn.spec.ts`'s legacy-materialization branch (`seed.sql:504-508`) and re-runs `backfill_legacy_courses` (517).
- Student RLS: `student_lesson_progress` select policy (`202608270001:29-37`); `entitlements_own` policy hides held/revoked and not-yet-unlocked rows (described in `202608310002:6-13`).
- Latest migration on disk: `202609150002_revoke_backfill_legacy_courses_execute.sql`.
- Tests: vitest under `src/__tests__`. SQL tests connect via `pg` to `127.0.0.1:54322` inside BEGIN/ROLLBACK and run as the authenticated role with a student JWT claim for RLS assertions (for example `issue5-phase5-sql-core.test.ts`). Edge contract/live tests include `adminStudentOperationsFixes.test.ts` and `issue5-phase5-learn-edge-live.test.ts`. Playwright e2e lives in `src/__tests__/e2e` (`wp11-learn.spec.ts`, `owner-dashboard.spec.ts`, `wp3-owner-dashboard.spec.ts`, `phase5-learn-detail-live-verification.spec.ts`).
- Local run (`README.md:49-60,174-198`): `npx supabase start` (Postgres 54322, API 54321, Studio 54323); `npx supabase db reset` (migrations + `seed.sql` + `seeds/full-catalog.sql`); `npm run dev` (Vite, http://localhost:5173; `predev` runs `ensure:bucket`). `playwright.config.ts` `baseURL` defaults to http://localhost:8888 via `npm run build && netlify serve --context production --port 8888` unless `E2E_BASE_URL` is set.

### Research

Research evidence: none. Research was classified as not needed; all decisions are grounded in local repository evidence and the user decisions above.

## Design route

- `DESIGN_ROUTE` profile: `none`.
- Reasons: no new screen, component, state, copy, or visual change. Roadmap, `/learn`, owner dashboard, student detail, and workspace Progress only change their data source. Band-assigned students reuse the existing `/learn` rendering. Existing error states (`useLessonCompletion` `saveError`, `LearnDataError`) are reused unchanged.
- agents_required: none. prototype: forbidden. existing_system_mode: preserve.
- design_handoff: none. design_review: none.
- Stale-plan trigger: if implementation finds it must add or change any user-visible copy or state, it must stop with `Plan stale` and the plan returns to Planner for a Compact design route.

## Judge route

- Risk: high (production data migration, SECURITY DEFINER functions, cross-surface data flow).
- `PLAN_DUCK`: required before approval. Rubric: forward-only migration safety, RLS/SECURITY DEFINER parity, `completed_at` flapping elimination, backfill determinism, rollback realism.
- `CODE_REVIEW`: required after `JOB_DONE` and before Verifier. Rubric: guard parity, grants/revokes, monotonic completion, idempotent backfill, no gate reading the `completed_at` cache.
- `VERIFICATION_CHALLENGE`: conditional, only if evidence or coverage risk remains after `VERIFICATION_PASS`.
- `VISUAL_REVIEW`: skipped (no design change).
- Call cap: 4 total; one repeat after remediation; more needs user approval.
- Findings flow: judge finding IDs are carried into the engineering job and Verifier brief. `PLAN_DUCK` findings J-001 to J-003 and their disposition are recorded below.

### Judge findings and disposition

`PLAN_DUCK` (Codex, shadow/advisory) verdict: REVISE. Planner checked each finding against the repository files, accepted all three, and this revision remediates them.

- **J-001 (accepted, remediated).** Evidence: `materialize_enrollment_entitlements` inserts a row only when the lesson's prerequisite revision is already completed (`202608300001_issue5_phase2_cadence_sql_core.sql:60-63`). `record_lesson_completion` denies the lesson when the entitlement row is missing (`202608300002:387-394`) and never grants dependents. The earlier draft treated a missing mapped entitlement as a no-op in 3b while 3c still wrote `student_lesson_progress`, which would let the two stores diverge. Remediation: 3c now materializes lazily, fails closed when the mapped revision has no entitlement row for the enrollment, and writes entitlement, mirror, dependents, then recalc in that order; new helper 3i grants newly eligible dependents; new check A9 and a new e2e check.
- **J-002 (accepted, remediated).** Evidence: the earlier Migration B step 4(2) materialized active enrollments only, and the earlier resume path did not union-sync completions. Remediation: Migration B step 4(2) and 4(3) cover active and preserved enrollments; `resume_band_enrollment` is a single transaction that syncs before activating; new check A10 and journey J7.
- **J-003 (accepted, remediated).** Evidence: `lesson_revisions` and the v1 `course_version_lessons` mappings are created only by the `202608280003` backfill (lines 223-232, 575-578), so a legacy lesson inserted later has no revision and sits outside the single source of truth. Remediation: new trigger 3j on `public.lessons`; fail-closed rule in 3c; Migration B step 4(0); audit additions (f) and (g); explicit Step 10 thresholds; new check A11; risk R5 updated.

## Ordered work

### Step 0 - Branch strategy

Owner: orchestrator with the user. Precondition for all engineering.

- In `H:\CommandCenter\orchestrator\lizbeth_spanish`, inspect `git status` and unmerged branches.
- Existing unmerged local work goes into a separate cleanup branch/PR (suggested `chore/local-work-cleanup`) branched from `main`, reviewed and merged independently, never mixed into #176.
- Then create a new branch per item from the updated `main` (`feat/issue-176-completion-foundations` for this item), with one PR per item. The #176 PR references epic #172.
- Commits, pushes, and PR creation happen only when the user explicitly authorizes them.
- If the cleanup PR adds migrations, renumber this plan's migration timestamps to sort after the newest migration on `main`.

### Step 1 - Read-only production audit

Owner: T1 writes the script. The user or orchestrator runs it only with explicit user go-ahead. No writes.

Add `scripts/audit/issue176-completion-audit.sql` (SELECT-only, wrapped in a READ ONLY transaction) reporting:

- (a) Count of active and preserved enrollments with null `course_version_id`, grouped by band.
- (b) Count of bands with more than one published `course_version`, and which is `is_current`.
- (c) Entitlement row counts per enrollment, and enrollments with `course_version_id` but zero entitlement rows.
- (d) Progress-vs-entitlements diff via `legacy_lesson_id`: slp completed but entitlement missing or incomplete; entitlement completed but slp missing/incomplete; legacy lessons with no mapped revision in the enrollment's version.
- (e) Enrollments whose `completed_at` would change under the unified recalculation (would-set and would-clear counts) and their `auto_completed_from_progress` flag.
- (f) Legacy lessons with no `lesson_revisions` row.
- (g) `student_lesson_progress` completed rows whose lesson has no mapped revision in the enrollment's version, counted per band.

Record results in the PR description (no PII beyond counts/ids).

### Step 2 - Tests first (T1, TDD)

Write failing tests for every acceptance check below before production edits.

### Step 3 - Migration A, forward-only

Example file: `supabase/migrations/202610030001_issue176_single_completion_record.sql`. Use `create or replace` only; no edits to applied files.

- **3a. Helper `resolve_band_course_version(p_band_id uuid) returns uuid`.** Stable, security definer, `search_path=public`, revoked from public/anon/authenticated, service_role only. Deterministic choice: the published version of the band's legacy course (`courses.legacy_band_id`) with `is_current = true`, else the lowest `version_no` published version whose lessons map via `legacy_lesson_id`; null if none.
- **3b. `sync_legacy_completion_to_entitlement(p_enrollment_id uuid, p_lesson_id uuid)`.** Internal (no grant to authenticated/anon). If the enrollment has `course_version_id` and no entitlement rows, call `materialize_enrollment_entitlements`. Find the revision in the enrollment's version with `legacy_lesson_id = p_lesson_id`; set entitlement `completed_at = coalesce(completed_at, now())` (monotonic). No mapped revision means no-op.
- **3c. Redefine `record_lesson_progress`.** Same signature and guards: `auth.uid`, `user_requires_password_change`, `is_account_active`, ownership and `status='active'`, band lock rule, revoke from public/anon, grant to authenticated. On `'complete'`, in order:
  1. Lazily materialize, as in 3b, when the enrollment has zero entitlement rows.
  2. Resolve the mapped revision in the enrollment's version. If the lesson has no mapped revision in that version, fail closed with errcode `42501` 'Lesson is locked' and write neither store (J-003: no completion can exist outside entitlements).
  3. If the mapped revision exists in the version but this enrollment has no entitlement row for it (its prerequisite is not met), raise `42501` 'Lesson is locked' before any write (J-001).
  4. If the entitlement is held or revoked, raise the same error (D1; parity with `record_lesson_completion`; prevents satisfying prerequisites via Roadmap).
  5. Only after these checks pass: write the entitlement `completed_at` (monotonic), then the `student_lesson_progress` mirror, then call 3i to grant dependents, then call the unified recalc (3e).

  `'open'` keeps writing only open/`last_opened` timestamps.
- **3d. Redefine `record_lesson_completion` and `set_lesson_completion`.** Same signatures, guards, grants. When the revision has a `legacy_lesson_id` belonging to the enrollment's band, they write through `student_lesson_progress.completed_at` as a compatibility mirror in the same transaction (set on complete; cleared only by the owner clear path). When either function completes a lesson it also calls 3i in the same transaction, so both surfaces behave the same. `student_lesson_progress.completed_at` becomes a derived mirror: no new code reads it.
- **3e. Single completion recalculation.** Redefine `recalculate_progress_completion(p_enrollment_id)` to delegate to `recalculate_course_version_completion` when `course_version_id` is not null. Keep the legacy band-count body only for enrollments with null `course_version_id` (should be none after Migration B). The `recalculate_band_progress` trigger and `reset_lesson_completion` then route through the same single routine. Exactly one routine decides auto completion for any enrollment.
- **3f. Redefine `reset_lesson_completion(p_enrollment_id, p_lesson_id)`.** service_role only, unchanged signature. Clear the mapped entitlement `completed_at` and the mirror row, record an activity event matching `set_lesson_completion`'s `lesson_completion_set` payload shape, then recalc. Clearing remains permitted on held rows.
- **3g. Student read RPC `get_enrollment_lesson_completion(p_enrollment_id uuid) returns jsonb`.** Language sql, stable, security definer, `search_path=public`. Same fail-closed guards as `get_student_learn_course`: `auth.uid` not null, own enrollment, status active, `is_account_active`, not `user_requires_password_change`. Revoke from public/anon; grant to authenticated and service_role. Returns per lesson `{lesson_revision_id, legacy_lesson_id, completed_at}` from entitlements of the enrollment's version. Never returns content, assets, answer keys, or thresholds.
- **3h. Trigger `student_enrollments_default_course_version`.** BEFORE INSERT OR UPDATE OF `band_id`, `status` on `student_enrollments`: when `course_version_id` is null and `band_id` is not null, set it from 3a. It does not materialize (materialization is explicit, see Step 5), so seed fixtures with zero entitlements remain possible.
- **3i. Internal helper `grant_newly_eligible_dependents(p_enrollment_id uuid, p_lesson_revision_id uuid)`.** SECURITY DEFINER, `search_path=public`; no grant to anon/authenticated. Inserts entitlement rows only for `course_version_lessons` in the enrollment's published version whose `prerequisite_lesson_revision_id` equals the just-completed revision. Computes `unlock_at` from `resolve_entitlement_anchor` plus `unlock_offset_days`. Uses `ON CONFLICT DO NOTHING`, so it never rewrites an existing `unlock_at` or `manual_release_state`. This is deliberate: the full materialize function's `ON CONFLICT` updates `unlock_at`. Called in the same transaction by `record_lesson_progress`, `record_lesson_completion`, and `set_lesson_completion` when it completes a lesson.
- **3j. Trigger on `public.lessons`.** AFTER INSERT trigger that creates the `lesson_revisions` row (`legacy_lesson_id`, `revision_no` 1) and the `course_version_lessons` row in that band's selected legacy version (D3 rule), using the `202608280003:575-578` precedent with `ON CONFLICT DO NOTHING`. It does not touch any other version.
- **Step 5 companions in Migration A:** `assign_band_enrollment(p_student_id, p_band_id, p_enrollment_date)` and `resume_band_enrollment(p_enrollment_id)` (see Step 5).

### Step 4 - Migration B, forward-only backfill

Example file: `supabase/migrations/202610030002_issue176_band_enrollment_backfill.sql`. Idempotent and re-runnable.

0. Runs first: map every legacy lesson that has no revision into the band's selected legacy version, using the `202608280003:575-578` precedent. Only when the selected version is the band's legacy-mapped version. If a band's selected version is a later authored version (D3 fallback), Migration B raises an exception for that band rather than guessing. Adding lessons to a published version can lower completion ratios; D4 still applies, so the backfill never clears an existing enrollment `completed_at`.
1. Set `course_version_id` via 3a for enrollments with null `course_version_id` and non-null `band_id` (active and preserved).
2. Materialize entitlements for active and preserved enrollments with `course_version_id` and zero entitlement rows.
3. Union-sync completions for both statuses: entitlement `completed_at = coalesce(entitlement.completed_at, slp.completed_at)` via `legacy_lesson_id`, and mirror entitlement completions into `student_lesson_progress` where the mirror is missing. Never clears any `completed_at`.
4. Recalc only in set-direction: for affected enrollments set `completed_at` and the auto flag when the unified rule says complete. Never clear an existing enrollment `completed_at` during backfill; would-clear cases are left as-is and are listed by the Step 1 audit for owner review.

Emit a `RAISE NOTICE` summary of row counts.

### Step 5 - Edge function admin-student-operations

File: `supabase/functions/admin-student-operations/index.ts`.

- Assign (484-501) and resume (456-481) call the new service_role-only SQL functions `assign_band_enrollment(p_student_id, p_band_id, p_enrollment_date)` and `resume_band_enrollment(p_enrollment_id)`, added in Migration A. `assign_band_enrollment` atomically inserts the enrollment with `course_version_id` and materializes entitlements. `resume_band_enrollment` runs in one transaction: lock the row, ensure `course_version_id`, materialize, union-sync completions from `student_lesson_progress` in both directions (set-only), recalculate, and only then set `status='active'`. If any step fails, the whole call rolls back and the enrollment stays preserved. Response shapes are unchanged (`{enrollment_id, status}`).
- `handleDashboard` (682-733) and `handleGetStudentDetail` (754-829): completion comes from entitlements joined to `lesson_revisions.legacy_lesson_id`. Response field names and `lesson_id` semantics are unchanged for backward compatibility. Last activity still uses `student_lesson_progress` open timestamps plus entitlement `completed_at`.
- `handleResetLessonCompletion` (744-752): the existence check uses the mapped entitlement, not the `student_lesson_progress` row.

### Step 6 - Edge function course-authoring list_progress

File: `course-authoring/index.ts`, `list_progress` (213-219).

- Return entitlement-derived completion per enrollment for the owner's versions, keeping existing fields (`id`, `enrollment_id`, `lesson_id`, `first_opened_at`, `last_opened_at`, `completed_at`, `updated_at`) and adding `lesson_revision_id`.
- Workspace-authored lessons (no legacy id) now appear with `lesson_id` null.
- Update the `issue5BackendContract.test.ts` expectations accordingly.

### Step 7 - Client shared completion layer

- New `src/services/completionData.ts` exporting `getEnrollmentCompletion(enrollmentId)` (rpc `get_enrollment_lesson_completion`), returning maps keyed by legacy lesson id and by `lesson_revision_id`.
- `getLessonProgress` and `getLessonProgressForEnrollment` in `adminStudentData.ts` delegate to it while keeping their signatures and Map semantics (empty Map is legitimate; errors reject).
- `useLessonCompletion` keeps its four-state machine, fire-once Stamp rule, and `'open'` write unchanged.
- This module is the documented completion API for #179/#180/#174/#175 shared components.

### Step 8 - seed.sql

Replace the ad-hoc sync block (527-537) with calls to the canonical sync path so local data mirrors production behavior. Preserve the `fullaccess` zero-entitlement fixture required by `wp11-learn.spec.ts`. If lazy materialization in 3b would mutate it during e2e, move that legacy-branch test onto a dedicated fixture enrollment never completed on Roadmap, and document the choice in the PR.

### Step 9 - Local validation

`npx supabase db reset`, full vitest, type-check, lint, `verify:build`, Playwright e2e, and the Browser Validator journeys below.

### Step 10 - Production (separate, user-gated)

After local validation and PR merge:

1. Rerun the Step 1 audit read-only. Before apply, (g) must be fully explained by (f), which Migration B maps. Any (g) row in a band whose selected version is not legacy-mapped blocks the apply until the user decides.
2. User explicitly approves.
3. Take a fresh backup/PITR marker and export snapshots of `student_enrollments(id, course_version_id, completed_at, auto_completed_from_progress)`, `enrollment_lesson_entitlements(enrollment_id, lesson_revision_id, completed_at)`, and `student_lesson_progress(enrollment_id, lesson_id, completed_at)`.
4. Apply migrations.
5. Rerun the audit. After apply require (f) = 0, (g) = 0, the mapped progress-vs-entitlement diff = 0, and the null `course_version_id` count for band enrollments = 0. Any nonzero result blocks frontend deployment and triggers the rollback review.
6. Deploy Edge functions, then the frontend.

## Interfaces and data

- New SQL: `resolve_band_course_version`, `sync_legacy_completion_to_entitlement`, `get_enrollment_lesson_completion`, `assign_band_enrollment`, `resume_band_enrollment`, `grant_newly_eligible_dependents`, trigger `student_enrollments_default_course_version`, and the AFTER INSERT trigger on `public.lessons` (3j).
- Redefined with unchanged signatures and grants: `record_lesson_progress`, `record_lesson_completion`, `set_lesson_completion`, `recalculate_progress_completion`, `reset_lesson_completion`.
- No table drops, no column drops, no applied-migration edits.
- Edge response shapes are unchanged except `list_progress`, which gains `lesson_revision_id` and may include rows with `lesson_id` null.
- Compatibility: old frontend builds that still read `student_lesson_progress` stay correct during rollout because of the write-through mirror (3d) and backfill step 4(3).
- Grants: every new SECURITY DEFINER function sets `search_path=public` and revokes from public/anon; only `get_enrollment_lesson_completion` is granted to authenticated.

## Acceptance checks

### SQL/RLS

Vitest + `pg` against local Supabase, BEGIN/ROLLBACK, RLS cases as authenticated role with student JWT.

- **A1** Roadmap complete sets entitlement `completed_at` for the mapped revision; `get_student_learn_course` shows completed; `completed_count` matches.
- **A2** `/learn` complete sets the `student_lesson_progress` mirror; `get_enrollment_lesson_completion` shows it under the legacy lesson id.
- **A3** No flapping: interleaved completions on both surfaces, opens, reset, and the lessons trigger never set then clear (or clear then set) enrollment `completed_at`; only one routine writes it; manual/legacy completion dates are never altered.
- **A4** Roadmap complete on a held or revoked mapped entitlement raises 42501 and writes nothing.
- **A5** Monotonic: student paths never clear; owner reset/`set_lesson_completion` clear both stores and recalc.
- **A6** Guard parity: each new/redefined function denies another student's enrollment, inactive account, password-change-required, non-active enrollment, and anon; `get_enrollment_lesson_completion` returns null (fail-closed) for non-owned ids; `information_schema`/`pg_proc` checks confirm grants and `search_path`.
- **A7** Backfill idempotent: running Migration B logic twice yields identical state; never clears `completed_at`; deterministic version choice when a band has multiple published versions.
- **A8** Trigger fills `course_version_id` on band insert and on preserved->active.
- **A9** Roadmap completion of a lesson whose prerequisite is not met raises 42501 and writes neither store. Completing the prerequisite on either surface creates the dependent's entitlement atomically, and existing held/released rows and their `unlock_at` are untouched. Test on a fixture version that has a prerequisite chain mapped to legacy lessons.
- **A10** (SQL plus Edge) Resuming a preserved enrollment that has prior Roadmap completions shows those lessons completed on both surfaces. Running resume or Migration B twice produces identical state.
- **A11** Inserting a new legacy lesson creates its mapped revision. Completing an unmapped lesson fails closed. A Migration B dry run on a fixture with an unmapped completed lesson maps it and syncs the completion.

### Edge function tests

- Assign and resume create/activate enrollments with `course_version_id` and entitlements (response shape unchanged).
- Dashboard, student-detail, and `list_progress` counts derive from entitlements and match `get_student_learn_course` for the same enrollment.
- Reset clears both stores.

### Unit tests

- `completionData.ts`.
- `adminStudentData` delegations (empty Map vs error).
- `useLessonCompletion` unchanged behavior (fire-once Stamp).
- Existing `WeekDetailPage`, `LearnDetailPage`, `BandRoadmap`, and `OwnerDashboard` suites stay green.

### E2E (Playwright, local)

- A student completes a lesson on Roadmap and sees it completed on `/learn`; completes another on `/learn` and sees it on Roadmap.
- Owner dashboard, student detail, and workspace Progress/Roster show identical counts.
- An owner band-assigns a new student who then sees the course on `/learn` (not "No enrolled courses yet").
- A student completes a prerequisite on the Roadmap, and the dependent lesson becomes available on `/learn`.

### Gates

`npm run type-check`, `npm run lint`, `npm test` (vitest run), `npm run verify:build`, `npm run test:e2e`; deterministic no-native-dialog scan; Verifier pass; Browser Validator pass.

## Browser UI dialog policy and browser validation inputs

### Dialog policy

Applies to every touched browser UI: `WeekDetailPage`/`LessonContentView` via `useLessonCompletion`, `BandRoadmap`, `LearnDetailPage`, `OwnerDashboardPage`, admin student detail, `CourseWorkspacePage`.

- No `alert`, `confirm`, `prompt`, `window.alert`/`window.confirm`/`window.prompt`, or `beforeunload` prompts.
- Acknowledgement or confirmation uses the app-owned accessible Modal; errors use inline validation/status messaging.
- Keyboard and focus behavior of any existing modal on touched paths is verified (focus trap, Escape, focus return).
- Deterministic scan: grep `src` for `\b(window\.)?(alert|confirm|prompt)\s*\(` and `beforeunload`; both must return zero product-code matches.

### Browser validation inputs

- **Launch/readiness:** from `lizbeth_spanish`, `npx supabase start` (ready when `npx supabase status` reports API http://localhost:54321 and DB 54322), then `npm run dev` (ready when Vite prints the local URL). For Playwright parity runs: `npm run build && netlify serve --context production --port 8888`, or set `E2E_BASE_URL`.
- **Base URL:** http://localhost:5173 (dev; confirm the printed port) or http://localhost:8888 (Playwright default).
- **Fixture/reset:** `npx supabase db reset` before each validation run (migrations + `seed.sql` + `seeds/full-catalog.sql`). Accounts from `seed.sql`: student1@test.local, student2@test.local, owner@test.local.
- **Journeys:**
  - J1: student1 opens a Beginner unlocked, incomplete week on Roadmap, marks complete, navigates to `/learn/<enrollmentId>` and sees that lesson Completed with a matching N of M count.
  - J2: student1 marks a different unlocked lesson complete on `/learn`, returns to the Roadmap/week and sees it completed (Stamp does not replay on remount).
  - J3: owner opens the dashboard, student detail for student1, and Course Workspace Progress and Roster for Beginner; all show the same completed lessons and counts.
  - J4: owner band-assigns a student with no prior enrollment; that student signs in and sees the course on `/learn` (not "No enrolled courses yet").
  - J5: owner resets a completion; both student surfaces show it incomplete.
  - J6: student completes a prerequisite lesson on the Roadmap; the dependent lesson becomes available on `/learn`.
  - J7: owner resumes a preserved enrollment; the student sees prior completions on both surfaces.
- **Viewports:** 390x844 and 1440x900.
- **Visible outcomes:** identical completion states/counts across Roadmap, `/learn`, and owner views; no native dialog appears; no console errors; layouts unchanged from the current baseline.

## Risks and rollback

### Risks

- **R1** Data loss or wrong completion during backfill. Mitigation: union-only, set-only, idempotent backfill; pre-apply audit; snapshots.
- **R2** Privilege escalation via new SECURITY DEFINER functions. Mitigation: guard parity tests A6, explicit revokes, service_role-only internals.
- **R3** Prerequisite bypass via Roadmap on held lessons. Mitigation: A4 refusal.
- **R4** Non-deterministic version selection. Mitigation: 3a rule and audit (b).
- **R5** Unmapped lessons or revisions. Remediated and gated: trigger 3j maps new legacy lessons, Migration B step 4(0) maps existing ones (raising for a band whose selected version is a later authored version), `record_lesson_progress` fails closed on an unmapped lesson, and audit items (d), (f), (g) plus the Step 10 thresholds gate the apply. Remaining limit: Roadmap/`/learn` parity applies to legacy-mapped lessons.
- **R6** Seed fixture drift breaks wp11 tests. Mitigation: Step 8.
- **R7** Deploy-order window. Mitigation: the mirror keeps old readers correct; deploy DB, then Edge, then frontend.
- **R8** Performance of dashboard entitlement joins. Mitigation: single batched queries, no N+1; existing `idx_entitlements_user`.

### Rollback

Forward-only.

- Code rollback: revert the PR and redeploy previous Edge functions and frontend. Old readers still work because the mirror is maintained.
- DB rollback: a new forward migration restoring the previous function bodies of `record_lesson_progress`, `recalculate_progress_completion`, `reset_lesson_completion`, `record_lesson_completion`, and `set_lesson_completion` (copied verbatim from `202608270001` and `202608300002`), and dropping the new functions (`resolve_band_course_version`, `sync_legacy_completion_to_entitlement`, `get_enrollment_lesson_completion`, `assign_band_enrollment`, `resume_band_enrollment`, `grant_newly_eligible_dependents`) and both triggers (`student_enrollments_default_course_version` and the `public.lessons` trigger). Backfilled `course_version_id` and entitlement rows are additive and are left in place (they only make `/learn` visible).
- Data defect: restore affected rows from the Step 10 snapshots via a reviewed corrective migration; PITR is the last resort.
- Prepare the rollback migration file in the PR (not applied).

## Dependencies

- Step 0 branch strategy precedes all engineering; a cleanup PR that adds migrations forces renumbering of Migrations A and B.
- Migration A precedes Migration B, Edge changes (Steps 5, 6), and client changes (Step 7).
- Step 1 audit runs before and after production application (Step 10).
- Local Supabase CLI stack, Node tooling, and Playwright per `README.md`.
- Epic #172; downstream features #179, #180, #174, #175 consume `completionData.ts`.

## Assumptions

- The Supabase CLI local stack serves Edge functions on `npx supabase start`.
- Band-assign enrollments are rolling (no cohort), so entitlement `unlock_at` equals the legacy band unlock rule.
- Legacy courses' v1 revisions carry `legacy_lesson_id`.

## Resolved decisions

D1-D5 are resolved with the recommended defaults. They take effect when the user approves this plan.

- **D1** Roadmap completion is refused for held/revoked entitlements, entitlements whose prerequisite is not met, and unmapped lessons. Rationale: parity with `/learn` and no completion outside entitlements.
- **D2** `student_lesson_progress.completed_at` is a write-through compatibility mirror; nothing new reads it. Rationale: old frontend builds stay correct during rollout.
- **D3** Version selection uses the legacy course's `is_current` published version, falling back to the lowest legacy-mapped published version, with the J-003 exception raised for an unmapped fallback. Rationale: deterministic choice, no guessing.
- **D4** The backfill only sets completion and never clears; enrollments where the new rule would clear are listed for owner review. Rationale: avoids destroying existing completion data.
- **D5** Existing unmerged local work goes into its own cleanup PR first, branched from `main`. Then a new branch per item from the updated `main` (`feat/issue-176-completion-foundations` for this item), one PR per item, as the user's brief specifies. Commits, pushes, and PRs still require explicit user authorization.

## Remaining approvals

- Explicit user approval of this plan.
- A separate explicit user approval for production application (Step 10).

## Engineering mode

Standard: T1 first-line; T2 on two counted gate failures. An extreme advisory team is not recommended because the work is sequential and single-writer. team_authorization: not applicable.

## Downstream owner

`engineering-fleet`, after explicit user approval of this plan. The `ENGINEERING_JOB` passes this file's path as `approved_plan`. The writer must return `JOB_BLOCKED` with `Plan stale` if a material repository, requirement, dependency, or evidence change invalidates the plan.

## Approval record

Approved by the user on 2026-10-03, together with the plans for the other three lizbeth-spanish issues among #173, #176, #177, and #178, in the orchestrator session.

- Covered: commits, pushes, and pull requests for this item. User instruction: create new branches and PRs as needed; existing unmerged local work in lizbeth_spanish lands as its own cleanup PR first.
- Not covered: production writes (storage re-tag, migrations, Edge Function deploys, Netlify deploys). Each needs a separate explicit user go-ahead after local validation.
