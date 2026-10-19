# Plan: Admin Student Operations — Combined Fix, Self-Service Account Access, and Error-Contract Remediation

**Status: DRAFT — awaiting explicit user approval.**

- Task ID: `lizbeth-spanish-admin-student-operations-combined`
- Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish`
- Production Supabase project ref: `udrlwexyzaqaqxdxdsml`
- Production site: https://lizbeth-spanish.netlify.app/
- Audience: the solo non-technical owner-operator, and the T1 engineering agent that executes this plan after approval.
- Engineering mode: standard.
- **This is the single authoritative T1 brief for one combined engineering dispatch.** Do not dispatch any of its three workstreams separately.

---

## 1. What is happening, in plain language

Students you create from the admin panel cannot sign in. This is not a delivery problem or a spam-folder problem: the account is created in a state that nothing can ever clear. When you use "Add Student," the code tells Supabase the new account is "not yet confirmed," and it also never sends any confirmation email, because your product's design deliberately does not use email at all — you generate a password on screen and hand it to the student yourself. The result is an account stuck waiting for a confirmation that will never arrive, because nothing was ever supposed to arrive.

Right now, if a student account gets stuck, your only way to fix it is through the Supabase dashboard, a tool built for developers, not for day-to-day account management. This plan also adds an in-app "Account access" panel so you can fix a stuck account, or issue a fresh password, without leaving your own admin screen.

Finally, this plan finishes cleanup work already in progress on a separate, related incident: several places in the same admin code silently swallow real error information, so when something does go wrong, you and the code that talks to it currently cannot tell what happened.

All three pieces are being shipped together, in one reviewed change, verified once and deployed once, rather than as separate patches. There is no urgency forcing a rushed partial fix: you have confirmed no student is currently locked out, since the feature is still in testing.

---

## 2. Decisions already made (not open for discussion)

These were confirmed by you on 2026-08-05 and are treated as settled facts for this plan, not choices for the engineering agent to revisit:

- **No hotfix.** A proper, complete fix — no workarounds.
- **No urgency pressure.** No students are currently locked out (still in testing), which is exactly why the combined, more thorough route is the right one instead of a fast partial one.
- **One combined dispatch.** This plan is the single authoritative brief for one T1 engineering job, not two layered patches.
- **The backfill dry-run approval gate stays.** Any repair of already-affected accounts requires you to see and approve the exact list first.

---

## 3. Reconciliation: how this plan relates to the other two plans

| Workstream | What it does | Source of the detailed requirements | Who executes it | Status of the source plan |
|---|---|---|---|---|
| **WS-A** — root-cause fix | Change new admin-created accounts to be created already confirmed, so students can sign in immediately; repair (with your approval) any accounts already stuck. | `docs/plans/lizbeth-spanish-admin-created-student-email-confirmation.md` | This combined plan (Stage 1, Stage 4) | **Superseded by this plan.** Kept only as the root-cause record; must not be dispatched on its own. |
| **WS-B** — new feature | New "Account access" controls on the student detail screen: mark an account's email confirmed, and issue a fresh temporary password. | This plan only (new work, not in either prior plan) | This combined plan (Stage 3) | Not applicable — originates here. |
| **WS-C** — error-contract and defect sweep | Fix the Edge Function so real errors are classified and surfaced instead of collapsed into a generic 500; fix silent-failure defects RF-20 and RF-22; wire up an orphaned error message. | `docs/plans/lizbeth-spanish-admin-student-operations-prod-500.md` | This combined plan (Stage 1, Stage 2), referencing that plan's per-site detail | **Remains active and NOT superseded.** It stays intact as the detailed reference record for WS-C's full fifteen-site sweep, its redaction rule, and its deploy-authorization rule. This combined plan does not restate all of that detail; read the 500 plan alongside this one for WS-C's per-site specifics. |

If anything in this plan appears to conflict with the 500 plan on a WS-C detail not restated here, the 500 plan's detail controls, since it remains the authoritative per-site reference. This plan controls the overall sequencing, scope boundary, and the fact that everything ships together.

---

## 4. Outcome and audience

**Outcome:** one coherent change to the admin student management area that:

1. Makes admin-created students able to sign in immediately (WS-A).
2. Gives you a self-service control to diagnose and fix a stuck student account without the Supabase dashboard (WS-B).
3. Completes the confirmed error-contract and error-surfacing remediation already in flight on the related 500 incident (WS-C).

Shipped as a single reviewed diff, verified once, and deployed once.

**Audience:** you, the solo owner-operator, and the T1 engineering agent that executes this plan after your approval.

---

## 5. Scope

### In scope — three workstreams, one dispatch

- **WS-A (root-cause fix).** New admin-created students are marked confirmed at creation. An approval-gated, one-time repair (backfill) of any accounts already stuck in the broken state.
- **WS-B (new feature).** Owner-facing "Account access" controls on the student detail screen: mark an account's email confirmed, and re-issue (regenerate) a student's temporary password.
- **WS-C (absorbed from the in-flight 500 plan).** The Edge Function error-contract sweep across all fifteen 500-returning sites, client-side recovery of real error bodies, redaction of sensitive detail before it reaches the operator, a focus-management fix, and two known silent-failure defects (RF-20, RF-22).

### Explicitly out of scope (non-goals)

- Custom SMTP.
- `inviteUserByEmail` or `resetPasswordForEmail` (email-based invite/reset flows).
- Disabling "Confirm email" in the Supabase dashboard.
- A student-facing self-service password reset.
- Bulk or multi-student actions.
- Forced password rotation on first login.
- Any deploy or production data write without a separate, explicit per-step approval at execution time.
- Closing gate G14.5 (referenced by the 500 plan; not addressed here).

### No-touch boundary observed during planning

All planning work was read-only. No file in the target repository was modified while producing this plan.

---

## 6. Root cause and supporting evidence

### WS-A root cause

- **RC-1 (confirmed root cause).** `supabase/functions/admin-student-operations/index.ts`, lines 173-205, function `handleRegisterStudent`, calls `serviceClient.auth.admin.createUser({ email, password: tempPassword, email_confirm: false })`. The inline comment at line 184, "Let user set their own password on first login," is factually wrong about what this setting does.
- **RC-2.** The Supabase Admin API's `createUser` call sends no email under any setting. With `email_confirm: false`, the account's confirmation timestamp is left empty, and nothing in the codebase ever calls the functions that would send a confirmation email (`inviteUserByEmail`, `generateLink`, `resetPasswordForEmail` appear nowhere). This is precisely why no confirmation email reaches a new student: none is ever sent.
- **RC-3.** Production has "Confirm email" enabled, so an unconfirmed student's sign-in attempt is rejected with "Email not confirmed" (error code `email_not_confirmed`).
- **RC-4 (why this was never caught by tests).** The local development configuration (`supabase/config.toml`) disables confirmation checks entirely and leaves email sending unconfigured. Locally, an unconfirmed account can sign in without issue — this is a pure local-versus-production gap, not a case anyone missed.
- **RC-5.** Your onboarding is deliberately email-free by design: a temporary password is generated on the server, shown once on screen ("Account Created"), and you share it with the student directly. `email_confirm: false` is simply inconsistent with a design that already ships this way.
- **RC-6.** The "Add Student" screen currently tells you the student will "set their own password on first login." No such flow exists anywhere in the codebase. This copy will be corrected as part of this plan (design item 2 below).

### WS-C supporting defects (client-side error handling)

- **RC-7.** `src/services/adminStudentData.ts`'s `registerStudent()` only reads the real error body on a code path that the installed Supabase client library never actually takes for a non-2xx response — so that branch is dead code, and the operator always sees a hardcoded generic message ("Edge Function returned a non-2xx status code") no matter what actually went wrong on the server. The real response body is available but unread.
- **RC-8.** `src/context/AuthContext.tsx` passes the raw Supabase authentication error string straight through to the student-facing login screen, which is why a failed sign-in currently could leak internal wording instead of showing plain, safe copy.
- **RC-9 (security constraint).** The project's local configuration has public self-registration enabled. This is the reason a tempting-looking shortcut — disabling "Confirm email" globally — is rejected below in section 12, Decision 1.

### WS-B supporting evidence (new feature, confirmed by inspection)

- **RC-10.** Neither the roster-listing handler nor the student-detail handler currently returns any email-confirmation information. The existing "account status" indicator (active/disabled/pending) is a genuinely separate concept from confirmation status — a confirmation field must be added as new information, not inferred from what exists today.
- **RC-11 (security-critical, informs the mount-invariant requirement in section 9).** The codebase's own comments document a previously-shipped defect ("Defect B"): the registration modal that reveals a one-time password had to be moved to a screen position that survives a background data refresh, because an earlier version of that refresh silently discarded an already-generated one-time password mid-flow. The per-student action modals used elsewhere on this screen do not have this special placement, and their existing pattern (refresh the student's data right after an action succeeds) is exactly the pattern that caused the earlier defect. The new "re-issue password" feature in this plan creates a second one-time-secret modal and must use the same safe placement as the first one, not the ordinary pattern.
- **RC-12 (pre-existing defect, fixed opportunistically).** The existing "Account Created" reveal screen sets an error state when copying the password to the clipboard fails, but nothing on screen currently displays that error — a copy failure today produces no visible feedback at all.
- **RC-13 (pre-existing type gap).** The student-detail data type is missing an account-status value used elsewhere in the code (`'pending_first_login'`); this plan does not change account-status logic but the type gap should be closed as part of this touch.

### Research evidence

Two nested research evidence packets, grounded in the official Supabase Auth server (GoTrue) source code and official documentation, retrieved 2026-08-04 and 2026-08-05:

- Both the "create user" and "update user" admin operations map the confirmation setting to the identical server action: setting it to true marks the account confirmed. Neither operation sends any email.
- **Critical hazard, directly informs AC23 below.** Marking an already-confirmed account confirmed again is not a safe no-op on the server: it unconditionally overwrites the original confirmation timestamp and invalidates any of that student's outstanding one-time tokens (for example, an in-progress password-reset link, if one ever existed). There is no built-in guard against re-confirming an already-confirmed account. The server-side code this plan adds must check first and skip the action if the account is already confirmed.
- The sign-in rejection for an unconfirmed account is driven by a specific error code, not by matching text in the error message. Any error-copy logic this plan adds must match on that code, never on message text.
- Regenerating a student's password via the admin "update user" operation sends no email and does **not** end that student's existing sign-in sessions elsewhere. Unlike disabling an account, it does not force a currently-signed-in student to be signed out.
- Retrieving a one-time action link server-side (an alternative considered for WS-B and rejected below) does not itself send email and does not confirm the account.
- Inviting a user by email or sending a password-reset email would work, but both require configured outbound email (SMTP), which this project does not have; the built-in fallback is explicitly non-production-grade (roughly two emails per hour, best-effort, no guarantee).
- There is no supported administrative action that signs a specific student out of all their existing sessions by account ID; the only lever available today for that purpose is the existing disable/enable (ban) mechanism.

**Researcher-flagged unknowns (unverified, dashboard-only or environment-only):** the hosted project's actual "Confirm email" setting (assumed on, inferred from the symptom — see Assumptions, section 12), its outbound-email configuration, and its one-time-code expiry window are all Supabase dashboard settings not visible from the repository. Undocumented rate limits may apply to hosted admin operations. Source code read from the current released version of the Supabase Auth server may drift from what is actually deployed on the hosted project.

---

## 7. Design: error-state copy and behavior (compact scope)

This design work was independently reviewed and passed after one revision. The reviewer found one critical defect (RC-7, the dead error-reading code path) plus three smaller issues; all four were fixed and the revised design passed re-review.

**Item 1 — sign-in error messages.** Replace the current "pass the raw error straight through" logic in `AuthContext.tsx` with a lookup keyed on the error's code, never its text:
  - Unconfirmed account: "We can't sign you in yet. Please contact your instructor to activate your account." (This copy must never contain the words email, confirm, verify, or inbox — it should not point the student toward an email step that does not exist.)
  - Wrong email or password: "That email or password isn't right. Please try again." (This exact copy is used regardless of whether the account exists, so a wrong-password attempt cannot be used to discover which emails have accounts.)
  - Anything else: "We couldn't sign you in. Please try again, or contact your instructor if this continues."
  - The on-screen alert element and its placement are unchanged. Sign-in failure must not move keyboard focus.

**Item 2 — corrected "Account Created" reveal copy**, replacing the current inaccurate "set their own password" text: "**Important:** This account is ready to use right now. Share this password with the student through a secure channel — it will not be shown again after you close this window. The student can sign in immediately with their email and this password."

**Item 3 — duplicate-email handling when adding a student**, three coordinated parts:
  - **3a.** The service function that calls the registration Edge Function must actually read the real error body the server sends back on failure (fixing RC-7, the dead-code path), rather than always showing the generic hardcoded message.
  - **3b.** A duplicate email address must produce a specific, structured "this email is already registered" response instead of the current generic server error, so the interface can tell this case apart from any other failure.
  - **3c.** Only two specific failures — an empty email field, and a duplicate email — move keyboard focus to the email field, select its contents, and mark it as invalid for assistive technology. Any other kind of failure shows a visible error message but does **not** move focus or mark any field invalid. Duplicate-email copy: "An account already exists for this email address. Check the students list, or use a different email address."
  - A temporary, interim way of detecting "this is specifically a duplicate-email error" (rather than a more reliable, permanent server-side signal) must be confirmed against real local test output before this code is considered final — it must not ship as a guess.

---

## 8. Design: "Account access" panel (standard scope, new feature)

This design work was independently reviewed and passed after one revision. The reviewer found one high-severity defect (the Defect B recurrence risk described in RC-11 above) plus four smaller issues; all five were fixed and the revised design passed re-review, with the fix independently confirmed to reuse the exact placement pattern already proven safe elsewhere on the same screen for the identical hazard.

### Placement

A new "Account access" section on the student detail screen, positioned between the existing student-info header and the existing enrollments list, and kept structurally separate from the existing "Delete student" controls. It contains two rows.

### Row 1 — email confirmation status

- **This row and its button always appear**, for every account status including a disabled account. The button's *only* condition for being unavailable is that the account is already confirmed — never based on whether the account is active or disabled. (Confirming a disabled account's email is harmless and does not lift the disable; it simply removes the separate confirmation block if the account is later re-enabled.)
- Unconfirmed: "Not confirmed" / "This student may not be able to sign in until this is fixed." / button "Mark email confirmed."
- Confirmed: "Confirmed" / "Already confirmed. No action needed." / no active button.
- Confirming opens a plain, dismissible confirmation dialog (not a type-to-confirm dialog): "Mark {email} as confirmed?" / "This clears the block that's stopping this student from signing in. It can't be undone, and once confirmed you won't be able to run this again for this student." / buttons "Mark Confirmed" (working state: "Confirming…") and "Cancel." / failure message: "Couldn't mark this email confirmed. Try again." / race-condition message if it was already confirmed by the time the request runs: "This email is already confirmed."

### Row 2 — re-issue access

- "If this student forgot their password or never got it, generate a new one here." / button "Re-issue access" (visually a step below the destructive "Delete student" button, but a step above a plain default button, to signal caution without alarm).
- Confirming opens a plain dialog: "Generate a new temporary password for {email}?" with three bullet points:
  - "Their current password will stop working right away."
  - "If they're already signed in somewhere, that won't change — this doesn't sign them out."
  - "You'll need to share the new password with them yourself. Nothing is sent automatically."
  - Buttons "Re-issue Access" (working state: "Re-issuing…") and "Cancel." / failure message: "Couldn't generate a new password. Try again."
- On success, a "New Password Ready" reveal screen, structurally identical to the existing "Account Created" reveal: student's email, the new temporary password, a "Copy" button, a copy-success confirmation, a **visible** message if the copy fails ("Couldn't copy automatically. Select the password above and copy it manually." — this also fixes RC-12's missing feedback, applied at both places this reveal pattern is used), explanatory text ("Share this password with the student one time only. It replaces their old password immediately. This password will not be shown again."), and a "Done" button.
- No copy anywhere in this feature mentions a confirmation email, an invite email, an inbox, or any Supabase/GoTrue terminology. All language stays in plain, owner-facing terms.

### Critical placement requirement (Defect B recurrence prevention)

The re-issue password dialog, in both its confirmation phase and its password-reveal phase, **must** be placed at the same stable screen position already used for the existing "Add Student" reveal — a position that does not get torn down when the page refreshes its data in the background. It must **not** be placed inside the ordinary per-student action area used by the other student-detail buttons, because that area's existing pattern (refresh data immediately after a successful action) is the exact pattern that caused the previously-shipped "Defect B," and would discard the one-time password the same way. As a secondary safety measure, any background data refresh triggered by this feature should be deferred until after the operator closes the reveal screen — but this deferral is a backup, not a substitute for the correct placement.

The "mark confirmed" dialog does not carry a one-time secret and does not need this special placement; it can safely use the ordinary per-student action pattern already used elsewhere on this screen.

### Visual treatment

Both new status rows must use text-plus-icon indicators, never color alone, and must use a high-contrast ink-on-tinted-background treatment rather than a bare colored icon — a bare colored icon on white background was checked and found to fail accessible contrast requirements in this design system, while the ink-on-tint combination passes with a wide margin. The three-bullet warning list for re-issuing access is a plain bulleted list, not a bordered/tinted warning callout — it should read as informational, not alarming.

### Accessibility requirements

- Status indicators are never color-only.
- A disabled "Mark email confirmed" button (once already confirmed) must be a genuinely disabled control, not just visually dimmed — it must be removed from keyboard tab order.
- The re-issue reveal screen cannot be dismissed by clicking outside it or pressing Escape (matching the existing "Account Created" reveal's behavior, since it displays a one-time secret); the two plain confirmation dialogs can be dismissed with Escape.
- "Cancel" appears before the confirming action in both dialogs' layout.
- The panel must remain usable and readable at a narrow phone width and at high browser zoom, with no horizontal scrolling.
- After a successful "mark confirmed," keyboard focus must be explicitly moved to the updated status text (this must be done deliberately in code; it will not happen automatically). After the re-issue reveal's "Done," keyboard focus must be explicitly returned to the "Re-issue access" button that opened it — this specific transition needs deliberate handling because a button that becomes temporarily unavailable during the "working" state does not reliably keep focus tracking automatically.

### Backend requirements

- Both the student-list and the student-detail data the server sends to the browser must be extended with a new confirmation-status field. This is a pure addition; nothing existing changes shape.
- "Mark confirmed" must, on the server, check that the account is not already confirmed before proceeding, and skip the action if it is (see the "critical hazard" in section 6 — the client-side disabled button is not sufficient protection on its own).
- "Re-issue access" must use the admin password-update operation only; it must not touch the confirmation flag.
- Both new server actions must use the same "must be the account owner" check, the same input validation, and the same error-classification approach as the existing admin actions in this same code, and must be included in the WS-C classification sweep described in Stage 1 below.

### Secret handling

The one-time password shown on the reveal screen must never be written to a log, echoed inside any error message, or kept in the application's memory state after the operator closes the reveal — matching exactly how the existing "Account Created" reveal already behaves.

### Recommended (not required) implementation approach

Because the "Account Created" reveal and the new "New Password Ready" reveal are functionally identical one-time-secret displays, it is recommended that the engineering agent extract the existing reveal into one shared piece of code reused by both, rather than writing it twice — reducing the risk that a future change fixes one copy and not the other. If this extraction is done, it must also fix RC-12 (the missing visible copy-failure message) in both places at once.

### One remaining open design decision

Both design passes above leave exactly one decision unresolved, and it needs your confirmation before or during implementation (see section 12's open decision).

---

## 9. Ordered work

One dispatch, four sequenced stages. WS-C's full per-site technical detail is not repeated here in full; the engineering agent should read `docs/plans/lizbeth-spanish-admin-student-operations-prod-500.md` alongside this plan for that detail.

### Stage 1 — foundation, test-first

1.1. **(WS-A)** Change the new-account creation call from "not confirmed" to "confirmed." Remove the incorrect comment and replace it with an accurate one explaining that admin-created accounts are intentionally pre-confirmed because onboarding is deliberately email-free and credentials are shared directly by the admin.

1.2. **(WS-A)** Add a test asserting the account-creation call is made with the "confirmed" setting. This is the single most important test in this plan — it is the safeguard against this exact bug silently coming back, and unlike a sign-in test it works correctly even in the local environment where confirmation checks are disabled.

1.3. **(WS-C)** Complete the error-contract sweep across all fifteen error-returning sites in the admin Edge Function per the 500 plan's detailed sweep requirements, classifying each one as either "stays a generic server error" or "becomes a specific, readable error." Include the duplicate-email case from design item 3b above as one of these fifteen sites. Any duplicate-account detection must be based on the actual database conflict, never by matching text in an error message.

1.4. **(WS-C, defect RF-20)** The disable, enable, and delete admin actions must check the result returned by the Supabase Admin API and report failure when it fails. Today a failed operation is incorrectly reported to the operator as successful.

1.5. **(WS-C, defect RF-22)** The roster-listing handler must not silently drop a student from the list when that student's enrollment lookup fails; it must surface the failure instead of quietly omitting the student.

### Stage 2 — client error plumbing and copy

2.1. **(WS-C / design item 3a)** Fix `registerStudent()` to actually read the real error body on failure. Apply the equivalent fix to the other admin-student operations, per the 500 plan's scope for this fix.

2.2. **(WS-C)** Build the redaction step that decides what error detail is safe to show the operator, with required automated tests, defaulting to withholding information unless it is confirmed safe, and always allowing a known account-ID format through unredacted.

2.3. Design item 1: the sign-in error-message lookup described above.

2.4. Design item 2: the corrected "Account Created" reveal copy.

2.5. Design item 3c: the field-level error/focus scoping described above.

2.6. **(WS-C)** Wire up the existing but currently-unused error-display element in the "re-enable student" action, which today has no error handling at all and fails silently.

### Stage 3 — new "Account access" feature (WS-B)

3.1. Add the confirmation-status field to both the student-list and student-detail server responses.

3.2. Add the "confirm email" server action, including the mandatory "skip if already confirmed" check.

3.3. Add the "re-issue access" server action using the password-update operation only. Both new actions must follow the same authorization, validation, and error-classification conventions as the existing actions, and must be included in Stage 1's classification sweep.

3.4. Add the corresponding front-end data types, the two new service functions, and the two new modal states.

3.5. Build the "Account access" section, its two dialogs, and the re-issue reveal at the required stable screen placement described in section 8.

3.6. If the shared-reveal extraction (section 8, recommended approach) is done, apply the RC-12 fix at both usage sites.

3.7. Add tests for every new state, for the critical placement requirement (a background refresh must not discard the revealed password), and for the secret-clearing behavior.

### Stage 4 — verification and release

4.1. **Local verification gate (hard gate).** Linting, type-checking, a full build, the full automated test suite, end-to-end browser tests, and a real local run of the Edge Function, per the 500 plan's local-gate requirements.

   **Important caveat to keep in view:** because the local environment disables confirmation checks entirely, a successful local sign-in test does **not** prove WS-A actually works — it would "pass" even with the old broken code. The test suite must instead directly check that a newly created account's confirmation timestamp is set, and that the creation call itself uses the corrected setting (from 1.2). A local sign-in succeeding is never acceptable as proof that this fix works.

4.2. **Backfill dry run (read-only).** Produce the exact list of existing accounts that are still unconfirmed — account ID and email only, no changes made. This list must exclude your own account (`rob.hasselbach@gmail.com`) and the reserved smoke-test account (`rob.hasselbach+smoke@gmail.com`).

4.3. **Backfill execution — requires your separate, explicit approval of that exact list before it runs.** Only the accounts on the approved list are touched, using the server-side "confirmed" update, one at a time, with results recorded. You have confirmed no student is currently locked out, so this list may well be empty or limited to test accounts; if it is empty, that is recorded and this step is skipped.

4.4. **Independent Verifier pass** (required, separate from the engineering agent).

4.5. **Browser Validator pass** (required — see section 11 below).

4.6. **Production deploy of the Edge Function — requires your separate, explicit go-ahead at execution time**, after 4.1, 4.4, and 4.5 have all passed, following the 500 plan's authoritative deploy-authorization rule.

4.7. **Post-deploy production check.** Create one throwaway test student, confirm sign-in works immediately with the temporary password and no email step is needed, try the "mark confirmed" and "re-issue access" controls once each, then remove the throwaway account. If anything looks wrong at this stage, the correct response is to roll back the deploy (redeploy the last known-good version), not to attempt a live fix in production.

---

## 10. What changes, technically (interfaces and data)

- The student-registration server action changes its duplicate-email response from a generic server error to a specific, structured "already registered" response. The success response when a student is created successfully does not change.
- The student-list and student-detail server responses each gain one new field describing confirmation status. This is a pure addition — nothing that reads these responses today will break.
- Two new server actions are added ("confirm email" and "re-issue access"). "Re-issue access" returns a one-time temporary password in the same shape as the existing student-registration response.
- The existing (currently unused) structured-error-detail capability on the client side becomes reachable for the first time.
- **Data changes:** an account's confirmation timestamp moves from empty to set, for new accounts going forward and for the approved backfill list. A student's stored password is replaced when "re-issue access" is used. No database schema change. No application data table is touched. No change to local development configuration is required or proposed by this plan — the local "confirmations disabled" setting stays as-is; it is not the thing being fixed.

---

## 11. How this will be verified before you're asked to approve a deploy

All original acceptance checks from the in-flight 500 plan (covering the fifteen-site sweep, redaction, and RF-20/RF-22) carry forward unchanged and apply here. This plan adds the following checks specific to WS-A and WS-B:

- A newly created student's confirmation timestamp is set immediately, and the account-creation call is proven (by direct test, not by a sign-in attempt) to use the corrected setting.
- "Mark confirmed" is proven, by test, to refuse to act a second time on an already-confirmed account — the button being disabled in the interface is not treated as sufficient proof on its own.
- "Re-issue access" is proven, by test, to invalidate the old password and activate the new one.
- The re-issue password reveal is proven to survive a background data refresh that happens between the request succeeding and the operator clicking "Done" — this is a direct regression test for the previously-shipped "Defect B," and it must fail if the reveal is placed anywhere other than the required stable position.
- No revealed password appears in any log, error message, or leftover on-screen/in-memory state after "Done" is clicked.
- A disabled-and-unconfirmed account's status row looks identical to an active-and-unconfirmed account's status row (confirming the button never hides based on disabled status).
- A clipboard-copy failure produces a visible message at both places the password-reveal screen is used.
- A generic (non-field-specific) registration failure shows a visible message without marking the email field invalid and without moving keyboard focus.
- Exact wording is checked for all three sign-in error variants and the corrected reveal copy, and the actual error-code behavior observed is recorded rather than assumed.
- A source-level scan confirms no native browser popup (`alert`, `confirm`, `prompt`, or a "leaving this page" browser prompt) exists anywhere in the changed files.

### Browser UI dialog policy (required)

No native browser dialogs anywhere in this feature: no `alert`, `confirm`, `prompt`, or "are you sure you want to leave" browser prompts. Every confirmation and acknowledgement in this feature uses the app's own existing accessible dialog component; all inline validation uses the app's existing inline-alert pattern. Keyboard and focus behavior must be checked for every new control, including the two explicit focus-management requirements called out in section 8.

### Browser validation brief

- **Launch and readiness:** the existing local development server, plus the local Supabase stack with the Edge Function served locally; ready once the dev server responds and the function is reachable.
- **Base URL and routes:** the local dev server's existing student sign-in page and existing admin students/detail pages. No new page routes are introduced.
- **Test data and reset:** the existing seeded local test-student accounts for sign-in checks; the "Add Student" flow for registration checks; register one test email once, then attempt it again to trigger the duplicate-email case; a test double or fixture account is needed for the "unconfirmed account tries to sign in" case, since the local environment does not naturally produce unconfirmed accounts.
- **Journeys to check:** wrong password; unconfirmed account trying to sign in; successful registration with the corrected reveal copy; duplicate email during registration; a generic non-field registration failure; mark-confirmed success; an already-confirmed account rendering correctly from page load; a mark-confirmed server error; a disabled-and-unconfirmed account rendering the same as active-and-unconfirmed; the full re-issue flow through to "Done" with focus correctly returned; the background-refresh-survives-the-reveal case; a clipboard-copy failure showing visible feedback; a re-issue server error that never reaches the reveal screen; and a full keyboard-only pass confirming tab order, that Escape closes the two plain dialogs, and that Escape does **not** close either password-reveal screen.
- **Screen sizes:** roughly phone-narrow, tablet, and desktop widths, plus a narrow 320px-wide check and a 400%-zoomed check, confirming no horizontal scrolling appears.
- **What "correct" looks like:** exact wording matches this plan's copy for every state; status is never shown by color alone; the "mark confirmed" button is genuinely unclickable (not merely faded) once already confirmed; "re-issue access" is always clickable; the warning bullets read as plain information, not an alarm; the new reveal screen looks and behaves like the existing "Account Created" screen; every new control shows a visible focus outline; no errors appear in the browser console; no password is ever left visible or retrievable after "Done"; no native browser popup appears at any point.

---

## 12. Risks, and what protects against each one

Everything from the in-flight 500 plan's risk list (secret leakage through the new error surface, over-redaction, a silently-failing focus fix, and others) carries forward unchanged and applies here. This plan adds the following:

**Risk A — the backfill cannot be cleanly undone (high severity).** There is no supported way to reverse "mark confirmed" through the same tool used to set it; undoing it would require direct database access. **Protection:** the dry run in step 4.2 shows you the exact list before anything changes; you approve that exact list; nothing outside that list is touched; your own account and the smoke-test account are excluded by name; every result is recorded. A blanket "confirm everyone unconfirmed" action is never run.

**Risk B — issuing a new password is a real credential-minting action (high severity).** Re-issuing access immediately invalidates a student's current password, but does not sign them out of any device where they're already signed in — so a student already logged in elsewhere stays logged in on a password that no longer works, which could be confusing. **Protection:** the dialog copy states this plainly, as written in section 8. There is currently no supported way to force sign-out by account; if that is ever needed, the only existing lever is the disable/enable control. This is recorded here, not solved by this plan.

**Risk C — re-confirming an already-confirmed account has a real side effect on the server (high severity).** It's not a harmless no-op: doing it a second time overwrites the original confirmation record and cancels any of that student's outstanding one-time codes. **Protection:** the mandatory server-side check in section 8 and 9 (verified by a dedicated test) is the only acceptable protection. The interface disabling the button is a nice-to-have, not the actual safeguard.

**Risk D — recurrence of the previously-shipped "Defect B" (high severity).** Placing the new password-reveal dialog anywhere other than the required stable position would silently discard the one-time password exactly as the previous defect did. **Protection:** the mandatory placement requirement in section 8, verified by a dedicated regression test (section 11). This is the single most important implementation detail in the new feature.

**Risk E — admin-created accounts' email addresses are never actually verified (medium severity, knowingly accepted).** Because confirmation is being set automatically rather than through a real email-verification step, a mistyped address results in a confirmed account nobody actually controls, and since no email is ever sent, nobody is notified of the mistake. This is not a new risk introduced by this plan — the account was already being created at whatever address was typed in; this plan only makes that account usable. The duplicate-email detection and clearer validation copy help you notice a mistake. This risk should be accepted knowingly, not overlooked.

**Risk F — a temporary password, once shared, stays valid indefinitely (medium severity).** There is no first-login forced password change, because no such flow exists. This plan makes it possible for you to rotate a password on request, but rotation is still something you have to initiate. A follow-up improvement, out of scope here.

**Risk G — local testing cannot fully reproduce the original bug (medium severity).** Because the local environment disables confirmation checks, a local sign-in success is necessary but never sufficient proof. **Protection:** the tests check the actual confirmation timestamp and the actual call arguments directly (see section 11), and the post-deploy production check in step 4.7 is the only true end-to-end proof.

**Risk H — this is now a large combined change (medium severity).** A single diff spanning the Edge Function, the data-service layer, the sign-in logic, and the admin interface. **Protection:** the four-stage sequencing above, tests written before each piece of work, a recommended independent cross-vendor code review checkpoint (section 13), and the fact that nothing is currently broken for real students, so there is no reason to rush. If the change proves too large to review well in practice, the right response is to split it at a stage boundary and bring it back for approval, not to skip a verification step.

**Risk I — the sign-in error code this plan relies on depends on a request header the client library sends (low severity).** If that header is absent for any reason, all sign-in failures fall back to the safe generic message rather than the more specific ones. This is not a blocking issue; the plan requires recording which case actually happens during verification, and it must never be worked around by guessing at error text instead.

**Rollback:** all code changes can be reverted through normal version control; the Edge Function itself is rolled back by redeploying its last known-good version. The backfill (step 4.3) does not roll back through this same mechanism — see Risk A.

---

## 13. Independent review

An independent cross-vendor plan review is recommended before you approve this plan, given its combined scope, its touch on the authentication boundary, an irreversible production data change (the backfill), and a new feature that mints real credentials. This would run in an advisory capacity, not a blocking one, and is capped at two review calls.

A second independent code review is recommended at engineering time, given the sensitivity of the error-redaction work in WS-C and the secret-handling requirements in WS-B.

Note that the in-flight 500 plan already went through its own independent plan review, with five findings, all of which were addressed (see that plan for the full record). This new review, if run, would cover only the newly combined WS-A and WS-B material, not repeat that earlier review.

---

## 14. Decisions and assumptions

**Decision 1 — how WS-A is fixed.** Recommended and adopted: mark new accounts confirmed at creation. **Rejected alternative — switch to email-based invitations.** This would discard the already-working, already-tested password-reveal flow, requires outbound email that this project does not have (the built-in fallback is roughly two emails per hour, best-effort, with no guarantee — not production-grade), and would be enough of a product-direction change to need its own separate plan. **Rejected on security grounds — disable "Confirm email" globally in the dashboard.** This would make the symptom disappear with no code change at all, which is exactly why it looks tempting. It is rejected because the project's local configuration also has public self-registration enabled (RC-9); if the hosted project has the same setting, turning off confirmation project-wide could let anyone register an account for an email address they don't actually control. It would weaken a project-wide protection to fix one specific admin-created-account path.

**Decision 2 — how WS-B re-issues a password.** Recommended and adopted: the direct password-update action described in section 8. It requires no outbound email, matches the existing trust model exactly (admin creates and shares credentials directly), and reuses an interface pattern already proven safe. **A genuinely viable alternative exists and is recorded here in case you'd prefer it:** generating a one-time action link instead. This also sends no email, but it hands the operator a bearer link rather than a password, its expiry is a dashboard setting nobody has checked, and it would need a different kind of reveal screen. If you'd rather use this approach, say so at approval time — it would change this feature's interface and copy, but not this plan's overall structure.

**Decision 3 — sequencing.** Resolved by you: one combined dispatch. This document is the single authoritative brief. `docs/plans/lizbeth-spanish-admin-student-operations-prod-500.md` remains the detailed reference for WS-C's full per-site sweep, its redaction rule, and its deploy-authorization rule, and is **not** superseded. `docs/plans/lizbeth-spanish-admin-created-student-email-confirmation.md` **is** superseded by this plan and must not be dispatched on its own.

### One open design decision requiring your confirmation

Section 7 (WS-C) assumes that real, if carefully filtered, server error detail should keep reaching you on admin-facing error screens, because that is what makes a future failure diagnosable. Section 8 (WS-B) assumes the two new feature's own failure messages should always be plain, hardcoded, non-technical language, because you are not a technical user and internal error terminology would not help you.

These are not actually in conflict — one is about admin diagnostic screens, the other is about two specific new plain-language feature failures — but the line between them has not been drawn for you explicitly before now. **Recommendation:** keep real, filtered server detail on the existing admin error surfaces per WS-C's rule, and use the plain hardcoded messages written in section 8 for the two new WS-B failures specifically, with the real underlying message kept available in the background (for later diagnosis) but not shown by default. This needs your confirmation, either at approval or during implementation.

### Assumptions

The hosted (production) project has "Confirm email" turned on. This is inferred from the symptom you reported, which matches exactly what that setting produces, but it has not been checked directly. **Recommended:** confirm this in the Supabase dashboard under Authentication > Providers > Email before or during implementation — this is a zero-risk, read-only check.

### Approvals still required

1. Your approval of this combined plan.
2. Your confirmation of the one open design decision above.
3. Your explicit approval of the exact backfill list before step 4.3 runs.
4. Your separate, explicit go-ahead for the production deploy in step 4.6.

### Execution note

T1 remains the engineer of record, under its normal test-first process and full quality review. No accommodation to that process is required by this plan.

---

## 15. Status

**DRAFT.** Awaiting your explicit approval of this plan, your confirmation of the one open design decision in section 14, and, at the appropriate later steps, your separate approvals for the backfill list (step 4.3) and the production deploy (step 4.6).
