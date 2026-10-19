# Lizbeth Spanish — Issue #67: Owner Settings Forced-Colors Coverage

Status: APPROVED — approved by user blanket instruction, 2026-09-02 session (see Approval gate)

Task ID: issue67-forced-colors-owner-settings
Plan ID: lizbeth-spanish-issue67-owner-settings-forced-colors
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub remote `lebobo88/lizbeth-spanish`)

## Outcome and audience

Close the forced-colors (Windows High Contrast) accessibility gap in `src/pages/OwnerSettingsPage.css` so that every selector in that file declaring its own `border` and/or `box-shadow` has an intentional, convention-consistent forced-colors treatment.

This stylesheet is imported by `OwnerSettingsPage`, `BusinessSettingsPage`, and `BrandDesignPage`, so all three owner/admin-facing pages benefit. This work resolves GitHub issue #67.

Audience: the engineering writer (T1) who will implement this plan, and the user who must approve it before execution.

## Scope

**In scope:**
- Additive `@media (forced-colors: active)` rules in `src/pages/OwnerSettingsPage.css` only.
- The two static regression checks specified under Acceptance and validation, added as one new test file.

**Non-goals:**
- No change to rendering outside forced-colors mode.
- No new design tokens, no new colors.
- No DOM, copy, or component changes.
- No visual-invalid treatment added to the base (non-brand) `input[aria-invalid="true"]`.
- No modification of `App.css` — **AMENDED 2026-09-03.** This deferral was overtaken by execution evidence: the live GitHub issue #67's actual literal ask targets the bare `.owner-settings-page` selector sourced from `App.css:706` (affecting `OwnerSettingsPage.tsx` and `BusinessSettingsPage.tsx`), not only the `OwnerSettingsPage.css`-only scope this plan originally described. T1 correctly halted execution and returned `JOB_BLOCKED: Plan stale` rather than silently expanding scope. The orchestrator reviewed the stop, determined the `App.css` fix is purely additive and low-risk (one new `@media (forced-colors: active) { .owner-settings-page { box-shadow: none; border-color: ButtonText; } }` block appended, with no existing selector or declaration removed or modified), and directed T1 to implement both the original 10-item `OwnerSettingsPage.css` scope and the `App.css` fix in the same pass, under the user's standing blanket "just do all the work" instruction recorded in Approval gate below. See the Amendment record at the end of this document for the full account.
- No change to the existing forced-colors block at lines 173-178 or the responsive block at lines 194-205.

## Repository findings

**Material premise correction.** The issue as originally relayed claims `OwnerSettingsPage.css` has "zero `@media (forced-colors: active)` blocks file-wide." This claim is false and was independently verified false by both the Planner and the Design Reviewer. Lines 173-178 already contain a forced-colors block guarding `.owner-settings-page.owner-settings-page--brand` with:

```css
box-shadow: none;
border-color: ButtonText;
```

This block was added during the earlier issue #43/#44 remediation. The real gap is that this is the *only* guarded selector in the file while roughly a dozen other bordered or shadowed selectors remain unguarded. This plan's work is therefore "extend coverage," not "create the first forced-colors block." Step 0 requires T1 to re-verify this correction against the live issue body before making any edit.

**House convention (ratified, test-enforced across sibling stylesheets).** The codebase has four settled forced-colors roles:

| Role | System-color pairing |
|---|---|
| plain-container | `box-shadow: none; border-color: ButtonText` |
| form-field | `border-color: FieldText` / `background-color: Field` |
| badge-like-chip | `background: Canvas` / `color: CanvasText` |
| primary-button | `color: ButtonText` / `background: ButtonFace` |

`forced-color-adjust` is deliberately reserved for the gradient/interactive-control family (`WeekCard`, `SegmentLedger`, `Control`, `BandRoadmap`, `MetricPlate`, `OwnerLedgerRow`) and must **not** be used in `OwnerSettingsPage.css`.

Precedent files and lines verified for this convention:
- `src/components/ui/Field.css:76-79` and `:81-83`
- `src/components/ui/Control.css:158-169` and `:190-193`
- `src/components/ui/Badge.css:61-65`
- `src/components/ui/AccountStatusPill.css:38-42`
- `src/pages/AdminStudentsPage.css:484-497` (and its unguarded border-left banners at `:5-12`, `:196-201`)
- `src/pages/OwnerDashboardPage.css:113-129`
- `src/pages/WeekDetailPage.css:177-187`
- `src/pages/RoadmapPage.css:100-111`
- `src/components/FeedbackForm.css:171-193`
- `src/components/ForcedPasswordChangeGate.css:181-186`
- `src/components/LoginForm.css:183` and `:363`
- `src/components/FlashcardsViewer.css:301`
- `src/components/MetricPlate.css:93`
- `src/components/FeedbackLedgerRow.css:245`
- `src/components/AdminShell.css:49`
- `src/components/BandRoadmap.css:124`
- `src/components/AccessibilitySettings.css:202`
- `src/components/journal/journal-devices.css:96` and `:160`

**Shared-selector check (verified).** `.owner-settings-field input, .owner-settings-field textarea` are plain `<input>`/`<textarea>` elements, not routed through `Field.css` or `Control.css`. No Field or Control component import appears in `OwnerSettingsPage.tsx`, `BusinessSettingsPage.tsx`, or `BrandDesignPage.tsx`. These selectors therefore need their own guard; this is not a duplicate of existing coverage.

**Cascade-collision check.** `App.css` line 726 declares:

```css
.login-form-container, .demo-section, .admin-shell, .owner-settings-page {
  border-radius: var(--radius-square);
  border: var(--border-width-strong) solid var(--color-ink-800);
  box-shadow: var(--shadow-print);
}
```

`App.css` has zero `@media (forced-colors: active)` blocks file-wide, so the base `.owner-settings-page` border and box-shadow on all three pages remain unguarded. A guard written from `OwnerSettingsPage.css` against a bare `.owner-settings-page` would be an exact specificity tie with `App.css:726`, decided by import order — this is the documented issue #66 failure mode (see the load-bearing comment at `OwnerSettingsPage.css:143-158`). This risk is deliberately deferred; see Risks, Risk 2.

## Research evidence

None. This plan relies on local repository evidence only. No external or current-facts question was material to this work.

## Design route

**Route:** compact.

**Reason:** bounded brownfield accessibility CSS applying a ratified, test-enforced house convention with no new visual language. Forced-colors treatment is an explicit design-system accessibility concern under the design contract.

**Agents required:** design-generalist, design-reviewer.

**Prototype:** forbidden.

**Model tier:** sonnet.

**Existing system mode:** preserve.

**Design handoff (selected direction, revision 1):** "Reuse-only — apply the codebase's four ratified forced-colors role conventions verbatim; no new visual language, no new tokens, no visual change outside `forced-colors: active`."

**Design review:** PASS (revision cycle 2). Cycle 1 returned NEEDS_REVISION with four evidence-backed findings: incorrect specificity tuples, a factual misdescription of the brand save-button `:hover` rule, an undisclosed fifth `GrayText` role, and a browser-validation brief that rationalized around broken tooling. All four were corrected in revision 1 and independently re-verified as fixed with no regression.

## Judge route

`PLAN_DUCK` is eligible at the Orchestrator's discretion before approval. Risk is low: this is a single-file, CSS-only change. `PLAN_DUCK` is not required by this plan. No `CODE_REVIEW`, `VERIFICATION_CHALLENGE`, or `VISUAL_REVIEW` trigger is met.

## Ordered work

**Step 0 (blocking precondition, owner: T1).** Run `gh issue view 67 --repo lebobo88/lizbeth-spanish` and read the live issue body.
- Confirm the intended scope matches this plan.
- If the live body still asserts "zero forced-colors blocks file-wide," that premise is factually wrong (lines 173-178 exist); proceed with the corrected scope in this plan and note the correction in the completion evidence.
- If the live body describes materially different work than this plan, return `JOB_BLOCKED` with "Plan stale."

**Step 1 (owner: T1).** Read `src/pages/OwnerSettingsPage.css` in full and re-confirm the current line numbers cited throughout this plan. Line numbers are evidence, not addresses. If the file has shifted, locate each selector by name and record the actual lines.

**Step 2 (owner: T1).** Write the test first, per the project's test-first policy. Add a static regression test following the existing pattern in `src/__tests__/` (see `fjdsAuthenticatedScreensRemediation.test.ts` and `issue3743UnauthenticatedScreensRevalidation.test.ts` for the established file-read-and-assert shape). The test must assert:

(a) The new forced-colors block's source position falls **after** the unconditional rules for:
  - `.owner-settings-page--brand .owner-settings-field input` (line ~315)
  - `.owner-settings-page--brand .owner-settings-field input[aria-invalid="true"]` (line ~329)
  - `.owner-settings-page--brand .owner-settings-save-button` (line ~357)
  - `.owner-settings-page--brand .owner-settings-save-button:hover:not(:disabled)` (line ~370)
  - `.owner-settings-page--brand .owner-settings-success` (line ~382)

(b) No `var(--color-*)` token appears inside any `@media (forced-colors: active)` block in this file.

(c) Each specified selector/declaration pair from Step 3 is present.

Confirm the test **fails** before making the Step 3 CSS change.

**Step 3 (owner: T1).** Add one new `@media (forced-colors: active) { ... }` block as the last rule block in the file, after the final existing rule (currently ending at line 395). Contents, exactly:

1. `.owner-settings-field input, .owner-settings-field textarea`
   ```css
   border-color: FieldText;
   background-color: Field;
   color: FieldText;
   ```
   (per `Field.css:76-79`)

2. `.owner-settings-page--brand .owner-settings-field input`
   ```css
   background-color: Field;
   color: FieldText;
   ```
   (per `Control.css:158-164`'s documented "illegible corrupted white blob" failure mode)

3. `.owner-settings-page--brand .owner-settings-field input[aria-invalid="true"]`
   ```css
   border-style: double;
   ```
   Only this declaration. (per `Field.css:81-83`)

4. `.owner-settings-color-swatch` and `.owner-settings-preview-swatch`
   ```css
   border-color: ButtonText;
   ```
   (per `AdminStudentsPage.css:495`, `OwnerDashboardPage.css:119`)

5. `.owner-settings-preview-swatch--empty`
   ```css
   border-color: ButtonText;
   ```
   Only this declaration. Leave `border-style: dashed` untouched; it is the surviving non-color cue.

6. `.owner-settings-save-button`
   ```css
   border: var(--border-width-rule) solid ButtonText;
   background: ButtonFace;
   color: ButtonText;
   box-shadow: none;
   ```
   (per `Control.css:158-169`)

7. `.owner-settings-page--brand .owner-settings-save-button`
   ```css
   color: ButtonText;
   ```

7a. `.owner-settings-page--brand .owner-settings-save-button:hover:not(:disabled)`
   ```css
   background-color: ButtonFace;
   border-color: ButtonText;
   box-shadow: none;
   ```
   Leave `transform` untouched (layout, not color). This state does declare an authored color pair at lines 370-375; it is not box-shadow-and-transform only.

7b. `.owner-settings-page--brand .owner-settings-save-button:active:not(:disabled)` — **no guard.** Verified to declare only `transform` and `box-shadow`; the box-shadow is already neutralized by item 6.

8. `.owner-settings-preview`
   ```css
   box-shadow: none;
   border-color: ButtonText;
   ```
   The defensive `box-shadow: none` matches `AdminStudentsPage.css`'s `.enrollment-item` pattern.

9. `.owner-settings-preview-mark`
   ```css
   background: Canvas;
   color: CanvasText;
   border-color: CanvasText;
   ```
   (per `Badge.css:61-65`, `AccountStatusPill.css:38-42`)

10. `.owner-settings-page--brand .owner-settings-success`
    ```css
    background: Canvas;
    color: CanvasText;
    border-color: CanvasText;
    ```

Include a disclosure comment above the block explaining the source-order reasoning (see Risks, Risk 1).

**Step 4 (owner: T1).** Deliberately add **no** guard for:
- `.owner-settings-permission-denied` (lines 19-24)
- the base `.owner-settings-success` banner (lines 124-130)

Both are 4px `border-left` / no-`box-shadow` status stripes, and the ratified precedent (`AdminStudentsPage.css:5-12` and `:196-201`; `FeedbackForm.css:171-187`) leaves this exact shape unguarded everywhere in the codebase.

Also add no guard for the text/layout-only selectors:
- `.owner-settings-field-error`
- `.owner-settings-error`
- `.owner-settings-intro` and its brand variant
- `.owner-settings-eyebrow`
- `.owner-settings-brand-h1`
- `.owner-settings-preview-label`
- `.owner-settings-preview-name`
- `.owner-settings-page--brand .owner-settings-field label`
- `.owner-settings-logo-helper`
- `.owner-settings-action-row`
- `.owner-settings-preview-text`
- `.owner-settings-color-preview`
- `.owner-settings-field label`

This list was independently verified complete against the full file.

**Step 5 (owner: T1).** Run the new test, the full existing test suite, and the production build. Return evidence.

**Step 6 (owner: verifier).** Independent read-only verification of scope, diff, and check results.

## Interfaces and data

None. This is a CSS-only change with no contract, migration, or data change.

## Acceptance and validation

- The new regression test from Step 2 passes, and demonstrably failed before Step 3.
- No `var(--color-*)` token appears inside any `@media (forced-colors: active)` block in this file — only system-color keywords (`ButtonText`, `ButtonFace`, `FieldText`, `Field`, `Canvas`, `CanvasText`). `GrayText` must not appear.
- No `forced-color-adjust` appears anywhere in this file.
- The new block is the last rule block in the file.
- The existing block at lines 173-178 and the responsive block at lines 194-205 are byte-identical to before this change.
- The compound selector `.owner-settings-page.owner-settings-page--brand` (line 159) is unchanged and not simplified.
- The full existing test suite passes.
- The production build succeeds.
- The diff is confined to `src/pages/OwnerSettingsPage.css`, `src/App.css`, plus the one new test file. (Amended 2026-09-03 to add `src/App.css` — see Non-goals, Risk 2, and the Amendment record at the end of this document.)
- An independent verifier pass is required. T1 cannot self-approve.

## Risks and rollback

**Risk 1 (high likelihood if ignored; the load-bearing risk) — source-order cascade collision.** Items 2, 3, 7, 7a, and 10 each target the exact same selector, textually, as an unconditional un-media-gated rule already declared later in the file (lines ~315, ~329, ~357, ~370, ~382). An identical selector has identical specificity to itself, so the tie is decided by source order, not by `@media` membership. Placing the new block anywhere before those rules would let them silently win in forced-colors mode, making the guard dead code. This is the #66/#44 defect family, already caught live once by Browser Validator and documented in the file's own comment at lines 180-193.

*Mitigation:* the new block must be last in the file, and the Step 2 test asserts this positionally.

**Risk 2 (medium) — `App.css` cross-file gap — RESOLVED 2026-09-03, not deferred.** `App.css:726`'s base `.owner-settings-page` border and box-shadow previously lacked an intentional forced-colors treatment on all three pages, and `App.css` had zero forced-colors blocks file-wide. This risk is now resolved within this plan's execution rather than left open: the live issue #67 actually required this fix, and the orchestrator authorized T1 to add one additive, narrowly-scoped `@media (forced-colors: active) { .owner-settings-page { box-shadow: none; border-color: ButtonText; } }` block to `App.css`, guarding only the `.owner-settings-page` selector without touching the shared `.login-form-container, .demo-section, .admin-shell, .owner-settings-page` rule's other selectors or any existing declaration. See the Amendment record at the end of this document.

*Original deferral rationale (superseded):* `App.css`'s blast radius (`.login-form-container, .demo-section, .admin-shell, .owner-settings-page`) was believed to exceed this issue's scope, and the project generally treats `App.css` cascade fixes as their own dedicated remediation cycles (see `App.css` comments at lines 797-824). This general practice still applies to future `App.css` changes; it was overridden here specifically because the live issue's actual scope required this one additive, low-risk block.

**Risk 3 (low-medium) — item 7a is a genuinely novel application.** No sibling file guards a color-changing interactive hover state. It reuses existing role keywords rather than inventing a new pairing, but it is the highest-uncertainty item in this plan and is the primary target of the deferred screenshot follow-up described under Browser UI validation.

**Risk 4 (low, disclosed and unverified) — border-left status stripes.** The "no guard needed" decision for the border-left status stripes relies on browsers auto-substituting authored border-color under forced colors. This is inferred from consistent sibling precedent and written CSS Forced Colors Mode behavior, but has not been empirically confirmed live by any party this session.

**Rollback.** Revert the single CSS block and the one test file. The change is purely additive with no effect outside forced-colors mode, so rollback is trivial and carries no data or contract consequence.

## Assumptions and decisions

- **Assumption requiring user confirmation:** issue #67's real intent is "extend forced-colors coverage in `OwnerSettingsPage.css`," notwithstanding its factually incorrect "zero blocks file-wide" premise.
- **Decision requiring user confirmation — RESOLVED 2026-09-03.** The `App.css` gap was originally recorded here as deferred to a separate follow-up rather than fixed in this plan. It is now resolved and included in this plan's execution instead of deferred: the orchestrator determined the additive `App.css` fix was low-risk and directly authorized by the user's blanket "just do all the work" instruction, so no further per-decision user confirmation was sought before proceeding. See the Amendment record at the end of this document.
- **Open cosmetic decision (implementer's discretion, no behavioral effect):** whether to also restate `border-color: FieldText` on item 2 for self-containment.
- **Superseded: standing forward authorization does not cover this plan.** This note previously stated that issue #67 is newly tracked and not one of the originally-named backlog items, so it required explicit fresh per-plan approval. That narrower scoping is superseded, effective 2026-09-02, by the user's direct blanket instruction recorded in Approval gate below. See that section for the operative approval record.

## Browser UI dialog policy

Applicable as a preserved invariant. No dialogs are in scope and none may be introduced. The change must not add `alert`, `confirm`, `prompt`, any `window.*` variant, or `beforeunload`. A deterministic no-native-dialog source scan over the diff satisfies this requirement; since the diff is CSS plus one test file, the scan is expected to be trivially clean.

## Browser UI validation

**Deliberate, reasoned exception:** real-browser confirmation is not required to merge this change, and the Browser Validator gate is not the primary evidence here. This rationale was argued on its own merits and independently endorsed by the design reviewer:

1. Every color-role pairing is copied verbatim from a ratified sibling rule, several of which carry comments recording that they were already live-screenshot-confirmed by Browser Validator after an earlier mismatched-color bug. The novel-pairing risk class that browser validation exists to catch does not apply here.
2. The one genuinely load-bearing risk, the source-order cascade tie, is a deterministic, statically verifiable CSS fact that a screenshot cannot add confidence to, and is better caught by the positional regression test in Step 2.
3. Forced-colors mode replaces authored colors with system values, so correctness here is established by source-level pattern-matching against the sibling convention, not by `getComputedStyle` color-value inspection.

**Primary gate:** the two static checks in Step 2 plus the independent verifier pass.

**Separately disclosed open risk, not a justification for the exception above:** this session's browser tooling has failed repeatedly. This should be escalated as an infrastructure problem and must not be treated as evidence that visual confirmation is unnecessary.

**Deferred follow-up once tooling is reliable:** capture one forced-colors screenshot of `BrandDesignPage` (which exercises items 2, 3, 6, 7, 7a, 9, and 10 together), observing specifically the interactive hover state (item 7a) and the two badge-like chips (items 9, 10), and if practical also the unguarded border-left status stripes (Risk 4). The launch/readiness command, base URL, fixture/reset procedure, and viewport profiles will be supplied at that time from the project's standard dev-server configuration; they are not prerequisites for this merge.

## Engineering mode

Standard.

## Team authorization

Not applicable.

## Downstream owner

engineering-fleet.

## Approval gate

**Approved.** This plan's design chain (see Design route above) had flagged that its narrower "standing forward authorization does not cover this plan" note required a fresh, explicit per-plan user approval before T1 execution. That narrower requirement is superseded as of 2026-09-02, within the same user session, by the user's direct, unambiguous blanket instruction:

> "just do all the work. i don't care which order you do it in. it all needs to be done."

This is a direct instruction from the user (not a teammate or agent relay) and is treated as explicit approval of this plan. It supersedes the plan's own narrower per-plan-approval flag recorded above under Assumptions and decisions.

**Scope of this blanket approval, as recorded by the orchestrator this session:**

- It covers this plan (issue #67) in full, and extends to all other subsequent remaining backlog/follow-up work identified during this same session, specifically including: issue #10's remaining scope, issue #41's verification pass, the owner-settings-page design question, this issue #67, and any further genuine defects found during this session's work.
- The user separately and explicitly approved a Playwright CLI fallback for browser validation this session ("playwright cli is fine as a fall back"), which applies wherever this plan's or related plans' browser-validation steps would otherwise stall on unavailable tooling.
- The orchestrator will continue to present each unit of work in summary form for visibility as it completes, but will not pause to wait for an individual per-plan approval reply before proceeding to the next unit of work, per this explicit instruction.

**What this blanket approval does NOT waive:**

- It does not waive the independent Verifier pass required by this plan (Ordered work, Step 6; Acceptance and validation).
- It does not waive the Browser Validator gate policy recorded under Browser UI validation above (Playwright CLI is an approved fallback transport for that gate, not a waiver of the gate itself).
- It does not waive any applicable Codex judge checkpoint under `docs/JUDGE-CONTRACT.md`.
- It does not authorize commit, push, pull request creation, deployment, plugin installation, permission grants, or MCP server additions; those remain prohibited without a separate explicit user request, per the orchestrator's operating contract.

The status header above has been updated to APPROVED to reflect this record.

## Amendment record — 2026-09-03: App.css scope amendment

**What changed.** During execution, T1 read the live GitHub issue #67 body per Step 0 of Ordered work and found its actual literal ask was a forced-colors guard for the bare `.owner-settings-page` selector sourced from `App.css:706` (affecting `OwnerSettingsPage.tsx` and `BusinessSettingsPage.tsx`) — not the `OwnerSettingsPage.css`-only, 10-item scope this plan had originally specified. This plan's own Non-goals section had explicitly deferred any `App.css` modification as a separate follow-up. T1 correctly identified this mismatch and returned `JOB_BLOCKED: Plan stale` rather than expanding scope unilaterally.

**Why it changed.** The orchestrator reviewed T1's blocked report and the underlying evidence, and determined:

1. Both pieces of work are legitimate parts of closing issue #67 as it actually reads live, not as this plan had originally paraphrased it.
2. Both are low-risk. The `App.css` fix is purely additive: one new `@media (forced-colors: active) { .owner-settings-page { box-shadow: none; border-color: ButtonText; } }` block appended to the file, with no existing selector or declaration removed or modified.
3. The user's standing blanket instruction from this session — "just do all the work. i don't care which order you do it in. it all needs to be done." — already covers issue #67's full, correctly-scoped work, including a low-risk fix the plan had not originally anticipated, without requiring a fresh pause for individual per-decision approval.

**What was authorized.** The orchestrator directed T1 to implement both the original 10-item `OwnerSettingsPage.css` plan and the additive `App.css` fix in the same execution pass. This is recorded here as an orchestrator-authorized scope amendment made under the user's explicit, standing blanket instruction — not as an ungoverned deviation from an approved plan. It does not waive the independent Verifier pass, the Browser Validator gate policy, or any applicable Codex judge checkpoint; those requirements from Approval gate above continue to apply unchanged to the amended scope.

**Sections updated to reflect this amendment:** Non-goals; Risk 2; Assumptions and decisions ("Decision requiring user confirmation"); Acceptance and validation (diff-confinement criterion).
