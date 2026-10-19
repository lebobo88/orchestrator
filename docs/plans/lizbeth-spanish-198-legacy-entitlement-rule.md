# Sub-plan: Lizbeth Spanish #198 legacy entitlement rule (PR 5c-1)

- Plan id: `lizbeth-spanish-198-legacy-entitlement-rule`
- Task id: `lizbeth-wave5c-198-entitlement-rule`
- Status: **APPROVED 2026-10-13 (Revision 1).** The user stated, verbatim, on 2026-10-13: "H:\CommandCenter\orchestrator\docs\plans\lizbeth-spanish-198-legacy-entitlement-rule.md is also approved." Decisions D-198-1 to D-198-8 are adopted at their recommendations. Each hosted step (preview run, repair script, migration apply, rollback) still needs separate explicit approval. PR 5c-1 still starts only after PR #251 merges.

**Revision 1 (PLAN_DUCK J-198-01..04, shadow, gpt-5.6-terra).** One revision applied in place. Planner re-checked all four findings against the code at `88b43fd` and confirmed each. Approval was recorded later, on 2026-10-13 (see Status).

- J-198-01 (direct-insert enrollments never materialize). Re-check: trigger `student_enrollments_set_default_course_version` (`202610030001:525-540`) states that it "does not materialize"; `seed.sql:179-267` inserts enrollments directly; 26 test files insert directly (for example `storageIntegration.test.ts:243`); lazy materialization exists only inside `record_lesson_progress` and `sync_legacy_completion_to_entitlement` (`202610040006:96-103`, `:204`). Fix: an AFTER INSERT OR UPDATE trigger `student_enrollments_ensure_entitlements` in migration A, a table of every insert and activate path, test T18. Sections touched: 2, 3.5, 3.6, 5, 6 (Steps 2, 4, 6), 7, 9 (T18), 11, 13 (D-198-6), 15.
- J-198-02 (the owner cannot "accept the loss"). Re-check: the binding invariant in `202608300002` and `202610030001:13-14` ("no completion gate may read the `student_enrollments.completed_at` cache") forbids a policy branch on `se.completed_at`; `save_outline` (`202610120003:42-57`) inherits a link only from revisions already linked in the draft; `apply_version_migration` deletes entitlement rows, including `completed_at`, for revisions absent from the target. Fix: H2 becomes a hard NO-GO while any active student would lose access they legitimately have today; classes INTENDED, RECOVERED_BY_A and BLOCKING; an access-preserving repair script (Step 5b, test T19); D-198-2 option B removed; D-198-7 rewritten; R198-1 and R198-2 rewritten; a repair risk added. Sections touched: 3.6, 5, 6 (Step 5b), 7, 8, 9 (T13, T19), 11, 12 (H2, H2b), 13 (D-198-2, D-198-7), 14, 15, 16.
- J-198-03 (Q2 to Q4 were prose). Fix: section 8 now holds complete executable SQL for Q1 to Q5 and a threshold table; the script contains exactly those statements inside a read-only transaction; the Step 5 test is extended; post-apply verification re-runs Q3. Sections touched: 6 (Step 5), 8, 9, 12 (H4).
- J-198-04 (progress artifacts beyond `completed_at`). Re-check: `student_lesson_progress` (`202608270001:2-12`), `lesson_task_submissions` (`202610040003:41-46`), `quiz_attempts` (`202608280003:144-152`). Fix: the rollback A delete predicate requires no progress artifact of any kind, with a Step 0 foreign-key catalog query; test T17; R198-REPAIR added and R198-ROLLBACK extended. Sections touched: 5, 6 (Steps 0, 4), 9 (T17), 11 (R198-9), 15.
- Parent: deferred Wave 5c sub-plan of the approved plan `docs/plans/lizbeth-spanish-open-issues-deep-dive-2026-10.md` (sections 4.2 #198 and #202, 9 PR 5c, 9.1, 10, 11, 13 R8, 14 D-15, 15.3, 17 item 5). D-15 is approved: the entitlement rule is canonical, and the work comes after #202. Parent section 17 item 5 requires re-plan and approval of this sub-plan before work starts.
- Route: engineering. Engineering mode: standard (T1 first-line, T2 escalation per fleet rules). No extreme-advisory team.
- Target: `lebobo88/lizbeth-spanish` (private).
- Evidence base: read-only checkout `H:\CommandCenter\orchestrator\lizbeth_spanish-main-88b` at `origin/main` `88b43fd`. Every `file:line` below refers to `88b43fd` unless a worktree is named. Migration filenames are given by their numeric prefix and slug under `supabase/migrations/`.
- PR worktrees (reference only):
  - `lizbeth_spanish-5b` = PR #251 (#202, head `c9561da`, migration `202610120003` plus Edge `map_lesson` hardening)
  - `lizbeth_spanish-5a` = PR #250 (#190, migration `202610120002`)
  - PR #237 (B1, migration `202610120001`)
  - `lizbeth_spanish-228` = PR #231 (create-and-assign through `assign_band_enrollment`)

Reading guide: sections 1, 2, 12, 13 and 16 are what an approver needs. Section 3 holds the evidence. Sections 6 to 10 are execution detail for the engineering fleet. Evidence is labelled Observed unless marked Inference or Unknown.

### Standing constraint: production is live

Recorded 2026-10-13 from the user's words: "from this point forward we must consider the project live and production supabase as live with real student and course tracking data. moving forward nothing can be lost in production supabase and all migrations must account for that."

- Production is live, with real student and course tracking data, as of 2026-10-13.
- No production data may be lost.
- Every migration must be non-destructive and account for existing production rows. That means:
  - no DROP, TRUNCATE or DELETE of student, enrollment, progress, submission, attempt, entitlement, course or content data without an approved, logged and reversible data plan;
  - additive or backfilled schema changes with safe defaults;
  - rollbacks that preserve data written after apply;
  - a read-only production preview before any apply that changes access or data.
- Hosted actions still need separate explicit approval.

---

## 1. Outcome and audience

Audience: the owner (Rob), who approves this sub-plan and answers the decisions in section 13, and the engineering fleet, which executes it.

Outcome: close #198, an access-widening security defect. Two legacy student read policies (on `public.resources` and on `storage.objects` for bucket `lesson-assets`) must enforce the same canonical entitlement rule as every newer student read path, without hiding content students are legitimately entitled to. The PR delivers:

1. A forward migration pair with rollback files.
2. A RED test for each divergence case, shown failing before and passing after.
3. A read-only hosted impact preview that the user runs before any apply.
4. A hosted rollout order with rollback.
5. Regression browser journeys.

PR base is `main`, body "Closes #198". No merge. No hosted action without separate approval (parent D-28).

## 2. Scope and non-goals

In scope (PR 5c-1, one PR):

1. Migration A: an insert-only gap backfill of missing entitlement rows for active legacy enrollments, an amendment of the `lessons_map_legacy_revision` trigger, and a new `student_enrollments_ensure_entitlements` trigger that materializes zero-row active enrollments.
2. Migration B: two SECURITY DEFINER boolean helpers, a rewrite of `students_read_unlocked_resources` and `students_read_unlocked_lesson_assets`, and one supporting index.
3. Two rollback files.
4. A read-only impact-preview SQL script under `scripts/audit/`, and an access-preserving repair script under `scripts/repair/` (not a migration) with its rollback, run on hosted only under its own approval and only if the preview shows blocking pairs.
5. RED tests, plus updates to the existing suites and seed that encode the legacy date rule.
6. The #222 EXECUTE-allowlist test update for the two new helpers.

Non-goals:

- No change to `get_student_lesson_assets`, `resolve_student_course_asset`, or the `/learn` RPCs. They already use the canonical rule and govern `course_assets`, not `resources`.
- No frontend code change in 5c-1.
- No automatic repair of NULL-link revisions inside a migration. Repair, if the preview requires it, is the separate owner-confirmed script in Step 5b (D-198-7).
- No change to the owner policies `owner_read_instructor_decks`, `owner_read_instructor_deck_objects`, or `owner_*_lesson_assets`.
- No Edge change.
- No hosted apply, deploy, or database write without separate explicit approval.
- No push to main and no merge.
- Roadmap UI state alignment is a separate follow-up, PR 5c-2, with its own sub-plan and design route (D-198-5).

## 3. Repository findings

### 3.1 Current policy text (Observed)

Source: `202610050005_issue180d_instructor_decks_owner_only.sql:19-66`. Earlier history: `202607170002:35-53`, `202607170005:23`, `202607200002:35-81`, `202608070001:59-113`.

```sql
create policy "students_read_unlocked_resources" on public.resources for select
  using (
    not public.user_requires_password_change()
    and resources.resource_type <> 'pptx'
    and exists (
      select 1 from public.lessons l
      join public.student_enrollments se on l.band_id = se.band_id
      where l.id = resources.lesson_id
        and se.user_id = auth.uid() and se.status = 'active'
        and public.is_account_active(auth.uid())
        and ( now() >= (se.enrollment_date + make_interval(days => l.unlock_offset_days))
              or (se.completed_at is not null and se.completed_at <= now()) )));
create policy "students_read_unlocked_lesson_assets" on storage.objects for select to authenticated
  using (
    not public.user_requires_password_change()
    and bucket_id = 'lesson-assets'
    and exists (
      select 1 from public.resources r
      join public.lessons l on l.id = r.lesson_id
      join public.student_enrollments se on se.band_id = l.band_id
      where r.storage_bucket = storage.objects.bucket_id and r.storage_path = storage.objects.name
        and r.resource_type <> 'pptx'
        and se.user_id = auth.uid() and se.status = 'active'
        and public.is_account_active(auth.uid())
        and ( now() >= (se.enrollment_date + make_interval(days => l.unlock_offset_days))
              or (se.completed_at is not null and se.completed_at <= now()) )));
```

The resources policy has no `to authenticated` clause. Anonymous callers get false because `auth.uid()` is null.

Other policies on these tables (Observed):

- `service_role_all_resources` (`202607170002:55`).
- `owner_read_instructor_decks` and `owner_read_instructor_deck_objects` (`202610050005:69-90`): pptx only, `app_metadata` role owner.
- `owner_insert/select/update/delete_lesson_assets` (`202608300003:116-218`): version-uuid path prefix through `owns_lesson_asset_path`. They do not cover legacy band paths.

Bucket `lesson-assets` is private (`supabase/config.toml:134-135`).

Indexes (Observed):

- `resources` unique `(storage_bucket, storage_path)` (`202607170006:24-26`); `idx_resources_lesson_id`; `idx_student_enrollments_user_id` (`202607170001:92-94`).
- `lesson_revisions` unique `(legacy_lesson_id, revision_no)` (`202608280003:64`).
- `enrollment_lesson_entitlements` primary key `(enrollment_id, lesson_revision_id)` and `idx_entitlements_user (enrollment_id, unlock_at)` (`202608280003:195-199`).
- There is no index leading on `enrollment_lesson_entitlements.lesson_revision_id`.

### 3.2 Grants (Observed, corrects the parent)

`202608280003:531` revokes all on `lesson_revisions`, `enrollment_lesson_entitlements`, `course_version_lessons` and related tables from `anon, authenticated`. `:536` then re-grants SELECT to `authenticated` on `course_versions`, `lesson_revisions`, `course_version_lessons`, `cohorts`, `cohort_memberships`, `enrollment_requests`, `quiz_attempts`, and `enrollment_lesson_entitlements`. This corrects parent section 15.3 bullet 2: the student read policies at `:520-527` are not inert. `course_assets` has no `authenticated` grant.

### 3.3 Canonical entitlement rule (Observed)

- Anchor: `coalesce(cohorts.starts_at, se.enrollment_date)` in `resolve_entitlement_anchor` (`202608300001:34-40`).
- `unlock_at = anchor + course_version_lessons.unlock_offset_days` in `materialize_enrollment_entitlements` (`202608300001:50-65`). Rows exist only for versions with `cv.status = 'published'`. Prerequisite-gated lessons get no row until the prerequisite is completed. `ON CONFLICT` updates `unlock_at`.
- The newest student paths use `manual_release_state not in ('held','revoked') and (manual_release_state = 'released' or unlock_at <= now())`: `202610040002:24-25, :63-64, :99-100` (`get_student_lesson_assets`, `resolve_student_course_asset`), `202610040003:326-327`, `202610040006:412-413`, `202610050001:508`, and the client function `isMaterialsEligible` in `src/services/learnMaterials.ts:40-51`.
- The older 2026-08 RLS policies (`202608280003:520-527`) use `unlock_at <= now()` and not held/revoked, without the `released` early-unlock.

### 3.4 Readers of `public.resources` and lesson-assets objects (Observed)

These run in student context and are subject to the two policies:

- `src/services/roadmapData.ts:114-132` `fetchResourcesForLesson`, the `/roadmap` week gate. Its comment says RLS is "the real gating check".
- `src/services/learnMaterials.ts:99-121`: legacy `/learn` materials. It goes through the `lesson_revisions` bridge, then `resources`. Effective access is the intersection of both.
- `src/lib/storageSigning.ts:202-244` `getSignedResourceUrl`, using the student anon-key client. `createSignedUrl` is subject to `storage.objects` RLS.
- `src/lib/resourceSigner.ts:27-44`.
- `src/services/vocabularyReviewLoader.ts:81-117`, the student vocabulary review (signs, then fetches).
- `WeekDetailPage.tsx:783-829`: `resources.length > 0` means available, and `loadContentStatus` reads `lesson_content`. Otherwise the client `computeWeekRoadmap` uses `enrollment_date + lessons.unlock_offset_days` to choose `locked` or `empty`. The `empty` copy is "No resources published for this week yet." (`:1006-1009`).
- Components `ResourcesPanel.tsx`, `LessonResources.tsx`, `LearnDetailPage.tsx`.

Not affected (service role, bypasses RLS):

- Edge `get_owner_resource_text` (`course-authoring/index.ts:157-179`): owner vocabulary review, needs a non-null legacy link (#202).
- Edge `sign_student_course_asset` (`index.ts:73-96`): resolver through the caller JWT, service-role signing of `course_assets` paths only.
- `admin-student-operations/index.ts:759`: `lesson_content` listing.
- RPCs `get_student_lesson_assets` and `resolve_student_course_asset` read `course_assets`, not `resources`, and already use the canonical rule.
- Owner preview (course-authoring `preview` action, `course_preview_lessons` view) runs as service role.
- The owner has no student enrollment, so the student policy is already false for the owner.

### 3.5 Materialization paths and gaps

Enrollment insert and activate paths (Observed, enumerated by Planner at `88b43fd`):

| Path | Location | Materializes? |
|---|---|---|
| `assign_band_enrollment` | `202610030001:574-586` | Yes (rolling, when `course_version_id` is not null) |
| `grant_cohort_enrollment`, used by `enroll_cohort_member` and `approve_enrollment_request` | `202608300005:129`, `:143` | Yes (cohort-anchored; sets `cohort_id` and `band_id`) |
| `request_cohort_enrollment` | latest `202608300002:570-597` | Yes |
| `request_version_enrollment` | `202608300004:28` | Delegates to the primitives above |
| `resume_band_enrollment` (preserved to active) | `202610030001:593-615` | Only when there are zero rows |
| `apply_version_migration` | `202608300002:57-116` | Updates `course_version_id` and runs a guarded upsert; deletes and reinserts rows for revisions in the target |
| `admin-student-operations` Edge | `index.ts:512` resume, `:525` assign, `:560` update to preserved | Through the RPCs above |
| Direct SQL inserts | `seed.sql:179-267` and the tests | No. Trigger `student_enrollments_set_default_course_version` (`202610030001:525-540`) "does not materialize" |
| `grant_enrollment_entitlements_with_prerequisites` | `202608290001:437-498`, redefined `202608300001:312` and `202608300002:493` | Yes; the dark, owner-only prerequisite path |

Older definitions in `202608280003:413` and `:468` and `202608300001:385` and `:412` are superseded. Lazy materialization exists only inside `record_lesson_progress` and `sync_legacy_completion_to_entitlement` (`202610040006:96-103`, `:204`), so a direct-insert enrollment has no rows until it records progress.

The #176 backfill (`202610030002:80-105`) materialized every active or preserved enrollment that had a `course_version_id` and zero rows. Per the parent's evidence, hosted Stage A to D was applied in October 2026.

Gaps:

| Id | Gap | Label |
|---|---|---|
| G1 | Enrollments with zero entitlement rows: direct inserts (trigger `student_enrollments_set_default_course_version`, `202610030001:525-540`, "does not materialize"), `course_version_id` null, or version not published. Local seed leaves `fullaccess` and other seeded enrollments unmaterialized (`supabase/seed.sql:505-526`; only student1 and student2 Beginner are materialized) because the `wp11-learn.spec.ts` "legacy-materialization branch" relies on it. | Observed |
| G2 | Legacy lessons inserted after enrollment: trigger `lessons_map_legacy_revision` (`202610030001:546-568`) maps into the version but creates no entitlement for existing enrollments. | Observed |
| G3 | NULL-link revisions (J-202-003): revisions saved by pre-#202 `save_outline` carry `legacy_lesson_id` NULL. PR #251 prevents new ones but does not repair existing ones. An enrollment on such a version (`resolve_band_course_version` may select a non-legacy-mapped published version, `202610030001:24-60`) has no path from entitlement to resources. | Observed, exposure Unknown until Q4 |
| G4 | Prerequisite-gated lessons have no row until the prerequisite completes. Legacy lessons have no prerequisites. | Inference |
| G5 | Cadence: `update_course_settings` changes only draft offsets (`202608300001:491-500`). Published entitlements change only through `apply_enrollment_reconciliation` (automatic rows) or version migration. `lessons.unlock_offset_days` is never updated, so the legacy rule keeps the original schedule. | Observed |
| G6 | Completed enrollments: the legacy rule unlocks every week once `se.completed_at <= now()`. The entitlement rule does not. `completion_threshold` may be below 1, so completion can precede late unlocks. | Observed |

### 3.6 Divergence matrix (legacy to canonical)

| Case | Direction of change | Handling |
|---|---|---|
| Enrolled before cohort start | Widening in legacy | Fixed by the new rule |
| Late joiner | Narrowing in legacy | Fixed; the student gains access |
| Held or revoked, readable through PostgREST and storage, including rolling enrollments | Widening in legacy | Fixed |
| Cadence change or reconciled `unlock_at` | Both directions | Follows `unlock_at` |
| `released` early-unlock | Narrowing in legacy | Fixed if D-198-1 is accepted |
| Completed enrollment unlocks everything | Widening in legacy | Policy branch removed (D-198-2). Completed students who would lose legitimate access are handled by repair R-d, not by a policy branch |
| Zero-row enrollments, unmapped new lessons, NULL-link revisions, stale `unlock_at`, missing course version | Legitimate access that would be lost | Backfilled and trigger-materialized (G1, G2), or repaired before apply by the Step 5b script (G3 and the BLOCKING class, D-198-7). Apply is a NO-GO until none remain |

### 3.7 #202 dependency (Observed)

PR #251 migration `202610120003` (`lizbeth_spanish-5b\supabase\migrations\202610120003_issue202_save_outline_identity.sql`) preserves `legacy_lesson_id` across saves with `revision_no = max + 1`. A legacy lesson can therefore have several revisions. The new rule must join on `lesson_revisions.legacy_lesson_id` regardless of `revision_no`.

### 3.8 Existing tests that encode the legacy rule (Observed)

These must be updated, not weakened:

- `src/__tests__/rlsSecurityRegression.test.ts` (Test 2 `:172`, Test 3 `:202`).
- `rlsIntegration.test.ts` (`:263-401`: student-1, student-4, and the student-3 completed branch at `:367`).
- `storageIntegration.test.ts` (`:38-138`; `:243` inserts an enrollment directly without materializing).
- `storageLessonAssetWriteRls.test.ts`.
- `fullAccessTestStudent.test.ts` (fullaccess has at least 175 days, all 26 weeks).
- e2e: `wp10-roadmap-week-flashcards`, `issue175-vocabulary-review`, the issue174 fixtures, and `wp11-learn` (legacy-materialization branch).
- The #222 test `authenticatedFunctionExecuteGrants.test.ts` must allowlist the two new helpers.

Precedent for audit scripts and tests: `scripts/audit/issue176-completion-audit.sql` with `src/__tests__/issue176-audit-script.test.ts`. Rollback naming precedent: `supabase/rollbacks/issue180d_instructor_decks_owner_only_rollback.sql`.

### 3.9 Research basis

Researcher was not invoked. Supabase Storage RLS semantics are established locally and empirically: `202608300003:129-153` records real Storage API behavior (`createSignedUrl`, upsert, and delete evaluate `storage.objects` policies in the caller role), and `storageIntegration.test.ts` exercises real signed URLs.

Inference, recorded as a rollout limit: a signed URL already issued stays valid until its TTL (default 3600 s, `storageSigning.ts:252`; `ResourcesPanel` uses shorter TTLs). Revocation is not retroactive for minted URLs.

## 4. Design route

`DESIGN_ROUTE` profile: none. Reason: PR 5c-1 changes only database policies, functions, a trigger, an index, scripts and tests. No component, copy, style or layout changes. The student-visible effect is the intended access change, rendered by existing states. Design handoff: none. Design review: none.

Known interim UI limitation (Observed): `/roadmap` computes week state client-side from `enrollment_date + lessons.unlock_offset_days` (`src/lib/roadmap.ts:118-127`; `WeekDetailPage.tsx:812-829`). After 5c-1:

- A held, revoked, or not-yet-started-cohort week that the client thinks is unlocked shows "No resources published for this week yet."
- A late joiner may see locked cards for weeks the server now allows.

Alignment is follow-up PR 5c-2, a separate sub-plan with its own design route (probably compact, reusing the `/learn` "paused" concept), sized by the preview results (D-198-5).

## 5. Judge route

Policy: shadow (advisory). High-risk cap of four calls. Per `docs/JUDGE-CONTRACT.md`.

- PLAN_DUCK is eligible on this draft before approval (the orchestrator runs it).
- CODE_REVIEW is required (high-risk access control) after `JOB_DONE` and before Verifier. Rubric ids:

| Rubric id | Check |
|---|---|
| R198-AUTHZ | Both policies deny held, revoked, not-yet-unlocked, and pre-cohort; allow released and late-joiner; pptx still excluded; anon denied |
| R198-FAILCLOSED | Helpers return false on null `auth.uid()`, inactive account, password-change flag, preserved enrollment, and missing rows |
| R198-DEFINER | SECURITY DEFINER, `set search_path = public`, boolean return only, EXECUTE to `authenticated` only, revoked from public and anon |
| R198-RECURSION | No policy cycle; helpers read tables whose policies never reference `resources` or `storage.objects` |
| R198-ROLLBACK | Rollback restores the `202610050005` text exactly; backfill rollback never deletes a row with any progress artifact (`completed_at`, `student_lesson_progress`, `lesson_task_submissions`, `quiz_attempts`, or any other activity table found by the Step 0 catalog query) or manual state |
| R198-REPAIR | The repair script only widens or preserves access, defaults to dry-run, logs every change, and is reversible; it is never a migration |
| R198-TESTS | Every divergence case is RED then GREEN |

- One repeat after remediation is allowed.
- VERIFICATION_CHALLENGE is recommended (parent section 8 lists #198) when coverage risk remains.
- VISUAL_REVIEW is not applicable.
- Deterministic failures dominate. Finding ids flow into the engineering job and the Verifier brief. No judge pass is promised and no model-generated findings are included.

## 6. Ordered work

**Step 0 (T1): preflight.**

- Wait until PR #251 is merged to main (hard dependency). Branch from the post-merge main head and record the base SHA.
- Re-verify every cited `file:line`.
- Confirm which migration prefixes are present on main (`202610120001` to `202610120003` if #237, #250 and #251 have merged). Choose the next free prefixes that sort after all of them (expected `202610130001` and `202610130002`, or later).
- Record the vitest and e2e baseline per parent 11.3.
- Run a catalog query over `pg_constraint` foreign keys that reference `public.lesson_revisions(id)` and `public.student_enrollments(id)`. List every referencing table and extend the rollback A predicate (Step 4) to each one that records per-student, per-lesson activity. Put the list in the PR body.
- Check whether the UI exposes `map_lesson` for legacy revisions (Unknown).
- Stale-plan trigger if any of these changed: the two policies, `materialize_enrollment_entitlements`, `resolve_entitlement_anchor`, `lessons_map_legacy_revision`, `has_completed_course_version`, `grant_enrollment_entitlements_with_prerequisites`, the `get_student_lesson_assets` predicate, or the seed materialization block; or if the FK catalog finds an activity table the plan does not cover.

**Step 1 (T1): RED tests first.** Write the tests listed in section 9 against the local stack and record the failing runs.

**Step 2 (T1): migration A,** `<prefix>1_issue198_legacy_entitlement_backfill.sql`.

- (a) Create `public.issue198_entitlement_backfill_log(enrollment_id uuid, lesson_revision_id uuid, inserted_at timestamptz default now(), primary key (enrollment_id, lesson_revision_id))`. Revoke all from `anon, authenticated`. Grant to `service_role` only.
- (b) Insert-only backfill. For every `student_enrollments` row with status in `('active','preserved')`, `course_version_id` not null, and version status `'published'`, insert into `enrollment_lesson_entitlements(enrollment_id, lesson_revision_id, course_version_id, unlock_at)` one row for each `course_version_lessons` row of that version that has `prerequisite_lesson_revision_id` null and no existing entitlement row.
  - `unlock_at = public.resolve_entitlement_anchor(se.id, se.course_version_id) + make_interval(days => cvl.unlock_offset_days)`. The helper is hoisted per enrollment, with no inline anchor computation, which preserves the `202608300001` invariant.
  - `ON CONFLICT DO NOTHING`, recording each inserted key in the log (use `INSERT ... RETURNING` into the log).
  - Never update existing rows. Do not call `materialize_enrollment_entitlements` here, because its `ON CONFLICT` rewrites `unlock_at` of existing rows.
  - `raise notice` with counts.
- (c) Amend `lessons_map_legacy_revision` (`202610030001:546-568`). After mapping the new revision into the version, insert entitlement rows for that revision for every active or preserved enrollment on that version (same anchor helper, `ON CONFLICT DO NOTHING`). Keep SECURITY DEFINER, the `search_path`, and the revokes from public, anon and authenticated.
- (d) Add trigger `student_enrollments_ensure_entitlements` on `public.student_enrollments`: AFTER INSERT OR UPDATE OF `status`, `course_version_id`, `band_id`, `WHEN (new.status = 'active' and new.course_version_id is not null)`, ordered after the existing BEFORE default-version trigger. Its function is SECURITY DEFINER, uses `set search_path = public`, and is revoked from public, anon and authenticated. It calls `public.materialize_enrollment_entitlements(new.id)` only when all three hold:
  1. the enrollment has zero entitlement rows;
  2. the version is published;
  3. the course-level prerequisite is satisfied. Mirror the gate in `grant_enrollment_entitlements_with_prerequisites`: when `courses.prerequisite_version_id` is not null, require `public.has_completed_course_version(new.user_id, prerequisite_version_id)`. If it is unmet, insert nothing and leave the enrollment fail-closed.

  Properties and consequences:
  - Because it acts only on zero rows, it never rewrites existing rows (`unlock_at`, manual state and `completed_at` are untouched).
  - It is idempotent with every RPC that already materializes after its insert: the RPC's later materialize call finds the same rows and sets the same `unlock_at`.
  - `apply_version_migration` is unaffected, because enrollments being migrated already have rows, and a zero-row case ends in its `ON CONFLICT` upsert.
  - Seeded enrollments become materialized automatically when `backfill_legacy_courses()` sets `course_version_id`, so D-198-6 is partly satisfied by the trigger.
  - An active, zero-row legacy enrollment becomes unreachable except when the prerequisite is unmet or the version is unpublished. The `wp11` "legacy-materialization branch" test must move to a prerequisite-unmet or unpublished-version fixture, or document that the branch is dead for legacy courses.
  - Tests that insert directly and then assert zero rows or exact counts must be reviewed and updated with an explicit reason, never weakened.

**Step 3 (T1): migration B,** `<prefix>2_issue198_legacy_entitlement_rule.sql`.

```sql
create or replace function public.student_can_read_legacy_lesson(p_lesson_id uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select auth.uid() is not null
    and not public.user_requires_password_change()
    and public.is_account_active(auth.uid())
    and exists (
      select 1
      from public.student_enrollments se
      join public.enrollment_lesson_entitlements ele on ele.enrollment_id = se.id
      join public.course_version_lessons cvl
        on cvl.course_version_id = se.course_version_id and cvl.lesson_revision_id = ele.lesson_revision_id
      join public.lesson_revisions lr on lr.id = ele.lesson_revision_id
      where se.user_id = auth.uid() and se.status = 'active'
        and lr.legacy_lesson_id = p_lesson_id
        and ele.manual_release_state not in ('held','revoked')
        and (ele.manual_release_state = 'released' or ele.unlock_at <= now()));
$$;
create or replace function public.student_can_read_legacy_object(p_bucket text, p_name text)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.resources r
    where r.storage_bucket = p_bucket and r.storage_path = p_name
      and r.resource_type <> 'pptx'
      and public.student_can_read_legacy_lesson(r.lesson_id));
$$;
revoke all on function public.student_can_read_legacy_lesson(uuid) from public, anon;
revoke all on function public.student_can_read_legacy_object(text, text) from public, anon;
grant execute on function public.student_can_read_legacy_lesson(uuid) to authenticated;
grant execute on function public.student_can_read_legacy_object(text, text) to authenticated;
drop policy if exists "students_read_unlocked_resources" on public.resources;
create policy "students_read_unlocked_resources" on public.resources for select to authenticated
  using (resources.resource_type <> 'pptx' and public.student_can_read_legacy_lesson(resources.lesson_id));
drop policy if exists "students_read_unlocked_lesson_assets" on storage.objects;
create policy "students_read_unlocked_lesson_assets" on storage.objects for select to authenticated
  using (bucket_id = 'lesson-assets' and public.student_can_read_legacy_object(bucket_id, name));
create index if not exists idx_entitlements_lesson_revision on public.enrollment_lesson_entitlements(lesson_revision_id);
comment on policy ... (state the canonical rule and #198).
```

- The `comment on policy` lines are abbreviated in the source handoff; T1 writes them for both policies, stating the canonical rule and #198.
- The predicate shown is the D-198-1 (released early-unlock) and D-198-2 option A (no completion branch) version. Adjust it only if the user decides otherwise.
- The `course_version_lessons` join binds entitlements to the enrollment's current version, matching `get_student_lesson_assets`.
- Recursion safety: the helpers are SECURITY DEFINER, so the owner role bypasses RLS on the read tables. There is no stacked policy evaluation and no dependency on the table-level grants. No policy on `student_enrollments`, `enrollment_lesson_entitlements`, `course_version_lessons`, `lesson_revisions` or `resources` references these helpers or `storage.objects`, so there is no cycle.
- Oracle analysis: the helpers return boolean only and are bound to `auth.uid()`. A caller learns only what a `resources` select already reveals.

**Step 4 (T1): rollbacks.**

- `supabase/rollbacks/issue198_legacy_entitlement_rule_rollback.sql`: recreate both policies with the exact `202610050005:19-66` text, drop the two helpers, and drop `idx_entitlements_lesson_revision` (optional; harmless to keep).
- `supabase/rollbacks/issue198_legacy_entitlement_backfill_rollback.sql`: restore the `202610030001:546-568` trigger function body, and drop trigger `student_enrollments_ensure_entitlements` and its function. Delete only rows that are present in `public.issue198_entitlement_backfill_log` AND match all of the following:
  - `ele.manual_release_state = 'automatic'` and `ele.completed_at is null`;
  - no `student_lesson_progress` row exists for `(ele.enrollment_id, lr.legacy_lesson_id)`, with any columns (`first_opened_at`, `last_opened_at`, `completed_at`; `202608270001:2-12`);
  - no `lesson_task_submissions` row exists for `(ele.enrollment_id, ele.lesson_revision_id)` (`202610040003:41-46`);
  - no `quiz_attempts` row exists for `(se.user_id, ele.lesson_revision_id)` (`202608280003:144-152`);
  - no row exists in any other table that the Step 0 catalog query finds and classifies as per-student, per-lesson activity.

  Report (`raise notice`) every other logged row as kept, with the kept count. Drop the log table last.
- Rolling back B alone restores prior access immediately. A's rows are correct data and may stay.

**Step 5 (T1): impact-preview script** `scripts/audit/issue198-impact-preview.sql`. It is read-only, begins with `begin transaction read only;` and ends with `rollback;`, and contains exactly the statements Q1 to Q5 of section 8. Add a vitest test that checks:
- the script parses and runs on the local stack inside a read-only transaction;
- on a constructed fixture it returns the expected rows for at least one example of each reason: `held`, `revoked`, `not_yet_unlocked_cohort`, `no_entitlement_rows`, `lesson_not_in_version`, `stale_unlock_at`, `completed_branch_only`;
- it contains no insert, update, delete, alter, create, drop, grant or truncate outside comments.

**Step 5b (T1): access-preserving repair script** `scripts/repair/issue198-access-preserving-repair.sql`, with a matching `scripts/repair/issue198-access-preserving-repair-rollback.sql`. It is not a migration, so `db push` never applies it. It is transactional, writes the log table `public.issue198_repair_log` (service_role only), defaults to dry-run (ending in `rollback`), and is run by the user on hosted only with its own explicit approval and only if the preview shows BLOCKING pairs. It has four sections, each idempotent and each only widening or preserving access:

- **R-a `no_course_version`:** set `course_version_id = public.resolve_band_course_version(band_id)` for the listed active enrollments where that value is not null. The new trigger then materializes.
- **R-b NULL-link (`lesson_not_in_version`):** driven by an explicit owner-confirmed pair list (`lesson_revision_id` to `legacy_lesson_id`). Never automatic position matching (the parent plan rejected that as an integrity risk). The read-only candidate query Q5 (section 8) lists each NULL-link revision mapped in a published version of a legacy course, with its position, title, and the same-band legacy lesson for that week, so the owner can confirm each pair in writing. The repair updates only revisions whose `legacy_lesson_id` is null, whose version's course has `legacy_band_id` equal to the lesson's `band_id`, and which are not already claimed in that version. It sets `revision_no = coalesce(max(revision_no) for that legacy_lesson_id, 0) + 1`, under the same per-legacy advisory lock and sorted order as `202610120003`, to avoid the unique `(legacy_lesson_id, revision_no)` conflict. It logs the old values, and its rollback restores NULL and the old `revision_no`.
- **R-c `stale_unlock_at`:** for automatic rows, set `unlock_at = least(unlock_at, expected)` only where `expected < unlock_at`. It only moves earlier and never reduces visibility (the same monotonic shape as `202608300002:102-112`).
- **R-d `completed_branch_only`:** for enrollments where `public.has_completed_course_version(se.user_id, se.course_version_id)` is true, set `manual_release_state = 'released'` on automatic rows with `unlock_at > now()`. Log them. The rollback restores `'automatic'` only for logged rows still `'released'` and never deletes rows. This relies on D-198-1.

Why there is no owner republish path (Observed): `save_outline` (`202610120003:42-57`) inherits a link only from revisions already linked in the draft, and `apply_version_migration` deletes entitlement rows (including `completed_at`) for revisions absent from the target. A republish or move therefore cannot restore links and is not recommended for NULL-link repair. Whether the UI exposes `map_lesson` for legacy revisions is Unknown (Step 0 check). The repair rollbacks apply the same "no progress of any kind" predicate as Step 4. Before the script is used it gets a local RED/GREEN test (T19) and the dry-run default is verified.

**Step 6 (T1): update seed and existing suites** (no weakened assertions):

- The seed materializes every active seeded enrollment that has a version (D-198-6); the new trigger does this automatically once `backfill_legacy_courses()` sets `course_version_id`, and the seed is checked to confirm it.
- `storageIntegration.test.ts:243` is reviewed: the trigger now materializes its direct insert, so any assertion of zero rows or exact counts is updated with an explicit reason.
- The 26 test files that insert enrollments directly are reviewed for zero-row or exact-count assertions. Each change is documented, never weakened.
- `rlsIntegration` completed-branch expectations follow D-198-2 (T13).
- The `wp11` legacy-materialization test moves to a prerequisite-unmet or unpublished-version fixture (the only zero-row active states left), or documents that the branch is dead for legacy courses.
- The #222 allowlist adds the two helpers.

**Step 7 (T1): full gates** (parent 11.1), Verifier, CODE_REVIEW, and Browser Validator regression journeys. Open the PR against `main` with "Closes #198". The body lists the hosted rollout steps and states that no hosted action was taken.

Owners: T1 first-line, T2 per fleet escalation; Verifier; Browser Validator; `codex-judge-runner` for CODE_REVIEW; Scribe for the evidence record after hosted rollout; the user runs all hosted queries.

## 7. Interfaces and data

- New functions `public.student_can_read_legacy_lesson(uuid)` and `public.student_can_read_legacy_object(text, text)`, with EXECUTE for `authenticated`.
- Policy names are unchanged, so rollback is by name.
- New index `idx_entitlements_lesson_revision`.
- New table `public.issue198_entitlement_backfill_log` (service_role only).
- Changed trigger function `lessons_map_legacy_revision`.
- New trigger `student_enrollments_ensure_entitlements` and its SECURITY DEFINER function (`search_path = public`, revoked from public, anon and authenticated).
- Repair artifacts (not migrations): `scripts/repair/issue198-access-preserving-repair.sql`, its rollback, and the log table `public.issue198_repair_log` (service_role only), created by the script under its own approval.
- Preview artifact: `scripts/audit/issue198-impact-preview.sql` with Q1 to Q5.
- Data: insert-only entitlement rows from migration A; the repair script, if used, updates `course_version_id`, `legacy_lesson_id`/`revision_no`, `unlock_at` (earlier only) and `manual_release_state` (to `released`), all logged.
- No client, Edge, or response-shape change.
- Hosted: migration apply needs separate approval. Netlify and Edge: none.

## 8. Impact preview

The user runs the script read-only on hosted before any apply. `scripts/audit/issue198-impact-preview.sql` contains exactly the statements Q1 to Q5 below, wrapped in `begin transaction read only; ... rollback;`. Verifier checks the script against this section. Formatting may change, logic may not.

### Q1: legacy-versus-canonical diff

Parameter `t` defaults to `now()`. The user may also rerun with `now() + interval '7 days'`.

```sql
begin transaction read only;
with params as (select now() as t),
legacy as (
  select distinct se.user_id, r.id as resource_id
  from public.resources r
  join public.lessons l on l.id = r.lesson_id
  join public.student_enrollments se on se.band_id = l.band_id
  cross join params p
  where r.resource_type <> 'pptx' and se.status = 'active' and public.is_account_active(se.user_id)
    and (p.t >= se.enrollment_date + make_interval(days => l.unlock_offset_days)
         or (se.completed_at is not null and se.completed_at <= p.t))),
canonical as (
  select distinct se.user_id, r.id as resource_id
  from public.resources r
  join public.lesson_revisions lr on lr.legacy_lesson_id = r.lesson_id
  join public.enrollment_lesson_entitlements ele on ele.lesson_revision_id = lr.id
  join public.student_enrollments se on se.id = ele.enrollment_id
  join public.course_version_lessons cvl on cvl.course_version_id = se.course_version_id and cvl.lesson_revision_id = ele.lesson_revision_id
  cross join params p
  where r.resource_type <> 'pptx' and se.status = 'active' and public.is_account_active(se.user_id)
    and ele.manual_release_state not in ('held','revoked')
    and (ele.manual_release_state = 'released' or ele.unlock_at <= p.t))
select 'loses_access' as direction, count(distinct user_id) as students, count(distinct resource_id) as resources, count(*) as pairs
  from (select * from legacy except select * from canonical) x
union all
select 'gains_access', count(distinct user_id), count(distinct resource_id), count(*)
  from (select * from canonical except select * from legacy) y;
rollback;
```

### Shared CTE prefix for Q2, Q2-detail and Q3

Repeat this prefix at the top of each of those statements. A pair takes the first reason that matches, in the order of the `case` expression.

```sql
with params as (select now() as t),
legacy as (
  select se.id as enrollment_id, se.user_id, se.course_version_id, se.cohort_id, l.band_id,
         r.id as resource_id, r.lesson_id,
         (p.t >= se.enrollment_date + make_interval(days => l.unlock_offset_days)) as by_date
  from public.resources r
  join public.lessons l on l.id = r.lesson_id
  join public.student_enrollments se on se.band_id = l.band_id
  cross join params p
  where r.resource_type <> 'pptx' and se.status = 'active' and public.is_account_active(se.user_id)
    and (p.t >= se.enrollment_date + make_interval(days => l.unlock_offset_days)
         or (se.completed_at is not null and se.completed_at <= p.t))),
canonical as (
  select distinct se.user_id, r.id as resource_id
  from public.resources r
  join public.lesson_revisions lr on lr.legacy_lesson_id = r.lesson_id
  join public.enrollment_lesson_entitlements ele on ele.lesson_revision_id = lr.id
  join public.student_enrollments se on se.id = ele.enrollment_id
  join public.course_version_lessons cvl on cvl.course_version_id = se.course_version_id and cvl.lesson_revision_id = ele.lesson_revision_id
  cross join params p
  where r.resource_type <> 'pptx' and se.status = 'active' and public.is_account_active(se.user_id)
    and ele.manual_release_state not in ('held','revoked')
    and (ele.manual_release_state = 'released' or ele.unlock_at <= p.t)),
lost as (
  select lg.* from legacy lg
  where not exists (select 1 from canonical c where c.user_id = lg.user_id and c.resource_id = lg.resource_id)),
classified as (
  select lo.*,
    case
      when lo.course_version_id is null then 'no_course_version'
      when cv.status is distinct from 'published' then 'version_not_published'
      when not exists (select 1 from public.enrollment_lesson_entitlements e0 where e0.enrollment_id = lo.enrollment_id) then 'no_entitlement_rows'
      when not exists (select 1 from public.course_version_lessons m join public.lesson_revisions mr on mr.id = m.lesson_revision_id
                       where m.course_version_id = lo.course_version_id and mr.legacy_lesson_id = lo.lesson_id) then 'lesson_not_in_version'
      when best.manual_release_state is null then 'entitlement_missing_for_lesson'
      when best.manual_release_state = 'held' then 'held'
      when best.manual_release_state = 'revoked' then 'revoked'
      when not lo.by_date then 'completed_branch_only'
      when best.manual_release_state = 'automatic'
           and best.unlock_at <> public.resolve_entitlement_anchor(lo.enrollment_id, lo.course_version_id) + make_interval(days => best.unlock_offset_days)
        then 'stale_unlock_at'
      when best.unlock_at > (select t from params) and lo.cohort_id is not null then 'not_yet_unlocked_cohort'
      when best.unlock_at > (select t from params) then 'not_yet_unlocked_rolling'
      else 'other_unexplained'
    end as reason
  from lost lo
  left join public.course_versions cv on cv.id = lo.course_version_id
  left join lateral (
    select ele.manual_release_state, ele.unlock_at, cvl.unlock_offset_days
    from public.enrollment_lesson_entitlements ele
    join public.lesson_revisions lr on lr.id = ele.lesson_revision_id
    join public.course_version_lessons cvl on cvl.course_version_id = lo.course_version_id and cvl.lesson_revision_id = ele.lesson_revision_id
    where ele.enrollment_id = lo.enrollment_id and lr.legacy_lesson_id = lo.lesson_id
    order by (ele.manual_release_state in ('held','revoked')), ele.unlock_at
    limit 1) best on true),
classed as (
  select c.*, case
      when reason in ('held','revoked','not_yet_unlocked_cohort','not_yet_unlocked_rolling') then 'INTENDED'
      when reason in ('no_entitlement_rows','entitlement_missing_for_lesson') then 'RECOVERED_BY_A'
      else 'BLOCKING' end as class
  from classified c)
```

Reason classes:

| Class | Reasons | Meaning |
|---|---|---|
| INTENDED (security effect, allowed) | `held`, `revoked`, `not_yet_unlocked_cohort`, `not_yet_unlocked_rolling` | The stored `unlock_at` equals anchor plus the current `course_version_lessons` offset, so the schedule is the owner's |
| RECOVERED_BY_A (allowed only when Q3 shows full recovery) | `no_entitlement_rows`, `entitlement_missing_for_lesson` | Migration A (backfill and trigger) restores the access |
| BLOCKING | `no_course_version`, `version_not_published`, `lesson_not_in_version` (includes NULL-link), `stale_unlock_at`, `completed_branch_only`, `other_unexplained` | A student would lose access they legitimately have today. `stale_unlock_at` is an automatic row whose `unlock_at` differs from `resolve_entitlement_anchor` plus the `course_version_lessons` offset, for example after an `enrollment_date` or cohort `starts_at` edit |

### Q2: reason breakdown for loses_access pairs

Append to the shared prefix.

```sql
select b.name as band, class, reason,
       count(distinct user_id) as students, count(distinct resource_id) as resources, count(*) as enrollment_resource_rows
from classed join public.bands b on b.id = classed.band_id
group by b.name, class, reason
order by class, reason, b.name;
```

### Q2-detail: non-intended pairs (for owner review; contains user ids)

Append to the shared prefix.

```sql
select class, reason, user_id, enrollment_id, band_id, count(distinct resource_id) as resources
from classed where class <> 'INTENDED'
group by class, reason, user_id, enrollment_id, band_id order by class, reason;
```

### Q3: gap simulation (simulates migration A, read-only)

Append to the shared prefix.

```sql
, sim as (
  select se.id as enrollment_id, se.user_id, cvl.lesson_revision_id,
         public.resolve_entitlement_anchor(se.id, se.course_version_id) + make_interval(days => cvl.unlock_offset_days) as unlock_at
  from public.student_enrollments se
  join public.course_versions cv on cv.id = se.course_version_id and cv.status = 'published'
  join public.course_version_lessons cvl on cvl.course_version_id = se.course_version_id
  where se.status in ('active','preserved') and cvl.prerequisite_lesson_revision_id is null
    and not exists (select 1 from public.enrollment_lesson_entitlements x
                    where x.enrollment_id = se.id and x.lesson_revision_id = cvl.lesson_revision_id)),
sim_visible as (
  select distinct s.user_id, r.id as resource_id
  from sim s join public.lesson_revisions lr on lr.id = s.lesson_revision_id
  join public.resources r on r.lesson_id = lr.legacy_lesson_id and r.resource_type <> 'pptx'
  where s.unlock_at <= (select t from params))
select
  (select count(*) from sim) as rows_to_insert,
  (select count(distinct enrollment_id) from sim) as enrollments_affected,
  (select count(*) from classed c where c.class = 'RECOVERED_BY_A'
     and exists (select 1 from sim_visible v where v.user_id = c.user_id and v.resource_id = c.resource_id)) as recovered_rows,
  (select count(*) from classed c where c.class = 'RECOVERED_BY_A'
     and not exists (select 1 from sim_visible v where v.user_id = c.user_id and v.resource_id = c.resource_id)) as recovered_by_a_but_still_lost,
  (select count(*) from classed c where c.class = 'BLOCKING') as blocking_rows,
  (select count(*) from classed c where c.class = 'BLOCKING') +
  (select count(*) from classed c where c.class = 'RECOVERED_BY_A'
     and not exists (select 1 from sim_visible v where v.user_id = c.user_id and v.resource_id = c.resource_id)) as blocking_pairs_after_A;
```

### Q4: inventory (standalone; each is its own SELECT)

```sql
-- Q4a enrollments by kind
select case when se.cohort_id is null then 'rolling' else 'cohort' end as kind,
       case when se.course_version_id is null then 'no_version'
            when public.is_legacy_mapped_version(se.course_version_id) then 'legacy_mapped' else 'authored' end as version_kind,
       count(*) as active_enrollments,
       count(*) filter (where not exists (select 1 from public.enrollment_lesson_entitlements e where e.enrollment_id = se.id)) as zero_row_enrollments
from public.student_enrollments se where se.status = 'active'
group by 1, 2 order by 1, 2;
-- Q4b entitlement rows by manual state for active enrollments
select ele.manual_release_state, count(*) from public.enrollment_lesson_entitlements ele
join public.student_enrollments se on se.id = ele.enrollment_id and se.status = 'active'
group by 1 order by 1;
-- Q4c NULL-link exposure (J-202-003)
select c.id as course_id, c.title, cv.id as course_version_id, cv.version_no,
       count(distinct cvl.lesson_revision_id) filter (where lr.legacy_lesson_id is null) as null_link_revisions,
       (select count(distinct se.user_id) from public.student_enrollments se
         where se.course_version_id = cv.id and se.status = 'active') as active_students
from public.courses c
join public.course_versions cv on cv.course_id = c.id and cv.status = 'published'
join public.course_version_lessons cvl on cvl.course_version_id = cv.id
join public.lesson_revisions lr on lr.id = cvl.lesson_revision_id
where c.legacy_band_id is not null
group by c.id, c.title, cv.id, cv.version_no
having count(*) filter (where lr.legacy_lesson_id is null) > 0;
-- Q4d null_link_active_students (threshold value)
select count(distinct se.user_id) as null_link_active_students
from public.student_enrollments se
join public.course_versions cv on cv.id = se.course_version_id
join public.courses c on c.id = cv.course_id and c.legacy_band_id is not null
where se.status = 'active'
  and exists (select 1 from public.course_version_lessons cvl join public.lesson_revisions lr on lr.id = cvl.lesson_revision_id
              where cvl.course_version_id = se.course_version_id and lr.legacy_lesson_id is null);
```

### Q5: R-b candidate list (read-only)

```sql
select cv.id as course_version_id, cvl.position, lr.id as lesson_revision_id, lr.title as revision_title,
       l.id as candidate_legacy_lesson_id, l.week_number, l.title as legacy_title
from public.course_versions cv
join public.courses c on c.id = cv.course_id and c.legacy_band_id is not null
join public.course_version_lessons cvl on cvl.course_version_id = cv.id
join public.lesson_revisions lr on lr.id = cvl.lesson_revision_id and lr.legacy_lesson_id is null
left join public.lessons l on l.band_id = c.legacy_band_id and l.week_number = cvl.position
where cv.status = 'published'
order by cv.id, cvl.position;
```

The candidate in Q5 is a suggestion only. Each pair needs the owner's written confirmation before repair R-b uses it.

### Threshold table (GO only if every row passes)

| Check | Required |
|---|---|
| Q3 `blocking_pairs_after_A` | 0 |
| Q3 `recovered_by_a_but_still_lost` | 0 |
| Q4d `null_link_active_students` | 0 |
| Q2 class INTENDED | No numeric threshold. The owner reviews the counts by reason before H3, and that review is recorded in the evidence |
| Q1 `gains_access` | Informational; reviewed |

If any GO row fails, the result is NO-GO. Run the repair (Step 5b), re-run Q1 to Q4, and repeat.

### Post-apply read-only verification (user)

1. `select policyname, roles, qual from pg_policies where policyname in ('students_read_unlocked_resources','students_read_unlocked_lesson_assets');` shows the helper calls and no `enrollment_date`.
2. `select has_function_privilege('anon','public.student_can_read_legacy_lesson(uuid)','execute'), has_function_privilege('authenticated','public.student_can_read_legacy_lesson(uuid)','execute');` returns `false, true`.
3. The Q4 zero-row-enrollment count is 0 for active enrollments with a published version.
4. The row count of `issue198_entitlement_backfill_log` equals Q3's `rows_to_insert` from the pre-apply run.
5. Re-run Q3 and confirm `rows_to_insert = 0` and `blocking_rows = 0`.

## 9. Acceptance and validation

### 9.1 RED tests

New files: `src/__tests__/issue198LegacyEntitlementRuleSql.test.ts` (a `pg` Client using `set_config('request.jwt.claims', ...)` and role `authenticated`, loopback-guarded) and `src/__tests__/issue198LegacyEntitlementStorageLive.test.ts` (real Storage API `createSignedUrl` with student sessions). Each case asserts both the `resources` select and the storage signed URL. Show each failing before and passing after.

| Id | Case | Expected |
|---|---|---|
| T1 | Enrolled before cohort start: cohort `starts_at` now()+14d, `enrollment_date` now()-30d, materialized | Week 1 (offset 0) denied (legacy allowed) |
| T2 | Late joiner: cohort `starts_at` now()-60d, enrolled now() | Week with offset 14 allowed (legacy denied) |
| T3 | Held: rolling enrollment, unlocked week set to held through `set_lesson_access_state` (`202608290001:43`) | Denied |
| T4 | Revoked: same as T3 with revoked | Denied |
| T5 | Cadence change: entitlement `unlock_at` moved later through the real reconciliation path (`apply_enrollment_reconciliation` after a published version with changed offsets), or, if no real path reaches a legacy version, a superuser update labelled as simulation | Visibility follows `unlock_at`, not `lessons.unlock_offset_days` |
| T6 | Rolling enrollment through `assign_band_enrollment`: unlocked week allowed, future week denied (parity, green before and after); `released` state with future `unlock_at` | Parity cases pass; `released` allowed (RED, D-198-1) |
| T7 | Owner unaffected: owner reads pptx through `owner_read_instructor_decks` and the deck object; `owner_select_lesson_assets` version-path read unchanged; `get_owner_resource_text` Edge still returns vocabulary text; owner gets no non-pptx rows through the student policy | Unchanged |
| T8 | Zero-row enrollment | Denied before migration A data, allowed after the backfill; backfill is idempotent (second run inserts 0) and never changes existing `unlock_at` or manual state |
| T9 | New legacy lesson inserted after enrollment | Amended trigger creates the entitlement; visible per schedule |
| T10 | NULL-link: enrollment on a version whose revision has `legacy_lesson_id` null | No resources for that lesson (documented fail-closed); a #202-preserved revision (`revision_no` 2, link kept) stays visible |
| T11 | Entitled student requests a pptx | Denied |
| T12 | Forced password change, inactive account, preserved enrollment, anon | Denied |
| T13 | Completed enrollment (D-198-2 option A) | Without repair R-d, denied for future-unlock lessons. After R-d, allowed. Held and revoked stay denied in both cases |
| T14 | Catalog: `pg_policies.qual` references the helpers and not `enrollment_date`; helpers have `prosecdef` true, `proconfig` `search_path=public`, EXECUTE for `authenticated` only | Pass |
| T15 | Performance: `EXPLAIN (ANALYZE, BUFFERS)` as a student for the `fetchResourcesForLesson` query and a 26-lesson IN query, plus one `createSignedUrl`; record plans | Each under 50 ms on the seeded local stack |
| T16 | Rollback parity: apply rollback B, then the legacy-rule tests pass again and policy text equals `202610050005`; apply rollback A, then trigger body equals `202610030001`, the new trigger and function are gone, and progress rows survive | Pass |
| T17 | Rollback A keeps progress: after the backfill, (a) open a lesson (`record_lesson_progress` 'open', so `first_opened_at` is set with no completion), (b) create a task draft or submission on another backfilled lesson, (c) record a quiz attempt on a third; run rollback A | All three rows remain; untouched backfilled rows are deleted; the notice reports the kept count |
| T18 | Trigger `student_enrollments_ensure_entitlements` (in the issue198 SQL test file): (a) a superuser direct insert of an active band enrollment; (b) update from preserved to active with zero rows; (c) insert with status preserved; (d) a course with an unmet `prerequisite_version_id`; (e) existing rows after an `UPDATE OF status`; (f) `assign_band_enrollment`, `enroll_cohort_member`, `request_cohort_enrollment` and `resume_band_enrollment`; (g) `apply_version_migration` | (a) gets entitlement rows and can read its unlocked week's resources and object; (b) materializes; (c) creates no rows; (d) creates no rows and is denied; (e) `unlock_at`, `manual_release_state` and `completed_at` byte-identical; (f) each produces rows identical to before the trigger (same count and `unlock_at`); (g) results unchanged |
| T19 | Repair script (Step 5b) on a constructed BLOCKING fixture: dry-run default ends in rollback and changes nothing; a real run applies R-a to R-d; the preview then shows `blocking_pairs_after_A = 0`; repair rollback restores the logged values; R-b touches only owner-listed pairs | Pass |

### 9.2 Full gates

Per parent 11.1 and 11.2: `npm ci`, type-check, lint with 0 errors, `verify:build`, full vitest on a fresh reset with no new failures versus the baseline, and targeted e2e (`wp10-roadmap-week-flashcards`, `issue175-vocabulary-review`, the issue174 suite, `wp11-learn`). Verifier PASS. CODE_REVIEW per section 5. Browser Validator PASS on the regression journeys in section 10.

## 10. Browser UI dialog policy and browser validation

### 10.1 Dialog policy

This applies as a regression check only, because there are no UI code changes. No `alert`, `confirm`, `prompt`, `window.*` variants, or `beforeunload`. Only the app-owned accessible Modal (`src/components/Modal.tsx`) is used. Run the parent 11.5 scan and expect zero product hits:

```text
rg -n "\b(window\.)?(alert|confirm|prompt)\s*\(|beforeunload" src --glob "!src/__tests__/**"
```

Attach a failing `page.on('dialog')` listener in each journey. No modal is touched, so modal keyboard and focus checks are not required beyond the listener.

### 10.2 `browser_ui_validation`

- Launch and readiness, in the port-shifted mirror per parent 12.2:

```text
npx supabase start
npx supabase db reset
docker restart supabase_kong_lizbeth_spanish supabase_rest_lizbeth_spanish supabase_edge_runtime_lizbeth_spanish   (first request may 502)
npx vite --port 5180 --strictPort
```

  Ready when `http://localhost:5180` serves sign-in.
- Base URL: `http://localhost:5180`.
- Fixture and reset: `db reset` plus seed (accounts `owner@test.local`, `student1@test.local`, `fullaccess@test.local`, password `password`). The held-week fixture is created per journey through the owner `set_lesson_access_state` path (or a loopback-guarded SQL helper) and reverted after.
- Viewports: 1440x900 and 390x844.
- Screenshots under `browser-validation-artifacts/198/`.

### 10.3 Journeys and visible outcomes

| Id | Journey | Visible outcome |
|---|---|---|
| J1 | student1 on `/roadmap`, an unlocked Beginner week | Files list renders; the PDF download link opens a PDF; flashcards open; weekly vocabulary review text loads |
| J2 | student1, a future week | Locked state with the unlock date |
| J3 | Owner holds an unlocked student1 week; student1 reloads it | No files and no download link; `/learn` shows that lesson as paused with no materials. Record the interim copy ("No resources published for this week yet.") as the known 5c-2 limitation |
| J4 | fullaccess, all weeks of all three bands (after the D-198-6 seed change) | All weeks show files |
| J5 | student1, `/learn` legacy course materials | Unchanged for unlocked lessons |
| J6 | Owner: admin vocabulary review through the owner loader | Loads; owner still sees instructor decks where shown |

## 11. Risks and rollback

| Id | Risk | Containment |
|---|---|---|
| R198-1 | Legitimate access lost (zero-row enrollments, new lessons, NULL-link revisions, stale `unlock_at`, missing or unpublished version, completed students) | Migration A backfill and trigger recover the RECOVERED_BY_A class. Anything BLOCKING makes H2 a hard NO-GO until the Step 5b repair is applied under its own approval and the preview is re-run to zero (D-198-7). The owner cannot accept the loss. Rollback B restores prior access immediately |
| R198-2 | Students see content disappear for an intended reason (held, revoked, pre-cohort-start, cadence) | Intended security effect; Q2 INTENDED counts are reviewed by the owner and recorded before H3; roadmap copy mismatch until 5c-2 |
| R198-10 | Repair script is a data write on hosted | Not a migration; dry-run default ending in `rollback`; every change logged in `issue198_repair_log`; matching rollback script; only widens or preserves access; own explicit approval; R-b only with owner-confirmed pairs; local RED/GREEN test T19 |
| R198-3 | RLS performance on resource lists and storage signing | Definer helper, new `lesson_revision_id` index, T15 EXPLAIN gate |
| R198-4 | Definer helper misuse or oracle | Boolean only, `auth.uid()`-bound, EXECUTE for `authenticated` only, #222 allowlist test |
| R198-5 | Policy recursion or stacked RLS | Definer helpers; no cross-referencing policies; T14 |
| R198-6 | Already-minted signed URLs stay valid up to TTL (Inference) | Accept; at most 1 hour; note in rollout |
| R198-7 | Ordering with open PRs (#237, #250, #251) and migration prefixes | Step 0 checks; hosted migration history must contain `202610120001` to `202610120003` before 5c's files (`db push` applies pending migrations in timestamp order); any earlier pending migration needs its own approval first |
| R198-8 | Seed and test fallout (fullaccess unmaterialized, direct inserts) | D-198-6; tests updated, never weakened |
| R198-9 | Backfill rollback could erase progress | Rollback deletes only logged rows that are `automatic`, not completed, and have no `student_lesson_progress`, `lesson_task_submissions`, `quiz_attempts` or other activity row (Step 0 FK catalog); T17 |
| R198-11 | New ensure-entitlements trigger changes direct-insert behavior in tests and seed | T18 parity cases; acts only on zero rows; affected tests reviewed with explicit reasons, never weakened |

Rollback: apply `supabase/rollbacks/issue198_legacy_entitlement_rule_rollback.sql` (restores the `202610050005` policies; immediate effect on new requests). Optionally apply `issue198_legacy_entitlement_backfill_rollback.sql`, and, if the repair was run, `scripts/repair/issue198-access-preserving-repair-rollback.sql`. Each is separately approved. No Netlify or Edge rollback is needed.

## 12. Hosted rollout order

Each hosted step is a separate explicit approval. The user runs all hosted SQL.

| Step | Action |
|---|---|
| H0 | PR #251 merged; `202610120003` applied and the `map_lesson` Edge change deployed (their own approvals); PRs #237 and #250 migrations applied or explicitly sequenced |
| H1 | PR 5c-1 merged by the user |
| H2 | The user runs `scripts/audit/issue198-impact-preview.sql` (read-only) on hosted. The orchestrator records the output in `docs/evidence/lizbeth-spanish-prod-issue198-preview-<date>.md` (Scribe) |
| H2b | Only if H2 is a NO-GO: the user runs `scripts/repair/issue198-access-preserving-repair.sql` (dry-run first, then a real run) under its own explicit approval, with R-b only for owner-confirmed pairs. Then re-run the preview (Q1 to Q4) and repeat H2 |
| H3 | Approval, only after H2 is GO, then apply migrations A and B together (`supabase db push` applies both in order) |
| H4 | Post-apply read-only verification queries (section 8, including the Q3 re-run), plus the owner or a test student smoke of J1 and J3 on production if a test account exists (Unknown) |
| H5 | Evidence record; close #198 only after H4 |

H2 is a hard NO-GO while any active student would lose access they legitimately have today, unless a repair has been applied first and the preview has been re-run. The owner cannot "accept the loss". GO requires every row of the section 8 threshold table to pass:

- Q3 `blocking_pairs_after_A = 0` and `recovered_by_a_but_still_lost = 0`. Every `loses_access` pair is then INTENDED or fully recovered by migration A.
- Q4d `null_link_active_students = 0`.
- The owner has reviewed the INTENDED counts by reason and the `gains_access` list, and that review is recorded in the evidence.

## 13. Decisions

Each requires an explicit user answer. None carries a silent default.

| Id | Decision | Recommendation |
|---|---|---|
| D-198-1 | Predicate form: include the `released` early-unlock (`state not in held/revoked and (state = 'released' or unlock_at <= now())`), matching `get_student_lesson_assets`, lesson tasks, quizzes and `isMaterialsEligible`, or follow the literal D-15 wording (`unlock_at <= now()` only) | Include `released`. Otherwise `/learn` marks a released lesson eligible while RLS returns nothing |
| D-198-2 | Completed-enrollment branch. Drop the completion branch (strict canonical; held and revoked still deny after completion, consistent with `learnMaterials.ts:20-21`, which deliberately avoids `completed_at` priority). The former option B, a narrowed `se.completed_at` branch in the policy, is removed: the binding invariant in `202608300002` and `202610030001:13-14` ("no completion gate may read the `student_enrollments.completed_at` cache") forbids it, and `has_completed_course_version` is plpgsql and too heavy to run per row. Completed students who would lose access are handled by repair R-d (Step 5b), not by a policy branch | Drop the branch (option A) |
| D-198-3 | Ship the insert-only gap backfill (migration A) in this PR | Yes (idempotent; no-op if no gaps) |
| D-198-4 | Amend `lessons_map_legacy_revision` to create entitlements for existing enrollments | Yes. Otherwise every newly provisioned legacy week is invisible on `/roadmap` and `/learn` |
| D-198-5 | Roadmap UI alignment as follow-up PR 5c-2 with its own sub-plan and design route after 5c-1, not bundled | Yes; prioritise by the preview counts |
| D-198-6 | Local seed materializes every active seeded enrollment (including fullaccess). The new `student_enrollments_ensure_entitlements` trigger does this automatically once `backfill_legacy_courses()` sets `course_version_id`, so this is partly satisfied by the trigger. An active, zero-row legacy enrollment is then unreachable except when the prerequisite is unmet or the version is unpublished, so the `wp11` legacy-materialization test moves to a prerequisite-unmet or unpublished-version fixture, or documents that the branch is dead for legacy courses. Tests that insert directly and assert zero rows or exact counts are reviewed and updated with an explicit reason, never weakened | Yes |
| D-198-7 | Do not apply B while any active student is in the BLOCKING class. If the preview shows BLOCKING > 0, run the access-preserving repair (sections R-a to R-d as needed; R-b only with the owner's written pair confirmation) under its own approval, re-run the preview, and proceed only at zero | As stated |
| D-198-8 | Apply A and B in one hosted push after the preview, or in two separate pushes | One push (Q3 already simulates A read-only) |

## 14. Assumptions

Safe assumptions:

- Legacy lessons have no prerequisites (Inference; the T-tests confirm).
- The hosted #176 backfill materialized existing enrollments (verified by Q4).
- Signed URL TTL semantics (Inference).

Unknowns: whether a production test student account exists for the H4 smoke; the hosted exposure to NULL-link and other BLOCKING classes (answered by Q2 to Q4); whether the UI exposes `map_lesson` for legacy revisions (Step 0 check).

## 15. Stale-plan conditions

This sub-plan is stale and must be re-planned (or re-verified at Step 0) if any of these occur:

- PR #251 changes its migration or is abandoned.
- Any cited function or policy changes on main.
- The preview shows a loss reason that is not in Q2's list.
- PR #231 or another PR adds an enrollment path that does not materialize.
- The Step 0 foreign-key catalog finds an activity table not covered by the rollback predicate.
- `has_completed_course_version`, `grant_enrollment_entitlements_with_prerequisites`, or `save_outline` identity handling changes.

## 16. Approvals required

1. Explicit approval of this sub-plan (parent section 17 item 5).
2. Answers to D-198-1 to D-198-8.
3. Separate approvals for each hosted step (H0, H2b repair, H3, any rollback), and the owner's written pair confirmation for any R-b repair.
4. No commit to main, merge, deploy, or live Codex call without explicit instruction.

## 17. Engineering mode and downstream owner

- Engineering mode: standard (T1 first-line, T2 escalation per fleet rules: two counted T1 gate failures escalate to T2; two counted T2 gate failures block for user review). No extreme-advisory team. Team authorization: not applicable.
- Downstream owner: engineering-fleet (PR 5c-1); Scribe for the preview and rollout evidence records; the orchestrator relays hosted queries to the user.
