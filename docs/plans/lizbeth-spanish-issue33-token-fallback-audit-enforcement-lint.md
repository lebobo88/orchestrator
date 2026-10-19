# Lizbeth Spanish — Issue #33: DS plumbing, token fallback audit + enforcement lint

**Status: Drafted, routed to engineering under the user's standing authorization. This document has not itself been separately approved by the user; the user has granted standing authorization ("keep going until all the gh issues are finished") that the orchestrator applies to route this plan to engineering, per the Approval basis recorded below. Approval of this document authorizes only issue #33's scope; it does not authorize any of issues #34-#44.**

Note: the shared #31/#32 Atelier compiler-gap follow-up (Atelier MCP's project-root resolution failure, which forced manual transcription of `src/tokens/field-workbook.generated.css` on 2026-08-31) remains open. It is **not re-litigated in this plan**; it is inherited context only, referenced in Interfaces and data below where it directly governs how this issue's new tokens must be authored.

---

## Approval basis

This plan was routed to engineering under the orchestrator's application of the user's standing authorization, not a user-verified per-plan approval. The record below is an orchestrator-applied inference, consistent with the Status line above, and follows the same provenance discipline the #31 and #32 plans used.

- **Standing authorization quoted (verbatim, as relayed by the orchestrator):** "didn't i tell you to stop asking me for approval? i told you to keep going until all the gh issues are finished," reinforced by an explicit session goal, "don't stop until all the DS gh issues are implemented and browser validated."
- **Application:** The orchestrator applied this standing authorization to route this plan (issue #33 of `lebobo88/lizbeth-spanish`, the next issue in the dependency chain the user directed continuation through, after #31 and #32) to engineering without a further live per-plan checkpoint.
- **Staleness cross-check:** The orchestrator independently fetched the live GitHub issue #33 body AND the referenced issue #29 body (via `gh issue view`) and relayed both directly into Planner's context mid-session. This confirmed issue #33 is titled "DS plumbing: token fallback audit + enforcement lint," that it explicitly closes #29, and that it requires a build-breaking enforcement test covering undefined `var()` references, raw hex colors, non-zero `border-radius`, and non-zero-blur `box-shadow` — all reflected in this plan's Scope (§2) and Ordered work (§7, step 0). This fetch-and-relay satisfied this plan's own pre-flight staleness check as part of the same session action, not as a separate later step; the plan is not stale.
- **Provenance label:** This basis reached Scribe entirely through the orchestrator's account of the session; Scribe has not independently observed the quoted user statements or the raw `gh issue view` output. It is recorded here as an orchestrator-applied inference under standing authorization, NOT as a Scribe-verified per-document user approval.
- **Design gate, distinguished from the standing-authorization inference above.** The design route for this plan did not conclude with a full `DESIGN_REVIEW_RESULT: PASS`. After two review cycles, cycle 2 verified all nine cycle-1 findings CLOSED but raised one new high-severity finding: 11 call sites carrying stale focus-ring fallbacks not yet extended to the already-validated fix pattern. Per `docs/DESIGN-CONTRACT.md`, this second disagreement escalated to the user. The orchestrator reports the user chose "option A": accept the design packet as-is and carry the 11 sites forward as a binding, fully-specified engineering work item (this plan's §7 step 1), rather than running a third design cycle, on the stated grounds that the gap is mechanical with no open design question remaining. This is recorded in this plan as a user-accepted design gate (see §4), not as a design PASS, and is documented here for the same reason recorded on the #32 precedent: it is a lead/user decision distinct from the general standing-authorization inference above.
- **Date:** 2026-09-01.

## 1. Outcome and audience

GitHub issue #33, "DS plumbing: token fallback audit + enforcement lint," is the third issue in the 14-issue Field Journal Design System milestone (#31–44), dependency-chained after #31 (foundations) and #32 (typography). Closing #33 also closes issue #29.

Primary audience: the T1/T2 engineering writer who implements this plan. Secondary audience: Verifier (independent completion check) and Browser Validator (rendered UI check).

Observable result when this plan is complete:

- Every `var(--token)` referenced anywhere under `src/` resolves to a value defined in the generated token layer. No dangling custom-property references remain.
- The Field Journal palette (ink / paper / brass / terracotta / moss / slate) renders everywhere in the app instead of silently degrading to generic Tailwind gray/blue/green/amber fallback colors.
- A new build-breaking test exists under `src/__tests__/` that prevents regression of both defects, and names the offending file and line on failure.

## 2. Scope and non-goals

### In scope (verbatim from issue #33)

Every `src/**/*.css` file, `src/components/icons.tsx`, and a new test under `src/__tests__/`.

Issue #33 acceptance criteria, verbatim:

- Every custom property referenced anywhere under `src/` is defined in the generated token layer.
- A test in `src/__tests__/` fails the build on: (a) a `var(--x)` whose `--x` is never defined, (b) a raw hex color outside `src/tokens/`, (c) a non-zero `border-radius`, (d) a `box-shadow` with a non-zero blur radius.
- The test names the offending file and line, so a failure is actionable.
- `src/components/icons.tsx` takes its colors from tokens.
- Running the app with the network blocked (no webfonts) still renders the correct palette.

Plus the standard fixed A.6 criteria (see §3) and the standard Verification section (tsc/vitest, Atelier tools, Codex judge), the same as #31/#32.

### Non-goals

- Do not change any token value shipped by #31 or #32. Those values are browser-validated, design-reviewed PASS, and are treated as **ground truth** by this plan.
- Do not reopen any ratified deviation recorded in `design/field-journal/ADOPTION-PLAN.md`.
- The `role.body.lineHeight` static-1.6 vs `max(var(--line-height-floor), var(--line-height))` divergence is **explicitly out of scope**. It is a deliberate, tested, disclosed decision (J-032-003), documented at `src/__tests__/typographyFourHands.test.ts:195-265`. It is not drift and must not be touched.
- The narrow #29 fixes already landed for `AdminStudentModals.css` and `RegisterStudentModal.css` (including the WCAG 2.39:1 → 10.1:1 contrast fix) are done and are not to be redone.
- #29's own "per-page batches" triage suggestion is superseded: #33 is the single consolidated remediation, not a batch-by-batch continuation of #29.

## 3. Repository findings and evidence references

- Design system of record: `design/field-journal/Field Journal DS.dc.html`, §A.6 "rules that do not bend" (approximately line 21337).
- Token values: `design/field-journal/extracted/tokens.field-journal.json`, with a clean cross-vendor verdict recorded at `design/field-journal/judge/verdict.json`.
- Ratified deviations: `design/field-journal/ADOPTION-PLAN.md`.
- Token source of truth: `src/tokens/field-workbook.generated.css`.
- Derived app-level custom properties: `src/App.css :root`.

Shipped #31 focus values (ground truth, do not change):

- `--color-focus-ring: var(--color-ink-slate, #3d5f6b)` at `src/App.css:41`.
- `--focus-ring-width: 3px` at `src/tokens/field-workbook.generated.css:29`.
- `--focus-ring-offset: 2px` at `src/tokens/field-workbook.generated.css:28`.
- `--radius-square: 0px` at `src/tokens/field-workbook.generated.css:58`.

The `src/App.css:41` hex fallback is **deliberate**. `src/App.css:36-40` documents it as a guard against a token-load-order race between two mechanisms. This plan keeps it; it is the sole exception to the fallback-stripping pass in step 9.

Existing regression tests to keep green throughout this work: `src/__tests__/fieldJournalTokens.test.ts` and `src/__tests__/typographyFourHands.test.ts`.

Deprecated non-zero radii `--radius-medium` / `--radius-pill` / `--radius-small` (`field-workbook.generated.css:51-57`) have zero live `var()` consumers, independently confirmed by the design reviewer. No new consumer of these deprecated tokens may be introduced by this work.

### Evidence provenance

Issue #33 and #29 bodies were retrieved by the orchestrator via `gh issue view` and are quoted verbatim in §2 above. All repository findings in this plan were produced by a nested Researcher's exhaustive read-only audit of all 26 `src/**/*.css` files, then independently re-verified by the design reviewer across all 1282 `var(--` matches in `src/`.

Corrections to the original brief that this plan records for the record:

- `ForcedPasswordChangeGate.css` is located at `src/components/` (not `src/pages/`), and it has 4 affected sites (not 2), as enumerated in the ordered work below.
- `AccessibilitySettings.css:27` was only partially fixed by a prior pass: the width is correctly 3px but the color fallback is still stale. This means there are 6 fully-stale sites in that file, not 7.
- `--measure` is **not** undefined. It is defined at `src/App.css:73` as `65ch` and consumed at `src/App.css:315`, `:330`, `:471`, and `LessonContentView.css:4`. The earlier flag against `--measure` was a false positive and needs no remediation action.

## 4. Design route, reviewed handoff, and user-accepted design gate

**Design route: compact.** Agents required: `design-generalist`, `design-reviewer`. Prototype: forbidden. Model tier: sonnet. Existing-system mode: preserve.

Rationale recorded by Planner: no new screens, flows, or components are introduced; all work sits inside the ratified system already shipped by #31/#32. However, because this work produces a real rendered palette change across many surfaces, the design route could not be `none`.

### Design handoff

`DESIGN_HANDOFF` (compact, task_id `lizbeth-issue33`), revision 2, accepted by explicit user decision.

### Design review outcome — user-accepted gate, not a design PASS

The design review ran two cycles:

- **Cycle 1:** `DESIGN_REVIEW_RESULT` = NEEDS_REVISION, 9 findings.
- **Cycle 2:** all 9 cycle-1 findings verified CLOSED. One new finding was raised by the reviewer: 11 residual stale-fallback outline/border sites (enumerated in step 1 below).

Per `docs/DESIGN-CONTRACT.md`, a second disagreement escalates to the user. The user was presented the finding on 2026-08-31 and chose **option A**: accept the design packet as-is and carry the 11 sites as an explicit, fully-specified engineering work item (step 1 of the ordered work below), rather than running a third design cycle.

This plan records this outcome as a **user-accepted design gate**, not a design PASS. The reviewer independently recomputed and confirmed every load-bearing contrast ratio cited in this plan (§7) and every citation to `ADOPTION-PLAN.md` used to justify a token mapping.

## 5. Browser UI dialog policy

Required. This is browser-rendered UI, and `Modal.css` is directly in scope for this issue.

Native `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload` prompts are **prohibited**. Confirmation and acknowledgement must use the app-owned accessible modal. Modal keyboard/focus behavior and the focus trap must be verified unregressed by Browser Validator. A deterministic no-native-dialog source scan is mandatory before this issue can be considered complete.

## 6. Browser UI validation brief

**Launch/readiness:** the project's dev server on a non-standard port, explicitly avoiding 5173–5195. Use port 5310 unless the repository already pins another non-conflicting port. Readiness is defined as the dev server reporting listening and the base URL returning the app shell.

**Base URL:** `http://localhost:5310`

**Fixture/reset:** use the repository's existing seeded local auth/data path. Reset to a clean seeded state before each journey batch. Both admin-role and student-role sessions are required. Do not weaken Docker or host security to obtain access.

**Journeys:**

- ForcedPasswordChangeGate (all fields, link buttons, error panel)
- RegisterStudentModal (submit, hover, validation error)
- Modal.css generic dialogs
- AdminStudentModals confirm/destructive/hard-delete/wipe-save flows
- AdminStudentsPage roster list, detail, and all status badges including `.status-confirmed`, `.status-unconfirmed`, `.status-preserved`
- CourseWorkspace and the TipTap editor
- AccessibilitySettings (Aa trigger, both sliders)
- WeekCard roadmap icons
- FeedbackPage
- RoadmapPage
- LessonContentView, all four chunk variants (rule/example/translation/dialect)
- ResourcesPanel
- OwnerSettingsPage
- OwnerDashboardPage metrics and status text
- WeekDetailPage locked/not-available/not-authored/error states
- LearnDetailPage
- FlashcardsViewer badge

**States to cover:** default, hover, keyboard focus-visible (tab through every control — do not rely on mouse click), disabled, error.

**Viewports:** 375px mobile, 768px tablet, 1280px desktop, per `CourseWorkspace.css`'s `@media (max-width: 700px)` and `src/App.css`'s 56.25rem breakpoint.

**Visible outcomes to confirm:**

- Every keyboard-focused control shows a 3px solid slate `#3d5f6b` ring at 2px offset, with zero remaining 2px or generic-blue outlines anywhere.
- Gate and register buttons/links render brass `#866843` / `#7c6136`, not blue.
- Admin roster rows, status badges, and every alert/confirmation panel render Field Journal ink/paper/terracotta/brass/moss on a neutral paper background with a colored border/text accent, not a Tailwind-style tinted fill.
- Error/success/warning panels remain visually distinguishable from each other and from ordinary content.
- CourseWorkspace textarea and TipTap editor focus rings render slate, not terracotta, while terracotta still correctly marks the active workspace tab underline and the `role=alert` rule.
- WeekCard roadmap icons render moss/brass-500/ink-700.
- Every previously round or pill control renders hard-square.
- Modal dialog and slider-thumb shadows render as hard zero-blur offsets, not soft drop-shadows.
- FeedbackPage and RoadmapPage containers render identically to before.
- No native dialog fires anywhere, and the Modal focus trap is unregressed.

## 7. Ordered work

Work must proceed in this order. Steps 1–9 are separately committable units so that a partial revert is possible if a later step surfaces a problem.

### Step 0 — Write the enforcement test first (TDD)

Write the enforcement test in `src/__tests__/` before any production edit. It must fail the build on:

- (a) `var(--x)` where `--x` is never defined anywhere in the union of `src/tokens/field-workbook.generated.css` and `src/App.css :root`.
- (b) a raw hex color outside `src/tokens/` — this explicitly includes inline `var(--token, #hex)` fallback literals.
- (c) any non-zero `border-radius`, including `50%` and `999px`.
- (d) any `box-shadow` with non-zero blur.

Every failure must name file and line. The test must correctly handle minified single-line files (`src/pages/CourseWorkspace.css`). It must whitelist the one deliberate exception at `src/App.css:41`.

Expect this test to fail loudly against current HEAD. That failing list is the authoritative work inventory that drives steps 1–9.

### Step 1 — User-accepted addition: the design reviewer's final finding (11 sites)

Fix 11 residual stale-fallback sites by dropping the stale `#0284c7` literals:

Replace `outline: 2px solid var(--color-focus-ring, #0284c7)` with `outline: var(--focus-ring-width, 3px) solid var(--color-focus-ring)` at:

- `Modal.css:33`
- `Modal.css:86`
- `AdminStudentModals.css:87`
- `RegisterStudentModal.css:26`
- `RegisterStudentModal.css:105`
- `AccessibilitySettings.css:27`
- `AccessibilitySettings.css:85`
- `AccessibilitySettings.css:105`
- `AccessibilitySettings.css:110`
- `AccessibilitySettings.css:155`
- `AccessibilitySettings.css:168`
- `AccessibilitySettings.css:193`

Replace `border-color: var(--color-focus-ring, #0284c7)` with `border-color: var(--color-focus-ring)` at `AdminStudentModals.css:140`.

Add `outline-offset: var(--focus-ring-offset, 2px)` wherever it is absent.

### Step 2 — Focus/primary family

Retire `--color-primary-500` / `-600` / `-700` entirely. The Field Journal has no blue primary.

All `-500` sites are focus outlines/borders and become `var(--color-focus-ring)`:

- `ForcedPasswordChangeGate.css:32, 71, 73, 136`
- `AdminStudentsPage.css:52` — a dead cascade-losing `.roster-item:focus-within` rule; the winning correct rule is at `:424`.
- `AdminStudentsPage.css:129`

Upgrade every accompanying hardcoded `outline: 2px` to the 3px/2px focus-ring tokens.

`-600` (button fill and link text) becomes `var(--color-brass-600)` (`#866843`):

- `RegisterStudentModal.css:91` (button fill)
- `ForcedPasswordChangeGate.css:123` (link text)
- `AdminStudentsPage.css:129, 138` (link text)

`-700` (hover) becomes `var(--color-brass-700)` (`#7c6136`):

- `RegisterStudentModal.css:101`
- `ForcedPasswordChangeGate.css:132`

### Step 3 — Ink family

Retire `--color-ink-400` / `-500` / `-600`, replacing all with `var(--color-ink-700)` (`#504940`) at:

- `ForcedPasswordChangeGate.css:78, 88, 117, 141, 146`
- `CourseWorkspace.css:5, 8`
- `AdminStudentsPage.css:28, 68, 176, 215, 313, 341, 348, 362`

Do not invent lighter ink steps. Disabled states keep the existing `opacity: 0.5` pattern from `src/App.css:571`.

### Step 4 — Size/type drift

- `--font-size-label` (`CourseWorkspace.css:1`) becomes `var(--font-size-caption)` (`.8125rem`).
- `--font-size-h4` (`LearnDetailPage.css:141`) becomes `var(--font-size-header-subtitle)` (`1.125rem`, byte-identical value, confirmed).
- `--size-helper-row` (`OwnerDashboardPage.css:12, 15`) becomes `var(--size-helper-row-height)` (`1.5rem`).
- `--content-max` (`FeedbackPage.css:2`, `RoadmapPage.css:2`) becomes `var(--size-content-max)` (`75rem`, identical value, zero visual change).

Do not conflate `--font-size-label` with the separate, correctly-defined `--font-weight-label` (`700`) — these are different tokens.

No action is required for `--measure` (see §3 corrections).

### Step 5 — Surface family

Retire `--color-surface-white` / `-50` / `-100` / `-200` / `-300`, mapping to the existing semantic tier at `src/App.css:44-48`:

- `-white` becomes `var(--color-surface-interactive-default)` (paper-100).
- `-50` and `-100` become `var(--color-surface-chrome-default)` (paper-200).
- `-200` / `-300` (border-only uses) become `var(--border-color-default)` at `var(--border-width-hairline)`.

### Step 6 — Status families (largest block)

First, add these new component tokens, built only from ratified primitives with no new hex values:

- `--color-status-error-text` = `var(--color-terracotta-600)`
- `--color-status-error-border` = `var(--color-terracotta-600)`
- `--color-status-warning-text` = `var(--color-brass-700)`
- `--color-status-warning-border` = `var(--color-brass-600)`
- `--color-status-success-text` = `var(--color-ink-moss)`
- `--color-status-success-border` = `var(--color-ink-moss)`
- `--color-status-neutral-text` = `var(--color-ink-700)`
- `--color-status-neutral-border` = `var(--color-ink-700)`
- `--color-roadmap-completed` = `var(--color-ink-moss)`
- `--color-roadmap-current` = `var(--color-brass-500)`
- `--color-roadmap-locked` = `var(--color-ink-700)`

Then remap 30+ undefined status properties **by role, not by name**:

**Solid button fill:**

- `--color-error-600` becomes terracotta-600 at `AdminStudentModals.css:178, 189` and `AdminStudentsPage.css:230, 241`.
- `--color-warning-600` / `-700` become brass-600/brass-700 at `AdminStudentsPage.css:253, 264`.

**Tinted backgrounds** (`-50`/`-100`/`-200` steps, plus `--color-brass-50`, `--color-terracotta-50`, `--color-info-50`): **retire the tint entirely** — no tinted surface is ratified in the design system. Background becomes `var(--color-surface-chrome-default)` (paper-200); hue is carried by the border/rule only. Sites:

- `AdminStudentsPage.css:8, 84, 90, 105, 112, 118, 163, 395, 407`
- `AdminStudentModals.css:14, 55, 66`
- `ForcedPasswordChangeGate.css:94-95, 162-163`
- `RegisterStudentModal.css:32, 117`
- `LessonContentView.css:68, 73, 78, 83`

**Panel text on those now-paper-200 panels:** error text must drop to `var(--color-ink-900)` because terracotta-600 fails AA on paper-200 (4.05:1, see §9) — the terracotta hue stays on the border/rule only. Success (moss) and warning (brass-700) both clear paper-200 and keep their hue. Sites: `ForcedPasswordChangeGate.css:97, 169`; `AdminStudentsPage.css:396, 408`.

**Border-only:** maps to the matching `--color-status-*-border`. Sites: `AdminStudentsPage.css:9, 83, 89, 104, 111, 117, 163`; `AdminStudentModals.css:15`; `ForcedPasswordChangeGate.css:83`; `RegisterStudentModal.css:33`.

**Plain text, no panel (paper-50):** maps directly to `--color-status-*-text`. Sites: `BandRoadmap.css:16, 21`; `OwnerDashboardPage.css:21, 22`.

**Separate `--color-state-*` family:** maps to the same `--color-status-*` tokens under the same border-vs-text role rules. Sites: `LessonContentView.css:72, 77, 127, 176`; `ResourcesPanel.css:107`; `FeedbackPage.css:7`; `RoadmapPage.css:7`; `OwnerSettingsPage.css:20, 22, 50, 104, 111`; `WeekDetailPage.css:29, 73`.

**Labeled design decision (not DS-sourced):** `--color-state-info` (`LessonContentView.css:77`, translation chunks only) retires to `--color-status-neutral-*` (ink-700), because ink-slate already carries two meanings (focus ring; Advanced band per `ADOPTION-PLAN.md:50`) and a third meaning would overload it.

**`--color-ink-300` / `--color-ink-50`** at `AdminStudentsPage.css:95-96`, `.status-preserved`: `-300` (border) becomes `--color-status-neutral-border`; `-50` (background) becomes `--color-surface-chrome-default`. Line 97's text is already a real token; leave it unchanged.

**`.status-badge.status-confirmed` / `.status-unconfirmed`** at `AdminStudentsPage.css:390-412`: background becomes paper-200; text becomes `--color-status-success-text` / `--color-status-warning-text` respectively.

**Raw hex A.6 violation:** `.status-pill.published{color:#226b45}` in `CourseWorkspace.css` becomes `var(--color-ink-moss)`.

### Step 7 — Criterion (c): border-radius

Rule: the Field Journal is a zero-radius system. `var(--radius-square)` (`0px`) is the only permitted value, including for `50%` and `999px` declarations.

- Fix the undefined-property typo at `src/App.css:495`: `var(--border-radius-square)` becomes `var(--radius-square)`.
- **Delete** (do not merely remap) the redundant local declaration at 6 sites confirmed superseded by `src/App.css`'s override blocks at `:690` and `:748-762`, because a static source scan trips on the literal regardless of which same-specificity rule wins at runtime: `WeekCard.css:5`, `LessonContentView.css:29, 59, 120`, `Modal.css:26`, `AdminStudentsPage.css:76`.
- **Direct remap** at `AdminStudentsPage.css:390, 402`, which are compound selectors `(0,0,2,0)` that genuinely outrank the bare `.status-badge` override `(0,0,1,0)` — verified by the design reviewer.
- **Direct remap** everywhere else: `AdminStudentModals.css:17, 57, 68, 81, 128, 182`; `ForcedPasswordChangeGate.css:64, 96, 164`; `RegisterStudentModal.css:21, 61, 74, 94`; `Modal.css:77`; `ResourcesPanel.css:15, 58, 87`; `LessonContentView.css:155`; `WeekDetailPage.css:36, 43, 55, 89`; `OwnerSettingsPage.css:41, 68, 81`; `AdminStudentsPage.css:27, 40, 148, 175, 189, 234, 257, 276, 298, 370, 397, 409`; `WeekCard.css:80, 118`; `FlashcardsViewer.css:28, 54, 87`; `AccessibilitySettings.css:8, 60, 72, 92, 147, 178`; `App.css:338, 398, 455, 559, 585, 600`.

### Step 8 — Criterion (d): box-shadow

There are exactly three non-zero-blur declarations app-wide, independently confirmed exhaustive across inset/multi-value/rgba forms with no `drop-shadow` anywhere in `src/`:

- `Modal.css:27` (`0 4px 12px rgba(0,0,0,0.15)`) becomes `var(--shadow-sheet)`.
- `AccessibilitySettings.css:76` and `:96` (`0 2px 4px rgba(0,0,0,0.2)`, both range-slider-thumb pseudo-elements) become `var(--shadow-brass)`.

### Step 9 — icons.tsx and fallback strip

`currentColor` inheritance is sufficient for the three glyphs in `src/components/icons.tsx` (`stroke=currentColor`, `fill=none`, `aria-hidden`, always paired with visible text), **conditional on every consumer's color resolving through a real token**. The one failing consumer is `WeekCard.css:32-47`, which is fixed by the roadmap tokens added in step 6.

Then strip every inline `, #hex` fallback clause project-wide (19+ files affected), with the single documented exception retained at `src/App.css:41`.

## 8. Interfaces and data

No API, schema, or data-contract change. The only interface change is the token layer itself.

`src/tokens/field-workbook.generated.css` carries a "do not edit by hand" header and states it was manually transcribed on 2026-08-31 because Atelier MCP's project-root resolution was broken. Atelier remains disclosed-unavailable this session (see status header note above).

**Pre-authorized:** engineering may hand-transcribe the new `--color-status-*` / `--color-roadmap-*` tokens under the same disclosed-fallback precedent established by #31's amendment. It must extend the existing header disclosure rather than silently editing, and must not stop to re-ask the user.

**Permitted variation:** engineering may place the new component tokens either in `field-workbook.generated.css` or in a separate app-level semantic file mirroring `src/App.css`'s existing `--color-surface-*` pattern, provided resolved values match exactly and no raw hex reaches a consuming call site.

## 9. Acceptance and validation

- TDD discipline: the step 0 enforcement test is written first and must fail against current HEAD, then pass once steps 1–9 are complete.
- `tsc` runs clean.
- Full `vitest` suite is green, including the pre-existing `src/__tests__/fieldJournalTokens.test.ts` and `src/__tests__/typographyFourHands.test.ts`.
- Deterministic re-scan confirms zero remaining `#0284c7` and `#3b82f6` literals, and zero remaining references to `--color-primary-*`, `--color-ink-300/-400/-500/-600`, `--color-surface-*`, `--color-error-*`, `--color-success-*`, `--color-warning-*`, `--color-state-*`, `--font-size-label`, `--font-size-h4`, `--size-helper-row`, `--content-max`, `--border-radius-square`.
- Deterministic no-native-dialog scan (no `alert`/`confirm`/`prompt`/`window.*`/`beforeunload`) per §5.
- Network-blocked run still renders the correct palette, per #33's own acceptance criterion.
- Independent Verifier pass, then Browser Validator pass per §6.
- Deterministic failures always dominate judge opinion (see §10).

### Judge route

`PLAN_DUCK` eligible after this draft, per `docs/JUDGE-CONTRACT.md`.

- `CODE_REVIEW` recommended given the breadth of this change (14+ files, 80+ call sites).
- `VISUAL_REVIEW` recommended given the rendered palette change and the square-corner change.
- Deterministic failures always dominate judge opinion.
- Respect the standard call caps defined in `docs/JUDGE-CONTRACT.md`.

## 10. Risks and rollback

**HIGH — scope is far larger than issue #33's summary implies.** Roughly 30+ status properties across 12 files, 50+ border-radius sites across 14+ files, plus the focus and surface families. Mitigation: the step 0 test produces the authoritative work inventory; steps 1–9 are sequenced as separately committable units so a partial revert is possible.

**HIGH — deeper root cause that may outlive this issue.** `src/tokens/primitives.json:41-59` hardcodes Tailwind-derived `success.600 #16a34a`, `warning.600 #ca8a04`, `info.600 #0284c7`, aliased by `src/tokens/semantic.json:21-26`. `ADOPTION-PLAN.md` ratifies no success/warning/info/error primitives at all. Fixing only the CSS layer may let the same off-brand colors return through a different mechanism if `tokenSystem.ts` is a live runtime consumer of those files. This is **untraced**: engineering must trace it and report. If it is live, it needs the identical correction, or a tracked follow-up issue, before #33 can honestly claim to close #29.

**MEDIUM — visible affordance change.** Previously round/pill controls go hard-square: `AccessibilitySettings.css:8, 72, 92` (the circular "Aa" trigger and both slider thumbs) and `FlashcardsViewer.css:54`'s 999px pill. This is intended per the zero-radius rule with no ratified exception, but must be explicitly confirmed during browser validation, not silently absorbed.

**MEDIUM — contrast regressions per #29 item 4, as fallbacks become real colors.** Two hard constraints, both independently recomputed and confirmed by the design reviewer:

- brass-600 text/link is invalid on paper-200 (4.34:1) — use brass-700 (4.88:1) instead.
- terracotta-600 text is invalid on paper-200 (4.05:1) — use ink-900 with the hue carried on the border instead.

Confirmed-passing figures:

- brass-600/paper-50: 5.02:1
- brass-700/paper-50: 5.65:1
- terracotta-600/paper-50: 4.69:1
- terracotta-600/paper-100: 4.53:1
- ink-moss/paper-50: 7.42:1
- ink-700/paper-100: 8.35:1
- ink-700/paper-50: 8.64:1

Do **not** propagate terracotta-500 to new sites: it computes 2.97:1 on paper-50, failing even the 3:1 UI floor. This is a pre-existing shipped gap in `.demo-button.primary:hover`, out of scope to fix under this issue, but must not be spread to new locations.

**LOW — deletion assumption in step 7.** Deleting the 6 superseded border-radius declarations assumes the `App.css` override genuinely wins at runtime; the reviewer confirmed the selector/specificity match.

**Rollback for all of the above:** revert per-step commits. No data migration and no schema change are involved anywhere in this plan; nothing here is irreversible.

**Residual verification carried by the reviewer:**

- Cross-check each step-6 cited line against the design packet's table during implementation.
- `src/App.css:607` has a non-zero-blur `text-shadow` on a demo `.color-swatch`. This is outside #33's literal criterion (d) box-shadow scope. Do not fix it under this issue; record it as a candidate only if criterion (d) is ever broadened in a future issue.

## 11. Dependencies

- Issue #31 (foundations) — landed, browser-validated, design-reviewed PASS.
- Issue #32 (typography) — landed, browser-validated, design-reviewed PASS.
- Issue #33 closes issue #29 upon completion of this plan.

## 12. Assumptions and open decisions

- **User decision, 2026-08-31:** the user accepted the design packet as-is (option A) rather than running a third design round; the 11 residual sites became step 1 of this plan. This is recorded as a user-accepted design gate, not a design PASS (see §4).
- **Confirmed in scope** by the user and by the design contract: the expansion beyond the originally enumerated property list. This is the same defect class in the same files, and is exactly what #33's mandate demands.
- **Open, needs engineering to resolve or defer with a tracked issue:** destructive-button hover has no `--color-terracotta-700` primitive in the shipped ramp. A recommendation is recorded here, not a decision, because adding a new primitive is a palette decision outside design's authority in this plan: keep the fill at terracotta-600 and carry the hover affordance via the existing hard-shadow-lift micro-interaction (`transform: translate(-1px,-1px)`, `src/App.css:689`).
- **Open, engineering's call:** whether `AdminStudentsPage.css`'s page-local `button.caution` / `button.destructive` (lines 229-270) should be deleted as duplicates of the shipped `.demo-button.caution` (`src/App.css:554-568`) rather than independently retokenized.
- **Labeled design decision, not DS-sourced:** the `--color-state-info` retirement to neutral ink-700 (step 6).
- Status is never carried by color alone: border hue, text hue, and the pre-existing text labels all remain. The reviewer confirmed no new WCAG SC 1.4.1 risk from retiring the tinted backgrounds in step 6.

## 13. Required approvals

This plan is routed to engineering under the user's standing authorization recorded in "Approval basis" above, not a separate live per-plan approval. The design gate in §4 has already been resolved by the user (option A, 2026-08-31); it is a distinct decision from the standing-authorization inference and does not itself substitute for the routing basis recorded above. If the user revokes or narrows the standing authorization at any point, execution of any remaining ordered-work steps must stop until a further explicit instruction is obtained.

## 14. Engineering mode and downstream owner

**Engineering mode:** standard.

**Team authorization:** not applicable.

**Downstream owner:** `engineering-fleet`, per `docs/BUILD-CONTRACT.md` and `docs/JUDGE-CONTRACT.md` routing once this plan is approved.
