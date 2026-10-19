# Lizbeth Spanish: publish RLS and cohort enrollment, corrected

Status: **Approved.** See the Approval section below for the recorded approval.

Plan ID: `lizbeth-spanish-publish-rls-and-cohort-enrollment-corrected`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: `engineering-fleet`, after explicit user approval of this plan
Roadmap: not part of the Issue #5 five-phase roadmap (`docs/plans/lizbeth-spanish-issue5-roadmap.md`). This is a corrected, narrower re-issue of the independent defect-remediation plan superseded by this document.
Related plan (blocked consumer of this fix): `docs/plans/lizbeth-spanish-issue5-phase3-owner-enforcement-controls.md`. Phase 3's browser validation cannot exercise the roster/reconciliation/entitlement UI it already built without a real enrolled student, and no student can currently be enrolled into a cohort-based course through any UI. This plan exists to unblock that validation.
Supersedes: `docs/plans/lizbeth-spanish-publish-and-cohort-enrollment-fixes.md`, approved 2026-08-30 and superseded the same day. See "What changed from the superseded plan" below.
Design route: compact. `design-generalist` and `design-reviewer`. Prototype forbidden. Model tier: sonnet. Existing-system mode: preserve. See the design section below.

Note on file locations: this plan document lives in the orchestrator repository's `docs/plans/` directory, alongside its sibling Issue #5 phase plans, per this engagement's established convention. All source-file references below (for example `src/services/courseAuthoring.ts`) are paths relative to the target repository root stated above, `H:\CommandCenter\orchestrator\lizbeth_spanish`, matching the convention already used by the sibling Phase 2 and Phase 3 plans.

## Blocking prerequisites

None block the start of this plan. This plan itself is a blocking prerequisite for Phase 3's Browser Validator pass, which requires a real enrolled cohort student to exercise the roster, reconciliation, and entitlement UI Phase 3 already built. Until this plan ships, Phase 3 cannot be validated end to end.

## What changed from the superseded plan

This section is the point of this document. Read it before reading anything else below.

The prior plan (`lizbeth-spanish-publish-and-cohort-enrollment-fixes.md`) was approved by the user on 2026-08-30. Before implementation began, Phase 3's engineering work landed changes in the same files the prior plan targeted, and T2 returned `JOB_BLOCKED "Plan stale"` rather than execute against outdated line numbers. Planner then independently re-verified every factual claim in the prior plan against current repository state, rather than assuming the prior plan's staleness was cosmetic (line-number drift only).

**Finding: the prior plan's entire "Defect 1B: systemic courseId/versionId parameter confusion" no longer exists and must NOT be implemented.** The causal theory behind that defect — that a course id was being passed where call sites required a version id — is falsified against current code:

- `CourseWorkspacePage.tsx:70` now passes `courseId={course.id}` to both `<Publishing>` and `<Students>`. `course.id` IS the version id (`getCourse()` returns the version object, with `course_id` as the separate course-id field). `uploadGeneratedAsset`, `stagePublish`, and `createCohort` therefore already receive a correct version id at these call sites.
- Cohort creation genuinely works today. `CohortForm` receives the version id through the `Students` prop chain described above. T2 additionally reported finding a real cohort, "QA Cohort C", in the live database with a valid foreign key. **This is second-hand from T2** — Planner is read-only and cannot query the database — and must be independently re-confirmed as the first step of this plan's Track B work (see Track B, step B1), not assumed true.
- `<StudentRoster courseVersionId={courseId}>` at `CourseWorkspacePage.tsx:402` is correct: inside the `Students` component, `courseId` is already `course.id`, the version id.
- `listPublishJobs(courseId)` is moot regardless of which id is passed. The `list_publish_jobs` handler (`supabase/functions/course-authoring/index.ts:129-131`) ignores any id argument entirely and filters only by `requested_by`. The `Publishing` component then narrows the result client-side by `row.id === job.id`, so behavior is correct independent of the id-confusion question.
- `list_cohorts` (`index.ts:133-135`) is still unscoped by course server-side, but `CourseWorkspacePage.tsx:68` already compensates with a client-side filter: `const courseCohorts = cohorts.filter(c => c.course_version_id === course?.id)`. That filtered value, not the raw unscoped list, is what both the Students and Outline tabs consume. The prior plan never saw this filter and proposed fixing the wrong layer.

**Still true and unaffected by the above:** the storage RLS gap (no INSERT/UPDATE/DELETE policy on `storage.objects` for `lesson-assets`), the missing cohort invite UI, and the public-catalog `requestEnrollment` parameter/error-swallowing defect. These three problems are real, independently verified against current code, and are this plan's actual scope.

**Net effect: total scope is smaller than the prior plan.** An entire defect category (1B) is removed. One new finding narrowed the catalog fix to a server-side resolution (see Track B below, and the settled decision in Assumptions and decisions).

**Consequence for the implementer.** The prior plan's publish-flow and cohort-creation "correct id reaches the call site" tests are now vacuous: current code already passes them without any change. Do not write them as if they were expected to fail (RED). Writing a RED test for already-correct behavior would either fail to go red (revealing the mistake) or, worse, be quietly weakened until it does go red, reintroducing a working code path's breakage. See Track B step B1 and Risk R4 below.

## Outcome and audience

Unblock course publishing, which currently fails with "Could not upload course.pdf.", and give an owner a working path to enroll a student into a cohort. Audience is the engineering fleet implementing this plan and the user approving it. The operational purpose is unblocking Phase 3's browser validation, which needs a real enrolled cohort student to exercise UI Phase 3 already built.

## Scope and non-goals

**In scope, three bounded, independent tracks:**

- **Track A.** A storage RLS migration granting INSERT, UPDATE, and DELETE on `storage.objects` for the `lesson-assets` bucket, owner-scoped.
- **Track B.** A cohort member list and invite UI inside the existing "Cohorts and enrollment" panel, plus the `PublicCatalogPage` `requestEnrollment` error-handling fix.
- **Track C.** Dead-code cleanup and one documented no-op decision.

**Non-goals:**

- A cohort-management redesign.
- Member removal/revocation, cohort edit/delete, bulk invite, role assignment, cohort-detail routing, resend-invite, member list search/filter/sort/pagination.
- Any change to the legacy band-assignment enrollment system in `AdminStudentsPage`. It works today and stays untouched.
- Broadening or altering any existing student-facing SELECT RLS policy.
- Phase 4 concerns (hard re-lock/`revoked`).
- A full self-service catalog enrollment product flow.
- No commit, push, PR, or deploy.

## Verified repository findings

All findings below were verified directly against current repository state during planning; the staleness finding above additionally strengthens, rather than weakens, the confidence in these findings, since they were re-checked after the prior plan's staleness was discovered.

### Track A: missing storage write policy

Exactly one policy exists on `storage.objects` for `lesson-assets`: `students_read_unlocked_lesson_assets`, SELECT only.

- Created at `supabase/migrations/202607170005_storage_gating_policy.sql:23-35`.
- Recreated (same policy) at `supabase/migrations/202607200002_admin_student_rls_hardening.sql:59-72`.
- Recreated again, adding a force-password-change check, at `supabase/migrations/202608070001_force_password_change_rls_enforcement.sql:87-104`.
- `supabase/migrations/202607170003_storage_setup.sql` is documentation only and creates no policy.

There is zero INSERT/UPDATE/DELETE/ALL policy on `storage.objects` anywhere in the repository. All existing policies gate through `public.resources` joined to legacy `student_enrollments.band_id`, a student-read path that structurally cannot authorize an owner writing a newly generated publish artifact, because that `resources` row does not and cannot exist at upload time.

**Critical ordering constraint the implementer must not miss.** `uploadGeneratedAsset` (`src/services/courseAuthoring.ts:86`) uploads to storage FIRST and only then calls the `register_asset` action, which inserts the `course_assets` row. The new policy therefore CANNOT be scoped by joining to `course_assets`, because that row does not exist at the moment the INSERT is evaluated. This is the central design constraint of the fix.

**Correct scoping basis, strengthened by the staleness finding.** The storage path is constructed as `${versionId}/generated/${name}` (`uploadGeneratedAsset`, line 86) and `${versionId}/${uuid}-${sanitizedFileName}` (`uploadCourseAsset`, line 77). The staleness investigation confirmed the id passed into these functions is genuinely a version id (see "What changed" above), so the first path segment reliably resolves: first path segment → `public.course_versions.id` → `course_versions.course_id` → `public.courses.owner_id = auth.uid()`. The Edge Function already uses exactly this ownership chain server-side — see `ownedVersion`/`ownedCourse` in `supabase/functions/course-authoring/index.ts:44-64` — so the new policy mirrors an already-established, already-trusted authorization rule.

**Three verbs are required, not one.**

- INSERT: the upload itself.
- UPDATE: `uploadGeneratedAsset` calls `.upload(..., { upsert: true })` (line 86), which requires UPDATE on an existing object.
- DELETE: both `uploadCourseAsset` (line 77) and `uploadGeneratedAsset` (line 86) call `.storage.from('lesson-assets').remove([path])` in their rollback/catch path when `register_asset` fails. Without DELETE the rollback silently fails and orphans the object. Fixing only INSERT produces a flow that appears to work in the happy path but silently orphans objects on rollback.

### Track B: no cohort enrollment UI

- `inviteToCohort` (`courseAuthoring.ts:68`) has zero UI callers anywhere in the app, confirmed by a repository-wide search.
- Cohorts still render only as the literal `<p>{cohorts.length} cohort(s)</p>` (`CourseWorkspacePage.tsx:401`), confirmed still unbuilt after the Phase 3 changes.
- `list_members` already exists server-side (`index.ts:137-143`), owner-scoped, but is not exposed to the client.
- `getRoster()` already exists (`src/services/adminStudentData.ts:384-401`).
- The `invite` handler (`index.ts:360-365`) upserts on the `(cohort_id, user_id)` conflict and short-circuits to a success response returning the existing row when `status === 'active'`, so the client can distinguish a fresh invite from an already-active member from the response alone.

### Track B: catalog `requestEnrollment` defect

- `PublicCatalogPage.tsx:42` calls `requestEnrollment(course.id)`; `course` comes from `getCoursePreview`, whose `id` field is a course VERSION id, but `request_cohort_enrollment` requires `p_cohort_id`. The call can never succeed.
- The bare `catch` at lines 44-46 swallows every failure into the single message "Sign in to request enrollment.", so a signed-in user whose call fails for any other reason is told to sign in.

**New finding, missed by T2's staleness report, and it blocks the prior plan's prescribed catalog fix.** The prior plan instructed the implementer to "resolve an actually-eligible cohort for the previewed version and pass its id." That instruction is NOT implementable from the client as the schema currently stands:

- `public.cohorts` has RLS enabled (`supabase/migrations/202608280003_issue5_course_authoring.sql:510`) with NO policy granting any authenticated read. The only cohort-adjacent policies are `cohort_members_own` on `cohort_memberships` and `requests_own` on `enrollment_requests` (lines 524-525).
- The public catalog/preview actions (`index.ts:15-22`) expose `course_catalog` and `course_preview_lessons` only; neither returns a cohort id.
- The Edge Function's `list_cohorts` action is owner-scoped, not available to a student.

A student therefore has no client-side path to obtain a cohort id for the previewed version today. `request_cohort_enrollment` (`supabase/migrations/202608300002_issue5_phase3_enforcement_sql_core.sql:570-600`) is `SECURITY DEFINER` and validates `enrollment_mode in ('request','open')` internally, so the validation logic already exists server-side; it is simply not reachable from a client that cannot obtain the cohort id. **This is now resolved.** Rather than exposing cohort ids to the client (which the RLS gap above shows was never viable), the remedy moves cohort resolution server-side: a new `SECURITY DEFINER` function resolves the eligible cohort inside the same trust boundary that already validates enrollment mode, so the client keeps passing the course version id it already has and never needs to see a cohort id at all. See Track B step B8 and the settled decision in Assumptions and decisions below.

### Track C: dead code

`publishCourse` (`courseAuthoring.ts:123`) and `inviteToCourse` (line 124) have zero callers anywhere in `src/`, confirmed by a repository-wide search. `publishCourse` is additionally a latent trap: it forwards its `courseId` argument straight into `stagePublish`, which requires a version id, so any future caller written by name-matching alone would reintroduce a version of the falsified Defect 1B. `src/__tests__/courseAuthoringUi.test.tsx:8` matches one of these names in an import/mock line; the implementer must check and update that test before deleting either function.

### Research evidence

None. No external or current-fact evidence was needed. Every finding is local and verified directly against the repository.

## Design route and handoff

**Compact.** Reasons: this is a bounded brownfield addition to one existing panel ("Cohorts and enrollment") in an established workspace; no new screen, no new visual language, no new flow direction; the existing design system is preserved and authoritative. `design-generalist` and `design-reviewer` only. Prototype forbidden. Model tier sonnet. Existing-system mode preserve.

**Design review: PASS.** The reviewer independently verified the packet against current code and confirmed that `list_members` and `getRoster()` both genuinely already exist (no new backend read action is being smuggled in as a UI requirement), and confirmed the invite short-circuit behavior (fresh invite vs. already-active member, distinguished by the response's `status` field) is correctly characterized.

**Three non-blocking notes the reviewer recorded, carried forward for the implementer:**

1. The invite picker's roster-load failure is specified below as advisory (`role="status"`) by analogy to `PrerequisiteField`'s existing pattern, but a roster-load failure actually blocks the invite entirely (there is nobody to invite). `role="alert"` would be an equally defensible choice for that specific state. Left to implementer discretion; either choice is acceptable and should be noted in the implementation.
2. The cohort list's loading and error states are visually indistinguishable from a genuine "0 cohorts" state, because `reloadCohorts` swallows any fetch failure to `[]` (`CourseWorkspacePage.tsx:35`). This is a preexisting condition shared with the `Outline` tab, legitimately out of scope for this plan, and worth a follow-up ticket.
3. Some existing reused CSS classes contain raw px literals. These are inherited from the existing design system, not introduced by this change; a token-purity scan flagging them against this diff would be a false positive.

### Design handoff (compact, passed)

**Placement.** Inside the existing `.workspace-panel` "Cohorts and enrollment" (`Students` component, `CourseWorkspacePage.tsx` ~378-404). Order top to bottom: `<h2>` → existing panel feedback line → NEW cohort list (replacing the bare count at line 401) → existing enrollment-requests list (unchanged) → `CohortForm` (unchanged, stays last).

**Cohort row.** One-line summary: `{name} · {enrollment mode label} · {start/end dates via the existing formatShortDate helper}`, plus a "Manage members" toggle styled as `.roster-student-toggle`. Enrollment-mode labels reuse `CohortForm`'s existing `<option>` text verbatim: `invite_only` → "Invite only", `request` → "Request approval", `open` → "Open enrollment".

**Disclosure.** `<button aria-expanded aria-controls>` toggling `<div role="region" aria-label="{cohort.name} members">`, identical in shape to `StudentRoster`'s per-student disclosure. Focus stays on the toggle just activated; nothing calls `.focus()` on expand or collapse.

**Member row.** `{displayName} — {"Invited" | "Active"}`. Status is conveyed by visible text, never color alone. Rows with `status === 'removed'` are filtered client-side, because `list_members` has no status filter server-side.

**Invite control.** `<select aria-label="Student to invite to {cohort.name}">` with a "Select a student…" placeholder option, listing eligible roster students by email, plus an "Invite" button. Eligible means: a roster row not already an active or invited member of this cohort.

**Cohort list states.** Empty (0 cohorts): nothing renders above `CohortForm` beyond the existing feedback line. Populated: renders the `<ul>`.

**Member list states.** Loading: `<p role="status">Loading members…</p>`. Error: `<p role="alert" className="schedule-severity-error">` plus a "Try again" button. Empty: plain `<p>No members yet.</p>` with no role. Populated: `<ul>`.

**Invite picker states.** Loading: `<p role="status">Loading students…</p>` with no submit button rendered. Roster-load error: `<p role="status" className="schedule-severity-advisory">Students could not be loaded right now. Try again shortly.</p>` (see reviewer note 1 above; `role="alert"` is an acceptable alternative). Empty directory: plain `<p>No students available to invite.</p>`. Blocked submit: the submit button is `disabled aria-disabled` when nothing is selected; there is no separate inline error, because the disabled state itself communicates the block. Submitting: button reads "Inviting…", disabled, no double-submit possible.

**Success branch A, fresh invite (response `status === 'invited'`).** `<p role="status">{email} invited to {cohort.name}.</p>`, and that cohort's member list refreshes.

**Success branch B, already-active member (response `status === 'active'`).** Distinct copy: `<p role="status">{email} is already an active member of {cohort.name}.</p>`. No list refresh.

**Failure.** `<p role="alert" className="schedule-severity-error">` with the thrown message, fallback "Could not send the invite." Selection is preserved for retry.

**Lazy loading.** Member and roster fetches fire on a cohort's first expand, not on `Students` mount. Cache per cohort so re-collapsing does not refetch.

**No modal.** Reasoned from codebase precedent: `Modal` is reserved for irreversible actions (`ModeSwitchModal`; the lesson-release confirmation in `StudentRoster`), while non-destructive submits (cohort creation, enrollment approve/decline) use inline feedback. An invite creates a pending row and grants no entitlements. Acknowledged tension, carried from the prior plan and unchanged: as shipped, an invite has no undo path, because no `remove_member` action exists and adding one is a stated non-goal.

**Visual system.** Preserve mode: no new tokens, no new hex/px literals in any NEW class. Reuse `.workspace-panel`, `.demo-button` variants, `.schedule-severity-error`/`.schedule-severity-advisory`, `.roster-student-toggle`, `.roster-lesson-list`/`.roster-lesson-row`. Feedback uses only `role="alert"`/`.schedule-severity-error` and `role="status"`/`.schedule-severity-advisory`; no toast, snackbar, or banner.

### Design engineering invariants (carry into implementation verbatim in substance)

1. Add `'list_members'` to the `ReadAction` union (`courseAuthoring.ts:7`) and export a `listMembers(cohortId)` wrapper via the existing `readAuthoring` helper. Add server-side display-name resolution to the existing `list_members` handler, mirroring the `list_enrollment_requests` precedent exactly (`index.ts:153-160`: `db.auth.admin.getUserById` per row, coalescing full name → email → 'Student') so the client never renders a raw `user_id`. Do NOT create a duplicate `list_cohort_members` action.
2. Do NOT add a server-side status filter to `list_members`; filter `removed` rows client-side.
3. Reuse `inviteToCohort` unchanged.
4. No native browser dialogs anywhere: no `alert`, `confirm`, `prompt`, no `window.*` forms, no `beforeunload`.

## Interfaces and data

- New additive-only migration: INSERT, UPDATE, and DELETE policies on `storage.objects` for `bucket_id = 'lesson-assets'`, owner-scoped via first-path-segment → `course_versions` → `courses.owner_id`, with a guarded uuid cast. Reversible by dropping the three new policies. Must not drop, alter, or weaken `students_read_unlocked_lesson_assets` or any other existing policy. Follow the existing migration date-naming convention.
- Client: add `'list_members'` to the `ReadAction` union and a `listMembers(cohortId)` wrapper in `courseAuthoring.ts`. Remove `publishCourse` and `inviteToCourse` (Track C).
- Server: add display-name resolution to the existing `list_members` handler in `supabase/functions/course-authoring/index.ts`. No other Edge Function change.
- No schema change, no data migration.

## Ordered work

TDD is mandatory throughout: no production code before a failing test exists for it. Tracks A, B, and C are independent and may proceed in any order, but each track's RED step precedes its own implementation.

### Track A — storage RLS write policies (owner: T2, security-sensitive)

- **A1. RED.** Reproduce the denial directly: an authenticated owner attempts an INSERT into `lesson-assets` at an owned `${versionId}/...` path and is denied by RLS. Capture the denial. Then write the failing positive RLS test and the four failing negative RLS tests (see Acceptance and validation) before any migration exists.
- **A2.** Write a new additive-only migration granting INSERT, UPDATE, and DELETE on `storage.objects` for `bucket_id = 'lesson-assets'`, scoped through first-path-segment → `course_versions` → `courses.owner_id = auth.uid()`. Guard the uuid cast so a non-uuid first segment fails closed rather than raising inside policy evaluation; state the chosen guard approach explicitly in a migration comment. Follow the existing migration date-naming convention. Must not drop, alter, or weaken `students_read_unlocked_lesson_assets` or any other existing policy.
- **A3.** Decide and document in the migration comment whether to additionally require `course_versions.status = 'draft'`. Publish staging happens while the version is still draft, so an overly strict predicate would re-break publishing. The approved default is NOT to add the constraint unless implementation finds a concrete reason, which must then be documented at the point of implementation.
- **A4.** Turn all Track A tests green and prove the existing student SELECT gating still denies a locked/unentitled path exactly as before.
- **A5. GREEN, live.** Run a real course publish end to end against a running Supabase instance; both artifacts upload and a publish job stages, with no "Could not upload course.pdf." failure.

### Track B — cohort invite UI and catalog fix (owner: T2 for the backend additions, T1 for UI; depends on nothing in Track A)

- **B1. RED, hard staleness gate.** Confirm no reachable UI path invokes `inviteToCohort`; confirm `CourseWorkspacePage.tsx:401` still renders only the bare cohort count; confirm live `cohort_memberships` count is 0. **Also independently re-confirm T2's second-hand claim** that cohort creation works and a real cohort exists: create a cohort through the existing `CohortForm` against a live instance and confirm the row persists with a valid foreign key. If it does NOT persist correctly, stop and return `JOB_BLOCKED "Plan stale"`, because this plan's central staleness finding (that Defect 1B no longer exists) would itself be wrong, and Track A/B work built on that assumption would need re-planning.
- **B2. Backend, T2.** Add `'list_members'` to the `ReadAction` union and the `listMembers(cohortId)` client wrapper; add display-name resolution to the existing `list_members` handler following the `list_enrollment_requests` precedent exactly. Failing tests first.
- **B3. UI, T1.** Cohort list replacing the bare count, per the design handoff, covering empty and populated states.
- **B4. UI, T1.** "Manage members" disclosure and member list, covering loading/error/empty/populated states, filtering `removed` rows client-side, with the full ARIA contract.
- **B5. UI, T1.** Invite control reusing `getRoster()`, covering every state in the design handoff including both success branches keyed on the response `status` field.
- **B6.** Accessibility pass on the new controls: keyboard operability of the toggle, focus never stolen on expand/collapse, invite controls reachable only when expanded and in correct tab order.
- **B7.** Catalog error handling, T1, unconditionally in scope: replace the bare catch at `PublicCatalogPage.tsx:44-46` so it no longer tells every failing user to sign in. Distinguish an unauthenticated user from any other failure and surface an accurate message.
- **B8. Catalog eligibility, owner T2 (SQL) with T1 wiring the call site.** Add a new `SECURITY DEFINER` function `public.request_version_enrollment(p_course_version_id uuid, p_idempotency_key text)`, following the conventions of the existing `request_cohort_enrollment` (`202608300002_issue5_phase3_enforcement_sql_core.sql:570-600`): `language plpgsql security definer set search_path=public`, and reject immediately when `auth.uid() is null` or the idempotency key is null/shorter than 8 trimmed characters, exactly as the existing function does.
  - It must RESOLVE the eligible cohort and then DELEGATE to the existing `request_cohort_enrollment` rather than reimplementing enrollment. This is a binding requirement: the existing function already enforces the prerequisite check (`assert_course_prerequisite`), the capacity check, the declined/cancelled reactivation path, the idempotent upsert, the membership insert, the `student_enrollments` insert, and `materialize_enrollment_entitlements`. Duplicating any of that would create a second, divergent enrollment path.
  - Eligibility predicate: cohorts whose `course_version_id = p_course_version_id` and whose `enrollment_mode in ('request','open')`, matching the mode check the existing function already performs.
  - Required additional guard, not present in the existing function because it never needed one: only consider a cohort whose course version is actually publicly reachable, that is, a published version exposed through the catalog. Without this, a student who guesses or obtains a draft version id could enroll into an unpublished version. Ground the exact predicate against `course_versions.status` and the `course_catalog` view during implementation and state the chosen predicate in the migration comment.
  - Ambiguity rule, must be explicit and deterministic: when several eligible cohorts exist for one version, select deterministically by `starts_at` ascending then `id` ascending, and document that ordering in the migration comment. When none is eligible, raise the same 'enrollment is not available' error the existing function raises, so the client sees one consistent failure mode.
  - Client: `requestEnrollment` in `src/services/courseAuthoring.ts:125` changes to call the new RPC with the previewed version id, and `PublicCatalogPage.tsx:42` passes `course.id` (which is the course version id, and is now the correct argument type). This makes the existing `course.id` argument correct rather than requiring the call site to find a different value.
  - Step B7's honest error handling still applies and composes with this: a 'no eligible cohort' failure must surface accurate copy, never "Sign in to request enrollment."
- **B9. GREEN, live.** A student actually invited into a cohort through the new UI, appearing in the member list. This is the specific outcome that unblocks Phase 3 validation.

### Track C — cleanup and documented decisions (owner: T1, independent)

- **C1.** Delete `publishCourse` and `inviteToCourse` (`courseAuthoring.ts:123-124`). Both have zero callers; `publishCourse` is additionally a latent trap that forwards a course id into a version-id parameter. First check and update `src/__tests__/courseAuthoringUi.test.tsx:8`, which references one of these names. If either turns out to have a live caller (recheck at implementation time, per Risk R7 below), mark it clearly as unused instead of deleting and document why.
- **C2.** `list_cohorts` server-side scoping: leave as is. Add a code comment at `index.ts:133-135` and at `CourseWorkspacePage.tsx:68` recording that per-course scoping is deliberately performed client-side at line 68, that it feeds both the Students and Outline tabs, and that the handler is already owner-scoped (`.eq('owner_id', data.user.id)`) so the over-fetch is never a cross-tenant leak. Do not add a redundant server-side filter. See the decision rationale in Assumptions and decisions below.

## Acceptance and validation

All tests are written failing first. **The prior plan's publish-flow and cohort-creation id-correctness tests are now vacuous** — current code already passes them — and must not be written as if they were expected to fail (RED). If an implementer's trace shows one of these paths is not actually correct, that is itself grounds to stop and return `JOB_BLOCKED "Plan stale"` (see Track B step B1 and Risk R4).

**RLS tests belong with the existing RLS regression suites**: `src/__tests__/rlsSecurityRegression.test.ts`, `src/__tests__/rlsSecurityRegressionRuntime.test.ts`, `src/__tests__/storageIntegration.test.ts`. Follow whichever established pattern those files already use.

**Track A, positive RLS.** An authenticated owner can insert, upsert-update, and delete an object at `${ownedVersionId}/...` in `lesson-assets`.

**Track A, four mandatory negative RLS tests, non-negotiable, the security core of this change:**

- (a) A different authenticated owner cannot insert into another owner's version path.
- (b) An enrolled student cannot insert anywhere in the bucket.
- (c) An anonymous/unauthenticated request cannot insert.
- (d) An owner cannot insert at a path whose first segment is a version they do not own, or is not a valid uuid at all.

**Track A, regression.** The existing student SELECT gating still denies a locked/unentitled path exactly as before; prove the new policies did not widen read access.

**Track B, UI.** Tests for every state in the design handoff's state list; both success branches (fresh invite vs. already-active member) asserted distinctly; the `removed`-status filter; the disabled-submit-when-nothing-selected behavior; display-name resolution never rendering a raw `user_id`.

**Track B, catalog.** A test proving a failure surfaces an accurate message rather than the blanket "Sign in to request enrollment." Additionally, tests written failing first for `request_version_enrollment`:

- A signed-in student with no eligible cohort for the previewed version gets an accurate 'enrollment is not available' message, never the sign-in copy.
- A signed-in student CAN request enrollment into a version that has exactly one eligible (`request` or `open`) cohort, and the resulting `enrollment_requests` row has the expected status (`pending` for request mode, `approved` for open mode).
- Negative, security-critical: an unauthenticated caller is rejected.
- Negative, security-critical: a version whose only cohorts are `invite_only` yields no enrollment and raises the not-available error.
- Negative, security-critical: a DRAFT or otherwise non-public version id cannot be used to enroll, even when it has a `request` or `open` cohort. This is the guard that does not exist in the current `request_cohort_enrollment` function.
- Deterministic selection: with two eligible cohorts on one version, the documented `starts_at`/`id` ordering picks the expected one, asserted rather than left to chance.
- Idempotency: repeating the same call with the same key does not create a duplicate request or duplicate membership.

**Track C.** A test or type-check proving nothing references the deleted functions.

**Deterministic native-dialog source scan** across every changed file: no `alert(`, `confirm(`, `prompt(`, `window.alert`, `window.confirm`, `window.prompt`, `beforeunload`. Hard gate.

**Full existing test suite, typecheck, and build must pass.**

**Mandatory live verification, explicitly NOT satisfied by a passing unit suite alone**, matching this engagement's established practice:

1. A real course publish uploading both artifacts and staging a publish job with no "Could not upload course.pdf." failure.
2. A student actually invited into a cohort through the new UI and appearing in the member list.

Then a Verifier pass, then a Browser Validator pass.

## Risks and rollback

| ID | Severity | Risk | Mitigation |
|----|----------|------|------------|
| R1 | Critical | The `storage.objects` write policy over-grants, letting a student or non-owning owner write or overwrite another owner's lesson assets (cross-tenant integrity breach) | Additive-only migration; owner-chain scoping mirroring the Edge Function's already-trusted `ownedVersion`/`ownedCourse` rule; guarded uuid cast; the four mandatory negative RLS tests; explicit regression proof that student read gating is unchanged |
| R2 | High | A malformed or non-uuid first path segment raises inside policy evaluation instead of failing closed | Required uuid-format guard before casting, stated explicitly in the migration; covered by negative test (d) |
| R3 | High | The UPDATE policy, required by `upsert: true`, lets an owner overwrite an existing generated artifact in a way that conflicts with the `course_assets_immutable` trigger's intent | Bind UPDATE to the owner's own version paths; document the interaction with `course_assets_immutable` in the migration comment |
| R4 | High | An implementer works from the SUPERSEDED plan and reintroduces the falsified Defect 1B "fix", actively breaking a publish and cohort-creation path that currently works | The superseded banner on the old document; the "What changed" section above; the explicit note that the old id-correctness tests are vacuous |
| R5 | Medium | Someone "helpfully" adds server-side scoping to `list_cohorts` anyway, interacting with the existing client-side filter at `CourseWorkspacePage.tsx:68` in an untested way and breaking the Outline tab's cadence preview, which consumes the same filtered value | Track C's explicit leave-as-is decision plus code comments at both sites |
| R6 | Medium | Reusing `getRoster()` (an admin-tier call) inside the course workspace widens where an admin-scoped call is made, and a non-owner could reach it | Confirm the existing authorization gate still holds in this call context; add a test asserting a non-owner cannot reach the invite picker's directory read |
| R7 | Medium | This plan itself goes stale again if further engineering lands in `CourseWorkspacePage.tsx`, `courseAuthoring.ts`, the `course-authoring` Edge Function, or storage migrations before implementation | The writer re-verifies the "What changed" claims before editing and returns `JOB_BLOCKED "Plan stale"` if any no longer holds; Track B step B1 makes this a hard gate |
| R8 | Low | A stale local database produces false verification results | Mandatory `npx supabase db reset` before every validation pass |
| R9 | High | The new `request_version_enrollment` duplicates rather than delegates to `request_cohort_enrollment`, creating a second enrollment path that silently skips the prerequisite, capacity, or entitlement-materialization logic | The binding delegate-do-not-reimplement requirement in step B8, plus tests asserting prerequisite and capacity enforcement still apply through the new entry point |
| R10 | High | The new function omits the published/public version guard, letting a student enroll into a draft or unlisted version by supplying its id | The explicit guard requirement in B8 and its dedicated negative test |
| R11 | Low | Multiple eligible cohorts make cohort selection nondeterministic, so two students requesting the same version land in different cohorts unpredictably | The documented `starts_at`/`id` ordering and its assertion test |

**Rollback.** The storage migration is reversible by dropping the three new policies, restoring today's state (publishing broken, no new exposure). All client and Edge Function changes revert normally. No data migration is introduced by any part of this plan, so no rollback carries a data-loss risk.

## Assumptions and decisions

**Assumed safe:** the storage path's first segment is a `course_versions.id` (verified in both upload functions, and further confirmed because the version id passed in is genuinely a version id, per "What changed" above).

**Decided by Planner, recorded with rationale:**

- **Track C, `list_cohorts`:** leave server-side scoping alone. The handler is already owner-scoped, so the over-fetch is never a cross-tenant leak; it only ever returns the requesting owner's own cohorts. `CourseWorkspacePage.tsx:68` already filters to the current version, and that filtered value feeds both the Students and Outline tabs. Adding a redundant server-side filter would change what a shared value returns while an untested client filter also narrows it, for zero security or correctness gain. Document it; do not fix it.
- Delete rather than annotate the dead `publishCourse`/`inviteToCourse`, because `publishCourse` is not merely unused but actively misleading (it would silently forward a course id into a version-id parameter if ever called).
- No new backend read action for the invite UI: `list_members` and `getRoster()` both already exist.
- No modal for the invite action; inline feedback only.
- **Catalog eligibility (settled).** The prior plan instructed the implementer to make the catalog's "Request enrollment" button resolve an eligible cohort and pass its id, which Planner found is not implementable from the client: `public.cohorts` has RLS enabled with no authenticated-read policy, and no public action exposes a cohort id. Two other approaches were considered and rejected: exposing a bounded public read action for eligible cohorts per published version (rejected because it leaks cohort ids to anonymous users), and shipping only honest error handling with the button left permanently unable to succeed (rejected as it knowingly ships a non-functional control). **The user chose to add a new `SECURITY DEFINER` function, `request_version_enrollment`, that resolves the eligible cohort server-side.** This was chosen because it keeps cohort ids private and adds no new client read surface, while making the button genuinely work. The user made this choice directly in the live session on 2026-08-30. See Track B step B8 for the full specification.

**Still needs user approval:** this entire plan. The prior plan's approval does not carry over.

## Browser UI dialog policy

Required and strict. This is browser-rendered UI. Native browser dialogs are prohibited: no `alert`, `confirm`, `prompt`, no `window.*` variants, no `beforeunload`. Any acknowledgement or confirmation must be an app-owned accessible modal following the existing `Modal`/`ModeSwitchModal` precedent, with focus trap, defined initial focus, Escape-to-cancel, and focus restoration to the triggering control; validation must be inline. The design determined no modal is needed here. A deterministic no-native-dialog source scan over all changed files is a required acceptance gate, and the new disclosure and invite controls require keyboard and focus verification.

## Browser UI validation

- **Launch and readiness:** `npx supabase start`, then `npx supabase db reset`, then `npm run dev`. Capture the actual printed Vite URL; it has been observed in the 5173-5178 range and must never be hardcoded.
- **Base URL:** the captured Vite dev URL. Relevant routes: the course workspace Publishing area, the Students tab hosting the cohort list/member disclosure/invite control, and the public catalog page.
- **Credentials:** owner account `owner@test.local` / `password`, per `supabase/seed.sql:78`.
- **Fixture and reset:** `npx supabase db reset` before each pass.
  - Fixture A: a course with zero cohorts.
  - Fixture B: a cohort with zero members.
  - Fixture C: a cohort with members in mixed invited/active status.
  - Fixture D: a populated student directory.
  - Fixture E: an empty student directory.
  - Fixture F: a draft version ready to publish with no generated artifacts yet.
  - Fixture G: a published version with exactly one eligible (`request` or `open`) cohort, for the catalog success journey.
  - Fixture H: a published version with no eligible cohort (either zero cohorts or `invite_only` only), for the catalog failure journey.
- **Journeys:**
  1. Students tab shows a real cohort list, not the bare "N cohort(s)" string.
  2. Zero-cohort case (Fixture A): no cohort list renders and `CohortForm` still works below it.
  3. "Manage members" disclosure: `aria-expanded` flips, `role="region"` appears with an accessible name, keyboard-only activation works.
  4. Cohort with no members (Fixture B): plain "No members yet." with no alert or status role.
  5. Mixed invited/active members (Fixture C): correct visible status text; no `removed` row appears.
  6. Student-directory load failure, simulated via devtools request blocking against the `admin-student-operations` endpoint called inside `getRoster()`: the specified degraded state renders and Invite is not actionable.
  7. Submit disabled when no student is selected.
  8. Successful fresh invite (Fixture D): busy state, then `role="status"` success copy naming student and cohort, member list refreshes with the new Invited row.
  9. Inviting an already-active member: distinct already-a-member copy, no duplicate row.
  10. Invite network failure, simulated by blocking the `course-authoring` endpoint: `role="alert"` `.schedule-severity-error`, selection preserved, Invite re-enables.
  11. Full course publish (Fixture F) succeeds end to end with both artifacts uploaded and a publish job staged.
  12. Public catalog "Request enrollment" SUCCESS (Fixture G): a signed-in student requests enrollment into a version with exactly one eligible open or request cohort, and sees accurate confirmation copy naming the outcome (pending vs. approved, matching the cohort's enrollment mode).
  13. Public catalog "Request enrollment" FAILURE (Fixture H): shows an accurate 'enrollment is not available' message, never "Sign in to request enrollment." to an already-signed-in user.
  14. No native dialog fires anywhere in journeys 1-13.
  15. Visible focus throughout keyboard traversal; focus never silently lost on expand, success, or failure.
  16. Empty student directory (Fixture E): "No students available to invite." and no actionable Invite.
- **Viewports:** desktop ~1280px, tablet ~768px, mobile ~375px.
- **Visible outcomes:** screenshots or DOM assertions per state showing correct ARIA roles, real fixture-sourced text with no fabricated names, and no native dialog artifacts.

## Judge route

`PLAN_DUCK` eligibility is the orchestrator's call after this draft exists, under `docs/JUDGE-CONTRACT.md`. Pending, not yet asserted.

## Approval

Explicit user approval of this document is required before any engineering writer begins. The prior plan's approval, recorded 2026-08-30 on `lizbeth-spanish-publish-and-cohort-enrollment-fixes.md`, does not carry over: this document has a materially different scope (an entire defect category removed) and reflects a scope decision (the catalog eligibility resolution, see Assumptions and decisions above) that the prior approval never addressed.

The storage RLS change (Track A) is security-sensitive: it grants write access to a bucket that currently has none. Its scoping predicate warrants specific attention during approval, separate from the rest of the plan's ordinary risk profile. The new `request_version_enrollment` function (Track B step B8) is also security-sensitive, as it is `SECURITY DEFINER`; its delegate-do-not-reimplement requirement and published-version guard warrant the same attention.

This plan is downstream-authorized for `engineering-fleet` only after the user records approval here, per the Downstream owner field above.

**Approval recorded.** rob.hasselbach@gmail.com, 2026-08-30, direct interactive-session response to the orchestrator. The orchestrator presented the finalized plan, specifically flagging both security-sensitive changes — the Track A storage RLS migration, and the new `SECURITY DEFINER` function `request_version_enrollment` reachable from the public catalog, guarded to only consider published versions and covered by the four negative security tests specified in Acceptance and validation — and asked "Ready to finalize approval and proceed?" The user's exact reply was "yes". This approves the plan in full, including both flagged security-sensitive changes and option 1 for the catalog enrollment decision (the server-side `SECURITY DEFINER` resolution function, already reflected throughout this document, including Track B step B8 and the settled decision in Assumptions and decisions above).
