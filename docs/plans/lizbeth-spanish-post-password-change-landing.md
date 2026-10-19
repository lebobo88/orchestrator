# Plan: Lizbeth Spanish post-sign-in and post-password-change landing

- Plan id: `lizbeth-spanish-post-password-change-landing`
- Task id: `lizbeth-postpw-admin-redirect`
- Status: **APPROVED 2026-10-13 (Revision 1).** The GitHub issue is filed as #259 (https://github.com/lebobo88/lizbeth-spanish/issues/259). Hosted actions (Netlify deploy) still need separate explicit approval.
- Approval note: the user approved on 2026-10-13, verbatim: "Plan approved, use recommendations for open decisions. Proceed as planned for items now that prerequisites are merged."
  - D-L1 adopted: PR L is its own small PR, first in Wave 3, before PR 3a and PR 3b.
  - D-L2 resolved: issue #259 is filed.
  - D-L3 adopted: after sign-in, the owner always lands on `/admin/dashboard`, with no returnTo.
  - Hosted actions (Netlify deploy) still need separate approval.
- Revision 1 (PLAN_DUCK J-001..J-006, Codex shadow, 2026-10-13): J-001 auth-token and public-path exemptions for the identity-change landing; J-002 re-login of the same user after sign-out; J-003 precise restore baseline including failed load plus Retry; J-004 L5 cross-tab journey redesigned for shared persisted sessions; J-005 RED split into reproduction versus preservation tests; J-006 `roleHomeFor` contract. Touches sections 2, 3 (no change to D-L1), 9, 10, 11, 12, 14.
- Route: engineering. Engineering mode: standard (T1 first-line, T2 escalation per fleet rules). No extreme-advisory team.
- Target: `lebobo88/lizbeth-spanish`, `main` at `ac7815839beaed903f654bde2482cd5dae3d716a` (includes PR #229, #230, #231, #232).
- Evidence base: read-only checkout `H:\CommandCenter\orchestrator\lizbeth_main_verify_20261013` (detached at `ac78158`). Every `file:line` reference in this plan is at `ac78158`.
- Related plans (sequenced against, not duplicated): `docs/plans/lizbeth-spanish-open-issues-deep-dive-2026-10.md` (Wave 3 PR 3a and PR 3b) and `docs/plans/lizbeth-spanish-password-flow-and-followups.md` (PR D and PR E).
- Judge route: PLAN_DUCK eligible per `docs/JUDGE-CONTRACT.md` (the orchestrator runs it on this draft before approval; medium risk, auth routing). CODE_REVIEW recommended for the PR (auth client routing; the parent plan recommends CODE_REVIEW for auth PRs), standard cap of two calls. VISUAL_REVIEW skipped (no visual change). Deterministic test failures dominate. No judge pass has been run for this draft.
- Design route: none, see section 12.

Reading guide: sections 1, 2, 3, 4, 13 and 14 are what an approver needs. Sections 5 to 11 hold the evidence and execution detail for the engineering fleet. Evidence is labelled Observed unless marked Inference or Unknown.

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

User report, verbatim (2026-10-13): "We found another issue to address. A user who signs in can't change their own password. So when the owner reissues access setting a new temp pw and requiring the user to change PW at next login, after they change their new password it sends them to a */admin/* URL and the pages says they don't have access, naturally. Instead it should route them to the main page any other user sees after sign in. File a gh issue and perform proper root cause investigation and diagnosis and plan a proper fix so it behaves as expected moving forward."

Note on the report's wording: "can't change their own password" is the user's description of the symptom. The password change itself succeeds (Edge atomic write, `index.ts:1738-1741`). What fails is the landing after it.

---

## 1. Outcome and audience

Observable result: after any successful sign-in (a session identity change) or forced-password change (gate cleared), the user lands on their role home. Students land on `/roadmap`. Owners land on `/admin/dashboard`. A role-invalid path is never kept across those transitions, and the "You do not have permission to view this owner area" card never appears as a consequence of signing in or changing a password.

Audience: students (Lizbeth's real students on a live production site), the owner, and the engineering fleet.

## 2. Root cause summary

The app has no post-authentication landing step. The route is `window.location.pathname` (`src/hooks/useRoute.ts:310-330`), and it outlives both sign-out and sign-in. Neither `AuthContext.signOut` (`src/context/AuthContext.tsx:168-173`) nor `signIn` (`:147-166`) navigates, and `AuthGate` renders the sign-in form in place with no URL change (`src/App.tsx:793-809`). The forced-password gate renders regardless of path (`src/App.tsx:98-104`), which hides the stale URL from the student while the gate is showing. When the password change succeeds, the session updates and `AuthenticatedApp` renders the unchanged `/admin/*` path. For a non-owner that path is the `AdminShell` permission-denied card (`src/components/AdminShell.tsx:76-100`). The only role redirects in the app act for owners, from `/` or unknown `/admin/*` paths (`src/App.tsx:91-96`).

The role is detected correctly (`src/lib/ownerSettingsAuthorization.ts:65-67`). Only the URL is wrong.

This is the same URL-outlives-session family as B4 / #236, but it exposes a second, independent gap that B4's sign-out reset alone does not close: there is no post-authentication landing policy at all, and the gate masks the stale path until it clears.

## 3. Sequencing

Decision D-L1 (recommended): ship as its own small PR, "PR L", which Closes the new issue, sequenced first in Wave 3, before PR 3a and PR 3b, and independent of PR 3a.

Reasons:

1. It is a live production defect for real students and becomes more frequent once PR D flags every new student, so it should not wait behind PR E's five prerequisites (#229, 3a, 3b, 1b, PR D).
2. Folding it into PR E would put a routing fix in a gate-internals PR that does not otherwise touch `App.tsx` route effects, and would delay it longest.
3. PR 3b is larger, needs an owner copy confirmation (the ES expiry notice, parent D-7) and design D3, so folding would hold this fix hostage to that.
4. PR L introduces the shared `roleHome` helper that PR 3b's role-home defense and D7 can reuse, so 3b gets smaller. PR L touches `AuthGate` and `AuthenticatedApp` landing code but not `AuthContext`, `signOut`, the signed-out branch, or the steady-state owner effects that 3b rewrites, which minimizes conflicting hunks.

Revision 1 does not change the packaging analysis; the shared exemption predicate and `roleHomeFor` make PR 3b's reuse more direct.

Alternative, if PR 3b is already in flight when this plan is approved: fold PR L's scope into PR 3b as an added work item with the same tests and close both issues there. Rejected: folding into PR E.

Relationships:

- PR 3a (B3 #235, `invalid_credentials` mapping, `AuthContext` only): independent of PR L. No shared hunks.
- PR 3b (B4 #236: `AuthGate` signed-out replace to `/`, explicit sign-out marker and `signedOutReason` in `AuthContext`, expiry notice, role-home defense in depth, #150 canonicalization; design D3, D7; invariants 3 to 6): PR 3b rebases onto PR L and reuses `roleHomeFor`. Parent invariant 4 reads "A role-invalid post-login state goes to the role home, with no returnTo." This defect is a concrete violation of invariant 4 on two transitions that PR 3b's design does not enumerate: the gate-cleared transition, and a sign-in that starts on a role-invalid path without a preceding in-app sign-out (cross-tab, bookmark). PR 3b journey J6 keeps "a student loading `/admin/students` sees the permission-denied card". That remains correct for a deliberate steady-state load and is not changed here.
- PR D (`lizbeth-spanish-password-flow-and-followups.md`: server-side first-sign-in requirement, D0 requirement table, re-issue reorder): flags every new student, so every first sign-in passes through the gate. This increases exposure of this defect and is the main reason PR L goes first.
- PR E (#243, gate client, Option B per D-P2: session-based password change then `refreshSession()`, which emits `TOKEN_REFRESHED` rather than `SIGNED_IN`; starts after #229, 3a, 3b, 1b, and PR D): PR E must keep U3's Option B variant green. The gate-cleared landing keys on the gate transition, not the auth event type, so it covers both options.

## 4. Decisions for the user

- D-L1, packaging: own PR first in Wave 3 (recommended) vs fold into PR 3b (#236) vs fold into PR E (#243, rejected).
- D-L2: resolved: filed as #259 (https://github.com/lebobo88/lizbeth-spanish/issues/259) with the text in section 14, so PR L can say `Closes #259`.
- D-L3: an owner signing in always lands on `/admin/dashboard`, even from a valid admin deep link (recommended yes, consistent with parent D-7; a returnTo would be a separate future decision).

Required approvals: explicit user approval of this plan before engineering; a separate approval for any hosted deploy.

Safe assumptions: student home is `/roadmap`; owner home is `/admin/dashboard`; the fix applies to all sign-ins and password changes, not only re-issue flows; no returnTo.

## 5. Scope and non-goals

In scope:

1. File a GitHub issue (text in section 14; filing is the orchestrator's action after approval).
2. A post-authentication role-home landing policy in the client (`App.tsx` plus one small pure helper module).
3. RED unit tests and RED e2e journeys at 1440 and 390.
4. Correcting the weak post-gate assertion in the existing e2e.

Non-goals:

- The sign-out/expiry URL reset, the expiry notice, the explicit sign-out marker and `signedOutReason` (all PR 3b / #236, design D3).
- Steady-state canonicalization of student `/`, `/roadmap/`, and unknown paths (#150, D7, PR 3b).
- Inverting issue-132's `/` assertion (PR 3b).
- Any change to `ForcedPasswordChangeGate` internals, copy, the Option A/B password flow, the Edge function, or a migration (PR D / PR E, #243).
- returnTo or deep-link restoration (explicitly rejected, parent D-7).
- Any server, database, or hosted change.
- No new copy, no new component, no visual change. No migration of any kind; no data touched.

## 6. Repository findings: runtime path

All Observed unless marked.

1. Owner re-issue. The owner is on `/admin/students/<studentId>` (the detail route; `AdminStudentsPage.tsx:347` and `:402` navigate there). "Re-issue access" calls Edge `handleReissueAccess` (`supabase/functions/admin-student-operations/index.ts:1540-1599`). It generates a temp password and makes one admin `updateUserById` with the password plus `app_metadata {...current, force_password_change: true}` (`:1568-1578`). `app_metadata` is spread, so no role claim is added or changed. The UI only reveals and copies the temp password (`AdminStudentModals.tsx:631-642`, `navigator.clipboard` of `tempPassword` only). No URL or link is generated anywhere (grep of `redirectTo`, `emailRedirectTo`, `location.origin` in `src` and `supabase/functions`: no product hits).
2. Owner signs out. `AuthContext.signOut` (`src/context/AuthContext.tsx:168-173`) calls `client.auth.signOut()`, `setSession(null)`, `setError(null)`. No navigation. The URL stays `/admin/students/<studentId>`.
3. Signed-out render. `AuthGate` (`src/App.tsx:715-816`) renders `LoginForm` in place when `!session` (`:793-809`) with no URL change and no returnTo logic. `LoginForm.tsx` contains no navigate, history, or location calls.
4. Student signs in with the temp password. `AuthContext.signIn` (`:147-166`) calls `signInWithPassword` then `setSession`. No navigation. `AuthGate` renders `AuthenticatedApp` (`:811-815`). The path is still `/admin/students/<studentId>` (`useRoute` reads `window.location.pathname`, `src/hooks/useRoute.ts:310-330`).
5. Gate. `AuthenticatedApp` (`App.tsx:72-163`) computes `needsPasswordChange = shouldForcePasswordChange(session.user)` (`:88`; `src/lib/forcedPasswordChangeAuthorization.ts:34-36`) and, when true, returns only the gate (`:98-104`). The gate branch ignores the path entirely, so the stale `/admin/*` URL is invisible to the student while the gate shows. Role effects at `:91-96` act only for owners (`/` to `/admin/dashboard`; unknown `/admin/*` to the dashboard).
6. Password change. `ForcedPasswordChangeGate.handleSubmit` (`src/components/ForcedPasswordChangeGate.tsx:133-221`) calls `setNewPasswordAndClearRequirement` (Edge `handleClearPasswordChange`, `index.ts:1663-1760`: one admin `updateUserById` with the password and `force_password_change` false, `:1730-1741`), shows "Password updated." for 1000 ms (`:173-177`), then `reestablishSession` (`:83-99`) signs in again with `signInWithPassword` (same user id), which fires `onAuthStateChange` and then `setSession` (`AuthContext.tsx:123-128`). The gate has no navigation (no navigate, history, or location in the file).
7. Post-change render. `needsPasswordChange` is now false, so `AuthenticatedApp` renders the normal shell for the unchanged path. `isAdminRoute` is true (`App.tsx:115-120`) and owner is false, so `main` renders `<AdminShell>` (`:617-622`). For a non-owner, `AdminShell` returns the permission-denied card with `role="alert"` and the text "You do not have permission to view this owner area. This area is limited to the course owner." (`src/components/AdminShell.tsx:42`, `:76-100`).

## 7. Repository findings: where `/admin/*` comes from

Candidate disposition:

- (a) CONFIRMED primary mechanism (Observed by code trace): the browser URL retained from the owner's prior session in the same tab. This is the same URL-outlives-session root cause as B4 / #236, but this report exposes a second, independent gap that B4's sign-out reset alone does not close: there is no post-authentication landing policy at all, and the gate masks the stale path until it clears.
- (b) RULED OUT: no returnTo, redirect, or stored-path value exists (grep: no `returnTo` or `redirectTo` in `src`; parent plan 5.4 confirms).
- (c) RULED OUT: neither the gate nor `AuthContext` calls navigate, reload, or history; the session update re-renders the existing path.
- (d) RULED OUT: role is not misdetected. `isOwnerUser` checks `app_metadata.role === 'owner'` (`src/lib/ownerSettingsAuthorization.ts:65-67`). Re-issue and clear both spread existing `app_metadata` (`index.ts:1568-1572`, `:1730-1733`) and never add a role. The student seeing the permission-denied card (rather than admin content) is itself evidence the role was correctly resolved as non-owner. Only the URL is wrong.
- (e) RULED OUT: no explicit admin redirect in the gate success handler or `LoginForm`.
- (f) ADDITIONAL VECTORS (Inference, medium; to be confirmed by RED e2e):
  - (f1) Cross-tab session swap. `supabase-js` ^2.110.7 (`package.json:37`) persists the session in shared localStorage and syncs auth state across same-origin tabs, so an owner tab sitting on `/admin/*` adopts the student's session when the student signs in in another tab, then shows the gate and, after the change, the permission-denied card. Separate browser contexts cannot test this because they do not share storage; L5 uses one context with two pages. Session persistence is on (`persistSession` true and `autoRefreshToken` true, `src/services/supabase.ts:170-175`), so a second page in the same context restores the owner session.
  - (f2) A bookmarked or shared `/admin/*` URL loaded in a fresh tab and signed into by a student (same render path, no landing policy).

Fresh tab versus prior owner session (distinguished by evidence): a fresh tab opened at `/` does NOT reproduce by code. The student signs in at `/`, the gate clears at `/`, and `/` falls through to `RoadmapPage` (`App.tsx:623-625`). The existing e2e journey that exercises exactly this (fresh `/` sign-in) reaches the app shell (`browser-validation-status-clarity-and-gate.spec.ts:206-272`). Therefore the reported behavior requires the tab's URL to already be `/admin/*` at sign-in: the same tab the owner used (most likely the owner testing the flow, or a shared family or classroom device), a cross-tab owner session (f1), or an `/admin/*` bookmark or link (f2). Report to the user that a fresh tab at the site root lands correctly today; the fix nevertheless makes every case deterministic. Inference: the user observed it while testing as owner in one browser.

Same root cause without the gate (Observed): on `main`, newly registered or create-and-assign students are NOT flagged (`createUser` at `index.ts:320` and `onboarding.ts:369` set no `force_password_change`), so a first-login student signing in in the owner's tab lands directly on the permission-denied card with no gate. After PR D (password-flow plan) flags every new student, every first sign-in passes through the gate, which increases exposure of this defect.

Owner's own forced change: the gate and `needsPasswordChange` are role-agnostic (`App.tsx:88-104`), so a flagged owner would hit the same landing gap. The owner flag is not settable through the UI (the roster targets students); Inference. Covered by the generic policy and a unit test; no e2e (the seeded owner must not be mutated).

Student home on `main` (Observed): the student nav "Roadmap" button navigates to `/roadmap` (`App.tsx:499`); `ContextStatusStrip` renders only at `path === '/roadmap'` (`ContextStatusStrip.tsx:99` per the parent plan); `/` renders the same `RoadmapPage` only as a fall-through. Parent design D7 makes `/roadmap` canonical. Student role home is `/roadmap`. Owner role home is `/admin/dashboard` (`App.tsx:92`, `:95`; `useRoute.ts:105-107`).

Router facts (Observed), `useRoute.ts`: `navigate` (`:58-81`, guarded); `replaceNavigate` (`:98-103`, sets `lastNavigationWasReplace`, never guarded, a no-op when the path is equal); `wasLastNavigationReplace` (`:29-32`). The route-change focus effect (`App.tsx:302-342`) skips focus on initial mount and on replace navigations (`:338`), so a replace landing preserves "skip link is first Tab stop".

## 8. Why existing tests missed it

All Observed.

- `browser-validation-status-clarity-and-gate.spec.ts`: its `signIn` helper (`:51-63`) always does `page.goto('/')` before filling the form. After the owner re-issues on `/admin/students/<id>` (`:164-195`) and signs out (`:197-204`), the student sign-in at `:206` starts from `/`, so the stale-URL path is never exercised. The post-gate assertion (`:270-272`) is a loose `.first()` union locator (h1 "Field Workbook", `.roadmap-page`, h2 "Beginner") with no pathname assertion and no assertion that the permission-denied card is absent.
- `App.test.tsx` gate tests (`:482-545`) all start at `/` (`:482`) and assert only gate presence or absence, never the resulting pathname.
- `ForcedPasswordChangeGate.test.tsx` and `wp9-forcedPasswordChangeGateStates.test.tsx` render the gate in isolation, outside App routing.
- No test anywhere asserts the URL after a cross-role sign-in (parent plan 5.4: "No existing test asserts the URL after sign-out or a cross-role re-login").

Research evidence: none. Research is not needed. The defect is fully explained by local source. The one external-behavior inference (cross-tab auth sync, f1) is verified directly by RED e2e journey L5 rather than by web research.

## 9. Ordered work

Owner: engineering fleet, standard T1 route; one writer; PRs only against `main`, never push to `main`.

### Step 0: preflight

- Confirm the `main` SHA (`ac78158` or later). If `App.tsx` `:72-163` or `:715-816`, `AuthContext.tsx`, `ForcedPasswordChangeGate.tsx`, or `useRoute.ts` changed materially (for example PR 3a or 3b merged first), return Plan stale.
- Record vitest and e2e baselines (known baseline list in the parent plan 11.3).
- Inventory e2e sign-in helpers that fill the login form at a non-root URL: `rg -n "Open my journal" src/__tests__/e2e`, and inspect each helper's preceding `goto`. List any spec that expects to stay on a deep path after a fresh sign-in. Those expectations change by design: post-sign-in always lands on role home.

### Step 1: RED unit and integration tests

Vitest, mocked auth like `App.test.tsx`. Tests fall into two labeled groups (J-005).

**Reproduction tests** must FAIL on `main` `ac78158` and then PASS after the fix; record both runs: U2, U3 (both the `SIGNED_IN` and `TOKEN_REFRESHED` variants), U4, U5, U7, U9, and e2e L1, L3, L4, L6, plus L5 if page A receives the change, and the existing-spec `toHaveURL(/\/roadmap$/)` assertion (an intended behavior change, not the defect itself, consistent with L2).

**Preservation tests** must PASS on `main` AND after the fix: U6, U8, U10, U11, e2e L2, and the existing-spec permission-card-absent and `RoadmapPage` visibility assertions. U1 is new code, so it is a unit spec for the helper with no `main` run.

- U1, `roleHome` helper (`roleHomeFor(user: User)` takes a non-null session user only): student user returns `/roadmap`; owner (`app_metadata.role` `'owner'`) returns `/admin/dashboard`; a user with `app_metadata` null or a missing role returns `/roadmap`. Also unit-test `isPostAuthLandingExempt` against the U10 and U11 inputs.
- U2, sign-in transition with a stale admin path: history at `/admin/students/<id>`, `AuthGate` signed out, then a student session arrives (`signIn` success or `onAuthStateChange` `SIGNED_IN`). Expect pathname `/roadmap`, `RoadmapPage` rendered, and no `.permission-denied-card` or `admin-shell-permission-denied` alert ever inserted into the DOM during the transition (a MutationObserver record over the whole sequence).
- U3, gate-cleared transition: start at `/admin/students/<id>` with a flagged student session (restored session, so no sign-in landing), gate renders; deliver a session with `force_password_change` false for the SAME user id. Expect pathname `/roadmap` and no permission-denied card inserted at any commit. Run U3 twice: once delivering the update as `SIGNED_IN` (current Option A re-sign-in) and once as `TOKEN_REFRESHED` / `refreshSession` (PR E Option B), proving the policy keys on the gate transition, not the auth event type.
- U4, owner forced change: flagged owner at `/roadmap`; after clear, `/admin/dashboard`.
- U5, owner sign-in from a student path (`/roadmap/enr-1/week/2`) lands on `/admin/dashboard`.
- U6, non-regressions:
  - a restored session (initial load, no transition) at `/admin/students` as owner is NOT replaced;
  - a restored student at `/roadmap/enr-1/week/2` is NOT replaced;
  - a restored student at `/admin/students` still shows the permission-denied card (PR 3b J6 behavior preserved);
  - public `/courses` and `/courses/:id` are untouched while signed out;
  - landing uses `replaceNavigate` (history length unchanged; `wasLastNavigationReplace()` true) and does not move focus (skip link remains the first Tab stop; route-change focus effect not triggered);
  - a same-user `TOKEN_REFRESHED` with no gate transition does not navigate;
  - no loop (replace is a no-op when already at role home).
- U7, cross-identity swap while signed in: user A owner at `/admin/students`, session changes to user B student without passing through null; expect `/roadmap`.
- U8, restore baseline (preservation, J-003): an owner restored at `/admin/students/<id>` after a forced initial session failure (the `window.__E2E_FORCE_SESSION_ERROR__` seam at `AuthContext.tsx:84-86`, or a rejected `getSession` mock) and then Retry keeps the path `/admin/students/<id>`; the same for a student at `/roadmap/enr-1/week/2`.
- U9, re-login of the same user (reproduction, J-002): student A signs in (lands `/roadmap`), navigates to `/learn`, signs out (on `main` the URL stays `/learn`), and A signs in again, landing `/roadmap`. The same with a stale `/admin/students` path left in the URL by a direct `pushState` before the re-login: expect `/roadmap` and no permission card.
- U10, public paths (preservation, J-001): a cross-tab identity change delivered via `onAuthStateChange` while on `/courses` and on `/courses/course-1` does not navigate, and the catalog stays rendered.
- U11, auth-token URLs (preservation, J-001): each token form (`#access_token=...`, `#type=recovery`, `#type=invite`, `?code=x`, `?error=x&error_description=y`) loaded at first render and followed by a sign-in transition does not replace the URL. U11 is evaluated against the first-render snapshot.

### Step 2: implementation (minimal, client-only)

- Add `src/lib/roleHome.ts` (pure and dependency-free, like `ownerSettingsAuthorization.ts`). Export `roleHomeFor(user: User): '/roadmap' | '/admin/dashboard'`, which takes a non-null session user only: `/admin/dashboard` when `isOwnerUser(user)`, otherwise `/roadmap`. Callers invoke it only when a session exists. Also export `isPostAuthLandingExempt(pathname, firstRenderSearch, firstRenderHash)` (pure, see Exemptions). PR 3b should reuse both for its role-home defense and D7.
- Sign-in landing (identity transition). In `AuthGate` (which stays mounted across sign-in), keep a ref `observedUserId: string | null | undefined` (undefined means no baseline yet).
  - Restore baseline: whenever `AuthContext` `loading` is true, and on the first commit where `loading` becomes false (the initial `getSession()` resolution, and again after every `retrySession()` bump, because retry sets `loading` true at `AuthContext.tsx:101` and resolves through the same `getSession` at `:106-113`), set `observedUserId` to the current session's user id or null, with NO landing. A failed load (`sessionError`, `:114-121`) leaves the baseline undefined until Retry resolves; the Retry resolution is a restore, never a sign-in. A page reload is a restore. A same-user `TOKEN_REFRESHED` or `USER_UPDATED` is not an identity change.
  - After a baseline exists: a session becoming null (in-app sign-out, expiry, cross-tab sign-out) sets `observedUserId` to null. A non-null session whose user id differs from `observedUserId` (null to A, including A to null to A re-login of the same user, or A to B) is a sign-in transition. It lands on `roleHomeFor(user)`, subject to the exemptions below, and then sets `observedUserId` to that id.
  - Landing mechanics: call `replaceNavigate(roleHomeFor(user))` before `AuthenticatedApp` renders the stale path. During that one pending commit, render the existing loading status (`signInCopy.loading`) or no page content, never the stale route. Do not change `AuthContext`'s public value (keeps PR 3a and 3b `AuthContext` hunks conflict-free).
- Exemptions (J-001). The identity-change landing never fires when (1) the path is public (`/courses` or `matchPublicCourseRoute`, `useRoute.ts:115`; `AuthGate` returns `PublicCatalogPage` for `/courses` and `/courses/:id` before any session check, `App.tsx:730-732`, and `replaceNavigate` at `useRoute.ts:98-103` has no exemptions of its own), or (2) the URL carried auth-token parameters at first render: hash `access_token`, `refresh_token`, or `type=recovery|invite|signup`; query `code`, `error`, or `error_description`. Capture the first-render URL once in a module-level or ref snapshot so later `replaceState` calls do not change the decision. The exemption list must be identical to parent invariant 3 so PR 3b can share it, and the predicate lives in `src/lib/roleHome.ts` as `isPostAuthLandingExempt(pathname, firstRenderSearch, firstRenderHash)`. Observed: `getSupabaseClient` sets `detectSessionInUrl: false` (`src/services/supabase.ts:170-175`), so the client does not consume token URLs today; the exemption is kept for parity with parent invariant 3 and PR 3b. The gate-cleared landing is not exempted, because a gated user is never on a public page (`AuthGate` renders the catalog before the gate).
- Gate-cleared landing. In `AuthenticatedApp`, detect `needsPasswordChange` going true to false within the mounted component (a ref holding the previous value; also correct after a reload while gated, since the reload mounts with true). On that transition, call `replaceNavigate(roleHomeFor(user))` and do not render the stale path's page for that commit (same pending treatment). This is independent of the auth event type, so it works for current Option A (`signInWithPassword`, `SIGNED_IN`, same user id) and PR E's Option B (`refreshSession`, `TOKEN_REFRESHED`).
- Do not alter the gate component, `LoginForm`, `AuthContext.signOut`, the signed-out branch, or the existing owner effects at `App.tsx:91-96` (PR 3b owns those). Add a short code comment citing the issue number and parent invariant 4.

### Step 3: RED e2e

Playwright, new spec `src/__tests__/e2e/issue259-post-auth-landing.spec.ts`, plus correction of the existing spec. Each journey runs at 1440x900 and 390x844 (L5 at 1440x900 only), with a `page.on('dialog')` listener that fails the test, and uses disposable students only.

- L1, same tab, owner re-issue then student change. The owner signs in, opens the disposable student's detail `/admin/students/<id>`, re-issues access (reads the temp password), and signs out via the app. WITHOUT any `page.goto`, the student signs in on the current URL with the temp password. Assert the URL is `/roadmap` immediately after sign-in (before the gate) and the gate shows. Set a new password. Assert URL `/roadmap`, `RoadmapPage` and `.context-strip` visible, and `.permission-denied-card` count 0 at every checkpoint.
- L2, fresh tab (preservation). New browser context, `goto('/')`, sign in as a re-issued disposable student, complete the gate. A fresh tab at `/` lands correctly on `main` by code trace, so on `main` L2 asserts "no permission card and `RoadmapPage` visible". After the fix the URL becomes `/roadmap` instead of `/`, so L2 additionally asserts "URL `/roadmap`" only after the fix.
- L3, tab that last showed `/admin/*` without an in-app sign-out. Owner context on `/admin/students/<id>`; clear storage via `context.clearCookies` plus a localStorage clear in that page (simulating expiry or a different-user handoff) and reload so the sign-in card renders on `/admin/students/<id>`. The student signs in there and lands on `/roadmap`; complete the gate and stay on `/roadmap`. After PR 3b merges, 3b replaces the signed-out URL with `/`; this journey must then still pass, landing on `/roadmap`.
- L4, first-login student created by the owner. The owner creates a disposable student via the Register / Create-and-assign modal on `/admin/students`, signs out, and the student signs in in the same tab, landing on `/roadmap`. On `main` the student is unflagged, so no gate appears; after PR D the gate appears and the same assertions apply after completing it. Write the journey to handle both by completing the gate if it appears.
- L5, cross-tab (same browser context, two pages; verifies Inference f1; 1440 only). Page A: the owner signs in, opens `/admin/students/<id>`, and re-issues access for a disposable student. Page B (same context, so it restores the owner session from shared localStorage): sign out via the app in page B, which also signs page A out through shared storage (record what A shows; on `main` A keeps `/admin/students/<id>`). In page B, sign in as the student with the temporary password. Assert page A (without any `goto` or reload) either shows the gate over `/roadmap` or the sign-in card, and never the permission card. Complete the gate in page B; assert page B ends on `/roadmap` and page A, once it reflects the student session, is on `/roadmap`. If page A does not receive the session change without a reload, record that as the observed behavior, change the f1 label from Inference to Observed-not-reproducible, and reword the issue #259 "cross-tab" sentence accordingly in a follow-up comment (orchestrator action); the fix is still covered by U7 (identity swap A to B) at the unit level.
- L6, owner sign-in from a stale student path. In a tab last on `/roadmap` (student signed out, URL kept on `main`), the owner signs in and lands on `/admin/dashboard`.
- Existing spec correction, `browser-validation-status-clarity-and-gate.spec.ts` journey 3/4/6/7: after the gate clears (`:264-272`), add two assertions that belong to different groups. (1) Preservation group (passes on `main` and after the fix): `expect(page.locator('.permission-denied-card')).toHaveCount(0)` plus the `RoadmapPage` visibility check. (2) Reproduction group (fails on `main` because a fresh `/` sign-in stays at `/` via the fall-through at `App.tsx:623-625`, passes after the fix): `expect(page).toHaveURL(/\/roadmap$/)`. This URL assertion is a behavior change, not the defect itself, consistent with L2. Keep the helper's `goto('/')` for that journey (L1 covers the no-goto path). Never weaken existing assertions.

### Step 4: GREEN

Implement until all RED tests pass. Run the full vitest and full e2e suites versus baseline, plus type-check, lint, and `verify:build`.

### Step 5: PR

Branch from `main` and open a PR against `main` with "Closes #259" and "Refs #236, #243". The body states the root cause, the RED-then-GREEN evidence, and the sequencing note for PR 3b (reuse `roleHomeFor`; keep J6). No merge and no deploy without separate approval (a Netlify deploy of the merged client is a hosted action needing its own approval).

### Step 6: parent plan touch-up

Scribe, after approval, as a separate small doc edit: note in the deep-dive plan's PR 3b section that PR L landed the `roleHome` helper and the transition landing, so 3b reuses rather than re-implements; note in the password-flow plan's PR E section that PR E must keep U3's Option B variant green.

## 10. Interfaces and data

New pure module `src/lib/roleHome.ts` (`roleHomeFor(user): '/roadmap' | '/admin/dashboard'`). No change to `AuthContext`'s public type, `useRoute` exports, the gate, Edge functions, SQL, migrations, or storage. No data is read or written; no migration, so production student data is untouched (consistent with the standing constraint that production is live). Compatible with PR 3b (which adds a signed-out reset and marker; both policies converge on role home) and PR E (Option B `refreshSession` is handled by the gate-transition trigger).

## 11. Acceptance, validation, risks

### 11.1 Acceptance and validation

- RED evidence: the reproduction tests (U2, U3 both variants, U4, U5, U7, U9, e2e L1, L3, L4, L6, the existing-spec URL assertion, and L5 if page A receives the change) shown failing on `main` ac78158 (record output), then passing. The preservation tests (U1, U6, U8, U10, U11, e2e L2, and the existing-spec permission-card-absent and `RoadmapPage` visibility assertions) pass on `main` and after the fix (U1 has no `main` run).
- `npm ci`; `npm run type-check`; `npm run lint` (0 errors); `npm run verify:build`; full `npx vitest run` on a freshly reset local stack with no new failures versus the recorded baseline; full Playwright suite versus baseline; targeted specs green 3 of 3 runs at both viewports.
- No-native-dialog scan: `rg -n "\b(window\.)?(alert|confirm|prompt)\s*\(|beforeunload" src --glob "!src/__tests__/**"` returns zero product hits; every new or changed spec has a failing `page.on('dialog')` listener.
- Focus: after each landing, `document.activeElement` is body or the skip link is the first Tab stop (no focus theft), matching the owner `/` landing precedent; the gate's own heading focus on mount is unchanged.
- Verifier PASS, then Browser Validator PASS; CODE_REVIEW per the judge route.
- Fixture integrity: PRE and POST fingerprints of seeded accounts (owner@test.local, student1, student2, fullaccess credentials and flags) unchanged; all disposable accounts deleted in `afterAll` (`deleteDisposableAccount`) with the `globalTeardown` sweep.

### 11.2 Invariants and risks

Invariants:

- The identity-change landing is exempt on public paths and auth-token URLs, using the parent invariant 3 list.
- A restore (initial load, page reload, Retry after a failed load) is never a sign-in transition and never lands.
- Landing uses `replaceNavigate`, never moves focus, and never renders the stale route for the pending commit.

Risks:

- R1: a legitimate post-sign-in deep link is lost (owner signs in from a bookmarked `/admin/students`). Accepted by design, consistent with parent D-7 "no returnTo" and PR 3b's signed-out reset. Mitigation: documented in the PR body.
- R2: landing fires on a restored session or token refresh, which would break hard reload of deep pages (PR 3b J4). Prevented by keying on identity change after initial load and on the gate transition only; U6 guards it.
- R3: a one-frame flash or screen-reader announcement of the permission-denied `role="alert"` during landing. Prevented by the pending-commit rule; U2 and U3 MutationObserver assertions guard it.
- R4: e2e helpers that sign in at deep URLs change behavior. Step 0 inventory; update expectations deliberately, never weaken.
- R5: conflict with PR 3b or PR E. PR L avoids `AuthContext`, `signOut`, the signed-out branch, and the owner effects; 3b rebases and reuses `roleHomeFor`. If 3b is already in flight, use the fold-in alternative (D-L1).
- R6: cross-tab inference (f1) is wrong. L5 records actual behavior; if tabs do not sync, L5 asserts the stale tab is unaffected until reload and the landing still holds on the next transition.
- R7: baseline misclassification (restore or Retry treated as sign-in) would bounce deep-link reloads. Guarded by the restore rule and U8.
- R8: ejecting a public-catalog visitor or erasing an auth callback. Guarded by the exemptions and U10/U11.

### 11.3 Rollback

Revert the PR (client-only; no data, no migration). Hosted: the Netlify deploy of the reverted client restores prior behavior; deploys need separate approval.

## 12. Design route and browser UI policy

Design route: none. Reason: no new or changed copy, no new component or state, no visual change, and focus behavior is preserved (the landing uses the existing replace-redirect rule at `App.tsx:338`, identical to the owner's existing `/` to `/admin/dashboard` landing). The visible outcome is an existing page (`RoadmapPage` or the owner dashboard). The only transient render during a landing reuses the existing `AuthGate` loading status (`signInCopy.loading`, `App.tsx:734-745`) or renders no page content; no new string. If engineering finds it must add any visible copy or change focus, the job returns Plan stale and a compact design route is run. Design handoff: none. Design review: none.

Browser UI dialog policy: required. No `alert`, `confirm`, `prompt`, their `window.*` forms, or `beforeunload` prompts. This change adds no modal or confirmation. Any future confirmation uses the app-owned accessible Modal (`src/components/Modal.tsx`) with Escape/Close and focus return, and validation stays inline. Verification: the deterministic `rg` scan in section 11.1 with zero product hits; a failing `page.on('dialog')` listener in every new and changed spec; the existing gate keyboard checks (Tab order new to confirm password, focus to the confirm field on mismatch) re-run unchanged.

### 12.1 Browser UI validation brief

- Launch and readiness: port-shifted mirror `H:\CommandCenter\orchestrator\lizbeth_spanish-218e-run`, API 64321, DB 64322; per-file copies of the PR worktree into the mirror, never `robocopy /MIR`; new Edge files would need a full `supabase stop`/`start`, but this PR has none. Run `npx supabase start`; `npx supabase db reset`; `docker restart supabase_kong_lizbeth_spanish supabase_rest_lizbeth_spanish supabase_edge_runtime_lizbeth_spanish` (the first request after reset may 502). Keep the mirror's local CSP patch and `.env.local` (VITE Supabase URL `http://127.0.0.1:64321`). Start `npx vite --host 127.0.0.1 --port <free 518x, e.g. 5183> --strictPort`. Ready when `http://127.0.0.1:<port>/` serves the sign-in card ("Open my journal" button visible).
- Base URL: `http://127.0.0.1:<port>` (`E2E_BASE_URL` set to the same).
- Fixtures and reset: `db reset` plus seed. Seeded accounts (owner@test.local / password) are used only for owner actions. Every credential-rotating journey uses disposable students from `fixture-isolation.ts` `createDisposableStudent(..., { enrollInBand: 'Beginner' })` or owner-created via the UI (L4), deleted in `afterAll`; `reassertSeededCredentials` in `beforeAll`/`afterAll`. Never re-issue, flag, or change the password of any seeded account.
- Journeys: L1 to L6, plus the corrected existing journey 3/4/6/7.
- Viewports: 1440x900 and 390x844 for every journey (L5 runs at 1440 only, because it needs two pages in one context).
- Visible outcomes: after each sign-in and each password change the address bar shows `/roadmap` (student) or `/admin/dashboard` (owner); the student sees the roadmap page with the context strip; the owner sees the dashboard; the text "You do not have permission to view this owner area" never appears in L1 to L6; no flash of the permission card in screenshots taken immediately after the gate clears; no native dialog; focus not stolen (skip link is the first Tab stop).
- Evidence: screenshots under `browser-validation-artifacts/issue259/` (before sign-in URL, gate URL, post-change URL at both viewports).

## 13. Approval gate and handoff

- This plan is DRAFT. T1 does not start until the user explicitly approves it. On approval relayed by the lead, Scribe updates this plan's status to approved before T1 is dispatched.
- Judge flow: the orchestrator may run PLAN_DUCK on this draft before approval. CODE_REVIEW findings, if run, flow into engineering and verification by finding ID. No judge finding is recorded here because none has been observed.
- Engineering mode: standard. Team authorization: not applicable. Downstream owner: engineering fleet.

### 13.1 Revision 1 disposition

All six findings were re-checked against code at `ac78158` by Planner. Codex was in shadow mode and its findings are advisory.

| Finding | Disposition |
| --- | --- |
| J-001 | Accepted: public-path and auth-token exemptions plus U10/U11 |
| J-002 | Accepted: null reset on sign-out plus U9 |
| J-003 | Accepted: restore baseline including Retry plus U8 |
| J-004 | Accepted: L5 redesigned to one context with two pages; separate contexts rejected because they share no storage |
| J-005 | Accepted: reproduction versus preservation test groups |
| J-006 | Accepted: non-null `roleHomeFor` contract |

## 14. Ready-to-file GitHub issue (filed as #259)

Filed: #259 (https://github.com/lebobo88/lizbeth-spanish/issues/259). The text below is kept as the filed record.

**Title:** After a forced password change (or any sign-in), a student can land on an /admin/* page and see "You do not have permission": no post-sign-in role-home landing

**Suggested labels:** bug, area:auth (plus severity:S2 if that label exists)

**Summary:** When a student signs in or finishes the required password change in a browser tab whose URL is still an owner page (for example `/admin/students/<id>` after the owner re-issued their access and signed out), the app keeps that URL and shows the owner-area permission-denied card instead of the student's roadmap.

**Steps to reproduce:**

1. Sign in as the owner and open a student's detail page (`/admin/students/<id>`).
2. Click "Re-issue access", confirm, and note the temporary password.
3. Sign out in the same tab (the URL stays `/admin/students/<id>`).
4. Sign in as that student with the temporary password; the "Choose a new password" screen appears.
5. Set a new password.

**Expected:** the student lands on `/roadmap`, the same page any student sees after signing in. An owner lands on `/admin/dashboard`. A page the role cannot use is never kept after sign-in or a password change.

**Actual:** after "Password updated.", the URL is still `/admin/students/<id>` and the page shows "You do not have permission to view this owner area. This area is limited to the course owner." The same happens without the password screen for a new student signing in on that tab, and (inference, to be confirmed) when a student signs in in another tab while an owner tab is open on an `/admin/*` page. A fresh tab opened at the site root lands correctly.

**Root cause:** the app has no post-authentication landing step. The route is `window.location.pathname` (`src/hooks/useRoute.ts:310-330`), which survives sign-out (`src/context/AuthContext.tsx:168-173`) and sign-in (`:147-166`); `AuthGate` renders the sign-in form in place without changing the URL (`src/App.tsx:793-809`). The forced-password gate renders regardless of path (`src/App.tsx:98-104`), hiding the stale URL; when the change succeeds (`src/components/ForcedPasswordChangeGate.tsx:173-198`) the session updates and App renders the unchanged `/admin/*` path, which for a non-owner is the `AdminShell` permission-denied card (`src/components/AdminShell.tsx:76-100`). The only role redirects act for owners from `/` or unknown `/admin` paths (`src/App.tsx:91-96`). The student's role is detected correctly (`src/lib/ownerSettingsAuthorization.ts:65-67`); only the URL is wrong. Tests missed it because the e2e sign-in helper always opens `/` first (`src/__tests__/e2e/browser-validation-status-clarity-and-gate.spec.ts:51-63`) and its post-gate check never asserts the URL (`:270-272`).

**Impact:** real students handed a re-issued password on a shared device or in the owner's browser see an error after successfully changing their password; exposure grows once every new student must change their password at first sign-in (#243 PR D).

**Proposed fix:** on every sign-in that changes the signed-in user and on every forced-password-gate clear, replace the URL with the role home (students `/roadmap`, owners `/admin/dashboard`) before rendering, with no returnTo, no focus theft, and no flash of the permission card. Restored sessions and token refreshes are unaffected. Related: #236 (sign-out keeps the deep link), #150, #243.

**Acceptance:** RED unit tests for both transitions (including the Option B refresh path) and e2e journeys at 1440 and 390: owner re-issue then student change in the same tab and in a fresh tab, a tab left on `/admin/*`, a first-login owner-created student, and cross-tab; zero permission-card renders; zero native dialogs.
