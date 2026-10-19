# Plan: harden student read policies on lesson delivery tables (lesson_revisions_student_read and siblings)

Status: APPROVED 2026-10-18. User verbatim: "1. approve security fix plan, as recommended to all. 2. approved. build 208 b. i don't have storage version number now but can't you do the read only lookup? do not write anything to prod but you can do read only look ups." D1 to D4 are adopted at their recommendations. Hosted preview and hosted apply remain unscheduled and each needs separate explicit approval ("We're not ready for prod rollout yet"). Production writes are prohibited; read-only production lookups are permitted.
Plan ID: lizbeth-spanish-lesson-revisions-student-read-hardening
Task ID: lizbeth-lesson-revisions-student-read-hardening
Date: 2026-10-18
Route: engineering (standard mode), downstream owner: engineering-fleet
Target repository: `lebobo88/lizbeth-spanish` (private)

The user approved this plan on 2026-10-18 and the approval was relayed to Scribe, which marked the status approved. T1 dispatch is permitted for the local scope only.

## Plan review disposition

- **PLAN_DUCK** (`gpt-6-astra`, medium effort, shadow mode): verdict REVISE.
- **J-01-JWT-PREVIEW** (major, high confidence): ACCEPTED. The evidence checks out: `user_requires_password_change()` at `202608070001:24-33` reads `auth.jwt()->'app_metadata'->>'force_password_change'` with a `::boolean` cast, not stored metadata. Applied in sections 10, 11, and 15.
- **J-02-PRECONDITION-COVERAGE** (minor, high confidence): ACCEPTED. Applied in section 4 (finding 7), section 9, section 10 (Q0), and section 15 (T-B, T-C).
- The user approved this fix direction on 2026-10-18. Every hosted step stays unscheduled: "We're not ready for prod rollout yet".
- The user approved the plan on 2026-10-18 (see the Status line).

## 1. Outcome

One pull request (base `main`) that:

- adds an additive, non-destructive row-level-security (RLS) hardening migration so a student's SELECT on `lesson_revisions`, and on the sibling entitlement-gated delivery tables (see D1), enforces the account-active and must-change-password gates by itself;
- ships a prepared, data-preserving rollback file;
- ships a prepared, read-only production impact preview script;
- ships tests that fail on the current policy and pass after the migration;
- is linked to a newly filed GitHub issue that the PR closes (`Closes #N`).

Audience: the owner/operator (Rob), who approves the PR and, later and separately, any hosted action; and the engineering fleet that implements it.

## 2. Scope and non-goals

### 2.1 User intent (verbatim, 2026-10-18)

> "Approve the first two items still open from last time"

The first item, quoted from the user-facing summary: file and fix the security gap:

> "One older database access rule (`lesson_revisions_student_read`) lets students read lesson rows directly. It skips the 'account active' and 'must change password' checks."

### 2.2 In scope

- Root cause write-up.
- New migration and rollback file.
- Read-only preview SQL script.
- SQL tests and live tests (local mirror only).
- Static script and migration tests.
- Deploy-skew analysis.
- GitHub issue filing.
- PR with `Closes #N`.

### 2.3 Non-goals and hard constraints

- **No hosted action of any kind.** The user said, verbatim: "We're not ready for prod rollout yet". Production Supabase is LIVE with real student data. Hosted apply and hosted preview each need separate explicit approval later; this plan schedules neither. It only prepares the PR and scripts.
- PRs only, base `main`. No direct push to `main`, no deploy, no Netlify or Supabase hosted commands.
- No change to the entitlement semantics of the existing permissive policy predicates (see D2).
- No frontend change.
- No DML in the migration.
- Follow-up divergences F1 to F4 are documented and filed, not fixed.
- The dev-server rule (section 13) applies to every job.
- Local mirror stack: `H:\CommandCenter\orchestrator\lizbeth_spanish-218e-run` (API 64321, DB 64322). Port patches must never be committed.
- Codex judges use `gpt-6-astra` at medium effort.

## 3. Root cause

Migration `202608280003_issue5_course_authoring.sql` (issue #5 course authoring, 2026-08-28) authored the new delivery-table student policies about three weeks after migration `202608070001` had made both gates mandatory on every student read. It did not carry them forward: it copied `is_account_active` onto `course_versions` only. No test asserted gate parity for newly student-readable tables, so the omission was never caught.

## 4. Repository findings

Observed in the reference checkout `H:\CommandCenter\orchestrator\lizbeth_main_verify_20261013` (read-only evidence, detached, OLDER than main) unless marked as inference. Step 0 must re-confirm every finding on current `origin/main` (8e2facab or later; #297 and #298 are being merged). Note: that checkout's `node_modules` is a junction; never recurse-delete through it.

1. **The offending policy.** `supabase/migrations/202608280003_issue5_course_authoring.sql:521`:

   ```sql
   create policy lesson_revisions_student_read on public.lesson_revisions for select to authenticated using (exists(select 1 from enrollment_lesson_entitlements el where el.lesson_revision_id=id and el.unlock_at <= now() and el.manual_release_state not in ('held','revoked') and exists(select 1 from student_enrollments e where e.id=el.enrollment_id and e.user_id=auth.uid() and e.status='active')));
   ```

   It has no `is_account_active()` and no `user_requires_password_change()`. The unqualified `id` resolves to `lesson_revisions.id` because `enrollment_lesson_entitlements` has no `id` column (its primary key is `(enrollment_id, lesson_revision_id)`, file lines 185-196), so the predicate is correct but fragile. `lesson_revisions.content` (jsonb lesson content) is exposed by this policy. It is the only policy on `lesson_revisions`, and `authenticated` has SELECT on it (line 536).

2. **Sibling policies in the same block (lines 520-527), same origin.** No later migration redefines any of them (grep across `supabase/migrations`).
   - `course_versions_student_read` (520): has `is_account_active`, MISSING the password gate.
   - `course_version_lessons_student_read` (522): missing both.
   - `entitlements_own` on `enrollment_lesson_entitlements` (527): missing both.
   - `course_assets_student_read` (523): missing both, but `authenticated` has NO SELECT grant on `course_assets` (revoked at line 531, absent from the grant at line 536, no later grant found), so it is inert today.
   - `cohort_members_own` (524), `requests_own` (525), `quiz_attempts_own` (526): own-row `user_id=auth.uid()` only; not lesson content.

3. **Gate definitions.**
   - `is_account_active(uid)` in `202607200001_admin_student_management_schema.sql:40` (SECURITY DEFINER, STABLE; true unless `auth.users.banned_until > now()`).
   - `user_requires_password_change()` in `202608070001_force_password_change_rls_enforcement.sql:24` (reads `auth.jwt()->'app_metadata'->>'force_password_change'`; the claim authority and the table `password_change_requirements` were added by `202610130003`, function unchanged).

4. **Canonical predicate.** `student_can_read_legacy_lesson` (`202610130002_issue198_legacy_entitlement_rule.sql:39`) requires: `auth.uid()` not null; not `user_requires_password_change()`; `is_account_active(auth.uid())`; active enrollment; entitlement in the enrollment's CURRENT version (join `course_version_lessons` on `se.course_version_id`); not held or revoked; and (released OR `unlock_at <= now()`). Every newer student path includes both gates:
   - `get_student_learn_course` and `get_student_learn_index` (`202608310002:154-159`);
   - `get_student_roadmap_week_states` (`202610150002:84-89`);
   - `students_read_own_lesson_task_submissions` (`202610040003:113-123`);
   - `students_read_own_lesson_progress` (`202608270001:29-36`);
   - the `202608070001` policies on lessons, resources, `storage.objects`, `student_enrollments`, and feedback.

   `get_student_lesson_content` (`202610170001`, #293a) is NOT in the reference checkout. Step 0 must read it on `origin/main` and record its gates.

5. **Root cause** is recorded in section 3.

6. **Inference, to be verified by the Step 1 probe: exposure is probably already closed transitively.** The policy's nested subquery on `student_enrollments` is evaluated under the caller's RLS. `students_read_own_enrollments` (`202608070001:117-128`; authenticated SELECT granted in `202607170004:12`) requires `not user_requires_password_change()` AND `is_account_active(auth.uid())`. A banned or forced-password student therefore sees no own enrollment row, and the `exists()` fails. `entitlements_own` and `course_version_lessons_student_read` are gated the same way (through `student_enrollments` and entitlements RLS); `course_versions` gets the password gate the same way. Consequence (inference): the gap is a latent defense-in-depth gap at the policy-text level, one policy change away from a live leak (for example, any future relaxation of `students_read_own_enrollments` for preserved-history display). The issue text and PR must state severity according to the Step 1 probe result: "latent (transitively closed)" or "live (reproduced)".

7. **Frontend direct reads (non-test `src`).** Exactly one: `src/services/learnMaterials.ts:106`, `client.from('lesson_revisions').select('id, legacy_lesson_id').in('id', eligibleIds)` (legacy-course materials bridge on `/learn` detail). All other student reads go through SECURITY DEFINER RPCs (`get_student_learn_course`, `get_student_learn_index`, `get_student_lesson_assets`, `get_student_roadmap_week_states`, lesson task and quiz RPCs, `record_lesson_completion`) that do not depend on these table policies. Edge course-authoring student actions (`index.ts:65-117`) call RPCs through the caller JWT; owner actions use the service-role client (`index.ts:120`). The `course_preview_lessons` and `course_catalog` views run as owner (no `security_invoker`) and are unaffected. No `FORCE ROW LEVEL SECURITY` and no restrictive policy exists anywhere in `supabase/`. LearnDetailPage, handouts, and roadmap must be re-grepped on `origin/main` because #293a, #297, and #298 may add direct reads. The claim that these reads are unaffected depends on specific execution properties, which Q0 asserts and the compatibility proof (section 9.3) names: `is_account_active(uuid)` is SECURITY DEFINER with `search_path=public`; `user_requires_password_change()` is SECURITY INVOKER and reads the session JWT; each cited student RPC is SECURITY DEFINER with its expected owner; the two views run as their owner with no `security_invoker`; and RLS is enabled but not forced on the target tables.

8. **Patterns to follow.**
   - Migration: `202610130002` (`begin; set local lock_timeout='5s'; set local statement_timeout='60s'; ... commit;`, header with DATA SAFETY and rollback path).
   - Rollback: `supabase/rollbacks/<name>_rollback.sql` ("prepared, NOT applied").
   - Preview: `scripts/audit/issue198-impact-preview.sql` (whole script in `begin transaction read only; ... rollback;`, GO/NO-GO block at top, Q-numbered queries, private user-id output).
   - SQL tests: `src/__tests__/issue198LegacyEntitlementRuleSql.test.ts` with `helpers/issue198Fixtures.ts` (`newDb` loopback guard, `asRole` sets `request.jwt.claims` with `app_metadata`, BEGIN/ROLLBACK per test, ports from `SUPABASE_DB_PORT` and `SUPABASE_API_URL` env so no file edits are needed for the 64321/64322 mirror).
   - Live supabase-js: `src/__tests__/issue174LearnMaterialsLive.test.ts`.
   - Static script test: `src/__tests__/handoutHostedCheckScript.test.ts`.
   - `package.json` scripts: `test=vitest`, `lint=eslint src --ext ts,tsx`, `build=tsc && vite build`, `dev=vite`.

Research evidence: none (research not needed). Behavior is fully determined by local migrations and standard PostgreSQL RLS semantics: permissive policies OR together, restrictive policies AND, policy subqueries run under caller RLS, and SECURITY DEFINER owner functions bypass RLS absent FORCE RLS.

## 5. Policy inventory

"Gate" columns describe the policy text as found. Disposition reflects the recommended option for D1 (Option B).

| Policy | Table | Account gate | Password gate | Authenticated SELECT grant | Disposition |
|---|---|---|---|---|---|
| `lesson_revisions_student_read` | `lesson_revisions` | missing | missing | yes (line 536) | Add restrictive companion gate (D1 Option A and B) |
| `course_version_lessons_student_read` | `course_version_lessons` | missing | missing | yes | Add restrictive companion gate (D1 Option B) |
| `entitlements_own` | `enrollment_lesson_entitlements` | missing | missing | yes | Add restrictive companion gate (D1 Option B) |
| `course_versions_student_read` | `course_versions` | present | missing | yes | Add restrictive companion gate with both checks, for uniformity (D1 Option B) |
| `course_assets_student_read` | `course_assets` | missing | missing | none (revoked, line 531) | Excluded; inert today; follow-up F3 |
| `cohort_members_own` | `cohort_members` | missing | missing | yes (inference: own-row only) | Excluded; own data; follow-up F4 |
| `requests_own` | requests table | missing | missing | yes (inference) | Excluded; own data; follow-up F4 |
| `quiz_attempts_own` | quiz attempts table | missing | missing | yes (inference) | Excluded; own data; follow-up F4 |

Step 0 re-confirms this table on `origin/main`, including grants and the absence of any other permissive authenticated SELECT policy on the four target tables.

## 6. Design route

`design_route: none`. `design_handoff: none`. `design_review: none`.

Justification: this is a backend-only RLS change with no screen, copy, layout, state, or interaction change. Active students see identical rows (shown by the restrictive-AND-true argument and by tests). Students who lose access are already blocked by the existing SECURITY DEFINER RPCs and the forced-password route flow, so no new user-visible state is introduced.

`browser_ui_dialog_policy`: not applicable (no browser UI change). If the optional Step 7 regression runs, no code change touches UI, so the native-dialog scan is not required. `browser_ui_validation`: not applicable (Browser Validator not dispatched).

## 7. Decisions

Each decision has a recommendation. On 2026-10-18 the user approved the plan and adopted D1 to D4 at their recommendations ("approve security fix plan, as recommended to all").

### D1. Scope

- Option A: `lesson_revisions` only.
- **Option B (RECOMMENDED):** `lesson_revisions`, `course_version_lessons`, `enrollment_lesson_entitlements` (`entitlements_own`), and `course_versions` (password gate). Reason: same root cause, same entitlement-gated delivery family, same migration, preview, and tests, no frontend reads beyond the one bridge, negligible extra risk.
- Excluded under either option: `course_assets_student_read` (inert, no grant; follow-up F3) and the own-row policies `cohort_members_own`, `requests_own`, `quiz_attempts_own` (own data only, lower severity; follow-up F4).

### D2. Mechanism

- **Option A (RECOMMENDED):** restrictive companion policies. Truly additive, permissive predicates stay byte-identical, one-line exact rollback, and entitlement semantics cannot change, so only inactive and forced-password students can lose access.
- Option B: `ALTER POLICY` or drop-and-create in place with the gates ANDed in (the 198 precedent). The rollback would have to restore the exact original text, with higher risk of accidental predicate drift.

### D3. Follow-ups

Recommended: file one follow-up issue and do not fix here. See section 17 (F1 to F4). Fixing F1 or F2 changes access for active students and therefore violates this plan's GO rule; each needs its own plan and preview. Preview Q4 sizes F1 and F2.

### D4. Severity wording

Depends on the Step 1 probe (latent versus live). Safe assumption (inference): latent.

## 8. Ordered work

Single writer (T1, standard mode). Verifier after. No Browser Validator, because there is no UI change (see the Step 7 regression option).

| Step | Owner | Work |
|---|---|---|
| 0 | T1 | Ground on current main (below). |
| 1 | T1 | Reproduce on the local mirror (below). |
| 2 | T1 | File the GitHub issue (section 16). |
| 3 | T1 | Tests first, run red, keep output (section 15). |
| 4 | T1 | Migration (section 9). |
| 5 | T1 | Rollback (section 9). |
| 6 | T1 | Read-only preview script (section 10). |
| 7 | T1 | Local validation (below). |
| 8 | T1 | PR (section 16). |
| 9 | Codex judge, Verifier, Codex judge | CODE_REVIEW, then independent Verifier, then VERIFICATION_CHALLENGE; report. No merge, no hosted apply. |

### Step 0 (T1): ground on current main

- `git fetch origin`; create a fresh worktree from `origin/main` (8e2facab or later) under `H:\CommandCenter\orchestrator\` (for example `lizbeth_issue-lr-gates`), branch `fix/issueN-delivery-read-account-gates` once N is known. Record the SHA.
- Re-confirm findings 1 to 8 on `origin/main`: policy texts at `202608280003:520-527` unchanged and not redefined later; `students_read_own_enrollments` unchanged; `is_account_active` and `user_requires_password_change` definitions unchanged.
- Read `get_student_lesson_content` (`202610170001`) and any #297 or #298 migrations; record their gates.
- Re-grep non-test `src` for `.from('lesson_revisions'|'course_version_lessons'|'enrollment_lesson_entitlements'|'course_versions'|'course_assets')` and embedded `lesson_revisions(`.
- Confirm `course_assets` still has no authenticated SELECT grant; confirm no other permissive authenticated SELECT policy exists on the target tables.
- Pick the next free migration timestamp.
- If any material difference appears, return `JOB_BLOCKED` "Plan stale".
- Never recurse-delete through any `node_modules` junction. Remove a junction only with `cmd /c rmdir <junction>`, or leave it.

### Step 1 (T1): reproduce on the local mirror

- Mirror: API 64321, DB 64322, env `SUPABASE_DB_PORT=64322 SUPABASE_API_URL=http://127.0.0.1:64321`. Any port patch in the mirror stays uncommitted.
- As `authenticated` with (a) `app_metadata.force_password_change=true` and (b) `banned_until=now()+1 day`, and an otherwise valid active entitlement: select from `lesson_revisions`, `course_version_lessons`, `enrollment_lesson_entitlements`, `course_versions`. Record effective rows (expected 0 per finding 6).
- Then, inside a rolled-back transaction, replace `students_read_own_enrollments` with plain `user_id = auth.uid() and status='active'` and repeat. Expected: rows visible, which is the latent leak.
- Record both results. They set the issue severity (D4).

### Step 7 (T1): local validation on the mirror

- Full vitest suites for `issue198*`, `issue174*`, `issue5-phase5*`, and the new suite; lint; build (`tsc`).
- Optional regression (recommended): run the existing learn and handout Playwright specs (for example `wp11-learn.spec.ts`, `issue174-handout-links.spec.ts`, `issue198-5c2-roadmap-week-states.spec.ts`) once against the mirror with exactly one dev server, started intentionally, port recorded, stopped after the run. Perform an orphan check (no listening vite or node process on the dev port, and no stray node processes from the run) before and after. Record the evidence.

## 9. Migration and rollback specification

### 9.1 Migration

File: `supabase/migrations/<next_ts>_issueN_delivery_read_account_gates.sql`, following the `202610130002` pattern.

- `begin;`
- `set local lock_timeout='5s';` and `set local statement_timeout='60s';`
- For each D1 table, create a restrictive companion policy, for example:

  ```sql
  create policy lesson_revisions_student_account_gate on public.lesson_revisions as restrictive for select to authenticated using ((select public.is_account_active((select auth.uid()))) and not (select public.user_requires_password_change()));
  ```

  The same form applies to `course_version_lessons`, `enrollment_lesson_entitlements`, and `course_versions` (the last gets both checks for uniformity).
- Each new restrictive policy must be declared `AS RESTRICTIVE`, `FOR SELECT`, `TO authenticated` only. `pg_policies.roles` must equal `{authenticated}` and never include `public`, `anon`, or `service_role`.
- Add a `comment on policy` for each, naming issue N and stating that any future permissive authenticated SELECT policy on the table (for example an owner read) is also gated.
- Header content: root cause, DATA SAFETY (no table, column, or row change; only new policies), rollback path, and the sentence "MUST NOT be applied to production without separate explicit approval and a GO preview".
- `commit;`
- Post-apply verification query (LOCAL only for now; a hosted run is a separate approval): a `select` on `pg_policies` for the four tables asserting that each new policy has `permissive = 'RESTRICTIVE'`, `cmd = 'SELECT'`, `roles = '{authenticated}'`, and that the four original permissive policies are unchanged. This query is part of the test suite (T-B, T-C) and is not run against production by this plan.
- Idempotency is guarded by name only (`create policy` fails if the policy exists). The writer may precede each create with `drop policy if exists <new restrictive name>`, since that drops only a policy this migration introduces.
- Constraints: no `DROP` or `ALTER` of existing policies, no insert, update, delete, or truncate.

### 9.2 Rollback

File: `supabase/rollbacks/issueN_delivery_read_account_gates_rollback.sql`. Prepared, NOT applied. It contains `drop policy if exists` for each new restrictive policy only, touches no row, and leaves the original permissive policies untouched. Because those are byte-identical to before, rollback restores exact pre-migration behavior.

### 9.3 Interfaces and compatibility

New objects: up to four restrictive RLS policies (no table, column, function, or data change), one rollback SQL, one read-only audit SQL, and tests. No API or frontend contract change. SECURITY DEFINER RPCs and views are unaffected, and that proof depends on these execution properties (asserted by Q0): the RPCs are SECURITY DEFINER with their expected owners and, without FORCE ROW LEVEL SECURITY, bypass the table policies; the views `course_catalog` and `course_preview_lessons` are owner-run with no `security_invoker`; `is_account_active(uuid)` is SECURITY DEFINER, STABLE, `search_path=public`; `user_requires_password_change()` is SECURITY INVOKER, STABLE, and reads the session JWT claim; `relrowsecurity = true` and `relforcerowsecurity = false` on the target tables. `service_role` is unaffected because the policies are `to authenticated`.

## 10. Read-only production preview and GO/NO-GO rule

File: `scripts/audit/issueN-delivery-read-gate-preview.sql`, following `issue198-impact-preview.sql`. The whole script runs in `begin transaction read only; ... rollback;`, depends on nothing the migration creates, and prints user ids only in a clearly marked private detail query.

### 10.1 What RLS actually evaluates (JWT claim versus stored metadata)

`public.user_requires_password_change()` (`202608070001:24-33`) reads `auth.jwt()->'app_metadata'->>'force_password_change'` and casts it with `::boolean`. It does not read stored `auth.users.raw_app_meta_data`. RLS therefore evaluates the session JWT claim, which can differ from stored metadata: a JWT issued before an owner flags the student, or before the flag is cleared, carries the old value until the session refreshes. Consequences for the preview:

- Every count derived from `raw_app_meta_data` is an ESTIMATE. Q2, Q3, and Q4 output and this plan label such counts "ESTIMATE (stored metadata)".
- The preview evaluates each student under BOTH JWT flag scenarios, independently of stored metadata: `S_false` (claim absent or false) and `S_true` (claim true). It uses a set-based CTE that substitutes a scenario column for the claim.
- The preview never calls the no-argument `public.user_requires_password_change()` and never calls `auth.jwt()`, because under the preview caller's identity those would evaluate the operator's own session or an empty claim. It uses only the scenario column and stored metadata.

### 10.2 Queries

- **Q0 preconditions and fingerprints.** Any mismatch below is NO-GO.
  1. *Policy roles and commands:* each of the four existing permissive policies (`lesson_revisions_student_read`, `course_version_lessons_student_read`, `entitlements_own`, `course_versions_student_read`) is PERMISSIVE, cmd SELECT, roles `{authenticated}`, and its qual text equals the expected text. `students_read_own_enrollments` has its expected roles, cmd, and qual.
  2. *RLS state:* `relrowsecurity = true` and `relforcerowsecurity = false` on `lesson_revisions`, `course_version_lessons`, `enrollment_lesson_entitlements`, `course_versions`, and `student_enrollments`.
  3. *Functions:* `is_account_active(uuid)` is SECURITY DEFINER, STABLE, owned by `postgres` (or the recorded expected owner), with `search_path=public` in `proconfig`, and its `prosrc` matches expected. `user_requires_password_change()` is SECURITY INVOKER, STABLE, with `prosrc` matching expected. Every student RPC cited in the deploy-skew analysis (`get_student_learn_course`, `get_student_learn_index`, `get_student_lesson_assets`, `get_student_roadmap_week_states`, plus `get_student_lesson_content` once Step 0 confirms it) is SECURITY DEFINER with its expected owner.
  4. *Views:* `course_catalog` and `course_preview_lessons` are owned by the expected owner (`postgres`) and their `reloptions` contain no `security_invoker=true`, so they keep running as their owner.
  5. *Grants:* the `authenticated` SELECT grants match the expected set (`lesson_revisions`, `course_version_lessons`, `enrollment_lesson_entitlements`, `course_versions` granted; `course_assets` NOT granted), cross-checked against `202608280003:531-537`.
  6. *Policy inventory:* no restrictive policy exists yet on the four tables, and no other permissive authenticated SELECT policy exists on them.
  7. *Static text assertion:* the preview script text itself contains no `user_requires_password_change(` call and no `auth.jwt(` (also asserted by T-G).
- **Q1 per table.** (user_id, row) pairs admitted by the OLD predicate, evaluated set-based with `se.user_id` in place of `auth.uid()`. Two OLD variants are computed for each scenario: the policy-text level (ignoring nested RLS) and the EFFECTIVE path (current permissive policy plus the `student_enrollments` nested gates, with the scenario column standing in for the claim). The PROPOSED predicate is OLD plus the restrictive gate (an `is_account_active` equivalent via `banned_until`, and not the scenario flag).
- **Q2 loss by scenario and cause.** For each of `S_false` and `S_true`, and for each table, report pairs and distinct students that lose access (effective OLD admitted, PROPOSED denied), split by cause: `inactive` (`auth.users.banned_until > now()`), `jwt_flag_true` (the scenario), `both`, and `unexplained` (must be 0). Counts that depend on stored `raw_app_meta_data` are labelled ESTIMATE.
- **Q3 incremental loss.** Under `S_false`, the number of pairs an active student (not banned) loses must be 0. Under `S_true`, the PROPOSED predicate may remove only pairs that the OLD effective path already denied, or pairs attributable to the flag; any other removed pair is unintended incremental loss and must be 0. Also report, as an ESTIMATE, how many removed pairs belong to students whose stored metadata flag is true versus false, so the owner can see how many sessions could hold a stale claim.
- **Q4 informational and metadata classification.**
  - Classify each student's stored `raw_app_meta_data->>'force_password_change'` with a safe `CASE` (never a raw cast, which could abort the read-only transaction) into `true`, `false`, `absent`, or `unknown_invalid`. Mirroring the helper's `::boolean` semantics: after trim and lower-casing, the accepted values `t`, `tr`, `tru`, `true`, `y`, `ye`, `yes`, `on`, `1` classify as `true`; `f`, `fa`, `fal`, `fals`, `false`, `n`, `no`, `of`, `off`, `0` classify as `false`; null or absent classifies as `absent` (treated as false). PostgreSQL boolean input accepts unique prefixes, and the preview classifies those prefixes by the value they parse to. `o` alone is ambiguous and therefore invalid. Only values that `::boolean` would reject are `unknown_invalid`. Step 0 confirms this accepted set against the PostgreSQL documentation for the hosted major version.
  - Report `unknown_invalid` as its own counted category. For such a user the helper would raise a cast error at runtime, which is a failed (denied) read and not a grant, so the count is informational. Any `unknown_invalid` student who holds an active entitlement must be listed (private detail query) for owner review before GO.
  - Claim versus authority skew (stored flag versus `password_change_requirements.required`), labelled ESTIMATE.
  - Counts for follow-ups F1 and F2 (released-before-unlock entitlements; entitlements whose revision is not in the enrollment's current version). These size the follow-ups and do not gate.

### 10.3 GO/NO-GO rule

This rule is also placed at the top of the script. GO only if ALL of these hold:

1. Q0 passes completely (all seven groups, including the static text assertion).
2. Each of `S_false` and `S_true` has `unexplained` = 0 and zero unintended incremental loss (Q3).
3. Every removed pair is attributable to `inactive` or to the JWT flag scenario.
4. Metadata-based counts are labelled estimates and the owner has reviewed and recorded them.
5. `unknown_invalid` students holding an active entitlement are listed and reviewed.

Anything else is NO-GO: do not apply; revise the plan. Running this script on production is itself a hosted action requiring separate explicit approval. It is NOT scheduled by this plan.

## 11. Deploy-skew analysis

- The PR contains only a migration, rollback, audit script, and tests. There is no frontend change, so frontend and database deploy order cannot create a mismatch.
- **Active, unflagged students:** the restrictive gate evaluates true, and permissive OR restrictive-AND-true equals the current result, so every row set is identical. The only direct frontend read (`learnMaterials.ts:106`, legacy bridge) and all RPC-backed reads (LearnDetailPage roster, handouts via `get_student_lesson_assets` and `sign_student_course_asset`, roadmap via `get_student_roadmap_week_states`) are unchanged.
- **Forced-password and banned students:** already denied by the SECURITY DEFINER RPCs and (inference) transitively by `students_read_own_enrollments`, so no newly visible state.
- **Residual:** RLS evaluates the session JWT claim, which can differ from stored `auth.users.raw_app_meta_data`. A JWT issued before an owner flags the student, or before the flag is cleared, keeps the old value until the session refreshes. This is identical to existing RPC and policy behavior and is not new. The preview therefore evaluates both claim scenarios (section 10) and labels metadata-based counts as estimates.
- **Owner:** no authenticated direct reads of these tables were found; Edge owner paths use `service_role`.
- Step 0 re-verifies on `origin/main`. Any new direct read added by #293a, #297, or #298 must be listed and covered by T-D and T-E, or the plan is stale.

## 12. Browser UI policy

Not applicable; see section 6.

## 13. Dev-server rule and local mirror rules

The dev-server rule applies to EVERY job. User verbatim:

> "during implementation make sure no more than one dev server is running per browser validation at any given time. do not leave orphaned dev servers running indefinitely. we need to clean those up as we progress. this should also help avoid port conflicts. can use more than one dev server but only intentionally as needed."

Local mirror rules:

- Mirror stack at `H:\CommandCenter\orchestrator\lizbeth_spanish-218e-run`: API 64321, DB 64322.
- Tests take ports from `SUPABASE_DB_PORT` and `SUPABASE_API_URL`; do not edit files to change ports.
- Port patches (for example `supabase/config.toml` edits) must never be committed; Step 8 verifies with `git diff --name-only`.
- Record dev-server before and after evidence in each job.
- Never recurse-delete through a `node_modules` junction.

## 14. Judge route

High-risk (security, live student data). Cap: four calls. Model `gpt-6-astra`, effort medium. Deterministic failures dominate judge findings. Finding IDs from any judge flow into the engineering fix list and then into the Verifier brief. No judge pass is promised or recorded here.

| Checkpoint | Requiredness | Rubric |
|---|---|---|
| PLAN_DUCK on this plan, before approval | required | plan soundness |
| CODE_REVIEW after JOB_DONE, before Verifier | required | gates present on all chosen policies; permissive predicates byte-identical; rollback restores exactly; preview read-only with complete cause attribution; tests fail on the pre-migration schema |
| VERIFICATION_CHALLENGE after VERIFICATION_PASS | required | evidence that tests were run red-then-green; preview GO logic sound; no hosted command in the transcript; dev-server cleanup evidence |
| VISUAL_REVIEW | skipped | no UI |

## 15. Tests that fail on the current policy

New file `src/__tests__/issueN-delivery-read-account-gates-sql.test.ts` (issue198 fixture pattern) plus a static test file. Run red first and keep the output.

- **T-A latent-leak proof (FAILS now).** In a transaction, relax `students_read_own_enrollments` as in Step 1. A forced-password student and a banned student must still read 0 rows of `lesson_revisions`, `course_version_lessons`, `enrollment_lesson_entitlements`, and `course_versions`.
- **T-B policy self-sufficiency (FAILS now).** `pg_policies` shows, for each D1 table, a policy that is RESTRICTIVE, cmd SELECT, with roles exactly `{authenticated}` (never `public`, `anon`, or `service_role`), whose qual contains `is_account_active` and `user_requires_password_change`.
- **T-C permissive predicates unchanged (passes before and after).** The `pg_get_expr` / `pg_policies` qual, permissive flag, cmd, and roles of the four original permissive policies equal a fingerprint captured from the pre-migration schema.
- **T-D active-student parity (passes before and after).** An active, unflagged, entitled student reads the same rows; held, revoked, and not-yet-unlocked rows are still denied; `banned_until` in the past is still allowed; `force_password_change=false` is allowed.
- **T-E live supabase-js** (`issue174LearnMaterialsLive` pattern). A forced-password student's learnMaterials bridge read returns empty, with the relaxed enrollment policy simulated or via direct REST; an active student's bridge returns its rows.
- **T-F rollback.** Apply the rollback SQL inside a transaction; restrictive policies are gone, permissive quals are unchanged, and table row counts and checksums are identical before and after migration plus rollback.
- **T-G static.** The migration has no `DROP` or `ALTER` of existing policies, no insert, update, delete, or truncate, and has `lock_timeout` and `statement_timeout`. The preview script starts with `begin transaction read only` and ends with `rollback`, and contains no DML or DDL. The preview text contains no `user_requires_password_change(` call and no `auth.jwt(`. No file references a hosted URL or project ref.
- **T-H preview correctness on local fixtures.** Seed one banned, one flagged, one both, and one active student; run the preview; cause counts match in each scenario (`S_false`, `S_true`) and the unexplained count is 0. The preview runs without error and stays read-only.
- **T-I metadata versus JWT disagreement (new).** Fixtures where stored metadata and the JWT claim disagree: metadata true with JWT false; metadata false with JWT true; metadata invalid (`'maybe'`); metadata absent; metadata `'tr'` (an accepted prefix, expected to be classified `true`, not `unknown_invalid`). Assert that:
  - (a) live RLS reads under `asRole` follow the JWT claim and not the stored metadata;
  - (b) the preview reports each fixture in the correct ESTIMATE bucket and scenario bucket;
  - (c) the invalid value lands in `unknown_invalid`, the preview does not error, and an entitled `unknown_invalid` student appears in the review list.

Acceptance: T-A and T-B demonstrably red on the pre-migration schema and green after (output captured); T-C to T-I green; existing `issue198`, `issue174`, and `issue5-phase5` suites green; lint and build green; the preview runs locally in a read-only transaction and reports unexplained = 0 and unintended incremental loss = 0 in both scenarios on fixtures; the rollback test is green; the local post-apply verification query (section 9.1) passes.

## 16. Issue filing and PR

### Step 2: issue

`gh issue create --repo lebobo88/lizbeth-spanish`, title along the lines of "Security: lesson_revisions_student_read (and sibling delivery policies) skip account-active and must-change-password gates". Body: root cause (section 3), severity from Step 1, affected policies per D1, an explicit statement "no production action in this issue's PR; hosted apply and preview need separate approval", and follow-ups F1 to F4. Record N. Optionally file F1 to F4 as one follow-up issue (D3) and reference it.

### Step 8: PR

- Commit only intended files. `git diff --name-only` must not include `supabase/config.toml`, `.env*`, or any port patch.
- Push the branch; `gh pr create --repo lebobo88/lizbeth-spanish --base main`.
- Body contains: root cause, severity, D1 and D2 choices, test red/green evidence, preview GO rule, deploy-skew summary, the explicit statement "No hosted action performed; hosted preview and apply require separate approval", the follow-up issue link, and the line `Closes #N`.
- Acceptance: issue N exists and the PR body contains `Closes #N`; Verifier PASS; Codex judges per section 14; dev-server evidence shows at most one dev server per browser validation and none left running; no hosted command in any transcript.

## 17. Follow-ups F1 to F4 (documented and filed, not fixed here)

- **F1.** `lesson_revisions`, `course_version_lessons`, and `entitlements_own` require `unlock_at <= now()` and ignore `manual_release_state='released'`, unlike the canonical rule. A legacy lesson released early therefore shows no materials on `/learn` (`learnMaterials` `isMaterialsEligible` allows released; the bridge returns empty). This is a student-visible narrowing bug.
- **F2.** These policies are not pinned to the enrollment's current `course_version_id`, unlike the canonical rule, so stale entitlement rows from a prior version can still admit old revisions.
- **F3.** `course_assets_student_read` is inert (no grant); drop or harden.
- **F4.** Own-row policies (`cohort_members_own`, `requests_own`, `quiz_attempts_own`) lack the gates.

F1 and F2 change access for active students and so would violate this plan's GO rule. They need their own plan and preview.

## 18. Risks and rollback

| ID | Risk | Mitigation |
|---|---|---|
| R1 | A restrictive policy also gates any future permissive authenticated policy (for example an owner read) on these tables | Policy comments, T-B and T-C inventory, Q0 precondition |
| R2 | Per-row function cost | `(select ...)` initplan wrapping; `is_account_active` is STABLE SECURITY DEFINER |
| R3 | Stale plan because main moves (#297, #298) | Step 0 re-grounding and `JOB_BLOCKED` "Plan stale" |
| R4 | Accidental hosted action | Forbidden; Verifier checks transcripts and commands; scripts carry headers |
| R5 | Port patch or env committed | Diff check in Step 8 |
| R6 | Orphaned dev servers or port conflicts | Dev-server rule in every job with before/after evidence |
| R7 | `node_modules` junction deletion | Never recurse-delete |

Rollback and containment: the rollback file drops only the new restrictive policies; no data is touched; the original permissive policies are never modified, so rollback is exact. Locally, revert by dropping the policies or by a `db reset` of the mirror.

## 19. Approvals required

- Explicit user approval of this plan, including D1 to D4: GRANTED 2026-10-18, recorded in the Status line.
- Commit, push, and PR authority (PRs only, base `main`) is granted by the PLAN_JOB once the plan is approved.
- Hosted preview and hosted apply each need separate explicit approval later. Neither is scheduled by this plan.

## 20. Engineering mode and downstream owner

- `engineering_mode`: standard.
- `team_authorization`: not applicable.
- `downstream_owner`: engineering-fleet (T1 writer, then Verifier, with Codex judges per section 14). Load `build` and `engineering-fleet` after approval.
