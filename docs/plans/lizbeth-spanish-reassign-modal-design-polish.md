# Lizbeth Spanish — Reassign Modal Design Polish

**Status: Approved**

- Plan ID: `lizbeth-spanish-reassign-modal-design-polish`
- Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish`
- Engineering mode: standard
- Team authorization: not applicable
- Downstream owner: engineering-fleet
- Commit authority: no

## Outcome and audience

A minimal, evidence-grounded visual polish of the "Assign to Band" modal (`ReassignModal`) so it renders in the app's real warm workbook palette with correct interaction states, plus one queued follow-up engineering fix. This plan was triggered by the user's direct reaction to a production screenshot ("that 'assign to band' modal is UGLY") and their explicit request to loop in the design fleet using Atelier MCP.

Audience: the engineering writer implementing this plan, and the user approving it.

## Scope and non-goals

### In scope

Five CSS edits inside `H:\CommandCenter\orchestrator\lizbeth_spanish\src\components\AdminStudentModals.css`, plus one two-line JSX cleanup in `AdminStudentModals.tsx`, plus one separate small follow-up import fix in `RegisterStudentModal.tsx`.

### Not in scope

- No new design tokens.
- No redesign.
- No change to the two-radio-card interaction pattern.
- No change to `Modal.tsx` / `Modal.css` focus-trap, keyboard, or ARIA behavior.
- No copy changes.
- No app-wide undefined-token remediation.
- No changes to `AdminStudentsPage.css`.
- No reopening or duplication of already-verified Batch A or Batch B remediation work.

This plan is additive and bounded.

### Explicitly prohibited

Do **not** add a `.form-error` rule to `AdminStudentModals.css`. See "Corrected finding on `.form-error`" below — this was raised and rejected during the design review cycle for this plan.

## Repository findings

All findings below were verified during planning, independently by two agents (design-generalist and design-reviewer, both Sonnet), and are reproduced here without softening.

### Already-fixed, out of scope

The prior functional bug — `AdminStudentModals.css` not being imported — is already fixed and independently verified: `import './AdminStudentModals.css';` now exists at `AdminStudentModals.tsx` line 3. This plan does not revisit it.

### Confirmed defect, separate follow-up: `RegisterStudentModal.css` is orphaned

`H:\CommandCenter\orchestrator\lizbeth_spanish\src\components\RegisterStudentModal.css` exists but is imported by nothing. A repo-wide grep for the literal string `RegisterStudentModal.css` returns zero matches, and `RegisterStudentModal.tsx` imports only React and `Modal`. This is the same defect class as the already-fixed `AdminStudentModals.css` bug. It is handled as Step 5 below, a separate follow-up that does not block Steps 1-4.

### Confirmed: several referenced CSS custom properties are never defined

`--color-ink-600`, `--color-surface-50`, `--color-surface-300`, `--color-surface-400`, `--color-error-50`, `--color-error-600`, `--color-warning-600`, and `--color-primary-500` are never DEFINED anywhere in the repository. Every occurrence is a `var(--token, #fallback)` reference, so the hardcoded generic Tailwind-style fallback hex is what actually renders, not the app's warm palette. This spans multiple stylesheets including `AdminStudentModals.css`, `RegisterStudentModal.css`, `ForcedPasswordChangeGate.css`, and `AdminStudentsPage.css`.

### Confirmed defined and live app-wide

Via `App.css` line 13 `@import './tokens/field-workbook.generated.css'` and `App.css` `:root`, with `App.css` imported by `App.tsx` line 29:

- `--color-ink-700` (`#504940`)
- `--color-ink-800` (`#3d3530`)
- `--color-paper-200` (`#f0ebe2`)
- `--color-brass-600` (`#866843`)
- `--motion-easing-standard` (`cubic-bezier(0.2, 0, 0, 1)`)
- `--color-focus-ring` (`#0284c7`, defined at `App.css` line 36)

All five CSS edits in Step 1 reuse only these tokens. No new token is introduced.

### Corrected finding on `.form-error`

`.form-error` is already styled and must be left alone. These components use side-effect `import './X.css'`, not CSS Modules, so `.form-error` is a global class. It is defined at `ForcedPasswordChangeGate.css` line 92, imported by `ForcedPasswordChangeGate.tsx` line 5, which `App.tsx` imports statically and unconditionally at line 11 (a normal ES import, not `React.lazy`). With no code-splitting boundary, `.form-error` is in the global stylesheet on every page load, so the `.form-error` elements in `AdminStudentModals.tsx` (lines 56, 227, 331, including `ReassignModal`'s own error paragraph) already render with padding `.75rem`, `#fff5f5` background, `1px solid #fecaca` border, `#7f1d1d` text.

Adding a competing same-specificity declaration to `AdminStudentModals.css` would make the winner depend on bundler import order — this is why the prohibition above exists. The orphaned-`.form-error` problem is real only in the unimported `RegisterStudentModal.css` (see Step 5).

### Contrast evidence

Via `mcp__atelier__contrast_check`: `#9ca3af` (current `.choice-option:hover` border fallback) on `#faf8f4` (paper-100) measures 2.39:1, **failing WCAG 1.4.11** non-text contrast, which requires at least 3:1 for a UI component boundary. Separately, `#4b5563` on `#faf8f4` measures 7.12:1 and passes AA — so the ink-600 swap in Step 1a is a palette-consistency fix, not a contrast fix. The border-color swap in Step 1b is what actually fixes the 2.39:1 failure.

### `AdminStudentsPage.css` — confirmed to exist, disclosed consequence

`AdminStudentsPage.css` does exist at `H:\CommandCenter\orchestrator\lizbeth_spanish\src\pages\AdminStudentsPage.css` and still uses the same cool-gray fallbacks at roughly 20 call sites. (An earlier "file does not exist" read error during planning was corrected.) Consequence to disclose plainly: after this fix ships, the modal will render warm while its parent page chrome stays cool — an intra-feature palette split. This is intentionally left out of scope for this plan; see "Risks and rollback."

## Research evidence

None. No external or current-evidence question arose. All findings are local and verified in-repository.

## Design route and design handoff

**Design route: compact.**

- Reasons: bounded brownfield polish of one existing modal with an existing CSS file and existing app-wide token layer; no new screen, flow, or visual direction. `existing_system_mode: preserve`.
- Agents used: `design-generalist` (Sonnet), `design-reviewer` (Sonnet).
- Prototype: forbidden.
- Model tier: Sonnet.

**Design handoff: passed**, revision 1, compact profile, produced by `design-generalist`. Its substance is reproduced in full in "Ordered work" below, since every user-visible change in this plan is a direct instruction from that handoff.

**Design review: passed (verdict PASS)**, from an independent `design-reviewer`, after one evidence-backed NEEDS_REVISION cycle. The first review pass raised two high-severity findings — a factually wrong `.form-error` recommendation (now the corrected finding above) and a doubled focus ring (resolved by the outline-free approach in Step 1c) — plus two lower-severity items. All four were resolved in revision 1, and the re-review found no new defect, no new token, and no scope violation.

**Reviewer's disclosed limits, to state honestly:** the reviewer did not run a browser. On the re-review pass, it verified the underlying CSS/cascade mechanics directly against the repository, but it had only a structured description of the revised document rather than its literal text — so its sign-off on document wording is weaker than its sign-off on the technical mechanics.

## Judge route

No Codex judge checkpoint required. This is low-risk, single-file CSS polish with an independent design review already passed and a mandatory Browser Validator gate downstream (Step 4).

## Ordered work

### Step 1 (owner: engineering writer) — five edits in `AdminStudentModals.css`

File: `H:\CommandCenter\orchestrator\lizbeth_spanish\src\components\AdminStudentModals.css`.

**1a. Lines 8 and 156 — palette drift on secondary text.**

Replace:

```css
color: var(--color-ink-600, #4b5563);
```

with:

```css
color: var(--color-ink-700, #504940);
```

**1b. Lines 80 and 127 — default border, and lines 133-136 — hover state.**

Default border, replace `var(--color-surface-300, #d1d5db)` with:

```css
border: 1px solid var(--color-ink-700, #504940);
```

Hover state (lines 133-136), replace the block using `var(--color-surface-50, #fafafa)` and `var(--color-surface-400, #9ca3af)` with:

```css
.choice-option:hover {
  background-color: var(--color-paper-200, #f0ebe2);
  border-color: var(--color-ink-800, #3d3530);
}
```

The border-color swap here is what fixes the 2.39:1 WCAG 1.4.11 failure documented above.

**1c. New interaction-state rules — deliberately outline-free to avoid a doubled focus ring.**

Add:

```css
.choice-option:focus-within {
  border-color: var(--color-focus-ring, #0284c7);
}

.choice-option:has(input:checked) {
  border-color: var(--color-brass-600, #866843);
  background-color: var(--color-paper-200, #f0ebe2);
}
```

Rationale to preserve in the diff or commit context: `App.css` lines 124-131 already apply `input:focus { outline: 2px solid var(--color-focus-ring); outline-offset: 2px; }` to the radio inside `.choice-option`. A card-level `outline` would fire at the same instant and render two concentric rings. Dropping the card-level outline leaves the native radio ring as the single outline while the card still changes border color. The design reviewer confirmed this satisfies WCAG 2.4.7, because the untouched native ring on the actually-focused element is the compliant indicator, and the card border shift from `#504940` (warm brown) to `#0284c7` (saturated cyan-blue) is a strong supplementary hue cue. This must still be confirmed visually at the browser validation gate (Step 4), not assumed from this reasoning alone.

**1d. Line 130 — motion fix.**

Flagged by `mcp__atelier__design_critique` rule `layout-transition`. Replace:

```css
transition: all 0.2s;
```

with:

```css
transition: background-color 0.2s var(--motion-easing-standard, cubic-bezier(0.2, 0, 0, 1)),
            border-color 0.2s var(--motion-easing-standard, cubic-bezier(0.2, 0, 0, 1));
```

**1e. Line 87 — `.confirmation-input:focus`** (used by `HardDeleteStudentModal` and `WipeSaveModal`).

Replace:

```css
outline: 2px solid var(--color-primary-500, #3b82f6);
```

with:

```css
outline: 2px solid var(--color-focus-ring, #0284c7);
```

At specificity `(0,2,0)`, this rule currently beats the global `input:focus` rule at `(0,1,1)`, so it overrides the app's branded ring with a generic blue. This edit corrects that.

### Step 2 (owner: engineering writer) — JSX cleanup

File: `H:\CommandCenter\orchestrator\lizbeth_spanish\src\components\AdminStudentModals.tsx`.

Remove the two `<br />` elements at lines 303 and 319. Both `.choice-option strong` and `.choice-option small` are already `display: block` (CSS lines 149-158), so the `<br>` is redundant and adds an extra line box on top of the intended `margin-top: 0.25rem`. Confirmed safe by independent design review. This is the only JSX touch authorized in Steps 1-4.

### Step 3 (owner: verifier) — independent read-only verification

Verify the diff against this plan's scope. The diff must touch only `AdminStudentModals.css` and the two `<br />` lines in `AdminStudentModals.tsx` (Step 5's `RegisterStudentModal.tsx` single import line is verified separately, as it is a distinct follow-up).

### Step 4 (owner: browser-validator) — mandatory live browser validation

This step cannot be skipped or self-approved by the writer. See "Browser UI validation" below for the full brief.

### Step 5 (owner: engineering writer) — separate follow-up, does not block Steps 1-4

Add the missing import to `H:\CommandCenter\orchestrator\lizbeth_spanish\src\components\RegisterStudentModal.tsx`:

```
import './RegisterStudentModal.css';
```

This is an engineering fix, not a design decision. It must receive the same live-browser-verification discipline as the rest of this remediation effort. State explicitly: during this remediation effort, unit-test-only completion claims proved wrong twice, so a passing test suite alone is not sufficient evidence for this step either.

**Conditional design assessment to record alongside Step 5.** Once the import is restored, `RegisterStudentModal` will also need equivalent polish and is **not** a pass as-is. It has the identical undefined-token pattern:

- `--color-ink-900` fallback `#111827`
- `--color-surface-300` fallback `#d1d5db`
- `--color-primary-500` / `--color-primary-600` / `--color-primary-700` fallback blues `#3b82f6` / `#2563eb` / `#1d4ed8`
- `--color-success-600` fallback `#10b981`
- `--color-warning-50` / `--color-warning-600` fallback `#fffbeb` / `#f59e0b`

Its submit/Copy/Done buttons use `className="demo-button primary ..."`, so `App.css`'s `.demo-button.primary` at two-class specificity correctly beats `.temp-password-copy`'s single-class blue, and they will render on-brand brass, not blue. But `.temp-password-section`, `.temp-password-display`, and `.temp-password-warning` are covered by no `.demo-button` class and will render with off-palette gray/amber fallbacks. Its warning fallback `#f59e0b` is also internally inconsistent with `AdminStudentModals.css`'s `#d97706` / `#b45309` for the same nominal token family. Its own `.form-error` at its line 30, currently orphaned, would become live with yet a third inconsistent error palette.

This conditional assessment is a record of a known future gap, not authorization to fix it now. Fixing `RegisterStudentModal`'s palette is out of scope for this plan.

## Interfaces and data

None. No API, schema, migration, or data-contract change. CSS and two JSX line deletions only (plus, for Step 5, one JSX import line addition).

## Acceptance and validation

- Existing test suite passes, including `src/__tests__/AdminStudentModals-CssImport.test.ts` (the GitHub issue #14 / LS-QA-003 regression test) and `src/__tests__/RegisterStudentModal.test.tsx`.
- Verifier confirms the diff touches only `AdminStudentModals.css` and the two `<br />` lines in `AdminStudentModals.tsx` (and, for Step 5, only the single import line in `RegisterStudentModal.tsx`).
- Confirm no new token name was introduced and every replacement value resolves to a token already defined in `field-workbook.generated.css` or `App.css` `:root`.
- Browser Validator gate must pass. Live visual confirmation was explicitly UNVERIFIED at design time: the design agent has no Bash and no browser driver, so no dev server could be started and no screenshot was taken. State plainly that no screenshot was fabricated or simulated, and that live confirmation is deferred entirely to the Step 4 gate.

## Risks and rollback

- **Risk:** `:has()` requires Chrome/Edge, Safari 15.4+, Firefox 121+. No legacy-browser requirement has been stated for this project.
  - **Mitigation/fallback:** toggle a `selected` class from the `choice` state already tracked in `ReassignModal`; that is a JSX change and is optional, not required. The visual result — brass border plus paper-200 fill — should be identical either way.
- **Risk:** the card-level focus cue in Step 1c is border-color only.
  - **Mitigation:** the native radio ring is the compliant WCAG 2.4.7 indicator and remains untouched; the design reviewer assessed the supplementary cue as adequately perceivable. Still must be confirmed at the Step 4 browser gate, not assumed.
- **Risk:** intra-feature palette split — warm modal against cool `AdminStudentsPage` chrome.
  - **Disposition:** accepted and disclosed; deliberately out of scope for this plan.
- **Rollback:** revert the single CSS file and the two JSX lines (Step 5's single import line reverts independently). No data, schema, or API surface is touched, so rollback is trivial and carries no migration risk.

## Assumptions and decisions

**Assumptions, not verified at design time (design agent has no Bash or browser access):**

- `owner@test.local` / `password` are valid test credentials for the Browser Validator precondition.
- `:has()` support is acceptable for the target browser matrix, since no legacy requirement was stated.

**Decisions recorded:**

- The two-radio-card interaction pattern is an existing approved product decision and is preserved as-is; this plan does not change it.
- Permitted implementation variation: an implementer may substitute a different already-defined token of equivalent visual weight (for example `--color-ink-800` instead of `--color-ink-700` for the border) if it reads better live, provided it is a real defined token and not a new hardcoded hex. The focus-within fix (Step 1c) may alternatively use the suppression variant — a card-level `outline` plus `.choice-option:focus-within input { outline: none; }` — but not both approaches at once, and whichever is chosen must be verified single-ring at the Step 4 browser gate. Spacing, radius, and typography values are otherwise fixed; no variation is invited there.

**Atelier MCP tooling status**, recorded honestly since the user specifically asked for Atelier to be used:

- `contrast_check` on targeted color pairs succeeded and produced the 2.39:1 WCAG 1.4.11 finding above.
- `contrast_check` in whole-project token-audit mode failed with "No token sources configured. Add token file paths to tokens.sources in atelier.config.json" — a real, unworked-around tool configuration gap, worth fixing separately from this plan.
- `design_critique` succeeded but ran regex-engine-only, with 26 rules explicitly skipped for lack of a browser/DOM/pixel engine; it produced the `transition: all` finding (Step 1d).
- `design_review` succeeded with 57 findings, mostly hardcoded-hex flags on `var(--token, #fallback)` literals, hand-cross-referenced against the real token files to separate true divergence from harmless fallback safety nets.
- `a11y_audit` ran but its results are not meaningful component evidence: axe-core loaded the raw `.tsx` as a bare file rather than a mounted React app, so every violation returned (`document-title`, `html-has-lang`, `landmark-one-main`, `page-has-heading-one`, `region`) is a generic document-shell artifact, not a finding about the modal's DOM.
- `screenshot`, `visual_diff`, and `baseline_update` were not attempted — all need a live URL or local HTML file that this read-only design pass could not produce.

**Open decisions requiring a user or engineering call, recorded but not blocking this plan:**

1. The app-wide undefined-token families (`--color-error-*`, `--color-warning-*`, `--color-primary-*`, `--color-surface-*`, `--color-ink-600`) need a remediation approach — either compile a semantic error/warning/surface tier into `:root` (the primitives already exist as `error.50/400/600` and `warning.50/400/600` in `primitives.json`, they are simply never emitted as custom properties), or replace references file-by-file with the nearest existing warm token. A follow-up plan should cover the token pipeline and affected pages together.
2. Whether `:has()` support is acceptable for the target browser matrix.
3. Whether to realign `ForcedPasswordChangeGate.css`'s `.form-error` colors to the app's real error tokens once defined. Optional, touches a shared second file, deferrable.

**Approval recorded:** approved by rob.hasselbach@gmail.com on 2026-08-29, via direct interactive-session response to the orchestrator. The user additionally directed that the deferred, non-blocking open decision #1 above (app-wide undefined-token remediation) be filed as its own GitHub issue for later follow-up; it is not implemented as part of this plan.

## Browser UI dialog policy

Required. This is browser-rendered React UI. Native `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload` are prohibited. This modal is already an app-owned accessible modal via the shared `Modal` component; nothing in this plan changes that, and keyboard operation, visible focus, and focus trapping must be preserved. A deterministic no-native-dialog source scan is required at the Step 4 gate.

## Browser UI validation

- **Launch/readiness:** start the `lizbeth_spanish` dev server (`npx supabase start`, `npx supabase db reset`, `npm run dev`) and confirm the backend is reachable.
- **Base URL:** the local dev URL once confirmed running.
- **Fixture/reset:** sign in as `owner@test.local` / `password`. Find a student with an active band assignment, unassign them via `UnassignModal` to create a preserved save, then reopen "Assign to Band" on that same student and band to reach the `hasPreservedSave === true` branch of `ReassignModal` — the branch with the two radio cards this work targets.
- **Journeys and visible outcomes:**
  - Choice cards render in warm ink-700 / paper-200 / ink-800 tones, not cool gray, with correct hover treatment.
  - Tab to a radio inside `.choice-option`: exactly one 2px `#0284c7` outline is visible, around the radio, and the card's border color changes with no second concentric outline around the card. This is the specific defect corrected in design revision 1 and must be explicitly confirmed, not assumed.
  - Click a radio: the `:has(input:checked)` selected treatment renders, brass border plus paper-200 fill.
  - Force an error in `ReassignModal`: the pre-existing global `.form-error` styling still renders correctly and is unaffected by this change.
  - On `HardDeleteStudentModal` or `WipeSaveModal`, the typed-confirmation input's focus ring is now branded `#0284c7`, not generic blue.
  - The `<br />` removal did not collapse title and description into one run-on line at any viewport; they still read as two distinct lines via the existing `display: block` rules.
  - Deterministic no-native-dialog scan passes.
- **Viewport profiles:** 1440x900, 768x1024, 390x844.
