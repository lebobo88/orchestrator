# Lizbeth Spanish — FJDS Carry-Forward Fixes

**Status: APPROVED 2026-09-14 (user: Rob)**

- task_id / plan_id: `lizbeth-spanish-fjds-carry-forward-fixes`
- route: engineering
- target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (React 18 + Vite + TypeScript, local Supabase); orchestrator docs live under `H:\CommandCenter\orchestrator\docs`
- engineering_mode: standard
- downstream_owner: engineering-fleet
- team_authorization: not applicable

## Current implementation status — 2026-09-15

This dated addendum records the implementation state after the approved work-package plan was executed. The original scope, design decisions, and pre-execution findings below remain historical records; this section supersedes their current-status wording for WP-E / `#166` and the follow-up `#170`.

- **WP-C / `#164` course management:** the owner-facing archive/unarchive path is implemented locally and its earlier local verifier/browser gates are recorded below. `CourseSettingsPage` now lists active and archived courses separately, with owner-gated archive/unarchive behavior and the active-course empty state.
- **WP-E / `#166`:** implementation is complete locally. Journey 1 now uses the seeded `student7@test.local` pending-first-login fixture rather than a timestamped residue row. Independent local Chromium validation passed 4/4 in 28.7 seconds with one worker; two fixture restores returned HTTP 200, the sign-in probe returned HTTP 200, and 14 fresh screenshots were captured under `browser-validation-artifacts/status-clarity-gate`. AGY review used the required model `gemini-3.8-flash-medium` and returned `PASS` (conversation `d4e4feaf-e3c8-468d-b345-cc3d14f522f9`). GitHub issue `#166` remains open; no external closure was authorized here.
- **Follow-up `#170`:** the repaired course-workspace coverage passes 27/27, with the repeat affected set passing 12/12 and focused #49 coverage passing 8/8. The issue remains open pending final review; no issue closure is claimed.
- **Local validation snapshot:** fresh full Vitest passes 3,142/3,142 across 254 file results; type-check exits 0; scoped ESLint reports 0 errors and 813 warnings. Focused issue-164 security coverage is 2/2 and adjacent backend coverage is 21/21. Existing #166 Chromium evidence is 4/4. No full suite or browser rerun is required in this documentation-only step.
- **Production target/configuration:** the user selected Supabase project `gvobtuhbpqvfhjljjcye` and confirmed Netlify's Supabase variables were updated. No secret values are recorded, and this documentation update did not overwrite them. Current Netlify deploy `6a91c5a16bd89d0008ba7b80` remains the ready/locked frontend rollback baseline. The exact owner assignment for `thereallizbeth@gmail.com` is complete. Both hosted security migrations are applied and verified; the anonymous archived-preview policy is resolved to disable archived anonymous preview while retaining enrolled-student access. The existing legacy projection remains empty because the one-time backfill was not run and awaits explicit user approval.

This addendum does not claim that all release gates are green, that the current published artifact uses the new target, or that either GitHub issue is externally closed.

## Release packaging freshness pass — 2026-09-15

The bounded release-packaging step completed its fresh local validation and documentation review. The child repository remains intentionally dirty until explicit logical staging; unrelated design, scratch, generated, and YAML-only work is preserved.

- Fresh full Vitest: **254 file results, 3,142/3,142 tests passed**. This supersedes the earlier 3,139/3,140 and 3,140/3,140 snapshots.
- Existing scoped evidence remains: RLS 36/36; repaired E2E 27/27 including #170; repeat affected E2E 12/12; focused #49 8/8; #166 Chromium 4/4 with AGY `PASS` (`gemini-3.8-flash-medium`, conversation `d4e4feaf-e3c8-468d-b345-cc3d14f522f9`).
- Hosted backend step is complete only as `DEPLOYED_WITH_LIMITS` on `gvobtuhbpqvfhjljjcye`: the three required functions are ACTIVE v1 with JWT verification enabled. The authoritative receipt is `docs/evidence/lizbeth-spanish-backend-readiness-20260915.md`; the exact owner assignment is separately receipted, and no course backfill was run.
- Both additive hosted security migrations are applied and verified. Child-repository details are in `lizbeth_spanish/docs/evidence/lizbeth-spanish-hosted-security-20260915.md` and `lizbeth_spanish/docs/evidence/lizbeth-spanish-release-security-20260915.md`.
- Netlify read-only control evidence confirms site `36497726-71dd-42f6-a84e-834353a92cba`, published deploy `6a91c5a16bd89d0008ba7b80`, state `ready`, `locked=true`, production commit `4c6a8919...`, and publish directory `dist`. The API response did not expose `stop_builds`; the current `stop_builds=true` control remains the user-provided authoritative control state. No repository workflows were present, and no remote workflow/site setting was changed.
- The local Netlify CLI is available at `node_modules/netlify-cli` v17.38.1 and native auth works; only the global PATH/linking path is absent. This is not a claim that the Netlify CLI is unavailable.
- Remaining gates are explicit: fresh production-target build using the process-memory public anon key, upload only `dist` as an unpublished alias draft, anonymous candidate/deep-route smoke, unchanged published deploy/lock/old-live reachability, authenticated smoke, and final exact-model judgment. The one-time legacy projection backfill remains held pending explicit user approval after fresh backup and judge gates. Owner assignment and the anonymous archived-preview policy are resolved. Publish and merge remain prohibited in this phase.

## Outcome and audience

Close the seven outstanding items carried forward from the CLOSED `lizbeth-spanish-fjds-full-surface-conformance-audit` plan (GitHub issues `#163`-`#169` in the `lizbeth_spanish` repository), one work package per issue, each closing its issue only on verified completion with Verifier evidence and, for three packages, Browser Validator evidence.

Audience: the engineering fleet executing one work package at a time under T1 -> Verifier -> Browser Validator gates, and the repository owner approving this plan and its per-package evidence.

## Scope

**In scope — exactly seven work packages, one per GitHub issue:**

- WP-A / `#163` — `OwnerSettingsPage` dead-code removal.
- WP-B / `#169` — `seed.sql` `enrollment_lesson_entitlements` rows. Sequenced first among the test-facing packages; see Ordered work below.
- WP-C / `#164` — owner-facing course archive path (UI + data layer + authorization) plus a Playwright create-then-archive journey.
- WP-D / `#165` — gap-4 Defect C fixture drift, made a deterministic precondition.
- WP-E / `#166` — status-clarity Journey 1's timestamped seed-row locator, made a self-provisioning journey.
- WP-F / `#167` — `Field.tsx` error container `role="alert"` / live region.
- WP-G / `#168` — `/learn/:id` single-primary tie-break rule.

**Non-goals — explicitly excluded, carried-forward ledger items 8, 11, 13, 14, and 16:**

- The `.week-detail-footer-next-reason` measure cap.
- The issue-3-feedback-inbox transient input-visibility issue.
- The live-database vitest families (`rls`, `roadmap`, `storage`; cross-referenced to issues `#82`/`#139`).
- Deleting the roughly forty tracked validator scratch scripts at the repository root.
- The historical `claude-in-chrome` browser-validation deviation.

Do not widen scope to any other surface, and do not re-open the closed audit plan.

## Grounding and method

All findings below were verified by direct file reads during planning; no research pass was needed because both candidate unknowns (Supabase cascade/RLS behavior for archive, and whether `public.courses` needed a new RLS policy) were resolved locally from the cited migration files. If a work package finds the source materially different from the findings recorded here, the writer must return `JOB_BLOCKED` with `Plan stale` rather than improvise.

**Stale-plan condition:** a material change to `public.courses`, the `course-authoring` Edge Function, `Field.tsx`, `LearnDetailPage.tsx`, or `seed.sql` between approval and execution makes this plan stale.

### WP-A / `#163` — `OwnerSettingsPage`

`src\pages\OwnerSettingsPage.tsx` exports `OwnerSettingsPage`, which is mounted by no live route: `src\components\AdminShell.tsx` imports and mounts only `BusinessSettingsPage`, `CourseSettingsPage`, `BrandDesignPage`, and `AdminStudentsPage`. Verified finding: the page has no unique functionality. Its six fields are fully covered by two live surfaces sharing the same `sanitizeOwnerSettingsPayload` + `saveOwnerSettings` path: `BusinessSettingsPage.tsx` owns `brand_name`, `legal_copyright_text`, `legal_ip_notice`; `BrandDesignPage.tsx` owns `brand_primary_color`, `brand_secondary_color`, `logo_storage_path`.

**Critical constraint: the file is not dead even though the component is.** `src\pages\BrandDesignPage.tsx:8` does `import { ColorPreview } from './OwnerSettingsPage'` — `ColorPreview` is a live, `React.memo`-wrapped component rendered by `BrandDesignPage` for both color fields. `OwnerSettingsPage.css` is imported by both `BusinessSettingsPage.tsx:8` and `BrandDesignPage.tsx:9` and owns live shared shapes including `.permission-denied-card`, `.owner-settings-page`, `.owner-settings-brand-h1`, and the eyebrow pattern.

**Required steps:**
1. Relocate `ColorPreview` to a shared module (for example `src\components\ui\ColorPreview.tsx`) and repoint `BrandDesignPage`'s import.
2. Delete the `OwnerSettingsPage` component and its test, `src\__tests__\OwnerSettingsPage.test.tsx`.
3. Retain `OwnerSettingsPage.css` unmodified. Renaming it is optional and risky: it is referenced by `scripts\verify-token-pipeline.mjs:62`, `docs\token-deprecation-baseline\phase1-baseline.json` (three entries), `src\tokens\field-workbook.generated.css:225`, and numerous App.css/page-CSS comments. If it is renamed anyway, every one of those references must be updated and the token guards re-run.
4. Update `README.md:264`, which documents the removed test's flake fix.
5. Check `src\__tests__\e2e\wp7-settings.spec.ts:29` and `src\__tests__\issue67OwnerSettingsForcedColorsCoverage.test.ts`, both of which reference this surface.
6. **Mandatory pre-deletion inventory (Codex `J-CF-001`).** Before any deletion, produce a complete generated inventory of every import site and every `fs.readFileSync` source-read site referencing `OwnerSettingsPage.tsx` (not just its CSS), and classify each as retire / retarget / preserve. `src\__tests__\wp7-settings-conformance.test.tsx` alone touches the surface in three distinct ways that must be handled differently:
   - **(a) Retire — imports and renders the component:** line 9 (`import { OwnerSettingsPage } from '../pages/OwnerSettingsPage'`), and usages at lines 91, 150, 252. These break at compile time on deletion and must be retired or retargeted.
   - **(b) Retire — reads `OwnerSettingsPage.tsx` source from disk via `fs.readFileSync`:** lines 160, 167, 264. These throw `ENOENT` after deletion and must be retired.
   - **(c) Preserve — reads `OwnerSettingsPage.css` source:** lines 116, 169, 235, 275, 301, 342. The CSS file is retained by WP-A, so these assertions keep passing and must be preserved, not swept away with the rest of the file's OwnerSettingsPage references.
   - Lines 155-159 assert that `App.tsx` and `AdminShell.tsx` do not reference `OwnerSettingsPage`. Those assertions remain true and meaningful after deletion and may be kept as-is.
   - The inventory must also cover the already-known sites: `src\__tests__\OwnerSettingsPage.test.tsx` (already slated for deletion), `src\__tests__\issue67OwnerSettingsForcedColorsCoverage.test.ts`, and `src\__tests__\e2e\wp7-settings.spec.ts:29`.
   - The classification must be recorded in WP-A's completion evidence.

### WP-B / `#169` — `seed.sql` entitlements

`supabase\seed.sql` contains zero `enrollment_lesson_entitlements` rows, which is why populated `/learn` states are exercised only through Playwright route mocks. The table is created and granted in the issue-5 migrations; `list_enrollment_lesson_entitlements` exists at `supabase\migrations\202608300002_issue5_phase3_enforcement_sql_core.sql:627` and is redefined at `202608310001_issue5_phase4_revoked_roster_advisory.sql:23`.

Seed rows must be consistent with the existing seeded `student_enrollments` (`seed.sql:179-267`) and `student_lesson_progress` (`seed.sql:357-463`) so derived `/learn` states are coherent, and must deliberately include at least two lessons in simultaneous `unlocked-incomplete` state with distinct `position` values, so WP-G's tie-break is exercisable against live seed data rather than a mock.

E2E specs that route-mock `/learn` data must be adjusted only where the mock was a workaround for the missing seed. Mocks that deliberately isolate a behavior — for example forced error/500 paths such as `wp13-unauth.spec.ts`'s enrollment failure mocks — must be kept. The engineer must classify each mock before touching it (workaround-for-missing-seed vs. deliberate-behavior-isolation) and record the classification in completion evidence.

### WP-C / `#164` — owner-facing course archive

**Decision grounded in schema: archive (soft delete), not hard delete.** `supabase\migrations\202608280003_issue5_course_authoring.sql:23-44` defines `public.courses` with no archived/status/deleted_at column; line 45 adds `course_versions.course_id uuid references public.courses(id) ON DELETE RESTRICT`, and line 46 adds `student_enrollments.course_version_id ... ON DELETE RESTRICT`. A hard delete of a course that has any version is therefore blocked at the FK level, and forcing it would require cascading through `course_versions` -> `student_enrollments` -> `enrollment_lesson_entitlements`, destroying real student progress records. Archive is the correct and safe path.

**Authorization model.** Line 531 revokes ALL on `public.courses` (and the other authoring tables) from `anon, authenticated`; line 534 grants them only to `service_role`. There is no table-level RLS policy for the UI to satisfy — all course access is mediated by the `course-authoring` Edge Function and `SECURITY DEFINER` RPCs. The client layer is `src\services\courseAuthoring.ts`, which routes everything through `functions.invoke('course-authoring', { body: { action, payload } })` via `courseAction<T>()`; the `CourseAction` union at line 6 already contains `create_course` and `update_course`. Implement archive as a new `CourseAction` (or via `update_course`) with an owner check mirroring the existing `not authorized` pattern at migration line 300, plus a migration adding the archive column to `public.courses`.

**UI host surface.** `src\pages\CourseSettingsPage.tsx` (route `/admin/course-settings`, audit surface 21) renders a `.course-grid` of `<article className="course-card">`, each with a `.status-pill`, a title, a level/student-count line, and one `Control tier="secondary"` "Open workspace"; the page header carries the view's single `Control tier="primary"` ("New course"); `.workspace-empty` currently gates on raw `courses.length===0`. Course listing is `listCourses()` -> `normalizeCourseSummary` (`src\lib\courseAuthoring.ts`).

WP-C also resolves and closes the audit's recorded surface-24 exception: "the creation journey is not browser-validated because no UI course delete/archive path exists." The Playwright journey for this package must be a full create-then-archive round trip so the created fixture course is cleaned up by the feature itself.

Note: the ledger's cross-reference to issue `#81` is unrelated to this work package.

**Reviewed design handoff (binding on WP-C — see Design section below).**

### WP-D / `#165` — gap-4 Defect C fixture drift

`src\__tests__\e2e\gap-4-admin-students-remediation.spec.ts:193-223` ("Defect C: 'Assign a new band' entry point assigns a never-enrolled band") signs in as owner, selects `student5@test.local` — documented at line 199 as "the zero-enrollment SPOT-01 fixture — a clean target with no existing enrollment rows" and confirmed in `supabase\seed.sql:250` ("Note: student5 (SPOT-01 fixture) deliberately gets no row here — zero...") — then assigns the "Beginner" band and asserts a new active enrollment appears. It never restores state. On a second run against the same database, student5 is already enrolled in Beginner, so the "never-enrolled band" precondition is false and the picker may no longer offer Beginner.

**Fix, per the audit's shared fixture rule:** capture -> mutate -> assert -> restore (remove the created enrollment in a `finally`/`afterEach`), or provision a dedicated throwaway student for the journey. The sibling Defect A test at lines 127-132 already restores fixture state ("Restore fixture state for repeatability") and re-enables the account — follow that established local precedent.

**Cleanup obligation on every path (Codex `J-CF-002`).** Whichever path is chosen, every WP-D path must end with observable restoration, not only the capture/restore path. An `afterEach` or `finally` block must either restore the captured pre-test state, or, if a dedicated throwaway student is used instead, explicitly delete that throwaway student together with its dependent enrollment and entitlement/grant rows. Neither path may leave residue in the fixture database. This is the same cleanup obligation already required of WP-E, and it cites the same local precedent (`gap-4-admin-students-remediation.spec.ts:127-132`).

### WP-E / `#166` — status-clarity Journey 1

`src\__tests__\e2e\browser-validation-status-clarity-and-gate.spec.ts:117-149` ("Journey 1: status label clarity for a never-signed-in student") locates its roster row with the hardcoded literal `test-pw-security-1786131628810-z66crlr1cd@test.local` (line 131) — a timestamped residue row created by an earlier run, not a seeded fixture, which is why the journey fails after a `db reset`. The journey then asserts `.account-pill` reads "Pending first login" on both the roster row and the detail view, plus the `.account-access-explanation` copy, and ends with `expect(dialogFired).toBe(false)`.

**Fix:** either have the journey create its own never-signed-in row (the Add Student flow produces exactly a pending-first-login account — see the Defect B journey at lines 145-191, which already creates `remediation-${Date.now()}@test.local` through that flow) and clean it up afterward, or retarget to the seeded alternative `student7@test.local`, used by Defect D at lines 225-253 and documented there as "the seeded pending-first-login fixture (`last_sign_in_at` deliberately NULL, never banned)." If the journey only needs to read a pending row, retargeting to that seeded fixture is the simpler deterministic fix and creates nothing to clean up. The engineer must pick one and record why. The WP-14 retarget of this journey's copy/selector — "Awaiting first sign-in"/`.status-badge` -> "Pending first login"/`.account-pill` — is already done and must be preserved.

### WP-F / `#167` — `Field.tsx` error container

`src\components\ui\Field.tsx:138-142` renders the error as `<div id={errorId} className="field__error">{error}</div>` with no `role="alert"` and no live region. The control already gets `aria-invalid` and `aria-describedby={errorId}` (lines 95-96).

**Material downstream risk requiring an inventory.** The repository contains many singular `getByRole('alert')` / `page.getByRole('alert')` assertions that will break if a `Field` error adds a second alert to the same view, and at least one count assertion that would break outright: `src\__tests__\e2e\wp6-brand-design.spec.ts:247` asserts `expect(await page.getByRole('alert').count()).toBe(0)`.

**Illustrative, non-exhaustive sample of other singular-alert call sites (Codex `J-CF-003`: this list is illustrative only, not exhaustive — a generated inventory is required, see below).** `src\__tests__\Issue4SettingsPages.test.tsx:74,79` (which assert a single alert while a field error is present), `AdminStudentsPage.test.tsx:131`, `AdminStudentModals.test.tsx:106`, `adminStudentDataErrorPropagation.test.tsx:99,132`, `App.test.tsx:237,406`, `BandRoadmap.test.tsx:100-236`, `owner-dashboard.spec.ts:100,126`, `issue-4-owner-workspace.spec.ts:62`, `issue-3-feedback-inbox.spec.ts:105`, `wp11-learn.spec.ts:296`, `wp5-feedback-inbox.spec.ts:269,295`, several assertions in `wp13-unauth.spec.ts`, `src\__tests__\e2e\wp3-owner-dashboard.spec.ts:389`, `src\__tests__\RoadmapPage.test.tsx:103`, `src\__tests__\RegisterStudentModal.test.tsx:107,315`, `src\__tests__\LoginForm.test.tsx:30,128`, and `src\__tests__\issue5-phase3-reconciliation-panel.test.tsx:149`. A follow-up repository search found roughly 42 files under `src\__tests__` matching `getByRole('alert')` or `role="alert"`, against roughly 20 named above — the hand-written list is illustrative only. Specs asserting directly on the error markup, which must also be re-checked: `src\__tests__\Field.test.tsx:52,59` and `src\__tests__\issue49-editor-primitive.test.tsx:115,126,149`.

**Required steps:**
1. Enumerate every consumer of `Field` with an `error` prop.
2. Generate a complete inventory of every `getByRole('alert')`, `getAllByRole('alert')`, and `role="alert"` site across the test suite (not the hand-written sample above), and classify each site for coexistence — whether a `Field` error can be present in that same view at the same time, which would make a singular alert query ambiguous.
3. Run the full unit suite and the affected e2e suites.
4. Retarget any assertion that becomes ambiguous by narrowing a singular `getByRole('alert')` to a scoped locator, never by deleting the assertion.

If `role="alert"` proves too disruptive, the documented alternative is `role="alert"` plus an explicit scope, or an `aria-live="polite"` container. The engineer must record which was chosen and why.

### WP-G / `#168` — `/learn/:id` single primary

`src\pages\LearnDetailPage.tsx:269` renders `{state === 'unlocked-incomplete' && <MarkCompleteControl onConfirm={handleConfirm} />}` per lesson card, and `MarkCompleteControl` (lines 130-181) hardcodes `tier="primary"` on both its trigger (line 155) and its Confirm button (lines 167-168), with Cancel at `tier="quiet"`. `deriveLessonState` (lines 49-63) yields `unlocked-incomplete` whenever a row is entitled, not completed, not paused, past its unlock time, and `completion_rule === 'view'` — so several rows can hold that state simultaneously, producing several `.control--primary` controls and breaking the DS C.1 "exactly one Primary per view" invariant, documented in this same file at lines 116-127 and 406-417.

**Tie-break rule (deterministic, no date math).** `LearnCourseLessonRow` already carries `position: number` (`src\services\learnData.ts:87`). Among rows whose derived state is `unlocked-incomplete`, the row with the lowest `position` keeps Primary and every other such row renders the same control at Secondary. The full presentation contract, including the confirm-step propagation fix, is in the Design section below.

## Design

**DESIGN_ROUTE:** profile `compact`; agents `design-generalist`, `design-reviewer`; prototype forbidden; model tier Sonnet; existing_system_mode `preserve`. Rationale: only `#164` adds substantive new user-visible UI, and it is a bounded brownfield addition to an already DS-conformant admin surface using established patterns (D.7 admin header, card tier, app-owned Modal, Control tiers, status pill); `#168` is a control-tier/hierarchy change on an existing list, folded into the same compact brief; `#163`, `#165`-`#167`, and `#169` are non-visual.

**Design review verdict: PASS.** `design-reviewer` independently verified against the repository that the cited Control tiers (`caution-reversible`, `quiet-outline`, `quiet`), all cited tokens, the Modal/`useFocusTrap` mechanics including `suppressDismiss` and the `document.body.contains` guard, `CourseSummary.status: 'draft'|'published'` at `courseAuthoring.ts:10` and the coercion at line 88, and `LearnCourseLessonRow.position` at `learnData.ts:87` all exist as claimed. Three original findings — the confirm-step tier conflict, the `normalizeCourseSummary` narrowing bug, and a wrong live-region precedent — plus a `Modal.tsx` path correction were closed in one evidence-backed revision cycle. The reviewer scoped its second pass to closure of those findings and did not re-litigate previously passed aspects.

### `#164` — archive affordance on `CourseSettingsPage`

A new `.course-card-actions { display: flex; gap: var(--space-2); flex-wrap: wrap }` inside `.course-card` holds the existing `Control tier="secondary"` "Open workspace" plus a new `Control tier="caution-reversible"` "Archive" — never `caution-irreversible`, because archive is reversible; never a second page-level Primary.

Confirmation uses the existing app-owned `src\components\Modal.tsx` with `suppressDismiss={pending}`. Modal keyboard/focus is inherited unmodified from `src\hooks\useFocusTrap.ts`: initial focus on the `tabIndex={-1}` dialog container, Tab/Shift+Tab confined to it, Escape closes unless suppressed, and restoration guarded by `document.body.contains(triggerRef.current)`. Because a successful archive unmounts the trigger, the success handler must explicitly move focus to a stable fallback (the `course-settings-heading` `<h1>` given `tabIndex={-1}`), not rely on default restoration; cancel/Escape/failure keep the trigger mounted so default restoration is correct.

Success is announced through a new always-mounted `aria-live="polite"` region added to `CourseSettingsPage`, modeled on `LearnDetailPage.tsx`'s `<div aria-live="polite" className="learn-detail-live-region">{announcement}</div>` + `announcement` state pattern — explicitly not a reuse of the page's conditionally-mounted `{loading && <p role="status">}` / `{error && <p role="alert">}` paragraphs, which could unmount before assistive tech announces a one-off result. Failure is announced with `role="alert"` inside the modal body (acceptable because the modal stays mounted). Pending state shows a `role="status"` line "Archiving {title}…" and the Confirm control must carry the native `disabled` attribute, never a CSS-only class.

Archived courses are represented with a new `.status-pill.archived` modifier (same box model as `.status-pill.published`, text `var(--color-ink-700)`) and surfaced in a collapsed disclosure below `.course-grid`, toggled by a `Control tier="quiet-outline"` with `aria-expanded`/`aria-controls`, matching `LearnDetailPage`'s existing `LockedDisclosure` idiom. `.workspace-empty` must gate on the active (non-archived) course count, not raw `courses.length`, so archiving the last active course reveals the empty state while archived courses remain reachable.

### `#168` — `MarkCompleteControl` presentation contract

`MarkCompleteControl` gains an explicit `tier: 'primary' | 'secondary'` prop and an `aria-label` prop. The tier must govern both the trigger (line 155) and the Confirm button (line 168); Cancel stays `tier="quiet"` unconditionally. This is load-bearing: without it, opening the confirm step on a demoted row while the true primary row's idle trigger is still mounted renders two `.control--primary` controls at once. `LessonCard`/`LearnDetailPage` compute `tier={row.lesson_revision_id === primaryLessonId ? 'primary' : 'secondary'}` per render, derived from `position`, never stored in component state. Every instance gets `aria-label={`Mark "${row.title}" complete`}` so multiple rows do not share an identical accessible name; visible label text is unchanged. The primary row alone also renders a real-text `<span className="lesson-card-primary-marker">Up next</span>` (mono/eyebrow treatment, `var(--font-letter-spacing-eyebrow)`) so the distinction is not carried by visual weight alone.

### Tokens

No new primitives. Reused: `--space-2`, `--space-4`, `--color-amber-200`, `--color-ink-1000`, `--color-ink-700`, `--color-paper-50/100/200`, `--color-terracotta-600`, `--shadow-card`, `--border-width-rule`, `--radius-square`, `--control-height`, `var(--font-letter-spacing-eyebrow)`. Modal error styling reuses the terracotta-600-border/paper-200-background pattern already declared for `.workspace-panel p[role=alert]`, scoped to `.modal-body p[role="alert"]`.

### Binding engineering invariants (from the design handoff)

1. Exactly one `.control--primary` per view at any time, including in both the trigger and confirm-step branches on `/learn/:id`, so a demoted row's confirm step never renders primary while the true primary row's trigger is mounted.
2. Archive must never use `caution-irreversible`.
3. No native `alert`/`confirm`/`prompt`/`window.*`/`beforeunload` — confirmation is exclusively `src\components\Modal.tsx`.
4. Disabled-during-pending must use the native `disabled` attribute.
5. Post-archive focus restoration must not depend on `useFocusTrap`'s default trigger-restoration path.
6. Widening `CourseSummary.status` to include `'archived'` is two required changes: the TypeScript declaration at `src\lib\courseAuthoring.ts:10` and `normalizeCourseSummary`'s runtime coercion ternary at line 88 (`status: input?.status === 'published' ? 'published' : 'draft'`), which today silently maps any non-`'published'` value — including a future `'archived'` row — to `'draft'`. Fixing only the type leaves archived courses silently mislabeled "draft" with no error and no failing test.
7. The primary/secondary tier assignment must be derived per-render from `position` and threaded in as an explicit prop governing both buttons.

### Permitted variation

Exact modal/live-region wording (must name the course title, state the action is reversible/hidden-not-deleted, and make no claim about student or enrollment consequences); the disclosure toggle's label; the "Up next" marker's class name and placement (must be real text, not color-only, not focusable); whether Archive sits right of or below "Open workspace"; the exact prop name for the new tier input.

## Interfaces and data

- New migration on `public.courses` adding the archive column (soft delete). Must be additive and backward compatible; existing rows default to not-archived. No change to the `ON DELETE RESTRICT` FKs, and no hard-delete path.
- New/extended `course-authoring` Edge Function action for archive, with an owner check mirroring the existing `not authorized` pattern at `202608280003_issue5_course_authoring.sql:300`. No new grants on `public.courses` are needed or permitted; `anon`/`authenticated` remain revoked (line 531) and access stays Edge-Function/RPC-mediated.
- `src\services\courseAuthoring.ts`: extend the `CourseAction` union and export the archive binding.
- `src\lib\courseAuthoring.ts`: widen `CourseSummary.status` (line 10) and fix `normalizeCourseSummary`'s coercion (line 88) — both required.
- `src\components\ui\Field.tsx`: error-container semantics change, affecting every `Field` consumer's accessibility tree, hence the mandatory assertion inventory.
- `src\pages\LearnDetailPage.tsx`: `MarkCompleteControl` gains `tier` and `aria-label` props (an internal component contract change, not a public API).
- `supabase\seed.sql`: additive `enrollment_lesson_entitlements` rows only; must not invalidate the existing seeded enrollments, progress rows, or the documented student5 zero-enrollment and student7 pending-first-login fixtures.

## Work package completion notes

**WP-B / `#169` — complete, 2026-09-14.** `supabase/seed.sql` gained an additive block (lines ~485-538) materializing `enrollment_lesson_entitlements`: `student1` Beginner (26 rows; weeks 1-2 completed, synced from `student_lesson_progress`; weeks 3-4 unlocked-incomplete at positions 3 and 4, satisfying the tie-break precondition for WP-G) and `student2` Beginner (26 rows; one unlocked-incomplete row, week 1). `fullaccess` and all other enrollments remain at 0 rows, preserving the legacy-materialization branch. In `wp11-learn.spec.ts`, 2 workaround mocks were replaced with real `student2` seed data; 3 mocks that deliberately isolate a behavior were kept, each with a comment recording the classification; no other e2e spec mocks `/learn`. A new live-database test, `src/__tests__/wpB-seedLearnEntitlements.test.ts`, was added RED-then-GREEN against the seeded rows.

Independent Verifier evidence (2026-09-14): `psql` row counts confirmed the seeded rows; the full `vitest` suite passed 3132/3132 after a fresh `db reset`; TypeScript type-check was clean; ESLint reported 0 errors; Playwright `wp11-learn` passed 10/10 and `wp10-roadmap` passed 7/7 against a production preview. Codex `CODE_REVIEW` was skipped for this package under the trivial-work rule: it is a test/data fixture change with no production code path touched.

Issue `#169` was closed 2026-09-14 with this evidence.

**WP-G / `#168` — complete, 2026-09-14.** `src/pages/LearnDetailPage.tsx` and `.css` gained a tie-break rule for `/learn/:id`: among unlocked-incomplete lessons, the lesson with the lowest `position` is the sole Primary (rendering the `MarkCompleteControl` trigger and its Confirm step via a `tier` prop; Cancel remains quiet, non-primary). The primary is derived per render, so completing it promotes the next-lowest-position lesson; the comparison is null-safe (`undefined` position sorts to `+Infinity`) with array index as a secondary tie-break key. Each `MarkCompleteControl` instance carries a per-instance `aria-label` (`Mark "<title>" complete`), and the primary row alone shows a real-text "Up next" marker (`.lesson-card-primary-marker`, built from existing design tokens only, not color-only and not focusable). A new unit suite, `wpG-learnDetailTieBreak.test.tsx`, was added RED-then-GREEN (5/5). The existing `wp11-learn-conformance` (17/17) and `issue5-phase5` (24/24) suites were retargeted to the new composition, not weakened. `wp11-learn.spec.ts` gained 2 new e2e cases (desktop and 390px viewport; 12/12 total). `vitest.config.ts` was updated to exclude `browser-validation-artifacts/**` from the test run.

Codex `CODE_REVIEW` (shadow) raised two minor findings, both applied: J-WPG-001 (make the `undefined`-position tie-break outcome deterministic) and J-WPG-002 (add mobile-viewport coverage to the tie-break e2e test).

Independent Verifier evidence (2026-09-14): full `vitest` suite 3127/3127; TypeScript type-check clean; ESLint 0 errors; guard suite 49/49; design tokens confirmed defined. Browser Validator evidence (Playwright, 1440px and 390px viewports): `student1`'s fixture (position-3 unlocked-incomplete, position-4 also unlocked-incomplete) rendered exactly one Primary control, on position 3, with the "Up next" marker; position 4 rendered as non-primary/secondary. The confirm-step transition (trigger to Confirm to Cancel) kept exactly one Primary control visible throughout; focus moved to Confirm on open and returned to the trigger on Cancel. `student2`'s single-unlocked-incomplete fixture rendered exactly one Primary control. No native browser dialogs were observed. `wp11-learn` passed 12/12 and `wp10-roadmap` passed 7/7. Artifacts: `browser-validation-artifacts/wp-g/`.

Residual note (non-blocking): the `MarkCompleteControl` confirm step has no Escape-key handler. Cancel restores focus correctly and focus is never lost, so this is not a defect; it is an optional accessibility polish item, observed 2026-09-14 during WP-G browser validation.

Issue `#168` was closed 2026-09-14 with this evidence.

**WP-A / `#163` — complete, 2026-09-14.** `ColorPreview` was relocated as a pure move to `src/components/ui/ColorPreview.tsx` (`React.memo` and `aria-live`/`aria-hidden` behavior unchanged), and `BrandDesignPage.tsx` was repointed to import it from the new location. `OwnerSettingsPage.tsx` and `src/__tests__/OwnerSettingsPage.test.tsx` were deleted. `OwnerSettingsPage.css` was retained unmodified; it is still imported by `BusinessSettingsPage.tsx` and `BrandDesignPage.tsx`. The verified finding from planning was confirmed and recorded: `OwnerSettingsPage` had no unique functionality, its six fields being fully covered by `BusinessSettingsPage`/`BrandDesignPage` through the shared `sanitizeOwnerSettingsPayload`/`saveOwnerSettings` path.

The mandatory pre-deletion inventory required by Codex `J-CF-001` was produced and applied: `src/__tests__/wp7-settings-conformance.test.tsx`'s import/render sites (line 9 and usages at lines 91, 150, 252) were retired; its `fs.readFileSync` reads of `OwnerSettingsPage.tsx` source (lines 160, 167, 264) were retired, and the file's absence is now the asserted condition; its `fs.readFileSync` reads of `OwnerSettingsPage.css` source (lines 116, 169, 235, 275, 301, 342) were preserved unmodified, since WP-A retains the CSS file. `README.md:264`'s note documenting the removed test's flake fix was updated.

Independent Verifier evidence (2026-09-14): a repository-wide grep confirmed only `.css`-path references and comments to `OwnerSettingsPage` remain, with no surviving import or render site; TypeScript type-check was clean; ESLint reported 0 errors; the full unit suite passed 3122/3122; the token guards and `tokenDeprecationLint` stayed green; `wp6BrandDesignConformance` passed 9/9. `BROWSER_NOT_APPLICABLE` was recorded because this work package is unreachable-code removal with no rendered surface to validate. Codex `CODE_REVIEW` was skipped under the trivial-work rule: dead-code removal with no public contract.

Issue `#163` was closed 2026-09-14 with this evidence.

**WP-F / `#167` — complete, 2026-09-14.** `src/components/ui/Field.tsx`'s error container gained `role="alert"` on the same conditionally-mounted `<div id={errorId} className="field__error">` (mounted only when `error` is set), matching the repository's existing convention for assertive, on-demand error announcements (WCAG 4.1.3, Status Messages). `Field.test.tsx` gained 2 new tests, confirmed RED before the change and GREEN after. A generated, complete inventory of every `getByRole('alert')` / `getAllByRole('alert')` / `role="alert"` site across the test suite was produced and stored at `browser-validation-artifacts/wp-f/alert-inventory.md`: 43 files matched, and coexistence classification found 0 affected sites — the only production consumer that passes an `error` prop to `Field` is `LoginForm`'s email field, and no other alert-producing surface can be mounted simultaneously with it. Codex `J-CF-003`'s illustrative sample is therefore superseded by this generated inventory. Codex `CODE_REVIEW` was skipped under the trivial-work rule: a single JSX attribute change.

Independent Verifier evidence (2026-09-14): TypeScript type-check clean; ESLint 0 errors; full unit suite 3122/3122; Playwright e2e specs `wp13-unauth`, `wp6-brand-design`, `wp7-settings`, `wp12`, and `wp3-owner-dashboard` all passed on a production preview. `wp8-course-workspace.spec.ts` failed 7 tests, but this was confirmed a pre-existing local-data dependency unrelated to the WP-F change (see the new carry-forward item and issue below), not a regression introduced by this package.

Browser Validator evidence (2026-09-14, `BROWSER_PASS`, Playwright, 1440px and 390px viewports): on the sign-in wrong-password journey, exactly one `role="alert"` element renders with copy matching the on-screen error text, `aria-describedby` on the email input resolves to the alert's `id`, `aria-invalid="true"` is present on the input, and focus moves to the input; only the field alert is present on this path (no coexisting banner alert observed). No native dialog fired at either viewport. On a separate check, after a subsequent successful sign-in no stale alert remained mounted. Artifacts: `browser-validation-artifacts/wp-f/*.png`, `browser-validation-artifacts/wp-f/*.yaml`.

**Residual, disclosed, not a defect.** `LoginForm` could theoretically show a stale banner-level alert simultaneously with the new field-level alert if an async error persisted across a resubmit attempt; no current code path produces this state, so it is recorded as a residual risk rather than an open defect.

Issue `#167` was closed 2026-09-14 with this evidence.

**WP-D / `#165` — complete, 2026-09-14.** `src/__tests__/e2e/gap-4-admin-students-remediation.spec.ts`'s Defect C ("Assign a new band" entry point assigns a never-enrolled band) was rewritten to the capture -> mutate -> assert -> restore pattern, following the sibling Defect A precedent at lines 127-132. The test now captures `student5@test.local`'s existing enrollments via the local PostgREST/Admin API (the `127.0.0.1:54321` literal guard and demo service key, matching the pattern already established in the status-clarity spec) before mutating anything. If the documented zero-enrollment SPOT-01 precondition has drifted (student5 already enrolled from a prior unreset run), the test forces the precondition back to zero enrollments with a named `expect` rather than silently skipping. The UI assertion (assigning the "Beginner" band and confirming a new active enrollment appears) runs inside a `try` block, and a `finally` block deletes any enrollment created by the test run, which cascades to `enrollment_lesson_entitlements`, then asserts the residual enrollment set is `[]`. This satisfies Codex `J-CF-002`'s cleanup obligation: every path restores state, and the fix includes an explicit post-run residue check, not only the capture/restore path itself.

RED evidence: the unmodified test failed on the second consecutive run against the same (unreset) database, reproducing the documented drift mode — a `selectOption` timeout because "Beginner" was no longer offered as a never-enrolled band. GREEN evidence: the rewritten test passed 5/5 twice consecutively against the same database with no intervening reset, and passed 5/5 once more immediately after `npx supabase db reset`, confirming the fix is precondition-independent in both directions. No production code was touched; this is a test-only fixture-drift fix.

Independent Verifier evidence (2026-09-14, combined with the WP-C verifier pass): `vitest`/e2e run confirmed 5/5 twice consecutively on a production preview, with student5's enrollment residue confirmed `[]` after both runs. `BROWSER_NOT_APPLICABLE` beyond the spec runs themselves: the Playwright spec run is the validation surface for this fixture-drift fix, and there is no separate rendered-composition surface to check. Codex `CODE_REVIEW` was skipped under the trivial-work rule (test-only change); Codex `J-CF-002` from the plan's `PLAN_DUCK` pass was applied as specified above.

Issue `#165` was closed 2026-09-14 with this evidence.

**WP-C / `#164` — complete, 2026-09-14.** The owner-facing course archive path was delivered as a soft delete, per the schema-grounded decision recorded above: `public.courses` gained a nullable `archived_at` timestamp column (migration `202609140001_issue164_course_archive.sql`), the `course_catalog` view was updated to filter archived rows out of the public catalog, and a `SECURITY DEFINER` RPC `set_course_archived` performs the archive/unarchive write with an owner check. A follow-up migration (`202609140002_issue164_course_archive_security_fix.sql`) revoked `EXECUTE` on the RPC from `PUBLIC`/`anon`/`authenticated` and granted it to `service_role` only, added `auth.uid()` defense-in-depth inside the function, and pinned `search_path`; `proacl` was verified directly against the database. No FK or hard-delete path was touched, preserving the `ON DELETE RESTRICT` constraints cited in planning.

The `course-authoring` Edge Function gained an owner-gated `archive_course` action taking an `archived` boolean; unarchive derives the resulting course status from the current course version rather than hardcoding a value, so a previously published course stays published after unarchive (see Codex finding J-WPC-003 below). `list_courses` reports `'archived'` as a status value. The client layer (`src/services/courseAuthoring.ts`) gained `archiveCourse`/`unarchiveCourse` bindings, and `normalizeCourseSummary` (`src/lib/courseAuthoring.ts`) was widened to preserve `'archived'` through its status-coercion ternary rather than silently mapping it to `'draft'`, per the design handoff's binding invariant 6.

On `CourseSettingsPage.tsx`, each active course card gained a `Control tier="caution-reversible"` "Archive" control (never `caution-irreversible`, because archive is reversible) that opens the existing app-owned `Modal.tsx` for confirmation: initial focus lands on the dialog container, Escape returns focus to the triggering Archive button, the Confirm control carries the native `disabled` attribute while the request is in flight, and a rejected archive keeps the modal open with a `role="alert"` message and no lost `disabled` state. An always-mounted `aria-live="polite"` region announces success. Archived courses render in a collapsed disclosure below the active grid, toggled by a `Control tier="quiet-outline"` with `aria-expanded`/`aria-controls`, each archived card carrying the new `.status-pill.archived` modifier reading "archived" and an `Control tier="quiet-outline"` "Unarchive" control that acts inline (no modal) with its own `role="status"`/`role="alert"` announcement. `.workspace-empty` was changed to gate on the active (non-archived) course count rather than the raw course count, so archiving the last active course reveals the empty state while archived courses remain reachable through the disclosure. All CSS reused existing tokens; no new primitive or semantic token was added. Decision 1(a) from "Open decisions" (enrolled students keep access after archive) was honored and independently confirmed by the Verifier: the `/learn` RPCs students use do not join `course_catalog`, so an archived course's enrolled students are unaffected.

**Codex `CODE_REVIEW` (terra, shadow) findings and disposition:** `J-WPC-001` (critical) — the `set_course_archived` RPC was callable by `PUBLIC`, bypassing the intended owner-only path; fixed by the second migration plus a live test confirming a non-owner's direct RPC call is rejected. `J-WPC-002` (major) — no unarchive control existed in the UI; the Unarchive control described above was added. `J-WPC-003` (minor) — unarchive unconditionally returned `'draft'` instead of the course's actual current status; fixed so a previously published course stays published after an archive/unarchive round trip. `J-WPC-004` (minor) — Journey 6 (archiving down to zero active courses reveals `.workspace-empty`) was not covered by browser validation; disclosed as unit-test-only coverage, to avoid archiving the seeded fixture courses relied on by other packages' browser journeys.

**Tests.** Unit: `issue164CourseArchive`, `issue164CourseArchiveSecurity`, `issue164NormalizeCourseSummaryArchived`, and `issue164CourseSettingsArchive` (13 tests). E2E: a new Playwright spec `wpC-course-archive.spec.ts`, 3/3 passing at both 1440px and 390px viewports, covering the create-then-archive-then-unarchive round trip and the rejected-archive path; an `afterEach` deletes the throwaway course created by the spec from the database, so the journey is self-cleaning. This satisfies the plan's requirement that WP-C resolve and close the audit's recorded surface-24 creation-journey exception (see the ledger update below).

Independent Verifier evidence (2026-09-14, combined with the WP-D pass recorded above): full unit suite 3140/3140; TypeScript type-check clean; ESLint 0 errors; guard suite 49/49; `wp13-unauth`/`wp3-owner-dashboard`/`wp11-learn` combined 27/27; `wp8-course-workspace` 8/7 passing (the 1 pre-existing failure is tracked, unrelated issue `#170`, not a WP-C regression); a repository-wide check confirmed zero residual `archived_at`-related test or fixture inconsistencies.

Browser Validator evidence (2026-09-14, `BROWSER_PASS`, Playwright, 1440px and 390px viewports, 1440+390 round trips of the create-archive-unarchive journey plus the rejected-archive path): the confirmation modal's accessibility contract (initial focus, focus trap, Escape-restore, `disabled` during pending) was verified; the archive-then-disclosure-then-unarchive flow was verified end to end; the public course catalog was confirmed to never list the archived course at any point in the journey; no native browser dialogs fired at either viewport. Artifacts: `browser-validation-artifacts/wp-c/01` through `07` (PNG).

**Operator note.** The local Supabase edge runtime does not hot-reload function source; after editing `supabase/functions/*/index.ts`, `docker restart supabase_edge_runtime_lizbeth_spanish` is required before testing. Recorded in this plan's evidence trail and in the ledger's "Operator notes" section.

Open decisions 2 and 3 (see "Open decisions" above) are resolved: `listCourses()` returns archived rows and the disclosure filters them client-side with no separate fetch; the archived group uses the `.status-pill.archived` text modifier plus the disclosure, with no new visually-muted card treatment and no new token.

Issue `#164` was closed 2026-09-14 with this evidence.

## Ordered work

WP-B (`#169`, seed entitlements) runs first because WP-D, WP-E, and WP-G's e2e evidence depends on deterministic seeded `/learn` and roster state. Each work package completes T1 -> Verifier -> (where applicable) Browser Validator before the next begins.

1. **WP-B / `#169`** — add `enrollment_lesson_entitlements` rows to `supabase\seed.sql`, consistent with the existing seeded enrollments and lesson progress, deliberately including two or more lessons simultaneously `unlocked-incomplete` with distinct `position` values. Classify every `/learn` route mock in the e2e suite (workaround-for-missing-seed vs. deliberate-behavior-isolation) and record the classification. Owner: engineering fleet. Depends on: nothing.
2. **WP-A / `#163`** — relocate `ColorPreview` to a shared module, repoint `BrandDesignPage`'s import, delete the `OwnerSettingsPage` component and its test, retain `OwnerSettingsPage.css`, update `README.md:264` and any spec comments referencing the removed surface, and re-run the token guards. State the verified no-unique-functionality finding in both the plan evidence and the issue closure. Owner: engineering fleet. Depends on: nothing (parallel-safe with WP-B in principle, but keep execution serial per the one-writer rule).
3. **WP-F / `#167`** — add the error-container live-region semantics to `src\components\ui\Field.tsx`, after enumerating every `Field` consumer that passes `error` and every singular `getByRole('alert')` / alert-count assertion listed above. Retarget ambiguous assertions by scoping them, never by deleting them. Owner: engineering fleet. Depends on: nothing.
4. **WP-G / `#168`** — implement the lowest-`position` tie-break and the reviewed presentation contract (tier + `aria-label` props governing trigger and confirm, "Up next" marker), with unit tests covering: several simultaneous `unlocked-incomplete` rows, the concurrent confirm-step case, and promotion after the primary lesson is completed. Owner: engineering fleet. Depends on: WP-B (live seed data for the e2e half).
5. **WP-C / `#164`** — the archive path: migration adding the archive column to `public.courses`; the `course-authoring` Edge Function action with an owner check; the `src\services\courseAuthoring.ts` client binding; the `CourseSummary.status` widening (both the declaration and `normalizeCourseSummary`); the `CourseSettingsPage` UI per the reviewed design handoff; and a Playwright create-then-archive journey that cleans up its own fixture course. Also close the recorded audit surface-24 creation-journey exception. Owner: engineering fleet. Depends on: nothing technically, but sequenced after WP-G so the DS control-tier work lands first.
6. **WP-D / `#165`** — make Defect C deterministic via capture -> mutate -> assert -> restore (or a dedicated throwaway student), following the Defect A precedent in the same file. Owner: engineering fleet. Depends on: WP-B.
7. **WP-E / `#166`** — make status-clarity Journey 1 self-provisioning (or retarget to the seeded `student7@test.local`), preserving the WP-14 copy/selector retarget. Owner: engineering fleet. Depends on: WP-B.

**Post-gate steps (record only — do not perform during implementation, and do not let them precede any gate).** After every work package has passed Verifier and, where applicable, Browser Validator: commit all changes in `lizbeth_spanish` and the orchestrator docs, open a pull request, and merge to main. The user explicitly requested these; they remain post-gate and require their own separate, later, explicit approval at each step.

## Acceptance and validation

Per work package, each WP closes its GitHub issue only on verified completion.

**Cross-cutting guards that must stay green for every WP:** `nativeDialogPolicy` (`src\__tests__\nativeDialogPolicy.test.ts`), `tokenFallbackAuditLint`, `tokenPipelineOracle`, `weekDetailFooterForcedColorsCss`; TypeScript type-check clean; lint zero errors; full unit suite green.

- **WP-A:** the generated pre-deletion import/read-site inventory (retire / retarget / preserve classification) is recorded in completion evidence; a repository-wide search confirms zero remaining references to the removed component; `BrandDesignPage` still renders both `ColorPreview` instances; `wp7-settings-conformance.test.tsx`'s CSS-reading assertions (lines 116, 169, 235, 275, 301, 342) still pass unmodified; token pipeline guards stay green after the `ColorPreview` relocation.
- **WP-B:** `npx supabase db reset` produces `/learn` states with live entitlement data and at least two simultaneous `unlocked-incomplete` lessons; every mock reclassification is recorded.
- **WP-C:** unit tests for the archive action and the status widening; the Playwright create-then-archive journey passes; the no-native-dialog scan stays green; modal keyboard/focus verified.
- **WP-D / WP-E:** each spec passes twice consecutively against the same database without an intervening reset — this is the deterministic-precondition proof and the core acceptance check for both. For WP-D, an additional post-run check confirms no residual throwaway account or enrollment remains in the fixture database on either path.
- **WP-F:** the generated complete alert-site inventory and its per-site coexistence classification are recorded in completion evidence; every affected suite passes.
- **WP-G:** unit tests cover multiple simultaneous `unlocked-incomplete` rows, the concurrent confirm-step case, and promotion after completion.

**Independent gates.** No work package may be claimed complete on writer evidence alone. Every WP requires a read-only Verifier pass. WP-C, WP-F, and WP-G additionally require a Browser Validator pass. Two counted T1 gate failures escalate to T2; two counted T2 gate failures block for user review.

**One dev server rule (binding on writers, Verifier, and Browser Validator):** kill any running `lizbeth_spanish` dev/preview server before starting one; exactly one may run at any time.

## Risks and rollback

- **Highest risk — WP-F (`#167`).** A broad accessibility-tree change with many singular `getByRole('alert')` call sites and one hard count assertion (`wp6-brand-design.spec.ts:247` expects 0 alerts). Mitigation: enumerate before editing, scope assertions rather than delete them, run the full suite. Rollback: the change is a single JSX attribute plus test retargets and is trivially revertible.
- **WP-A (`#163`).** Deleting the file wholesale would break the live `ColorPreview` import and the CSS imported by two live pages. Mitigation: relocate `ColorPreview` first and retain the CSS. Rollback: restore the file from git.
- **WP-C (`#164`).** A schema migration touching the course table. Mitigation: additive column only, no FK changes, no hard-delete path, owner-checked Edge Function action. Rollback: a down migration dropping the added column; the local fixture database can be restored with `npx supabase db reset`. Residual risk: the unresolved student-access product policy (see Open decisions) — the UI copy deliberately makes no claim either way, so a later policy decision does not invalidate shipped copy.
- **WP-B (`#169`).** Inconsistent seed rows could produce incoherent `/learn` states or mask real regressions. Mitigation: derive seed values from the existing enrollments/progress rows and verify the derived states against `deriveLessonState`. Rollback: revert `seed.sql` and `npx supabase db reset`.
- **WP-D / WP-E.** Low risk, test-only.

## Open decisions (read before dispatching any work package)

None of these blocks approval of the overall approach; the first should be answered before WP-C's server-side behavior is finalized.

1. **Product policy for `#164` — RESOLVED.** (a) archive hides the course from owner listings and the public catalog; already-enrolled students keep access — user decision 2026-09-14.
2. **Engineering-resolvable during WP-C — RESOLVED.** `listCourses()` returns archived rows together with active ones; the disclosure filters them client-side rather than requiring a separate fetch — resolved 2026-09-14 during WP-C.
3. **Deferred by design — RESOLVED.** The archived-courses group uses the `.status-pill.archived` modifier (text only, same box model as `.status-pill.published`) plus the collapsed disclosure required by the Design section; no new visually-muted card treatment and no new token were added — resolved 2026-09-14 during WP-C, per the reviewed design handoff's binding constraint against new tokens.
4. **WP-E — RESOLVED 2026-09-15.** Journey 1 was retargeted to the seeded `student7@test.local` pending-first-login fixture. This is deterministic after reset, needs no test-created account, and avoids teardown mutation; the rationale and 4/4 local browser evidence are recorded in the current implementation addendum.

## Decisions made and grounded (no user input needed)

- `#164` uses archive (soft delete), not hard delete, on the FK and data-preservation evidence cited above. Hard delete is rejected.
- `#163`'s `OwnerSettingsPage` component has no unique functionality and is removed; its file's live `ColorPreview` export and its CSS are preserved.
- `#168`'s tie-break key is the lowest `position` among `unlocked-incomplete` rows.

## Browser UI dialog policy

Required. Native `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload` are prohibited across every browser-rendered surface. The `#164` archive confirmation must use the app-owned accessible `src\components\Modal.tsx` with the keyboard/focus behavior specified in the Design section (initial focus on the dialog container, focus trap, Escape-unless-suppressed, explicit post-success focus fallback). The deterministic source scan `src\__tests__\nativeDialogPolicy.test.ts` must stay green, and modal keyboard/focus must be verified in the browser.

## Browser UI validation

- **Launch/readiness:** `npm run build && npx vite preview --port <free> --strictPort`, with `E2E_BASE_URL` set to the preview origin. Local Supabase at `127.0.0.1:54321` via `npx supabase start`. Playwright is the only authorized browser-validation backend for this plan; `claude-in-chrome` is not authorized here.
- **Base URL:** the `vite preview` origin from the launch command.
- **Fixture/reset:** `npx supabase db reset` (permitted for the local fixture database only). Fixture accounts: `owner@test.local`, `student1@test.local`, `student2@test.local`, `fullaccess@test.local`, all with password `password`. For WP-C, seed or create at least three owner courses so the grid, the archive action, and the resulting empty and non-empty grid states are all reachable; `seed.sql` has no authored course titles today (courses are backfilled from bands, and "Beginner" is a real seeded band name) — reuse an existing band name rather than inventing product copy, and flag the gap rather than fabricating a title. For WP-G, the WP-B seed must provide two or more simultaneously `unlocked-incomplete` lessons with distinct `position` values.

**Journeys (all at both viewports):**

1. Each `.course-card` shows both "Open workspace" and "Archive," each at least 44px tall, no wrap overflow at 390px.
2. Clicking Archive mounts exactly one `[role="dialog"][aria-modal="true"]`, initial focus is the dialog container, Tab/Shift+Tab stay inside, and no native dialog fires.
3. Escape unmounts the dialog and returns focus to the same Archive button.
4. Confirm carries `disabled` during the request; on success the card is removed, the always-mounted `aria-live="polite"` region contains the title plus "archived," and `document.activeElement` is the fallback heading, not `document.body`.
5. Expanding the archived disclosure toggles `aria-expanded` and reveals the card with `.status-pill.archived` reading "archived" and specifically not "draft."
6. Archiving down to zero active courses reveals `.workspace-empty` while the disclosure still shows archived cards.
7. A forced rejected archive keeps the modal open, renders `[role="alert"]` in `.modal-body`, and removes Confirm's `disabled`.
8. On `/learn/:id` with two or more `unlocked-incomplete` rows, exactly one `.control--primary` exists, on the lowest-`position` row, that row alone shows "Up next," and no two instances share an accessible name.
9. With the primary row's trigger still idle and visible, opening a demoted row's confirm step leaves `.control--primary` count at exactly 1, and that row's Confirm/Cancel render `.control--secondary`/`.control--quiet`.
10. Completing the primary lesson unmounts its control and promotes the next-lowest-position row to `.control--primary` with the "Up next" marker, still exactly one.
11. WP-F: a Field error is announced and does not introduce a duplicate or ambiguous alert on any affected surface.

- **Viewport profiles:** 1440px and 390px, both required for every journey.
- **Visible outcomes:** `.control--primary` count (1 at every step, including the concurrent confirm-step case), `role="status"` / `role="alert"` / `aria-live` region text content, `aria-expanded` and `aria-label` attribute values, native `disabled` attribute presence and absence, and `document.activeElement` identity at each named step — all Playwright-observable without relying on screenshots alone.

## Cross-vendor judgment (Codex, selective, guarded)

Cross-vendor Codex judging runs in shadow mode with standing user authorization to apply evidence-backed findings. Deterministic failures always dominate a judge pass and shadow findings are never blocking. Eligible checkpoints per `docs\JUDGE-CONTRACT.md`:

- **PLAN_DUCK** — on this draft, before user approval.
- **CODE_REVIEW** — on the WP-C (archive UI + data layer + migration) and WP-G (tie-break) diffs, which carry the most design and data risk.
- **VERIFICATION_CHALLENGE** — on the WP-C completion claim.

Respect the contract's standing call caps.

## Cross-vendor judgment (Codex PLAN_DUCK)

A Codex `PLAN_DUCK` pass ran on this plan in shadow mode under the user's standing authorization to apply evidence-backed findings. Shadow findings are advisory, but the user's standing authorization directs that evidence-backed findings be folded into the plan. The following three findings were accepted and are incorporated at the cited locations:

| Finding ID | Severity | Claim | Disposition | Applied in |
|---|---|---|---|---|
| `J-CF-001` | major | WP-A's deletion inventory was incomplete. `src\__tests__\wp7-settings-conformance.test.tsx` touches `OwnerSettingsPage` in three distinct ways that must be handled differently: (a) import/render sites that break at compile time and must be retired/retargeted; (b) `fs.readFileSync` reads of `OwnerSettingsPage.tsx` source that would throw `ENOENT` after deletion and must be retired; (c) `fs.readFileSync` reads of `OwnerSettingsPage.css` source, which stays valid because WP-A retains the CSS file and must be preserved, not swept away. | Accepted and incorporated. | WP-A scope (new mandatory pre-deletion inventory step) and WP-A acceptance checks. |
| `J-CF-002` | major | WP-D's throwaway-student alternative lacked a required cleanup step; only the capture/restore path was described as self-cleaning. | Accepted and incorporated. | WP-D specification (new cleanup-obligation paragraph) and WP-D acceptance checks (residual-account/enrollment post-run check). |
| `J-CF-003` | minor | WP-F's hand-written alert-assertion list was presented as if complete; a repository search found roughly 42 matching files against roughly 20 named, so the list must be labeled illustrative and a generated complete inventory required instead. | Accepted and incorporated. | WP-F specification (list relabeled illustrative, new sites added) and WP-F acceptance checks (generated inventory with coexistence classification). |

## Research

Research was not needed for this plan. The two candidate unknowns — Supabase cascade/RLS behavior for archive, and whether `public.courses` needed a new RLS policy — were both resolved locally from the migration files cited above.
