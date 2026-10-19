# Plan: Admin-Created Student Accounts Cannot Confirm Their Email

> **SUPERSEDED.** This plan is superseded by `docs/plans/lizbeth-spanish-admin-student-operations-combined.md`. Its content is retained only as the root-cause record for this incident and must **not** be dispatched independently. All execution, including this plan's original fix and backfill, is authorized only through the combined plan above.

**Status: DRAFT — awaiting explicit user approval.**

- Task ID: `lizbeth-spanish-admin-created-student-email-confirmation`
- Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish`
- Production Supabase project ref: `udrlwexyzaqaqxdxdsml`
- Production site: https://lizbeth-spanish.netlify.app/
- Audience: the solo owner-operator, and the engineering agent that executes this plan after approval.
- Engineering mode: standard. No code has been written or modified during planning; this document is read-only work product.

---

## 1. What is happening, in plain language

When the owner uses **Add Student** to create a student account, the account is created with `email_confirm: false`. That setting does not do what the code's own comment says it does. It does not mean "let the student set their own password on first login." It means "mark this account as not yet email-confirmed."

The problem: **no confirmation email is ever sent** for an admin-created account. The Supabase Admin API call used here (`auth.admin.createUser`) never dispatches mail, under any setting. So the account is created in a state that requires confirmation, but there is no way for the student to ever confirm it. No email arrives because none is ever sent, not because of a delivery problem.

In production, the project's Auth setting "Confirm email" is on, so `signInWithPassword` rejects the unconfirmed student with "Email not confirmed." In local development, confirmations are disabled entirely, so the same code appears to work fine locally. That is a pure local-versus-production configuration gap, which is why this defect was never caught by existing tests.

The product's actual onboarding design does not use email at all: the admin creates the account, a temporary password is generated automatically, and it is shown once on screen for the admin to copy and share with the student directly. Email confirmation is simply inconsistent with a design that was already built and already tested this way.

**The fix:** mark admin-created accounts as already confirmed at creation (`email_confirm: true`), matching the onboarding model that already exists, plus a one-time approval-gated repair of the accounts already stuck in this state.

---

## 2. Root cause evidence

- **RC-1 (confirmed root cause).** `supabase/functions/admin-student-operations/index.ts`, lines 173-205, function `handleRegisterStudent`, calls:
  ```ts
  serviceClient.auth.admin.createUser({ email: payload.email, password: tempPassword, email_confirm: false })
  ```
  with the inline comment at line 184, "Let user set their own password on first login." That comment is factually wrong about what the parameter controls.

- **RC-2.** The GoTrue Admin `createUser` endpoint sends no email under any setting. With `email_confirm: false`, the account is created with `email_confirmed_at` null, and the codebase never calls `inviteUserByEmail`, `generateLink`, or `resetPasswordForEmail` anywhere. This is why no confirmation email reaches the student: none is ever sent.

- **RC-3.** Production has Auth "Confirm email" enabled. `signInWithPassword` therefore rejects the unconfirmed user with HTTP 400, error code `email_not_confirmed`, message "Email not confirmed." This matches the reported symptom exactly.

- **RC-4 (why this was never caught).** `supabase/config.toml` sets `[auth.email] enable_confirmations = false` for the local stack, and leaves SMTP unconfigured (local uses the inbucket test catcher). Locally, an unconfirmed user can sign in without issue. Every existing test passes locally and could never have caught this production-only failure.

- **RC-5 (the decisive fact).** `handleRegisterStudent` already generates a temp password server-side and returns it in the 201 response as `temp_password`, with the message "Student account created. Share the temp password once only." `src/components/RegisterStudentModal.tsx` has a two-phase flow whose second phase ("Account Created") displays that password once with a Copy button, and `src/__tests__/e2e/gap-4-admin-students-remediation.spec.ts` asserts this reveal behavior. The product's onboarding is deliberately built around the admin sharing credentials out-of-band. Email plays no role in it. `email_confirm: false` is simply inconsistent with a design that already exists and is already tested.

- **RC-6 (adjacent defect, in scope only as copy).** `RegisterStudentModal.tsx`, near line 177, tells the admin the student will "set their own password on first login." No such forced-password-change flow exists anywhere in `src/`. The copy promises a behavior the product does not have.

- **RC-7 (client error plumbing, overlaps the in-flight production-500 plan's R2).** `src/services/adminStudentData.ts`, function `registerStudent()`, lines 58-74, only reads real error detail on the `data?.error` branch (lines 70-72). The installed `@supabase/functions-js@2.110.7` throws `FunctionsHttpError` and returns `{ data: null, error }` for any non-2xx response, before the body is parsed. Because `handleRegisterStudent` returns 500 or 422 for every business failure, `data` is always null, that branch of code never runs, and the error message shown is always the generic hardcoded string "Edge Function returned a non-2xx status code." The real error body is only reachable through the unconsumed `error.context` response object.

- **RC-8.** `src/context/AuthContext.tsx`, line 90, does `setError(signInError.message)`, which surfaces raw GoTrue error strings such as "Email not confirmed" directly to students via `LoginForm.tsx`, lines 59-63.

- **RC-9 (security-relevant, drives the Option C rejection below).** `supabase/config.toml` sets `[auth] enable_signup = true` and `[auth.email] enable_signup = true`.

### Research evidence supporting the above

Retrieved 2026-08-04 by a nested Researcher pass, grounded in primary GoTrue and Supabase JS sources:

- GoTrue `internal/api/admin.go`, `adminUserCreate`: the only effect of `email_confirm` is `if params.EmailConfirm { user.Confirm(tx) }`. No mailer is invoked in that code path.
- `auth-js` `types.ts` JSDoc: "Confirms the user's email address if set to true. Only a service role can modify." It is a state flag, not a send trigger.
- APIs that do send mail: `inviteUserByEmail`, `resetPasswordForEmail`. `generateLink` explicitly does not send mail; it is meant to be delivered through a custom email provider.
- GoTrue `internal/api/token.go`, password grant: `if params.Email != "" && !user.IsConfirmed() { return NewBadRequestError(ErrorCodeEmailNotConfirmed, "Email not confirmed") }`, producing HTTP 400 with error code `email_not_confirmed`. The recommended fix maps on this code, not on the message string.
- The backfill mechanism: `adminUserUpdate` (`PUT /admin/users/{id}`, i.e. `auth.admin.updateUserById`) contains the identical `if params.EmailConfirm { user.Confirm(tx) }` block. So `updateUserById(id, { email_confirm: true })` is the supported, programmatic way to confirm an existing account. It sends no email, requires the service-role key server-side only, and has no bulk endpoint — it must be called once per user id.
- Supabase's built-in email provider is capped at 2 emails per hour, is best-effort with no delivery SLA, and is documented as unsuitable for production; production email requires custom SMTP.
- The only confirmation gate on the password grant is `!user.IsConfirmed()`. A user created with both a password and `email_confirm: true` can sign in immediately, regardless of the project's "Confirm email" setting.
- Unknowns the researcher flagged: the hosted project's actual "Confirm email" setting and SMTP configuration cannot be determined from source or documentation and require the user's Supabase dashboard; the dashboard's current per-user confirm affordance is unknown; whether an admin invite counts against the 2/hour built-in email bucket is not enumerated in the documentation reviewed.

---

## 3. Decision record: three options considered

### Option A — RECOMMENDED: set `email_confirm: true` on admin-created accounts

This is the only option consistent with the onboarding flow this codebase already implements and already tests (RC-5). It requires no new infrastructure, no SMTP, no DNS, and no third-party dependency. It is confirmed correct at the GoTrue source level. It is a one-flag change to `handleRegisterStudent` plus a bounded, approval-gated backfill for accounts already stuck unconfirmed.

Residual risk: RISK-2 below (unverified email ownership). That risk is inherent to the trust model this product already ships — the admin is the trusted party creating known students' accounts — not something newly introduced by this fix.

### Option B — REJECTED: adopt `inviteUserByEmail` plus production SMTP

This would replace a working manual-credential flow with an email-delivery flow, discarding the temp-password reveal screen and its existing tests. It introduces a hard new dependency on custom SMTP, since the built-in provider is capped at 2 emails/hour, best-effort, with no delivery SLA, and is explicitly documented as unsuitable for production use. It also adds SMTP provider selection, domain configuration, and DNS setup as new residual unknowns requiring the user's Supabase dashboard access.

This option solves a problem the product does not have. If the user later prefers an email-based invitation model as a product direction, that is a separate decision requiring its own plan, not a bug fix.

### Option C — REJECTED, specifically on security grounds: turn off "Confirm email" in the hosted Supabase dashboard

This would make the symptom disappear with zero code change, which makes it tempting. **It is rejected because of RC-9**: `[auth] enable_signup = true` and `[auth.email] enable_signup = true` are both set in this project's configuration. If public self-registration is likewise enabled on the hosted project, disabling email confirmation globally would let anyone self-register using an email address they do not control, with no confirmation step to catch it. This would weaken a real security control across the entire project in order to fix one narrow, admin-created-account code path.

Option A fixes exactly the intended path and leaves the confirmation requirement fully intact for every other flow, including public self-registration if it is enabled.

### Assumption requiring the user's confirmation (zero-risk read, not a change)

This plan assumes production has "Confirm email" enabled, inferred from the reported symptom, which the documented GoTrue password-grant gate produces only in that configuration. The plan recommends the user verify this directly in the Supabase dashboard, under Authentication > Providers > Email, before or during execution. This is a read-only check with no risk.

---

## 4. Scope

### In scope

1. Change `email_confirm: false` to `email_confirm: true` in `handleRegisterStudent`.
2. A one-time, approval-gated, service-role backfill confirming already-created, currently-locked-out student accounts.
3. Client-side sign-in error mapping, reveal-phase copy correction, and duplicate-email inline error handling (design detail in Section 6).
4. New automated tests covering the previously uncovered paths, plus local-stack verification before any production redeploy.

### Explicitly out of scope

- Configuring custom SMTP or adopting `inviteUserByEmail` (Option B, rejected above).
- Disabling "Confirm email" in the hosted Supabase dashboard (Option C, rejected above on security grounds).
- Building a forced first-login password-change or password-rotation flow. This is a real gap (RC-6, RISK-3) but is recorded only as a follow-on recommendation, not built here.
- Any deploy, redeploy, dashboard mutation, or production data write without a separate, explicit, per-step approval.
- The broader fifteen-site error-contract sweep owned by the separate, in-flight production-500 plan (`docs/plans/lizbeth-spanish-admin-student-operations-prod-500.md`). See Section 8 for how the two plans relate.

No file in the target repository was modified during the creation of this plan.

---

## 5. Sequencing decision — must be resolved before any engineering work starts

This plan and the in-flight plan `docs/plans/lizbeth-spanish-admin-student-operations-prod-500.md` both touch the same handler (`handleRegisterStudent`, around line 188 in `index.ts`) and the same client function (`registerStudent()` in `adminStudentData.ts`). That plan's R1 already maps register duplicate-email failures to HTTP 409, and its R2 already specifies client-side error-body recovery — the same work items 3a/3b below describe from this plan's angle. **They must not be implemented twice, and the two plans must not run concurrently against the same files.**

**Recommendation:** fold this plan's execution into the in-flight 500 plan's engineering dispatch as clearly labeled additional work items, rather than dispatching this plan independently. Under folding:
- The 500 plan's R1/R2 remain the authoritative owner of `index.ts` line 188 and of `adminStudentData.ts`.
- This plan contributes W1/W2 (the `email_confirm` fix and its regression test), W8/W9 (the backfill), and design items 1/2/3c (Section 6).
- This produces one redeploy, one verification pass, one browser validation pass, and one production smoke test instead of two overlapping rounds.

**Alternative, if the student lockout is judged too urgent to wait for the 500 plan's full scope:** ship W1, W2, W8, and W9 alone as a minimal standalone hotfix. The `email_confirm` change and the backfill are genuinely independent of the error-contract sweep. Defer items 3a/3b/3c entirely to the 500 plan in that case.

**Do not run both plans concurrently against the same files under either choice.** This sequencing decision must be made by the user before any dispatch to engineering.

---

## 6. Design specification (compact route, independently reviewed)

Design routed as **compact**: three bounded items, specification-only, reusing existing components, classes, and tokens with no new visual system. The design handoff was revised once after independent design review (round 1: NEEDS_REVISION, one critical finding that item 3's original error detection was dead code per RC-7; round 2, after remediation: PASS with one non-blocking style note recorded in item 3a). The reviewer independently spot-checked the cited files, line numbers, CSS classes, and the token conventions in use.

### Item 1 — sign-in error mapping

Replace `AuthContext.tsx` line 90 with a mapper keyed on `err.code`, never on message text:

| Code | Copy |
|---|---|
| `email_not_confirmed` | "We can't sign you in yet. Please contact your instructor to activate your account." |
| `invalid_credentials` | "That email or password isn't right. Please try again." |
| default (any other/unknown code) | "We couldn't sign you in. Please try again, or contact your instructor if this continues." |

Rendering is unchanged: `LoginForm.tsx` lines 59-63 keep `<p role="alert" className="login-form-error">{error}</p>`. Do not move focus on sign-in failure; `role="alert"` is implicitly assertive already.

Hard constraints:
- The `email_not_confirmed` copy must never contain the words email, confirm, or inbox, because no such email exists in this product's design.
- The `invalid_credentials` copy must be identical regardless of whether the account exists at all — no account-existence disclosure.

### Item 2 — reveal-phase copy correction

Replace `RegisterStudentModal.tsx` lines 174-179, the `.temp-password-warning` block, with:

> **Important:** This account is ready to use right now. Share this password with the student through a secure channel — it will not be shown again after you close this window. The student can sign in immediately with their email and this password.

No CSS change.

### Item 3 — duplicate-email conflict (three coordinated parts)

**3a (hard requirement).** In `registerStudent()` in `src/services/adminStudentData.ts`, detect `error instanceof FunctionsHttpError`, read the unconsumed response via `error.context`:
```ts
try { parsedBody = await error.context.json() } catch { parsedBody = undefined }
```
If `parsedBody?.error` is present, throw `new AdminStudentError(parsedBody.error, parsedBody.fieldErrors, error)`. Otherwise, fall back to the existing generic throw. Retain the existing `data?.error` branch after this new check. Scope this strictly to `registerStudent()`; do not extend it to disable/enable/delete/assign in this plan — those belong to the in-flight 500 plan's broader sweep.

Reviewer note (non-blocking style preference): import `FunctionsHttpError` from `@supabase/supabase-js`, which is a declared dependency, rather than `@supabase/functions-js`, which is only a transitive dependency, for lockfile hygiene.

**3b (hard requirement).** `handleRegisterStudent` must, on a GoTrue duplicate-user error, return HTTP 409 with:
```json
{
  "error": "An account already exists for this email address.",
  "fieldErrors": [{ "field": "email", "message": "An account already exists for this email address." }]
}
```
instead of the current generic 500 at line 188. The reviewer verified no consumer couples to a specific status code: `AdminStudentsPage.tsx` lines 297-301 consume only the promise, `RegisterStudentModal.test.tsx` mocks `onRegister`, and the Playwright spec asserts locators rather than status codes. `!response.ok` treats 409 identically to 500 in existing handling.

**3c.** Introduce an `errorField` state (`'email' | null`), separate from the existing `error` state. Gate `aria-invalid`, `aria-describedby="register-student-email-error"`, and the focus-plus-select side effect on `#student-email` on `errorField === 'email'`, setting it only for the two genuinely field-specific causes: empty email and duplicate email. A generic or transient failure sets `error` for the visible alert but leaves `errorField` null, so the input is never marked invalid and focus is not forced onto it.

Keep `<p role="alert" id="register-student-email-error" className="form-error">` with a stable id, rendering for any `error` regardless of `errorField`.

Duplicate-email copy: "An account already exists for this email address. Check the students list, or use a different email address."

A regex fallback (`/already (been )?registered|already exists/i`) is permitted only as an explicitly labeled interim measure, must be confirmed against the actual local GoTrue error text before commit, and is expected to become unnecessary once 3a/3b ship.

### Additional design invariants

- No native `alert`, `confirm`, `prompt`, `window.*` forms, or `beforeunload` anywhere in the touched files.
- Do not add message-substring matching as a workaround for the `err.code` header dependency (see RISK-6).
- Do not add a forced-password-change flow (out of scope, RC-6/RISK-3).

### Permitted variation

Copy wording may be tightened subject to the three hard copy constraints above. A lookup object may replace the switch statement. `errorField` may be a discriminated union instead of two separate `useState` calls, provided the scoping behavior is identical. Focus-only (without `.select()`) is acceptable if `.select()` proves inconsistent across browsers.

---

## 7. Ordered work

- **W0 (blocking prerequisite).** Resolve the Section 5 sequencing decision with the user before any engineering dispatch. No code is written until this is decided.
- **W1.** Change `email_confirm: false` to `email_confirm: true` at `index.ts` line 184, and delete the inaccurate comment ("Let user set their own password on first login"), replacing it with an accurate one explaining that admin-created accounts are pre-confirmed because onboarding is deliberately email-free and credentials are shared out-of-band.
- **W2.** Add a regression test asserting `createUser` is called with `email_confirm: true`. This is the single most important test in this change — it guards against silent reintroduction of the bug, and it passes locally even though local confirmations are disabled.
- **W3.** Implement design item 3b (409 status plus `fieldErrors`) in `handleRegisterStudent`.
- **W4.** Implement design item 3a (`FunctionsHttpError` body recovery) in `registerStudent()` only.
- **W5.** Implement design items 1, 2, and 3c (`AuthContext` mapper, reveal copy, `errorField` scoping).
- **W6.** Add tests for the previously uncovered paths: duplicate-email registration end to end (the existing e2e spec uses a unique email every run and has therefore never exercised this path), the sign-in error mapping branches, and the `errorField` scoping.
- **W7.** Local-stack verification: build, serve the Edge Function locally, and run the full suite.

  **Critical caveat, must be stated prominently at execution time:** because local `enable_confirmations = false`, the local stack cannot reproduce the original bug and cannot prove the fix by sign-in success alone. Local verification must instead assert that `email_confirmed_at` is non-null on a newly created user, and assert the `email_confirm: true` argument at the call site. Do not accept "the student signed in locally" as evidence the fix works.
- **W8.** Backfill dry run (read-only). Enumerate every existing auth user with `email_confirmed_at` null, produce the exact list of ids and emails, and present it to the user. Exclude the owner account (`rob.hasselbach@gmail.com`) and the banned smoke account (`rob.hasselbach+smoke@gmail.com`). Per the in-flight 500 plan's evidence, production `auth.users` held exactly those two rows as of 2026-07-26, so the list must be reviewed, not assumed.
- **W9. Backfill execution.** Requires separate, explicitly recorded user approval of the exact W8 list. Service-role `updateUserById(id, { email_confirm: true })`, called once per approved id, server-side only, idempotent, with each result recorded.

  **This step is effectively irreversible via the Admin API. See Section 9, RISK-1, before approving.**
- **W10.** Independent Verifier pass (required).
- **W11.** Browser Validator pass (required — this changes browser-rendered UI). See Section 10 for the validation brief.
- **W12.** Production redeploy of `admin-student-operations`. Requires separate, explicit go-ahead at execution time, after W7, W10, and W11 have passed. Followed by a production smoke test: create one throwaway student, confirm sign-in succeeds with the temp password with no email step, then clean up the throwaway account.

---

## 8. Interfaces and data affected

- `handleRegisterStudent`'s response contract changes for exactly one condition: duplicate email moves from a generic 500 `{error}` to 409 `{error, fieldErrors}`. The 201 success shape (`student_id`, `email`, `temp_password`, `message`) is unchanged. The reviewer confirmed no consumer couples to status codes.
- `AdminStudentError`'s shape is unchanged; its already-declared `fieldErrors` field (`adminStudentData.ts` lines 23-32) simply becomes reachable on this path for the first time. Its shape matches `ValidationError { field, message }` in `src/lib/adminStudentAuthorization.ts` lines 52-54.
- Data: `auth.users.email_confirmed_at` transitions from null to a timestamp for new account creates (W1) and for the approved backfill set (W9). No schema migration. No application table is touched.
- No change to `supabase/config.toml` is required or proposed. Do not "fix" the local environment by enabling confirmations there; that would remove the ability to test the pre-confirmed path locally.

---

## 9. Risks and rollback

**RISK-1 — HIGH, irreversibility.** The W9 backfill is effectively **irreversible** through the supported Admin API. `updateUserById` exposes `email_confirm: true` to set confirmation, but there is no documented, supported way to unset `email_confirmed_at` back to null through that API. Reverting would require direct database access outside the normal application flow. Required mitigations: the W8 dry run must produce the exact id/email list; the user must explicitly approve that list before execution; the operation must be scoped strictly to the approved list; the owner and smoke accounts must be excluded; each result must be recorded. **Do not run the backfill as an unbounded "confirm all unconfirmed users" sweep.**

**RISK-2 — MEDIUM, security, accepted deliberately.** Pre-confirming means email ownership is never verified for admin-created accounts. If the admin mistypes an address, a confirmed account will exist at an address nobody controls, and because no email is ever sent, the address holder is never notified. This is an accepted consequence of the already-shipped trust model, where the admin is the trusted party, students are known individuals, and credentials are shared out-of-band. It is not a new exposure introduced by this fix — the account was already being created at the mistyped address; this change only makes it usable. Mitigation: the duplicate-email and validation copy in item 3 helps the admin notice mistakes, and the admin retains the ability to delete a wrongly created account. **The user should knowingly accept this risk before approving this plan.**

**RISK-3 — MEDIUM, secret handling.** The temp password is displayed once and shared out-of-band by the admin. It is never rotated, because no forced-rotation flow exists (RC-6). A student's initial password therefore remains known to the admin indefinitely. Recorded as the top follow-on recommendation; explicitly out of scope here.

**RISK-4 — MEDIUM, shared-file conflict.** This plan and the in-flight 500 plan both edit `handleRegisterStudent` near line 188 and both touch `registerStudent()` in `adminStudentData.ts`. Concurrent or uncoordinated execution would conflict. Fully mitigated only by resolving the W0 sequencing decision first (Section 5).

**RISK-5 — MEDIUM, verification gap.** Local cannot reproduce the original bug (RC-4). A local pass is necessary but not sufficient evidence that the fix works. Mitigation: assert on `email_confirmed_at` and the call-site argument rather than on sign-in success (W7), and treat the W12 production smoke test as the only true end-to-end proof.

**RISK-6 — LOW.** `signInError.code` is populated by `auth-js` only when GoTrue sends the `X-Supabase-Api-Version` header at version 2024-01-01 or later. If that header is absent, every sign-in failure falls to the safe default copy in item 1. This is non-blocking because the default copy does not leak information, but the wrong-password and unconfirmed-account browser journeys must record which branch actually fires. Do not work around this with message-substring matching.

**RISK-7 — LOW.** The 409 status change could in principle surprise an unknown external consumer of this endpoint. The reviewer found none in the repository.

**Rollback.** W1-W6 are ordinary code changes and revert cleanly via Git; the Edge Function rolls back by redeploying its prior recorded source. **W9 does not roll back through the Admin API — see RISK-1.**

---

## 10. Acceptance and validation

- `createUser` is called with `email_confirm: true` (unit assertion at the call site).
- A newly created student has a non-null `email_confirmed_at` (local stack query).
- A duplicate-email registration returns 409 with `fieldErrors: [{field:'email', ...}]`, and the admin modal renders the exact duplicate copy, stays in the email phase, moves focus to `#student-email` with the text selected, and exposes `aria-invalid="true"` and `aria-describedby="register-student-email-error"`.
- A generic, non-field failure renders visible alert text while `#student-email` has neither `aria-invalid` nor `aria-describedby`, and focus is not moved.
- Sign-in copy assertions are exact-string for all three mapped variants; the executing agent must record which branch actually fires in practice (see RISK-6).
- No raw GoTrue error string ever reaches a student-facing surface.
- A deterministic source scan confirms no `alert(`, `confirm(`, `prompt(`, `window.alert/confirm/prompt`, or `beforeunload` in the touched files.
- The full existing test suite is green, including `edgeFunctionBootSmoke.test.ts` and `gap-4-admin-students-remediation.spec.ts`.
- Production smoke test (W12): a throwaway student created in production signs in successfully on the first attempt, with no email step required.

### Browser UI dialog policy (required for this job)

Native browser dialogs are prohibited: no `alert`, `confirm`, `prompt`, their `window.*` forms, and no `beforeunload` prompt. All acknowledgement and validation must use the existing app-owned accessible `Modal` component and the existing inline `role="alert"` patterns. Keyboard and focus behavior must be verified for the modal and for the scoped focus-return on `#student-email`. A deterministic source-level no-native-dialog scan is required as part of verification.

### Browser validation brief

- **Launch and readiness:** the project's existing dev-server command, plus the local Supabase stack (`supabase start`), with the Edge Function served locally. Ready when the dev server responds and the function is reachable.
- **Base URL and routes:** the local dev server; the existing student login route and the existing admin students route. No new routes are introduced.
- **Fixtures and reset:** use the existing seeded `LOCAL_TEST_STUDENTS` (declared in `LoginForm.tsx`) for credential journeys; use the admin students page's "Add Student" entry point for registration journeys. For duplicate-email, register a fixture email once, then attempt the same address again. For the unconfirmed-account journey, use a pre-backfill fixture or a test double, since local confirmations are disabled by default.
- **Journeys:**
  1. Wrong password: exact `invalid_credentials` copy, announced via `role="alert"`, with no account-existence disclosure.
  2. Unconfirmed account: exact `email_not_confirmed` copy, containing no email/confirmation/inbox language.
  3. Successful registration: reveal-phase paragraph matches the corrected copy exactly and no longer contains "will set their own password."
  4. Duplicate-email registration: exact duplicate copy, focus moves to `#student-email` with the text selected, `aria-invalid` and `aria-describedby` are present, and the modal remains in the email phase.
  5. Generic, non-field failure: alert text is visible, but there is no `aria-invalid`, no `aria-describedby`, and focus is not moved.
- **Viewport profiles:** desktop default and approximately 375px mobile, confirming copy wraps without overflow in `.login-form-error`, `.form-error`, and `.temp-password-warning`.
- **Visible outcomes:** the exact copy string for each state; a visible focus ring on `#student-email` for field-specific failures only; no native browser dialog appears at any point; `role="alert"` is present for every error state.

---

## 11. Cross-vendor judgment routing

Local Codex "PLAN_DUCK" review is recommended and eligible for this plan, based on: an auth/security boundary, an irreversible production auth-data mutation (the backfill), and a shared-file sequencing decision against an in-flight plan. Risk level is moderate. Blocking mode is not required; shadow/advisory review is sufficient given the root cause is confirmed at the GoTrue source level. Call cap: 2. A code-review checkpoint at engineering time is optional, not required.

---

## 12. Approvals required from the user before or during execution

1. Approval of this plan itself.
2. The W0 sequencing decision (fold into the in-flight 500 plan, or ship the minimal standalone hotfix — Section 5).
3. Explicit approval of the exact W8 backfill list before W9 executes.
4. Separate, explicit go-ahead for the W12 production redeploy.

---

## 13. Follow-on recommendations (not built in this plan)

- A forced first-login password-change flow, so the admin does not retain indefinite knowledge of a student's password (RISK-3).
- User confirmation, via the Supabase dashboard, of the actual "Confirm email" and public-signup settings on the hosted project, to validate the assumption this plan is built on.
