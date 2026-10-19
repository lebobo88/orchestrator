# Lizbeth Spanish QA Sweep Remediation — Batch 1

**Status: Approved**

**Approval record:** approved by rob.hasselbach@gmail.com on 2026-08-29, via direct interactive-session response to the orchestrator. Exact reply: "1. a. 2. block", mapped to (1) accept Option 1 on the #15/#16 tension — proceed now with the combined shared-Modal fix that also resolves #15's root cause as a byproduct — and (2) confirm BLOCK as the target behavior for #26 (unconfirmed email gets full access), rather than allow-with-visible-warning.

- Plan ID: `lizbeth-spanish-qa-sweep-remediation-batch-1`
- Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (its own Git repository, nested inside the orchestrator repository). GitHub slug `lebobo88/lizbeth-spanish` — always pass `--repo` explicitly to `gh`, since the local directory uses an underscore and the remote uses a hyphen.
- Engineering mode: standard
- Team authorization: not applicable
- Downstream owner: engineering-fleet

## Outcome and audience

Remediate 13 of the 16 GitHub issues (#12–#27) filed from the executed QA sweep documented at `docs/plans/lizbeth-spanish-full-app-qa-validation-sweep.md`, in the severity and dependency order below, through the standard engineering fleet (T1/T2, Verifier, Browser Validator).

Audience: the orchestrator, the T1/T2 writer, Verifier, Browser Validator, and the user approving this plan.

## Scope and non-goals

### In scope — exactly 13 issues

#23 (LS-QA-012), #24 (LS-QA-013), #12 (LS-QA-001), #13 (LS-QA-002), #15 (LS-QA-004), #19 (LS-QA-008), #26 (LS-QA-015), #14 (LS-QA-003), #17 (LS-QA-006), #18 (LS-QA-007), #27 (LS-QA-016, verification only), #20 (LS-QA-009), #25 (LS-QA-014).

### Explicitly out of scope — no build path, no fix, no dispatch

#16 (LS-QA-005), #21 (LS-QA-010), #22 (LS-QA-011). The user reserved these three for a separate planning pass with their direct input, before any implementation on them. See "The #15/#16 tension" below for the resolved consequence of that reservation on #15, which shares a root cause with #16.

Also out of scope: any new feature, the Electron desktop wrapper, establishing visual baselines, closing or re-grading any GitHub issue, and any commit, push, pull request, or deploy.

## Repository findings

All findings below were verified by direct file reads during planning. Several **contradict** the corresponding GitHub issue's stated root cause. Each contradiction is recorded explicitly and is not softened; where the filed root cause is wrong, that is stated plainly rather than reconciled with the issue text.

### A. #23 / #24 — the filed root cause is wrong, and acting on it would be a security regression

Both issues attribute the empty public catalog to "the anon Postgres role lacks SELECT grant on `public.courses` (confirmed via direct anon REST call returning 42501)." The 42501 is real but is a deliberate, correct security boundary, not the bug.

- `supabase/migrations/202608280003_issue5_course_authoring.sql:531` revokes all privileges on `public.courses` and twelve sibling tables from `anon` and `authenticated`.
- `supabase/migrations/202608280003_issue5_course_authoring.sql:537` grants `select` on exactly two purpose-built views — `public.course_catalog` and `public.course_preview_lessons` — to `anon` and `authenticated`.
- The views (defined at `supabase/migrations/202608280003_issue5_course_authoring.sql:214-222`) already filter to `c.visibility = 'catalog'` and `cv.status = 'published'`.
- Granting `anon` SELECT on `public.courses` would expose non-catalog and unpublished courses.

**This plan forbids the grant approach explicitly.** No migration touching anon grants on `public.courses` (or any sibling table) is authorized by this plan.

**#23 (listing) actual root cause:** `src/services/courseAuthoring.ts:46` `getCatalog()` correctly reads the `course_catalog` view. That view's column list (migration `:215`) is: `id, slug, title, description, visibility, enrollment_mode, capacity, course_version_id, version_no`. There is no `status` column and no `level` column. `src/lib/courseAuthoring.ts:15` `normalizeCourseSummary` then computes `status: input?.status === 'published' ? 'published' : 'draft'`, which is therefore **always** `'draft'` because the field it reads never exists on the input. `src/pages/PublicCatalogPage.tsx:6` renders `courses.filter(c => c.status === 'published')`, which therefore always yields the empty set. The catalog renders empty for everyone, anonymous or authenticated. This is a pure client-side defect with no database change required. `level` is likewise always defaulted to `'All levels'` for the same reason.

**#24 (detail page) actual root cause:** `PublicCatalogPage` calls `getCourse(courseId)` (`src/services/courseAuthoring.ts:45`), which routes through `courseAction` to the `course-authoring` Edge function with action `get_course`. That function (`supabase/functions/course-authoring/index.ts`) requires an `Authorization` bearer token at `:27-28` (401 without one) and then requires owner role at `:40` (403 otherwise). An anonymous visitor has neither, so the request always fails and the page falls into its `.catch(() => setMessage('This course is not available.'))`. Critically, the same Edge function already implements a correct unauthenticated path: the `catalog` and `preview` public actions at `:15-26`, handled before the token check, using an anon client against the two granted views. The fix is to route the public detail page through the existing `preview` public action rather than the owner-only `get_course`. Again, no database change.

**Writer note:** `PublicCatalogPage.tsx` is written as a single dense, minified-style line. Reformatting it is acceptable and probably necessary to make the fix legible, but the reformat must be flagged explicitly in the diff so the Verifier is not surprised by its size.

**Latent observation, not in scope, log only, do not fix:** the detail page's "Request enrollment" button calls `requestEnrollment(course.id)` where `course.id` has been reassigned to a course_version id, while `requestEnrollment` (`courseAuthoring.ts:60`) passes it as `p_cohort_id`. This is a real id-type mismatch. It is recorded here as an observation for a future plan; Batch A does not touch it.

### B. #12 / #13 / #17 — "Escape doesn't close" is not an accidental bug

Every one of these modals passes `suppressDismiss={true}` to the shared `Modal`, each with an explicit in-code comment stating Escape and backdrop are disabled deliberately.

- `src/components/Modal.tsx:34-45` implements Escape correctly and skips it only when `suppressDismiss` is true.
- `src/components/Modal.tsx:154` also hides the header close (X) button under the same flag.
- Affected call sites: `AdminStudentModals.tsx:126` (`HardDeleteStudentModal`), `:396` (`WipeSaveModal`), `:606` (`ReissueAccessModal` confirm phase), `:658` (`ReissueAccessModal` reveal phase), and `RegisterStudentModal.tsx:134` (email phase) and `:187` ("Account Created" reveal phase).
- Five other modals never set the flag and already close on Escape.

So #12/#13/#17 are a deliberate-design-versus-accessibility-expectation question, not a defect to patch blindly. The design route resolved this — see "Design handoff" below for the binding resolution (retain the single `suppressDismiss` prop; flip four of the six literals to `false`; keep the two one-time-secret reveals suppressed).

### C. #15 — the filed root cause is wrong

The issue describes a "disabled-button trap-boundary bug." `Modal.tsx:59-76` already excludes disabled controls correctly via `button:not([disabled])`, `input:not([disabled])`, etc. — that mechanism is not broken.

The actual cause is the deliberate "J-003" decision at `Modal.tsx:72-75`, which prepends `dialogRef.current` (the dialog container, `tabIndex=-1`) as index 0 of the focusable cycle. Shift+Tab from the first real control therefore lands on the container rather than wrapping to the last control.

Load-bearing supporting fact: the accompanying test `src/__tests__/Modal-FocusTrap-ShiftTab.test.tsx` asserts only that focus never leaves the modal (lines 48-50, 65-68, 74-77). It does not assert the container is a cycle stop, so the corrective change does not require rewriting that test's intent — the existing assertions must still pass unchanged after the fix.

### D. #18 — root cause identified, medium confidence, to be confirmed by the failing test written first

`Modal.tsx:48-55` captures `triggerRef.current = document.activeElement` inside the effect that also programmatically focuses the dialog. `RegisterStudentModal.tsx:151` gives the email input `autoFocus`, which React applies during the same commit, before that effect runs. The modal therefore captures the email input — a descendant — as the "trigger," and on close restores focus to a removed node, dropping focus to `document.body`.

This is stated at medium confidence per the source evidence, not certainty. The TDD-first failing test in Step 2 is the confirming step, not this write-up.

### E. #20 — root cause confirmed and trivial

`RegisterStudentModal.tsx:144-148` `onChange` clears `emailFieldError` but never clears the `error` state that populates the `role="alert"` region at `:156-160`.

### F. #14 — root cause confirmed

`src/components/AdminStudentModals.css:122-146` sets `.choice-option { display: flex }` with `.choice-option span { flex: 1 }` and no `min-width`, the classic flex min-content overflow. Design specifies `min-width: 0` on the flex text column.

### G. #19 — root cause is very likely a fixture gap, not application code. This is a hypothesis, not a conclusion

Two supporting facts:

1. The owner dashboard does not read progress under RLS: `supabase/functions/admin-student-operations/index.ts:682-690` `handleDashboard` queries `student_lesson_progress` with a service-role client, so the students-only RLS policy at `migrations/202608270001_issue2_progress_dashboard.sql:29-37` (there is no owner-read policy) is not the blocker.
2. `supabase/seed.sql` contains zero `student_lesson_progress` rows — a repository-wide grep for that table returns six files, none of them the seed.

So after `npx supabase db reset`, no lesson-progress rows exist at all, and every enrollment legitimately computes 0%. "Last Active identically today for every row" is consistent with a fallback to enrollment date or `now()` when no progress row exists.

This is explicitly a hypothesis, not a conclusion — it is the reason #19 gets a mandatory investigation step with a decision gate (Step 3) before any fix is scoped. The plan must not assume outcome (a) below and pre-scope a fix around it.

### H. #26 — root cause confirmed, and the app-versus-config contradiction is the whole story

`supabase/config.toml:238` sets `enable_confirmations = false`. There is no `email_confirmed_at` check anywhere in production `src/` — only in test files. Meanwhile the shipped owner-facing `ConfirmEmailModal` copy (`AdminStudentModals.tsx:499`) tells the owner "This clears the block that's stopping this student from signing in," describing a block that the code does not implement.

Two further facts bound the fix:

1. Admin-created students are created with `email_confirm: true` (`supabase/functions/admin-student-operations/index.ts:273`, comment: "Mark confirmed at creation since onboarding is email-free and credentials are shared directly by admin"), so a confirmation gate cannot break the primary onboarding path.
2. There is no self-service signup flow anywhere in `src/`.

**Unresolved and must be checked first (Step 4a):** two in-repo sources contradict each other about whether GoTrue even permits an unconfirmed password-grant sign-in. `config.toml:237-238` says confirmation is not required, while `supabase/seed.sql:17-20` states "GoTrue's password grant requires a confirmed email even when signup email confirmation is disabled project-wide." This is a five-minute empirical local check and it determines whether #26's fix is a post-session gate or a sign-in-form error state.

Also record: the design fleet independently verified that `supabase/seed.sql` sets `email_confirmed_at = now()` for every seeded auth user, on both insert (lines 52-78) and on the `ON CONFLICT` update (line 81), including `student7@test.local`, whose only null column is `last_sign_in_at`. The QA sweep plan's Section 5.D description of `student7` as the unconfirmed account is therefore **incorrect**. This in turn means the original #26 observation needs re-grounding: no fixture currently exists that can even produce an unconfirmed session, and Step 4 must create a disposable one.

### I. #25 — root cause confirmed, and it does not self-resolve after #23/#24

In `PublicCatalogPage.tsx` the `<h1>` on the detail route lives inside the `course ? ... : ...` truthy branch. The non-success branch renders only `<p role="status">{message || 'Loading preview…'}</p>`. So even after #24 is fixed, any load failure or the transient loading state still has no page-level H1. It needs its own fix, independent of #23/#24, and it must ship regardless of the outcome of Batch A.

### J. #27 — unconfirmed, one repro and one failed repro at a different viewport

Verification first. "Close as unreproduced" is an explicitly valid outcome. No fix is authorized without a reproduction.

## The #15/#16 tension — resolved

#15 (in scope) and #16 (out of scope, reserved) are the **same defect** in the **same shared component**: the J-003 decision at `Modal.tsx:72-75` that puts the dialog container in the focus cycle. #15 is its reverse-wrap symptom in `ReassignModal`; #16 is its forward-wrap symptom in `RegisterStudentModal`. This evidence and reasoning are preserved in full below as the record of why this was a decision at all.

The planning determination is unambiguous: **there is no sane narrow fix.** The focusable-elements array is built once, in one function, for every modal. Correcting the wrap boundary for one direction in one modal is impossible without a per-modal hack that would itself be a defect. Fixing #15 as specified will also fix #16. Additionally, #16's own filed root cause ("disabled-button trap-boundary bug") is wrong for exactly the same reason #15's is: disabled controls are already excluded correctly by the existing `:not([disabled])` selectors.

Two options were presented for the user to choose between:

- **Option 1 (recommended).** Accept the side effect. Implement the shared fix in Step 2, and after implementation, verify and report (Step 7) whether #16 is also resolved rather than assuming it. If it is, tell the user so they can close #16, noting that #16 was never the design-decision issue they reserved it as.
- **Option 2.** Hold #15 as well, moving it into the same reserved batch as #16, and drop it from this plan (Step 2 proceeds without #15).

**Resolution:** the user selected the recommended option on 2026-08-29, via direct interactive-session response to the orchestrator, exact reply "1. a. 2. block." The user's "a" corresponds to Option 1 above (accept the side effect and proceed with the shared fix). Option 2 (holding #15 back into the reserved batch) is rejected and no longer live. #15 proceeds in Step 2 (Batch B).

One consequence stated plainly: #16 remains formally out of this plan's scope, and this plan does not authorize closing it. If Step 7 shows it resolved, that outcome is reported to the user, who decides whether to close it.

## Research evidence

None. No external or current-evidence question arose during planning; all grounding is local repository evidence cited above.

## Design route and design handoff

**Design route: compact.** Grounded, not assumed: every change is brownfield inside the app's existing component language, with no new tokens, no new visual direction, and no new screen archetype. The one genuinely new user-visible surface (#26's gate) is a direct structural sibling of the already-shipped `ForcedPasswordChangeGate`, the app's established pattern for "authenticated but blocked." Agents used: design-generalist (Sonnet 5), design-reviewer (Sonnet 5). Prototype forbidden. `existing_system_mode: preserve`.

**Design handoff: passed.** Its substance is reproduced below as the binding specification for every user-visible change in this plan.

- **Dismiss policy.** `Modal`'s single `suppressDismiss` prop is retained. An earlier proposal to split it into two props was withdrawn under review because a grep of all 11 call sites showed none needs a mixed state. Only four literals flip `true` to `false`: `AdminStudentModals.tsx:126` (HardDelete), `:396` (WipeSave), `:606` (ReissueAccess confirm phase), `RegisterStudentModal.tsx:134` (email phase). Escape, backdrop click, and the now-restored header X all act as Cancel on those four, which is safe because none has produced a side effect at that point — the destructive ones are still guarded by their typed confirmation. The two one-time-secret reveal phases (`AdminStudentModals.tsx:658`, `RegisterStudentModal.tsx:187`) keep `suppressDismiss={true}`, as the WCAG/ARIA APG data-loss exception: the temp password is unrecoverable and reissuing would invalidate the credential just shown. To make that non-dismissibility legible rather than broken, add this exact line above "Done" in both reveal screens, under the existing `.temp-password-warning` paragraph: "This password is shown only here. Select Done once you've copied or shared it."
- **Focus trap.** Remove `dialogRef.current` from `getFocusableElements()`'s returned array so the container is never a Tab/Shift+Tab stop; it remains the one-time programmatic initial focus target on open. Tab from the last descendant wraps to the first; Shift+Tab from the first wraps to the last. Mandatory companion guard, added under review: removing the container means the existing `if (focusableElements.length === 0) return;` early return at `Modal.tsx:82` can now actually fire for a hypothetical zero-focusable body, which would let focus escape to native tab order. `handleTabKey` must therefore, when the list is empty, still call `preventDefault()` and re-focus `dialogRef.current` on both Tab and Shift+Tab. No current modal body is empty, so this is a unit-test-only invariant with no browser journey.
- **Focus restore.** Fix the trigger-capture race so the true page-level trigger is captured before `autoFocus` moves focus — either by replacing the email input's `autoFocus` with an effect-based focus that runs after Modal's capture effect, or by capturing the trigger synchronously at mount. Mechanism is implementer discretion; the outcome is not. It must hold for both the email-phase Cancel path and the full email → submit → reveal → Done round trip, because the reveal phase is a separate Modal mount whose own capture effect re-runs and must not capture an outgoing email-phase element. Required new test target: `src/__tests__/RegisterStudentModal-FocusRestore.test.tsx` covering both paths.
- **Stale error.** `onChange` must clear both `emailFieldError` and `error`. A later resubmission must re-render the `role="alert"` node so assistive tech re-announces it; do not dedupe identical error strings across submissions.
- **ReassignModal layout.** Add `min-width: 0` to the flex text column (`.choice-option` and/or `.choice-option span`). No new token, no fixed `.modal` width. Collision-free at 1440x900, 768x1024, 390x844.
- **EmailUnconfirmedGate (#26).** A full-page state, not a Modal. Direct sibling of `ForcedPasswordChangeGate`, rendered inside `AuthenticatedApp` before the normal shell, derived fresh from the session every render with no cached bypass flag, checked after the existing `needsPasswordChange` branch. Render condition must be `!owner && !session?.user?.email_confirmed_at` — the owner bypass is unconditional and does not depend on the owner's own confirmation state. This bypass exists because owner provisioning is a manual/service-role operation outside this codebase, so nothing in-repo guarantees a future owner is provisioned confirmed; without the bypass an unconfirmed owner would be locked out of all of `/admin/*` and told to "reach out to your instructor," a self-locking dead end. `h1` with `tabIndex={-1}`, focused on mount; status text `role="status"` `aria-live="polite"`; sign out always available. Final copy: heading "Sign-in is on hold"; paragraph 1 "Your account's email hasn't been confirmed yet, so access is on hold until it's confirmed."; paragraph 2 "There's nothing to do here — this app doesn't send confirmation emails. Please reach out to your instructor and ask them to confirm your account."; sign-out button "Sign out and come back later", pending label "Signing out…". No resend affordance of any kind — this app sends no transactional email. States: blocked; signing-out; correct re-render after refresh; disappears once the owner confirms via the existing `ConfirmEmailModal` and the session is re-fetched.
- **PublicCatalogPage H1 (#25).** The non-success branch must render a page-level `h1` sibling to the "← Browse courses" button, in both the loading and error sub-states, unconditioned on fetch outcome.
- **#27 receives no design and no fix.** Contract to check only: content remains rendered at every scroll position, including at a genuinely short-height viewport.

**Design review: passed**, one round of evidence-backed revision, then pass. The reviewer independently re-verified the seed, config, ownership, and CSS claims. One advisory carries forward as a real gate, not a footnote: the target outcome for #26 (BLOCK) is now user-confirmed, but the enforcement layer still rests on the live contradiction between `config.toml:238` and `seed.sql:17-20` about GoTrue's password grant. If the empirical check (Step 4a) shows GoTrue rejects unconfirmed password-grant sign-ins, then an unconfirmed user never reaches `AuthenticatedApp` at all and a post-session gate would solve an unreachable scenario — #26 instead needs a plain-language error state on the sign-in form, per Step 4b. That check must run before #26's implementation is scoped, using the disposable fixture described in Step 4.

## Judge route

`PLAN_DUCK` eligible, advisory/shadow, per `docs/JUDGE-CONTRACT.md`.

`CODE_REVIEW` is **required and blocking** on the Batch D (#26) diff only, because it changes an authentication/authorization boundary. Rubric focus: the owner bypass, the fresh-every-render evaluation with no cached bypass flag, and absence of any new anon data exposure.

`VERIFICATION_CHALLENGE` is optional at the orchestrator's discretion, if the Verifier and Browser Validator disagree.

`VISUAL_REVIEW` is optional on the ReassignModal and gate screenshots.

Standard call caps from `docs/JUDGE-CONTRACT.md` apply; deterministic failures always dominate judge findings.

## Ordered work

Each batch is one bounded `ENGINEERING_JOB`, TDD-first (failing test before production edit), each ending with an independent Verifier pass and, where UI-visible, a Browser Validator pass.

### Step 0 — Environment bring-up (blocking, precedes every batch)

Owner: T1.

1. `cd H:\CommandCenter\orchestrator\lizbeth_spanish`.
2. Confirm Docker is running.
3. `npx supabase start`.
4. Ensure `.env.local` carries `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` matching the emitted values — never a `VITE_`-prefixed service-role key.
5. `npx supabase db reset`.
6. `npm run dev` and capture the actual printed URL (Vite default 5173, but the QA sweep observed 5174 — capture the real value, never hardcode).
7. Assert `VITE_SUPABASE_URL` points at `127.0.0.1` before any journey.
8. Baseline: `npm test -- --run nativeDialogPolicy` must pass. Record `npm run type-check` and `npm run lint` output as the pre-existing baseline (pre-existing failures are recorded, not fixed).

### Step 1 — Batch A: S1 data access (#23, #24)

Owner: T1. Depends on Step 0.

Fix #23 by correcting the client's published-course determination so it no longer depends on a `status` column the `course_catalog` view does not expose. Fix #24 by routing the public detail page through the existing unauthenticated `preview` action instead of the owner-only `get_course`.

No migration, no new grant. This plan prohibits adding `anon` SELECT on `public.courses`, per the security-regression finding above. Also record the latent `requestEnrollment` id-mismatch observation without fixing it.

**Acceptance:**
- Anonymous `/courses` lists the seeded published catalog courses.
- Anonymous `/courses/:id` renders the preview.
- No new anon table grant appears in any migration.
- `src/__tests__/issue5BackendContract.test.ts:142-145` (asserts the exact existing grant line) and `src/__tests__/rlsSecurityRegressionRuntime.test.ts` still pass unchanged.

### Step 2 — Batch B: shared-Modal batch (#12, #13, #15, #17, #18, #20, plus #14)

Owner: T1, escalating to T2 on two counted gate failures. Depends on Step 1.

Deliberately grouped because #12/#13/#15/#17/#18 all land in `src/components/Modal.tsx`, `src/components/AdminStudentModals.tsx`, and `src/components/RegisterStudentModal.tsx`; #20 and #14 are in the same two files and cost nothing extra here. One bounded job, not five thrashing edits.

#15 is firmly in Batch B, per the resolved #15/#16 tension above.

TDD-first: write the failing reverse-wrap and forward-wrap assertions, the empty-focusable-list assertion, the `RegisterStudentModal-FocusRestore` tests, and a stale-error test before touching production code. Preserve the existing `Modal-FocusTrap-ShiftTab.test.tsx` assertions unchanged — they must still pass.

**Acceptance:**
- Every listed test passes.
- `npm test -- --run nativeDialogPolicy` still passes.
- No native dialog introduced.
- The four flipped modals close on Escape, backdrop, and X with no side effect.
- The two reveal phases still do not close on Escape/backdrop/X.
- The new reveal-screen line is present in both reveal phases.

### Step 3 — Batch C: #19 investigation with a decision gate

Owner: T1 (read-only investigation), reporting to the orchestrator. Depends on Step 0 only, scheduled here per the user's ordering.

This step produces **evidence, not a fix.**

Required: after a clean `npx supabase db reset`, query the local Postgres (port 54322) for the row count of `public.student_lesson_progress` and for the enrollments the dashboard renders; then read `handleDashboard` (`supabase/functions/admin-student-operations/index.ts:682` onward) and determine exactly how it derives the per-enrollment percentage and the Last Active value when zero progress rows exist.

**Gate.** The writer must stop and report, and the orchestrator must return to the user, before any fix is scoped. Three outcomes:

- (a) Zero progress rows exist and the computation is correct given the data — this is a fixture/seed gap, and whether to seed realistic progress data is a user decision, not an automatic fix.
- (b) Progress rows exist but the query or aggregation is wrong — a genuine code defect; scope the fix from the evidence.
- (c) Something else — report it.

Explicitly forbidden: inventing a percentage fallback or seeding data to make the dashboard look populated without the user's decision.

### Step 4 — Batch D: #26 unconfirmed-email access

Owner: T1, with mandatory blocking `CODE_REVIEW` on the diff. Depends on Step 2 (shares `AuthenticatedApp` composition context) and on its own sub-gate.

**Resolved requirement.** The user confirmed on 2026-08-29, via direct interactive-session response to the orchestrator, exact reply "1. a. 2. block": BLOCK is the target behavior for unconfirmed-email access. Unconfirmed-email sign-in must be rejected; allow-with-visible-warning is rejected and no longer live.

BLOCK is the target **outcome**, regardless of which layer ends up enforcing it. The Step 4a evidence gate (below) determines the enforcement layer, not whether blocking happens. In neither branch of Step 4b is "leave unconfirmed accounts with unrestricted access" an acceptable outcome.

**Hard prerequisite — fixture, required before Step 4a can run at all.** No seeded account currently has a null `email_confirmed_at`: every row in `supabase/seed.sql` is confirmed on insert and again on the `ON CONFLICT` update, including `student7@test.local`, whose only null column is `last_sign_in_at`. A disposable test-only account with a genuinely unconfirmed email must therefore be added before either Step 4a's empirical check or #26's browser validation can run. The committed seed's existing rows must not be modified. This fixture is a hard prerequisite for Step 4a itself, not only for later validation.

**Step 4a — mandatory pre-check, blocking, and still a live evidence gate.** The contradiction between `supabase/config.toml:237-238` (confirmation not required) and `supabase/seed.sql:17-20` ("GoTrue's password grant requires a confirmed email even when signup email confirmation is disabled project-wide") is unresolved and must be checked empirically against the running local stack, using the disposable fixture above, before #26's implementation is scoped. It is not presented as settled. Report the result.

**Step 4b — implement, scoped by 4a's result. Both branches must still deliver a block; the gate selects the layer, not whether to build.**
- If the check shows GoTrue **permits** an unconfirmed password-grant sign-in, enforcement is app-level: build `EmailUnconfirmedGate` exactly as the design specifies, including the unconditional owner bypass.
- If the check shows GoTrue **already rejects** unconfirmed sign-ins, the block already exists at the platform layer. In that branch the remaining work is to make the existing block legible and honest rather than to add a redundant post-session gate: a plain-language error state on the sign-in form, plus correcting the now-inaccurate `ConfirmEmailModal` copy at `AdminStudentModals.tsx:499`. Do not build the post-session gate in that case.

Grounds for BLOCK, carried forward from planning: an unconfirmed account currently has full unrestricted access with no restriction of any kind; the owner-facing UI already tells the owner a block exists; and admin-created students are pre-confirmed so the primary onboarding path is unaffected. Note honestly that the AdminStudentsPage copy ("This student may not be able to sign in until this is fixed") is hedged and was not by itself proof that a block was intended — the user's direct confirmation is what now makes BLOCK a settled requirement rather than a planning inference.

A test fixture producing an unconfirmed session must be added as part of this step (see hard prerequisite above); browser validation of #26 is blocked until it exists.

### Step 5 — Batch E: #27 verification-first

Owner: browser-validator, then T1 only if reproduced.

Attempt reproduction at the standard three viewports plus at least one genuinely short-height profile (e.g. 1024x500 or 1280x480). If not reproduced, "close as unreproduced" is the deliverable — record exact viewports and steps attempted. No fix is authorized without a reproduction.

### Step 6 — #25 fix plus post-#23/#24 verification

Owner: T1, then browser-validator.

Implement the page-level `h1` on `PublicCatalogPage`'s non-success branch, then re-run axe `page-has-heading-one` on both the loading and error sub-states at all three viewports. The `h1` fix is independent of #23/#24 and ships regardless. The "verify whether it still needs its own fix" question is answered: it does, because the existing `h1` sits inside the truthy branch only.

### Step 7 — #15/#16 side-effect report

Owner: browser-validator. Depends on Step 2.

Explicitly re-test `RegisterStudentModal`'s forward-Tab wrap (#16's symptom) and report whether it is now resolved. Do not close #16 and do not assume — report the observed result to the orchestrator for the user.

## Interfaces and data

No database migration. No schema change. No new grant or RLS policy — explicitly prohibited for #23/#24.

One internal component contract change: `Modal`'s `getFocusableElements` no longer includes the dialog container, and four call-site `suppressDismiss` values flip. `Modal`'s public prop shape is unchanged.

One new component (`EmailUnconfirmedGate`) and one new composition branch in `AuthenticatedApp`, conditional on Step 4a's result.

One new test fixture producing an unconfirmed auth user, added without altering existing seeded rows.

Possible reformatting of the single-line `PublicCatalogPage.tsx`, to be flagged in the diff.

## Acceptance and validation

- TDD-first: a failing test precedes every production edit in Batches B, D, and Step 6.
- `npm test -- --run nativeDialogPolicy` passes at the start and end of every batch. Zero native `alert`/`confirm`/`prompt`/`window.*` variants/`beforeunload` introduced.
- `npm run type-check` and `npm run lint` show no new failures against the Step 0 baseline; pre-existing failures are recorded, not fixed.
- Existing tests that must still pass unchanged: `src/__tests__/Modal-FocusTrap-ShiftTab.test.tsx`, `src/__tests__/issue5BackendContract.test.ts`, `src/__tests__/rlsSecurityRegressionRuntime.test.ts`.
- New tests: Modal reverse-wrap and forward-wrap boundary; Modal empty-focusable-list trap invariant; `RegisterStudentModal-FocusRestore` (Cancel path and full Done round trip); `RegisterStudentModal` stale-error clearing; `EmailUnconfirmedGate` render condition including the owner bypass (Step 4b only).
- Independent Verifier pass required per batch. Browser Validator pass required for every UI-visible batch. A clean console is never pass evidence; every claim needs a rendered screenshot or an observed visible state change.
- Each fixed issue is re-tested against its own filed reproduction steps from a clean `npx supabase db reset`.

## Risks and rollback

| ID | Severity | Risk | Mitigation |
|----|----------|------|------------|
| R1 | High | Security regression from acting on #23/#24's incorrect filed root cause. Granting anon SELECT on `public.courses` would expose unpublished and non-catalog courses. | The grant approach is prohibited by this plan; the fix is client-side only. `issue5BackendContract.test.ts:142-145` and `rlsSecurityRegressionRuntime.test.ts` act as the deterministic guard, and any new migration touching anon grants is an automatic blocker. |
| R2 | High | #26 changes an authentication boundary and could lock out the owner. | Unconditional owner bypass in the render condition; a dedicated owner-exemption validation journey (verify against a disposable copy with the owner's `email_confirmed_at` nulled, never the committed seed); mandatory blocking `CODE_REVIEW` on the diff; Step 4a gates the whole approach. |
| R3 | Medium | The shared Modal focus-trap change touches all eleven modal call sites at once. | TDD-first boundary tests, the empty-list invariant guard, preserving the existing trap test unchanged, and a full modal keyboard/focus sweep in browser validation. |
| R4 | Medium | Relaxing `suppressDismiss` on two destructive modals could enable accidental dismissal. | Dismissal at that point is pure cancel with zero side effect; the typed-guard confirmation still protects the destructive action itself; the two one-time-secret reveals keep full suppression. |
| R5 | Medium | #19 could be a fixture gap misread as a code defect, wasting effort or producing a cosmetic fake fix. | The Step 3 evidence gate, and an explicit prohibition on inventing a fallback percentage or seeding data to make the dashboard look populated. |
| R6 | Medium | The #15/#16 coupling means proceeding resolves a reserved issue's symptom as a byproduct. | The user confirmed proceeding (Option 1); Step 7 still reports rather than assumes the outcome, and this plan does not authorize closing #16. |
| R7 | Low | Vite port drift. | Capture the actual printed URL in Step 0. |
| R8 | Low | Docker or Supabase unavailable. | Step 0 is a hard blocker; report rather than degrade. |
| R9 | Low | `PublicCatalogPage` reformatting inflates the diff. | Flag it explicitly for the Verifier. |

**Rollback:** no migration and no destructive database operation, so `npx supabase db reset` fully restores fixture state and `git restore`/branch revert fully reverts code. Each batch is an independently revertable unit. No commit, push, PR, or deploy is authorized by this plan.

## Assumptions and decisions

**Safe assumptions:** local Supabase + Docker is the intended backend; the seeded password is `password`; `npm run dev` is the target; `session.user.email_confirmed_at` is readable client-side (flagged as an engineering feasibility check if not); ReassignModal's last focusable control before Assign is Cancel, with the spec written generically so it holds regardless.

**Decisions resolved by the user, direct interactive-session response to the orchestrator on 2026-08-29, exact reply "1. a. 2. block":**
1. BLOCK rather than allow-with-visible-warning for #26 — confirmed as the target outcome regardless of enforcement layer.
2. Option 1 on the #15/#16 tension — proceed with the combined shared-Modal fix now; #15 is firmly in Batch B (Step 2).

3. Outcome-(a) seeding decision for #19 (dashboard progress) — resolved by the user, direct interactive-session response to the orchestrator on 2026-08-29. The orchestrator relayed Step 3's investigation findings (confirmed outcome (a): zero `student_lesson_progress` rows, dashboard computation correct given empty data — a fixture/seed gap) and asked the required gated question. User's exact reply: "do a realistic seed." This authorizes seeding realistic `student_lesson_progress` data into `supabase/seed.sql` as a data-only addition (no migration, no schema change), per Step 3's original constraint that any such fix is data-only.

**Decisions the plan does not make and that require the user:**
- The #19 outcome-(a) question of whether to seed realistic progress data, after Step 3 reports — **resolved**, see decision 3 above.
- Any re-scoping that Step 4a's result forces within the block requirement (Step 4a determines only which branch of Step 4b applies; it does not reopen whether #26 must block).

**Approvals still required:** explicit user approval of this plan before any engineering writer begins.

## Browser UI dialog policy

Required and binding. No native `alert`, `confirm`, `prompt`, any `window.*` variant, or `beforeunload` anywhere. All acknowledgement and confirmation use the app-owned `src/components/Modal.tsx` primitive; validation is inline. Deterministic source scan: `npm test -- --run nativeDialogPolicy` (`src/__tests__/nativeDialogPolicy.test.ts`) at the start and end of every batch. Every modal touched gets the full open-focus / Tab / Shift+Tab trap / Escape-per-verdict / focus-restore protocol. Any violation is an automatic S1 blocker.

## Browser UI validation

- **Target surface:** browser-web-ui (Chrome-first via `mcp__claude-in-chrome__*`; Atelier `mcp__atelier__*` for deterministic screenshot, a11y, and contrast evidence).
- **Launch/readiness:** `cd H:\CommandCenter\orchestrator\lizbeth_spanish` → `npx supabase start` → `npx supabase db reset` → `npm run dev`. Ready when Vite prints its local URL and the login page renders.
- **Base URL:** the URL Vite actually prints (default `http://localhost:5173`; the QA sweep observed 5174 — capture, never hardcode).
- **Fixture/reset:** `npx supabase db reset` before each batch and at the end. Accounts from `supabase/seed.sql`, all with password `password`: `owner@test.local` (owner), `student1`–`student7@test.local`, `fullaccess@test.local`. Corrected fact: no seeded account is unconfirmed, so #26's journey requires a new disposable unconfirmed fixture and is blocked until one exists.
- **Journeys (per batch, per the design handoff's browser validation brief):** dismiss policy across all six `suppressDismiss` call sites; ReassignModal focus-trap reverse and forward wrap; ReassignModal layout collision; RegisterStudentModal focus restore via Cancel and via the full Done round trip; stale-error clearing on one keystroke; the EmailUnconfirmedGate blocked/refresh/URL-navigation journey plus the owner-exemption journey; anonymous `/courses` and `/courses/:id`; axe `page-has-heading-one` on both non-success sub-states; and the `/feedback` scroll check.
- **Viewport profiles:** 1440x900, 768x1024, 390x844 for everything, plus at least one genuinely short-height profile (e.g. 1024x500 or 1280x480) for #27 only.
- **Visible outcomes:** a rendered screenshot at each asserted state — catalog populated for an anonymous visitor; each modal closing or not closing per its verdict, with the header X present or absent as specified; focus visibly on the named control at each boundary; ReassignModal option text collision-free at all three viewports; the alert text gone after one keystroke; the gate rendered with focus on its heading and surviving refresh; the owner never seeing the gate; a visible `h1` on both non-success sub-states; and no blank frame at any scroll position. Console cleanliness is explicitly not accepted as pass evidence.
