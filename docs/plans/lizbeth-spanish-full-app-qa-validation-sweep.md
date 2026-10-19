# Lizbeth Spanish — Full-App QA Validation Sweep

**Status: Approved**

**Approval record:** Approved by rob.hasselbach@gmail.com on 2026-08-29, via direct interactive-session response to the orchestrator. The user's exact reply — "1. include. 2. approve" — answered the orchestrator's two pre-execution questions: (1) destructive owner journeys, resolved as INCLUDE; (2) plan approval, resolved as APPROVED. See Section 14 for the resolved decision record.

## 1. Outcome and audience

This plan defines a repeatable, deterministic browser-evidence QA sweep of the entire Lizbeth Spanish web app, exercised as both the owner/admin role and the student role. The deliverable is a triage-ready findings register of reproducible discrepancies, not a set of fixes.

Audience: the orchestrator, `browser-validator` (who executes the sweep), and the user, who will triage each finding after the sweep completes.

## 2. Scope and non-goals

**In scope:**
- Read-only functional and visual QA discovery across the full route surface, for both the owner and student roles.
- Deterministic per-page accessibility, contrast, and screenshot evidence at three viewport profiles.
- Browser UI dialog invariant enforcement (no native `alert`/`confirm`/`prompt`/`beforeunload`).
- Structured discrepancy logging in the findings register format defined below.

**Non-goals (explicit):**
- No new features.
- No design work of any kind (see Section 4, Design route).
- No product-code modification.
- No automatic remediation. Every discovered defect is logged for user triage, never silently fixed. Any fix requires a separate, subsequently approved plan.

## 3. Target surface

`target_surface: browser-web-ui`.

The application is confirmed as a React 18 + Vite single-page app (`vite`, `@vitejs/plugin-react`, `react-dom` in `package.json`). The repository also ships an Electron desktop wrapper (`desktop:start` → `electron desktop/main.cjs`, plus `desktop:package`), but that wrapper is **out of scope** for this sweep. Only the browser-served web app is validated.

Repository root for this work: `H:\CommandCenter\orchestrator\lizbeth_spanish` — its own Git repository, nested inside the orchestrator repository, and excluded from the orchestrator's `.gitignore`.

## 4. Design route

`design_route: none`. Per `docs/DESIGN-CONTRACT.md`, `none` applies when there is no user-visible interface or design-system effect. This sweep validates an existing app and produces no interface or token change, so no design-fleet role (design-generalist, design-director, UX architect, visual-system designer, motion designer, asset art director, design-reviewer, design-prototyper) is invoked.

Atelier's `design_review`, `design_critique`, and `contrast_check` MCP tools are used here strictly as deterministic **QA evidence instruments** operated by `browser-validator`. They are not design-fleet deliverables and do not substitute for the design review gate, which does not apply to this plan.

`design_handoff: none`. `design_review: none`.

## 5. Repository findings and evidence

All facts below were verified directly against the repository. Paths are given exactly as found.

### A. Stack and entry points

- `H:\CommandCenter\orchestrator\lizbeth_spanish\package.json` — scripts: `dev` = `vite`; `build` = `tsc && vite build`; `preview:prod` = `vite preview --port 4173 --strictPort`; `test` = `vitest`; `test:e2e` = `playwright test`; plus `lint`, `type-check`, `verify:build`.
- Backend is Supabase (`@supabase/supabase-js`), run locally via the Supabase CLI plus Docker.
- `H:\CommandCenter\orchestrator\lizbeth_spanish\src\App.tsx` — top-level composition: `AccessibilityProvider` > `AuthProvider` > `AuthGate` > (`BrandingProvider` > `AuthenticatedApp`).
- `H:\CommandCenter\orchestrator\lizbeth_spanish\src\hooks\useRoute.ts` — a hand-rolled `pushState` router (no router library): `navigate`, `replaceNavigate`, a custom `lizbeth:navigate` event, and `popstate`. Back/forward navigation and typed/refreshed direct URLs are genuinely supported and must be exercised, not assumed.

### B. Environment and configuration

- `H:\CommandCenter\orchestrator\lizbeth_spanish\.env.example` — requires `VITE_SUPABASE_URL` (local default `http://127.0.0.1:54321`) and `VITE_SUPABASE_ANON_KEY` (obtained from `supabase start` output). A service-role key must never carry a `VITE_` prefix.
- `H:\CommandCenter\orchestrator\lizbeth_spanish\PHASE_3A_SETUP.md` — documents `npx supabase start` (Docker required), migrations auto-applied from `supabase/migrations/`, seed auto-loaded from `supabase/seed.sql`, Supabase Studio typically at `http://localhost:54323`, Postgres on `54322`.
- `H:\CommandCenter\orchestrator\lizbeth_spanish\playwright.config.ts` — `testDir` is `./src/__tests__/e2e`; `baseURL` = `process.env.E2E_BASE_URL || 'http://localhost:8888'`. When `E2E_BASE_URL` is unset, Playwright boots `npm run build && netlify serve --context production --port 8888`.

### C. Critical runtime nuance affecting the login step

`H:\CommandCenter\orchestrator\lizbeth_spanish\src\components\LoginForm.tsx` line 99 gates the on-page test-account quick-select list behind `import.meta.env.DEV`. The visible test-account list therefore appears **only** under the Vite dev server (`npm run dev`), **not** under the `netlify serve` production-parity server that `playwright.config.ts` defaults to.

Consequence: the **primary sweep runs against `npm run dev`**, which is also what the user described ("test accounts visible on the login page"). A production-parity pass on port 8888 is an optional secondary run and must use typed credentials, not quick-select.

### D. Test accounts

Statically discoverable from `H:\CommandCenter\orchestrator\lizbeth_spanish\supabase\seed.sql`, which seeds auth users, all with password `password`:

- `owner@test.local` (uid ...0099) — carries `"role":"owner"` in `raw_app_meta_data`; this is the owner/admin account.
- `student1@test.local` — 3 weeks into Beginner.
- `student2@test.local` — just enrolled today.
- `student3@test.local` — completed Beginner.
- `student4@test.local` — 5 days in.
- `student5@test.local`, `student6@test.local`.
- `student7@test.local` — email **not** confirmed (`email_confirmed_at` is null).
- `fullaccess@test.local` — full-access test student.

`LoginForm.tsx` quick-select surfaces only: student1–student4 and `owner@test.local`, password `password`.

Execution-phase discovery (not a planning blocker): confirm at runtime that the seeded accounts actually authenticate, that the quick-select list renders, and capture the exact resolved dev-server port. Vite's default is `5173` but it increments if the port is occupied.

### E. Complete route/surface map

Verified from `App.tsx`, `useRoute.ts`, `AdminShell.tsx`, and `src/pages`.

**Public / unauthenticated** — `AuthGate` short-circuits *before* any session check (`App.tsx` lines 186–187):
- `/courses` and `/courses/:courseId` → `src/pages/PublicCatalogPage.tsx` ("Explore courses", "What you'll learn").

**Auth states:**
- Loading ("Loading…").
- `sessionError` state rendering `role="alert"` plus a Retry button (`retrySession`).
- Unauthenticated → `src/components/LoginForm.tsx` (inline email validation, `role="alert"` error region, no native dialogs).

**Forced password change gate:** `src/components/ForcedPasswordChangeGate.tsx`, driven by `shouldForcePasswordChange(session.user)`, re-evaluated on every render (`App.tsx` lines 55–66). It must reappear if the flag is re-asserted mid-session, and must survive a page refresh.

**Student surface:**
- `/` and `/roadmap` → `src/pages/RoadmapPage.tsx` ("Your roadmap"; `role="alert"` error state; `src/components/WeekCard.tsx`; `src/components/BandRoadmap.tsx`; locked/unlocked/"Unlocks in X days" three-state week rendering).
- `/roadmap/:enrollmentId/week/:weekNumber` → `src/pages/WeekDetailPage.tsx` ("Resources"; multiple `role="status"` and `role="alert"` regions at approximately line 61 and lines 194–266) with `src/components/ResourcesPanel.tsx`, `src/components/FlashcardsViewer.tsx`, `src/components/LessonContentView.tsx`, `src/components/IpNotice.tsx`. Includes a "← Back to roadmap" control.
- `/feedback` → `src/pages/FeedbackPage.tsx` ("Feedback & topic suggestions") with `src/components/FeedbackForm.tsx`.
- Header nav for a student: Roadmap, Feedback, Sign out. No "Owner workspace" button.
- Malformed week URL: `matchWeekDetailRoute` fails closed on a non-numeric week segment (`useRoute.ts` lines 59–75) — must render a "not available" state, never a broken resolve.

**Owner surface** (gated by `isOwnerUser` from `src/lib/ownerSettingsAuthorization.ts` / `src/lib/adminStudentAuthorization.ts`):
- `/` auto-redirects (`replaceNavigate`) to `/admin/dashboard`.
- Any unrecognized `/admin/*` path redirects to `/admin/dashboard`, briefly rendering `role="status"` "Redirecting to the owner dashboard…".
- `src/components/AdminShell.tsx` nav (`aria-label="Owner workspace sections"`), six links: Dashboard `/admin/dashboard`, Students `/admin/students`, Feedback inbox `/admin/feedback`, Course settings `/admin/course-settings`, Brand & design `/admin/brand-design`, Business settings `/admin/business-settings`. Links are real `<a href>` elements intercepted only on a plain left-click; ctrl/meta/shift/alt/middle-click must fall through to native browser navigation.
- `/admin/dashboard` → `src/pages/OwnerDashboardPage.tsx` ("Course pulse", "Attention rules", "Needs attention", "Student progress").
- `/admin/students` → `src/pages/AdminStudentsPage.tsx` ("Students"; multiple states around lines 174, 183, 190, 399).
- `/admin/students/:studentId` → same page, detail view ("Account Access", "Enrollments", "Assign a new band").
- `/admin/feedback` and `/admin/feedback/:feedbackId` → `src/pages/OwnerFeedbackPage.tsx` ("Feedback inbox", empty state "No feedback yet", "Recent notes").
- `/admin/course-settings` → `src/pages/CourseSettingsPage.tsx` ("Course settings", "Course authoring workspace", "Your library is ready").
- `/admin/courses/new` → `src/pages/NewCoursePage.tsx` ("Create a course").
- `/admin/courses/:courseId/:tab` → `src/pages/CourseWorkspacePage.tsx` — observed tab sections: Course outline / Published outline, Content studio, Asset library, Cohorts and enrollment, Course settings / Published settings, Version history and migration, Publishing, plus a "Workspace section unavailable" fallback for an unknown tab.
- `/admin/brand-design` → `src/pages/BrandDesignPage.tsx` ("Brand & design").
- `/admin/business-settings` → `src/pages/BusinessSettingsPage.tsx` ("Business settings").
- `src/pages/OwnerSettingsPage.tsx` ("Course settings") also exists in the tree. The sweep must determine at runtime whether it is still reachable from any nav path and log an orphaned/dead-page finding if it is not.

**Non-owner hitting an owner route:** `AdminShell.tsx` lines 28–31 render an inline `role="alert"` permission-denied panel ("You do not have permission to view this owner area…"). This is a required negative journey for the student role at `/admin/dashboard`, `/admin/students`, and `/admin/feedback`.

**Global chrome:** app header brand lockup, `BrandLogo` (configured logo with alt text, else `aria-hidden` placeholder "L"), owner-configured `brand_name`, footer copyright rendered only when `branding.legal_copyright_text` is set, and `src/components/AccessibilitySettings.tsx` present on every authenticated page.

### F. Owner modal inventory

All built on the shared `src/components/Modal.tsx` primitive, which has a focus trap (see `src/__tests__/Modal-FocusTrap-ShiftTab.test.tsx`):

- `src/components/AdminStudentModals.tsx`: `DisableStudentModal`, `HardDeleteStudentModal`, `UnassignModal`, `ReassignModal`, `WipeSaveModal`, `ConfirmEmailModal`, `ReissueAccessModal`, `TogglePasswordChangeModal` (includes a "Cancel" / "Confirm reset" pair).
- `src/components/RegisterStudentModal.tsx`: register a new student.

Every one of these must be opened during the owner sweep and checked for: focus moved into the dialog on open, Tab and Shift+Tab trapped inside, Escape closes it, focus returned to the invoking trigger, and no native dialog anywhere.

### G. Existing deterministic assets to reuse (do not rewrite)

- `src/__tests__/nativeDialogPolicy.test.ts` — the existing source-level scan for `alert(`, `confirm(`, `prompt(`, `beforeunload`. This **is** the deterministic no-native-dialog scan; run it via `npm test -- --run nativeDialogPolicy` rather than authoring a new scanner.
- Existing Playwright specs in `src/__tests__/e2e/`: `deep-route-check.spec.ts`, `owner-dashboard.spec.ts`, `issue-3-feedback-inbox.spec.ts`, `issue-4-owner-workspace.spec.ts`, `gap-1-owner-settings-persistence.spec.ts`, `gap-2-non-owner-permission-denied.spec.ts`, `gap-3-rls-signed-url-denial.spec.ts`, `gap-4-admin-students-remediation.spec.ts`, `browser-validation-status-clarity-and-gate.spec.ts`, `neo-workbook-visual-smoke.spec.ts`. These are prior-coverage references indicating what is already asserted; this sweep is broader and interactive, and does not replace them.

## 6. Environment bring-up

Phase 0 below is a hard blocker: if Docker, Supabase, or account authentication fail, the sweep stops and reports rather than proceeding in a degraded state.

1. `cd H:\CommandCenter\orchestrator\lizbeth_spanish`; confirm Docker is running (`docker --version`).
2. `npx supabase start`. Record the emitted API URL and anon key. Confirm Supabase Studio is reachable.
3. Ensure `.env.local` (or equivalent) carries `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` matching step 2. Never set a service-role key with a `VITE_` prefix.
4. `npx supabase db reset` — re-applies `supabase/migrations/` and `supabase/seed.sql` to a known clean state. This is the canonical reset used throughout the sweep.
5. `npm run dev`. Capture the exact resolved base URL from Vite's output (default `http://localhost:5173`; may increment). Readiness = that URL returns the app shell and the login page renders.
6. Runtime discovery checkpoint: confirm the quick-select test-account list renders on the login page, and that `owner@test.local` / `password` and `student1@test.local` / `password` both authenticate. If either fails, stop and report a Phase-0 blocker rather than proceeding with a degraded sweep.

## 7. Ordered journeys

### Phase 0 — Environment bring-up and runtime discovery (execution phase, blocking)

Steps 1–6 as listed in Section 6 above.

### Phase 1 — Deterministic source-level gate (before any browsing)

7. `npm test -- --run nativeDialogPolicy` — must pass. A failure is an S1 finding on its own.
8. `npm run type-check` and `npm run lint` — record output as baseline context. Pre-existing failures are logged as findings, not fixed.

### Phase 2 — Public / unauthenticated surface

9. `/courses` and `/courses/:courseId` (use a real course id discovered from the catalog page; also try a nonsense id for the not-found path).
10. Login page: empty-submit inline validation (must focus the email field and show `#login-email-error`, no native dialog); wrong-password error surfaced via `role="alert"`; quick-select buttons populate both fields.

### Phase 3 — Student role sweep

Run as `student1@test.local`; then spot-check `student2`, `student3`, `student4` for their distinct enrollment states.

11. Sign in; land on `/roadmap`.
12. Roadmap three-state rendering: unlocked weeks, locked weeks, and "Unlocks in X days" messaging. Verify student1 shows weeks 1–4 unlocked and week 5+ locked, per the seeded scenario.
13. Open an unlocked week → `/roadmap/:enrollmentId/week/:weekNumber`. Exercise the Resources panel, resource download/signed-URL affordances, FlashcardsViewer (advance/flip/exhaust the deck), LessonContentView, and IpNotice.
14. "← Back to roadmap" control, then browser Back and Forward buttons, then a hard refresh on a deep week URL — the pushState router must restore correctly in all three cases.
15. Direct-URL locked-week attempt: type a locked week URL. Expected: a clear denial/not-available state, no resource leak.
16. Malformed week URL (non-numeric segment, e.g. `/roadmap/<id>/week/abc`): must fail closed.
17. `/feedback`: submit a valid feedback/topic suggestion; confirm success state. Submit an empty/invalid form; confirm inline validation, no native dialog.
18. AccessibilitySettings: toggle each available setting and confirm a visible rendered effect persists across a route change and a refresh.
19. Negative journey: as the student, visit `/admin/dashboard`, `/admin/students`, `/admin/feedback` directly. Expected: the inline `role="alert"` permission-denied panel, never owner data.
20. Spot-check `student2` (just enrolled — week 1 only), `student3` (completed Beginner — all weeks open), `student4` (5 days in — weeks 1–2).
21. Sign out. Confirm the session is truly gone: after sign-out, a Back-button press must not restore an authenticated view.
22. `npx supabase db reset` before the owner run.

### Phase 4 — Owner/admin role sweep (`owner@test.local`)

23. Sign in; confirm the automatic `/` → `/admin/dashboard` redirect.
24. `/admin/dashboard`: Course pulse, Attention rules, Needs attention, Student progress — verify each renders real seeded data, not an empty or error state.
25. `/admin/students`: roster loads; verify status labels; open `/admin/students/:studentId` for a seeded student and exercise Account Access, Enrollments, and "Assign a new band".
26. Owner modals — open every one and run the full keyboard/focus protocol (open focus, Tab + Shift+Tab trap, Escape, focus restore), then Cancel out without committing: `RegisterStudentModal`, `ConfirmEmailModal` (use `student7@test.local`, the unconfirmed account), `ReissueAccessModal`, `TogglePasswordChangeModal`, `ReassignModal`, `UnassignModal`, `DisableStudentModal`, `WipeSaveModal`, `HardDeleteStudentModal`.
27. `/admin/feedback` and `/admin/feedback/:feedbackId` — including the "No feedback yet" empty state and, after the student's Phase-3 submission if data is retained, the populated "Recent notes" state.
28. `/admin/course-settings`, `/admin/brand-design`, `/admin/business-settings` — load each, exercise every form: save a change, reload the page, and confirm the change persisted and is actually reflected in the rendered UI (brand name in the header, logo with alt text, footer copyright appearing only when set).
29. `/admin/courses/new` — create a course through the form.
30. `/admin/courses/:courseId/:tab` — visit every tab: outline, content studio, asset library, cohorts and enrollment, course settings, version history and migration, publishing. Also visit a bogus tab and confirm the "Workspace section unavailable" fallback.
31. Unknown-admin-route redirect: visit `/admin/nonsense` and confirm the redirect to `/admin/dashboard`.
32. Determine whether `src/pages/OwnerSettingsPage.tsx` is reachable from any nav path; if not, log an orphaned-page finding.
33. Modified-click check on AdminShell nav links: ctrl+click and middle-click must open a new tab natively rather than being swallowed.
34. Forced password change journey (destructive, run late): use the owner's `TogglePasswordChangeModal` to set the flag on a student, sign in as that student, confirm the gate blocks the app, confirm the gate survives a refresh, complete the change, and confirm normal access resumes.
35. Destructive journeys last, in this order, each followed by verification of the observable outcome: DisableStudent, UnassignModal, WipeSaveModal, HardDeleteStudentModal. After these, the seed state is spent.
36. Owner sign out.
37. `npx supabase db reset` to leave the environment clean.

### Phase 5 — Deterministic visual/a11y evidence (Atelier, interleaved with Phases 2–4 at each named state)

38. At every distinct page state named above, for each viewport profile, capture: `mcp__atelier__screenshot` (fixed viewport, visually stable), `mcp__atelier__a11y_audit` (axe-core), and `mcp__atelier__contrast_check` (APCA + WCAG).
39. Run `mcp__atelier__design_review` / `mcp__atelier__design_critique` on the primary states of each role for token-adherence and rendered-design critique, and `mcp__atelier__microcopy_lint` on form/error/empty states. Treat all output as QA evidence and findings input, not as design direction.
40. `browser-validator`'s charter (`browser-validator-core` skill) prohibits it from ever updating visual baselines or test snapshots. Accordingly, this sweep does **not** run `mcp__atelier__baseline_update` and does not establish a baseline. On the first clean run, capture `mcp__atelier__screenshot` output at each named state as first-run evidence only, filed alongside the findings packet. Baseline establishment and any subsequent `mcp__atelier__visual_diff` comparison against a baseline are explicitly deferred to a separate, later, explicitly-scoped run if the user wants ongoing visual regression tracking; this sweep does not create that baseline as a side effect.

## 8. Findings register format

Each finding is a discrete, independently triageable record:

- `id`: `LS-QA-NNN`
- `severity`: S1 blocker (data loss, security/authorization leak, unusable core journey, native dialog) | S2 major (feature broken or misleading) | S3 minor (state/copy/layout defect) | S4 polish (visual/a11y nit)
- `role`: owner | student | unauthenticated
- `route` and `viewport`
- `preconditions`: exact fixture/reset state and account
- `steps`: numbered, replayable from a clean `db reset`
- `expected` vs `observed`: stated separately, in observable terms
- `evidence`: screenshot path, a11y/contrast/visual_diff output
- `suspected_source`: candidate file path(s) — an observation, never a fix
- `triage_question`: the single decision the user must make

**Rule:** the sweep never decides fix vs. no-fix and never modifies product code. Findings are returned to the orchestrator for per-item user triage. Any remediation requires a separate plan and separate approval.

Each `QA_FINDING` record is the direct source for one GitHub issue body. The field set above maps one-to-one onto the issue template sections defined in Section 9 (Discrepancy logging to GitHub).

## 9. Discrepancy logging to GitHub

The user has given a direct scope change: every discrepancy found during the sweep must be filed as a GitHub issue on the `lizbeth_spanish` repository, not only returned as an in-conversation finding. The user will work from the issue tracker afterward.

### Repository target

- Verified directly from `H:\CommandCenter\orchestrator\lizbeth_spanish\.git\config`: remote `origin` = `git@github.com:lebobo88/lizbeth-spanish.git`.
- GitHub repo slug: `lebobo88/lizbeth-spanish`.
- Naming mismatch to note explicitly: the local directory is `lizbeth_spanish` (underscore) but the GitHub repository is `lizbeth-spanish` (hyphen). Every `gh` invocation must pass the slug explicitly via `--repo lebobo88/lizbeth-spanish` rather than relying on directory-inferred context.
- Corroborating evidence that an issue-tracker workflow is already in use in this repository: `.git/config` contains branches `issue-2-owner-dashboard`, `issue-3-feedback-inbox`, `issue-4-owner-workspace`.

### Separation of duties

This is the core constraint governing this section:

- `browser-validator` is read-only by charter and has no GitHub-write tool grant. It does **not** file issues. It produces only the structured findings packet.
- The sweep must not silently expand any agent's tool or permission surface. Adding GitHub-write capability follows the same explicit-approval path already used for the Atelier grant.
- The work therefore splits into two distinct, sequenced steps:
  - **Step A — Capture** (owner: `browser-validator`, read-only). For each discrepancy, emit a `QA_FINDING` record with every field already defined in the Findings register format (Section 8): id, severity, role, route, viewport, preconditions, steps, expected, observed, evidence paths, suspected_source, triage_question. No GitHub interaction whatsoever.
  - **Step B — File** (owner: the orchestrator, or a bounded agent explicitly granted `Bash(gh issue create:*)`). Runs only after a finding is captured in Step A, and transcribes it verbatim into a GitHub issue. Step B performs no analysis, no severity re-grading, and no code inspection. It is a transport step.
- Cadence: Step B may run incrementally after each finding is captured, or as a single batch after the sweep completes. Either is acceptable; the executed plan run must record which cadence was used.

### Execution-time preconditions

Verify before filing any issue; each of the following is a hard blocker:

- `gh --version` — confirms the GitHub CLI is installed. Do not assume it is present.
- `gh auth status` — confirms authentication with an account that has issue-write access to `lebobo88/lizbeth-spanish`. Do not assume authentication; this environment has not been verified.
- `gh issue list --repo lebobo88/lizbeth-spanish --limit 1` — confirms the slug resolves and issues are enabled on the repository.
- If any precondition fails: stop the filing step, report the exact failure, and fall back to returning the complete findings packet in-conversation. Do not attempt to authenticate, do not modify git config, and do not create the repository or enable issues on it. The capture work in Step A is still delivered regardless of whether filing succeeds.
- Also verify the label set exists before use (`gh label list --repo lebobo88/lizbeth-spanish`). If a required label is missing, either create it only if the user has approved label creation, or file the issue without that label and note the omission in the returned summary.

### Issue template and required fields

**Title convention:** `[QA-sweep] LS-QA-NNN: <short observable symptom> (<role> / <route>)`

Example: `[QA-sweep] LS-QA-007: Locked week resource list renders despite denial state (student / /roadmap/:enrollmentId/week/:weekNumber)`

**Labels** (applied via `--label`):
- Always: `qa-sweep`.
- Role, exactly one: `role:owner`, `role:student`, or `role:unauthenticated`.
- Severity, exactly one: `severity:S1`, `severity:S2`, `severity:S3`, `severity:S4` — mapping to the blocker/major/minor/polish definitions already in the Findings register (Section 8).
- Optional area label where obvious, for example `area:admin`, `area:roadmap`, `area:auth`, `area:a11y`.

**Body sections** (required, in this order):
1. `## Summary` — one sentence, observable symptom only.
2. `## Environment` — base URL and resolved port, viewport profile, account used, commit SHA of `lizbeth_spanish` at sweep time, and the fixture state (whether `npx supabase db reset` was applied).
3. `## Steps to Reproduce` — numbered, replayable from a clean `npx supabase db reset`.
4. `## Expected` — stated in observable terms.
5. `## Observed` — stated in observable terms, separate from Expected.
6. `## Evidence` — screenshot paths, plus `a11y_audit` / `contrast_check` / `visual_diff` output. Local absolute paths are not viewable from GitHub; attach or inline the screenshot where practical, otherwise record the path and state explicitly that it is local-only.
7. `## Suspected source` — candidate file path(s), explicitly labelled an observation and not a proposed fix.
8. `## Triage question` — the single decision the user must make.
9. `## Plan reference` — `docs/plans/lizbeth-spanish-full-app-qa-validation-sweep.md`, plus the journey/phase number that surfaced it.

**Command shape** (illustrative; the body is supplied via a file to preserve Markdown formatting):

```
gh issue create --repo lebobo88/lizbeth-spanish --title "<title>" --label "qa-sweep" --label "role:student" --label "severity:S2" --body-file <path>
```

**Duplicate discipline:** before filing, check `gh issue list --repo lebobo88/lizbeth-spanish --label qa-sweep --search "<symptom>"`. If an open issue already covers the symptom, add a comment referencing the new `LS-QA-NNN` rather than opening a duplicate.

### Authorization boundary

- Filing issues is logging only. It does **not** authorize fixing anything.
- No product code change, no auto-remediation, no branch, no commit, no pull request, no closing of issues. The validation-only scope in Section 2 (Scope and non-goals) is unchanged and remains binding.
- The user's instruction authorizes exactly one new external write: creating issues (and duplicate-avoidance comments) on `lebobo88/lizbeth-spanish`. Nothing broader is implied.
- Any remediation of a filed issue requires a separate plan and separate explicit approval.

## 10. Acceptance and validation

- Every journey in Section 7 has been executed for its named role and every named viewport profile, with a screenshot captured at the asserted state.
- `npm test -- --run nativeDialogPolicy` passes.
- Zero native `alert` / `confirm` / `prompt` / `window.*` variants / `beforeunload` observed at runtime across the entire sweep.
- Every modal encountered passed the open-focus / Tab / Shift+Tab trap / Escape / focus-restore protocol.
- Each `a11y_audit` and `contrast_check` result is recorded per page state; every violation becomes a numbered finding.
- Explicit evidence rule: a clean console is **not** pass evidence. Every "working" claim must be backed by a rendered screenshot or an observed visible state change. DOM presence or console silence alone never establishes a pass.
- The deliverable is the findings register, returned to the orchestrator; it is complete when every route/state in the Section 5.E surface map has a recorded pass or a numbered finding.
- Every S1–S4 finding has a corresponding filed GitHub issue on `lebobo88/lizbeth-spanish`, or a recorded reason why filing was blocked.
- The returned summary lists each finding ID paired with its issue number/URL.
- No issue was closed, and no code change accompanied any issue.

## 11. Browser UI dialog policy

Required and enforced. No native `alert`, `confirm`, `prompt`, their `window.*` forms, or `beforeunload` prompts anywhere in the app. Confirmation and acknowledgement must use the app-owned accessible `src/components/Modal.tsx` primitive; validation must be inline.

- Deterministic source scan: `npm test -- --run nativeDialogPolicy` (`src/__tests__/nativeDialogPolicy.test.ts`).
- Runtime enforcement: no native dialog may appear during any journey; every modal encountered gets the full keyboard/focus verification described in Section 5.F.
- Any violation is an automatic S1 finding.

## 12. Browser UI validation inputs

- `target_surface`: browser-web-ui (Chrome-first via `mcp__claude-in-chrome__*`; Atelier `mcp__atelier__*` for deterministic evidence).
- `launch/readiness command`: `cd H:\CommandCenter\orchestrator\lizbeth_spanish` → `npx supabase start` → `npx supabase db reset` → `npm run dev`. Readiness = Vite prints its local URL and the login page renders.
- `base URL`: the URL Vite actually prints in Phase 0 (default `http://localhost:5173`, capture the real value). Optional production-parity secondary: `http://localhost:8888` via `npm run build && netlify serve --context production --port 8888` (no quick-select there).
- `fixture/reset`: `npx supabase db reset` (re-applies `supabase/migrations/` + `supabase/seed.sql`); run before the student sweep, between roles, and at the end. Accounts per Section 5.D.
- `journeys`: the full ordered list in Section 7, Phases 2–4, covering the complete route surface for both roles.
- `viewport profiles`: desktop 1440x900; tablet 768x1024; mobile 390x844. Every named page state is captured at all three.
- `visible outcomes`: for each journey, a rendered screenshot showing the asserted state — roadmap three-state weeks, week-detail resources, denial states, permission-denied alert, forced-password-change gate, each modal open with focus visible, each settings change persisted after reload and reflected in the header/footer chrome, each admin tab, and each empty/error state. Console cleanliness is explicitly not accepted as pass evidence.
- `output artifacts`: (1) the screenshot and a11y/contrast/visual_diff evidence set; (2) the structured findings packet (`QA_FINDING` records per Section 8); (3) the filed GitHub issue URLs per Section 9. `browser-validator` produces artifacts (1) and (2) only; it does not file issues.

## 13. Risks and rollback

- **R1** Destructive owner actions corrupt the fixture mid-sweep. Mitigation: destructive journeys ordered last; `npx supabase db reset` between roles and at the end.
- **R2** Dev-only quick-select absent under the production-parity server (`LoginForm.tsx:99`, `import.meta.env.DEV`). Mitigation: primary run on `npm run dev`; typed credentials for any 8888 run.
- **R3** Vite port drift breaks a hardcoded base URL. Mitigation: capture the resolved URL in Phase 0 and use it throughout.
- **R4** Docker/Supabase unavailable. Mitigation: Phase 0 is a hard blocker; report rather than degrade.
- **R5** Wrong-target risk — accidentally validating a hosted Supabase project. Mitigation: assert `VITE_SUPABASE_URL` points at `127.0.0.1` before any journey.
- **R6** Volume: this sweep is large. Mitigation: phases are independently resumable from a `db reset`; partial completion is reported as partial, never as a pass.
- **R7** Baseline laundering. Mitigation: this sweep does not run `mcp__atelier__baseline_update` and establishes no baseline (Section 7, step 40); `browser-validator`'s charter prohibits it from updating visual baselines or test snapshots. First-run screenshots are captured as evidence only. Baseline establishment and `visual_diff` comparison are deferred to a separate, later, explicitly-scoped run.
- **R8** `gh` unavailable or unauthenticated, blocking issue filing. Mitigation: the execution-time precondition check in Section 9, plus in-conversation fallback; no attempt to self-authenticate.
- **R9** Duplicate or noisy issues polluting the tracker. Mitigation: the duplicate check in Section 9, plus the mandatory `qa-sweep` label, which makes bulk triage and cleanup easy.
- **R10** Evidence screenshots referenced by local path are not viewable from GitHub. Mitigation: attach or inline where practical, and flag path-only evidence explicitly in the issue body.
- **Rollback:** `npx supabase db reset` fully restores fixture state. No product code is touched, so there is nothing else to revert. Filed GitHub issues are the only artifact that persists outside the repository working tree; they can be closed or deleted by the user, and nothing else needs reverting.

## 14. Assumptions and open decisions

**Assumed (safe, from repository evidence):**
- Local Supabase + Docker is the intended backend.
- Seeded password is `password`.
- `npm run dev` is the intended sweep target.
- The GitHub slug is confirmed as `lebobo88/lizbeth-spanish` (Section 9).

**Execution-phase discovery, not a planning blocker:**
- Exact resolved dev-server port.
- Live confirmation that seeded accounts authenticate.
- Real course/enrollment/student ids for parameterized routes.
- Whether `OwnerSettingsPage.tsx` is still reachable.
- Whether `gh` is installed and authenticated with issue-write access to `lebobo88/lizbeth-spanish`, and whether the required labels already exist.

**Pre-execution decisions — resolved:**

- **(a) Destructive owner journeys — RESOLVED: INCLUDE.** Approved by rob.hasselbach@gmail.com on 2026-08-29. Phase 4 steps 34–35 (the TogglePasswordChange / forced-password-change flow, DisableStudent, UnassignModal, WipeSaveModal, and HardDeleteStudentModal) are in scope for this sweep. These journeys are ordered last and bracketed by `npx supabase db reset`, so the seeded fixture state is recoverable after they run.
- **(b) Final plan approval — RESOLVED: APPROVED.** Approved by rob.hasselbach@gmail.com on 2026-08-29, via direct interactive-session response to the orchestrator ("1. include. 2. approve").

**Remaining, not blocking approval:**
- Per-finding triage after the sweep returns (Section 8, Section 9) — this occurs after execution, not before it.

## 15. Judge route

`judge_route`: PLAN_DUCK eligible but advisory/shadow only. This is a read-only validation plan with no code change, so no blocking cross-vendor gate applies. `CODE_REVIEW` and `VERIFICATION_CHALLENGE` are not applicable (no diff exists to review). `VISUAL_REVIEW` is optional, at the orchestrator's discretion, on the captured screenshot set.

## 16. Approvals required

- Explicit user approval of this plan document is required before any execution phase begins, including the pre-execution destructive-journeys toggle in Section 14.
- No design-fleet approval applies (`design_route: none`).
- No blocking cross-vendor judge gate applies (Section 15).
- This plan makes no product-code change and therefore requires no T1/T2/T3 code-writer dispatch; `browser-validator` executes the sweep directly once the plan is approved. Issue filing (Section 9) is a separate, explicitly bounded write authorization and does not expand `browser-validator`'s own permissions.

## 17. Engineering mode and downstream owner

- `engineering_mode`: standard.
- `team_authorization`: not applicable.
- `downstream_owner`: `engineering-fleet` — specifically `browser-validator` executes the sweep. No writer agent implements anything; this is a validation-only job. Findings return to the orchestrator for user triage, and any resulting remediation requires a new, separately approved plan.
