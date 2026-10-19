# Lizbeth Spanish: publish and cohort enrollment fixes

> **SUPERSEDED as of 2026-08-30** by `docs/plans/lizbeth-spanish-publish-rls-and-cohort-enrollment-corrected.md`. This plan's approval no longer authorizes execution. Reason: this plan's Defect 1B causal theory ("systemic courseId/versionId parameter confusion") was falsified against current code after Phase 3 engineering work landed in the same files; see the corrected plan's "What changed from the superseded plan" section for the full re-verification.

Status: **Approved by the user, 2026-08-30.** See the Approval section below for the full approval record.

Plan ID: `lizbeth-spanish-publish-and-cohort-enrollment-fixes`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: `engineering-fleet`, after explicit user approval of this plan
Roadmap: not part of the Issue #5 five-phase roadmap (`docs/plans/lizbeth-spanish-issue5-roadmap.md`). This is an independent defect-remediation plan for two real, independently-discovered bugs found during Phase 3 browser validation.
Related plan (blocked consumer of this fix): `docs/plans/lizbeth-spanish-issue5-phase3-owner-enforcement-controls.md`. Phase 3's browser validation cannot exercise the roster/reconciliation/entitlement UI it already built without a real enrolled student, and no student can currently be enrolled into a cohort-based course. This plan exists to unblock that validation.
Design route: compact. `design-generalist` and `design-reviewer`. Prototype forbidden. Model tier: sonnet. Existing-system mode: preserve. See the design section below.

Note on file locations: this plan document lives in the orchestrator repository's `docs/plans/` directory, alongside its sibling Issue #5 phase plans, per this engagement's established convention. All source-file references below (for example `src/services/courseAuthoring.ts`) are paths relative to the target repository root stated above, `H:\CommandCenter\orchestrator\lizbeth_spanish`, matching the convention already used by the sibling Phase 2 and Phase 3 plans.

## Blocking prerequisites

None block the start of this plan. This plan itself is a blocking prerequisite for Phase 3's Browser Validator pass, which requires a real enrolled cohort student to exercise the roster, reconciliation, and entitlement UI Phase 3 already built. Until this plan ships, Phase 3 cannot be validated end to end.

## Outcome and audience

Two real, independently-discovered defects found during Phase 3 browser validation are fixed so that:

1. An owner can publish a course without the upload failing with "Could not upload course.pdf."
2. An owner can actually enroll a student into a cohort-based course, through a new cohort member list and invite control.

Audience is the engineering fleet implementing this plan and the user approving it. The immediate operational purpose is unblocking Phase 3's browser validation.

## Scope and non-goals

**In scope:**

- Bug 1 (course publish fails): two stacked, independent defects.
  - Defect 1A: no INSERT/UPDATE/DELETE RLS policy on `storage.objects` for the `lesson-assets` bucket.
  - Defect 1B: systemic courseId/versionId parameter confusion across the publish, cohort-creation, and roster call sites.
- Bug 2 (no UI to enroll a student into a cohort-based course): a new cohort list and member-invite control inside the existing "Cohorts and enrollment" panel.
- Defect 2B: the `requestEnrollment` parameter defect and its swallowed error in the public catalog.

**Non-goals:**

- A cohort-management redesign.
- Everything in the design packet's anti-goals list: member removal/revocation, cohort edit/delete, bulk invite, role assignment, cohort-detail routing, resend-invite, member list search/filter/sort/pagination.
- Any change to the legacy band-assignment enrollment system in `AdminStudentsPage`. It works today and stays untouched.
- Broadening or altering any existing student-facing SELECT RLS policy.
- Phase 4 concerns (hard re-lock/`revoked`).
- A full self-service enrollment product flow on the public catalog. The catalog fix is bounded to not making an impossible call and not showing a misleading error.
- No commit, push, PR, or deploy.

## Verified repository findings

All findings below were verified directly against current repository state during planning; line numbers are current at time of writing and must be re-checked if the plan goes stale (see Risks below).

### Defect 1A: missing storage write policy

Every storage policy in the repository is SELECT-only.

- `supabase/migrations/202607170005_storage_gating_policy.sql` creates only `students_read_unlocked_lesson_assets` (`for select`).
- `supabase/migrations/202608070001_force_password_change_rls_enforcement.sql` lines 87-113 drops and recreates that same SELECT policy, adding a force-password-change check.
- `supabase/migrations/202607170003_storage_setup.sql` is documentation only; it creates no policy.
- There is zero INSERT/UPDATE/ALL policy on `storage.objects` anywhere in the repository.

All existing policies gate through `public.resources` joined to legacy `student_enrollments.band_id`, a student-read path that structurally cannot authorize an owner writing a newly generated publish artifact, because the `resources` row does not and cannot exist yet at upload time. Consequence: an authenticated owner uploading a generated publish artifact is denied by RLS regardless of whether the bucket itself exists.

**Critical ordering constraint the implementer must not miss.** `uploadGeneratedAsset` (`src/services/courseAuthoring.ts` line 86) uploads to storage FIRST and only then calls the `register_asset` action, which inserts the `course_assets` row. The new policy therefore CANNOT be scoped by joining to `course_assets`, because that row does not exist at the moment the INSERT is evaluated. This is the central design constraint of the fix.

**Correct scoping basis.** The storage path is constructed as `${versionId}/generated/${name}` (`uploadGeneratedAsset`, line 86) and `${versionId}/${uuid}-${sanitizedFileName}` (`uploadCourseAsset`, line 77). The first path segment is a `course_versions.id`. Ownership is resolvable as: first path segment → `public.course_versions.id` → `course_versions.course_id` → `public.courses.owner_id = auth.uid()`. Schema confirmed in `supabase/migrations/202608280003_issue5_course_authoring.sql`: `public.courses` has `owner_id uuid references auth.users(id)` (line 25); `public.course_versions` has `course_id` and a `status` column.

The Edge Function already uses exactly this ownership chain server-side — see `ownedVersion`/`ownedCourse` in `supabase/functions/course-authoring/index.ts` lines 44-64 — so the new policy mirrors an already-established, already-trusted authorization rule rather than inventing a new one.

**Three verbs are required, not one.**

- INSERT: the upload itself.
- UPDATE: `uploadGeneratedAsset` calls `.upload(..., { upsert: true })` (line 86), which requires UPDATE on an existing object.
- DELETE: both `uploadCourseAsset` (line 77) and `uploadGeneratedAsset` (line 86) call `.storage.from('lesson-assets').remove([path])` in their rollback/catch path when `register_asset` fails. Without DELETE the rollback silently fails and orphans the object. An implementer fixing only INSERT will produce a partially-broken flow that appears to work in the happy path.

Note that `uploadCourseAsset` (the manual per-version asset upload, line 77) is broken by the same missing policy and is fixed by the same change; it uses the same bucket and the same `${versionId}/...` path convention.

### Defect 1B: courseId/versionId parameter confusion

This is systemic across the publish flow, materially broader than a single call site. Every instance below was confirmed by reading current code.

- `src/services/courseAuthoring.ts` line 123: `export const publishCourse = (courseId: string, _version: number) => stagePublish(courseId);` — `stagePublish`'s parameter is `courseVersionId` (line 64), and the Edge Function passes it to the `stage_publish_job` RPC as `p_version_id` (`index.ts` line 344). A course id is passed where a version id is required.
- `src/pages/CourseWorkspacePage.tsx` line 615, `Publishing` component: receives prop `courseId` and calls `uploadGeneratedAsset(courseId, 'course.pdf', ...)`, `uploadGeneratedAsset(courseId, 'course.pptx', ...)`, and `stagePublish(courseId, ...)`. All three require a version id. This also means the artifact storage path is keyed by course id instead of version id, which breaks the per-version asset model.
- `src/pages/CourseWorkspacePage.tsx` line 615: `listPublishJobs(courseId)` has the same confusion.
- `src/pages/CourseWorkspacePage.tsx` line 615, error rollback: `uploaded.map(path => removeCourseAsset(path)...)` — the array is populated with `pdfAsset.assetId` values but the variable is named `path` and `removeCourseAsset` expects an `assetId`. The implementer must verify this is actually consistent at runtime; the naming is misleading even if current behavior is correct, and it must not be broken by the rest of this fix.
- `src/pages/CourseWorkspacePage.tsx` line 423, `CohortForm`: calls `createCohort(courseId, name, mode, ...)`, but `createCohort`'s first parameter is `courseVersionId` (`courseAuthoring.ts` line 67), and the Edge Function requires `course_version_id` and inserts it directly into `cohorts.course_version_id` (`index.ts` lines 356-357), a column with a foreign key to `course_versions(id)`. Passing a course id here means cohort creation fails on the FK constraint. This is very likely why no cohorts exist to enroll into, so it is causally connected to Bug 2 and must be fixed for Bug 2's UI to be testable at all.
- `src/pages/CourseWorkspacePage.tsx` line 402: `<StudentRoster courseVersionId={courseId} ... />` passes a course id into a prop explicitly named `courseVersionId`, which then flows into `listLessonEntitlements(versionId)`. Same confusion, affecting the Phase 3 UI this fix exists to unblock.
- `src/pages/CourseWorkspacePage.tsx` line 35: `listCohorts(courseId)`. The Edge Function's `list_cohorts` handler (`index.ts` line 134) actually ignores any course/version argument and filters only by `owner_id`, so it returns every cohort the owner has across all courses. This is a distinct correctness bug, a cohort list not scoped to the course being viewed, that the implementer will encounter immediately when building the cohort list UI, and it must be resolved for the new UI to be correct.

**Authoritative source of the correct version id.** `getCourse()` (`courseAuthoring.ts` line 73) returns an object whose `id` is the VERSION id and whose `course_id` is the course id. The workspace page already holds this as `course`. The correct version id is therefore already available in the component without a new fetch; the bug is that `courseId` (the route param) is being passed where `course.id` is required. The implementer must trace each call site and pass the right one; do not blanket-replace `courseId` with `course.id`, because some sites correctly want the course id (for example `updateCourse`, `getCourse`, `PrerequisiteField`'s `excludeCourseId`).

### Defect 2: no cohort enrollment UI

- `inviteToCohort` (`courseAuthoring.ts` line 68) and `inviteToCourse` (line 124) have zero UI callers anywhere in the app, confirmed by a repository-wide search.
- Cohorts render only as the literal `<p>{cohorts.length} cohort(s)</p>` (`CourseWorkspacePage.tsx` line 401). Never listed, never actionable.
- Only the legacy band-assignment system (`AdminStudentsPage`'s "Assign a new band") actually enrolls students today.

### Defect 2B: `requestEnrollment` parameter defect and swallowed error

- `requestEnrollment` (`courseAuthoring.ts` line 125) calls RPC `request_cohort_enrollment` with `p_cohort_id`.
- Its only caller, `src/pages/PublicCatalogPage.tsx` line 42, passes `course.id`. That value comes from `getCoursePreview` (`courseAuthoring.ts` line 75), which returns `id: courseVersionId`, so it passes a course VERSION id where a COHORT id is required. This can never succeed.
- Worse, the `catch` at `PublicCatalogPage.tsx` lines 44-46 is bare and swallows every failure into the single misleading message "Sign in to request enrollment.", so a signed-in user is told to sign in. This must be fixed regardless of the parameter fix.

**Product direction, grounded and stated explicitly.** This app's onboarding is admin/owner-driven throughout: the working enrollment path today is the owner-driven `AdminStudentsPage` band assignment, and earlier QA sweep findings characterized the app as admin-driven onboarding. Owner-invite is therefore the primary intended enrollment path and is where this plan's build effort belongs; student self-enrollment via the public catalog is secondary. The bounded correct fix for the catalog is to stop it from making an impossible call and stop it from lying to the user: resolve an actually-eligible cohort (`enrollment_mode in ('request','open')`) for the previewed version and pass its id, and when no eligible cohort exists, disable or hide the control with honest copy rather than firing a call that cannot succeed. This plan does not build out a full self-service enrollment product flow.

### Research evidence

None. No external or current-fact evidence was needed. Every finding is local, verified directly against the repository, and the Supabase RLS patterns required are already established in this repository's own migrations.

## Design route and handoff

**Compact.** Reasons: this is a bounded brownfield addition to one existing panel ("Cohorts and enrollment") in an established workspace; no new screen, no new visual language, no new flow direction; the existing design system is preserved and authoritative. `design-generalist` and `design-reviewer` only. Prototype forbidden. Model tier sonnet. Existing-system mode preserve.

**Design review: PASS.** `design-reviewer` independently verified the revised packet against current repository line numbers. One evidence-backed revision cycle occurred: the reviewer caught three material factual errors in the first draft that inflated scope, the claim that two backend read actions had to be built from scratch when both already exist. All were corrected and re-verified. The reviewer confirmed no new errors were introduced.

**Residual non-blocking items the reviewer explicitly deferred to this plan:** the concrete launch command, base URL, and fixture/reset procedure (supplied below, reused verbatim from Phase 2/Phase 3); and confirming during implementation whether any code path outside `course-authoring/index.ts` can set `cohort_memberships.status = 'removed'`.

### Design handoff (compact, passed)

**Placement.** Inside the existing `.workspace-panel` "Cohorts and enrollment" (`Students` component, `CourseWorkspacePage.tsx` ~378-404). Order top to bottom: `<h2>` → existing panel feedback → existing enrollment-requests list (unchanged) → new cohort list, one row per cohort with a "Manage members" disclosure → existing `CohortForm` (unchanged, stays last).

**Cohort row.** `{name} · {enrollment mode label} · Starts {formatted date or "date not set"}` plus a "Manage members" toggle. Enrollment-mode labels reuse `CohortForm`'s existing `<option>` text verbatim (line 426): `invite_only` → "Invite only", `request` → "Request approval", `open` → "Open enrollment".

**Member list (inside the disclosure).** One row per member: `{display name or email} — {"Invited" | "Active"}`. Status is conveyed by visible text, never color alone.

**Invite control.** A labelled student picker (`<select>`, or a filtered/searchable list if the directory is large, honoring the same accessible contract) plus an "Invite" button.

**Reused patterns, all verified to exist:** `StudentRoster`'s `aria-expanded`/`aria-controls`/`.roster-student-toggle` disclosure (`CourseWorkspacePage.tsx` 271-376); `PrerequisiteField`'s async-select loading/degraded/empty states including `role="status" className="schedule-severity-advisory"` at line 503; `CohortForm`'s `noValidate` + touched + `aria-invalid` + JS-gated submit (406-436); `Modal`'s focus trap/initial focus/Escape/focus restoration (`src/components/Modal.tsx`). CSS classes `.workspace-panel`, `.cohort-form`, `.schedule-severity-error`, `.schedule-severity-advisory`, `.field-hint` all already exist in `CourseWorkspace.css`.

**Full state coverage, required:**

- Cohort list: loading / empty ("No cohorts yet. Create one below." replacing the bare count) / populated.
- Member list: loading ("Loading members…", `role="status"`) / empty (plain `<p>` "No members yet.", no alert or status role) / error (`role="alert"` + "Try again" button) / populated.
- Invite picker: loading / load-error (`role="status"`, `.schedule-severity-advisory`, "Students could not be loaded right now. Try again shortly.", controls disabled) / empty directory ("No students available to invite yet.", controls disabled).
- Blocked submit with no selection: `role="alert"` "Choose a student to invite." shown only after a blocked attempt, never proactively.
- Submitting: button disabled + "Inviting…", select disabled.
- Success (fresh invite): `role="status"` "{student} invited to {cohort}.", list reloads showing the new Invited row, selection resets.
- Success (already an active member): distinct copy, for example "{student} is already a member of {cohort}." Must not reuse fresh-invite wording.
- Failure (network/unknown user only): `role="alert"` `.schedule-severity-error` with the thrown message, fallback "Could not invite this student.", selection preserved for retry.

**Accessibility.** Cohort toggle is a real `<button aria-expanded aria-controls>`, Tab/Enter/Space operable. Member region is `role="region" aria-label="{cohort name}'s members"`. Focus is never stolen on expand/collapse; it stays on the toggle just activated. Invite controls are in tab order after the toggle and reachable only when expanded. WCAG 2.2 AA intent, visible focus inherited (no override), no color-only meaning.

**No modal is required for this fix.** Rationale, explicitly reasoned and accepted at review: an invite creates a pending `cohort_memberships` row and never grants entitlements, so its stakes are materially below `StudentRoster`'s Release action, which is the app's own stated modal trigger (irreversibility, per its in-file rationale at `CourseWorkspacePage.tsx` 260-269). Acknowledged tension: as shipped, an invite has no undo path, because no `remove_member` action exists and adding one is an anti-goal.

### Design engineering invariants (carry into implementation verbatim in substance)

1. The member-list read action already exists server-side as `list_members` (`course-authoring/index.ts` 137-143), owner-scoped via a `cohorts.owner_id` check, returning `id, cohort_id, user_id, role, status, created_at`. It is simply not exposed to the client. Add `'list_members'` to the `ReadAction` union (`courseAuthoring.ts` line 7) and add a wrapper (for example `listCohortMembers(cohortId)` calling `readAuthoring('list_members', { cohort_id })`). Add server-side display-name resolution following the `list_enrollment_requests` precedent exactly (`db.auth.admin.getUserById` per row, coalescing full name → email → 'Student', `index.ts` 153-160) so the client never renders a raw `user_id`. Do not create a duplicate `list_cohort_members` action.
2. The student directory already exists client-side as `getRoster()` (`src/services/adminStudentData.ts` 384-401, backed by the working `admin-student-operations` `'roster'` action at `supabase/functions/admin-student-operations/index.ts` 592-639). Reuse it directly for the invite picker; `id` and `email` are available on `StudentInfo` (`src/lib/adminStudentAuthorization.ts` 25-34). No new backend read action is required. Directory scope is not an open question: `src/lib/ownerSettingsAuthorization.ts` 5-7 documents a single owner/admin tier with no role hierarchy, so "all platform students" and "students scoped to this owner" are the same set. Filtering by `account_status` (for example excluding disabled) is permitted engineering discretion, not a requirement.
3. The client must branch on the invite response's `status` field to choose success copy, because the backend never returns a duplicate-membership error: the `invite` handler (`index.ts` 360-365) upserts on the `(cohort_id, user_id)` conflict and short-circuits to a success response returning the existing row when its `status === 'active'` (line 363). Treating a repeat invite as an error, or showing fresh-invite copy for an already-active member, would both be wrong.
4. Member rows with `status === 'removed'` must be filtered client-side and not rendered as current members. The `list_members` query has no status filter, so such a row would otherwise be returned. (`cohort_memberships.status` union is `'invited'|'active'|'removed'`, migration `202608280003` line 126.)
5. `noValidate` + JS-only submit gating for the invite form, exactly as `CohortForm`, so no native constraint-validation tooltip can ever appear.
6. Reuse `role="alert" className="schedule-severity-error"` / `role="status"` / `className="schedule-severity-advisory"` exclusively. No toast, snackbar, or banner component.
7. `StudentRoster` keeps its entitlement scope boundary; the new member list is identity/membership only, never a lesson-entitlement or completion view. `CohortForm` stays untouched in position and behavior.
8. No native browser dialogs anywhere: no `alert`, `confirm`, `prompt`, no `window.*` forms, no `beforeunload`.

## Interfaces and data

- New migration adding INSERT, UPDATE, and DELETE policies on `storage.objects` for `bucket_id = 'lesson-assets'`, scoped to course owners. Recommended scoping predicate, to be validated by the implementer: the first path segment of `name` resolves to a `course_versions.id` whose `course_versions.course_id` joins to a `public.courses` row with `owner_id = auth.uid()`.
  - **Safety requirement.** Guard the uuid cast; a `name` whose first segment is not a valid uuid must not raise a cast error inside policy evaluation. Use a pattern guard (or an equivalent safe-cast approach) before casting, and state the chosen approach explicitly in the migration.
  - **Decide and justify:** whether to additionally require `course_versions.status = 'draft'`, consistent with the immutability posture already enforced elsewhere (the `revoke_asset` handler at `index.ts` 269-270 requires draft status, and a `course_assets_immutable` trigger exists). Publish staging occurs while the version is still draft, so an overly strict predicate would re-break publishing; resolve this explicitly rather than leaving it implicit.
  - The new migration must be additive only. It must not drop, alter, or weaken `students_read_unlocked_lesson_assets` or any other existing policy. Follow the existing migration file naming/date convention.
- Client: add `'list_members'` to the `ReadAction` union and a `listCohortMembers` wrapper in `courseAuthoring.ts`.
- Server: add display-name resolution to the existing `list_members` handler; resolve `list_cohorts` course-scoping.
- Signature corrections in `courseAuthoring.ts` and `CourseWorkspacePage.tsx` per Defect 1B. Rename misleading parameters where the rename prevents regression (for example `publishCourse`'s `courseId` parameter), rather than leaving a name that will mislead the next reader.

## Ordered work

TDD is mandatory throughout: no production code before a failing test exists for it. This engagement's established pattern has found real bugs invisible to unit tests, so live browser verification against a real running Supabase instance is mandatory, not optional, for both bugs' completion claims.

### Phase 1 — RED evidence and failing tests (owner: T1/T2 jointly, no dependency)

1. **RED evidence for Bug 1, both stacked defects.** Reproduce the storage-upload RLS denial directly (attempt an authenticated owner INSERT into `lesson-assets` at an owned version path and capture the denial), and reproduce the parameter confusion by tracing a real publish attempt end to end and showing a course id reaching a call site that requires a version id.
2. **RED evidence for Bug 2.** Confirm no reachable UI path invokes `inviteToCohort`/`inviteToCourse`; attempt to create a cohort through the current `CohortForm` flow and capture the FK violation caused by Defect 1B's `createCohort` parameter confusion.
3. **RED evidence for Defect 2B.** Attempt `requestEnrollment` from the public catalog against a real cohort/version pair and capture both the RPC failure and the misleading "Sign in to request enrollment." message shown regardless of actual cause.
4. **Failing tests first**, for every acceptance guarantee in the Acceptance and validation section below, before any production code changes.

### Phase 2 — storage RLS fix, Defect 1A (owner: T2, security-sensitive, no dependency on Phase 3/4)

5. Write the new additive-only migration granting INSERT, UPDATE, and DELETE on `storage.objects` for `bucket_id = 'lesson-assets'`, scoped through the owner chain described in Interfaces and data, with the guarded uuid cast and the explicit draft-status decision recorded in the migration comment.
6. Run and pass all four negative RLS tests and the positive RLS test described in Acceptance and validation, plus the regression proof that the existing student SELECT gating is unchanged.

### Phase 3 — Defect 1B parameter corrections, `createCohort` first (owner: T2, correctness-critical; sequencing within this phase is binding)

7. **Fix `createCohort`'s call site first, before any cohort UI work begins.** Trace `CohortForm`'s call to `createCohort(courseId, ...)` in `CourseWorkspacePage.tsx` and pass `course.id` (the version id) instead of the route's `courseId`. This is a hard prerequisite for Phase 5: cohorts cannot be created at all until this lands, and the new cohort UI would otherwise have nothing real to render or test against.
8. Fix `list_cohorts`' course-scoping (server-side, `course-authoring/index.ts`), deciding and implementing filtering scoped to the course/version being viewed rather than every cohort the owner has. Before doing so, check the sibling `Outline` component's consumption of `cohorts` (`CourseWorkspacePage.tsx` lines 30, 68, 77-81, 131) for cadence preview, and confirm the narrower scoping does not break that display; adjust the `Outline` call site if it does.
9. Fix the publish flow's parameter confusion: `publishCourse`/`stagePublish`, the `Publishing` component's `uploadGeneratedAsset` calls (both `course.pdf` and `course.pptx`), `listPublishJobs`, and the error-rollback `path`/`assetId` naming, tracing each call site individually rather than blanket-replacing `courseId`.
10. Fix `<StudentRoster courseVersionId={courseId} ... />` to pass the real version id, and verify `listLessonEntitlements` receives it correctly.
11. Verify every other `courseId`-named call site in the touched files (`updateCourse`, `getCourse`, `PrerequisiteField`'s `excludeCourseId`) is left correctly pointed at the course id, not accidentally swept into the version-id fix.

### Phase 4 — publish flow live verification (owner: T1, depends on Phases 2 and 3)

12. With both Defect 1A and Defect 1B fixed, run a real course publish end to end against a running Supabase instance and confirm both artifacts upload and a publish job stages successfully, with no "Could not upload course.pdf." failure.

### Phase 5 — cohort enrollment UI, Defect 2 (owner: T1 for UI, T2 for the two backend additions; depends on Phase 3 step 7 landing first)

13. **Backend additions**, owned by T2: add `'list_members'` to the `ReadAction` union and the `listCohortMembers` client wrapper; add server-side display-name resolution to the existing `list_members` handler, following the `list_enrollment_requests` precedent exactly.
14. **Cohort list UI**, owned by T1: render the real cohort list inside the existing "Cohorts and enrollment" panel per the design handoff, replacing the bare count, covering the loading/empty/populated states.
15. **Member list and "Manage members" disclosure**, owned by T1: implement the `aria-expanded`/`aria-controls`/`role="region"` disclosure, covering loading/empty/error/populated states, filtering `status === 'removed'` rows client-side.
16. **Invite control**, owned by T1: implement the student picker reusing `getRoster()`, the Invite button, and every state in the design handoff's full-state-coverage list, including the distinct fresh-invite vs. already-active-member success copy branching on the invite response's `status` field.
17. Accessibility pass on the new controls: keyboard operability of the toggle, focus never stolen on expand/collapse, invite controls reachable only when expanded and in the correct tab order.

### Phase 6 — Defect 2B, requestEnrollment fix (owner: T1, independent of Phases 2-5, can run in parallel)

18. Fix `requestEnrollment`'s call site in `PublicCatalogPage.tsx` to resolve an actually-eligible cohort (`enrollment_mode in ('request','open')`) for the previewed version and pass its id, rather than the course version id.
19. Replace the bare catch that produces the misleading "Sign in to request enrollment." message with accurate error handling that distinguishes an unauthenticated user from any other failure.
20. When no eligible cohort exists for the previewed version, disable or hide the enrollment-request control with honest copy, rather than firing a call that cannot succeed.

### Phase 7 — full verification (owner: T1/T2 jointly, depends on all prior phases)

21. Full existing test suite, typecheck, and build pass.
22. Deterministic source scan for native dialogs (`alert(`, `confirm(`, `prompt(`, `window.alert`, `window.confirm`, `window.prompt`, `beforeunload`) across every changed file; zero matches required.
23. **Mandatory live verification, not satisfied by unit tests alone**, matching this engagement's established practice:
    1. A course publish that actually uploads both artifacts and stages a publish job, without the "Could not upload course.pdf." failure, against a real running Supabase instance.
    2. A student actually invited into a cohort through the new UI, appearing in the member list. This is the specific outcome that unblocks Phase 3 validation.
24. Verifier pass, then Browser Validator pass.

## Acceptance and validation

TDD-first is mandatory, matching Phase 2 and Phase 3 practice. Every behavior below gets a failing test written and demonstrated failing before the corresponding production change.

**RLS tests belong with the existing RLS regression suites**: `src/__tests__/rlsSecurityRegression.test.ts`, `src/__tests__/rlsSecurityRegressionRuntime.test.ts`, `src/__tests__/storageIntegration.test.ts`. Follow whichever established pattern those files already use.

**Positive RLS.** An authenticated owner can insert, upsert-update, and delete an object at `${ownedVersionId}/...` in `lesson-assets`.

**Negative RLS, all four required, non-negotiable, the security core of the change:**

- (a) A different authenticated owner cannot insert into another owner's version path.
- (b) An enrolled student cannot insert anywhere in the bucket.
- (c) An anonymous/unauthenticated request cannot insert.
- (d) An owner cannot insert at a path whose first segment is a version they do not own, or is not a valid version id at all.

**Regression.** The existing student SELECT gating still denies a locked/unentitled path exactly as before; prove the new policies did not widen read access.

**Publish flow.** A test proving the correct VERSION id (not course id) reaches `uploadGeneratedAsset`, `stagePublish`, and `listPublishJobs`, and that the artifact path is version-keyed.

**Cohort creation.** A test proving `createCohort` receives a version id, so the `cohorts.course_version_id` foreign key is satisfied.

**Cohort UI.** Tests for every state in the design handoff's state list, both success branches (fresh invite vs. already-active member), the `removed`-status filter, and the blocked-submit-only-after-attempt validation behavior.

**`requestEnrollment`.** A test proving a cohort id (not a version id) is passed, and that a failure surfaces an accurate message rather than the blanket "Sign in to request enrollment."

**Deterministic source scan** for native dialogs across all changed files: no `alert(`, `confirm(`, `prompt(`, `window.alert`, `window.confirm`, `window.prompt`, `beforeunload`. This is a hard gate.

**Full existing test suite, typecheck, and build must pass.**

**Mandatory live verification, explicitly not satisfied by a passing unit suite alone**, matching this engagement's established practice:

1. A course publish that actually uploads both artifacts and stages a publish job without the "Could not upload course.pdf." failure, demonstrated against a real running app with a real Supabase instance.
2. A student actually invited into a cohort through the new UI, appearing in the member list, demonstrated the same way. This is the specific outcome that unblocks Phase 3 validation.

## Risks and rollback

| ID | Severity | Risk | Mitigation |
|----|----------|------|------------|
| R1 | Critical | The `storage.objects` write policy over-grants: any authenticated user, or any path in the bucket, would let a student or a non-owning owner write or overwrite lesson assets belonging to someone else, a cross-tenant integrity breach | Additive-only migration; owner-chain scoping mirroring the Edge Function's already-trusted `ownedVersion`/`ownedCourse` rule; guarded uuid cast; the four mandatory negative RLS tests; explicit regression proof that student read gating is unchanged |
| R2 | High | A malformed or non-uuid first path segment raises inside policy evaluation instead of failing closed cleanly | Required uuid-format guard before casting, explicitly stated in the migration; covered by negative RLS test (d) |
| R3 | High | The UPDATE policy, required by `upsert: true`, lets an owner overwrite an existing generated artifact at a known path in a way that conflicts with the `course_assets_immutable` trigger's intent | Confirm the UPDATE policy is bounded to the owner's own version paths; explicitly document the interaction with `course_assets_immutable` in the migration comment |
| R4 | High | Defect 1B's fix is done as a blanket search-and-replace of `courseId`, breaking call sites that correctly want the course id (`updateCourse`, `getCourse`, `PrerequisiteField`'s `excludeCourseId`) | Each site traced and fixed individually per the ordered work; acceptance tests assert the correct id at each site, not just "some id changed" |
| R5 | Medium | Changing `list_cohorts` scoping changes what an existing owner sees and breaks the sibling `Outline` component's cadence preview, which also consumes `cohorts` | Explicit check of the `Outline` component's consumption before narrowing scope, with its call site adjusted if needed, as an ordered-work step |
| R6 | Medium | Reusing `getRoster()` (an admin-tier call) inside the course workspace widens where an admin-scoped call is made, and a non-owner could reach it | Confirm the existing authorization gate still holds in this new call context; add a test asserting a non-owner cannot reach the invite picker's directory read |
| R7 | Medium | The invite UI ships before `createCohort` is fixed, making it untestable against real data and encouraging a mocked-only implementation | Binding ordering: `createCohort`'s fix (Phase 3, step 7) lands before any cohort UI work (Phase 5) begins |
| R8 | Low | A stale local database or stale repository state (see Staleness below) produces false verification results | Mandatory fresh database reset before every validation pass; explicit staleness check before implementation begins |

**Rollback.** The storage policy migration is reversible with a `drop policy` for each of the three new policies, restoring today's state: publishing broken, but no new security exposure introduced. Client and Edge Function changes are revertible by normal VCS revert. No data migration is introduced by any part of this plan, so no rollback carries a data-loss risk.

**Staleness.** This plan is grounded in repository state verified during planning. If Phase 3 engineering work lands changes to `CourseWorkspacePage.tsx`, `courseAuthoring.ts`, the `course-authoring` Edge Function, or storage migrations before this plan's implementation begins, the writer must return `JOB_BLOCKED` with `Plan stale` rather than proceeding against outdated line numbers.

## Assumptions and decisions

**Assumed safe:**

- Owner-invite is the primary intended enrollment path, grounded in this app's admin-driven onboarding model; the public-catalog self-enrollment path is fixed only to the extent of not making an impossible call and not showing a misleading error.
- The storage path's first segment is a `course_versions.id`, per both upload functions' path construction.

**Decided:**

- No new backend read actions are needed for the invite UI: `list_members` and `getRoster()` both already exist. This was the design reviewer's most material correction and it meaningfully reduced scope.
- No modal for the invite action; inline feedback only, per the design handoff's reasoning about stakes relative to `StudentRoster`'s Release action.

**Still needs user approval:** this entire plan, before any implementation begins.

**Open for the implementer to resolve and document, not blocking approval:**

- Whether the new storage write policies should additionally require `course_versions.status = 'draft'`.
- Whether any code path outside `course-authoring/index.ts` can set `cohort_memberships.status = 'removed'`; the design reviewer explicitly did not sweep the full repository for this.

## Browser UI dialog policy

Required and strict. This is browser-rendered UI. Native browser dialogs are prohibited: no `alert`, `confirm`, `prompt`, no `window.*` variants, no `beforeunload`. Any acknowledgement or confirmation must be an app-owned accessible modal following the existing `Modal`/`ModeSwitchModal` precedent with focus trap, defined initial focus, Escape-to-cancel, and focus restoration to the triggering control; validation must be inline. The design determined no modal is needed for this fix. A deterministic no-native-dialog source scan over all changed files is a required acceptance gate, and the new disclosure/invite controls require keyboard and focus verification.

## Browser UI validation

- **Launch and readiness:** `npx supabase start`, then `npx supabase db reset`, then `npm run dev`. Reused verbatim from the Phase 2 and Phase 3 plans' proven values. Capture the actual printed Vite URL; it has been observed in the 5173-5178 range and must never be hardcoded.
- **Base URL:** the captured Vite dev URL. Relevant routes are the course workspace's Publishing/Versions area and the Students tab hosting the cohort list, member disclosure, and invite control, plus the public catalog page.
- **Credentials:** owner account `owner@test.local` / `password`, per `supabase/seed.sql:78`, reused verbatim from the sibling plans.
- **Fixture and reset:** `npx supabase db reset` before each pass.
  - Fixture A: a course with zero cohorts.
  - Fixture B: a cohort with zero members.
  - Fixture C: a cohort with members in mixed invited/active status.
  - Fixture D: a populated student directory.
  - Fixture E: an empty student directory.
  - Fixture F: a draft version ready to publish, with no generated artifacts yet, for the publish-flow journeys.
- **Journeys:**
  1. Students tab shows a real cohort list, not the bare "N cohort(s)" string.
  2. Zero-cohort empty state (Fixture A) renders and `CohortForm` still works below it.
  3. "Manage members" disclosure: `aria-expanded` flips, `role="region"` appears with an accessible name, keyboard-only activation works.
  4. Cohort with no members (Fixture B) shows plain "No members yet." with no alert/status role.
  5. Mixed invited/active members (Fixture C) render correct visible status text; no `removed` row appears.
  6. Student-directory load failure, simulated via devtools request blocking against the `admin-student-operations` Functions endpoint called inside `getRoster()`: select disables with `role="status"` `.schedule-severity-advisory`, Invite stays disabled.
  7. Submit with no selection: `role="alert"` appears only after the blocked attempt.
  8. Successful fresh invite (Fixture D): busy state, then `role="status"` success naming student and cohort, list reloads with the new Invited row.
  9. Inviting an already-active member: distinct already-a-member copy, no duplicate row.
  10. Invite network failure, simulated by blocking the `course-authoring` Functions endpoint: `role="alert"` `.schedule-severity-error`, selection preserved, Invite re-enables.
  11. Full course publish (Fixture F) succeeds end to end with both artifacts uploaded and a publish job staged.
  12. No native dialog fires anywhere in journeys 1-11.
  13. Visible focus throughout keyboard traversal; focus never silently lost on expand, success, or failure.
  14. Empty student directory (Fixture E): the invite picker shows "No students available to invite yet.", controls disabled.
- **Viewports:** desktop ~1280px, tablet ~768px, mobile ~375px.
- **Visible outcomes:** screenshots/DOM assertions per state showing correct ARIA roles, real fixture-sourced text with no fabricated names, and no native dialog artifacts.

## Judge route

`PLAN_DUCK` eligibility is the orchestrator's call after this draft exists, under `docs/JUDGE-CONTRACT.md`. Pending, not yet asserted.

## Approval

Explicit user approval of this document is required before any engineering writer begins.

The storage RLS change (Defect 1A) is security-sensitive: it grants write access to a bucket that currently has none. Its scoping predicate warrants specific attention during approval, separate from the rest of the plan's ordinary risk profile.

**Approval recorded, 2026-08-30.** The user (rob.hasselbach@gmail.com) approved this plan directly in the live interactive session with the orchestrator, in response to the orchestrator's summary presenting the plan (publish RLS/ID-confusion fix plus cohort enrollment UI fix) and noting the two non-blocking implementer-level decisions listed above. Exact reply: "approved, proceed as planned." This is accepted as approval of the plan as drafted, including both non-blocking implementer decisions at their stated defaults:

- The new storage write policies do not additionally require `course_versions.status = 'draft'`, unless the implementer's own investigation finds a concrete reason to add that constraint, which must then be documented at the point of implementation.
- No sweep of the full repository for other code paths that can set `cohort_memberships.status = 'removed'` is required before implementation; the implementer documents this scope boundary at the point of implementation if it becomes material.

This plan is downstream-authorized for `engineering-fleet` per the Downstream owner field above.
