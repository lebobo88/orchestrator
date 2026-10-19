# Lizbeth Spanish: Issue #228 Create-and-Assign Student Workflow (with Prerequisite Students-Tab Fix for #140 and #183)

Status: APPROVED (revision 1, 2026-10-11) for execution. The user approved this plan on 2026-10-11 (verbatim: "Approve and agree"). Execution is two PRs: first the #140/#183 prerequisite from `origin/main`, then #228 stacked on it.

Approval record (2026-10-11):
- D-3a is approved: a third server-only function `transition_onboarding_operation`, with the same lockdown.
- No repeat `PLAN_DUCK`: the user agreed to skip it; `CODE_REVIEW` will cover the implementation.
- The P0 production read-only check is run by the user with their own credentials and does not gate the #140/#183 PR.
- Hosted rollout (migration apply, Edge deploys, Netlify) remains a separate, later approval.

Plan ID: `lizbeth-spanish-issue228-create-and-assign`. Task ID: `lizbeth-spanish-issue228-create-and-assign`. Route: engineering. Engineering mode: standard (T1 first-line; T2 on escalation). Extreme advisory is not recommended. Team authorization: not applicable. Downstream owner: engineering-fleet.

Target repository: `lebobo88/lizbeth-spanish`. Evidence worktree (read-only, detached `origin/main` `88b43fd`): `H:\CommandCenter\orchestrator\lizbeth_spanish-main-88b`. All paths and line numbers below are relative to that worktree and are re-verified at Step 0.

Parent plan: `H:\CommandCenter\orchestrator\docs\plans\lizbeth-spanish-issue-batch-2026-10.md` (PARTIALLY APPROVED 2026-10-10). #227 and #228 each need their own sub-plan, design pass and user approval. This document is the #228 sub-plan, covering Wave 2b-0 (PR A) and Wave 2b-2 (PR B). PR #229 (#224 to #226, branch `fix/224-226-signin-es-guidance`, `2afb6d5`) is open and unmerged and does not touch any file in this plan.

Audience: the user (approver and sole merger), the engineering fleet, the Verifier and the Browser Validator.

Evidence labels: **Observed** means read at file level in the `88b43fd` worktree. **Inference** is a conclusion drawn from observations. **Assumption** is taken as true until a runtime step verifies it. **Unknown** is not yet established.

---

## Plan revision 1 (PLAN_DUCK #1, shadow, advisory; user decisions received)

`PLAN_DUCK` #1 (Codex "Terra", shadow policy, advisory) returned findings J-001, J-002 and J-003. All three were ACCEPTED and remediated in place in this revision. Status stays DRAFT and final approval is still required. Judge accounting: PLAN_DUCK 1 of the #228 cap of 4 used (shadow); a repeat is at the lead's discretion.

| ID | Severity / confidence | Disposition | Summary | Sections changed |
| --- | --- | --- | --- | --- |
| J-001 | major / high | accepted | Rollback no longer drops the operation table. The rollback file drops only the service-only functions; the table and rows are retained, inert. Preserving export, post-rollback reconciliation path, and a rollback-preservation test are added. | 8 (B1), 9, 10.3, 12 |
| J-002 | major / medium | accepted | Concurrency-safe acquisition: lease columns, an expanded phase state machine, a third service-only function `transition_onboarding_operation`, `p_lease_token` on `grant_onboarding_targets`, a reconcile-first Edge algorithm, and deterministic interleaving tests T-a to T-h. | 8 (B1, B2, B3), 9, 10.3, 12, 13 |
| J-003 | minor / high | accepted | The "Re-issue access link" wording conflicted with the no-email invariant. The new outcome action is labelled "Reissue temporary password", and a no-email-claim text test is added. | 5.2, 5.7, 8 (B3), 10.3 |

### User decisions 2026-10-11 (relayed by the lead; recorded here, not independently confirmed by Scribe)

| ID | Decision | Recorded outcome |
| --- | --- | --- |
| D-1 | Revise for PLAN_DUCK, then return for approval | Done in this revision. Final approval is still required. |
| D-2 | Edge invite guard | YES. The Edge Function rejects invites into cohorts whose version is not published (422 `version_not_published`). |
| D-3 | New migration | APPROVED: operation-record table plus server-only functions, local only. Hosted rollout remains a separate later approval. See D-3a for the third function. |
| D-4 | Read-only production check | YES. Included as ordered-work step P0 (section 8). |
| D-5 | Merge order | STACK. PR B branch `feat/228-create-and-assign` is created from PR A's branch `fix/140-183-students-tab-published-version`. The user merges in order: PR A, then PR B. |

---

## 1. Outcome

The owner (Lizbeth) can create a student and assign one or more courses in one workflow, so the student sees those courses on first sign-in. Account-only creation stays an explicit choice. An explicit "assign courses to an existing student" path exists. The course workspace Students tab works on the published version even when a newer draft exists.

## 2. Delivery policy and scope

Binding delivery policy (from the parent plan): one branch and one PR per issue or justified coupled cluster, each from then-current `origin/main` in a fresh worktree; the PR targets `main` with "Closes #n"; no pushes to `main`; no agent merges; no hosted, production, Netlify, Edge deploy or hosted database writes without separate user approval.

This work is delivered as two PRs.

| PR | Wave | Branch | PR body | Base |
| --- | --- | --- | --- | --- |
| PR A (prerequisite) | 2b-0 | `fix/140-183-students-tab-published-version` | "Closes #140", "Closes #183"; Refs #228, #197 | then-current `origin/main` |
| PR B (#228) | 2b-2 | `feat/228-create-and-assign` | "Closes #228"; "Depends on PR A; merge it first" | PR A's branch `fix/140-183-students-tab-published-version` (stacked; user decision D-5) |

Coupling justification for PR A: #140 and #183 share one root cause (a version id used where a course id or published version id is required) on the same Students-tab path that #228 uses.

PR B is STACKED on PR A's branch (user decision D-5, 2026-10-11): `feat/228-create-and-assign` is created from `fix/140-183-students-tab-published-version`. Stacked PR mechanics: open PR B with base equal to PR A's branch so the review diff stays clean, and state "Depends on PR A; merge it first". After PR A merges, retarget PR B to `main` (GitHub closing keywords act only on PRs merged into the default branch), rebase if needed, and re-run the gates if the rebase changed anything. The user merges in order: PR A, then PR B.

### Non-goals

- Inventing a first-login profile or provisioning trigger.
- A generic direct-insert enrollment API.
- Silently creating cohorts.
- Dropping the one-active-enrollment-per-user/band constraint or cohort membership constraints.
- Changing registration's no-forced-password-change default.
- New self-service signup or email invitations. The app sends no email; no copy or report may claim it did.
- Changing the Outline tab's cohort/cadence preview.
- #198 legacy date versus entitlement reconciliation.
- Behaviour changes for #176.
- Hosted rollout.

## 3. Repository findings

Observed unless labelled otherwise.

### 3.1 Root cause for #228

1. No first-login gate exists anywhere on the assignment path.
   - `supabase/functions/admin-student-operations/index.ts:291-336` `handleRegisterStudent` calls `auth.admin.createUser({email, password, email_confirm:true})` and immediately returns `student_id` and `temp_password`.
   - `:455-539` `handleAssignStudent` (band) checks only `studentExists` (`getUserById`, `:1736-1745`) and `bandExists`. There is no `last_sign_in_at` check.
   - `:1719-1727` `deriveAccountStatus` value `pending_first_login` is display-only.
   - No migration references `last_sign_in_at` (grep).
   - `public.is_account_active` (migration `202607200001`:40-55) checks bans only.
   - `enroll_cohort_member` / `grant_cohort_enrollment` (migration `202608300005`:46-204) has no sign-in condition.
2. Confirmed contributing root cause: creation and enrollment are separate contracts and separate UI, with no combined operation.
   - `RegisterStudentModal` (`src/components/RegisterStudentModal.tsx`: submit `:101-125`, email-only form `:187-256`, one-time password reveal `:346-352`) is wired at `src/pages/AdminStudentsPage.tsx:331-347`.
   - Band assignment is a separate student-detail picker (`AdminStudentsPage.tsx:639-658, 875-925`).
   - Authored-course assignment is per cohort in the course workspace (`src/pages/CourseWorkspacePage.tsx` `CohortRow` `:787-912`).

### 3.2 Strongest on-path defect cluster (#140 and #183)

Still OPEN on `main` at `88b43fd`. The user believed it was done; source shows otherwise.

- a. `src/services/courseAuthoring.ts:115` `getCourse`: `version = versions.find(status==='draft') ?? versions[0]`. Edge `get_course` orders versions `version_no` descending (`supabase/functions/course-authoring/index.ts:189`). `getCourse` returns `id: version.id` (a VERSION id) and `course_id`.
- b. `CourseWorkspacePage.tsx:80` `courseCohorts = cohorts.filter(c => c.course_version_id === course?.id)`. With a newer draft, every published-version cohort is hidden from the Students tab, so there is nothing to invite a student into. Edge `list_cohorts` (`:234-237`) deliberately returns all owner cohorts; filtering is client-side.
- c. `CourseWorkspacePage.tsx:108` `<Students courseId={course.id} ... published={course.status==='published'}>`; `:736` `StudentRoster courseVersionId={courseId}`; `:491-517` `StudentRoster` sets `[]` unless published (#140). The roster is empty whenever a draft exists.
- d. `:715` `listEnrollmentRequests(courseId)` goes to `courseAuthoring.ts:67`, which sends `{course_id: <version id>}`. In `course-authoring/index.ts:115-123`, `ownershipFailure` runs `ownedCourse(version id)`, which is false, giving a 404 "Resource not found." The client `.catch(() => setRequests([]))` then shows "No enrollment requests." (#183). The handler at `:265-283` ignores `course_id` and returns all owner requests (no per-course filter).
- e. `:735` `CohortForm courseId={courseId}` creates cohorts on the DRAFT version. Invite (`course-authoring/index.ts:529-555` to `enroll_cohort_member` to `grant_cohort_enrollment`) does not reject unpublished versions (migration `202608300005`:66, 129), so it grants an enrollment pinned to the draft. `get_student_learn_index` joins `cv.status='published'` (migration `202608310002`:207-219), so the student never sees it while the owner sees "<email> is now enrolled in <cohort>".

**Inference:** items (b) to (e) are the most likely concrete mechanism behind "cannot assign a course to a new student", and none depends on first login. The production cause remains **Unknown** until reproduced (see section 8, R-steps).

### 3.3 Directory freshness

`CohortRow` (`:787-816`) fetches `getRoster` once per mounted row and caches failure. `rosterFailed` (`:881-887`) shows "Students could not be loaded right now. Try again shortly." with NO retry control. `membersError` (`:871-872`) already has a working "Try again". Backend `handleGetRoster` (`:628-675`) calls `auth.admin.listUsers()` once (no pagination) although `listAllAuthUsers` (`:677-686`, `perPage` 1000 loop) exists. GoTrue default page size and order: **Unknown**, determined by a local test with more than 50 users.

### 3.4 Enrollment models (not interchangeable)

- Authored course: an existing cohort on a published version, via `grant_cohort_enrollment(p_cohort_id, p_user_id)` (service_role only, `:148-149`; idempotent early return before capacity; capacity P4002; prerequisite P4001; writes `student_enrollments` including `band_id = v.band_id` `:129-130`, membership and entitlements) and the owner wrapper `enroll_cohort_member(cohort, user, owner, idempotency_key)` (`:165-201`).
- Legacy band: `assign_band_enrollment(p_student_id, p_band_id, p_enrollment_date)` (migration `202610030001`:570-617; the version resolver at `:44-66` can return NULL; no idempotency key) and `resume_band_enrollment`.
- One active enrollment per `(user_id, band_id)` via a partial unique index (migration `202607200001`:11-25).
- Legacy bands are also courses (`courses.legacy_band_id`; `course-authoring` `list_courses` `:140-151`).
- T1 Step 0 must confirm the LATEST definitions of these functions across all migrations (grep "function public.grant_cohort_enrollment" and the equivalents).

### 3.5 Hardening already on main

#222 least-privilege EXECUTE hardening is on `main` (migration `202610070002_revoke_authenticated_execute_internal_functions.sql`; tests `src/__tests__/anonFunctionExecuteGrants.test.ts`, `authenticatedFunctionExecuteGrants.test.ts`). Rollbacks live in `supabase/rollbacks/` (for example `revoke_authenticated_execute_internal_functions_rollback.sql`).

### 3.6 Existing tests to extend

Unit and integration: `src/__tests__/RegisterStudentModal.test.tsx` (including immediate sign-in copy, about `:417-455`), `RegisterStudentModal-FocusRestore.test.tsx`, `RegisterStudentModal-StaleError.test.tsx`, `AdminStudentsPage.test.tsx`, `AdminStudentModals.test.tsx`, `adminStudentOperationsFixes.test.ts`, `adminStudentAuthorization.test.ts`, `cohortInviteEnrollmentGrant.test.ts` (authz and idempotency about `:197-399`, concurrent capacity about `:484-550`), `cohortInviteEdgeContract.test.ts`, `cohortInviteEnrollmentUi.test.tsx`, `cohortMembersAndInvite.test.tsx`, `issue176-completion-edge-live.test.ts` (about `:68-129` signs the student in first; add a no-sign-in variant), `issue176-completion-foundations-sql.test.ts` (about `:514-603`, ACL and version selection), `issue5BackendContract.test.ts` (`:98`), `anonFunctionExecuteGrants.test.ts`, `authenticatedFunctionExecuteGrants.test.ts`.

Existing e2e: `src/__tests__/e2e/wp4-roster.spec.ts`, `gap-4-admin-students-remediation.spec.ts`, `wp8-course-workspace.spec.ts`, `issue-57-modal-background-inertness.spec.ts`.

### 3.7 Environment

Windows reserves ports 54314-54413, so the local Supabase stack runs from a port-shifted UNTRACKED mirror. Precedent: `H:\CommandCenter\orchestrator\lizbeth_spanish-224-run` (`supabase/config.toml` api 64321, db 64322, pooler 64329, studio 64323, smtp 64324; `.env.local` `VITE_SUPABASE_URL=http://127.0.0.1:64321`). Live tests hardcode `http://127.0.0.1:54321` (58 occurrences in 43 files under `src/__tests__`, for example `adminStudentOperationsFixes.test.ts:16`), so the mirror rewrites 543xx to 643xx in config, `.env.local` and tests. The mirror is never committed. Code edits happen in the PR worktree and are then synced to the mirror for runs. T1 Step 0 reproduces the 224-run recipe (diff `lizbeth_spanish-224-run` against `lizbeth_spanish-224` to list the substitutions).

### 3.8 Known pre-existing failures (compare against, do not fix)

- #218: 10 e2e tests across `gap-1-owner-settings-persistence`, `issue-3-feedback-inbox`, `issue-50-asset-card-grid` (x3), `issue-54-header-nav-reachability`, `issue-55-form-controls-ds-chrome` (x2), `wp4-roster`, `wp5-feedback-inbox`.
- Vitest: the require-backup test and 2 `issue5-services` PDF tests (3 failures); `fieldJournalTokens` needs a parent-directory config (from #222 evidence).
- `wp4-roster` is in #218 and is on this path. Its pre-existing failure is recorded, not masked.

## 4. Research

None. Research is not needed: no current or external fact changes the plan. GoTrue `listUsers` default ordering and page size are settled by a deterministic local test. Auth Admin `createUser` accepts `app_metadata` (used for operation provenance) and is exercised by live tests.

## 5. Design route and reviewed design handoff

`DESIGN_ROUTE`: profile standard. Reasons: user-flow change on an existing modal with multi-state outcomes, plus bounded Students-tab state changes. Agents required: design-director, ux-architect, visual-system-designer, design-reviewer. Prototype: forbidden. Model tier: sonnet. Existing-system mode: extend, with binding Field Workbook identity from `docs/plans/lizbeth-spanish-course-platform.md` sections 4.2, 4.5 and 8.

`DESIGN_REVIEW_RESULT`: verdict PASS (round 2, after one revision). Round 1 NEEDS_REVISION findings, all resolved: duplicate band/course representation (now one unified list), published-version invariant for roster and requests, duplicate-email id dependency, CohortRow retry scoping, committed "Assign courses now", and the component-extraction reading. Remaining limit: the backend was not design-reviewed; it is covered by this plan's judge route.

### 5.1 Selected direction: EXTEND

Reuse the existing Add-Student modal, `src/components/Modal.tsx` mechanics, the Control/Field/Badge vocabulary, and the `ReassignModal` fieldset/radio precedent (`src/components/AdminStudentModals.tsx`). No new Control tier, Badge/Pill variant, token or typeface. Extracting a React picker-row component built only from existing Control/Field/fieldset/radio markup is permitted.

### 5.2 UX journeys

**(a) Add Student modal.** Email plus ONE unified "Courses" target picker (no separate Bands group), nothing pre-selected, with a live selection-status line. The submit label is "Create account only" at zero selected and "Create account and assign N course(s)" where N is the number of checked course rows. Account creation then auto-chains the grant in one in-flight `role=status` advisement. The outcome screen has two stacked regions, Account then Course assignments, never interleaved.

**(b) Account-only is first-class.** The outcome shows a zero-state plus a COMMITTED "Assign courses now" action that pivots into (c) for the same student, with no re-registration and no password rotation.

**(c) Standalone "Assign Courses" modal.** Entry points are student detail "Assign courses" (alongside the unchanged "Assign a new band") and the duplicate-email branch (carrying selections). The email is read-only. "Assign course(s)" is disabled at zero selections. The outcome shows Course assignments only.

**(d) Outcomes.**

- `all_success`: the existing one-time password reveal and copy are unchanged, plus per-target granted lines.
- `partial_failure_retry`: reveal regardless; per-target real-text reasons; "Retry assignments" scoped to failed targets only; granted rows are never resubmitted.
- `operation_key_conflict`: `role=status` neutral notice; re-reads server state.
- `lost_credential_reissue`: informational notice with an action labelled "Reissue temporary password" that opens the UNMODIFIED `ReissueAccessModal`, which forces a password change; registration does not. The owner then shares the new temporary password directly. The existing student-detail button keeps its current label (out of scope).
- `duplicate_email`: no outcome screen; the existing inline error plus "Assign courses to this existing student".

**(e) Students tab.**

- The cohort list, `StudentRoster` and enrollment requests use the PUBLISHED version.
- A persistent `role=status` banner appears when a newer draft exists ("enrollments apply to the published version").
- A never-published course shows `JournalEmptyState` "Publish before enrolling students" with "Go to Publish" instead of empty panels.
- Cohort creation targets the published version.
- Content-editing tabs keep the draft.

### 5.3 Picker rows (one row per course)

| Case | Row behaviour |
| --- | --- |
| Authored course with exactly one eligible published-version cohort | Plain checkbox: title, version, cohort name or "Self-paced" when `starts_at` is null, start-date behaviour, capacity as text |
| Authored course with 2 or more cohorts | Checkbox plus required nested radio fieldset (legend "Choose a cohort for <title>"), no default |
| Band-backed course (`legacy_band_id`) with zero cohorts | Plain checkbox meaning "Rolling start on the assignment date" (band assignment) |
| Band-backed course with 1 or more cohorts | Required fieldset with "Rolling start on the assignment date" plus each eligible cohort, no default |
| Zero-target non-band course | Disabled with visible reason: "Publish this course before enrolling students." or "Create a cohort in this course's Students tab." |
| Already-active conflict (existing-student and retry only) | Whole row disabled: "Already active in <name> since <date>. Assigning again would conflict." Covers direct band and band-backed cohort enrollments (shared `band_id` constraint) |
| Prerequisite met | Advisory line |
| Prerequisite not met | Disabled with reason |
| Picker loading, error, empty | `role=status` or `role=alert` text with "Try again" |

### 5.4 Responsive behaviour

- 390 px: rows stack (title, metadata block, reason line). Footer actions are full width with the primary visually above Cancel via `column-reverse` on `.form-actions` (DOM and tab order: Cancel then primary).
- 1440 px: checkbox and title on one line, metadata on a second line, reason on a third line, footer actions side by side.

### 5.5 Accessibility

- `Modal.tsx` focus trap, `role=dialog` and `aria-modal` are reused for both modals.
- Escape, backdrop and close are suppressed only in flight.
- Focus returns to the trigger via a captured trigger plus a fallback selector (the `RegisterStudentModal` `fallbackTriggerSelector` precedent), including the new student-detail trigger and the duplicate-email pivot.
- First-invalid focus: the empty email, or the first radio of an unchosen fieldset with `role=alert`.
- One `aria-live` polite in-flight line.
- `role=alert` only for validation errors; `role=status` for informational notices.
- Native `disabled` attribute.
- Reason lines via per-row `aria-describedby` (the `StudentRoster` `revokedHintId` pattern, `CourseWorkspacePage.tsx:630-647`).
- WCAG 2.2 AA.

### 5.6 Visual rules

- Row title: body ink.900. Metadata: caption ink.700. Reason line: `.field-hint`. Legend: `.choice-group`.
- Status colours use the `--color-status-{success,warning,neutral,error}-*` families.
- Error text must not be terracotta.600 on paper.200 (4.052:1 fails AA; `src/__tests__/statusColorContrast.test.ts`), so ink.900 is used there. Neutral ink.700 on paper.100 is about 8.36:1.
- Disabled follows the `Field.css:56-62` contract.
- Nested fieldset indent is `--space-6` with a `--border-width-rule` ink.700 left border.
- Outcome divider is `--border-width-hairline` with `--space-4`. Outcome lines are plain text, not Badge or `AccountStatusPill`.
- `CohortRow` failures keep advisory severity with a secondary "Try again".
- The draft banner uses the neutral `.status-preserved` family.
- Motion and asset spec: not applicable. The never-published illustration defaults to `spot-02-compass-pocket-watch.png` (already imported).

### 5.7 Design engineering invariants

- No new tier, variant, token or typeface.
- One unified course list, never a Bands group; N counts course rows.
- One already-active wording.
- Students-tab cohort list, `StudentRoster` and enrollment-request reads resolve against the PUBLISHED version id (the course id for course-scoped calls) whenever a draft exists; content tabs keep the draft id.
- The duplicate-email conflict response (owner-only endpoint) includes the existing student's id and email, to route into Assign Courses with carried selections. Otherwise navigate to the student list filtered by that email. Never fabricate an id.
- `CohortRow` caches a successful load after first expand; each failed sub-load (members, directory) has its own "Try again" that re-fires only that fetch; the Students tab refreshes when the owner returns after creating a student.
- Account creation and enrollment stay separate in the UI.
- Retry never re-registers or rotates the credential.
- Lost credential recovery is only via the unmodified `ReissueAccessModal`.
- Explicit test (J-003): no outcome region, notice or button in the Add Student modal, the Assign Courses modal or the lost-credential notice renders text matching `/\b(sent|emailed|e-mailed|invitation|invite sent|check (your|their) (email|inbox))\b/i`. The query is scoped to the outcome regions so the email field label is excluded.
- No native dialogs; native `disabled`; `role=alert` only for validation.
- Explicit radio choice with no default.
- Cohort creation targets the published version.
- English-only admin copy.
- Never imply an email or invitation was sent.
- Plaintext temp password appears only in the single existing reveal.
- No visual cue marks band-backed rows beyond text.

### 5.8 Permitted variation and reviewer defaults

Permitted variation: copy wording within structure; picker-row component extraction; `SpotIllustration`; disabled DOM structure; spacing within `--space-2` to `--space-6` for the two new compositions; refresh-on-return as a full refetch or cache invalidation.

Reviewer defaults for remaining open items (non-blocking, adopted as plan defaults):

- Copy literal per target: "Rolling start: assigned to <band>, starting today" and "Assigned to <cohort> in <course>".
- Retry re-validates server-side and shows the real reason if a target is newly ineligible. It never resubmits blindly.
- Already-active rows state the conflict only (no Unassign link).
- A never-published course keeps the panel heading.
- A disabled `.choice-option` reuses the `Field.css` disabled contract via native `disabled`.

## 6. Judge route

Policy per `docs/JUDGE-CONTRACT.md`. Deterministic failures dominate. No judge result has been observed for this sub-plan yet; none is claimed.

| Checkpoint | PR A | PR B |
| --- | --- | --- |
| Risk | standard | high |
| PLAN_DUCK | not specified | REQUIRED on this sub-plan before approval; pass #1 (shadow) complete, see "Plan revision 1" |
| CODE_REVIEW | eligible (cap 2) | REQUIRED |
| VERIFICATION_CHALLENGE | not specified | optional |
| VISUAL_REVIEW | not specified | optional |
| Call cap | 2 | total 4 for #228 |

PR B rubric: authorization at Edge and SQL, all-or-none batch, idempotency and retry convergence, credential handling, #222 ACL preservation. Finding IDs from any judge pass flow to T1 as remediation items and to the Verifier as checks.

PLAN_DUCK status: pass #1 (Codex "Terra", shadow, advisory) returned J-001, J-002 and J-003, all accepted and remediated in revision 1 (see "Plan revision 1"). Judge accounting: 1 of the cap of 4 used; a repeat is at the lead's discretion. CODE_REVIEW findings must keep these IDs traceable: the J-001 rollback-preservation test, the J-002 state-machine tests T-a to T-h, and the J-003 no-email-claim test are named verification items for the Verifier.

## 7. Browser UI dialog policy

Required. No `alert`, `confirm`, `prompt`, `window.alert`, `window.confirm`, `window.prompt` or `beforeunload`. Acknowledgement and confirmation go only through the app-owned `src/components/Modal.tsx` with Escape/Close and focus return; inline validation is used where it serves the user better. Verification is a deterministic source scan plus a runtime dialog listener, plus modal keyboard, focus and return verification for the Add Student modal, the Assign Courses modal and the `ReissueAccessModal` hand-off.

## 8. Ordered work

Owner is T1 unless stated; T2 on escalation. One writer at a time.

### Step 0 (both PRs)

Fetch `origin`; record the SHA; create a fresh worktree (PR A from then-current `origin/main`; PR B from PR A's then-current branch head, D-5); re-verify every cited line; build the port-shifted untracked mirror (section 3.7); record the baseline as a full vitest run plus a full e2e run on a fresh `npx supabase db reset` in the mirror, compared with section 3.8.

### P0: read-only production check (D-4; after Step 0, before PR A code)

D-4 is approved. This step does not block implementation if it cannot run. Results go to a Scribe evidence file, `docs/evidence/lizbeth-spanish-issue228-prod-readonly-<date>.md`, with counts and opaque IDs only.

**Who runs it.** The user, with the user's own credentials. The lead may run it only if the user explicitly provides a read-only session in this conversation. Agents never store or echo the database password or service-role key, and no agent receives the service-role key for this step.

**Tools.**

1. Supabase CLI, already logged in as the user: `npx supabase migration list --linked` (applied migrations) and `npx supabase functions list --project-ref <ref>` (deployed Edge Function versions and `updated_at` for `course-authoring`, `admin-student-operations`, `site-content`).
2. Netlify: `npx netlify api listSiteDeploys --data "{\"site_id\":\"<site-id>\"}"` or the Netlify dashboard, to record the published production deploy's commit SHA.
3. SQL through the Supabase Dashboard SQL editor, or `psql "<user-provided connection string>"`, with every batch wrapped as `begin transaction read only; ... rollback;`.

**Exact queries** (SELECT-only; aggregates or opaque IDs; no emails, names or user_ids in the output):

- Q1: `select version from supabase_migrations.schema_migrations order by version desc limit 5;`
- Q2: `select cv.status, count(*) from public.student_enrollments se join public.course_versions cv on cv.id = se.course_version_id where se.status = 'active' group by cv.status;`
- Q3: `select se.id as enrollment_id, se.course_version_id, cv.version_no, cv.course_id, se.cohort_id, se.created_at from public.student_enrollments se join public.course_versions cv on cv.id = se.course_version_id where se.status = 'active' and cv.status <> 'published' order by se.created_at;`
- Q4: `select c.id as cohort_id, c.course_version_id, cv.status, c.created_at from public.cohorts c join public.course_versions cv on cv.id = c.course_version_id where cv.status <> 'published' order by c.created_at;`
- Q5: `select course_id, max(version_no) filter (where status = 'published') as latest_published, max(version_no) filter (where status = 'draft') as latest_draft from public.course_versions group by course_id having max(version_no) filter (where status = 'draft') > coalesce(max(version_no) filter (where status = 'published'), 0);`
- Q6: `select count(*) as never_signed_in_without_active_enrollment from auth.users u where u.last_sign_in_at is null and not exists (select 1 from public.student_enrollments se where se.user_id = u.id and se.status = 'active');` Aggregate only. Assumption: the owner account has signed in, so it is excluded in practice.

**Interpretation.** Q3 or Q4 non-empty, plus Q5 showing a newer draft, supports the #140/#183 mechanism as the production cause. Empty results leave the cause unconfirmed. No repair is performed; any targeted repair needs new evidence, its own plan, and approval.

### Reproduction (before PR A code)

T1, local only, disposable fixtures. T1 returns facts; Scribe records them in `docs/evidence/lizbeth-spanish-issue228-repro-<date>.md`.

- R1: Owner (`owner@test.local` / `password`) registers a disposable student on `/admin/students`; confirm `last_sign_in_at IS NULL` (service-role read on the local stack only).
- R2: Student detail "Assign a new band" before any student sign-in. Expect success. Record the response and the enrollment and entitlement rows.
- R3: For an authored or band-backed course with only a published version, create a cohort in the Students tab, expand it, confirm the new student is listed, and Invite. Expect enrollment and entitlements. Sign in as the student and confirm the course is on `/learn`.
- R4: (#140/#183 path) On a seeded band-backed course click "Create draft from current version". On the Students tab record that published cohorts disappear, the roster is empty, and the network shows a 404 from `course-authoring` `list_enrollment_requests` with "No enrollment requests." rendered. Create a cohort (it lands on the draft version), invite the new student ("now enrolled"), sign in as the student: the course is absent from `/learn`.
- R5: Directory. Force a `getRoster` failure on first `CohortRow` expand and confirm there is no retry control. Create 55 disposable users and record whether a newly created student appears in `getRoster`'s first page (GoTrue default page size and order).
- R6: Record which step reproduces the owner's report. If none reproduces a first-login dependency, record the production cause as unconfirmed (the issue permits this) and cross-reference the P0 read-only production check (D-4, approved) for deployed frontend, Edge and migration versions.

### PR A (#140 and #183), T1 with TDD

- A1: Write the tests first (section 9).
- A2: `courseAuthoring.getCourse` additionally returns `published_version_id` and `published_version_no` (the latest published version; versions are ordered `version_no` descending) without changing `id` (draft-else-latest, still used by the editing tabs).
- A3: `CourseWorkspacePage`:
  - Students receives the real course id and `publishedVersionId`.
  - Students cohorts are the cohorts on `publishedVersionId`.
  - `StudentRoster` gets `courseVersionId=publishedVersionId` and `published=!!publishedVersionId`.
  - `listEnrollmentRequests(course.course_id)`.
  - `CohortForm` creates on `publishedVersionId`.
  - A `draft_exists` banner.
  - A `never_published` `JournalEmptyState` with "Go to Publish" (navigates to the publishing tab).
  - Outline, Content, Settings and Publishing are unchanged.
- A4: Edge `course-authoring` `list_enrollment_requests`: when `course_id` is present (already ownership-checked as a course id), restrict to requests whose cohort belongs to a version of that course. Without `course_id`, keep the current owner-wide behaviour.
- A5: Edge invite: reject with 422 `{error_code:'version_not_published'}` when the cohort's version is not published, and write nothing (decision D-2).
- A6: Publishing prop rename `courseId` to `courseVersionId` (from #197; rename only).
- A7: Update existing tests intentionally, with no weakening.

### PR B (#228), stacked on PR A's branch; T1 with TDD (T2 on escalation)

**B1. Migration** `supabase/migrations/<timestamp later than main's latest>_issue228_student_onboarding.sql` (forward-only; uses `create table if not exists` and `create or replace function`, so re-applying after a rollback is safe and reuses preserved rows) and `supabase/rollbacks/issue228_student_onboarding_rollback.sql`.

- Table `public.student_onboarding_operations`:
  - `id uuid` PK (the client operation key); `unique (id, owner_id)` for keyed lookups; `owner_id uuid not null`; `kind text` check in (`'create_and_assign'`, `'assign_existing'`); `email_normalized text`; `request_fingerprint text not null`; `phase text not null` with a check constraint on the phase set (`'started'`, `'creating_account'`, `'account_created'`, `'granting'`, `'completed'`, `'assignments_failed'`); `student_id uuid null`; `results jsonb not null default '[]'`; `last_error jsonb`; `lease_token uuid null`; `lease_expires_at timestamptz null`; `created_at`; `updated_at`.
  - State machine: `started` to `creating_account` to `account_created` to `granting` to `completed` or `assignments_failed`; `assignments_failed` returns to `granting` on retry.
  - NO password or credential column.
  - RLS enabled with no policies; revoke all from `public`, `anon`, `authenticated`; `service_role` only.
- `public.transition_onboarding_operation(p_operation_key uuid, p_owner_id uuid, p_kind text, p_fingerprint text, p_email_normalized text, p_action text, p_lease_token uuid, p_student_id uuid, p_error jsonb) returns jsonb`, SECURITY DEFINER, EXECUTE revoked from `public`, `anon`, `authenticated`; `service_role` only (third service-only function; see D-3a). Actions:
  - `'acquire'`: `insert ... on conflict (id) do nothing`, then `select ... for update` on the row. If `owner_id` or the fingerprint differ, return `operation_key_conflict`. If the phase is `completed`, return the stored results (replay). If a live lease is held (`lease_expires_at > now()`), return `operation_in_progress` (retryable). Otherwise issue a new `lease_token` with `lease_expires_at = now() + interval '60 seconds'` and return the phase, `student_id` and `lease_token`.
  - `'begin_account'` (`started` to `creating_account`; needs the matching lease), `'account_created'` (records `student_id`; `creating_account` to `account_created`), `'begin_grant'` (`account_created` or `assignments_failed` to `granting`), `'fail'` (records `last_error`; goes to `assignments_failed`, or back to `started` if no account exists), `'release'`.
  - Every transition is a compare-and-set on `(id, owner_id, phase, lease_token)` under a row lock. A stale or foreign lease returns `lease_lost` and changes nothing.
- `public.grant_onboarding_targets(p_owner_id uuid, p_user_id uuid, p_operation_id uuid, p_lease_token uuid, p_targets jsonb) returns jsonb`, SECURITY DEFINER, `set search_path=public`, EXECUTE revoked from `public`, `anon`, `authenticated` and granted to `service_role`.
  - Locks the operation row `FOR UPDATE` first and requires phase `granting` with the matching live lease. A replay with phase `completed` returns the recorded results.
  - Validates every target before any write. `{type:'cohort', cohort_id}` must be owned by `p_owner_id` on a PUBLISHED version. `{type:'band', course_id}` must be owned, have `legacy_band_id` set, and have a resolvable published version (reuse the `202610030001` resolver; NULL means reject).
  - Rejects duplicate targets and two targets sharing a `band_id`.
  - Locks cohort rows in deterministic id order.
  - Delegates to `grant_cohort_enrollment` for cohorts (idempotent) and `assign_band_enrollment` for bands. An existing active (user, band) enrollment counts as success only if this operation's recorded results already contain it; otherwise it is a conflict.
  - Writes results and `phase='completed'` to the operation row in the SAME transaction. Any failure rolls back every grant (all-or-none).
  - Structured SQLSTATEs for capacity (P4002), prerequisite (P4001), unpublished or unresolvable, foreign owner, and duplicate or conflict.
- `public.find_auth_user_for_onboarding(p_email text) returns (id uuid, onboarding_operation_id text, is_owner boolean)`, reading `auth.users` by `lower(email)`; `service_role` only.
- Extend the `anonFunctionExecuteGrants` and `authenticatedFunctionExecuteGrants` expectations for the new functions (`grant_onboarding_targets`, `find_auth_user_for_onboarding`, `transition_onboarding_operation`: all denied).
- Rollback file (J-001): `supabase/rollbacks/issue228_student_onboarding_rollback.sql` drops ONLY the three service-only functions. The new Edge actions are reverted in the same code revert. The rollback RETAINS `public.student_onboarding_operations` and its rows (still RLS-enabled, no policies, `service_role`-only grants), so the table stays inert and does not interfere with the existing register and assign paths.
- Preserving export before any rollback (local, or later on hosted data with separate approval): `\copy (select id, owner_id, kind, phase, student_id, results, last_error, created_at, updated_at from public.student_onboarding_operations order by created_at) to 'onboarding-operations-<date>.csv' csv header`. The export leaves out `email_normalized` to reduce PII. The file goes in a private local location and is never committed.
- Dropping the table is a separate later step, allowed only after reconciliation shows no row with `phase <> 'completed'`. It needs its own explicit user approval and its own one-line SQL (`drop table public.student_onboarding_operations`) and is not part of the rollback file.
- Post-rollback reconciliation (manual, owner-facing, existing features only): run the read-only query `select o.id, o.phase, o.student_id, o.results, u.created_at, u.last_sign_in_at from public.student_onboarding_operations o left join auth.users u on u.id = o.student_id where o.phase <> 'completed'`, plus `select id from auth.users where raw_app_meta_data ? 'onboarding_operation_id' and id not in (select student_id from public.student_onboarding_operations where student_id is not null)` (accounts created by an operation whose row never recorded them). For each account found, the owner assigns courses through the existing student-detail band picker or the cohort Invite. A row in phase `started` with no account needs no action. Temporary-password loss uses the existing re-issue access button on student detail.

**B2. Edge `admin-student-operations`** (existing owner gate; actor id from the verified token only).

- `onboarding-targets` (read): the owner's non-archived courses with the latest published version, eligible cohorts (name, mode, `starts_at`, capacity and remaining), legacy-band flag, and prerequisite info. An optional `student_id` adds already-active conflicts.
- `create-and-assign` `{email, targets[], operation_key}`:
  - Compute a fingerprint (normalized email plus sorted targets).
  - Algorithm (J-002; replaces the earlier load/insert wording):
    1. `acquire` through `transition_onboarding_operation`. A different owner or fingerprint gives 409 `operation_key_conflict`. A live lease held by another caller gives `operation_in_progress`.
    2. If the phase is `completed`, replay the stored results with `credential_unavailable:true` and no `temp_password`.
    3. If the phase is `creating_account` with an expired lease, `account_created`, or `assignments_failed`, reconcile first: call `find_auth_user_for_onboarding(email)` and adopt the user only if its `app_metadata.onboarding_operation_id` equals the key.
    4. Otherwise `begin_account`, then `auth.admin.createUser({email, password, email_confirm:true, app_metadata:{onboarding_operation_id: key}})` (no role field). Dry-run validate targets before creating Auth where possible.
    5. On duplicate email: adopt only on a matching operation id (lost response; `credential_unavailable:true`); otherwise return 409 `duplicate_email` with the existing student id and email, and `release`. Never adopt an unrelated account and never reset credentials.
    6. `account_created` (stores `student_id`), then `begin_grant`, then `grant_onboarding_targets` when targets are non-empty.
    7. On failure, `fail` with `last_error`, and return `account_created:true`, `temp_password` (only when created in this request) and per-target errors.
  - Because of the `app_metadata` provenance, the Auth step is idempotent across lost responses. The lease stops two callers from running `createUser` or the grant at the same time.
  - The client treats `operation_in_progress` as retryable (bounded backoff, the same key, a `role=status` "Still working..." line), never as a failure and never with a new key.
  - Never log or persist the temp password.
- `assign-courses` `{student_id, targets[], operation_key}`: validates that the student exists and is not an owner; uses the same RPC; `kind` is `assign_existing`.
- `handleGetRoster` uses `listAllAuthUsers` (pagination).

**B3. Client.**

- `src/services/adminStudentData.ts`: `getOnboardingTargets`, `createStudentWithAssignments`, `assignCoursesToStudent` (structured results). The operation key is generated once per modal session and reused for every retry; it is held in memory only and never in browser storage.
- `RegisterStudentModal` extended per the design.
- A new Assign Courses modal (`Modal.tsx`) from student detail and the duplicate-email pivot.
- Outcome regions; Retry assignments; "Reissue temporary password" (J-003) opens the existing `ReissueAccessModal` unchanged, and the owner then shares the new temporary password directly. The existing student-detail button keeps its current label.
- Handle `operation_in_progress` with bounded backoff and the same key (see B2).
- Roster, detail and course roster refresh after success.
- `CohortRow` directory "Try again" plus Students-tab refresh on return.

**B4.** Tests, then verification gates.

### Gates per PR

T1, then CODE_REVIEW (required for PR B), then Verifier (independent), then Browser Validator, then PR opened. Two counted T1 gate failures escalate to T2; two counted T2 failures block for user review. Research, stale plans, credentials and unavailable prerequisites do not count.

### Implementation order across the wave

One writer at a time, in this order:

1. PR A (#140/#183) on `fix/140-183-students-tab-published-version` from then-current `origin/main`.
2. PR B (#228) on `feat/228-create-and-assign`, stacked on PR A's branch.
3. #227 on its own branch, stacked on PR #229's branch (see the #227 plan, `docs/plans/lizbeth-spanish-issue227-site-copy-editor-preview.md`).

Rationale: PR A is the prerequisite for PR B and shares files with it, so doing them back to back keeps one writer's context on the Students-tab and enrollment path and limits rebase churn. #227 touches only the site-content editor files and is independent of both, so going last costs nothing. Stacked PR mechanics are in section 2. The user merges in order: PR A, then PR B.

## 9. Interfaces and data

- **PR A:** `courseAuthoring.getCourse` gains `published_version_id` and `published_version_no` (additive). Edge `list_enrollment_requests` gains course scoping when `course_id` is supplied (a behaviour change for that action only; the only client caller is the Students tab). Edge invite gains a `version_not_published` 422. No migration. Edge deploy of `course-authoring` is a separate user-approved release step.
- **PR B:** a new table and 3 service-only functions (`grant_onboarding_targets`, `find_auth_user_for_onboarding`, `transition_onboarding_operation`; forward-only migration plus a rollback file that drops only the functions and retains the table and rows, J-001); new Edge actions `onboarding-targets`, `create-and-assign` and `assign-courses`; the existing register and assign actions are unchanged and still supported.
- **Response contract:** `{account:{status:'created'|'existing'|'reused', student_id, email, temp_password?, credential_unavailable?}, assignments:[{target, status:'granted'|'failed'|'skipped', enrollment_id?, error_code?, message?}], operation:{key, phase}}`; 409 `{error_code:'duplicate_email', existing_student:{id,email}}` and 409 `{error_code:'operation_key_conflict'}`; retryable `{error_code:'operation_in_progress'}` (J-002); `lease_lost` is internal to the SQL transitions.
- **Data impact:** HIGH RISK (migration, Auth, RLS/ACL). No backfill, no blanket profile migration, no student re-creation. Existing never-signed-in students use `assign-courses`. A read-only audit of existing enrollments pinned to unpublished versions runs locally now; the read-only production check is step P0 (D-4, approved), run by the user with the user's own credentials.
- **Hosted rollout** (migration apply, Edge deploys of `course-authoring` and `admin-student-operations`, Netlify) is a SEPARATE user decision (parent D-10).

## 10. Acceptance and validation

### 10.1 Commands

Run in the port-shifted mirror. Full suites are required; targeted runs are additional, never substitutes.

- `npm ci`; `npm run type-check`; `npm run lint` (0 errors); `npm run verify:build`.
- `npx supabase start`; `npx supabase db reset`; `docker restart supabase_kong_lizbeth_spanish supabase_rest_lizbeth_spanish supabase_edge_runtime_lizbeth_spanish` (T1 Step 0 confirms the container names in the mirror).
- Full unit/integration: `npx vitest run` (live suites need the reset stack). No new failures against the recorded baseline (section 3.8).
- Dev server: `npx vite --port 5180 --strictPort` (ready when `http://localhost:5180` serves the sign-in page; the mirror `.env.local` points at `http://127.0.0.1:64321`).
- Full e2e: `E2E_BASE_URL=http://localhost:5180 npx playwright test` (`playwright.config.ts`: `testDir` `src/__tests__/e2e`, workers 1, chromium).
- No-native-dialog scan: `rg -n "\b(window\.)?(alert|confirm|prompt)\s*\(|beforeunload" src --glob "!src/__tests__/**"` returns zero product hits, plus `page.on('dialog')` failing listeners in every new or changed spec.

### 10.2 PR A targeted

- `npx vitest run src/__tests__/issue140-183-studentsTabPublishedVersion.test.tsx src/__tests__/issue183-enrollmentRequestsLive.test.ts src/__tests__/cohortMembersAndInvite.test.tsx src/__tests__/cohortInviteEnrollmentUi.test.tsx src/__tests__/cohortInviteEdgeContract.test.ts src/__tests__/cohortInviteEnrollmentGrant.test.ts src/__tests__/issue5BackendContract.test.ts`
- e2e: `npx playwright test src/__tests__/e2e/issue140-183-students-tab.spec.ts src/__tests__/e2e/wp8-course-workspace.spec.ts`

PR A TDD list:

- `getCourse` `published_version_id` for published-only, published v1 plus draft v2, and draft-only.
- Students tab with draft v2 lists v1 cohorts; `StudentRoster` is requested with the v1 id; `listEnrollmentRequests` is called with the course id; `CohortForm` `createCohort` is called with the v1 id; the draft banner is shown.
- A draft-only course shows the never-published state and no invite or create controls.
- Outline still receives the draft-version cohort set (unchanged).
- Edge `list_enrollment_requests`: own course id gives 200 filtered to that course; another owner's course id gives 404; no `course_id` is unchanged (owner-wide list).
- Edge invite into a draft-version cohort gives 422 `version_not_published` and no enrollment or membership row.
- The Publishing rename compiles with no behaviour change.

### 10.3 PR B targeted

- `npx vitest run src/__tests__/issue228-onboarding-sql.test.ts src/__tests__/issue228-create-and-assign-edge-live.test.ts src/__tests__/issue228-roster-pagination-live.test.ts src/__tests__/issue228-operation-state-machine.test.ts src/__tests__/issue228-rollback-preserves-operations.test.ts src/__tests__/issue228-RegisterStudentModal-assign.test.tsx src/__tests__/issue228-AssignCoursesModal.test.tsx src/__tests__/RegisterStudentModal.test.tsx src/__tests__/RegisterStudentModal-FocusRestore.test.tsx src/__tests__/RegisterStudentModal-StaleError.test.tsx src/__tests__/AdminStudentsPage.test.tsx src/__tests__/AdminStudentModals.test.tsx src/__tests__/adminStudentOperationsFixes.test.ts src/__tests__/adminStudentAuthorization.test.ts src/__tests__/cohortInviteEnrollmentGrant.test.ts src/__tests__/cohortMembersAndInvite.test.tsx src/__tests__/issue176-completion-edge-live.test.ts src/__tests__/issue176-completion-foundations-sql.test.ts src/__tests__/anonFunctionExecuteGrants.test.ts src/__tests__/authenticatedFunctionExecuteGrants.test.ts src/__tests__/statusColorContrast.test.ts`
- e2e: `npx playwright test src/__tests__/e2e/issue228-create-and-assign.spec.ts src/__tests__/e2e/gap-4-admin-students-remediation.spec.ts src/__tests__/e2e/issue-57-modal-background-inertness.spec.ts src/__tests__/e2e/wp4-roster.spec.ts` (`wp4-roster` compared with #218).

PR B TDD list:

- **SQL**
  - anon and authenticated cannot execute `grant_onboarding_targets`, `find_auth_user_for_onboarding` or `transition_onboarding_operation`, or read `student_onboarding_operations`.
  - State machine (J-002), new `src/__tests__/issue228-operation-state-machine.test.ts` against the SQL functions directly (deterministic, local stack), plus Edge-level cases in `issue228-create-and-assign-edge-live.test.ts`:
    - T-a: two concurrent acquires on a new key insert exactly one row and grant exactly one lease; the other gets `operation_in_progress`.
    - T-b: lost response after acquire, before Auth. The lease expires (shortened in the test by a direct service-role update of `lease_expires_at`), and a retry acquires and proceeds.
    - T-c: lost response after `createUser` succeeds but before `account_created` is recorded. The retry finds the user by the `app_metadata` operation id and adopts it; there is never a second auth user for the email.
    - T-d: a concurrent retry while the first caller holds the lease during Auth gets `operation_in_progress`, and `createUser` is not called twice (the Edge test asserts one auth user).
    - T-e: lost response after the grant commits. The retry replays the completed results, with no extra enrollment rows, capacity use, or date or progress change.
    - T-f: two concurrent grant attempts. One runs and the other sees `lease_lost` or completed; the grants are unchanged.
    - T-g: the same key from a different owner gives `operation_key_conflict`; the same key with a different fingerprint gives `operation_key_conflict`.
    - T-h: a stale lease token after expiry and re-acquisition makes every transition return `lease_lost` and change nothing.
    - No production fault-injection seam is added. Lost-response cases are simulated by calling the SQL steps in sequence and by repeating Edge calls with the same key.
  - Rollback preservation (J-001), new `src/__tests__/issue228-rollback-preserves-operations.test.ts` (local stack): populate operations in every phase; apply the rollback SQL; assert the table and rows survive and the three functions are gone; run both reconciliation queries and assert the expected rows; re-apply the forward migration and assert existing rows are intact and the functions work again with the same operation keys (an idempotent replay returns the recorded results).
  - Create plus assign of two valid targets with `last_sign_in_at` NULL yields enrollments, memberships, pinned published versions and entitlements before any sign-in.
  - One full cohort (P4002) or an unmet prerequisite (P4001) in a batch rolls back every grant.
  - Unpublished or unresolvable version, foreign-owner cohort, duplicate targets, and two targets on one band are rejected with specific codes.
  - Re-running the same operation returns identical results with no double capacity, date or progress change.
  - Concurrent batches on the same cohorts serialize (deterministic lock order) without deadlock.
  - An existing active band enrollment not created by this operation gives a conflict.
- **Edge** (owner-only)
  - Anonymous gets 401, non-owner gets 403, and a forged owner id in the payload is ignored.
  - Double submit with the same key yields one account and one grant per target.
  - Key reuse with a different payload gives 409 `operation_key_conflict`.
  - A second call after completion returns completed results without `temp_password` and with `credential_unavailable`.
  - An assignment failure leaves the account created with phase `assignments_failed`; a retry with the same key grants without re-registering or changing the password.
  - An unrelated existing email gives 409 `duplicate_email` with id and email and no credential change.
  - The student's first sign-in shows every granted course on `/learn` (`get_student_learn_index`), and another student cannot see them.
  - No row, column or log contains the temp password (search the operation row JSON).
  - `getRoster` returns a student beyond the first Auth page (more than 50 users; local disposable users, cleaned up).
- **UI / RTL**
  - Zero preselection and "Create account only"; the label count.
  - Single-target rows have no fieldset; a multi-option fieldset has no default and the alert moves focus to the first radio.
  - Outcome regions are separated; Retry is scoped to failed targets.
  - Duplicate-email pivot with carried selections, and the fallback filtered navigation.
  - The lost-credential route ("Reissue temporary password") opens `ReissueAccessModal`.
  - No-email-claim text test (J-003), in RTL and e2e: no outcome region, notice or button in the Add Student modal, the Assign Courses modal or the lost-credential notice matches `/\b(sent|emailed|e-mailed|invitation|invite sent|check (your|their) (email|inbox))\b/i`; the query is scoped to the outcome regions so the email field label is excluded.
  - `operation_in_progress` is retried with the same key and a `role=status` "Still working..." line, never shown as a failure.
  - The Assign Courses modal is disabled at zero selections and shows disabled already-active rows.
  - Focus returns to the triggers.
  - `CohortRow` directory "Try again" and refresh on return.
  - The existing `RegisterStudentModal` reveal and copy, and the no-forced-password copy, are unchanged.

### 10.4 Fixtures

Local disposable per-run accounts and cohorts created by the tests, with cleanup. Never seeded or real student accounts. Assertions refuse non-local Supabase URLs.

## 11. Browser UI validation

- **Launch and readiness:** in the port-shifted mirror of the PR worktree: `npx supabase start`; `npx supabase db reset`; docker restart (as in section 10.1); `npx vite --port 5180 --strictPort`; ready when `http://localhost:5180` serves the sign-in page.
- **Base URL:** `http://localhost:5180` (`E2E_BASE_URL=http://localhost:5180`).
- **Fixture and reset:** `npx supabase db reset`; `owner@test.local` / `password`; disposable per-run students. Courses needed: one authored course with one published cohort; one with two published cohorts; one band-backed seeded course with no cohort; one band-backed with a cohort; one never-published course; one course with published v1 plus a newer draft (via "Create draft from current version"); one cohort at capacity; one course with an unmet prerequisite. Also a forced `getRoster` failure via route interception and a forced assignment failure for the partial-failure journey.
- **Viewports:** 390x844 and 1440x900 for every journey (320 and forced-colors spot checks).

### PR A journeys

- J-A1: course with v1 published and v2 draft at `/admin/courses/<id>/students`: published cohorts listed, Student roster rows visible, draft banner present, enrollment-requests panel loads with no 404 from `course-authoring` (network assertion).
- J-A2: create a cohort there; it attaches to v1 (service-role read), and Invite of a disposable student results in `/learn` showing the course after the student's first sign-in.
- J-A3: a never-published course shows "Publish before enrolling students", and Go to Publish lands on the publishing tab.
- J-A4: Content and Outline tabs still show draft content.
- J-A5: invite into a draft cohort created via service role returns the `version_not_published` message and no enrollment.

### PR B journeys (design brief 1 to 14)

- J1: mixed selection (multi-cohort course with a chosen cohort, plus a band-backed course with Rolling start) gives label "Create account and assign 2 courses", both granted, and Done returns focus to Add Student.
- J2: single-target rows have no fieldset.
- J3: band-backed with cohorts has no default; submitting without a choice focuses the first radio with `role=alert`.
- J4: account only gives the zero-state, and "Assign courses now" pivots without re-registration.
- J5: an already-active conflict row is disabled with a reason from either source.
- J6: partial failure gives per-target reasons; Retry is scoped to failed only; the granted row is untouched.
- J7: lost credential gives the informational notice, then "Reissue temporary password" opens `ReissueAccessModal` with forced-password-change copy; no outcome text claims an email or invitation was sent (J-003).
- J8: duplicate email with id lands on the matched student with carried selections; the fallback without id lands on the filtered student list.
- J9: student detail "Assign courses" beside the unchanged "Assign a new band"; zero selection is disabled.
- J10: Students tab draft-over-published (as J-A1) with the content tab still on the draft.
- J11: `CohortRow` with members OK and a directory failure shows only the directory "Try again"; recovery; cached re-expand without a loading flash; refresh after returning from creating a student.
- J12: never-published state.
- J13: no-native-dialog scan across all screens.
- J14: keyboard. Tab order is close, email, rows, nested radios, Cancel, primary. Escape is suppressed only in flight. Focus returns to the exact trigger. The reveal phase is Done-only.

### Visible outcomes and evidence

Screenshots per journey and viewport under `browser-validation-artifacts/issue-228/` and `browser-validation-artifacts/issue-140-183/`; a first-sign-in `/learn` screenshot for a student assigned before first login; network logs proving no 404 and no duplicate grants; the dialog-listener log; axe zero critical or serious on the modals and the Students tab; a contrast spot check on the banner and failed-target lines; no horizontal scroll at 390 and 320.

## 12. Risks and rollback

| ID | Risk | Mitigation |
| --- | --- | --- |
| R1 | Auth/DB non-atomicity | Durable operation record with a lease-based state machine (J-002), `app_metadata` provenance, reconcile-first retry with the same key, no auto-delete or password reset; tests T-a to T-h |
| R2 | Duplicate grants or capacity drift | Idempotent SQL path, operation results, `grant_onboarding_targets` requires phase `granting` with a live lease, concurrency tests T-a, T-d, T-f |
| R3 | Privilege escalation | Service-only functions, #222 ACL tests extended, Edge owner gate, actor from token |
| R4 | Credential leakage | No password storage; log and row search test |
| R5 | Unpublished enrollments | SQL and Edge publication checks |
| R6 | Behaviour change in `list_enrollment_requests` | Course scoping only when `course_id` is supplied; single caller |
| R7 | Existing draft-pinned enrollments from the pre-fix bug | Read-only audit (local) and the P0 read-only production check (D-4); no repair without new evidence |
| R8 | Stale plan if `origin/main` changes cited paths or PR #229 or others conflict | Step 0 re-verification; stale-plan return |
| R9 | `wp4-roster` pre-existing failure masks regressions | Compare per test with the #218 list |
| R10 | Port-mirror drift | Mirror rebuilt from the PR worktree each run, never committed |

Rollback: PRs stay unmerged until the user merges; post-merge revert is per PR. The PR B rollback file (J-001) drops ONLY the three service-only functions; the operation table and its rows are retained, inert (RLS-enabled, no policies, `service_role`-only). Revert the Edge actions in the same code revert. Re-applying the forward migration is safe (`create table if not exists`, `create or replace function`) and reuses the preserved rows. Export before any rollback and the manual reconciliation queries are in B1. Dropping the table is a separate later step that needs its own explicit user approval and is allowed only when no row has `phase <> 'completed'`. Local `npx supabase db reset` restores fixtures. No hosted change occurs under this plan.

## 13. Assumptions, decisions and approvals

### Safe assumptions

- Legacy band courses keep one active enrollment per (user, band).
- Cohort grant remains idempotent.
- GoTrue `createUser` accepts `app_metadata` via service role.
- Seeded fixtures include band-backed courses with published versions (no seeded cohorts or drafts; tests self-provision).

### Decisions

| ID | Decision | Status |
| --- | --- | --- |
| D-1 | Approve this sub-plan (two PRs, order, scope) | Revised for PLAN_DUCK; final approval of the revised plan REMAINING |
| D-2 | Edge invite guard rejecting unpublished-version cohorts | YES (2026-10-11) |
| D-3 | Forward-only migration with service-only RPCs and the operation table (high risk; local only) | APPROVED (2026-10-11) |
| D-3a | Confirm the THIRD service-only function, `public.transition_onboarding_operation`, added by the J-002 remediation (same ACL: EXECUTE revoked from `public`, `anon`, `authenticated`; `service_role` only) | REMAINING: user confirmation at final approval |
| D-4 | Read-only production check (step P0) | APPROVED (2026-10-11); "D-4 approved" |
| D-5 | Stack PR B on PR A's branch; merge in order | STACK (2026-10-11) |

Remaining decisions: D-1 final approval of the revised plan; D-3a confirm the third service-only function. Hosted migration, Edge and Netlify deploys remain separate later approvals (parent D-10).

### Stale-plan conditions

`origin/main` changes a cited path's behaviour; issue #228, #140 or #183 text or comments change scope; reproduction contradicts a root-cause claim materially; a decision above is reversed.

### Approval gate

This plan is DRAFT (revision 1). T1 execution requires explicit user approval relayed by the lead; Scribe then updates this status to approved. No approval has been recorded.
