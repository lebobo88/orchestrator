# Plan: Lizbeth Spanish password flow and follow-ups (October 2026)

- Plan id: `lizbeth-spanish-password-flow-and-followups`
- Task id: `lizbeth-auth-password-and-followups-2026-10`
- Status: **APPROVED 2026-10-13.** The user stated, verbatim, on 2026-10-13: "H:\CommandCenter\orchestrator\docs\plans\lizbeth-spanish-password-flow-and-followups.md is approved." Decisions D-P1 to D-P12 are adopted at their recommendations. Hosted actions (Edge deploy, migration apply, the Ops F backfill write, Netlify deploy) still each need separate explicit approval. Earlier owner words, 2026-10-12: "Continue as planned. I'll review everything later on regarding policy and final approval before completed pr merge."
- Route: engineering. Engineering mode: standard (T1 first-line; two counted T1 gate failures escalate to T2; two counted T2 gate failures block for user review). No extreme-advisory team. Team authorization: not applicable.
- Target: `lebobo88/lizbeth-spanish` (private). Local clone `H:\CommandCenter\orchestrator\lizbeth_spanish`.
- Relationship to the parent plan: addendum to the approved `docs/plans/lizbeth-spanish-open-issues-deep-dive-2026-10.md`. It sequences against that plan's Waves 1 to 3 (PR 1b, Wave 3 PR 3a = B3 #235 `invalid_credentials` mapping, PR 3b = B4 #236 sign-out landing plus #150). It does not duplicate #235 or #236.
- Evidence base: read-only checkout `H:\CommandCenter\orchestrator\lizbeth_spanish-main-88b` at `origin/main` `88b43fd37f04af90860fc93b5f3c8e4d696a48f9` (taken from the local `FETCH_HEAD`; the Planner could not re-fetch, so Step 0 must fetch and record the current SHA). Every `file:line` in this plan refers to `88b43fd` unless a PR worktree is named.
- Open-PR worktrees (reference only):
  - `lizbeth_spanish-224` = PR #229 (bilingual sign-in: `AuthContext`, `LoginForm`, `signInCopy.ts`)
  - `lizbeth_spanish-140` = PR #230
  - `lizbeth_spanish-228` = PR #231 (create-and-assign, stacked on #230; `supabase/functions/admin-student-operations/onboarding.ts`, `RegisterStudentModal`, `OnboardingOutcome`)
  - `lizbeth_spanish-227` = PR #232
- Wave 2 branches exist on origin: `test/218-require-backup-env`, `test/218-stale-e2e-201`, `test/218-isolation-81-137-48`, `test/218-self-provision-fixtures`, `test/82-fixture-date-reanchor`; B1 branches `fix/233-republish-current-version` and `fix/53-publishing-state-machine`. Their merge state is Unknown to the Planner; Step 0 checks it.

**Revision 1 (PLAN_DUCK J-001 to J-003 applied; Codex shadow verdict REVISE).** One revision, applied in place. Status stays DRAFT; no approval is recorded. The owner's latest words, verbatim: "Continue as planned. I'll review everything later on regarding policy and final approval before completed pr merge." The design was re-reviewed on design revision 2 and the delta review returned PASS (round 3, section 6.8).

- J-001 (critical/high, owner can clear `force_password_change` without a password change, so a student keeps a temporary password): `toggle-password-change` becomes one-way; `force_change:false` returns 422 `clear_not_permitted`; the owner control is removed. Touches sections 3, 4.1, 6.2 (G13), 6.3 (invariant 12), 6.6 (J10), 8 (D4a, D6, D7, RED (ix)), 12.2, 13 (R1), 15.1 (D-P12).
- J-002 (critical/high, read-modify-write of `app_metadata` lets a stale student clear overwrite a concurrent owner re-issue): new D0 requirement table with version plus `require_password_change` and `clear_password_change` functions; re-issue reordered; Edge returns 409 `requirement_changed` on a version mismatch. Touches sections 3, 4.1, 6.2 (G2), 6.3 (invariant 7), 6.5, 6.6 (J13), 8 (D0, D1, D2, D3, RED (x), (xii), PR E, Ops F), 9, 13 (R1, R12, R13), 14, 15.1 (D-P7).
- J-003 (major/high, Option B lockout when the flag clear fails after the password PUT succeeds): D3 adds the digest-based idempotent `same_password` recovery, `session_ended` (401) and `flag_clear_failed` (500) handling. Touches sections 6.2 (G2), 6.5, 6.6 (J14), 8 (D3, RED (xi)), 13 (R13), 15.1 (D-P2).
- Design revision 2 changes: G13 replaced, G2 split terminals, G15 clarification (DR2-4), invariants 7 and 12, new draft copy rows, J10 extended, new J13 and J14, new fault injections and scan, review round 3.

Reading guide: sections 3, 10, 14 and 15 are what an approver needs (summary, decisions, executable now versus deferred, approvals). Sections 4 and 5 hold the evidence. Section 6 is the reviewed design handoff. Sections 7 to 9 and 11 to 13 are execution detail for the engineering fleet. Evidence is labelled Observed unless marked Inference or Unknown.

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

Audience: the repository owner (Rob), who approves the plan and answers decisions, and the downstream engineering fleet.

Requester intent, verbatim, 2026-10-12: "file a gh issue to address and implement the suggested fixes for the password flow. And let's also set it so when owner creates a new student, enrolls them, and sends a temporary password first login always should prompt them to reset the password. Proceed as planned and as outlined." Later: "Continue as planned. I'll review everything later on regarding policy and final approval before completed pr merge."

Standing direction: accomplish the goal rather than the literal proposal; root-cause diagnosis; proper implementation order; PRs only (base `main`, body "Closes #N"), never push to main, no merges, and no hosted deploy, migration or database write without separate approval.

Observable results when the plan is complete:

1. Every owner-created student (direct register and create-and-assign) is server-enforced to choose their own password at first sign-in.
2. The forced-password gate is bilingual, accessible, and never loops.
3. The #244 accessibility trigger is always clickable.
4. The #245 FeedbackForm is not dirty after a successful submit.
5. The #218 remainder is fixed with explicit closure criteria.

## 2. Scope and non-goals

In scope: #243 (C1 to C8 plus the new server-side first-sign-in requirement), #244, #245, the #218 remainder (the `fullaccess` cross-spec state dependency and intermittents), and an existing-students backfill option.

Non-goals:

- B3 `LoginForm` `invalid_credentials` mapping (#235, parent PR 3a).
- B4 sign-out landing and expiry notice (#236, parent PR 3b).
- PR 1b `.form-error` contrast (parent).
- Replanning #229 to #232.
- Any merge, push to main, hosted deploy, migration apply or hosted database write without separate approval (parent D-28).
- Final Spanish (drafts only; owner approval required).
- Generic self-service password reset (out of scope per the existing code comment at `index.ts:1656-1658`).
- Changing public sign-up settings (adjacent finding only, R9).

Limit: the Planner could not run `gh issue view` (no `gh` access in the planning chain). The C1 to C8 summaries come from the PLAN_JOB and each was re-verified against code. Step 0 requires reading the bodies of #243, #244, #245 and #218. Any acceptance criterion there that this plan does not cover is a stale-plan trigger.

## 3. Summary of findings

1. **New students are never flagged (Observed).** `handleRegisterStudent` calls `createUser({email, password: tempPassword, email_confirm: true})` with no `app_metadata`. PR #231's `createUser` passes only `{onboarding_operation_id}`. Database enforcement already exists (`user_requires_password_change()` in RLS), so setting `force_password_change: true` at creation is sufficient for server-side enforcement.
2. **The password-change "loop plus 401" is most likely client state (Inference, medium).** After the admin password update GoTrue deletes all of the user's sessions. The gate's Step 3 ignores the `signInWithPassword` error and falls back to `refreshSession()`, which cannot succeed. The app keeps a server-dead session whose JWT still says `force_password_change: true`, so resubmission sends a dead token and the Edge returns 401. The hypothesis that the server rejects the new password is refuted locally by the live test.
3. **Error reporting collapses (Observed).** `classifyError` returns one generic message for nearly everything, and the gate renders server text raw.
4. **Temp password alphabet includes look-alikes (Observed)** and gives no class coverage guarantee.
5. **The gate is English-only, mis-associates errors, duplicates messages, can clip on short viewports, and hides the accessibility trigger (Observed).**
6. **#244 has a specificity explanation (Observed) and an unproven stacking hypothesis H1 (Inference).**
7. **#245 root cause is Observed:** the success path clears only `content`, so the selections keep the sign-out guard armed.
8. **#218 remainder:** four specs depend on contradictory states of the `fullaccess` entitlement rows; the materializer is Unknown.

9. **Revision 1 (PLAN_DUCK J-001 to J-003, Observed):** the owner toggle can clear the requirement without a password change; the flag writes are racy read-modify-writes; and Option B had no recovery when the flag clear fails after the password PUT succeeds. PR D now includes a migration (D0) and a one-way owner control.

Work packages: PR A (#244), PR B (#245), PR C (#218 remainder), PR D (server-side requirement and Edge changes), PR E (gate client), Ops F (existing-students backfill).

## 4. Repository findings

### 4.1 #243 server and Edge (Observed at 88b43fd unless marked)

- `handleRegisterStudent`, `supabase/functions/admin-student-operations/index.ts:291-336`: `createUser({email, password: tempPassword, email_confirm: true})` with NO `app_metadata`, so new students are never flagged (root cause of C6 and the new requirement).
- PR #231 (`lizbeth_spanish-228`) `supabase/functions/admin-student-operations/onboarding.ts:368-374`: `createUser` `app_metadata` is only `{onboarding_operation_id}`; no flag. Replay returns `credential_unavailable` (`:314-327`, `:406`); the reused-account path is at `:337-358`.
- `handleReissueAccess`, `index.ts:1479-1538`, already sets `force_password_change: true` with a new password (Decision 1).
- `handleTogglePasswordChange`, `index.ts:1540-1600`, sets or clears the flag only and issues no password (C6).
- `handleClearPasswordChange`, `index.ts:1602-1699` (J-001 design): checks length >= 8 (`:1636-1645`), requires the flag true (`:1659-1667`), then performs ONE admin `updateUserById({password, app_metadata flag false})` (`:1677-1680`); errors go through `classifiedErrorResponse`.
- Revision 1 re-check (Observed at 88b43fd): `handleTogglePasswordChange` writes `force_password_change: payload.force_change` including false (`index.ts:1570-1580`), so an owner can clear the requirement without a password change (J-001). Re-issue (`:1502-1517`, spreads `userData.user.app_metadata` then writes) and clear-password-change (`:1654-1680`, spreads `currentMetadata` then writes) are both read-modify-write on `app_metadata`, so a student clear built from stale metadata can overwrite a concurrent owner re-issue (J-002). No migration writes `auth.users` today (migrations only read `raw_app_meta_data`, for example `202610050003:23`). Research C26: GoTrue admin `app_metadata` updates merge key by key.
- Caller auth: `index.ts:160-169` `getUser(accessToken)` returns 401 "Invalid or expired session." when the session is gone; the clear-password-change special path is at `:183-189` (student self-service).
- `classifyError`, `src/lib/adminStudentErrorClassification.ts:75-112`: only duplicate-account (register) and 404 are specific; everything else collapses to the generic 'An error occurred while processing this request.' (root cause of C1). The `ErrorContext` type (`:44-62`) lacks 'clear-password-change' and 'toggle-password-change'.
- Temp password generator, `src/lib/adminStudentPasswordGeneration.ts:15-48`: charset A-Z a-z 0-9 (includes look-alikes 0/O/o and 1/l/I), length 12, no guaranteed class coverage (root cause of C2).
- Database enforcement already exists: `user_requires_password_change()` reads `auth.jwt()` `app_metadata` (migration `202608070001:24-33`) and is ANDed into student RLS policies there and in 15 later migrations and rollbacks (for example `202610040003`, `202610050001`, `202610040006`, `202610030001`). The client gate `App.tsx:87-103` derives `needsPasswordChange` from `session.user.app_metadata` on every render.
- Owner detection: `isOwnerUser` = `app_metadata.role === 'owner'` (`src/lib/ownerSettingsAuthorization.ts:65-67`).
- Local `supabase/config.toml` `[auth]`: `enable_signup = true` (`:188`, `:233`), `minimum_password_length = 6` (`:194`), `password_requirements = ""` (`:197`), `secure_password_change = false` (`:240`), rate limit `sign_in_sign_ups = 30` (`:219`). Hosted values Unknown.
- Live test `src/__tests__/admin-student-operations-password-change-security.test.ts`: `:165-190` a FRESH client signs in with the new password after clear-password-change (the server side works); `:216-222` asserts a newly registered (unflagged) student gets `password_change_not_required`. This test intentionally inverts under the new requirement.
- Test ripple (Inference, inventoried at Step 0): tests and fixtures that call 'register' include `admin-student-operations-password-change-security.test.ts`, `adminStudentOperationsFixes.test.ts`, `adminStudentDataErrorPropagation.test.tsx`, `e2e/course-fixtures.ts` (the Wave 2 branch adds `createPreservedBandStudentFixture`, `lizbeth_spanish-218d` `course-fixtures.ts:239-291`, which registers disposable students), `e2e/gap-4-admin-students-remediation.spec.ts`, and PR #231's tests. Any that sign in as the created student will now hit the gate.

### 4.2 #243 client (Observed)

- `ForcedPasswordChangeGate.tsx` (main-88b):
  - English-only copy (`:237-353`) (C5).
  - No `autoComplete` on either Field (`:248-274`) (C3).
  - `aria-describedby` hard-set to the hint (`:257`), so errors are not associated; `aria-invalid` on both fields for any error (`:256`, `:273`) (C7).
  - Errors in three separate `.form-error` paragraphs (`:277-293`); 'session-error' renders the same sentence twice and re-renders the full password form (`:245`, `:283-293`) (C4).
  - Server message rendered raw (`:157-163`) (C1 surface).
  - Step 3 `reestablishSession` (`:83-99`) ignores the `signInWithPassword` error and falls back to `refreshSession()`, which cannot succeed after an admin password update (C4).
  - Header comment `:43-60` claims only refresh tokens are revoked; research contradicts this (the whole session is deleted).
- `ForcedPasswordChangeGate.css`: `.forced-password-change-gate` is `position: fixed`, `inset: 0`, `display: flex`, `align-items: center`, `overflow: auto`, `z-index: 1000` (`:1-14`). This clips the top on short or mobile viewports with the keyboard open (C8) and covers any trigger. The local `.form-error` rule at `:93-102` is owned and deleted by parent PR 1b.
- `App.tsx:97-103` returns only `<div className="app"><ForcedPasswordChangeGate/></div>` when flagged. `<AccessibilitySettings>` mounts only in `AuthenticatedAppShell` (`:637-641`), so the accessibility trigger is absent on the gate. `AccessibilityProvider` wraps the app (`:815`).
- Field primitive `src/components/ui/Field.tsx:85-150`: the `error` prop sets `aria-invalid` and `aria-describedby` to a `role=alert` error; `...rest` is spread after (a caller `aria-describedby` overrides the error id); the adornment slot sits inside `.field__control-wrap`.
- PR #229 pattern: `lizbeth_spanish-224` `src/lib/signInCopy.ts` is typed `Record<'en'|'es', SignInCopy>` functional copy (not owner-editable). `LoginForm.tsx` password input at `:134` has no `autoComplete`. Precedent D-3 in `docs/plans/lizbeth-spanish-issue-batch-2026-10.md` (user accepted ES drafts, optional Lizbeth refinement) and parent D-21 (#208: engineering and Scribe draft, Lizbeth approves before shipping).
- Owner admin: `AdminStudentsPage.tsx:771-808` toggle row ("Require password reset" / "Remove reset requirement"); Re-issue row label "Re-issue access" (`:755-767`); `TogglePasswordChangeModal` `AdminStudentModals.tsx:850-916` copy; re-issue result and temp display `AdminStudentModals.tsx` about `778-820`; `.temp-password-display` code in `RegisterStudentModal.css` (Courier New 1.125rem, `user-select: all`, `overflow-x: auto`, `:71-86`).

### 4.3 #244 (Observed unless marked)

- `.accessibility-button` is `position: fixed`, `z-index: 1` (`src/components/AccessibilitySettings.css:12-26`, comment "do not raise above 997"). The solo focus rule `.accessibility-button:focus` is at `AccessibilitySettings.css:31-34` (pinned by `fieldJournalTokens.test.ts:283` Finding C for outline values). Admin chrome moves the trigger bottom-right (`AdminShell.css:535-538`).
- `App.css:231-240`: `button:focus, a:focus, input:focus, select:focus, textarea:focus, [tabindex]:focus { position: relative; z-index: 10 }` (specificity 0,1,1 beats `.accessibility-button` 0,1,0). `App.css:271-276` grouped rule (`.accessibility-button:focus, .modal:focus, .flashcards-overlay:focus, .vocab-review-overlay:focus`) restores only `position: fixed`. `.modal:focus` has z-index 999 at `:294-296`.
- `<main id="app-main" tabIndex={-1}>` (`App.tsx:578-582`) receives route-change focus. **Hypothesis H1 (Inference, unproven):** a focused `main` becomes a z-index 10 stacking context over the z-index 1 trigger.
- Other layers: MobileNavPanel 40, FlashcardsOverlay 40, VocabularyReviewViewer 40, admin modal wrappers 50 (`AdminStudentModals.css:105-113`, `RegisterStudentModal.css:46-51`), skip link 100 (`App.css:379-389`), Modal backdrop 998, Modal 999, gate 1000.
- Failing journey: `src/__tests__/e2e/issue-55-form-controls-ds-chrome.spec.ts:103-137` forced-colors test clicks the trigger (`:130`) after the course workspace Settings tab (`:117-121`).
- Guards to rerun: `FixedOverlayFocusPosition.test.ts`, `HeadingAccessibilityButtonClearance.test.ts`, `fieldJournalTokens.test.ts` Finding C, `ModalStackingAndInertness.test.ts:83-85` (trigger z below 998).

### 4.4 #245 (Observed)

`src/components/FeedbackForm.tsx:116-117` defines `isDirty` = `content.trim()` OR `courseId !== ''` OR `lessonId !== ''` OR `feedbackType !== 'feedback'`. `:119-124` registers the sign-out guard. The success path (`:195-197`) clears only `content`, so selections keep the guard armed (root cause).

### 4.5 #218 remainder (Observed unless marked)

- `neo-workbook-visual-smoke.spec.ts:233-243` opens `/admin/students/<fullaccess id 0000...0008>` and requires a "Reset Week N" button. Those buttons render from `enrollment.recorded_completions` (`AdminStudentsPage.tsx:834`), built from entitlement completions `fetchEntitlementCompletions` (`index.ts:733-745`, `:896-897`, `:951-956`). They therefore REQUIRE `fullaccess` entitlement rows with `completed_at`. `owner-dashboard.spec.ts:177-182` has the same dependency.
- `issue179c-student-task-form.spec.ts:394-409` signs in as `fullaccess` and requires the legacy (zero-entitlement) path: no task UI on `/roadmap/<fullaccess Beginner enrollment>/week/1`.
- `supabase/seed.sql:505-509` and `:533-534`: `fullaccess` is DELIBERATELY left with zero entitlement rows (`wp11-learn.spec.ts:264-265` relies on it too). On a clean reset, neo and owner-dashboard fail; if any spec materializes `fullaccess`, issue179c `:394` and wp11 fail (order-dependent). The materializing spec is Unknown (no materialize call on `fullaccess` found in e2e; candidates are UI flows or vitest suites). Step 0 diagnoses.
- D-12 self-provision pattern: `lizbeth_spanish-218d` `src/__tests__/e2e/course-fixtures.ts` `createOwnerCourseFixture` (`:97`) and `createPreservedBandStudentFixture` (`:239-291`, register + assign + unassign; cleanup via delete).
- Parent-plan intermittents still undiagnosed: wp2-owner-chrome J3, issue175, issue174 J8, browser-validation-status-clarity J1; vitest issue5-services PDF, issue179 SQL, courseAuthoringUi, issue5EdgeSmoke. Parent closure rule: close #218 only after a clean-reset full e2e run shows 0 failures twice.

## 5. Research evidence

Nested Researcher packet received 2026-10-12. Sources S1 to S17 (ledger below). Limits: GoTrue source was read through WebFetch summaries; hosted state was not inspected; the client race is static analysis only.

- **Q1 password strength.** GoTrue checks password strength on admin update (`adminUserUpdate` -> `checkPasswordStrength`) [S1 `internal/api/admin.go` master; S7 v2.170.0]. Admin create received the check only in PR #2758 (merged 2026-08-31) [S3]; hosted rollout Unknown [S12]. `checkPasswordStrength` reasons: `length` | `characters` | `pwned`; more than 72 characters returns 400 `validation_failed`; HIBP fails open by default [S4 `password.go`]. Response is 422 `weak_password` with `weak_password.reasons` [S5 `errors.go`]. auth-js 2.110.7 throws or returns `AuthWeakPasswordError` (code `weak_password`, status 422, `.reasons`) [S9 `fetch.ts:96-133`, `errors.ts:347-356`]; admin `createUser` and `updateUserById` return `{error}` rather than throw [S9 `GoTrueAdminApi.ts:482-496`, `786-802`].
- **Q2 session effects.** Any admin password update calls `user.UpdatePassword(tx, nil)`, then Logout, which DELETES all sessions for the user [S1, S6 `models/user.go`, S8 `sessions.go`]. Refresh then fails 400 `refresh_token_not_found` or `session_not_found` [S11]. The Edge `getUser` then returns 401 (`index.ts:166-168`). The user-facing `PUT /user` runs `checkPasswordStrength`, a `same_password` check (422 `same_password`), optional reauthentication when `secure_password_change` is on and the session is older than 24h (400 `reauthentication_needed`), and keeps the caller's session (`UpdatePassword(tx, &session.ID)` -> `LogoutAllExceptMe`) [S2b `user.go`]. The admin path has no `same_password` check [S1].
- **Q3 client behavior.** auth-js 2.110.7 in this app uses the lockless path (no custom lock; `src/services/supabase.ts:170-176`) [S9 `GoTrueClient.ts:209,356,449-452`]. `signInWithPassword` returns `{error}` and does not throw [S9 `:1210-1268`]. `refreshSession` with a revoked refresh token returns an error and KEEPS the local session if its access token is unexpired [S9 `:3729-3778`, `:4996-5041`], so the app keeps a server-dead session whose JWT still says `force_password_change` true. A refresh-failure-wipes-new-session race exists in theory but is low-likelihood [S9 `:4926-4983`]. Root-cause inference (medium): the "form loop + 401" is client state: Step 3 sign-in error (trigger Unknown: 429, transient, or hosted setting) -> refresh fallback fails -> stale session keeps the gate -> resubmission sends a dead token -> Edge 401. H-server-rejects-new-password is refuted locally by the live test.
- **Q4 flag at creation.** `createUser` merges `app_metadata` into the new user (`UpdateAppMetaData` key by key; `provider` and `providers` kept unless overwritten), and access-token claims include `app_metadata`, so a flag set at `createUser` is in the first JWT [S1, S6, S11b] (Inference, high for the token path).
- **Q5 defaults and limits.** GoTrue default minimum length is 6, no character requirements, secure password change off by default [S15 `configuration.go`]. Leaked-password protection is a Pro-plan feature, hosted default Unknown [S16]. Hosted token-endpoint rate limit is 150 per 5 minutes per IP, burst 30, 429 `over_request_rate_limit` [S17, S13].

Source ledger (all accessed 2026-10-12):

| Id | Source |
|---|---|
| S1 | https://raw.githubusercontent.com/supabase/auth/master/internal/api/admin.go |
| S2b | https://raw.githubusercontent.com/supabase/auth/master/internal/api/user.go |
| S3 | https://github.com/supabase/auth/pull/2758 |
| S4 | https://raw.githubusercontent.com/supabase/auth/master/internal/api/password.go |
| S5 | https://raw.githubusercontent.com/supabase/auth/master/internal/api/errors.go |
| S6 | https://raw.githubusercontent.com/supabase/auth/master/internal/models/user.go |
| S7 | supabase/auth v2.170.0 `admin.go` and `models/user.go` |
| S8 | https://raw.githubusercontent.com/supabase/auth/master/internal/models/sessions.go |
| S9 | local `@supabase/auth-js` 2.110.7 source at `lizbeth_spanish-224/node_modules/@supabase/auth-js/src` |
| S10 | local app files |
| S11 | https://raw.githubusercontent.com/supabase/auth/master/internal/tokens/service.go |
| S12 | https://github.com/supabase/auth/releases |
| S13 | https://supabase.com/docs/guides/auth/debugging/error-codes |
| S14 | https://github.com/supabase/auth/pull/2757 |
| S15 | https://raw.githubusercontent.com/supabase/auth/master/internal/conf/configuration.go |
| S16 | https://supabase.com/docs/guides/auth/password-security |
| S17 | https://supabase.com/docs/guides/auth/rate-limits |

Validation measures carried into tests: V1 `weak_password` shape against local with a stricter local config if feasible (else mocked); V2 old access token behavior after the server change; V3 browser stub of `/auth/v1/token` 429 during Step 3; V4 decode the first JWT after `createUser` with the flag; V5 hosted dashboard read-only check (D-P7).

## 6. Design route, reviewed design handoff, design review

### 6.1 Design route

`DESIGN_ROUTE` profile compact. Reasons: bounded brownfield corrections in the Field Workbook system (gate, owner admin copy, trigger stacking, FeedbackForm). Agents required: design-generalist, design-reviewer. Prototype forbidden. Model tier sonnet. Existing system mode: preserve.

### 6.2 Design handoff: "Field Workbook, corrective pass" (reviewed, revision 1)

Selected direction: Field Workbook, corrective pass (preserve). No new screens, tokens, primitives or modals.

Design brief: audience is Spanish- and English-reading students on first sign-in with a teacher-issued temporary password (often on a phone with the keyboard open), and the owner (admin English-only). Thesis: a calm paper sheet; choose a password, learn exactly what went wrong, recover if the session breaks after the save, always reach text-size settings. The work is association, language, ordering, mounting and layering.

**G1 Gate language.** New `src/lib/forcedPasswordCopy.ts`, typed `Record<'en'|'es', ForcedPasswordCopy>` (the #229 `signInCopy` pattern), functional, not owner-editable, compile error on a missing field. Uses `useSiteLanguage()`. The existing `LanguageToggle` renders at the top of `.gate-content`, before the h1 in DOM. Switching re-derives text from stored kinds and never moves focus, clears values, or clears errors.

**G2 Error kinds (closed union).** `ForcedPasswordErrorKind` = `too_short | mismatch | weak_characters | pwned | same_as_temporary | rate_limited | network | generic`; `PostSaveKind` = `session_not_reestablished | requirement_changed | session_ended` (DR2-2 split; revised). Mapping:

- `too_short` and `mismatch` are client checks.
- 422 `weak_password` reasons: contains `pwned` -> `pwned`; else contains `characters` -> `weak_characters`; `length` alone -> `too_short`.
- Edge `same_password` -> `same_as_temporary`.
- 429 `over_request_rate_limit` -> `rate_limited`.
- Failed or aborted request -> `network`.
- Every other code, including `reauthentication_needed` and unknown, -> `generic`.
- Never render `error.message` or server text.
- `weak_characters` copy is generic-but-true and conditional on the hosted policy.

**G3 Field association.** Use Field's `error` prop; no manual `aria-describedby` on gate fields. The 8-character rule is a sentence in the explanation paragraph. `too_short`, `weak_characters`, `pwned` and `same_as_temporary` attach to New password (focus there); `mismatch` attaches to Confirm only (focus there). `aria-invalid` only on the offending field.

**G4 Form-level alert.** `rate_limited`, `network` and `generic` render in ONE `<p role="alert" class="form-error" tabIndex={-1}>` between the fields and the submit row, focused on arrival, with no field `aria-invalid` and values kept. The network copy carries "can't be sure it saved" plus temporary-password advice.

**G5 Error clearing.** A field error clears when its own field is edited; the form-level alert clears on the next submit; a language switch preserves both.

**G6 State machine.**

- Initial: h1 focused on mount. Order: language toggle, h1, explanation, New password + Show/Hide, Confirm + Show/Hide, Submit, quiet sign-out.
- Saving and success: ONE persistent `role=status` container, always mounted, text empty -> "Saving your new password…" -> "Password updated." The form stays mounted; inputs `readOnly`; submit `aria-disabled` with a handler early-return guard (not `disabled`); Show/Hide `aria-disabled` while saving; submit label "Saving…"; sign-out hidden in flight; the 1s pause is kept; if anything unmounts, focus the h1 or the status container.
- Terminal (`session_not_reestablished`, only after a saved password and failed recovery): the form unmounts and NO input remains in the DOM. The h1 text becomes "Your password is saved" and is focused. The status container carries "Sign in again with your new password to continue." once. The old retry link and the duplicate message are removed. One Primary "Go to sign in" calls `AuthContext.signOut` (so the B4 explicit-sign-out marker is set and no expiry notice shows; the sign-in card then follows parent invariant 6). The quiet sign-out is removed.
- Terminal variants (Revision 1): Edge 409 `requirement_changed` and Edge 401 `session_ended` enter their own terminal states with the heading and status text in section 6.5. All terminals share one composition: no inputs, the h1 text changes and is focused, the persistent status carries the explanation once, one Primary "Go to sign in" (shared key; ES "Ir a iniciar sesión") calling `AuthContext.signOut`, and the D3 notice treatment. 409 and 401 never map to generic.

**G7 Show/Hide (option b).** One per field in Field's adornment slot. Control quiet text button; visible "Show"/"Hide"; accessible names change with it ("Show new password"/"Hide new password", "Show confirmation password"/"Hide confirmation password"); no `aria-pressed`. Invariant: the accessible name contains the visible text. It toggles `type` password/text preserving caret and value, with no blur. Both reset to hidden at submit start. Min-width for the longer localized label; min-height `var(--hit-target-min)` (44px; `App.css:492` / `tokens/field-workbook.generated.css:122`); gate-scoped `padding-inline-end` on inputs equal to the button width.

**G8 Autocomplete.** Both gate fields `autoComplete="new-password"`, `spellCheck` false, `autoCapitalize` none, `autoCorrect` off; Confirm `enterKeyHint` "go".

**G9 LoginForm (#229 tree).** Email `autoComplete="username"`, `inputMode="email"`, `autoCapitalize` none, `spellCheck` false; password `autoComplete="current-password"`; existing `aria-describedby` "login-help-body" stays. The same Show/Hide sub-component is recommended (shared composition of Field + Control).

**G10 Sign-out control.** Standalone Control quiet with min-height `var(--hit-target-min)`, NOT `.link-button`; computed height >= 44px at 320.

**G11 Layout and scroll.** Keep `position: fixed`, `inset: 0`, `overflow: auto`; remove `align-items: center`; `align-items: flex-start` plus `.gate-content` `margin: auto`; height `100dvh` with a `bottom: 0` fallback; `scroll-padding-top: var(--a11y-trigger-footprint)`. At <900px the toggle row and h1 get `padding-inline-end: calc(var(--a11y-trigger-footprint) + var(--space-2))` (`App.css:96` token; precedent `App.css:1016`, `1033`, `1037`); none at >=900px.

**G12 Trigger mount contract.** In the `needsPasswordChange` branch render `<AccessibilitySettings/>` uncontrolled with the default `renderTrigger` as a sibling AFTER the gate inside `.app`. Exactly one `.accessibility-button` after the gate in DOM. Open state may reset when the gate exits. A unit test asserts presence.

**G13 Owner admin (English only; replaced in design revision 2, owner control is one-way).**

- Required row: badge "Reset required at next sign-in"; description "This student will be asked to choose a new password the next time they sign in. Only the student can clear this, by choosing one. If they can't sign in, use Re-issue access."; NO control.
- Not-required row: badge "Not required"; description "No password reset is pending for this student."; Secondary Control "Require password reset" (`aria-label` "Require password reset for [email]"); helper "Asks the student to choose a new password the next time they sign in. This does not create or send a password. Only the student can clear it, by choosing a new password."
- Modal, enable-only: title "Require Password Reset"; body "The next time [email] signs in, they'll be asked to choose a new password before they can do anything else. This doesn't change their current password and doesn't send anything. Only the student can clear it, by choosing a new password. If they can't sign in, use Re-issue access. Continue?"; Cancel plus "Require Reset" ("Requiring..."); confirm tier Secondary (DR2-3).
- Delete the `currentlyRequired` prop and its branches, send true unconditionally, and fix the "always reversible" comment at `AdminStudentModals.tsx:900-903` (DR2-3).
- Failure shows the fixed "Couldn't update this setting. Try again." in the existing `role=alert` `.form-error` (not `err.message`, which today renders at `:867`); the modal stays open with focus on confirm.
- After confirm (DR2-1, preferred option): focus moves to the stable `.password-reset-info` container (`AdminStudentsPage.tsx:773`). Give it `tabIndex` -1, `role` group and `aria-labelledby` the badge, with the standard focus ring (forced-colors Highlight). Add NO separate status region; the announcement is spoken exactly once (test). The focus effect runs after Modal's own focus return. Escape and Cancel return focus to the row control.
- "Re-issue access" is the existing row label (`AdminStudentsPage.tsx:767`), plain text, no link or button in the modal.
- Where a temp password is shown (`RegisterStudentModal` and `OnboardingOutcome` in -228; re-issue result `AdminStudentModals.tsx` about `778-820`) add a `<p>` "[Student] will be asked to choose their own password the first time they sign in." after the show-once label and before the display. Keep the existing "can no longer be shown" text.
- Temp display keeps Courier New 1.125rem, `user-select: all` and the existing Copy; add `white-space: nowrap` with the existing `overflow-x: auto`; the scroller gets `tabIndex` 0, `role` group, `aria-label` "Temporary password".

**G14 Visual.** `.form-error` single-owner in `src/App.css` (ink-900). The gate PR lands AFTER parent PR 1b and adds only spacing-only scoped selectors; it never deletes or recolors `.form-error`. Field errors use `.field__error` plus `aria-invalid` border and the forced-colors double border. The terminal and status notice reuses parent D3 neutral treatment (paper-50, ink-700 hairline + 3px ink-700 left bar, ink-900 .875rem, forced-colors CanvasText). Success keeps status-success tokens. No token additions. Reviewer R-2: add minimal gate-scoped styles for `[aria-disabled="true"]` and `:read-only` using existing disabled tokens (`Field.css:56-62` pattern) and check forced-colors.

**G15 Layer contract (#244).** Focus bump 10; gate 15 (was 1000); accessibility trigger 20 (was 1); MobileNavPanel, Flashcards, VocabularyReviewViewer 40; admin modal wrappers 50; skip link 100; Modal backdrop 998; Modal 999. The `AccessibilitySettings.css` comment becomes "Layer contract: above the focus bump (10) and the gate (15); below every overlay/panel (40+) and modal (998). Do not raise above 39." Focused trigger: add `z-index: 20` to the SOLO `.accessibility-button:focus` rule at `AccessibilitySettings.css:31-34` (reviewer R-1: do NOT edit the grouped `App.css:271-276` rule, which would also change the flashcards and vocab-review overlays); keep the outline declarations for `fieldJournalTokens` Finding C. Invariant: the focused trigger's computed z-index is 20. H1 remains unproven; the validator reports the actual covering element if still covered. Forced-colors: scoped border fallback only if invisible. `AdminShell.css:535-538` sets no z-index above 39. Clarification (DR2-4): the focused-trigger z-index goes ONLY in the solo `.accessibility-button:focus` rule at `AccessibilitySettings.css:31-34` (reviewer R-1). The grouped `App.css:271-276` rule is untouched. This plan supersedes any handoff text that says otherwise.

**G16 DR-10 known limit.** The AccessibilitySettings trigger label (`AccessibilitySettings.tsx:66`) and modal title (`:75`) are English-only. Permitted variation: `lang="en"` on those on an ES gate. `PublicContentContext` forces 'en' on `/admin/*` paths (`lizbeth_spanish-224` `PublicContentContext.tsx:92`).

**G17 FeedbackForm #245.** On successful submit reset `courseId` '', `lessonId` '' and `feedbackType` 'feedback' along with content. The `isDirty` definition is unchanged; success announcement and focus are unchanged. The reset never moves focus or clears the success message. The guard is unarmed after success and re-arms on new input. On error nothing resets.

### 6.3 Engineering invariants (15)

1. No native dialogs, with a deterministic scan.
2. A single `.form-error` in `App.css` after 1b; spacing-only here.
3. Functional EN/ES kinds, no server text, unknown -> generic.
4. Field error association; `aria-invalid` only on the offending field; no manual `aria-describedby`; a single form-level alert; no duplicates; the clearing rules.
5. New-password autocomplete; Show/Hide name contains visible text; no `aria-pressed`; no layout shift; LoginForm hints.
6. One persistent status container; form mounted during saving and success with `readOnly`/`aria-disabled`; focus never to body.
7. Each terminal state renders no password input and exactly one primary action calling `AuthContext.signOut`, and 409/401 never map to generic.
8. The gate branch renders exactly one trigger after the gate, with a unit test.
9. Layer contract including focused z 20; existing guards pass (`FixedOverlayFocusPosition`, `HeadingAccessibilityButtonClearance`, `fieldJournalTokens` Finding C, `ModalStackingAndInertness`); update tests pinning z-index 1 or the old comment.
10. The gate never clips at 320/390 with the keyboard; footprint reservation <900px.
11. Standalone sign-out at `hit-target-min`.
12. Owner admin English-only; the client never sends `force_change:false`; the required row renders no control; after confirm, focus goes to the row info group with a single announcement; modal Escape/Close and focus return.
13. Every Spanish string marked `// DRAFT ES: pending owner (Lizbeth) approval` plus a PR body note.
14. Server recovery is engineering-owned; the UI keeps the terminal fallback.
15. `isDirty` unchanged; success resets content and selections.

### 6.4 Permitted variation

File names and placement; EN wording within categories (ES is draft); raw z integers keeping the order (gate > 10, trigger > gate and < 40, also in the focus rule); Show/Hide as text or an existing eye glyph only; scoped forced-colors border only if needed; terminal action label wording; `lang="en"` on trigger or modal title on an ES gate, or a recorded known limit; LoginForm hints in PR E or a follow-up.

### 6.5 Draft copy

EN candidate / ES DRAFT pending Lizbeth approval; tu register; "tu profesora".

| Key | EN | ES (DRAFT) |
|---|---|---|
| heading | Choose a new password | Elige una nueva contraseña |
| explanation | For your security, set a new password before you continue. Use at least 8 characters. You'll use it every time you sign in. | Por tu seguridad, elige una nueva contraseña antes de continuar. Usa al menos 8 caracteres. La usarás cada vez que inicies sesión. |
| label new | New password | Nueva contraseña |
| label confirm | Confirm new password | Confirma la nueva contraseña |
| show / hide (visible) | Show / Hide | Mostrar / Ocultar |
| names | Show new password / Hide new password / Show confirmation password / Hide confirmation password | Mostrar nueva contraseña / Ocultar nueva contraseña / Mostrar confirmación de contraseña / Ocultar confirmación de contraseña |
| too_short | Your new password needs at least 8 characters. | Tu nueva contraseña necesita al menos 8 caracteres. |
| mismatch | Those passwords don't match. Please enter them again. | Las contraseñas no coinciden. Vuelve a escribirlas. |
| weak_characters | That password doesn't meet this site's password rules. Try mixing upper and lower case letters, numbers and symbols. | Esa contraseña no cumple las reglas de contraseña de este sitio. Prueba a combinar mayúsculas y minúsculas, números y símbolos. |
| pwned | That password has appeared in a known data breach. Please choose a different one. | Esa contraseña ha aparecido en una filtración de datos conocida. Elige otra. |
| same_as_temporary | Your new password can't be the temporary one. Please choose a different one. | Tu nueva contraseña no puede ser la temporal. Elige otra distinta. |
| rate_limited | Too many attempts. Wait a minute and try again. | Demasiados intentos. Espera un minuto e inténtalo de nuevo. |
| network | We couldn't reach the server, so we can't be sure your new password was saved. Check your connection and try again. If it doesn't work, sign in with your temporary password. | No pudimos conectar con el servidor, así que no sabemos si se guardó tu nueva contraseña. Revisa tu conexión e inténtalo de nuevo. Si no funciona, inicia sesión con tu contraseña temporal. |
| generic | We couldn't save your new password. Please try again, or contact your teacher if this continues. | No pudimos guardar tu nueva contraseña. Inténtalo de nuevo o habla con tu profesora si sigue pasando. |
| saving button | Saving… | Guardando… |
| saving status | Saving your new password… | Guardando tu nueva contraseña… |
| success | Password updated. | Contraseña actualizada. |
| terminal heading | Your password is saved | Tu contraseña está guardada |
| terminal status | Sign in again with your new password to continue. | Inicia sesión de nuevo con tu nueva contraseña para continuar. |
| terminal action (shared by all terminals) | Go to sign in | Ir a iniciar sesión |
| terminal heading, `requirement_changed` | Your teacher reset your access | Tu profesora restableció tu acceso |
| terminal status, `requirement_changed` | Your teacher reset your access while you were choosing a new password. Sign in with the newest password your teacher gave you. | Tu profesora restableció tu acceso mientras elegías una nueva contraseña. Inicia sesión con la contraseña más reciente que te dio tu profesora. |
| terminal heading, `session_ended` | Sign in again | Inicia sesión de nuevo |
| terminal status, `session_ended` | Your sign-in changed while you were choosing a new password, so your new password was not saved. Sign in with the newest password your teacher gave you. | Tu sesión cambió mientras elegías una nueva contraseña, así que tu nueva contraseña no se guardó. Inicia sesión con la contraseña más reciente que te dio tu profesora. |
| sign out | Sign out and come back later | Cerrar sesión y volver más tarde |
| submit | Set password | Guardar contraseña |

### 6.6 Design browser-validation brief

Viewports: 1440x900, 390x844, 320x568, 320 at 200% zoom, 320x300 (keyboard open), plus forced-colors on the gate, sign-in and course workspace.

Fault injection via Playwright `page.route` (restore with `unroute` or a fresh context):

- Edge `clear-password-change` 422 `weak_password` with reasons `["pwned"]`, `["characters"]`, `["length"]`, `["characters","pwned"]`.
- 422 `same_password`.
- 422 unknown code and `reauthentication_needed` (generic).
- 429.
- `route.abort()` for network.
- Edge `clear-password-change` 409 `{code: 'requirement_changed'}` and 401 (`session_ended`); owner `toggle-password-change` 422 `clear_not_permitted` plus abort.
- `/auth/v1/token` `grant_type=password` and `refresh_token` 400 then 429 for the terminal state.

Journeys with visible outcomes:

- **J1** happy path EN then ES: the toggle keeps focus and values; status "Saving your new password…" then "Password updated." is announced before unmount; app shell after the pause; re-sign-in with the new password works.
- **J2** field errors: `aria-invalid` only on the offending field, `describedby` = its error id, focus there, message once, editing clears only its own error, unknown/reauth -> generic alert.
- **J3** form-level 429/abort: one focused alert, no field `aria-invalid`, values kept, cleared on next submit, kept on language switch.
- **J4** terminal: heading change focused, no inputs, one primary, sign-in card with no expiry notice, new password works.
- **J5** show/hide: visible text and name change together, no `aria-pressed`, identical bounding boxes, caret and value kept, no overlap at 320.
- **J6** mobile scroll plus `elementFromPoint` on both toggle buttons, trigger and Show/Hide after focusing fields; sign-out >= 44px at 320.
- **J7** trigger on gate: exactly one after the gate; `elementFromPoint` unfocused and keyboard-focused with computed z 20 and ring visible; settings Modal above gate with focus trap; Escape/Close return focus; text size resizes the gate; forced-colors visible.
- **J8** #244 after the course workspace Settings tab and admin pages at 1440/390, unfocused and focused; Modal makes the trigger inert; overlays open above the trigger without covering their controls; forced-colors issue-55 Location 3; report the covering element if still covered.
- **J9** LoginForm attributes and unchanged help/error/language behavior.
- **J10** owner admin (extended in Revision 1): create via register and create-and-assign shows the sentence; no look-alikes across several values; Copy status; 320 horizontal scroll with a focusable named scroller; re-issue sentence; no native dialog.
  - A new student's row shows required with no control. The not-required row shows the Secondary control and helper.
  - The modal is enable-only. After confirm, `document.activeElement` is `.password-reset-info` with a visible ring and the announcement is spoken once. The control stays gone after reload. Escape/Close/focus return still work.
  - Injected 422 `clear_not_permitted` and a network abort show the fixed message with focus on confirm.
  - No intercepted request body contains `force_change:false`.
- **J11** a newly created student's first sign-in shows the gate heading with no app shell.
- **J12** FeedbackForm reset, guard disarm and re-arm, Escape/Keep editing focus return, failed submit keeps values.
- **J13** `requirement_changed` (320, 390, 1440): `page.route` the Edge `clear-password-change` response to 409 `{code:'requirement_changed'}`. The heading and status differ from J4; no inputs; one primary; the sign-in card shows no expiry notice; the language toggle switches in place. Residual: the live race can only be faked in the browser.
- **J14** `session_ended`: `page.route` the Edge response to 401. The `session_ended` terminal copy shows; otherwise the same checks as J13.

Deterministic scans: no `force_change:false` in client code; no native dialogs; one `.form-error` color rule; every gate string in en and es; no server message in the gate; `.accessibility-button` and its `:focus` both resolve to z 20 with no AdminShell override higher; unit test for the single gate-branch trigger.

### 6.7 Design assumptions and unresolved items

Assumptions: the gate replaces the app shell (no 40/50 panels under it); the skip link is absent or harmless on the gate; password managers work without a hidden username field (add a visually hidden `autocomplete="username"` input carrying the email only if validation shows poor behavior); the hosted characters requirement is Unknown; z values are raw integers; `LanguageToggle` is mountable in the gate (reviewer confirmed provider order); Control quiet forced-colors affordance is verified in the browser.

Unresolved: the trigger sits under 40-level overlays when open (default as specified, D-P9); LoginForm hints in PR E versus a follow-up (D-P6); Lizbeth approval of ES drafts (blocks merge, D-P5); hosted password policy for `weak_characters` (D-P7); safe-area inset usage (skip unless already used); `lang="en"` on trigger or modal title.

### 6.8 Design review

- Round 1 `DESIGN_REVIEW_RESULT` NEEDS_REVISION (independent design-reviewer, Sonnet): DR-01 high, trigger not mounted on the gate (`App.tsx:97-103` vs `:637-641`); DR-02 high, focused trigger collapses to z 10 (`App.css:232-240` specificity); DR-03 high, trigger overlaps the right-aligned language toggle at 320/390; DR-04 medium, show/hide label-in-name (WCAG 2.5.3); DR-05 medium, contradictory `.form-error` sequencing versus PR 1b; DR-06 medium, error-kind union undefined; DR-07 medium, live region and focus loss during saving; DR-08 medium, sign-out target size; DR-09 low, non-focusable temp-password scroller; DR-10 low, English-only trigger on an ES gate; DR-11 medium, browser brief missing fault injection and visible outcomes; DR-12 low, error clearing. One bounded revision applied all.
- Round 2 `DESIGN_REVIEW_RESULT` PASS on revision 1. Findings carried into engineering: R-1 (medium, non-blocking) put the focused z-index in the solo `AccessibilitySettings.css:31-34` rule, not the grouped `App.css:271-276` rule; R-2 (low) scope `[aria-disabled]`/`[readonly]` visual cues with existing disabled tokens.
- Round 3 `DESIGN_REVIEW_RESULT` PASS on design revision 2 (delta re-review of the one-way owner control G13, the split terminals in G2, and the G15 clarification). Findings DR2-1 to DR2-4 are carried into engineering: DR2-1 focus to the stable `.password-reset-info` container after confirm with a single announcement; DR2-2 split terminal states (`requirement_changed`, `session_ended`) distinct from generic; DR2-3 Secondary confirm tier, delete `currentlyRequired` and fix the "always reversible" comment; DR2-4 focused-trigger z-index only in the solo `AccessibilitySettings.css:31-34` rule.
- Remaining limits: browser behavior is unverified (focused-trigger z and covering element; toggle-row fit at 320 beside the reserved footprint, about 168px usable; no-shift Show/Hide with ES labels; Control quiet forced-colors). Edge recovery was not reviewed by design. ES drafts need Lizbeth. `weak_characters` depends on hosted policy. Rerun `FixedOverlayFocusPosition`, `HeadingAccessibilityButtonClearance`, `fieldJournalTokens` Finding C and `ModalStackingAndInertness` after any trigger or z edit.

## 7. Judge route

Policy: shadow (advisory) per `docs/JUDGE-CONTRACT.md`.

- PLAN_DUCK is eligible before approval (the orchestrator runs it).
- CODE_REVIEW is recommended for PR D (auth/security Edge, J-001-sensitive) and PR E (auth client).
- VERIFICATION_CHALLENGE is optional for PR C (#218 closure claims).
- VISUAL_REVIEW is optional for PR E (gate) and PR A (layering).
- Standard task cap is two calls per eligible checkpoint set; high-risk PR D up to four. Deterministic failures dominate. No model-generated findings are included in this plan; any finding ids produced later flow into the engineering job and the Verifier evidence.

## 8. Ordered work

Rules for every PR: serial, one writer, T1 first-line standard mode; base `main`; never push to main; body "Closes #N" or "Refs #N"; no merge. **Step 0:** `git fetch`, record the base SHA, re-verify cited lines, read the GitHub issue bodies, check open-PR merge state, run the stale-plan check.

### Wave 0b: orchestrator via gh, after approval, no code

- (a) Per D-P1 file a new issue "Owner-created students must choose their own password at first sign-in (server-enforced)" or comment on #243.
- (b) Read the bodies of #243, #244, #245 and #218 and reconcile their acceptance criteria into the PR jobs.

### PR A: #244 accessibility trigger stacking (executable now)

- **RED first:** a new e2e (for example `src/__tests__/e2e/issue244-a11y-trigger-reachability.spec.ts`) as owner over `/admin/dashboard`, `/admin/students`, `/admin/courses/new`, `/admin/business-settings`, `/admin/course-settings`, then Open workspace -> Settings tab, at 1440x900 and 390x844 (where the trigger is not docked in the mobile panel) and 320, in normal and forced-colors contexts. `elementFromPoint` at the trigger center returns the trigger (or a descendant) both unfocused and after keyboard focus; a click opens the accessibility settings dialog. The RED run records the actual covering element (confirms or refutes H1).
- **Fix per G15:** trigger z 20; solo `:focus` rule z 20; comment; forced-colors border only if needed. Add a cascade/unit test resolving computed z for the unfocused and focused trigger (10 < z < 40, equal values). Update tests pinning z 1 or the old comment, deliberately.
- **Gates:** issue-55 spec 5/5 with `--repeat-each=5` (Location 2 also needs the PR 2d draft fixture; if 2d is not merged, assert Location 3 and the forced-colors trigger step via the new spec and record Location 2 as a 2d dependency); issue-54 header overlap spec, issue-57 modal inertness spec, `FixedOverlayFocusPosition`, `HeadingAccessibilityButtonClearance`, `fieldJournalTokens` Finding C and `ModalStackingAndInertness` all pass.
- If the covering element is not explained by z-order (for example `pointer-events` or a higher-z page element), return to the Planner and design (stale-plan).
- Closes #244; Refs #218.

### PR B: #245 FeedbackForm dirty after submit (executable now)

- **RED:** a unit test with course, lesson and a non-default type selected, a mocked successful `submitFeedback`, then `requestSignOut`: the guard must return false (no disclosure; fails today). After success, typing re-arms. A failed submit keeps text and selections and stays dirty.
- **Fix per G17** in `FeedbackForm.tsx` success path (`:195-197`).
- **e2e:** signing out after a successful submit shows no disclosure; a `page.on('dialog')` listener; existing `SignOutGuardContext` and wp2 sign-out tests unchanged.
- Closes #245.

### PR C: #218 remainder (test-only)

Starts after parent PR 2d (`test/218-self-provision-fixtures`, `course-fixtures.ts` helpers) merges; never stacked.

- **Step 0 diagnosis:** on a clean `db reset`, fingerprint the `fullaccess` entitlement count before and after each spec in a full run (or bisect) to identify the materializer, and record it:
  `select count(*) from public.enrollment_lesson_entitlements ele join public.student_enrollments e on e.id=ele.enrollment_id where e.user_id='00000000-0000-0000-0000-000000000008'`
- **Fix (D-P11):**
  - `neo-workbook-visual-smoke` (`:233-243`) and `owner-dashboard` (`:177-182`) use a disposable student provisioned through the owner API (register + assign Beginner) plus loopback pg completion of at least one entitlement so a "Reset Week N" button exists; cleanup deletes the student (`createPreservedBandStudentFixture` pattern).
  - `issue179c` `:394` uses a disposable legacy-path student (enrollment with `band_id` and zero entitlement rows, loopback pg) or, if kept on `fullaccess`, a `beforeAll` precondition guard asserting zero entitlements with a clear message.
  - The identified materializer stops mutating `fullaccess` (disposable account or `afterAll` restore).
  - Extend the parent PR 2c fingerprint/`globalTeardown` with "fullaccess entitlement count = 0".
  - All helpers hard-fail unless the Supabase URL is 127.0.0.1 or localhost.
- **Intermittents:** rerun wp2-owner-chrome J3, issue175, issue174 J8 and browser-validation-status-clarity J1 with `--repeat-each=5`, and vitest issue5-services PDF, issue179 SQL, courseAuthoringUi and issue5EdgeSmoke 5 times. Each gets an evidence-backed root cause and a fix, or a filed product-defect issue. Never weaken assertions.
- If PR D has merged, any journey that signs in as a disposable student must complete the gate via a loopback helper.
- **#218 closure criteria (all required):**
  1. PR A merged.
  2. Parent Wave 2 PRs 2a to 2e merged.
  3. PR C merged.
  4. On a fresh db reset, two consecutive full e2e runs with 0 failures, plus one full run without reset with 0 failures, plus the `fullaccess`-coupled specs (issue179c, neo-workbook-visual-smoke, owner-dashboard, wp11-learn) run in both orders in separate invocations with 0 failures.
  5. Previously intermittent specs 5/5.
  6. Full vitest run with 0 failures except documented environment skips (parent PR 2a).
- The last PR to land carries "Closes #218"; otherwise the orchestrator closes it with the evidence after approval. Refs #218.

### PR D: server-side first-sign-in requirement (#243 C1 server, C2, C6, new requirement)

Starts after PRs #230 and #231 merge (`onboarding.ts` exists only in #231). If 1b is in flight, whichever merges second rebases; never stacked. Fallback (D-P3): if the #231 merge slips more than about one week, ship PR D-a (register path, classification, generator, toggle copy, re-issue sentence) from main and PR D-b (create-and-assign flag + `OnboardingOutcome` sentence) after #231 merges.

- **D0 (new, Revision 1) Requirement authority and atomic writes**, via forward migration plus rollback. File names follow parent plan section 10: `supabase/migrations/YYYYMMDDNNNN_issue<N>_password_change_requirements.sql` after the latest migration, and `supabase/rollbacks/issue<N>_password_change_requirements_rollback.sql`.
  - New table `public.password_change_requirements` with columns `user_id uuid primary key references auth.users on delete cascade`, `version uuid not null`, `issued_digest text null`, `required boolean not null`, `updated_at timestamptz`. RLS is enabled with no policies. `revoke all` from `anon` and `authenticated`.
  - Function `public.require_password_change(p_user_id uuid, p_issued_digest text) returns uuid`. It locks or upserts the row, sets a new `version`, the digest, and `required = true`. In the same transaction it runs `update auth.users set raw_app_meta_data = raw_app_meta_data || jsonb_build_object('force_password_change', true, 'force_password_change_version', v) where id = p_user_id`.
  - Function `public.clear_password_change(p_user_id uuid, p_version uuid) returns boolean`. It takes `select ... for update` on the row. It clears only if `required` and `version = p_version`; for a legacy flagged user with no row it matches `p_version` null. When it clears, it sets `required = false` and `issued_digest = null`, and in the same transaction merges `force_password_change` false into `raw_app_meta_data`. It returns whether it cleared.
  - Both functions are `SECURITY DEFINER` with a fixed `search_path`. EXECUTE is revoked from `public`, `anon` and `authenticated` and granted to `service_role` only (the #222 pattern; extend `authenticatedFunctionExecuteGrants.test.ts`).
  - The JWT claim in `app_metadata` remains the input to the existing RLS function `user_requires_password_change()` (migration `202608070001`), so RLS is unchanged.
  - Unknown: whether the hosted `postgres` role may UPDATE `auth.users`. Local is proven by the RED tests. D-P7 gains a read-only hosted check: `select has_table_privilege('postgres','auth.users','UPDATE')`.
  - Fallback if it is not permitted: the row is the authority, and the Edge mirrors the claim with an admin key-merge update of only `{force_password_change: <row state>}`. It then re-reads the row and rewrites the mirror if the row changed (reconcile loop, at most 2 passes). This fallback is a stale-plan trigger requiring a plan revision (section 14).
  - Digest: SHA-256 hex of `version || ':' || password`, computed in the Edge. It is stored only in the `service_role`-only table and is never put in `app_metadata` or the JWT. It is nulled on clear.
- **D1 (amended)** Shared dependency-free helper (for example in `src/lib/forcedPasswordChangeAuthorization.ts`): `newStudentAppMetadata(extra)` -> `{ ...extra, force_password_change: true }`; never sets `provider`/`providers`.
  - `register` keeps `createUser` with `app_metadata` `force_password_change` true (`handleRegisterStudent`, `index.ts:308-312`, so the claim exists even if the next step fails), then calls rpc `require_password_change(user, digest of the issued temp password)`.
  - `create-and-assign` (`onboarding.ts:369-374` -> `{ onboarding_operation_id, force_password_change: true }`) does the same.
  - `re-issue` is reordered: compute the temp password, call rpc `require_password_change(user, digest)` FIRST (new version, flag true), then admin `updateUserById(userId, {password})` with NO `app_metadata` write. If the password update fails, the student stays flagged with the old password (fail-safe) and the endpoint returns the mapped error.
- **D2 (amended contract scan)** Deterministic test scanning `supabase/functions/**/*.ts`: no Edge code writes `force_password_change` through `updateUserById` `app_metadata`; every flag set goes through rpc `require_password_change` and every clear goes through rpc `clear_password_change`; every `createUser` call carries the helper's `app_metadata`.
- **D3 (replaced) `clear-password-change`**, Option B with version and idempotent recovery (per D-P2):
  1. `getUser(token)`; a 401 here maps to code `session_ended`. Read the requirement row and flag. If not required, return 400 `password_change_not_required` (existing). Note version V and digest.
  2. Keep the >= 8 length check. Call GoTrue `PUT {SUPABASE_URL}/auth/v1/user` with the caller token (`apikey` anon, `Authorization` Bearer) and body `{password}`.
     - 200 proceeds to step 3.
     - 422 `same_password` is the J-003 idempotent recovery. If the digest is non-null and `SHA-256(V:new) != digest`, GoTrue has confirmed the current password equals `new` and `new` is not the issued temporary password, which proves the student already changed it, so proceed to step 3. If the digest matches, return 422 `same_password` (UI: `same_as_temporary`). If the digest is null (toggle-on or legacy requirement), return 422 `same_password` and the student chooses a different password (the session is still valid, so no lockout).
     - 422 `weak_password` returns `{code: 'weak_password', reasons}`. 429 returns `rate_limited`. 400 `reauthentication_needed` returns `reauthentication_needed`. A session gone (403/401 `session_not_found`) returns 401 `session_ended`.
  3. rpc `clear_password_change(user, V)`.
     - true returns 200.
     - false returns 409 `requirement_changed` (an owner re-issue or toggle changed the version: J-002). The owner's admin password update has already ended the student's sessions.
     - An rpc error returns 500 `flag_clear_failed`. A retry follows step 2's recovery path.
  - Never treat `same_password` as success unless the digest proof holds. The misleading header comment in `ForcedPasswordChangeGate.tsx:43-60` is corrected in PR E. Option A (alternative) is retained only as a documented alternative and would need the same version-checked rpc.
- **D4** `classifyError`: add contexts 'clear-password-change', 'toggle-password-change', 'create-and-assign'; code-based mapping for `weak_password` (register/re-issue/create: distinct code `password_policy_rejected`, owner copy "Couldn't create a temporary password that meets the site's password rules. Try again, or contact support." English, owner-only), 429, and 5xx; never message-text matching.
- **D4a (amended, J-001) `toggle-password-change` is one-way.** `force_change` true calls rpc `require_password_change(user, null)`. `force_change` false returns 422 `{code: 'clear_not_permitted'}` with no write. The client never sends false. Only the student's verified change clears the requirement.
- **D5** Temp password generator (D-P8): alphabet excluding 0 O o 1 l I; length 12; guarantee at least one lower, one upper and one digit (rejection sampling, `crypto.getRandomValues` only); add a symbol class only if the hosted policy requires it (D-P7). Update `adminStudentPasswordGeneration` tests deliberately.
- **D6 (amended)** Owner admin English UI per G13 as replaced in design revision 2 (one-way required row with no control, enable-only modal, focus to `.password-reset-info`, creation and re-issue sentence, temp display nowrap + focusable named scroller).
- **D7 (amended)** Test ripple: inventory `rg -n "'register'|create-and-assign|createUser" src/__tests__ supabase`. Every test or fixture that registers and then signs in as the created student either completes the gate through a loopback helper (for example `completeForcedPasswordChange`) or asserts the gate.
  - The inverted test at `admin-student-operations-password-change-security.test.ts:216-222` can no longer use toggle-off to make an unflagged account. Create via register, complete the gate legitimately, then call clear again and expect `password_change_not_required`.
  - The #137 student2 restore in `browser-validation-status-clarity-and-gate.spec.ts` (parent plan, about `:18-91`) and any loopback restore must set state through rpc `require_password_change` or `clear_password_change` (loopback pg), never a raw `app_metadata` write, so the row and the claim stay consistent. Update that spec's expectations as needed.
  - Update `AdminStudentsPage-issue42-screenComposition.test.tsx:211-215` deliberately: the regex alternation can no longer assert the tier; rewrite it for the one-way Secondary control. Re-run `issue5-phase4-caution-button-relocation.test.ts:139`.
- **RED tests** (live local stack, loopback-guarded, disposable accounts):
  1. (i) register -> `getUserById` `app_metadata.force_password_change === true`; the first password sign-in JWT decodes with `force_password_change` true and `provider`/`providers` preserved; a flagged student's select on `student_enrollments` returns 0 rows (RLS).
  2. (ii) create-and-assign likewise; replay returns `credential_unavailable` and the reused account is flagged.
  3. (iii) clear-password-change with new == temporary -> 422 `same_password`, flag still true.
  4. (iv) success -> flag false, the OLD access token still passes `GET /auth/v1/user`, `refreshSession` yields a JWT with the flag false (Option B session preserved), old password rejected, new accepted.
  5. (v) (amended) a bare clear without a password and a forged or foreign token are rejected (J-001 regression); no path clears the flag without a password change.
  6. (vi) a unit mapping table for `weak_password` reasons, `same_password`, 429, `reauthentication_needed` and unknown with a mocked GoTrue fetch (V1 via mock if the local policy cannot be raised).
  7. (vii) generator: 10,000 samples contain no look-alikes and always include lower, upper and digit.
  8. (viii) the D2 contract scan.
  9. (ix) J-001: owner toggle `force_change:false` returns 422 `clear_not_permitted`, with the flag, row and version unchanged. `force_change:true` sets required with a new version. A source scan finds no `force_change:false` in client code.
  10. (x) J-002 two-connection pg test (the B1 pattern; loopback `127.0.0.1:54322` or the mirror port). Connection A runs `clear_password_change(user, V)` while connection B runs `require_password_change(user, digest2)`; commit in both orders. Assert that if B commits first, A returns false and the final state is `required = true` with version V2 and claim true. Assert that if A commits first, the final state is `required = true` with version V2 (B wins after). Assert there is never a final state with claim false while the row is required. 10 iterations without flake. Plus an Edge-level test: the student PUT succeeds, then an owner re-issue runs before the clear (a deterministic interleave via a local-only test hook or by calling the rpc directly between Edge steps). The clear returns 409 `requirement_changed` and the student remains flagged with the owner's new password.
  11. (xi) J-003 recovery, live without fault injection: call GoTrue `PUT /auth/v1/user` directly with the student's token (simulating step 2 success with a lost step 3), then call the Edge clear with the same new password. Expect 200, flag false, and the new password works. Then a fresh flagged student submitting the temp password gets 422 `same_password`. Then a toggle-on (null digest) student submitting their current password gets 422 `same_password`, and submitting a different one gets 200. Plus a unit test with the rpc failing returns 500 `flag_clear_failed`, after which a retry succeeds.
  12. (xii) migration: rollback parity; EXECUTE grants `service_role` only; the anon/authenticated grant test is extended; the table is unreadable by `authenticated`.
- **Hosted:** the hosted migration apply is a separate approval (D-28) and must precede the `admin-student-operations` Edge deploy, which is also a separate approval. The new response codes are compatible with the current client (old gate re-sign-in still works); the owner toggle-off control is removed by D6.
- Closes the D-P1 issue (or Refs #243 if no new issue is filed); Refs #243.

### PR E: forced-password gate client (#243 C1 client, C3, C4, C5, C7, C8, trigger on gate) plus LoginForm hints

Starts after PR #229, parent Wave 3 PR 3a (#235) and PR 3b (#236, the explicit sign-out marker), parent PR 1b (`.form-error`), and PR D merge.

- Implements the reviewed design handoff G1 to G16 and invariants 1 to 14.
- **Client recovery logic:** after the Edge returns 200, call `refreshSession()` (Option B keeps the session). If it fails, try `signInWithPassword(email, newPassword)` once and check its error. If that fails, enter the `session_not_reestablished` terminal state. Edge 409 `requirement_changed` enters the `requirement_changed` terminal and Edge 401 `session_ended` enters the `session_ended` terminal (G2); neither maps to generic. Never resend to the Edge with a dead token. Fix the `:43-60` comment. If Option A was chosen, go straight to `signInWithPassword`, then terminal.
- **RED tests:** unit tests for copy record completeness EN/ES (including the two new terminal variants); server-body -> kind mapping including unknown -> generic, 409 -> `requirement_changed`, 401 `session_ended` -> `session_ended`, and no message rendering; aria association and focus per state; the persistent status container; each terminal state has no inputs and exactly one primary calling `signOut`; an App test for exactly one trigger after the gate; LoginForm attributes; Show/Hide name and visible text. e2e journeys J1 to J7, J9, J11, J13 and J14 with `page.route` fault injection; credential-rotating journeys use disposable accounts created via register (flagged by PR D).
- Spanish drafts are marked and approval-gated per D-P5. Closes #243.

### Ops F: existing-students backfill (D-P4)

After PR D is deployed; a hosted write needs separate approval. Deliver a reviewed SQL file in the lizbeth repo (for example `scripts/ops/backfill-force-password-change.sql`, NOT `supabase/migrations`, so local resets and schema deploys are unaffected), inside PR D or a small separate PR.

- Read-only preview (the user runs it; query unchanged):
  `select id, email, last_sign_in_at, raw_app_meta_data from auth.users where coalesce(raw_app_meta_data->>'role','') <> 'owner' and not (raw_app_meta_data ? 'force_password_change') and last_sign_in_at is null;`
- Write (option a), revised: `select public.require_password_change(id, null) from auth.users where <same predicate>`. Capture the affected ids first. The backfill goes through the D0 function so the requirement row and the claim stay consistent. It needs the PR D migration applied first and runs as `service_role` (hosted write, separate approval).
- Rollback: `clear_password_change` with the captured versions, or the jsonb removal (`update auth.users set raw_app_meta_data = raw_app_meta_data - 'force_password_change' - 'force_password_change_version' where id = any(<captured ids>)`) plus deletion of the matching `public.password_change_requirements` rows for the captured ids.
- Option (b) drops `last_sign_in_at is null`, which also forces students who signed in but never changed the owner-issued password (Inference: an absent key means the student never passed the gate; after the J-001 revision the owner can no longer clear the requirement, so the only clearing path is the student's verified change). Their current JWT keeps the old claim until refresh (about 1 hour), after which RLS and the gate apply.

## 9. Interfaces and data

- **Edge `admin-student-operations`:** register and create-and-assign now create users with `app_metadata.force_password_change` true. `clear-password-change` response codes gain `weak_password` (with reasons), `same_password`, `rate_limited` (429), `reauthentication_needed`, `flag_clear_failed`. Register, re-issue and create gain `password_policy_rejected`. The Edge also gains codes `session_ended` (401), `requirement_changed` (409), `clear_not_permitted` (422, owner toggle-off) and `flag_clear_failed` (500). Request shapes are unchanged, but `toggle-password-change` with `force_change:false` is now rejected. Option B adds a server-side call to GoTrue `PUT /auth/v1/user` with the caller's token. Flag sets and clears go through the D0 rpc functions, not `updateUserById` `app_metadata`.
- **Client:** new `src/lib/forcedPasswordCopy.ts`; new shared Show/Hide sub-component; `AuthContext` unchanged by this plan beyond consuming #236's marker.
- **DB (revised):** PR D adds a forward migration and rollback: table `public.password_change_requirements` (RLS enabled, no policies, all privileges revoked from `anon` and `authenticated`) and functions `public.require_password_change` and `public.clear_password_change` (`SECURITY DEFINER`, fixed `search_path`, EXECUTE for `service_role` only). RLS policies are unchanged; they keep reading the JWT claim through `user_requires_password_change()`. Hosted migration apply is separately approved and must precede the Edge deploy. Optional ops backfill now calls `require_password_change` (hosted write, separate approval, rollback by captured ids or versions; Ops F).
- **CSS:** `AccessibilitySettings.css` z-index 20 (base and solo `:focus`); `ForcedPasswordChangeGate.css` layout, z 15 and scoped spacing; `RegisterStudentModal.css` temp display nowrap.
- **Compatibility:** PR D's new response codes are compatible with the current gate (old clients render `message`); PR E requires PR D's codes but degrades to generic for unknown codes, except that 409 and 401 map to their own terminals. The owner toggle-off is removed in PR D.

## 10. Executable now versus deferred

- **Executable now (after approval):** Wave 0b `gh` actions; PR A (#244); PR B (#245); PR C once parent PR 2d has merged (check at Step 0).
- **Deferred:** PR D (after #230 and #231; slip fallback D-a), PR E (after #229, parent 3a and 3b, 1b, and PR D), Ops F (after the PR D deploy and D-P4 and D-P7).
- **Order rationale:** independent defect fixes first; the server-side requirement next because it closes the security gap and is backward compatible; the client gate last because it depends on #229's copy pattern, #236's sign-out marker, 1b's `.form-error` and PR D's codes.

## 11. Acceptance and validation

### 11.1 Per PR (all)

Step 0; `npm ci`; `npm run type-check`; `npm run lint` (0 errors); `npm run verify:build`; full `npx vitest run` on a freshly reset local stack with no new failures versus the recorded baseline; targeted specs; a RED test shown failing before and passing after (both runs recorded); Verifier PASS; Browser Validator PASS for UI PRs (A, B, D, E); CODE_REVIEW where routed; PR opened against main with "Closes #N"; no merge.

PR-specific gates are listed in section 8 (A: `elementFromPoint` unfocused and focused, issue-55 5/5, guards; B: guard unit RED, e2e no disclosure; C: closure criteria; D: RED (i) to (viii); E: unit set + J1 to J11 + deterministic scans + Lizbeth ES approval before merge).

### 11.2 Commands

Port-shifted mirror: Windows reserves 54314-54413, so the mirror uses 643xx; the mirror `.env.local` points to `http://127.0.0.1:64321`; per-file copies only, never `robocopy /MIR`; new Edge function files need a full `supabase stop`/`start`.

```text
npx supabase start
npx supabase db reset
docker restart supabase_kong_lizbeth_spanish supabase_rest_lizbeth_spanish supabase_edge_runtime_lizbeth_spanish
npx vite --port 5180 --strictPort
E2E_BASE_URL=http://localhost:5180 npx playwright test
```

The first request after a reset may return 502. Vite is ready when `http://localhost:5180` serves the sign-in page. Playwright uses `testDir` `src/__tests__/e2e`, workers 1, chromium. Exact mirror procedure: `docs/plans/lizbeth-spanish-issue228-create-and-assign.md` section 10.1.

### 11.3 No-native-dialog scan (every UI PR)

`rg -n "\b(window\.)?(alert|confirm|prompt)\s*\(|beforeunload" src --glob "!src/__tests__/**"` must return zero product hits. Each new or changed spec carries a failing `page.on('dialog')` listener. Modal keyboard and focus checks (Escape/Close, focus return) run where Modal is touched.

## 12. Browser UI dialog policy and browser validation inputs

### 12.1 Dialog policy

Required for PRs A, B, D (owner admin UI) and E. No `alert`, `confirm`, `prompt`, `window.alert/confirm/prompt`, or `beforeunload` prompts. Confirmations use the app-owned accessible Modal (`src/components/Modal.tsx`) with Escape/Close and focus return; inline validation is preferred. Verification is the deterministic `rg` scan, a runtime `page.on('dialog')` listener in every new or changed spec, and modal keyboard and focus checks where a modal is touched.

### 12.2 `browser_ui_validation`

**Common (every UI PR):**

- Launch/readiness: in the port-shifted 643xx mirror run `npx supabase start`; `npx supabase db reset`; `docker restart supabase_kong_lizbeth_spanish supabase_rest_lizbeth_spanish supabase_edge_runtime_lizbeth_spanish`; `npx vite --port 5180 --strictPort`. Ready when `http://localhost:5180` serves sign-in.
- Base URL: `http://localhost:5180`.
- Reset: `db reset` + seed + docker restart (the first request may 502).
- Seeded accounts: `owner@test.local`, `student1@test.local`, `fullaccess@test.local` (password "password").
- Credential-rotating journeys (gate, re-issue, toggle) use disposable accounts only: register via the owner API, delete in cleanup, loopback-guarded restore; never mutate student1, student2 or fullaccess.
- Viewports: 1440x900 and 390x844 minimum, 320 wide, forced-colors spot checks.
- Evidence screenshots under `browser-validation-artifacts/<issue>/`.

**PR A:** journey J8 (and the trigger part of issue-55 Location 3). Visible outcomes: the trigger hit-test returns the trigger unfocused and focused on every listed admin page at 1440/390 and in forced-colors; the settings dialog opens; the trigger is inert behind an open Modal; overlays (mobile nav panel, flashcards, vocabulary review) open above it without covered controls.

**PR B:** journey J12. Visible outcomes: success status shown, fields and selects at defaults, Sign out proceeds with no disclosure; re-armed after new input; a failed submit keeps values.

**PR D:** journeys J10 (with the Revision 1 extensions) and J11. Visible outcomes: creation and re-issue outcomes show the first-sign-in sentence; no look-alikes across several generated values; Copy status; 320 horizontal scroll with a focusable named scroller; a new student's row shows required with no control and the not-required row shows the Secondary control and helper; the enable-only modal; after confirm, focus on `.password-reset-info` with a single announcement and the control gone after reload; injected 422 `clear_not_permitted` and a network abort show the fixed message with focus on confirm; no request body contains `force_change:false`; Escape/Close/focus return; a new student's first sign-in shows the gate.

**PR E:** journeys J1 to J7, J9, J11, J13 and J14 with the fault-injection list; viewports add 320x568, 320 at 200% zoom and 320x300; forced-colors on the gate and sign-in. The full journey definitions are in section 6.6.

## 13. Risks and rollback

| Id | Risk | Mitigation and rollback |
|---|---|---|
| R1 | Option B touches the J-001-hardened path (possible bypass). | Amended in Revision 1: the flag is cleared only by the version-checked rpc `clear_password_change`, after GoTrue confirms the change or the digest proves it; `same_password` is never treated as success without the digest proof; the owner clear is removed; RED (iii) to (v), (ix) to (xi); CODE_REVIEW. Rollback: PR revert plus Edge redeploy of the previous version, and the migration rollback file. |
| R2 | Flagging all new students breaks tests and fixtures that sign in as created students. | D7 inventory and the loopback gate-completion helper; full suites. |
| R3 | Hosted policy (and the #2758 admin-create strength check) rejects generated temp passwords. | D-P7 read-only check, generator class coverage, `password_policy_rejected` code. |
| R4 | Hosted `secure_password_change` on yields `reauthentication_needed` for sessions older than 24h. | Maps to generic; D-P7 check; the student can sign out and back in. |
| R5 | Conflicts with open PRs #229/#231, parent 1b and Wave 3. | Sequencing above, never stacked, Step 0 re-verify. |
| R6 | z-index change side effects on overlays and modals. | Layer contract tests, solo focus rule (R-1), J7/J8. Rollback: CSS revert. |
| R7 | The backfill writes hosted `auth.users`. | Preview, captured ids, rollback statement, separate approval, option (a) default. |
| R8 | Spanish drafts inaccurate. | Lizbeth approval before PR E merges. |
| R9 | Adjacent: local `enable_signup = true` (`config.toml:188`, `:233`) lets self-registered users exist without the flag (not owner-created, not enrolled). Hosted setting Unknown. | D-P7 read-only check; recorded, not scheduled. |
| R10 | #218 closure claimed prematurely. | Explicit criteria in PR C. |
| R11 | Stale plan. | Section 14. |
| R12 | The hosted `postgres` role may lack UPDATE on `auth.users`, so the D0 functions could not write the claim. | D-P7 read-only check (`has_table_privilege`); the documented fallback (row as authority, Edge claim mirror with a reconcile loop of at most 2 passes); a stale-plan trigger requiring a plan revision. |
| R13 | Digest storage: the issued-password digest is a credential-derived value. | SHA-256 salted by the version of a roughly 70-bit random temp password; stored only in the `service_role`-only table; never in `app_metadata` or the JWT; nulled on clear. |

## 14. Stale-plan conditions

This plan is stale and must be re-planned (or re-verified at Step 0) if any of these occur:

- `origin/main` moves past `88b43fd` with changes to any cited file.
- PR #229, #230, #231, parent 1b, 3a or 3b merges with changes to cited hunks (`ForcedPasswordChangeGate.*`, `AuthContext.tsx`, the `App.tsx` gate branch, `LoginForm.tsx`, `index.ts`/`onboarding.ts`, `RegisterStudentModal.css`, `AccessibilitySettings.css`, `App.css` focus rules, `FeedbackForm.tsx`).
- An issue body adds acceptance criteria not covered here.
- D-P7 shows a hosted policy or setting that contradicts an assumption.
- The PR A RED run shows a covering element not explained by z-order.
- The hosted `postgres` role cannot UPDATE `auth.users` (D-P7 check), which triggers the D0 fallback and a plan revision.
- The local RED test (x) shows the rpc cannot write `auth.users`.

## 15. Decisions and approvals

### 15.1 Decisions

Each requires an explicit user answer; none carries a silent default.

| Id | Decision | Recommendation |
|---|---|---|
| D-P1 | File a new issue for the server-enforced first-sign-in requirement (PR D closes it; PR E closes #243) versus only commenting on #243. | New issue. |
| D-P2 | `clear-password-change` design: Option B (change the password through the student's own session via GoTrue `PUT /user`, then clear the flag through the version-checked rpc `clear_password_change`; keeps the session, enforces strength, removes the re-sign-in step, and recovers a lost clear on retry through the digest-based `same_password` proof) versus Option A (keep the admin update; client re-signs in; terminal fallback; would need the same version-checked rpc). | B. |
| D-P3 | PR D sequencing: after #230/#231 merge (one PR covering both creation paths) with a split fallback (D-a from main, D-b after #231) if the #231 merge slips more than about one week; alternative: amend PR #231 now. | After-merge with the slip fallback. |
| D-P4 | Existing students: (a) flag never-signed-in students with no flag key; (b) flag every non-owner student with no flag key (forces anyone still on an owner-issued password); (c) none. Hosted write needs separate approval. | (a), with (b) if the owner wants every owner-issued password retired. |
| D-P5 | Gate Spanish: drafts marked; Lizbeth approves before PR E merges (parent D-21 precedent) versus the D-3 precedent (user accepts drafts, optional refinement). | Lizbeth approval before merge. |
| D-P6 | LoginForm autocomplete hints and Show/Hide land in PR E (after #229) rather than widening #229. | PR E. |
| D-P7 | The user runs a read-only hosted check before PR D's Edge deploy: Auth password policy (minimum length, required characters, leaked-password protection), secure password change, public sign-ups enabled, rate limits, and auth service version (whether #2758 is deployed). Revision 1 adds `select has_table_privilege('postgres','auth.users','UPDATE')`. | Yes. |
| D-P8 | Temporary password format: unambiguous alphabet (no 0 O o 1 l I), length 12, guaranteed lower/upper/digit; a symbol only if D-P7 shows it is required. | As stated. |
| D-P9 | #244 layer contract: trigger z 20 (above the focus bump and gate, below all overlays, panels and modals; it sits under mobile nav/flashcards/vocab overlays when they are open). | As specified. |
| D-P10 | #245: reset selections to defaults after a successful submit (versus keeping them as a new clean baseline). | Reset. |
| D-P11 | #218: self-provision disposable students for neo-workbook-visual-smoke, owner-dashboard and issue179c `:394` (`fullaccess` becomes a read-only fixture with an enforced zero-entitlement fingerprint). | Yes. |
| D-P12 | Owner cannot remove the reset requirement (one-way; only the student's verified change clears it); the existing "Remove reset requirement" control is removed. Closes PLAN_DUCK J-001. | Yes. |

### 15.2 Safe assumptions

- Inference items are confirmed by their RED tests.
- GoTrue behavior follows the research packet.
- The hosted project matches local defaults until D-P7 says otherwise.
- The C1 to C8 summaries reflect #243's body (verified in code; issue bodies are read at Step 0).

### 15.3 Approvals required

1. Explicit user approval of this plan. Status: NOT GRANTED. The user stated they will review policy and final approval later.
2. Answers to D-P1 to D-P11.
3. Separate approval for each hosted action (migration apply, which must precede the Edge deploy; Edge deploy; Netlify deploy; ops backfill write) per parent D-28.
4. Lizbeth's approval of the ES drafts before PR E merges.
5. No commit to main, merge, deploy or live Codex smoke call without explicit instruction.

## 16. Engineering mode and downstream owner

- Engineering mode: standard (T1 first-line; two counted T1 gate failures escalate to T2; two counted T2 gate failures block for user review). No extreme-advisory team. Team authorization: not applicable.
- Downstream owner: engineering-fleet (PRs A to E); the orchestrator for Wave 0b `gh` actions after approval; the user for hosted read-only checks (D-P7) and approved hosted writes (Ops F); Scribe for any later plan revisions.
