# Lizbeth Spanish, Issue #32: Typography — four hands

Status: Drafted, awaiting the orchestrator's routing decision under the user's standing authorization. This document has not itself been separately approved by the user; the user has granted standing authorization ("keep going until all the gh issues are finished") that the orchestrator applies to route this plan to engineering, per the assumption recorded below. Approval of this document authorizes only issue #32's scope; it does not authorize any of issues #33-#44.

## Approval basis

This plan was routed to engineering under the orchestrator's application of the user's standing authorization, not a user-verified per-plan approval. The record below is an orchestrator-applied inference, consistent with the Status line above, and follows the same provenance discipline issue #31's plan used.

- **Standing authorization quoted (verbatim, as relayed by the orchestrator):** "didn't i tell you to stop asking me for approval? i told you to keep going until all the gh issues are finished," reinforced by an explicit session goal, "don't stop until all the DS gh issues are implemented and browser validated."
- **Application:** The orchestrator applied this standing authorization to route this plan (issue #32 of `lebobo88/lizbeth-spanish`) to engineering without a further live per-plan checkpoint.
- **Staleness cross-check:** The orchestrator independently fetched the live GitHub issue #32 body (`gh issue view 32 --repo lebobo88/lizbeth-spanish`) and confirmed it matches this plan's grounding (six typography roles, font imports, the ratified 26px margin-hand value, the decorative-element `aria-hidden` requirement, and the dependency on #31) with no material contradiction; the plan is not stale. This fetch-and-compare action is the same check described by Ordered-work step 0's pre-flight; "Research evidence and its limits" and "Ordered work" step 0 below still read as if that check were outstanding and have not been separately updated as part of this Approval basis addition — reconciling their wording is flagged as a remaining limit rather than resolved here.
- **Provenance label:** This basis reached Scribe entirely through the orchestrator's account of the session; Scribe has not independently observed the quoted user statements. It is recorded here as an orchestrator-applied inference under standing authorization, NOT as a Scribe-verified per-document user approval.
- **Lead decision, distinguished from the standing-authorization inference above.** On 2026-08-31, the lead explicitly authorized recording the design reviewer's own one-line `role.label.fontFamily` remediation directly as a binding engineering invariant, without spending a second design-review revision cycle, on the stated grounds that reviewer and director agreed on the exact fix with no contested design judgment. This is recorded as a direct lead instruction, not as an application of the general standing authorization. See "Interfaces and data" for the correction itself.
- **Date:** 2026-08-31.

Plan ID: `lizbeth-spanish-issue32-typography-four-hands`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: `engineering-fleet`
Design route: standard (`design-director`, `ux-architect`, `visual-system-designer`, `design-reviewer`; prototype forbidden; model tier Sonnet; existing-system mode: extend)

## Outcome and audience

GitHub issue #32, "Typography: four hands," is the second issue in the 14-issue dependency-chained "Field Journal DS" milestone (#31-#44), unblocked by #31 which has landed (verified, browser-validated, design-reviewed PASS). This plan establishes the Field Journal typographic substrate ADDITIVELY: six ratified type roles, two new font families, a corrected font-loading chain, and one genuine typography bug fix.

Audience: the T1/T2 engineer implementing this plan, and the Verifier/Browser Validator gating it.

## Scope

**In scope** — the authorized touch-surface is exactly ADOPTION-PLAN.md row 2's file list: `src/App.css` (`@import` block only), the token JSON files (`src/tokens/primitives.json`, `src/tokens/semantic.json`), and `src/tokens/tokenSystem.ts`. Specifically:

1. Correct the Google Fonts `@import` chain at `src/App.css:14`.
2. Add `typography.fontFamily.*` primitive tokens to `src/tokens/primitives.json`.
3. Add pre-flattened `typography.role.<role>.<property>` scalar tokens to `src/tokens/semantic.json`.
4. Fix the `--line-height-body` undefined-reference bug at `src/App.css:735`.
5. Add a second `labelFontMap` to `src/context/AccessibilityContext.tsx` for role.label font substitution (an accessibility remediation required by design review; see Interfaces and data).
6. New/updated tests under `src/__tests__/`.

**Non-goals (belong to later chained issues; do NOT do them here):**

- Wiring any of the six new role tokens into ANY component selector. #32's tokens are ADDITIVE-AND-UNCONSUMED. Wiring belongs to #33/#35/#36 and the screen issues #37-#44.
- Issue #33's token plumbing + fallback audit: the ~10 literal `font-family` and ~36 literal `font-size` declarations across Modal.css, AdminStudentModals.css, RegisterStudentModal.css, AccessibilitySettings.css, AdminStudentsPage.css, ForcedPasswordChangeGate.css, CourseWorkspace.css. Confirmed via `judge/issue-map.json` and ADOPTION-PLAN.md that this is #33's work.
- The two pre-existing font-weight-availability gaps discovered during this plan's audit (Source Sans 3 weight-500 consumers; Atkinson Hyperlegible weight-600 consumers). Documented below, tracked, NOT fixed here — both are outside #32's authorized file list.
- The OpenDyslexic loading gap. Documented, recommended for a dedicated follow-up issue, NOT fixed here.
- Retiring, deleting, or repointing ANY existing type token or component call site. `--typography-fontSize-*`, `--font-size-*`, `--font-family-body`'s existing definitions, and all other pre-existing type tokens keep their exact current values.
- No new build tool. There is no PostCSS/Tailwind/style-dictionary in this repo and none is to be added. There is no CSS build step.
- Do NOT alter any color, radius, shadow, motion, or size token value shipped by issue #31. Those are ground truth.
- Do NOT re-litigate the ratified §A.2 type values, the 26px margin-hand deviation, or the brass.600/terracotta.600 APCA Lc-75 accepted deviation.

## Verified repository findings

Stack (carried from #31, unchanged): React 18.3 + TypeScript 5.5 + Vite 5.4 + Supabase. Vitest 2.0 (separate `vitest.config.ts`), Playwright 1.61 (`test:e2e`), ESLint 9.39 flat config (`npm run lint` = `eslint src --ext ts,tsx`). No CSS build step. `vite.config.ts` sets `server.port: 5173`, `open: true`.

**FOUR coexisting CSS-custom-property delivery mechanisms — one more than issue #31 documented. This is the central hazard of this issue and the direct analogue of #31's mechanism-1 cascade defect.**

1. Mechanism 1: `src/tokens/{primitives,semantic,components}.json` -> `src/tokens/tokenSystem.ts` `generateCSSVariables()` -> injected as a runtime `<style>` tag into `document.head` by `src/main.tsx`. WINS over mechanisms 2 and 3. Currently defines `--typography-fontSize-xs/sm/base/lg/xl/2xl/3xl/4xl/5xl` (0.75rem..3rem, primitives.json:64-72), `--typography-lineHeight-tight/normal/relaxed/loose` (1.25/1.5/1.75/2, primitives.json:75-78), `--typography-letterSpacing-tight/normal/wide/extra` (-0.02em/0em/0.05em/0.1em, primitives.json:81-84), `--typography-body-fontSize/-lineHeight/-letterSpacing` (semantic.json:38-42), `--typography-heading-fontSize/-lineHeight` (semantic.json:44-46), `--measure-reading: 65ch` (semantic.json:49). Defines ZERO font-family tokens — `primitives.json` has no `fontFamily` key.
2. Mechanism 2: `.atelier/tokens/field-workbook.tokens.json` -> `src/tokens/field-workbook.generated.css`, @import'ed at `src/App.css:13`. Defines `--font-family-body`, `--font-family-display`, `--font-letter-spacing-eyebrow: .08em`, `--font-line-height-body: 1.55`, `--font-weight-label: 700`, `--font-size-body: 1.0625rem`, `--font-size-caption: .8125rem`, `--font-size-control: 1rem`, `--font-size-display-title: 1.875rem`, `--font-size-header-subtitle: 1.125rem`, `--font-size-header-title: 2.2rem`, `--font-size-header-title-mobile: 1.5rem`, `--font-size-logo-mark: 1.25rem` (field-workbook.generated.css:30-42). This file's own header currently flags it as hand-transcribed pending real Atelier regeneration, per issue #31's Amendment.
3. Mechanism 3: `src/App.css` `:root` lines 17-94. Duplicates `--typography-fontSize-base/lg/xl/2xl/3xl` (App.css:51-55) at values identical to mechanism 1's; also defines `--text-size-multiplier: 1` (App.css:58), `--font-family-body` (App.css:69), `--line-height-floor`, `--line-height`, `--letter-spacing`, `--measure: 65ch` (App.css:70-73).
4. **MECHANISM 4, THE CRITICAL FINDING — an INLINE STYLE on `document.documentElement`, which outranks ALL THREE stylesheet mechanisms.** `src/context/AccessibilityContext.tsx:72` calls `root.style.setProperty('--font-family-body', ...)` from a `fontMap` (AccessibilityContext.tsx:65-70) keyed by `TypographyOption` (`'default'|'atkinson'|'lexend'|'opendyslexic'`), on every settings change. Line 59 likewise sets `--text-size-multiplier`. Observation, high confidence. **This is the true runtime winner for `--font-family-body`; any body-font change made only in mechanisms 1/2/3 is silently inert.** Verified: `fontMap.default` ALREADY matches the ratified `role.body.fontFamily` byte-for-byte, so drift risk today is NONE, and `App.css:69`'s slightly different fallback chain is provably dead code for this property.

**BLOCKING TECHNICAL CONSTRAINT — composite DTCG tokens cannot enter mechanism 1.** `src/tokens/tokenSystem.ts` `flattenTokens()` (lines 75-100) branches on `typeof value === 'object' && !Array.isArray(value) && '$value' in value`, then resolves references only `if (typeof tokenValue === 'string' && tokenValue.includes('{'))`, else emits `` `  --${varName}: ${tokenValue};` `` directly. It NEVER inspects `$type`. A DTCG `$type: "typography"` composite (object `$value`) would stringify to the literal `[object Object]` — invalid CSS that silently fails. Inference, high confidence: a deterministic consequence of the quoted logic, not empirically run in a browser. Existing precedent confirming the workaround: `semantic.json` already models `typography.body`/`typography.heading` as pre-flattened scalars, not composites.

**Font loading.** Exactly one path exists. `src/App.css:13` @imports mechanism 2's generated CSS; `src/App.css:14` is the Google Fonts @import, currently: `@import url('https://fonts.googleapis.com/css2?family=Fraunces:wght@400;600;700&family=Source+Sans+3:wght@400;600;700&family=Atkinson+Hyperlegible:wght@400;700&family=Lexend:wght@400;600;700&family=Lora:ital;wght@0,400;0,600;1,400&display=swap');`. No other font @import exists in `src/**`. No `@font-face` block exists anywhere in `src/**`. `index.html` has no font `<link>`, only a CSP `style-src`/`font-src` allowlist for `fonts.googleapis.com`/`fonts.gstatic.com` (index.html:8). The only self-hosted font file is `src/assets/fonts/NotoSans-Regular.ttf`, used exclusively by `src/services/exports.ts:8` for PDF export — unrelated to UI typography.

**Font-family liveness audit.** Atkinson Hyperlegible and Lexend are LIVE via mechanism 4's `fontMap`, surfaced as radio options at `src/components/AccessibilitySettings.tsx:92,103`. Lora is DEAD WEIGHT: zero consumers in `src/**` (only the @import string itself and unrelated `src/assets/dictionaries/en.dic` spellcheck coincidences), and its existing query syntax is also malformed. OpenDyslexic is a live, user-selectable radio option at `src/components/AccessibilitySettings.tsx:106-115` that currently does NOTHING — no `@font-face` or loading path exists anywhere in the codebase, and it is not a Google Fonts family. Observation, high confidence.

**Fraunces per-weight consumption (the defect design review caught).** Fraunces roman 600 is live and heavily consumed independent of #32: `src/App.css:292-296` (global `h1,h2,h3,h4,h5,h6 { font-family: Fraunces, serif; font-weight: 600; }` — EVERY heading in the app), `src/App.css:408-410` (`.app-header-logo-placeholder`), `src/components/WeekCard.css:56-58` (`.week-card-week-number`), `src/components/Modal.css:56-61` (`.modal-title`). Fraunces roman 700 is consumed at `src/pages/LearnDetailPage.css:140`. The current pre-#32 import DOES request roman 600. An earlier draft of the corrected import dropped it; this was caught as a CRITICAL design-review finding and is corrected below.

**Two pre-existing font-weight-availability gaps, discovered by this plan's audit, NOT in #32's scope.** (a) Source Sans 3 weight-500: consumed at `RegisterStudentModal.css:14,66,95,111`; `AdminStudentModals.css:49,59,116,184`; `AdminStudentsPage.css:57,78,203,236,259,289,399,411`; `App.css:561`; `ForcedPasswordChangeGate.css:56,170`; and `CourseWorkspace.css`. Weight 500 is not in the load list and never has been; browsers synthesize or fall back to the nearest loaded weight. (b) Atkinson Hyperlegible weight-600: consumed at `LessonContentView.css:158-160`, `ResourcesPanel.css:61-63` and `90-92`, `FlashcardsViewer.css:90-92`, `OwnerSettingsPage.css:84-86` — each pairing `font-family: var(--font-family-body, ...)` with `font-weight: 600`, while only 400/700 are requested for that family. A user who selects "atkinson" already sees synthetic-bold rendering at these call sites today. Both gaps are genuinely pre-existing, unchanged by #32, independently spot-checked and confirmed real by design review, and outside #32's authorized file list.

**`--text-size-multiplier` accessibility feature.** Defined `src/App.css:58` (default `1`), set at runtime by `AccessibilityContext.tsx:59` from the `textSize` field (`AccessibilityContext.tsx:6`), driven by a range input in `AccessibilitySettings.tsx`. Consumed by 44 occurrences of `calc(var(--typography-fontSize-*) * var(--text-size-multiplier))` across 10 CSS files: App.css (11), AccessibilitySettings.css (4), FlashcardsViewer.css (6), OwnerSettingsPage.css (4), WeekDetailPage.css (2), LessonContentView.css (5), IpNotice.css (1), Modal.css (3), ResourcesPanel.css (3), WeekCard.css (5). Must not regress.

**Pre-existing `--line-height-body` bug.** `src/App.css:735` reads `body { font-size: var(--font-size-body); line-height: var(--line-height-body); }`, but `--line-height-body` is defined by NO mechanism. The near-miss `--font-line-height-body: 1.55` (field-workbook.generated.css:33) is a differently-named, zero-consumer token that never applies. Per CSS spec, an invalid `var()` reference with no fallback on an INHERITED property computes to the property's inherited value — so `body`'s line-height currently renders whatever it inherits (typically the UA default `normal`), NOT 1.55. Two ADDITIONAL consumers reference the same undefined name DIRECTLY rather than via inheritance: `src/pages/OwnerDashboardPage.css:31` (`.dashboard-table-wrap th, .dashboard-table-wrap td`) and `src/pages/AdminStudentsPage.css:415` (`.admin-students-page`).

**Orphaned mechanism-1 tokens (context, not work).** `--measure-reading` (semantic.json) has zero `var()` consumers in `src/**`; the app reads the differently-named `--measure` (App.css:73) instead. `--typography-body-fontSize` and `--typography-heading-fontSize` are generated but referenced by no CSS in `src/**`.

**Existing tests that constrain this work.** `src/__tests__/designSystemConsistency.test.ts`: lines 58-65 (J-003a) assert the FIRST `@import` in App.css precedes the first `{` rule — since both @imports at lines 13-14 stay contiguous and before any rule, editing the line-14 URL does not affect it; lines 67-71 (J-003b) assert `"Source Sans 3"` is ALWAYS double-quoted (`.not.toMatch(/[^"]Source Sans 3/)` and `.toContain('"Source Sans 3"')`); lines 74-93 (J-001/J-002) assert `.lesson-content-chunk p` uses a token-based font-size matching `--typography-fontSize-(base|lg|xl)` plus `--typography-lineHeight-relaxed`, and `.lesson-content-chunk h4` uses `--typography-fontSize-base` and NOT `-sm`. `src/__tests__/fieldJournalTokens.test.ts:214-219` holds a second J-003 assertion scoped to mechanism 2's generated CSS; its comment at lines 145-150 notes this describe block is expected to stay RED until the Atelier pipeline regenerates that file — a known, pre-existing expected-red state from #31's Amendment, NOT a new regression to chase. `src/__tests__/tokenSystem.test.ts:39-44` asserts `generateCSSVariables()` output contains `--typography-fontSize-base`, `--typography-fontSize-2xl`, `--typography-lineHeight` — name presence only, not exact values, which is what makes additive work safe; it does NOT exercise composite tokens, so it would not catch the `[object Object]` failure mode. `src/__tests__/contrast.test.ts` contains zero typography assertions. `src/__tests__/nativeDialogPolicy.test.ts` enforces the no-native-dialog invariant.

**Routing** is a custom pushState router at `src/hooks/useRoute.ts` plus `src/App.tsx` lines 72-147 — not react-router. Real routes confirmed: `/learn`, week-detail via `matchWeekDetailRoute`, `/admin/dashboard`, `/feedback`. Native browser dialogs: ZERO call sites in `src/`.

**Mobile breakpoint convention:** the existing project convention is `@media (max-width: 640px)`, confirmed live at `App.css:629` and `ForcedPasswordChangeGate.css:175`. No new breakpoint system is introduced.

## Research evidence and its limits

A nested Researcher completed a full local sweep (profile: standard, mode: architecture); its findings are folded into "Verified repository findings" above and were independently spot-checked by design review against the actual files.

**RESIDUAL LIMIT, record prominently — identical in kind to issue #31's.** The verbatim GitHub issue #32 body, its acceptance-checkbox list, and the live open/closed/label state of #33-#44 are UNVERIFIED. `gh` is NOT on the Researcher Bash allowlist (`.claude/hooks/validate-researcher-bash.ps1`, allowed patterns at lines 33-42), and the repo is private so unauthenticated web/API access returns 404. One attempt each at `gh issue view 32` and `gh issue list` was made and blocked by the PreToolUse hook before any network call; no issue text was retrieved and none was fabricated.

Substitute evidence, treated as the specification of record, exactly as #31 did:

- `design/field-journal/ADOPTION-PLAN.md` §A.2 "Type — four hands" (lines 53-64), §A.6 (lines 88-95), the ratified-deviations section (lines 96-114), and Step 3 table row 2 (line 221): "Typography: four hands — add IBM Plex Mono + Caveat, Fraunces 900; define display/heading/body/target-line/label/margin-hand roles; fix the font import chain | A.2 | `src/App.css` (`@import` block), token files, `src/tokens/tokenSystem.ts`".
- `design/field-journal/judge/issue-map.json` confirms `"2": 32` — plan-issue 2 maps to GitHub #32.
- `design/field-journal/extracted/tokens.field-journal.json` lines 83-118 is the DTCG source of truth for every ratified type value.
- `design/field-journal/Field Journal DS.dc.html` §A.2 lines 104-131 carries the rendered specimens, verified byte-for-byte against the token JSON.
- Downstream chain confirmed from ADOPTION-PLAN.md lines 218-233: #33 "Token plumbing + fallback audit" (every var() gets a defined value, closes #29, adds a lint/test failing on undefined custom properties and raw hex outside the token layer, re-points icons.tsx) — CONFIRMED this is where the fallback/hardcoded-value audit lives, NOT #32. #34 Journal devices. #35 Components C.1-C.3. #36 Components C.4-C.8. #37 Login. #38 Roadmap. #39 Week detail. #40 Flashcards. #41 Feedback. #42 Owner dashboard + Roster. #43 Brand + Catalog. #44 Derived screens.

Also unverified, carried from #31: `lizbeth_spanish` is gitignored inside the orchestrator repo and has no local `.git`, so local file state cannot be reconciled against the GitHub remote HEAD.

## Design route and handoff

```
DESIGN_ROUTE
profile: standard
reasons: Issue #32 replaces the typographic substrate of every screen in a live production app — six type roles, two new font families, a new Fraunces weight, a corrected font-loading chain — and interacts directly with a live user-facing accessibility text-scaling and dyslexia-font-substitution feature. Not studio: the creative direction is already ratified and CLOSED upstream, so there were no three directions to select between. Not compact: too system-wide, too many mechanisms, too many interaction states.
agents_required: design-director, ux-architect, visual-system-designer, design-reviewer
prototype: forbidden
model_tier: sonnet
existing_system_mode: extend
END_DESIGN_ROUTE
```

**Design handoff: PASSED WITH ONE LEAD-AUTHORIZED CORRECTION** (see Design review below). The full `DESIGN_HANDOFF` was retained in the planning chain; all load-bearing content is reproduced in Interfaces and data and Acceptance and validation below. Selected direction: not applicable — no new creative direction was generated; the packet converts an already-ratified, closed system into an implementable token specification. Profile: standard. Prototype: forbidden, none created.

**Design review.** One full review plus the single permitted revision cycle.

- First pass: `NEEDS_REVISION` with 1 CRITICAL, 2 MAJOR, 2 MINOR findings. The CRITICAL was that the director's proposed Google Fonts import DROPPED Fraunces roman 600, which is consumed app-wide by `App.css:292-296` (every h1-h6), `App.css:408-410`, `WeekCard.css:56-58`, and `Modal.css:56-61` — shipping it would have silently substituted the nearest loaded weight for every heading in the app, an unflagged global visual regression. The two MAJORs: (i) the packet never stated whether the new role tokens were additive-and-unconsumed or wired into live selectors, risking either silent scope creep into #33/#35/#36 or a false-negative validation fail; (ii) `role.label` was excluded from accessibility font substitution on a "not a block of text" rationale despite carrying functional, non-decorative content with no aria-hidden defense. The two MINORs: an inaccurate rationale for the App.css:735 fix, and an untracked OpenDyslexic gap.
- Revision: all five findings confirmed remediated by the reviewer.
- Second pass: reviewer confirmed 5/5 remediated but surfaced ONE new CRITICAL defect introduced by the revision — the revised packet specified `typography.role.label.fontFamily`'s value as `var(--typography-role-label-fontFamily, "IBM Plex Mono", monospace)`, a custom property referencing its OWN generated name.
- **Resolution, by explicit lead authorization.** Because reviewer and director agreed on the exact one-line fix with no contested design judgment, the lead authorized recording the reviewer's own specified remediation directly as a binding engineering invariant without a further design-review pass, rather than spending a second revision cycle. That correction is recorded in Interfaces and data below and is BINDING. This is the sole point where the persisted plan departs from the reviewed packet, and it does so by adopting the reviewer's own remediation text verbatim.
- Reviewer's remaining limits, recorded verbatim in substance: both review passes were STATIC — no `npm test`, `tsc`, or Atelier validator was executed by the design fleet. Verification of the font-weight gaps and the CSS cycle-detection claim was done against repository files and CSS specification behavior, not against a built or rendered page. The four contrast ratios were independently recomputed by hand using the WCAG 2.x relative-luminance formula matching `src/lib/contrast.ts` and confirmed correct; the design director's earlier claim of live `mcp__atelier__contrast_check` provenance is NOT relied upon, because the Atelier MCP `projectRoot` misconfiguration documented in #31's Amendment remains unresolved this session.

## Judge route

Checkpoint `CODE_REVIEW` is REQUIRED, per the milestone's per-issue adoption judgement (ADOPTION-PLAN.md Step 4 checkpoint 2).

- Risk: medium.
- Model: gpt-5.6-terra/medium (multi-file, cross-layer semantics across four token-delivery mechanisms plus a JS inline-style mechanism).
- Rubric: type-value fidelity against `design/field-journal/extracted/tokens.field-journal.json` lines 83-118; no dropped font weight versus the pre-#32 import; no self-referential or circular custom property; no composite `$type: "typography"` token reaching `tokenSystem.ts`; additive-and-unconsumed discipline (no component selector wired); no raw hex outside the token layer; `--text-size-multiplier` participation preserved.
- Call cap: 2 for the standard path, one checkpoint repeatable once after remediation.
- `PLAN_DUCK` is available to the orchestrator after this plan is drafted, per `docs/JUDGE-CONTRACT.md`.
- Deterministic failures (`tsc`, vitest, Verifier, Browser Validator) ALWAYS dominate the judge.
- `.claude/judge-policy.json` is in shadow mode, so a judge finding is advisory unless blocking has been enabled.

## Ordered work

Owner for every step: T1, escalate to T2 on two counted gate failures. Strict TDD — RED evidence is required before any production edit in every step that has a test.

0. **PRE-FLIGHT** (orchestrator, before dispatching T1): run `gh issue view 32 --repo lebobo88/lizbeth-spanish` and `gh issue list --repo lebobo88/lizbeth-spanish --state all --limit 60 --json number,title,state,labels` and confirm the live issue #32 body matches this plan's scope. If it materially differs, do NOT implement — replan. This mirrors #31's step 0 and is the mitigation for the residual research limit.
1. **RED:** extend `src/__tests__/tokenSystem.test.ts` and add typography-layer assertions. Assert that every new custom property listed in Interfaces and data is emitted by `generateCSSVariables()`; that NO emitted value contains the substring `[object Object]`; that no emitted custom property's value contains a `var()` reference to its OWN name (the self-reference guard); and that `--typography-role-label-fontFamily` resolves to the literal `"IBM Plex Mono", monospace`. Add an assertion that the corrected App.css @import string contains every one of `0,400`, `0,600`, `0,700`, `0,900`, `1,600` for Fraunces. Confirm the tests fail for the right reason before writing any production code.
2. **GREEN, primitives:** add the `typography.fontFamily.*` group to `src/tokens/primitives.json` per Interfaces and data. Add NO new color primitive.
3. **GREEN, semantic:** add the pre-flattened `typography.role.<role>.<property>` scalar group and `typography.measure.reading` to `src/tokens/semantic.json` per Interfaces and data. Every `$value` must be a STRING or NUMBER — never a composite object, because `tokenSystem.ts` cannot flatten one. Do NOT modify the pre-existing `typography.body`/`typography.heading` groups or `measure.reading`.
4. **GREEN, font chain:** replace the `src/App.css:14` @import with the exact corrected string in Interfaces and data. Preserve the J-003a constraint — the @import block stays first, before any rule. Preserve J-003b — `"Source Sans 3"` stays double-quoted, and `"IBM Plex Mono"` follows the same quoting discipline.
5. **GREEN, line-height bug:** correct `src/App.css:735`'s `line-height` reference per Interfaces and data. Leave the unrelated `font-size: var(--font-size-body)` on the same line untouched. Then determine whether `src/pages/OwnerDashboardPage.css:31` and `src/pages/AdminStudentsPage.css:415` — which reference the undefined `--line-height-body` DIRECTLY — are fixed by the body-selector change or need their own explicit reference. Do NOT assume inheritance carries the fix; confirm it, and if it does not, apply the corrected reference at those two call sites too.
6. **GREEN, accessibility substitution:** add the `labelFontMap` to `src/context/AccessibilityContext.tsx` per Interfaces and data, setting `--typography-role-label-fontFamily` alongside the existing `--font-family-body` call. Do not alter the existing `fontMap` behavior for `--font-family-body`.
7. **Run the full deterministic gate:** `npm run lint`, `tsc`, `npm test`. Every pre-existing test must stay green and UNMODIFIED, with the single documented exception of `fieldJournalTokens.test.ts`'s already-expected-RED Atelier block carried over from #31's Amendment — that block's pre-existing state is not a #32 regression and must not be "fixed" by weakening it.
8. **Atelier gate, CONDITIONAL** — see the pre-authorized contingency in Assumptions and decisions. If the Atelier MCP `projectRoot` misconfiguration is resolved by the time this runs, execute `mcp__atelier__tokens_validate` -> `tokens_compile` -> `design_review` -> `contrast_check` -> `a11y_audit`. If it is still broken, apply the pre-authorized fallback rather than blocking.
9. **Codex `CODE_REVIEW` judge pass** per Judge route above.
10. **Verifier pass, then Browser Validator pass** per Browser UI validation below.

## Interfaces and data

**FLATTENING DECISION.** Pre-flattened scalar DTCG tokens through the EXISTING, UNMODIFIED `tokenSystem.ts` — zero code change to the flattener. Rationale: `flattenTokens()` never inspects `$type`, so a composite object `$value` stringifies to `[object Object]`, producing invalid CSS that silently fails. Precedent: `semantic.json` already models `typography.body`/`typography.heading` as pre-flattened scalars. Naming convention is director-authored structure, labeled as such: `typography.role.<role-name>.<property>` in `semantic.json`, `typography.fontFamily.<family-name>` in `primitives.json`. Placement under `role.` avoids a path collision with the pre-existing, differently-shaped `typography.heading`/`typography.body` groups. Hyphenated ratified role names (`target-line`, `margin-hand`) are preserved verbatim.

**New primitive tokens** (`src/tokens/primitives.json`):

| Token | Value | CSS variable |
|---|---|---|
| `typography.fontFamily.display` | `Fraunces, serif` | `--typography-fontFamily-display` |
| `typography.fontFamily.label` | `"IBM Plex Mono", monospace` | `--typography-fontFamily-label` |
| `typography.fontFamily.hand` | `Caveat, cursive` | `--typography-fontFamily-hand` |

`typography.fontFamily.body` is deliberately OMITTED from primitives.json — role.body sources its family live from `--font-family-body`, whose sole authoritative runtime source is mechanism 4.

**New semantic role tokens** (`src/tokens/semantic.json`), all pre-flattened scalars. Every value traces to `tokens.field-journal.json` lines 89-117 and the `.dc.html` §A.2 specimens at lines 111-130:

- role.display: `-fontFamily: Fraunces, serif`; `-fontWeight: 900`; `-fontSize: 68px`; `-lineHeight: 0.95`; `-letterSpacing: -0.03em`; `-color: var(--color-ink-1000, #1a1512)`
- role.heading: `-fontFamily: Fraunces, serif`; `-fontWeight: 700`; `-fontSize: 34px`; `-lineHeight: 1.15`; `-letterSpacing: -0.015em`; `-color: var(--color-ink-1000, #1a1512)`
- role.body: `-fontFamily: var(--font-family-body)`; `-fontWeight: 400`; `-fontSize: 17px`; `-lineHeight: 1.6`; `-color: #2a2420`
- role.target-line: `-fontFamily: Fraunces, serif`; `-fontWeight: 600`; `-fontStyle: italic`; `-fontSize: 22px`; `-lineHeight: 1.4`; `-color: #7c6136`
- role.label: `-fontFamily: "IBM Plex Mono", monospace`; `-fontWeight: 600`; `-fontSize: 12px`; `-letterSpacing: 0.2em`; `-textTransform: uppercase`; `-color-ink: var(--color-ink-1000, #1a1512)`; `-color-brass: #7c6136`; `-color-terracotta: #a85e4a`
- role.margin-hand: `-fontFamily: Caveat, cursive`; `-fontWeight: 700`; `-fontSize: 26px`; `-lineHeight: 1.3`; `-color: #a85e4a`; `-transform: rotate(-1.5deg)`
- `typography.measure.reading` = `62ch` -> `--typography-measure-reading`. Distinct from the pre-existing `measure.reading` (65ch) and App.css's `--measure` (65ch); NEITHER of those is repointed.

**BINDING CORRECTION — `role.label.fontFamily` must NOT be self-referential.** This is recorded here with its full rationale so T1, Verifier, and Browser Validator can trace it. The reviewed design packet specified this value as `var(--typography-role-label-fontFamily, "IBM Plex Mono", monospace)` — a custom property whose declared value references its own generated name. Per the CSS Custom Properties specification's cycle-detection rule, a custom property participating in a reference cycle (including a direct self-reference) is set to its guaranteed-invalid value, and this happens REGARDLESS of any fallback argument inside the offending `var()` — cycle detection preempts substitution entirely, so the fallback is never reached. The ratified default could therefore never render through mechanism 1, and role.label would depend silently on mechanism 4's post-mount JS override, which it was never designed to require.

**BINDING RESOLUTION, authorized by the lead on 2026-08-31 and adopting the design reviewer's own specified remediation:** `typography.role.label.fontFamily`'s `$value` in `semantic.json` is the plain literal `"\"IBM Plex Mono\", monospace"` — NOT a self-referential `var()`, and NOT an alias back to its own generated name. `AccessibilityContext.tsx`'s `setProperty('--typography-role-label-fontFamily', labelFontMap[...])` remains the SOLE runtime-switching mechanism, exactly mirroring the already-verified `--font-family-body` pattern. (A reference to the DIFFERENT primitive `{typography.fontFamily.label}` is the equally-valid alternative the reviewer named; the lead selected the plain literal. Either satisfies the invariant; the literal is what is authorized.)

**The `var(--color-ink-1000, #1a1512)` pattern, explained.** `color.ink.1000` (#1a1512) exists in mechanism 2 but NOT in mechanism 1's `primitives.json`. Adding a new color primitive is outside #32's typography-only scope, so every `#1a1512` reference uses the fallback form `var(--color-ink-1000, #1a1512)`, mirroring the identical pre-existing pattern at `App.css:41` for `--color-focus-ring`. Custom-property references resolve against the element's computed cascade rather than the defining stylesheet, so mechanism 2's definition satisfies the reference at runtime while the inline hex guarantees correctness if it does not. `color.ink.900`, `color.brass.700`, and `color.terracotta.600` DO exist natively in mechanism 1's `primitives.json` and use ordinary `{color.x.y}` aliases.

**CORRECTED GOOGLE FONTS @import — exact string, replaces `src/App.css:14` verbatim:**

`@import url('https://fonts.googleapis.com/css2?family=Fraunces:ital,wght@0,400;0,600;0,700;0,900;1,600&family=Source+Sans+3:wght@400;600;700&family=Atkinson+Hyperlegible:wght@400;700&family=Lexend:wght@400;600;700&family=IBM+Plex+Mono:wght@400;500;600;700&family=Caveat:wght@500;700&display=swap');`

Reviewer-verified: axis tags `ital,wght` are alphabetical and the five Fraunces tuples are in ascending lexicographic order by (ital, wght) — valid Google Fonts CSS2 syntax. Per-family justification:

- **Fraunces** — kept. Roman 600 RESTORED (the CRITICAL finding; serves App.css:292-296, App.css:408-410, WeekCard.css:56-58, Modal.css:56-61 at their exact currently-loaded weight, zero regression). Roman 400 kept (default/unstyled). Roman 700 kept (LearnDetailPage.css:140). Roman 900 ADDED (role.display). Italic 600 ADDED (role.target-line) — the current import requests NO italic axis at all, a real, previously-unflagged gap; correcting it renders an already-ratified value.
- **Source Sans 3** — kept, weight list `400;600;700` UNCHANGED.
- **Atkinson Hyperlegible** — kept, weight list `400;700` UNCHANGED. Live consumer via mechanism 4's fontMap.
- **Lexend** — kept, weight list `400;600;700` UNCHANGED. Live consumer via mechanism 4's fontMap; already covers all its weight-600 call sites.
- **IBM Plex Mono** — ADDED at `400;500;600;700`. Only 600 is ratified-consumed today (role.label).
- **Caveat** — ADDED at `500;700`. Only 700 is ratified-consumed today (role.margin-hand).
- **Lora** — DROPPED. Zero consumers in `src/**`; its existing query syntax was also malformed.
- **OpenDyslexic** — untouched. Not a Google Fonts family; its loading gap is pre-existing and out of scope.

**`src/App.css:735` corrected reference:** `line-height: var(--typography-role-body-lineHeight);` (resolves to 1.6). The unrelated `font-size: var(--font-size-body)` on the same line stays untouched. Whether `.dashboard-table-wrap th/td` and `.admin-students-page` — which reference the undefined name directly — are fixed by this change or need their own explicit reference is NOT assumed either way and must be confirmed at implementation and again at browser validation.

**Accessibility font-substitution mechanism (mechanism-4 extension), `src/context/AccessibilityContext.tsx`:** add a second, role-aware map alongside the existing `fontMap`, following the same already-proven pattern, so it carries no new architectural risk. Recommended shape:

```ts
const labelFontMap: Record<TypographyOption, string> = {
  default: '"IBM Plex Mono", monospace',
  atkinson: '"Atkinson Hyperlegible", system-ui, sans-serif',
  lexend: 'Lexend, system-ui, sans-serif',
  opendyslexic: '"OpenDyslexic", system-ui, sans-serif',
};
```

then `root.style.setProperty('--typography-role-label-fontFamily', labelFontMap[settings.typography])` alongside the existing `--font-family-body` call. The static `semantic.json` default remains the ratified value that renders before, or in the absence of, this JS override — exactly as role.body's static default equals `fontMap.default` today.

**Mechanism-4 invariant for `--font-family-body`:** `AccessibilityContext.tsx`'s `fontMap` IS and MUST REMAIN the sole authoritative source for this property's runtime value. Mechanism 2's and mechanism 3's definitions are dead code for it. A stylesheet-only edit is silently inert. Recommended reconciled `fontMap.default`: `"Source Sans 3", system-ui, -apple-system, sans-serif`. Recommended guardrail (a recommendation, not mandated for #32): a code comment marking `fontMap` as the sole source of truth, plus a J-004-style regression test asserting `fontMap.default` stays byte-identical to role.body's ratified fontFamily.

## Acceptance and validation

**Deterministic:** `npm run lint` clean; `tsc` clean; `npm test` green with every pre-existing test passing UNMODIFIED — J-001, J-002, J-003a, J-003b in `designSystemConsistency.test.ts`; `tokenSystem.test.ts`; `contrast.test.ts`; `nativeDialogPolicy.test.ts` — with the single documented exception of `fieldJournalTokens.test.ts`'s already-expected-RED Atelier block inherited from #31's Amendment. New RED-first tests per ordered-work step 1. The J-003a "@import must be the first rule" constraint must be preserved.

**Scope discipline, testable:** the six new role token groups are ADDITIVE-AND-UNCONSUMED. No component selector may be wired to a new role token in this issue. Merging #32 must cause ZERO visible change to any existing screen, with font loading itself the sole substrate change (new families and weights become available to the browser).

**Contrast, WCAG AA 4.5:1 as the sole gate,** computed with the repo's existing WCAG-only `src/lib/contrast.ts` formula and independently recomputed by hand during design review: `ink.1000` #1a1512 on #fdfcf9 = 17.65:1, on #faf8f4 = 17.07:1 (display, heading, label-ink). `ink.900` #2a2420 on #fdfcf9 = 14.92:1 (body). `brass.700` #7c6136 on #fdfcf9 = 5.65:1, on #faf8f4 = 5.47:1 (target-line, label-brass). `terracotta.600` #a85e4a on #fdfcf9 = 4.69:1, on #faf8f4 = 4.54:1 (margin-hand, label-terracotta). All four pass on both paper grounds, including at role.label's 12px size. There is NO APCA implementation in this repo and none is introduced.

**RECORDED ACCEPTED DEVIATION, ratified 2026-08-30, carried from #31 — do not soften, do not re-litigate:** `brass.600` (APCA Lc 73.7) and `terracotta.600` (Lc 71.3) fall under the APCA Lc 75 body threshold recorded in the Atelier config. Both clear WCAG AA and are ratified for their band-ink text roles. This is NOT a defect. A future `contrast_check` or `a11y_audit` finding against them must be read against this deviation and must NOT be treated as a new regression.

**The seven fixed acceptance criteria carried by every issue in this milestone** (ADOPTION-PLAN.md reference §A.6), scoped to the typography layer for #32:

1. No state by color alone — every state carries a glyph, outline, stamp shape, or literal word.
2. Text contrast >= 4.5:1, `amber.*` and `terracotta.500` never carry text.
3. Hit targets >= 44px, controls and fields 48px tall.
4. Focus = 3px `ink.slate` ring at 2px offset, drawn outside the shadow.
5. Decoration is inert and `aria-hidden` — deleting every decorative element must leave the screen fully usable.
6. Zero border-radius on everything in scope, depth is a hard offset never a blur.
7. No raw hex in CSS — tokens only, and `prefers-reduced-motion` collapses every animation to an instant state change with no opacity-only fades.

**Engineering invariants, all BINDING:**

- #32's authorized touch-surface is `src/App.css`'s @import block, the token JSON files, `src/tokens/tokenSystem.ts`, and `src/context/AccessibilityContext.tsx`'s substitution maps ONLY. No component selector may be wired to a new role token.
- No color, radius, shadow, motion, or size token value from issue #31 may be altered.
- No pre-existing `--typography-fontSize-*`, `--font-size-*`, or other pre-existing type token may be repointed.
- The corrected @import must not drop ANY currently-loaded Fraunces weight (roman 400/600/700) while adding roman 900 and italic 600.
- No custom property may reference its own generated name. Every `$value` reaching `tokenSystem.ts` must be a string or number, never a composite object.
- `AccessibilityContext.tsx`'s `fontMap` remains the sole source of truth for `--font-family-body`'s runtime value, extended with the second role-aware map for `--typography-role-label-fontFamily`.
- `role.margin-hand`, once it ever gains a markup site: always `aria-hidden="true"`; never the sole carrier of information; content always duplicated in an accessible role in the same view; removing it from the DOM must not change view completeness. Any `role.label` instance using contextual ink to signal a category must also spell out that category in text or its accessible name.
- No `forced-color-adjust: none` or equivalent on any of the six roles.
- No transition, animation, or `@keyframes` is added for any of the six roles. `role.margin-hand`'s `rotate(-1.5deg)` is a ratified STATIC transform, not an animation, and needs no reduced-motion branching.
- No native browser dialog may be introduced.

## Risks and rollback

| ID | Severity | Risk | Mitigation |
|----|----------|------|------------|
| R1 | Highest | Dropping a currently-loaded font weight silently substitutes the nearest match app-wide. Fraunces roman 600 backs EVERY heading in the app | Caught as a CRITICAL design-review finding; the corrected @import restores `0,600`; ordered-work step 1 adds an explicit test asserting all five Fraunces tuples are present |
| R2 | High | Mechanism 4's inline style silently reverts any body-font change made only in mechanisms 1/2/3 — the direct analogue of #31's mechanism-1 cascade defect | `fontMap` is declared the sole authoritative source; drift risk is currently NONE because `fontMap.default` already matches the ratified value byte-for-byte; a J-004-style guardrail test is recommended |
| R3 | High | A composite `$type: "typography"` token reaching `tokenSystem.ts` emits `[object Object]` — invalid CSS that fails SILENTLY, with no existing test catching it | Pre-flattening to scalars; ordered-work step 1 adds an explicit `[object Object]` assertion |
| R4 | High | A self-referential custom property is set to guaranteed-invalid per CSS cycle detection, with the fallback never reached — also a silent failure | The BINDING CORRECTION in Interfaces and data; ordered-work step 1 adds a self-reference guard assertion |
| R5 | Medium | The `--line-height-body` fix may not reach `OwnerDashboardPage.css:31` and `AdminStudentsPage.css:415`, which reference the undefined name directly rather than inheriting | Ordered-work step 5 requires confirming rather than assuming; browser-validation check (d) re-confirms at runtime |
| R6 | Medium | Plan staleness: `lizbeth_spanish` has no local `.git` and is gitignored by the parent repo, and issue #32's body was never read verbatim | Ordered-work step 0 pre-flight is the mitigation |
| R7 | Medium | The Atelier MCP `projectRoot` misconfiguration remains unresolved this session, so `field-workbook.generated.css` is still hand-transcribed and mechanism 2 cannot be tool-verified | The pre-authorized contingency in Assumptions and decisions; #32 does not require regenerating mechanism 2, which materially lowers this risk versus #31 |
| R8 | Low | Residual legibility risk for dyslexic and low-vision users from role.label's ratified uppercase + 0.2em tracking at 12px, which the font-substitution extension does NOT remove | Disclosed honestly, not resolved; recorded as an open item requiring accessibility sign-off before any future change to that ratified treatment |

**Rollback.** Every change is confined to the token layer, the App.css @import line, one App.css line-height reference, one accessibility-context map, and new tests. No component file is restyled, no data migration, no schema change, no API surface change. Revert is a straight `git revert` of the commit.

**Follow-ups, explicitly out of scope here:** self-host OpenDyslexic or remove the option from `AccessibilitySettings.tsx:106-115` (a live, user-selectable accessibility option that currently does nothing); the Source Sans 3 weight-500 availability gap; the Atkinson Hyperlegible weight-600 availability gap; the `-apple-system` `fontMap.default` reconciliation and the J-004 guardrail test if not filed inside #32; full retirement of mechanism 1's runtime JS injection; the orphaned `--measure-reading`/`--typography-body-fontSize`/`--typography-heading-fontSize` tokens.

## Assumptions and decisions

**Assumptions, labeled:**

- `ADOPTION-PLAN.md` row 2 plus `issue-map.json` are treated as the specification of record for issue #32 because the verbatim issue body is unreachable. Verification step: ordered-work step 0.
- Director-authored, NOT ratified: the `typography.role.*` / `typography.fontFamily.*` naming convention; the proposed 40px mobile `role.display` size; the reuse of the existing `@media (max-width: 640px)` breakpoint; the `labelFontMap` extension; the `-apple-system` reconciliation; the proposed J-004 test. Each is labeled as director-authored scaffolding in the same way #31 labeled its component tier.
- Inference, high confidence, not empirically run in a browser: that `tokenSystem.ts` would emit `[object Object]` for a composite token, and that mechanism 1 wins the cascade over mechanisms 2 and 3.
- The Fraunces italic-axis import correction was INFERRED as necessary to render an already-ratified value, not independently requested by the reference text.
- Whether `.dashboard-table-wrap`/`.admin-students-page` inherit the body line-height fix is NOT assumed either way; flagged for confirmation.

**PRE-AUTHORIZED ATELIER CONTINGENCY — cite #31's Amendment as precedent; engineering does NOT need to stop and ask again.** The Atelier MCP compiler is currently broken in this session: its `projectRoot` resolves to `H:\CommandCenter\orchestrator` instead of the target repository, confirmed twice via `mcp__atelier__atelier_info`, and the misconfiguration is still unresolved. Issue #31's plan Amendment (2026-08-31) recorded the user's verbatim live-session authorization — "skip atelier for now and proceed forward as planned." — and established a deterministic, disclosed, byte-verified hand-transcription fallback with a binding follow-up requirement. That same fallback is PRE-AUTHORIZED for issue #32 on identical terms: if #32 requires generating or regenerating `src/tokens/field-workbook.generated.css` through the real Atelier pipeline and the pipeline is still non-functional, T1 may hand-transcribe deterministically, must verify byte-for-byte via `git diff` that no pre-existing declaration changes except the deliberate ones this plan specifies, must rewrite the file header to flag it as a manual transcription pending real Atelier re-verification rather than claiming machine generation, and must report the absence of each skipped Atelier validator honestly rather than fabricating a result.

**Note materially: #32's scope does not currently require touching mechanism 2 at all** — the new tokens land in mechanisms 1 and 4 plus the App.css @import — so this contingency is a safeguard, not an expected path. The binding follow-up from #31 stands unchanged: once the misconfiguration is fixed, the real `tokens_validate` -> `tokens_compile` pipeline must be re-run and diffed for zero drift, and issue #31 remains CONDITIONALLY complete until then.

**Standing authorization.** The user has granted standing authorization covering both bounded implementation decisions and plan approvals for this milestone, quoted as relayed by the orchestrator: "didn't i tell you to stop asking me for approval? i told you to keep going until all the gh issues are finished," reinforced by an explicit session goal, "don't stop until all the DS gh issues are implemented and browser validated." The same provenance discipline #31's plan used applies here: this reached Scribe entirely through the orchestrator's account of the session; it is recorded as an orchestrator-applied inference under standing authorization, NOT as a Scribe-verified per-document user approval. Approval of this document authorizes only issue #32's scope; it does not authorize #33-#44.

**Lead decision, 2026-08-31.** The lead explicitly authorized recording the design reviewer's one-line `role.label.fontFamily` remediation directly as a binding engineering invariant, without spending a second design-review revision cycle, on the stated grounds that reviewer and director agreed on the exact fix with no contested design judgment. This is recorded as a direct lead instruction, distinguished from the standing-authorization inference above.

## Browser UI dialog policy

REQUIRED — this is a browser-rendered React UI. Native `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload` prompts are prohibited. Any acknowledgement or confirmation must use an app-owned accessible modal, with inline validation where it serves the user better. The repo currently has ZERO native dialog call sites, enforced by `src/__tests__/nativeDialogPolicy.test.ts`. Issue #32 must introduce none; a deterministic no-native-dialog source scan is a required check.

## Browser UI validation

**Launch/readiness:** `npm run dev -- --port 4319 --strictPort` — NOT the Vite default 5173, and outside the reserved 5173-5195 range. `vite.config.ts` currently sets `server.port: 5173`; override via CLI rather than editing the committed config, since a config change is outside this issue's scope. Readiness = the Vite ready line plus a successful load of the base URL.

**Base URL:** `http://localhost:4319`

**Fixture/reset:** existing Supabase development data. This is a presentation-layer change with no data dependency; no seeding or reset is required beyond an authenticated student session and an authenticated owner session to reach the admin routes.

**Journeys (confirmed real routes):** `/learn` (LearnIndexPage); the week-detail route matched by `matchWeekDetailRoute` (WeekDetailPage + LessonContentView); `/admin/dashboard` (OwnerDashboardPage); `/feedback` (FeedbackPage).

**Viewport profiles:** 1440x900 (desktop reference artboard) and 390x844 (mobile reference artboard).

**Visible outcomes — note prominently that because #32 is ADDITIVE-AND-UNCONSUMED, validation targets token existence, font loading, and the ABSENCE of regression, NOT new visible role rendering. No selector consumes a new role token yet.**

(a) **FONT LOADING** — via devtools Network/Font panel on `/learn` after the corrected @import ships, confirm Fraunces roman 900, Fraunces italic 600, IBM Plex Mono (400/500/600/700), and Caveat (500/700) all load with no 404s; and confirm Fraunces roman 600 — the previously-at-risk weight — still loads and that existing headings (`h1`-`h6`, `.app-header-logo-placeholder`, `.week-card-week-number`, `.modal-title`) render pixel-identical to the pre-#32 baseline.

(b) **TOKEN RESOLUTION** — via the devtools Computed panel or `getComputedStyle()` on `:root`, confirm every new custom property in Interfaces and data is DEFINED, non-empty, and not `[object Object]`, and resolves to its exact ratified value — for example `--typography-role-display-fontSize` computes to `68px`, `--typography-role-margin-hand-transform` computes to `rotate(-1.5deg)`, and `--typography-role-label-fontFamily` computes to `"IBM Plex Mono", monospace` before any accessibility override is applied.

(c) **NO VISIBLE REGRESSION** — full-page screenshot diff at both viewports across all four journeys against pre-#32 baselines. Expect zero pixel difference, since no selector consumes a new token. A 0.1% global tolerance is permitted only for anti-aliasing noise unrelated to any token in this spec.

(d) **LINE-HEIGHT FIX** — after the `body{}` correction, use computed-style inspection to confirm `.dashboard-table-wrap th/td` (OwnerDashboardPage.css:31) and `.admin-students-page` (AdminStudentsPage.css:415) both compute `line-height` to 1.6. Do NOT assume inheritance carries the fix; if either still resolves to `normal` or another value, flag it as a remaining defect requiring its own explicit token reference.

(e) **ACCESSIBILITY SUBSTITUTION** — toggle atkinson, lexend, and opendyslexic in Accessibility Settings and confirm that `--font-family-body` AND `--typography-role-label-fontFamily` both change together to the selected family, while `--typography-fontFamily-display`, `--typography-fontFamily-hand`, and `--typography-role-{display,heading,target-line,margin-hand}-fontFamily` remain unchanged. Record honestly that selecting opendyslexic will not visually change anything until the pre-existing loading gap is fixed by the recommended follow-up.

(f) **TEXT SCALING** — adjust the text-size range control and confirm the existing 44 `calc(var(--typography-fontSize-*) * var(--text-size-multiplier))` call sites still scale correctly with no layout collision or overflow at either viewport.

(g) **NO NATIVE DIALOGS** — deterministic source scan confirming none was introduced.

(h) **REGRESSION SUITE** — confirm `designSystemConsistency.test.ts` (J-001, J-002, J-003a, J-003b) and `nativeDialogPolicy.test.ts` pass unmodified.

**FORWARD REFERENCE, not this issue's validation target:** once a future issue wires the six roles into live selectors, that issue's own validation brief should use the route-to-role mapping preserved in this plan's design section — `/learn` (display, label, heading, body), week-detail (heading, label, body, target-line), `/admin/dashboard` (heading, label, body), `/feedback` (heading, body, label). `role.margin-hand` has no markup site anywhere yet, verified by direct read of `LessonContentView.tsx`.
