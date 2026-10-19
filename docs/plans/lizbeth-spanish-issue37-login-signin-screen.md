# Lizbeth Spanish, Issue #37: Screen — Login / Sign in

Status: Drafted, routed to engineering under the user's standing authorization. This document has not itself been separately approved by the user; the user has granted standing authorization that the orchestrator applies to route this plan to engineering, per the Approval basis recorded below. Approval of this document authorizes only issue #37's scope; it does not authorize any of issues #38-#44.

Plan ID: `lizbeth-spanish-issue37-login-signin-screen`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: `engineering-fleet`
Design route: standard (`design-director`, `ux-architect`, `visual-system-designer`, `design-reviewer`; prototype forbidden; model tier Sonnet; existing-system mode: extend)

## Approval basis

This plan was routed to engineering under the orchestrator's application of the user's standing authorization, not a user-verified per-plan approval. The record below is an orchestrator-applied inference, consistent with the Status line above, and follows the same provenance discipline the #31-#36 plans used.

- **Standing authorization quoted (verbatim, as relayed by the orchestrator):** "didn't i tell you to stop asking me for approval? i told you to keep going until all the gh issues are finished," reinforced by an explicit session goal, "don't stop until all the DS gh issues are implemented and browser validated."
- **Application:** The orchestrator applied this standing authorization to route this plan (issue #37 of `lebobo88/lizbeth-spanish`, the seventh issue in the Field Journal Design System milestone (#31-#44) and the first of the screen-redesign batch, the next issue in the exact dependency chain the user directed continuation through) to engineering without a further live per-plan checkpoint.
- **Provenance label:** this basis reached Scribe entirely through the orchestrator's account of the session; Scribe has not independently observed the quoted user statements. It is recorded here as an orchestrator-applied inference under standing authorization, NOT as a Scribe-verified per-document user approval.
- **Live GitHub issue verification, additional to the plan's own drafting.** The orchestrator independently fetched the live bodies of both issue #37 and issue #10 via `gh issue view` and relayed them directly into Planner's context, satisfying this plan's pre-flight staleness check against the actual current issue text rather than an assumed or cached paraphrase.
- **`PLAN_DUCK` Codex judge checkpoint: not run, by orchestrator determination.** `PLAN_DUCK` was eligible per `docs/JUDGE-CONTRACT.md` once Scribe returned the drafted plan. The orchestrator determined a judge checkpoint was not warranted this time and proceeded directly to approval, reasoning that this plan's scope is moderate and bounded: no data-model or auth-security-critical logic change, visual/composition work only. Planner's own findings support that assessment — issue #35 already migrated the underlying Control/Field primitives, and this issue adds only the missing brand-panel composition plus a bounded, line-confined `App.tsx` amendment (see the plan's own "Right-sizing this issue" and "Scope" sections). This differs from the #35 precedent, where a high-blast-radius `Modal.tsx` change and an issue-#28 closure claim justified running `PLAN_DUCK` in advisory mode. `PLAN_DUCK` checkpoints are reserved for higher-risk, higher-blast-radius plans under this engagement's established pattern; this plan was assessed as not meeting that bar.
- **Design gate.** The design route was Standard (director, UX architect, visual system designer, reviewer; prototype forbidden). The first design review cycle returned `NEEDS_REVISION` with seven findings, two high severity; all seven were resolved in revision 1, and the reviewer returned `DESIGN_REVIEW_RESULT: PASS`.
- **Four notable Planner findings, recorded for the approval record:**
  1. **A real WCAG AA contrast failure in the reference specimen itself.** The reviewer computed relative-luminance contrast of `--color-brass-700` against the panel background (`--color-ink-900`) at 4.06:1, below the 4.5:1 AA threshold for normal text, contradicting the specimen's own literal styling. The plan deliberately deviates from the artboard on this one point, substituting `--color-brass-300` (6.80:1) instead of matching the specimen exactly. This deviation is recorded openly in the plan (see "Brand panel token mapping" and Risk R4) and must not be silently reverted toward the artboard's literal color during implementation or review.
  2. **The issue's own cited specimen line numbers were stale and wrong.** Issue #37 cites specimen lines 73068 (§D.1) and 167431 (§E.1); the specimen file is only 1,595 lines total. Planner independently located the real content at §D.1 lines 580-622 and §E.1 lines 1274-1309 by content search and directed engineering to the corrected locations.
  3. **Scope necessarily extends into `App.tsx` beyond the issue's literal file list.** The brand-panel copy already partly exists in `App.tsx` lines 224-262; building the panel only inside `LoginForm.tsx` would produce two identical `<h1>Learn in the open</h1>` headings, a genuine accessibility and content defect. Planner approved a bounded, disclosed amendment confined to `App.tsx:224-262`, reviewer-confirmed to sweep in no unrelated code.
  4. **Issue #10 cannot be closed by this issue.** Issue #10 ("on student login" / "display the roadmap page as well as a dashboard showing metrics") concerns the post-login landing experience, not the sign-in screen. Repository evidence shows it remains only half-resolved: the student roadmap exists and is the student's landing page, but issue #36's dashboard/metrics work is owner-gated only, so students see zero metrics dashboard. Planner recommends issue #10 stay open and be re-titled for clarity rather than closed by #37; this is recorded in the plan's "Issue #10 disposition" section and explicitly excluded from #37's scope.
- **Date:** 2026-09-01.

---

## Outcome and audience

GitHub issue #37, "Screen: Login / Sign in," is the seventh issue in the 14-issue Field Journal Design System milestone (#31-#44) and the first of the screen-redesign batch (#37-#44, label `design:screen`). It rebuilds the login/sign-in screen and the coupled forced-password-change gate against reference artboards §D.1 (@1440) and §E.1 (@390). It depends on issue #35, which already landed.

Audience: the T1/T2 engineering fleet implementing this plan, then Verifier and Browser Validator gating it.

## Right-sizing this issue

State this prominently, since it is the plan's key framing: issue #35 already migrated `LoginForm.tsx/.css` and `ForcedPasswordChangeGate.tsx/.css` onto the C.1 Control and C.2 Field primitives as part of its auth-flow non-regression contract. This issue is therefore **not** a from-scratch rebuild and **not** a primitive migration. Verified directly: `LoginForm.tsx:90` already renders `Control tier="primary"`, `LoginForm.tsx:103` renders `Control tier="secondary"`, and `LoginForm.tsx:69`/`:81` render `Field`. What genuinely remains is:

1. the specimen's brand-panel composition, which has no counterpart anywhere in production;
2. per-breakpoint sheet elevation for the login card and the gate; and
3. targeted token/semantic corrections.

## Scope

**In scope** — the issue's literal file list plus two evidence-mandated additions:

1. `src/components/LoginForm.tsx` / `.css` — new `.auth-sheet-card` and `.auth-brand-panel`/`.auth-split-layout` composition, error retokenization, quick-select hover fix.
2. `src/components/ForcedPasswordChangeGate.tsx` / `.css` — `.gate-content` sheet elevation, `.form-error` semantic fix, media-query retarget.
3. `src/tokens/field-workbook.generated.css` — four additive font-size tokens only.
4. `src/App.tsx` lines 224-262 only — the `sessionError` and `!session` branches. This file is not in the issue's literal file list; the amendment is required because the brand-panel content already partly exists there (see Planner decision 1 below). No other route or branch in this file may be touched.
5. `src/__tests__/LoginForm.test.tsx` — label-assertion updates only, with written justification (see Planner decision 2 below).

**Non-goals** — explicitly deferred, each with a stated reason:

- Any edit to `src/components/ui/Control.tsx/.css` or `Field.tsx/.css`. These are shipped #35 primitives; they must be consumed, not modified. Every visual requirement they do not natively cover is achieved by layering new selectors in the two in-scope component CSS files, the same pattern already used for `.login-form-quick-select-button`.
- Any edit to `src/App.css:693`'s shared sheet-card rule. Its selector list is `.login-form-container, .demo-section, .band-roadmap, .feedback-form, .admin-shell, .owner-settings-page, .admin-students-page` — changing it would hit six other app surfaces.
- Altering any shipped value in `field-workbook.generated.css`. Additive only.
- Issue #10's student-facing metrics dashboard (see the dedicated section below).
- Reconciling the four documented specimen divergences (see Interfaces and data).

## Verified repository findings

- `LoginForm.tsx` already consumes Control/Field as described in Right-sizing above. `LoginForm.tsx:1-4` import order is React, `Control`, `Field`, then `./LoginForm.css` last — load-bearing for the hover fix (see Interfaces and data).
- `LoginForm.css` is 21 lines with zero `@media` rules. Line 1's sheet uses `--border-width-strong` (2px) + `--shadow-print` (`.3rem .3rem 0rem 0rem #a07e48`, an amber shadow) + `max-width: var(--size-login-max); margin: 0 auto;` where `--size-login-max: 28rem` (`field-workbook.generated.css:97`). Line 2's `.login-form-container h2` rule becomes dead code once this ships. Line 7 is `.login-form-error`.
- `App.css:693`'s shared rule, verbatim selector list above, applies `border: var(--border-width-strong) solid var(--color-ink-800); box-shadow: var(--shadow-print);`. `.auth-sheet-card` is genuinely absent from it, and so is `.gate-content` — both confirmed by the design reviewer. `App.css:755`'s scoped `.forced-password-change-gate .gate-content` sets `border-radius` only and does not collide.
- `App.css:699`/`:726` carry the app's only existing structural breakpoint, 900px (`56.25rem`/`56.24rem`). This plan reuses it rather than inventing a new one.
- `--shadow-sheet: 8px 8px 0 0 #1a1512` (`field-workbook.generated.css:89`) currently has zero consumers repo-wide — this plan is its first real use. `--shadow-card: 5px 5px 0 0 #1a1512` (`field-workbook.generated.css:74`). Both exactly match the specimen literals at `Field Journal DS.dc.html:600` and `:1289`.
- `App.tsx:211-269`: `AuthGate`'s `sessionError` branch (lines 224-245) is evaluated before the `!session` branch (lines 247-262). Both render byte-identical header markup: `.app` > `.app-header` > `.app-header-brand-lockup` (`.app-header-eyebrow` p, `<h1>Learn in the open</h1>` at line 253 in the login branch, `.subtitle` p) + `BrandLogo`. The `sessionError` branch has `role="alert"` on `.session-error` (line 236) and a Retry button with `className="demo-button secondary"` (line 239) — an unmigrated legacy control. Lines 245-247 contain only a closing brace, a blank line, and the `if (!session)` opener, so the 224-262 range sweeps in no unrelated code.
- `ForcedPasswordChangeGate.css`: line 13's outer `.forced-password-change-gate { overflow: auto; }` is load-bearing for zoom/reflow. Lines 16-20's `.gate-content { width:100%; max-width:400px; padding:2rem; }` carry no border and no shadow today. Lines 65-74's `.form-error` uses `color: var(--color-ink-900)` with no error semantics — a real defect. Lines 121-134's `.gate-success` is already fully token-correct and is the mapping's template. Lines 137-149's existing `@media (max-width: 640px)` contains three declarations: outer wrapper `padding: 1rem`, `.gate-content { padding: 1.5rem }`, `.gate-content h1 { font-size: 1.25rem }`. Lines 151-157 are the existing `@media (prefers-reduced-motion: no-preference)` opt-in pattern.
- `Field` already satisfies the C.2 error contract: `aria-invalid="true"` changes border-color to `--color-status-error-border` (`Field.css:55-57`) and renders a mono `.field__error` line in `--color-status-error-text` (`Field.css:59-64`, `Field.tsx:86-90`). `min-height: var(--control-height)` = 48px (`Field.css:23`).
- `Control.css:18` hardcodes `font-family: "Source Sans 3", system-ui, sans-serif` on the base unconditional `.control` rule, applying to every tier including primary. `Control.css:56-57` sets `.control--secondary:hover:not(:disabled) { background: var(--color-paper-200); }`.
- Primary count today: `LoginForm` production-renders exactly one Primary (submit); the five quick-select Controls are Secondary and `import.meta.env.DEV`-gated. The gate renders one Primary plus two Quiet. Both already satisfy "exactly one Primary."
- Email-not-confirmed has no separate component. `AuthContext.tsx:41-46` maps the `email_not_confirmed` case to "This account's email hasn't been confirmed yet. Contact your instructor to confirm it." and it surfaces through `LoginForm`'s generic `role="alert"` `<p className="login-form-error">` at `LoginForm.tsx:61-65`.
- `src/__tests__/LoginForm.test.tsx` (6 cases) and `ForcedPasswordChangeGate.test.tsx` (2 cases) query exclusively via Testing Library role/label/text selectors; a grep for `className|querySelector|\.field__|\.control--|\.login-form-|\.gate-` across the four named test files returned zero matches. No test asserts on CSS classNames or DOM structure, so a layout-only change is unlikely to break them. `LoginForm.test.tsx:14,30` assert `getByRole('button', { name: /sign in/i })` — the only label-coupled assertions.
- **Stale reference, recorded explicitly.** Issue #37's own body cites specimen lines 73068 (§D.1) and 167431 (§E.1). Those line numbers do not exist — `design/field-journal/Field Journal DS.dc.html` is 1,595 lines total. The real locations are §D.1 at lines 580-622 and §E.1 at lines 1274-1309, located by content search. Engineering must use the corrected locations.

## Research evidence and its limits

A nested Researcher packet (standard profile, architecture mode; source ledger S1-S17, all local repository reads with file:line) was consumed directly by Planner.

**Residual limit, recorded honestly.** Researcher could not execute the test suite — `.claude/hooks/validate-researcher-bash.ps1` restricts its Bash tool to a read-only inspection allowlist that excludes test-runner commands. No test pass/fail baseline was fabricated. Establishing the green baseline for `AuthContext-EmailNotConfirmed.test.tsx`, `step4b-email-not-confirmed-flow.test.tsx`, `LoginForm.test.tsx`, and `ForcedPasswordChangeGate.test.tsx` is therefore the implementing writer's first ordered step, before any production edit (see Ordered work, Phase 0).

## Design route and handoff

```
DESIGN_ROUTE
profile: standard
reasons: A screen redesign against two reference artboards at two breakpoints. #35 already migrated the underlying controls/fields, so this is not a primitive rebuild — but the specimen's composition (full-bleed two-column split with a dark brand panel at 1440; stacked single column with a dark brand banner at 390) has no counterpart in production, and neither in-scope CSS file carries any responsive step matching the specimen. That is new screen composition plus multi-breakpoint responsive behavior, beyond compact. Not studio: the visual direction is already fixed by the shipped specimen and the #31-#33 token layer, so no safe/refined/novel selection exists to make.
agents_required: design-director, ux-architect, visual-system-designer, design-reviewer
prototype: forbidden
model_tier: sonnet
existing_system_mode: extend
END_DESIGN_ROUTE
```

**Design handoff: PASSED (revision 1).** Full reviewed `DESIGN_HANDOFF` retained in the planning chain; its load-bearing content is reproduced in Interfaces and data below.

**Design review: PASSED.** `DESIGN_REVIEW_RESULT verdict: PASS` from an independent design-reviewer on revision 1, after one evidence-backed `NEEDS_REVISION` cycle. Revision 0 raised seven findings, all resolved in revision 1:

1. **HIGH, accessibility — a real WCAG AA failure.** The reviewer resolved tokens to hex and independently computed relative-luminance contrast against the `--color-ink-900` (#2a2420) panel: `--color-brass-300` (#dca250) = 6.80:1 PASS; `--color-brass-500` (#a07e48) = 4.06:1 FAILS the 4.5:1 normal-text threshold; `--color-brass-700` (#7c6136) = 2.64:1 FAILS both thresholds; `--color-paper-200` (#f0ebe2) = 12.90:1 PASS; `--color-paper-50` (#fdfcf9) = 14.93:1 PASS. The specimen renders wordmark line 2 ("Field Journal") and the footer row at 11-12px in #a07e48 — unambiguously normal-size text — and revision 0 had mapped exactly those elements to brass-500. Resolved by moving both to `--color-brass-300`.
2. **HIGH** — the `sessionError` sibling branch at `App.tsx:224-245` was silently dropped from scope. Resolved by bringing it in.
3. **MEDIUM** — the gate's card mapping was unspecified despite the acceptance criteria requiring sheet elevation. Resolved with an explicit gate mapping.
4. **MEDIUM** — the submit-button typography divergence was under-escalated. Resolved by raising it to a decision item.
5. **LOW** — an ambiguous panel "eyebrow" clause. Resolved: the panel has no eyebrow; it was a misplaced reference to the card's "Access" label.
6. **LOW** — the hover load-order question was over-escalated. Resolved by downgrading it to a browser-validation checkpoint.
7. **LOW** — a self-contradictory hedge about the centering mechanism. Resolved with the confirmed value.

On re-review the reviewer independently recomputed and confirmed 4.063:1 for brass-500 (matching the original defect and validating its method), 6.798:1 for brass-300, 8.04:1 for `--color-ink-1000` (#1a1512) on brass-300 (the logo glyph), and 5.65:1 for brass-700 on paper-50 (the card eyebrow). It verified `.gate-content`'s absence from the `App.css:693` list, the `overflow: auto` claim, the accuracy of the `App.tsx:224-245` description, and that the widened amendment range sweeps in no unrelated code.

The disclosed, user-authorized Atelier MCP compiler gap is not a review finding; see Assumptions and decisions.

## Judge route

`PLAN_DUCK` is eligible after Scribe returns this draft and before routing, per `docs/JUDGE-CONTRACT.md`, justified by medium-high risk: this plan touches live authentication rendering and amends `App.tsx`'s auth gate. The orchestrator owns that call, not this plan. Deterministic failures always dominate any judge finding.

## Planner decisions on the four escalated design items

Recorded as Planner decisions made under standing authorization, each reversible by the user:

1. **Brand-panel host.** Approve path (b), the narrow additive `App.tsx` amendment confined to lines 224-262 (both the `sessionError` and `!session` branches). Rationale: the artboards are the issue's stated acceptance reference, and a card-only fallback cannot satisfy "Matches §D.1 at 1440 and §E.1 at 390." Building the panel inside `LoginForm.tsx` alone would produce two `<h1>`s both reading "Learn in the open" — a genuine accessibility and content defect. Both branches adopt the panel so the two adjacent unauthenticated screens stay consistent. The `sessionError` branch's Retry migrates from `demo-button secondary` to `Control type="button" tier="secondary"`. The reviewer confirmed the widened range sweeps in no unrelated code.
2. **Submit button label.** Adopt the specimen's "Open my journal" in place of "Sign in" (`LoginForm.tsx:91`). Rationale: the acceptance criteria's binding text is "Matches §D.1 at 1440 and §E.1 at 390," and the specimen states this label at both breakpoints. Consequence: `LoginForm.test.tsx:14,30` break mechanically. Under #35's auth-flow non-regression contract, changing a test requires explicit written justification in the PR — the justification here is that these are label-literal assertions, not behavior assertions, and the new label is specimen-mandated. Updating the two selectors is permitted; loosening, deleting, or weakening any behavioral assertion is a job failure. Everything else in that file must pass unchanged.
3. **LoginForm submit-in-flight state.** Adopt. Rationale: #35 explicitly listed "LoginForm's missing loading/disabled state on its async 'Sign in' call" as a deferred non-goal; #37 is the login-screen issue and the natural home for it. Implement by copying the gate's existing "Setting password..." text-swap pattern, not by inventing a spinner. It closes a real double-submit gap.
4. **Submit button typography.** Accept the divergence. Control renders the label in Source Sans 3 (`Control.css:18`, hardcoded, unconditional), not the specimen's IBM Plex Mono. Rationale: Control is out of scope to modify, and a wrapper override would fight the primitive's own type ramp at equal-or-higher specificity. Record this openly as the plan's primary visible tension against the literal "matches §D.1/§E.1" criterion — it is a known, accepted, documented gap, not a silent one.

## Ordered work

Owner for every step is T1, escalating to T2 on two counted gate failures. TDD-first throughout — RED evidence is required before any production edit in every phase. Four sequenced phases within ONE plan and ONE engineering job.

**Phase 0 — Baseline (no production edits).** Run `npx vitest run` scoped to `src/__tests__/LoginForm.test.tsx`, `src/__tests__/ForcedPasswordChangeGate.test.tsx`, `src/__tests__/AuthContext-EmailNotConfirmed.test.tsx`, `src/__tests__/step4b-email-not-confirmed-flow.test.tsx`. Record exact pass/fail counts as the baseline Researcher could not establish. Gate: baseline recorded; if any test is already RED, report it before proceeding rather than absorbing it into this issue's changes.

**Phase 1 — Tokens and the card.** Add the four additive font-size tokens. Introduce `.auth-sheet-card` in `LoginForm.css`, replacing `.login-form-container` in `LoginForm.tsx`, with the per-breakpoint border/shadow/background/padding mapping (see Interfaces and data). Remove the now-dead `.login-form-container h2` rule. Retokenize `.login-form-error`. Gate: `npx tsc` clean; a source scan proving no shipped token value changed and all four new tokens are additive; a source scan proving `.auth-sheet-card` does not appear in `App.css:693`'s selector list and that `App.css` is unmodified; the four Phase-0 test files still green.

**Phase 2 — Brand panel and the App.tsx amendment.** Build `.auth-brand-panel`/`.auth-split-layout` per the token mapping, with the inline `aria-hidden` SVG logo mark and all decorative layers `aria-hidden` and non-focusable. Amend `App.tsx` lines 224-262 only, applying the panel to both branches and migrating the `sessionError` Retry to `Control tier="secondary"`. Gate: a source scan proving `App.tsx` changes are confined to lines 224-262; a source scan proving exactly one `<h1>` reading "Learn in the open" renders per branch; a source scan proving the new CSS contains a `@media (forced-colors: active)` block; `npx tsc` clean; full suite green.

**Phase 3 — Gate elevation and semantics.** Apply the `.gate-content` per-breakpoint elevation mapping. Retarget the existing `@media (max-width: 640px)` to `@media (max-width: 56.24rem)`. Fix `.form-error`'s missing error semantics and tokenize its padding. Gate: a source scan proving `Control.tsx/.css` and `Field.tsx/.css` are byte-unchanged; a source scan proving the gate CSS contains a `forced-colors` block; `ForcedPasswordChangeGate.test.tsx` green unchanged.

**Phase 4 — Label, in-flight state, hover fix, and validation.** Apply the "Open my journal" label with the two justified test-selector updates. Add the submit-in-flight disabled/text-swap state with new tests. Add the quick-select hover fix. Gate: all four Phase-0 test files green with only the two justified selector edits; a deterministic scan across `src/` proving zero occurrences of native `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload`; a scan proving no `-webkit-text-fill-color: transparent` and no `forced-color-adjust: none` introduced; full suite green; `npx tsc` clean; then Verifier, then Browser Validator.

## Interfaces and data

No API, schema, migration, or persistence change.

**Four new additive tokens** in `src/tokens/field-workbook.generated.css` (reviewer-confirmed: no collision with any existing `--font-size-*` name, and each value matches a specimen literal at `Field Journal DS.dc.html:590,1285,603,1291`):

| Token | Value | Use |
|---|---|---|
| `--font-size-hero-lg` | `5.5rem` (88px) | brand-panel h1, >=900px |
| `--font-size-hero-sm` | `2.875rem` (46px) | brand-panel h1, <900px |
| `--font-size-signin-lg` | `2.75rem` (44px) | card h2, >=900px |
| `--font-size-signin-sm` | `2rem` (32px) | card h2, <900px |

**Composition.** >=900px (`56.25rem`, reusing `App.css:699/726`'s existing convention): `.auth-split-layout`, CSS grid `minmax(0,1fr) minmax(0,1fr)`, `.auth-brand-panel` left and a centered `.auth-sheet-card` right at `max-width: 460px`. `fr` units only, no fixed pixel columns. <900px: single column, panel first in document order as a banner, card below in normal flow. Critical: do not copy the specimen's artboard-frame styling (`width:390px; height:844px; overflow:hidden`, `Field Journal DS.dc.html:1277`) into production — it is a mockup device frame, and reproducing it clips content under 200% zoom (WCAG 1.4.10).

**Card content order** (unchanged from current `LoginForm.tsx`): eyebrow "Access" (>=900px only, confirmed absent at 390) -> `<h2>Sign in</h2>` -> Email `Field` -> Password `Field` -> submit `Control tier="primary"` -> DEV-only quick-select list (`import.meta.env.DEV`, all five `LOCAL_TEST_STUDENTS` — the specimen's 2-and-1 button counts are mockup space-saving only, do not reduce the real list).

**Brand panel content order:** logo mark (56x56px >=900, 44x44px <900) plus two-line wordmark "Lizbeth Spanish" / "Field Journal" -> `<h1>` "Learn in" / "the open" (two lines, identical at both breakpoints) -> tagline, full at >=900px ("Seventy-eight weeks of Spanish, one notebook page at a time. Your week opens when you reach it.") and shortened at <900px ("Seventy-eight weeks of Spanish, one notebook page at a time.") — a real per-breakpoint content difference confirmed by direct specimen read -> (>=900px only) horizontal rule plus a footer row of two separate text nodes on one flex row, "Beginner · Intermediate · Advanced" left and "78 weeks" right. There is no eyebrow at panel level. All copy must be transcribed exactly; do not invent marketing text.

**`.auth-sheet-card` mapping.** >=900px: `border: var(--border-width-rule) solid var(--color-ink-1000)` (3px) + `box-shadow: var(--shadow-sheet)` + `background: var(--color-paper-50)` + padding `2.75rem 2.5rem 2.5rem` (the last two are `var(--space-10)`). <900px: `border: var(--border-width-strong) solid var(--color-ink-1000)` (2px) + `box-shadow: var(--shadow-card)` + padding `1.875rem 1.25rem 1.5rem`. Border colour is `--color-ink-1000` at both breakpoints, deliberately not the `--color-ink-800` that `App.css:693` uses. Centering carries forward unchanged from `LoginForm.css:1`: `max-width: var(--size-login-max); margin: 0 auto;`.

**Escape mechanism** — how the sheet-elevation criterion is met without editing the shared rule: because `.auth-sheet-card` is a new class name absent from `App.css:693`'s selector list, that shared rule simply never matches it. No specificity fight, no `!important`, zero `App.css` edits. This is what satisfies the acceptance criteria's "3px rule + 8px hard offset" at 1440 while the six other consumers of the shared rule stay untouched. `.login-form-container` becomes dead once this ships.

**`.gate-content` mapping.** >=900px: `border: var(--border-width-rule) solid var(--color-ink-1000)` + `box-shadow: var(--shadow-sheet)` + `background: var(--color-paper-50)`, keeping the existing `max-width: 400px` and `padding: 2rem`. <900px: `border: var(--border-width-strong) solid var(--color-ink-1000)` + `box-shadow: var(--shadow-card)`, keeping the existing reduced `padding: 1.5rem` and `h1 { font-size: 1.25rem }`. No escape-class rename is needed: `.gate-content` is absent from `App.css:693`, and `App.css:755`'s scoped `.forced-password-change-gate .gate-content` sets `border-radius` only. The gate does not import the washi-tape or eyebrow decoration — no gate artboard exists in the specimen, so only the elevation/border/background language is shared. **Breakpoint reconciliation:** the file's existing `@media (max-width: 640px)` is retargeted to `@media (max-width: 56.24rem)` so elevation and density step together at one threshold rather than producing an inconsistent 640-900px zone where the border and shadow have stepped down but padding and heading size have not.

**Brand panel token mapping**, with the accessibility correction binding: background `var(--color-ink-900)`; h1 `var(--color-paper-50)` (14.93:1); tagline `var(--color-paper-200)` (12.90:1); wordmark line 1 `var(--color-brass-300)` (6.80:1); wordmark line 2 `var(--color-brass-300)` (6.80:1) — corrected from the specimen's literal `#a07e48`/brass-500, which fails at 4.06:1; footer text `var(--color-brass-300)` (6.80:1) — same correction, same justification; logo-mark fill `var(--color-brass-300)` with `border: var(--border-width-rule) solid var(--color-ink-1000)` (border width constant, only the 56->44px square dimension changes); footer rule and banner bottom-border `var(--border-width-strong)` / `var(--border-width-rule) solid var(--color-ink-700)` / `var(--color-ink-1000)` respectively. **Record this deviation prominently:** the brass-500 to brass-300 substitution is an explicit, openly documented departure from the artboard's literal colour, required because WCAG 2.2 AA is the binding project gate and the specimen is a static artboard that was never contrast-audited. It must not be silently reverted to match the artboard during implementation or review.

**Card "Access" eyebrow:** `var(--color-brass-700)` on the card's `var(--color-paper-50)` background — 5.65:1, PASS. This is a light-background pairing, distinct from the failing dark-panel pairing, and is unchanged.

**Decorative layers.** Texture overlay `background: color-mix(in srgb, var(--color-paper-200) 6%, transparent)`, reusing the `color-mix()` pattern already shipped at `Control.css:129-134`. Light-side grid texture reuses `var(--color-paper-300)`. Washi tape `background: color-mix(in srgb, var(--color-amber-200) 85%, transparent)` with `border: color-mix(in srgb, var(--color-brass-700) 50%, transparent)`; dimensions 150x28px and 120x24px as plain literals. Logo mark is an inline SVG rather than a CSS background box, for forced-colors robustness, `aria-hidden="true"`, rect `fill: var(--color-brass-300); stroke-width: 3`, glyph `fill: var(--color-ink-1000)` (8.04:1). Every decorative layer — texture, washi tape, and the 390-only status-bar mock — must be `aria-hidden="true"`, non-focusable, carry zero information, and be safe to `display: none` under forced-colors.

**Typography literals.** Tagline is `1.1875rem` (19px) at >=900px as a single-use plain literal, and reuses `var(--font-size-body)` (17px) at <900px. Letter-spacing and line-height values (h1 `-.035em`, h2 `-.03em`, mono tracking `.12em`-`.22em`) stay plain literals, following the shipped precedent at `Field.css:16` (`letter-spacing: .18em` is already a raw literal in shipped code). The project's lint restricts only raw hex colour, undefined `var()`, non-zero border-radius, and non-zero-blur box-shadow — none of these literals are restricted.

**Four documented divergences from the specimen**, all traced to Control/Field being shipped and unmodifiable:

1. Field's border stays 3px at both breakpoints where the specimen shows 2px at 390 — leave the shared C.2 primitive unfragmented.
2. Control's quick-select border stays 3px for the same reason.
3. The submit label renders Source Sans 3 rather than IBM Plex Mono — see Planner decision 4, the plan's primary visible acceptance-criteria tension.
4. Submit `min-height` is 48px via Control against the specimen's 52/54px, accepted implicitly by reusing the shared primitive.

**Quick-select hover fix**, confined to `LoginForm.css`: `.login-form-quick-select-button:hover:not(:disabled) { background: var(--color-amber-200); }`, because Control's shipped secondary hover is `var(--color-paper-200)` (`Control.css:56-57`) while the specimen calls for amber. This rule and `.control--secondary:hover:not(:disabled)` have equal specificity (0,3,0), so the winner is decided by source order — and `LoginForm.tsx:1-4` imports `Control` and `Field` (which side-effect-import their own CSS) before `./LoginForm.css`, so under depth-first Vite/ESM insertion `LoginForm.css` lands last and this rule wins by default. Confirm empirically in browser validation; only if it loses, apply the documented doubled-class fallback `.login-form-quick-select-button.login-form-quick-select-button:hover:not(:disabled)` rather than `!important`.

**Error and status language.** Keep the boxed-paragraph treatment for `.login-form-error` and the gate's `.form-error`/`.gate-success` — do not switch them to Field's mono-line convention, because these communicate page-level failure, a different scope from Field's per-field error, and the visual-weight difference is correct. `LoginForm.css:7` retargets to `var(--color-status-error-text)`, `var(--color-status-error-border)`, and `var(--color-surface-chrome-default)` — the same resolved colours at the correct token layer. `ForcedPasswordChangeGate.css:65-74`'s `.form-error` carries a real defect: `color: var(--color-ink-900)` gives it no error semantics; retarget to `var(--color-status-error-text)` and replace the literal `padding: 0.75rem` with `var(--space-3)`. `.gate-success` at lines 121-134 is already fully token-correct and needs no change; it is the template the two error boxes align to.

**States.** Field supplies default, focus, disabled, and `aria-invalid` error for free. Control primary supplies default, hover, active, focus, and disabled for free; loading/busy is not native to Control, so the new in-flight state copies the gate's existing text-swap pattern. Control secondary supplies everything but the hover colour. The gate's six existing states (`form`, `confirming`, `error`, `success`, `session-error`, `network-error`) are preserved verbatim with only their visual language changing. The `sessionError` screen has a single static error-plus-retry state.

**Accessibility and focus.** Keyboard order is identical at both breakpoints, since the brand panel contains zero interactive elements regardless of DOM position: Email -> Password -> Submit -> (DEV builds only) quick-select buttons in list order. The existing empty-email focus-move at `LoginForm.tsx:42-46` and the gate's mount-time heading focus (`headingRef`, `tabIndex={-1}`) must be preserved exactly. On the `sessionError` screen, Retry remains the sole interactive element and must stay keyboard-reachable. No new motion is introduced; any future hover-lift must follow the existing opt-in pattern at `ForcedPasswordChangeGate.css:152-157`. Forced-colors blocks are required for `.auth-brand-panel` and `.auth-sheet-card`, mirroring the shipped remap pattern at `Control.css:154-197` and `Field.css:75-91`: panel `background: Canvas` with `color: CanvasText`, logo-mark `fill: ButtonFace` and `stroke: ButtonText`, dividers `border-color: CanvasText`; card `border-color: ButtonText; box-shadow: none`; decorative layers `display: none`. The dark panel is structurally novel — this app has zero prior full-bleed dark surfaces — so it needs dedicated forced-colors verification and must not rely on background colour alone to establish the region.

## Issue #10 disposition

Issue #10 is titled "on student login" with the complete verbatim body "display the roadmap page as well as a dashboard showing metrics," labelled `blocked:field-journal-ds`, no milestone, state OPEN. Issue #37's body directs re-reading it and folding in anything the redesign resolves.

Repository evidence: `App.tsx:192`'s fallback branch renders `RoadmapPage`, which `RoadmapPage.tsx:14-18` self-describes as "The student-facing weekly roadmap/dashboard (Phase 3b)" and which renders one `BandRoadmap` per enrollment (`RoadmapPage.tsx:4,20-46`) — so the roadmap half is satisfied for students. However `OwnerDashboardPage` and its `MetricPlate` components (`OwnerDashboardPage.tsx:24-29`) are reachable only through the admin route gated on the owner role (`App.tsx:187-190`) and are confirmed owner-facing only. A grep for `MetricPlate|metrics|dashboard-metric` in `RoadmapPage.tsx` returned zero matches; its only quantitative element is `BandRoadmap`'s single completion-percentage bar.

**Conclusion:** #10 is half resolved — the roadmap exists and is the student's landing page, but no student-facing metrics dashboard exists, and #36's dashboard work does not reach students. #37 must not recommend closing #10. Nothing in the login-screen redesign resolves it, since #10's real content concerns the post-login landing experience rather than the sign-in screen itself.

Recommendation: #10 should stay open, be re-titled or clarified to reflect its actual body, and have the student-metrics-dashboard gap tracked as its own scoped work. Explicitly out of #37's scope.

## Acceptance and validation

**Deterministic gates, all required:**

- `npx tsc` clean.
- `npm test` (vitest) green.
- A deterministic source scan across `src/` proving zero occurrences of native `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload`.
- A scan proving no shipped value in `field-workbook.generated.css` was altered and all four new tokens are additive.
- A scan proving `Control.tsx/.css` and `Field.tsx/.css` are byte-unchanged.
- A scan proving `App.css` is unmodified and `.auth-sheet-card` never appears in its line-693 selector list.
- A scan proving `App.tsx` edits are confined to lines 224-262.
- A scan proving no `-webkit-text-fill-color: transparent` and no `forced-color-adjust: none` were introduced.
- A scan proving every new CSS block for `.auth-brand-panel`, `.auth-sheet-card`, and `.gate-content` contains a `@media (forced-colors: active)` block.

**Issue-literal criteria, each individually checkable:**

- Matches §D.1 at 1440 and §E.1 at 390 (subject to the four documented divergences and the one documented contrast deviation).
- Sheet elevation as a 3px rule plus 8px hard offset at 1440.
- Fields follow C.2 exactly — mono label above, 48px tall, error changing both the terracotta rule and the mono error line.
- Exactly one Primary control on the screen at both breakpoints, DEV block included.
- Email-not-confirmed and forced-password-change paths render in the new system with `AuthContext-EmailNotConfirmed.test.tsx` and `step4b-email-not-confirmed-flow.test.tsx` staying green.
- Keyboard-only sign-in works end to end with a visible focus ring at every stop.

**Independent gates:** Verifier pass required before any completion claim; Browser Validator pass required after Verifier.

## Risks and rollback

| ID | Severity | Risk | Mitigation |
|----|----------|------|------------|
| R1 | High | Scope expansion into `App.tsx`. The brand panel cannot be built correctly without it, but `App.tsx` hosts the auth gate. | Edits confined to lines 224-262, reviewer-confirmed to sweep in no unrelated code; a deterministic source scan enforces the boundary; Phase 2 is independently revertible. |
| R2 | High | Live authentication surface. A layout regression here locks every user out. | #35's auth-flow non-regression contract carries forward — the four named test files must pass, with only the two justified label-selector edits permitted; no behavioural assertion may be loosened, deleted, or weakened. |
| R3 | Medium | The gate's media-query retarget from 640px to 900px newly applies phone-tuned padding and heading reductions across the 640-900px tablet band. | The reviewer assessed this as a low, non-blocking density risk, since `.gate-content` stays capped at `max-width: 400px` so the outer padding is largely inert at those widths and the card's own steps are modest. Browser validation includes a tablet-width spot check. |
| R4 | Medium | The documented brass-500 to brass-300 contrast deviation could be "corrected" back toward the artboard by a later reviewer comparing against the specimen. | Recorded prominently here and in the browser-validation brief as intentional, with the computed ratios stated. |
| R5 | Medium | No verified test baseline existed at planning time. | Phase 0 establishes it before any production edit. |
| R6 | Low | The quick-select hover rule depends on CSS source order. | Source-order analysis says it already wins; browser validation confirms; a doubled-class fallback is documented. |
| R7 | Low | `--shadow-sheet` has zero existing consumers, so this is its first production use and it is unproven at render. | Browser validation captures it at 1440. |

**Rollback.** Each phase is an independent revert. Phase 1 is near-additive. Phase 2 carries the `App.tsx` risk and reverts cleanly to the existing flat header. Phase 3 is confined to the gate's own file. Phase 4's label, in-flight, and hover changes revert independently of one another.

## Assumptions and decisions

**Labeled assumptions:**

- Both specimen artboards are static default-state mockups showing no error, focus, disabled, or loading state, so those states are generalized from the shipped primitives.
- The specimen's pre-filled input values are illustrative and real fields start empty.
- The `sessionError` screen's card-versus-plain-content treatment is an implementer choice, not load-bearing to any acceptance criterion.
- The specimen's reduced quick-select button counts (two at 1440, one at 390) are mockup space-saving rather than a product requirement.

**Planner decisions recorded:**

- The four escalated design items resolved as recorded above under Planner decisions.
- `DESIGN_ROUTE` standard rather than studio, because the specimen fixes the visual direction.
- Scope held to the issue's file list plus the bounded `App.tsx` amendment.
- Issue #10 recommended to stay open.

**Pre-authorized by the user and not to be re-litigated:** the disclosed Atelier MCP compiler gap, including hand-transcription of specimen values and the documented-manual substitute for the `visual_diff` verification requirement, per the precedent established in issues #31, #34, and #35. Note that #37 states `visual_diff` at both 1440 and 390 explicitly — a stricter requirement than prior issues — so the documented-manual substitute must be performed and recorded separately at each breakpoint rather than once generally. Recorded as a disclosed limitation, never as a silent pass.

**Standing constraints to record:** TDD-first throughout; the non-standard dev-server port specified in Browser UI validation below; never weaken Docker or host security; the no-native-dialog invariant.

**Approvals still required:** this plan is routed to engineering under the user's standing authorization rather than a separate per-plan approval; see Approval basis above.

## Browser UI dialog policy

Required and load-bearing. Native `alert`, `confirm`, `prompt`, every `window.*` variant, and `beforeunload` are prohibited across the entire app, including the `sessionError` screen. All validation on these surfaces stays inline — the existing empty-email inline error with focus movement to the email field (`LoginForm.tsx:42-46`) must be preserved exactly. Enforced by a deterministic source-level scan, not by assertion.

## Browser UI validation

**Launch/readiness:** `npm run dev -- --port 5199 --strictPort` from the repository root. `package.json`'s `dev` script is bare `vite` with no pinned port, so the non-standard port must be passed explicitly; `--strictPort` makes readiness deterministic by failing rather than silently drifting. Ready when Vite reports listening on 5199.

**Base URL:** `http://localhost:5199`

**Fixture/reset:** an unauthenticated session with no seeded or cached auth for the login journeys; a session-restore-failure condition to reach the `sessionError` screen; a user with `force_password_change` set for the gate; the DEV build for the quick-select journey.

**Viewport profiles:** 1440x900 and 390x844 are mandatory and every journey must be run at both. Add a spot check just above and below the 900px breakpoint, and a tablet-width check around 700-900px specifically for the gate's retargeted media query.

**Journeys, each at both mandatory viewports:**

1. Load `/` unauthenticated and confirm the composition matches the approved split-panel path, with the full tagline plus footer row and the "Access" eyebrow at >=900px, and the shortened tagline with no footer and no eyebrow at <900px.
2. Trigger `sessionError` and confirm it shares `.auth-brand-panel`/`.auth-split-layout` with the login screen rather than the old flat header, and that Retry renders as a secondary Control.
3. Keyboard-only: Tab reaches Email, Password, Submit, then the DEV quick-select buttons in list order, with a visible focus ring at every stop, and no decorative panel, texture, washi-tape, or status-bar content ever receiving focus.
4. Submit with an empty email and confirm the inline error appears with focus returning to the email field.
5. Trigger a generic auth error and, if reachable by fixture, an email-not-confirmed error, confirming `.login-form-error` renders with `role="alert"` and the correct error tokens.
6. DEV build only: quick-select fills the credentials on click and hover shows amber-200, confirming the CSS source-order resolution wins on the built bundle; if it does not, apply the doubled-class fallback and re-verify.
7. Reach the forced-password-change gate and confirm `.gate-content` shows sheet elevation per the new mapping at both breakpoints, that border, shadow, padding, and heading size all step together at the ~900px threshold with no inconsistent transition zone, and that all six gate states are exercised where feasible with sign-out and retry staying Quiet tier and never more than one Primary visible.
8. A deterministic no-native-dialog scan across all journeys including `sessionError`.
9. `prefers-reduced-motion: reduce` emulation showing no motion on any new static element.
10. `forced-colors: active` emulation at both breakpoints, confirming the panel and card stay legible under system colours while decorative layers may disappear as expected.
11. 200% browser zoom at 390 width with no horizontal scrolling and no clipped content.
12. A contrast spot check visually confirming wordmark line 2 and the footer row render in the corrected brass-300 rather than the specimen's literal brass-500 at both breakpoints — this intentional deviation must be visible in the screenshot evidence and must not be silently reverted.

**Visible outcomes to capture:** full-page screenshots at both mandatory viewports for the default, keyboard-focus-on-submit, empty-email-error, generic-auth-error, and `sessionError` states; gate screenshots for the form, error, and success states at both elevation breakpoints; one forced-colors screenshot per breakpoint; and the documented-manual `visual_diff` substitute recorded separately at 1440 and at 390.

**FAIL conditions:** any focus stop without a visible ring; any decorative element receiving focus; more than one Primary control visible on any screen; any horizontal scroll at 390 or at 200% zoom; any clipped content; any native dialog; the brand panel or card becoming illegible under forced-colors; any of the four named test files failing; or the brass-300 contrast correction having been reverted to the specimen's literal brass-500.
