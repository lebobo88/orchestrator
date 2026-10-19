# Lizbeth Spanish — Issue #34: Field Journal Devices + C.9 Empty State

**Status: Drafted, routed to engineering under the user's standing authorization. This document has not itself been separately approved by the user; the user has granted standing authorization ("keep going until all the gh issues are finished") that the orchestrator applies to route this plan to engineering, per the Approval basis recorded below. Approval of this document authorizes only issue #34's scope; it does not authorize any of issues #35-#44.**

- Plan id: `lizbeth-spanish-issue34-journal-devices-empty-state`
- Date: 2026-09-01
- Issue: lizbeth_spanish GitHub issue #34
- Milestone: Field Journal Design System (#31-44)
- Depends on: shipped #31, #32, #33
- Engineering mode: standard
- Downstream owner: engineering-fleet (T1 first-line, escalate to T2 per `docs/BUILD-CONTRACT.md` gate rules)
- Team authorization: not applicable (nested Planner chain, not an agent team)

This plan grants no authority to begin implementation. It is a specification only. Explicit user approval, relayed by the orchestrator, is required before any T1/T2 engineering writer starts work.

---

## Approval basis

This plan was routed to engineering under the orchestrator's application of the user's standing authorization, not a user-verified per-plan approval. The record below is an orchestrator-applied inference, consistent with the Status line above, and follows the same provenance discipline the #31, #32, and #33 plans used.

- **Standing authorization quoted (verbatim, as relayed by the orchestrator):** "didn't i tell you to stop asking me for approval? i told you to keep going until all the gh issues are finished," reinforced by an explicit session goal, "don't stop until all the DS gh issues are implemented and browser validated."
- **Application:** The orchestrator applied this standing authorization to route this plan (issue #34 of `lebobo88/lizbeth-spanish`, the next issue in the dependency chain the user directed continuation through, after #31, #32, and #33) to engineering without a further live per-plan checkpoint.
- **Staleness cross-check:** The orchestrator independently fetched the live GitHub issue #34 body (via `gh issue view`) before dispatching Planner and relayed it directly into Planner's context as the grounding source, rather than having Planner re-fetch it separately. This fetch-and-relay satisfied this plan's own pre-flight staleness check as a single combined action, not as a separate later step. Section 3 of this plan records the specific points where the live issue body diverged from the actual repository state (e.g. the `SpotIllustration.tsx`/`IpNotice.tsx` already-exists corrections, the spot-asset filename correction) and where this plan's repository findings override the issue text; the plan is not stale.
- **Provenance label:** This basis reached Scribe entirely through the orchestrator's account of the session; Scribe has not independently observed the quoted user statements or the raw `gh issue view` output. It is recorded here as an orchestrator-applied inference under standing authorization, NOT as a Scribe-verified per-document user approval.
- **Design gate, distinguished from the standing-authorization inference above.** Unlike the #33 precedent's user-accepted "option A" gate, this plan's design route reached a genuine `DESIGN_REVIEW_RESULT: PASS` on its own terms. The design route was Standard (director, UX, visual, motion, reviewer). The first review cycle returned `NEEDS_REVISION` with two MAJOR findings (pre-fix DONE-stamp contrast figures; device 06 bundling structural and decorative declarations into one removable class, invalidating the removal test). Both were resolved in revision 2 (see Section 4), and the reviewer returned `DESIGN_REVIEW_RESULT: PASS` on the second cycle with no escalation and no user gate decision required. No special approval-gate language is needed for the design portion of this record.
- **Scope-narrowing decision carried into this approval record (D4).** The orchestrator reports that Planner found no week-completion user action anywhere in the current codebase: `week.state` is derived at fetch time from `enrollment.completed_at` (`src/lib/roadmap.ts:90-107`), not transitioned in-session, and the only real user-initiated completion event in the app is lesson-level (`src/pages/LearnDetailPage.tsx:212-215`). Planner deliberately scoped the Stamp device (device 04) as presentational only, with an `animate` prop and a fire-once `journal-stamp--animate` class contract (Section 6.4), and did not authorize building a new week-completion action, button, or backend surface. This is a bounded scope-narrowing decision made to keep the plan grounded in what the repository actually supports, not a rejected requirement, and is recorded in the plan's own non-goals (Section 2) and Section 11 as Decision D4.
- **Date:** 2026-09-01.

---

## 1. Outcome and audience

**Outcome.** Nine reusable, decorative "journal devices" (tape, staple, clip, stamp, tabs, index card, folio, deckle edge, dot matrix) plus the C.9 empty-state composition, implemented as React components and CSS utilities under a new `src/components/journal/` directory in `H:\CommandCenter\orchestrator\lizbeth_spanish`. `BandRoadmap`'s existing empty state becomes the first consumer of the C.9 composition.

**Audience.**
- The T1/T2 engineering writer who implements this plan and has no access to the underlying `DESIGN_HANDOFF` JSON — every load-bearing value the writer needs is transcribed in full below.
- The Verifier, who independently checks writer completion against this plan's acceptance criteria.
- The Browser Validator, who runs the nine browser journeys in Section 9.

This is the fourth issue in the 14-issue "Field Journal Design System" milestone (#31-44) and depends on #31, #32, and #33 having already shipped (token layer, lint, and prior Field Journal primitives).

---

## 2. Scope and non-goals

### In scope

- All nine devices, each as a reusable component or CSS utility class, using the exact class names, CSS declarations, and prop contracts transcribed in Section 6.
- Every device is `aria-hidden` **except** device 09 (Dot Matrix), which is applied directly to real, load-bearing text, and C.9's eyebrow/body text, which is always real accessible content.
- The removal test (Section 8.1) implemented as a real automated test wherever mechanically feasible, and as an explicit documented manual procedure only where automation genuinely cannot reach (state that explicitly per device — do not leave any part as an unstated assertion).
- The stamp entrance animation (`fj-stamp-done` / `fj-stamp-locked`) with the exact keyframes, timing, and the `journal-stamp--animate` fire-once class contract in Section 6.4 and 6.11.
- The C.9 empty state delivering all three required parts together (spot illustration, `.paper-stock--graph` ground, dashed rule) as one composition.
- `BandRoadmap.tsx:73-81` adopting `JournalEmptyState` with the exact instantiation in Section 6.12, without regressing `BandRoadmap.test.tsx:87-91`, `:93-102`, or `:98`.

### Explicit non-goals (do not build)

- No week-completion user action, button, backend surface, or new user flow. `week.state` is derived at fetch time (`src/lib/roadmap.ts:90-107`) from `enrollment.completed_at`; there is no in-session completion transition to wire. The only real user-initiated completion event in the app is lesson-level (`src/pages/LearnDetailPage.tsx:212-215`) and stays untouched. Stamp ships as a presentational component only (Decision D4).
- No "IN HAND" third stamp state. `Stamp.state` is exactly `'done' | 'locked'`.
- No generalized/shared dashed-rule utility. The dashed rule is defined once, locally scoped inside `.journal-empty-state` itself.
- No modification to `.paper-stock--graph` or `.paper-stock--ruled` (`src/App.css:120-125`).
- No functional change to `src/components/IpNotice.tsx` / `IpNotice.css` (Decision D5).
- No change to `SpotIllustration.tsx`'s existing contract — reuse it unmodified.
- No new design tokens.
- No re-litigation of #31/#32/#33's shipped token values.
- No re-opening of the disclosed Atelier MCP compiler gap (see Section 5 and Section 10).

---

## 3. Repository findings (with evidence paths)

These findings were established by the nested Researcher and by direct repository reads during planning. They override any conflicting statement in the live GitHub issue #34 body (see Section 12, Staleness).

1. **`src/components/journal/` does not exist.** This work creates the first subdirectory under `src/components/` (30 flat files there today).
2. **`src/components/SpotIllustration.tsx` already exists.** The issue body wrongly implies it needs creation. Confirmed contract: props `{ src: string; className?: string }`; renders `<img src={src} alt="" aria-hidden="true" className={['spot-illustration', className].filter(Boolean).join(' ')} />`. Its CSS lives in `src/App.css:623-629` (`max-width: 140px`), not in a component CSS file. Three call sites: `BandRoadmap.tsx:78`, `RoadmapPage.tsx:63`, `WeekDetailPage.tsx:215`. Four test files assert its rendered class list: `SpotIllustration.test.tsx`, `BandRoadmap.test.tsx:98`, `RoadmapPage.test.tsx:76`, `WeekDetailPage.test.tsx:193`. Preserve this contract exactly — do not modify `SpotIllustration.tsx`.
3. **`src/components/IpNotice.tsx` and `IpNotice.css` already exist.** The issue body implies creation; both are already lint-clean and token-only. `ADOPTION-PLAN.md` lists them in this row's file list with zero acceptance criteria and zero reference coverage. Planner decision D5: no functional change in scope.
4. **Spot asset naming.** The issue body's `assets/spot_01.png` / `spot_02.png` / `spot_03.png` do not exist and resolve to nothing. The real files are `src/assets/spot-illustrations/spot-01-agave-horizon.png`, `spot-02-compass-pocket-watch.png`, `spot-03-open-book.png`, ES-imported and passed as the `src` prop. `BandRoadmap.tsx:7` already imports `spotOpenBook from '../assets/spot-illustrations/spot-03-open-book.png'` — reuse this exact import for the `JournalEmptyState` adoption.
5. **`.paper-stock--graph` (`src/App.css:120-125`) is shipped and currently unconsumed.** C.9 is its first real consumer. It is `background-color: #faf8f4` with 18px-pitch `#e3dbcd` gradients — same pitch, colors, and ground as the reference's C.9 inline grid, differing only by a 1px phase. It is the correct reuse target; re-deriving the grid inline would duplicate it and fail the raw-hex lint.
6. **No dashed-rule utility exists anywhere in `src/`.** The single `/dashed/` hit, `src/components/LoginForm.css:10`, is a local hairline divider at a different width — not a utility, and must not be generalized.
7. **`src/components/BandRoadmap.tsx:73-81` already renders a C.9-shaped empty state** (`.band-roadmap-empty-state`, `SpotIllustration` + "No weeks published yet for this band.") whose copy matches the reference C.9 body verbatim (confirmed by direct read, transcribed above in Section — see the file excerpt read during planning). It is the natural first consumer. `.band-roadmap-empty-state` is live-consumed at `src/components/BandRoadmap.css:32-34` and `src/__tests__/e2e/neo-workbook-visual-smoke.spec.ts:56`.
8. **Build-breaking lint — `src/__tests__/tokenFallbackAuditLint.test.ts`** runs over every `src/**/*.css` (comments blanked first) with four checks:
   - (a) every `var(--x)` must resolve in `src/tokens/field-workbook.generated.css` or `src/App.css :root`;
   - (b) any raw hex outside `src/tokens/` fails, including inside `var()` fallbacks, with only two line-exact exemptions in `src/App.css` — **important negative:** the regex matches only `#`-prefixed literals, so `rgba()`/`hsla()` would pass while still being untokenized color, which is why the design mandates `color-mix()` instead of raw `rgba()`;
   - (c) any non-zero `border-radius` fails in every form;
   - (d) any `box-shadow` with non-zero blur fails, though a bare single `var(--shadow-<name>)` is trusted.
9. **`--shadow-card` (`5px 5px 0 0 #1a1512`) currently has zero consumers**; the index card is its first.
10. **Confirmed present tokens:** `--motion-duration-stamp: 260ms`; `--motion-easing-standard: cubic-bezier(0.2,0,0,1)`; `--radius-none`; `--radius-square`. Reduced motion is already implemented at `src/App.css:142-148`, collapsing `--motion-duration-stamp` to 1ms (deliberately 1ms, not 0ms, so a future `animationend` fire-once callback still fires). The stamp animation needs zero new motion code — it inherits the collapse via `var()`.
11. **A.5 easing resolved.** The reference applies `fj-stamp 260ms cubic-bezier(.2,0,0,1) both` (`DS.dc.html:848`); this matches `--motion-easing-standard` exactly. No new easing token is needed. The overshoot lives entirely in the keyframe scale sequence (1.9 → .94 → 1), not the curve. Rotation is a constant held across all keyframes; it does not animate.
12. **Reference structure.** `design/field-journal/Field Journal DS.dc.html` is a Claude Design canvas. §B (lines 205-319) draws all nine devices with inline styles and zero class names and zero custom properties. Every class name and component API in this work is new, defined by the design handoff — there was nothing to extract. The 190px demo swatch frames are canvas chrome, not part of the devices.
13. **Conventions to follow:** PascalCase.tsx with a named export plus a co-located sibling PascalCase.css imported by the component itself (no central CSS barrel; `src/main.tsx` imports no CSS). Tests live flat in `src/__tests__/`, never co-located.
14. **`ADOPTION-PLAN.md`'s ratified deviations (lines 96-114)** contain exactly two items, both in §A, neither touching §B or C.9, and line 99 states they are "not to be re-opened during implementation." No ratified deviation exists for these devices. (Confirmed by direct read: item 1 is the margin-hand 26px-vs-24px specimen call; item 2 is the WCAG-AA-vs-APCA gate for band-ink contrast. Both are unrelated to §B/C.9.)
15. `ADOPTION-PLAN.md:116-118` (§B header): "tape, staple, clip, stamps, tabs, index card, folio, deckle edge, dot matrix — all pure CSS/SVG, all decorative." This blanket framing is read by the design handoff (Decision D8, Section 11) as covering only the scanline flourish on device 09, not the underlying text's semantics.
16. `ADOPTION-PLAN.md:93-95` (accessibility rule 5): "Handwriting, tape, staples, stamps are decorative and `aria-hidden` — removing all of them must leave the screen fully usable." This is the ratified source for the removal-test requirement in Section 8.1.

---

## 4. Design route and reviewed handoff

`design_route: standard` (profile: standard; agents: design-director, ux-architect, visual-system-designer, motion-designer, design-reviewer; prototype: forbidden; model_tier: sonnet; existing_system_mode: extend). Reasons recorded by Planner: nine new reusable components plus a three-part empty-state composition plus a keyframe animation with reduced-motion behavior; this is the first subdirectory under `src/components/`; a multi-state component language; qualitatively different from #31-33's token plumbing.

**Design review result.** `DESIGN_REVIEW_RESULT` verdict **PASS** (independent design-reviewer, second cycle). The first cycle returned `NEEDS_REVISION` with two MAJOR findings:

1. DONE-stamp contrast figures were the pre-fix 88%-alpha-blended values, contradicting the shipped full-opacity spec.
2. Device 06 (index card) bundled structural declarations (width/padding) into the same removable class as decorative ones, invalidating the removal test — which is *the* acceptance test for §B.

Plus one MEDIUM finding (BandRoadmap copy-split regression risk) and one LOW finding (evidence-wording).

Revision 2 (transcribed in full in Section 6 below) closed all four:
- DONE restated at full opacity: 7.42:1 on paper-50, 6.41:1 on paper-200, independently recomputed as 7.42/6.45 within rounding.
- LOCKED figures re-verified unchanged (they were already full-opacity values).
- Devices 06 and 08 split into structural vs. decorative classes, with the audit extended across all nine devices and C.9.
- Removal test rewritten as concrete computed-style before/after assertions.
- Exact BandRoadmap prop contract specified.

The reviewer confirmed no silent regressions remained.

---

## 5. Judge route

`PLAN_DUCK` eligible per `docs/JUDGE-CONTRACT.md`: the orchestrator runs Codex plan judgment on this draft before requesting user approval; shadow findings are advisory only and do not block. `VISUAL_REVIEW` is a candidate checkpoint at the browser-validation stage, given the disclosed Atelier `visual_diff` gap (Section 10). Deterministic failures — `tsc`, `vitest`, and the token lint — always dominate any judge finding, per the standing contract; a judge finding never overrides a deterministic test failure.

---

## 6. Full transcribed design specification (DESIGN_HANDOFF revision 2)

This section is the authoritative, complete transcription of the reviewed `DESIGN_HANDOFF` (revision 2) for issue #34. The T1/T2 writer implements from this section; do not consult any other source for values that conflict with it, except where this plan explicitly defers to a live repository file (e.g., exact token names — verify against `src/tokens/field-workbook.generated.css` at implementation time).

### 6.0 Selected direction and framing

Field Journal decorative-device layer for issue #34: nine reusable, `aria-hidden` decorative components/utilities (tape, staple, clip, stamp, tabs, index card, folio, deckle edge, dot matrix) plus a C.9 empty-state composition, specified against the ratified `Field Journal DS.dc.html` §B/§C.9 geometry and made lint-clean/token-derived against `src/tokens/field-workbook.generated.css` and `src/__tests__/tokenFallbackAuditLint.test.ts`. No new creative direction is introduced; this extends the shipped, ratified Field Journal system (`existing_system_mode: extend`).

This is revision 2, closing four independent-review findings on the prior handoff:
1. Corrected DONE-stamp contrast figures (the prior figures were pre-fix 88%-opacity-blended values, not the shipped full-opacity values).
2. A structural-vs-decorative CSS split for devices 06 and 08 so the removal test is mechanically true rather than merely asserted.
3. An exact BandRoadmap prop contract that keeps the existing test's single-text-node assertion intact.
4. A reworded (not changed) rationale for the stamp ±8° rotation decision, plus a plain fidelity disclosure that device 09's scanline effect is inert as specified.

### 6.1 Directory and file layout

New directory: `src/components/journal/`.

Naming convention: devices that need props/state/dynamic content get their own `PascalCase.tsx` + co-located `PascalCase.css` (repo convention):
- `ClipRing.tsx` / `ClipRing.css` (device 03)
- `Stamp.tsx` / `Stamp.css` (device 04)
- `TabStack.tsx` / `TabStack.css` (device 05)
- `Folio.tsx` / `Folio.css` (device 07)
- `JournalEmptyState.tsx` / `JournalEmptyState.css` (C.9)

Devices with zero props/state (01, 02, 06, 08, 09) become pure CSS utility classes in one shared `journal-devices.css`, not owned by any single component — justified by existing repo precedent: `.paper-stock--graph` / `.paper-stock--ruled` (`src/App.css:120-125`) already ship as bare utility classes with no owning component.

Tests: any device with props/state gets a flat test file under `src/__tests__/` (`ClipRing`, `Stamp`, `TabStack`, `Folio`, `JournalEmptyState`). Pure-CSS utilities (01, 02, 06, 08, 09) are covered by the removal-test checklist (Section 8.1) plus visual review — write them as real automated tests wherever the DOM assertion is mechanically expressible (all of 01/02/06/08/09 are: see Section 8.1 per-device table), not merely "visual review."

### 6.2 Per-device DOM/props/state contract

**Device 01 — Tape.** Utility class `.journal-tape`. Consumer inserts one `<span aria-hidden="true" className="journal-tape" />`. No props. Self-contained wrapper node — never touches host structural properties.

**Device 02 — Staple.** Utility class `.journal-staple` (second bar via `::after`, one DOM node total). No props. Self-contained wrapper node.

**Device 03 — Clip.** `ClipRing({ className? })`. Renders `<svg aria-hidden="true" focusable="false" className={cx('journal-clip-ring', className)}>` with two concentric stroked paths (round linecap/linejoin), no `<title>`/`<desc>`, no id-based `<defs>`/`<use>` cross-references. Self-contained wrapper node, absolutely positioned, never touches host structural properties.

**Device 04 — Stamp.** `Stamp({ state, label, animate?, className? })` where `state: 'done' | 'locked'` (exactly two — `IN HAND` explicitly excluded), `label: string` is the literal display text decoupled from `state`. DOM:
```tsx
<span
  aria-hidden="true"
  className={cx('journal-stamp', 'journal-stamp--' + state, hasFiredAnimation && 'journal-stamp--animate')}
>
  {label}
</span>
```
Self-contained node inserted alongside (never replacing) real state text — carries its own duplicate text, never the host's layout.

**Device 05 — Tabs.** `TabStack({ tabs, className? })` where `tabs: [TabSpec, TabSpec, TabSpec]`, `TabSpec = { label: string; selected: boolean }`. DOM:
```tsx
<div aria-hidden="true" className="journal-tab-stack">
  {/* three: */}
  <span className={cx('journal-tab', tab.selected && 'journal-tab--selected')}>{tab.label}</span>
</div>
```
No standalone `JournalTab` export. Self-contained, independently positioned decorative rail; real band navigation lives elsewhere in the DOM with its own layout.

**Device 06 — Index card (structural/decorative split — closes review Finding 2).** Applied directly to the consumer's real card element via **two** classes, not one:
- `.journal-index-card-frame` (structural, host-required, **excluded** from the removal test): `width: 200px; padding: 14px; overflow: hidden;`
- `.journal-index-card-trim` (decorative, removal-test subject): border, box-shadow, `::before` header bar, ruled-body background-image (full declarations in Section 6.6).

Both classes are applied together in normal use: `className="journal-index-card-frame journal-index-card-trim"`. Only `-trim` is a candidate for the removal-test claim. `Field Journal DS.dc.html:283` frames the 200px bordered/padded object as "the same object in two places" — its dimensions are part of its identity, which is why they cannot live in the same removable class as its ornament.

**Device 07 — Folio.** `Folio({ bandLabel, weekNumber, className? })`. Formatting rule: zero-pad `weekNumber` to 2 digits, wrap as `— NN —`. DOM:
```tsx
<div aria-hidden="true" className="journal-folio">
  <div className="journal-folio__row">
    <span className="journal-folio__band">{bandLabel}</span>
    <span className="journal-folio__week">{formattedWeek}</span>
  </div>
</div>
```
The rule is `border-top` on the container itself (no extra node). Two-child `space-between` structure, kept as-is (see Decision, Section 11, Folio centering). Self-contained node instantiated with its own content, not a utility layered onto pre-existing host markup — no structural coupling risk.

**Device 08 — Deckle edge (structural/decorative split, same category as 06 — closes review Finding 2's extension).** Two classes:
- `.journal-deckle-host` (structural marker, **excluded** from removal test): carries zero width/height/background declarations — the real scrolling content block supplies its own sizing exactly as it already does today.
- `.journal-deckle-edge` (decorative, removal-test subject): the sawtooth `mask`/`-webkit-mask` bottom-edge cut, plus the framing border needed to visually read as a torn card edge — border is decorative framing, not host sizing, so it stays in the removable class.

The reference's isolated demo-swatch dimensions (210×120px, `background: var(--color-paper-50)`) are **explicitly not** carried into implementation — that was an artifact of the demo card, not a device requirement; forcing fixed dimensions/background onto arbitrary "existing scrolling content" (Deckle's own stated purpose, `DS.dc.html:304`) would have been a layout/paint regression on removal, the same failure class Finding 2 named for device 06.

The class must carry this mandatory header comment banner in `journal-devices.css`:
```
/* journal-deckle-edge: page-level utility. Use at most once per screen.
   Belongs on scrolling content, never on cards. */
```
This is a documented convention, not lint-enforced (open item, Section 10).

**Device 09 — Dot matrix (real-text asymmetry made explicit — closes review Finding 2's device-09 extension).** Utility classes `.journal-dot-matrix` / `.journal-dot-matrix--secondary`, applied directly by the consumer to real, visible, **non**-`aria-hidden` text elements, e.g.:
```tsx
<h2 className="journal-dot-matrix">WEEK 03 · UNLOCKED</h2>
```
Resolution: dot matrix is a CSS presentational utility on real, load-bearing text, not a separately-inserted decorative device — no `<DotMatrixLabel>` wrapper exists. Rationale: the reference applies the scanline treatment to actual content, and hiding real content from assistive technology to satisfy the blanket "all nine devices are decorative" framing (`ADOPTION-PLAN.md:117-118`) would itself be a WCAG regression (Decision D8, Section 11).

Removal semantics are structurally **different** from devices 01-08 and must be tested/documented accordingly: there is no wrapper node for device 09 — "removal" means stripping the `.journal-dot-matrix` class attribute from the real text element, leaving its tag, real text content, and ARIA/semantic attributes byte-identical, with the text falling back to the surrounding component's default typography. This remains fully removal-test-compliant (the text was never dependent on the class for existence or meaning) but is a different operation than 01-08's node deletion.

**C.9 — JournalEmptyState (prop contract, closes review Finding 3).**
```ts
JournalEmptyState({
  illustrationSrc: string;
  eyebrow?: string;
  bodyText: string;
  className?: string;
})
```
`eyebrow` is optional — renders its own `<p className="journal-empty-state__eyebrow">` only when provided. `bodyText` always renders its own `<p className="journal-empty-state__body">`, always a single, complete text node. DOM:
```tsx
<div className={cx('journal-empty-state', 'paper-stock--graph', className)}>
  <SpotIllustration src={illustrationSrc} />
  {eyebrow && <p className="journal-empty-state__eyebrow">{eyebrow}</p>}
  <p className="journal-empty-state__body">{bodyText}</p>
</div>
```
(dashed-rule border defined once, locally scoped inside `.journal-empty-state` itself). Eyebrow/body are real, visible, accessible text — not `aria-hidden`. All three parts (illustration, graph ground, dashed rule) are structurally required together per `ADOPTION-PLAN.md:288-290` — a distinct "all three or fail" acceptance test, separate from the nine-device removal test (see Section 8.2). `.band-roadmap-empty-state` (the existing host wrapper, `BandRoadmap.tsx:74`, `BandRoadmap.css:32-34`, `text-align: center` only) remains unchanged and is always structural — not part of this device's removability claim.

### 6.3 BandRoadmap instantiation (exact, closes review Finding 3)

Replace the current inner JSX at `BandRoadmap.tsx:73-81` (the `SpotIllustration` + `<p>` block) with:
```tsx
<JournalEmptyState
  illustrationSrc={spotOpenBook}
  bodyText="No weeks published yet for this band."
/>
```
Leave the outer element and `band-roadmap-empty-state` className, and the surrounding `{status === 'ready' && weeks.length === 0 && (...)}` conditional, untouched. `eyebrow` is omitted for this consumer — inventing placeholder eyebrow copy would fabricate unjustified content and risks `getByText(/no weeks published yet/i)` matching more than one text node. `illustrationSrc={spotOpenBook}` continues to satisfy the existing `img.spot-illustration` / `alt=""` / `aria-hidden="true"` assertions unchanged (reuse the existing import at `BandRoadmap.tsx:7`, do not add a new import).

### 6.4 Motion specification — Stamp entrance (device 04)

Scope: motion. Component: `Stamp` (`journal-stamp`), device 04 of 9.

Purpose: fire-once entrance emphasis for a Stamp rendered in a "settled" state (done/locked) at initial mount. No other of the nine decorative devices carry motion in this scope.

Trigger: component mount only, when the `animate` prop is true at mount time. Fires at most once per mounted component instance; replay only via a React `key` change forcing a fresh mount.

Property animated: `transform` (rotate held constant per state, scale animates 1.9 → .94 → 1) and `opacity` (0 → 1). No color/layout/`::before`-layer property animates.

Duration: `var(--motion-duration-stamp)` (260ms; collapses to 1ms under reduced motion, `src/App.css:142-148`). Never a literal value.

Easing: `var(--motion-easing-standard)` (`cubic-bezier(0.2, 0, 0, 1)`). Never a literal value.

Orchestration: single-element, single-pass; no delay; iteration count 1; `animation-fill-mode: both`.

Interruption behavior: not interruptible (`aria-hidden`, non-interactive); unmount mid-animation is simply discarded with the DOM node.

Performance constraints: only `transform`/`opacity` animated — compositor-only, no layout/paint cost.

Reduced motion: zero new code required. The existing `--motion-duration-stamp` → 1ms collapse applies automatically via `var()`; `animation-fill-mode: both` guarantees no post-animation revert/flash.

**Keyframes (exact):**
```css
@keyframes fj-stamp-done {
  0%   { transform: rotate(-8deg) scale(1.9); opacity: 0; }
  55%  { transform: rotate(-8deg) scale(.94); opacity: 1; }
  100% { transform: rotate(-8deg) scale(1); opacity: 1; }
}
@keyframes fj-stamp-locked {
  0%   { transform: rotate(8deg) scale(1.9); opacity: 0; }
  55%  { transform: rotate(8deg) scale(.94); opacity: 1; }
  100% { transform: rotate(8deg) scale(1); opacity: 1; }
}
```

**Animation declaration (exact):**
```css
.journal-stamp--done.journal-stamp--animate {
  animation-name: fj-stamp-done;
  animation-duration: var(--motion-duration-stamp);
  animation-timing-function: var(--motion-easing-standard);
  animation-iteration-count: 1;
  animation-delay: 0s;
  animation-fill-mode: both;
}
.journal-stamp--locked.journal-stamp--animate {
  animation-name: fj-stamp-locked;
  animation-duration: var(--motion-duration-stamp);
  animation-timing-function: var(--motion-easing-standard);
  animation-iteration-count: 1;
  animation-delay: 0s;
  animation-fill-mode: both;
}
```

Scoping to fire-once: the literal class token the animate-once prop logic must emit is `journal-stamp--animate`; base `.journal-stamp` rules carry zero animation properties.

Lint cleanliness: no new raw hex/border-radius/box-shadow; both `var()` references are existing tokens.

Dialog involvement: none.

Fire-once observability note: 1ms (not 0ms under reduced motion) guarantees `animationend` still fires for a future fire-once listener even under reduced motion.

Not in scope: motion for the other eight Field Journal decorative devices.

### 6.5 Color and contrast — raw-hex-to-token map

Verified against `src/tokens/field-workbook.generated.css`. Every raw hex value below is a citation of the reference's inline styling, mapped to its already-shipped token — the implementation must use the token, never the raw hex:

| Reference raw value | Token |
|---|---|
| `#faf8f4` | `--color-paper-100` |
| `#2a2420` | `--color-ink-900` |
| `#3d3530` | `--color-ink-800` |
| Tape border `rgb(124,97,54)` = `#7C6136` | `--color-brass-700` (not ink-700) |
| `#1a1512` | `--color-ink-1000` |
| Clip/staple `#504940` | `--color-ink-700` |
| Stamp DONE `#2f5d3f` | `--color-ink-moss` |
| Stamp LOCKED `#a85e4a` | `--color-terracotta-600` |
| Tabs selected bg `#866843` | `--color-brass-600` |
| Tabs selected label `#fdfcf9` | `--color-paper-50` |
| Tabs unselected bg `#f0ebe2` | `--color-paper-200` |
| Index card bg `#fdfcf9` | `--color-paper-50` |
| Index card header `#d97a5c` | `--color-terracotta-500` |
| Folio rule/row | `--color-ink-1000` / `--color-ink-700` |
| Deckle border | `--color-ink-1000` |
| Dot-matrix primary | `--color-ink-1000` |
| Dot-matrix secondary | `--color-brass-700` |
| Dot-matrix secondary rule `#e3dbcd` | `--color-paper-300` |
| C.9 border | `--color-ink-700` |
| C.9 eyebrow | `--color-brass-700` |
| C.9 body | `--color-ink-900` |

**`color-mix()` replacements (Planner resolution 3, all three confirmed exact hex-to-token matches — resolves raw `rgba()` literals that would silently pass the hex-only lint regex, per Section 3 finding 8b):**

1. Tape fill `rgba(255,214,153,.82)` = `#FFD699` = `--color-amber-200` →
   ```css
   background: color-mix(in srgb, var(--color-amber-200) 82%, transparent);
   ```
2. Tape border `rgba(124,97,54,.5)` = `#7C6136` = `--color-brass-700` →
   ```css
   border-color: color-mix(in srgb, var(--color-brass-700) 50%, transparent);
   ```
3. Dot-matrix scanline `rgba(253,252,249,.55)` = `#FDFCF9` = `--color-paper-50` →
   ```css
   color-mix(in srgb, var(--color-paper-50) 55%, transparent)
   ```

Browser-support caveat: `color-mix()` support is Chrome/Edge 111+, Firefox 113+, Safari 16.4+. Declare a solid `var(--token)` fallback declaration immediately before each `color-mix()` declaration (standard CSS cascade fallback — a browser that does not understand `color-mix()` ignores that declaration and keeps the prior one).

### 6.6 Contrast figures (tool-verified via `mcp__atelier__contrast_check`, this revision)

**DONE stamp (ink-moss `#2f5d3f`) at full opacity** (opacity is never applied to text/border paint):

| Background | Ratio | WCAG 4.5:1 |
|---|---|---|
| paper-50 (`#fdfcf9`) | **7.42:1** | PASS (wide margin) |
| paper-200 (`#f0ebe2`) | **6.41:1** | PASS (wide margin) |

Correction note (preserved for audit trail): the prior handoff revision cited 5.49:1/4.89:1 for DONE and labeled them "tool-verified full-opacity" values. Those numbers were in fact the pre-fix 88%-opacity-blended values (the ones produced if `opacity: .88` were still applied to the text/border paint) — not the actual full-opacity values that the shipped CSS (opacity removed from text/border) produces. This was never a live accessibility failure — the true contrast is higher, not lower — but the prior "tool-verified" label was inaccurate as written. Corrected and re-verified in this revision.

**LOCKED stamp (terracotta-600 `#a85e4a`) at full opacity** — re-verified this revision, confirmed unchanged from the prior packet (these were already full-opacity values, not blended):

| Background | Ratio | WCAG 4.5:1 |
|---|---|---|
| paper-50 (`#fdfcf9`) | 4.69:1 | PASS (thin margin) |
| paper-100 (`#faf8f4`) | 4.54:1 | PASS (thin margin) |
| paper-200 (`#f0ebe2`) | 4.05:1 | **FAIL** |

**Ruling (unchanged):** LOCKED Stamp permitted surfaces remain paper-50 and paper-100 only; paper-200 is confirmed unusable (`.paper-stock--card`, `src/App.css:127-129`, is byte-exact paper-200 and a real, common, in-use surface).

**Enforcement mechanism (ships as-is, doc-comment only — see Section 10, unresolved item 1 for the compiler-gate gap):**
```
/**
 * Stamp — decorative device, aria-hidden="true".
 *
 * ENFORCEMENT — `variant="locked"` (border-color/color: var(--color-terracotta-600)):
 * MUST NOT be placed on a paper-200 surface (e.g. `.paper-stock--card`,
 * src/App.css:127-129). WCAG 1.4.3 fails there: 4.05:1, tool-verified
 * (mcp__atelier__contrast_check) below the 4.5:1 normal-text minimum.
 * Permitted surfaces: paper-50 (4.69:1) and paper-100 (4.54:1) only —
 * both pass at a thin margin; do not stack additional translucent
 * overlays on top of a locked Stamp on paper-100.
 *
 * Do not restore opacity to the text/border paint of this variant.
 * Opacity must stay isolated to the decorative ::before layer only —
 * reapplying it to text/border reproduces the .88-opacity failure
 * this component was fixed for (3.77:1 / 3.34:1, both fail).
 */
```

**Tabs contrast (unchanged):** selected 5.02:1 PASS; unselected 10.10:1 PASS.

**Dot-matrix primary line:** rendered contrast is plain ink-1000-on-paper, 17.65:1 paper-50 / 15.25:1 paper-200 — both PASS with a large margin. Note: per the fidelity disclosure (Section 6.9), the scanline background-image has zero visible effect as specified, so this contrast figure describes the text as it will actually render (plain opaque monospace), not a hypothetical.

**C.9 eyebrow/body (unchanged):** dominant background 5.46:1 (eyebrow) / 14.44:1 (body), both PASS; worst-case grid-line intersection 4.22:1 (eyebrow, marginal FAIL against 4.5:1) / 11.15:1 (body, PASS) — still an open judgment call, not adjudicated (no defined WCAG methodology for patterned backgrounds). Record this as an open non-blocking item (Section 10, unresolved item 2).

Tool-verification record: `mcp__atelier__contrast_check` calls this revision — `#2f5d3f` on `#fdfcf9` → 7.42:1; `#2f5d3f` on `#f0ebe2` → 6.41:1; `#a85e4a` on `#fdfcf9` → 4.69:1; `#a85e4a` on `#faf8f4` → 4.54:1; `#a85e4a` on `#f0ebe2` → 4.05:1. Five calls, consistent with the disclosed Atelier substitution policy in Section 10.

### 6.7 Typography

Unchanged from prior revision. IBM Plex Mono via literal `font-family: "IBM Plex Mono", ui-monospace, monospace;` (no `--font-family-mono` token exists — flagged gap, Section 10 unresolved item 4).

- Stamp: 15px / 700 / `.22em` tracking
- Tabs: 11px / 700, `vertical-rl`
- Folio row: 12px / `.2em` tracking
- Dot matrix primary: 15px / 700 / `.3em` tracking
- Dot matrix secondary: 11px / `.24em` tracking
- C.9 eyebrow: 12px / 600 / `.18em` tracking / uppercase
- C.9 body: 17px / `var(--font-line-height-body)` / `var(--font-family-body)` / `34ch` max-width

### 6.8 Layout and geometry (exact declarations, revised for the 06/08 split)

**01 Tape:**
```css
.journal-tape {
  position: absolute;
  top: 20px;
  left: 50%;
  transform: translateX(-50%) rotate(-2.5deg);
  width: 128px;
  height: 30px;
  background: color-mix(in srgb, var(--color-amber-200) 82%, transparent);
  border: 1px solid color-mix(in srgb, var(--color-brass-700) 50%, transparent);
}
```
(Border width and any other declaration not specified numerically above should use the nearest matching existing border-width token consistent with the reference's thin tape-edge line; confirm against reference geometry at implementation time — this is the only geometry value in Section 6.8 without an exact reference pixel citation, flag if ambiguous.)

**02 Staple:**
```css
.journal-staple {
  position: absolute;
  top: 40px;
  left: 40px;
  transform: rotate(-32deg);
  width: 26px;
  height: 5px;
  background: var(--color-ink-700);
}
.journal-staple::after {
  content: '';
  position: absolute;
  top: 12px;
  left: 2px;
  width: 26px;
  height: 5px;
  transform: rotate(-32deg);
  background: var(--color-ink-700);
}
```
(`top`/`left` on `::after` are relative to `.journal-staple` itself, i.e. `.journal-staple` must be `position: relative` or otherwise establish the containing block for `::after`'s `position: absolute`.)

**03 Clip:** overall SVG box 26×62. Two concentric stroked paths, round linecap/linejoin, `stroke: var(--color-ink-700)`, no fill, no `border-radius` (SVG stroke geometry, not CSS border-radius — satisfies Decision D1, Section 11). `stroke` must be set via CSS property, never an inline SVG attribute (engineering invariant, Section 6.13).

**04 Stamp:**
```css
.journal-stamp {
  border-width: var(--border-width-rule);
  padding: var(--space-2) 14px;
  font-family: "IBM Plex Mono", ui-monospace, monospace;
  font-size: 15px;
  font-weight: 700;
  letter-spacing: .22em;
}
.journal-stamp--done {
  transform: rotate(-8deg);
  color: var(--color-ink-moss);
  border-color: var(--color-ink-moss);
}
.journal-stamp--locked {
  transform: rotate(8deg);
  color: var(--color-terracotta-600);
  border-color: var(--color-terracotta-600);
}
```
(Border-style, e.g. `solid`, is implied by the reference and required for `border-width`/`border-color` to render; use `border-style: solid`.)

**05 Tabs:**
```css
.journal-tab-stack { /* container, positions the three tabs at the pitch below */ }
.journal-tab {
  position: absolute;
  width: 34px;
  min-height: 46px; /* was a fixed 46px height in the reference; changed to min-height, see bilingual mitigation Section 6.10 */
  border-width: var(--border-width-strong);
  border-right: 0;
  writing-mode: vertical-rl;
  font-size: 11px;
  font-weight: 700;
  background: var(--color-paper-200);
}
/* three tabs positioned at top: 18px / 70px / 122px (52px pitch) */
.journal-tab--selected {
  background: var(--color-brass-600);
  color: var(--color-paper-50);
}
```

**06 Index card (split — exact declarations):**
```css
.journal-index-card-frame {
  /* structural — excluded from removal test */
  width: 200px;
  padding: 14px;
  overflow: hidden;
}
.journal-index-card-trim {
  /* decorative — removal-test subject */
  border: var(--border-width-rule) solid var(--color-ink-1000);
  box-shadow: var(--shadow-card);
}
.journal-index-card-trim::before {
  content: '';
  display: block;
  height: 5px;
  background: var(--color-terracotta-500);
}
.journal-index-card-trim {
  background-image: repeating-linear-gradient(
    to bottom,
    transparent 0 21px,
    var(--color-paper-300) 21px 22px
  );
}
```
(The ruled-body stripe color is an assumption: `var(--color-paper-300)`, not independently confirmed against a second source — see Section 10 unresolved item 5. The 22px pitch is distinct from `.paper-stock--ruled`'s 31/32px pitch and does not modify it.)

**07 Folio:**
```css
.journal-folio {
  width: 220px;
  border-top: var(--border-width-strong) solid var(--color-ink-1000);
  margin-bottom: 10px;
}
.journal-folio__row {
  display: flex;
  justify-content: space-between;
  align-items: flex-start; /* assumption, not independently confirmed — Section 10 unresolved item 5 */
}
.journal-folio__band,
.journal-folio__week {
  font-size: 12px;
  letter-spacing: .2em;
  color: var(--color-ink-700);
}
```

**08 Deckle (split — exact declarations):**
```css
.journal-deckle-host {
  /* structural marker only — zero width/height/background declarations.
     The host's own scrolling content supplies its own sizing. */
}
.journal-deckle-edge {
  border: var(--border-width-rule) solid var(--color-ink-1000);
  border-bottom: 0;
  mask: conic-gradient(from -45deg at bottom, transparent, black 1deg 89deg, transparent 90deg) 50% / 16px 100%;
  -webkit-mask: conic-gradient(from -45deg at bottom, transparent, black 1deg 89deg, transparent 90deg) 50% / 16px 100%;
}
```
The reference's 210×120px / `background: var(--color-paper-50)` demo-swatch dimensions are explicitly not implemented (see Section 6.2, device 08 rationale).

**C.9 empty state:**
```css
.journal-empty-state {
  padding: 32px;
  text-align: center;
  border: 1px dashed var(--color-ink-700); /* dashed rule, defined once, locally scoped here */
}
.journal-empty-state__eyebrow {
  font-size: 12px;
  font-weight: 600;
  letter-spacing: .18em;
  text-transform: uppercase;
  color: var(--color-brass-700);
}
.journal-empty-state__body {
  font-size: 17px;
  line-height: var(--font-line-height-body);
  font-family: var(--font-family-body);
  max-width: 34ch;
  color: var(--color-ink-900);
}
```
SpotIllustration is kept at its shipped 140px `max-width` (Decision D9, Section 11) — do not modify `SpotIllustration.tsx` or its CSS.

### 6.9 Forced-colors mode (per device family, revised class names for the 06/08 split)

Baseline mechanism: under `forced-colors: active` with default `forced-color-adjust: auto`, the user agent overrides `color`/`background-color`/`border-*-color`/`outline-color`/SVG `fill`/`stroke` to system colors. It does not cover `background-image`/`box-shadow`/`text-shadow`.

| Device | Technique | Verdict |
|---|---|---|
| 01 Tape | background-color + color-mix fill/border | no defensive CSS needed |
| 02 Staple | background-color bars | no defensive CSS needed |
| 03 Clip | SVG stroke, no fill | no defensive CSS needed, contingent on stroke set via CSS property |
| 04 Stamp | border-color + color, aria-hidden | no defensive CSS needed |
| 05 Tabs | background-color + border-color + color, aria-hidden | no defensive CSS needed |
| 06a `.journal-index-card-frame` | sizing only, no color | no defensive CSS needed (nothing to remap) |
| 06b `.journal-index-card-trim` | border + box-shadow + background-image + `::before` bg-color | **explicit rule required** |
| 07 Folio | border-top + color | no defensive CSS needed |
| 08a `.journal-deckle-host` | no declarations | no defensive CSS needed |
| 08b `.journal-deckle-edge` | border-color + CSS mask | no defensive CSS needed — border auto-remaps, mask is alpha/luminance not color |
| 09 Dot Matrix | color + background-clip:text scanline (inert as specified) | **explicit rule required** |
| C.9 Empty State | dashed border-color + `.paper-stock--graph` background-image | **explicit rule required** |

**The three required rules (exact, and only these three — no others):**
```css
@media (forced-colors: active) {
  .journal-index-card-trim {
    background-image: none;
    box-shadow: none;
  }
}
@media (forced-colors: active) {
  .journal-dot-matrix {
    background-image: none;
    color: CanvasText;
  }
}
@media (forced-colors: active) {
  .journal-empty-state {
    background-image: none;
  }
}
```

**Shared invariant (hard requirement, never violate):** never add `forced-color-adjust: none` or `-webkit-text-fill-color: transparent` anywhere in this device set.

### 6.10 Responsive and bilingual risk mitigations

- **Tabs (05) bilingual risk:** fixed 34px × 46px box in `vertical-rl` mode. Risk: longer Spanish labels clip at a hard-fixed 46px. Mitigation: the 46px dimension becomes an intrinsic `min-height` that grows to fit label content (no truncation, no silent clipping); the 34px stacking dimension stays fixed.
- **Folio (07) bilingual risk:** band names run longer in Spanish. Mitigation: `.journal-folio__band` has no fixed width and wraps naturally at narrow viewports; `align-items: flex-start` (not center) keeps a wrapped two-line band label anchored to the top instead of colliding with the week-number sibling.
- **Stamp (04) bilingual risk:** fixed rotated mono-tracked badge has little tolerance for reflow. Mitigation: `label` is a caller-supplied prop decoupled from `state`; a localized label (e.g. "HECHO"/"BLOQUEADO") should be a short fixed-length token comparable in length to the English original. (Localized string content itself is a future consumer's decision, not specified here — Section 10 unresolved item.)
- **Zoom/reflow (400% zoom / 320px CSS width, all nine devices):** fixed-geometry devices (Tabs' 34px stacking width, Stamp's fixed badge) must never force horizontal scrolling of real page content; any overflow a device's own fixed dimension produces must be contained to that device's own box, never propagated to the real content's container. Device 06's `.journal-index-card-frame` width (200px) is a structural host property, not a device-removability concern, and must reflow like any other fixed-width card at narrow viewports per the app's existing card-reflow behavior (out of scope to redesign here).

### 6.11 Accessibility hard requirements

- **Tabs decorative/real-selection-state separation rule (hard requirement):** any page rendering `TabStack` must already expose the real current-selection state through separate, non-decorative, accessible markup, independent of whether `TabStack` renders at all. The same rule extends to Stamp (04): the page must independently expose completion/lock status through real accessible markup, not rely on the stamp.
- **Keyboard/focus invariant (all nine devices, hard):** none render a focusable element. Holds even for `TabStack`: it must never use `role="tab"`/`role="tablist"` or interactive semantics.
- **No-native-dialog constraint:** none of the nine devices or C.9 introduce any native or custom dialog.
- Every device is `aria-hidden` except device 09 applied to real text, and C.9's eyebrow/body, which must never be `aria-hidden`.
- No device may render a focusable element.

### 6.12 Fidelity disclosure — device 09 scanline (accessibility-over-fidelity tradeoff, disclosed and not reopened)

Device 09's `background-clip: text` scanline is inert as specified in every standards-compliant browser — `color` correctly stays opaque and `-webkit-text-fill-color: transparent` is correctly forbidden, so the repeating-gradient background never becomes visible through the glyphs. Device 09 ships as plain bold letter-spaced monospace typography only, not the reference's textured scanline look. This mirrors an identical omission in the reference's own canonical markup (`Field Journal DS.dc.html:310`, same properties, same opaque `color`, no `-webkit-text-fill-color`). This is a deliberate accessibility-over-fidelity tradeoff, confirmed correct by the design reviewer, and is not to be "fixed" by adding `-webkit-text-fill-color: transparent` (doing so would make roughly two-thirds of every glyph see-through and is explicitly forbidden — see Risk, Section 9).

### 6.13 Engineering invariants (hard constraints, apply throughout implementation)

- Zero raw hex outside `src/tokens/` in any declaration; every `var(--x)` resolves in the token file; no non-zero `border-radius` anywhere (Clip uses SVG stroke); the only `box-shadow` is the bare `var(--shadow-card)` token.
- `.paper-stock--graph` and `.paper-stock--ruled` stay unmodified.
- Clip's `stroke` must be set via CSS property, never inline attribute.
- LOCKED Stamp must never render on a paper-200 surface (doc-comment enforced); opacity never reapplied to Stamp text/border paint.
- `.journal-index-card-frame`'s `width`/`padding` and `.journal-deckle-host`'s absence of sizing/background must never be merged back into their respective decorative sibling classes (`-trim`/`-edge`) — this split is load-bearing for the removal test, not a stylistic preference.
- `-webkit-text-fill-color: transparent` and `forced-color-adjust: none` must never be added anywhere in this device set.
- Stamp animation properties must always read `var(--motion-duration-stamp)`/`var(--motion-easing-standard)`, never literals.
- BandRoadmap's `<JournalEmptyState illustrationSrc bodyText />` instantiation must omit `eyebrow` and must render `bodyText` as the sole, complete text node containing "No weeks published yet for this band." — preserving `BandRoadmap.test.tsx:87-91` and `:93-102`.

### 6.14 Permitted variation (implementer discretion — do not exceed)

Implementers may:
- Choose exact prop/type naming conventions consistent with existing repo TypeScript conventions.
- Choose CSS custom-property vs. duplicated-declaration style for shared cross-state rules, as long as resolved values match.
- Reorder CSS declarations within a rule.
- Adjust the SVG clip-ring path's sweep-flag direction after visual confirmation.
- Choose the exact class-name spelling for the device 06/08 structural/decorative split (`-frame`/`-trim` and `-host`/`-edge` are this plan's suggested names, not mandatory strings), provided the two-class separation itself and which declarations live in which class are preserved exactly.

Implementers may **not**:
- Alter any specified color/token mapping, dimension, rotation angle, contrast-driven restriction (LOCKED/paper-200), or animation timing/easing source.
- Alter the BandRoadmap prop values.
- Merge structural and decorative declarations back into one class for devices 06 or 08.

---

## 7. Ordered work

1. **TDD first.** Write failing tests before any production CSS/TSX: the removal test (Section 8.1), the C.9 three-part test (Section 8.2), per-component contract tests for `ClipRing`, `Stamp`, `TabStack`, `Folio`, `JournalEmptyState` under `src/__tests__/` (flat, per repo convention), and an `aria-hidden`/no-focusable-node assertion for every device.
2. Create `src/components/journal/` with the shared `journal-devices.css` (stateless devices 01, 02, 06, 08, 09) and the five component pairs (`ClipRing`, `Stamp`, `TabStack`, `Folio`, `JournalEmptyState`), each `PascalCase.tsx` + co-located `PascalCase.css` with a named export, per Section 6's exact class names, declarations, and prop contracts.
3. Implement the stamp keyframes and the compound-selector animation rules exactly as specified in Section 6.4, always via `var(--motion-duration-stamp)` / `var(--motion-easing-standard)`, never literals. Implement the mount-time fire-once latch emitting the literal class token `journal-stamp--animate`.
4. Add the three `@media (forced-colors: active)` rules from Section 6.9 and nothing more; never add `forced-color-adjust: none` or `-webkit-text-fill-color: transparent`.
5. Adopt `JournalEmptyState` in `BandRoadmap.tsx:73-81` using the exact instantiation in Section 6.3, leaving the outer element and `.band-roadmap-empty-state` className untouched.
6. Run the full gate: `npx tsc --noEmit`, full `vitest` suite (including `src/__tests__/tokenFallbackAuditLint.test.ts` and `src/__tests__/fieldJournalTokens.test.ts`), and the four `SpotIllustration`-asserting test files (`SpotIllustration.test.tsx`, `BandRoadmap.test.tsx`, `RoadmapPage.test.tsx`, `WeekDetailPage.test.tsx`).
7. Verifier pass, then Browser Validator pass on the nine journeys (Section 9).

---

## 8. Acceptance and validation

`npx tsc --noEmit` must be clean; the full `vitest` suite must be green, explicitly including `src/__tests__/tokenFallbackAuditLint.test.ts` (build-breaking) and `src/__tests__/fieldJournalTokens.test.ts`.

Two acceptance criteria are primary and must each be satisfied independently:

### 8.1 The removal test (PRIMARY criterion #1 for §B)

This must be a real test, not a design assertion. Definition: "removed," per device, means the specific selector/class named below is deleted from the stylesheet (and, for 01-05/07, its dedicated wrapper node is deleted from the DOM), while every structural class named in Section 6.2 (`.journal-index-card-frame`, `.journal-deckle-host`), every other node, attribute, event handler, and real text content stays byte-identical.

Per-device before/after table:

| Device | What is removed | Before | After |
|---|---|---|---|
| 01 Tape, 02 Staple, 03 Clip, 05 Tabs, 07 Folio | the device's own wrapper node | node present (`aria-hidden="true"` where applicable) | node absent; host/adjacent real content unchanged in position, size, visibility, and (for 05/07) operability |
| 04 Stamp | `.journal-stamp` node | stamp present alongside real state text | stamp absent; real accessible state text/control remains present and unchanged |
| 06 Index Card | `.journal-index-card-trim` class only | trim class applied | `.journal-index-card-frame` remains; assert computed `width` stays `200px`, computed `padding` stays `14px`; real content still present, sized, legible; only border/shadow/header-bar/ruling visually absent |
| 08 Deckle | `.journal-deckle-edge` class only | edge class applied | host block's own `width`/`height`/`background` are unaffected (Deckle never declares them); bottom edge is a plain rectangle; host content's own dimensions/scroll behavior unchanged |
| 09 Dot Matrix | `.journal-dot-matrix` class from the real text element (not a node deletion) | class applied to real text | same text node/tag/content/accessibility attributes, rendered in the surrounding component's default typography |
| C.9 empty state | `<JournalEmptyState>` element, reverting to the prior hand-rolled JSX or equivalent fallback | JournalEmptyState rendered | `.band-roadmap-empty-state` host className/`text-align: center` unaffected either way; `getByText(/no weeks published yet/i)` continues to match a single text node in both states (governed by its own separate test, Section 8.2, not this checklist) |

Pass checklist (all five must hold for every device row above):
1. Only the named selector/class (and, where applicable, its dedicated wrapper node) is deleted; nothing else changes.
2. No layout collapse hides/overlaps/truncates remaining real content, verified per-device by the explicit before/after assertions above, not asserted generically.
3. All structural classes/declarations (Section 6.2) remain untouched and are explicitly out of scope for any device's removal claim.
4. Real, non-decorative text (vocabulary content, state labels, band names, week numbers) is present, unchanged, legible in both states.
5. The only observable diff between before/after is the device's own visual flourish.

If any part of this table is not mechanically expressible as an automated test (e.g. a genuinely visual "legible" judgment), write the exact manual procedure and expected result into the implementation's test documentation rather than leaving it as an unstated assertion. All nine device rows above are expected to be mechanically expressible via computed-style and DOM-presence assertions; flag any exception explicitly if discovered during implementation.

### 8.2 The C.9 three-part test (PRIMARY criterion #2, per `ADOPTION-PLAN.md:288-290`)

C.9 is governed by a separate acceptance test: spot illustration + graph ground + dashed rule, all three together. Any one missing is a failing implementation. This is independent of the removal-test checklist in Section 8.1 (C.9's own removal row in that table covers the *reversion* case, not the *presence* case tested here).

### 8.3 Additional acceptance checks

- Every device is `aria-hidden` with no screen-reader-needed text; no device renders a focusable element; `TabStack` must never use `role="tab"`/`role="tablist"` or interactive semantics.
- Stamp supports the Section 6.4 animation and collapses to an instant settled state under `prefers-reduced-motion`, with no flash or revert.
- WCAG 2.2 AA per the Section 6.6 contrast table (noting the one open, non-blocking exception recorded in Section 10, unresolved item 2).

---

## 9. Browser UI dialog policy and validation brief

**Dialog policy (required — browser-rendered React UI).** Native `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload` are prohibited. Any acknowledgement or confirmation uses the existing app-owned accessible modal (`src/components/Modal.tsx`); prefer inline validation where it serves the user better. No device in this issue may introduce a dialog of any kind. A deterministic source scan for native dialog calls is required, plus modal keyboard/focus verification if any modal is touched (none is expected in this scope).

**Launch/readiness.** `npm run dev` on the project's already-configured, non-standard dev-server port (use the port already configured in the repo; do not introduce a new one and do not fall back to a default). Base URL: that dev server's origin. No new routes introduced.

**Fixture/reset.** A band with zero published weeks for the C.9 journey. Simulate `prefers-reduced-motion: reduce` and `forced-colors: active` via browser emulation.

**Nine journeys:**

1. Each of the nine devices rendered in isolation; confirm visual match to the token-derived CSS.
2. Stamp entrance done+locked plays once at 260ms with the specified easing and never replays without a React `key` change.
3. Stamp under reduced motion appears instantly settled with no flash.
4. TabStack selected/unselected states, plus confirmation that the host page exposes real selection state independently through non-decorative markup.
5. C.9 on BandRoadmap with zero published weeks — all three parts simultaneously present, and `BandRoadmap.test.tsx:87-91` AND `:93-102` still pass (not just line 98 as an earlier draft stated).
6. Removal test (Section 8.1) exercised live: for each device, apply the exact "remove" operation from the per-device table and confirm the checklist's five pass conditions.
7. Forced-colors simulation for `.journal-index-card-trim`, C.9, and dot matrix; no orphaned artifacts, dot-matrix text stays legible in `CanvasText`.
8. Bilingual stress with long Spanish strings in Stamp `label`, Folio `bandLabel`, and TabStack labels.
9. 400% zoom / 320px width with no horizontal scroll or clipped real content; no-native-dialog scan.

**Viewports.** 320px, 375-414px, 768px, 1280px+, plus 400% zoom at desktop width.

**Visible outcomes.** Every device renders its specified geometry and color with zero lint violations; LOCKED stamp never appears on a paper-200 surface; C.9 always shows all three parts; dot-matrix text remains fully legible (never see-through) in normal and forced-colors rendering; keyboard focus never lands on any device.

### Atelier disclosed-unavailable fallback (pre-authorized, consistent with the #31 precedent)

The Atelier MCP compiler gap (project-root misconfiguration) remains unresolved this session and is user-disclosed and user-authorized. For `tokens_validate`, `design_review`, `contrast_check`, and `a11y_audit`, use the same hand-transcription and documented self-check fallback established in #31, recording each substituted check and its result in the completion evidence.

For `screenshot` + `visual_diff` specifically — a new verification step not present in #31-33 — there is no way to fabricate a real pixel diff against a reference artboard. The substitute is: the Browser Validator captures real screenshots of the implemented §B devices and §C.9 empty state and performs a documented manual visual comparison against the rendered §B and §C.9 sections of `design/field-journal/Field Journal DS.dc.html`, recording per-device pass/fail with the observed discrepancy. **This is a disclosed substitute for a real pixel diff, must be labelled as such in the evidence, and must never be reported as a completed `visual_diff`.**

---

## 10. Reviewer's remaining limits (open, non-blocking items — carry forward, do not silently drop)

Recorded verbatim in substance from the design reviewer's second-cycle PASS verdict:

1. LOCKED Stamp / paper-200 enforcement is doc-comment-only with no compiler/lint gate. A stronger fix (a darker terracotta token or a surface-aware prop) was named but not invented; needs product/engineering sign-off if stronger enforcement is wanted.
2. C.9 eyebrow's 4.22:1 worst-case-on-gridline contrast is below the 4.5:1 AA minimum, with no defined WCAG methodology for patterned backgrounds. Open judgment call; needs design/engineering sign-off.
3. Deckle's "once per screen" and Tabs' "state conveyed elsewhere" are documentation-only conventions, not lint/runtime enforced. Whether to automate is a future engineering-process decision.
4. `--font-family-mono` is missing as a token, and `--border-width-strong`/`--border-width-thin` are duplicated (both 2px) — flagged for token maintainers, not resolved here.
5. Index card's ruled-body stripe color (`var(--color-paper-300)`) and Folio row's `align-items: flex-start` are stated assumptions, not confirmed against a second source.
6. Whether this project adopts APCA as a binding contrast standard is unresolved — if adopted, it would currently fail LOCKED Stamp on every surface including paper-50/100. WCAG 1.4.3 is the currently governing standard; this is noted, not adjudicated.
7. Device 09's scanline is inert as specified in every standards-compliant browser and ships as plain typography (Section 6.12) — disclosed as a fidelity limitation, not a defect to fix, and not reopened by this disclosure.
8. Exact class-name spelling for the device 06/08 structural/decorative split is a suggestion, not mandatory (Section 6.14, permitted variation).

None of these items block implementation or acceptance under this plan. They are carried forward as open engineering/product decisions for a future issue or explicit follow-up.

---

## 11. Assumptions and Planner decisions (D1-D10)

All decisions below were made by Planner under the user's standing authorization and are recorded as reversible on request.

- **D1 — Clip radius.** `ADOPTION-PLAN.md:66` ratifies "radius is zero everywhere, no exception," and lint check (c) (Section 3, finding 8) is shipped and build-breaking; the reference's 13px/6px caption is not a ratified deviation. Resolved as an inline SVG stroked path with round linecap/linejoin — SVG stroke geometry is not `border-radius`, satisfying both the bent-wire intent and the lint.
- **D2 — Deckle mask.** Substitute CSS keywords `transparent` for `#0000` and `black` for `#000`. Behaviorally identical, lint-clean.
- **D3 — rgba alpha literals.** Use `color-mix(in srgb, var(--token) N%, transparent)` so color stays token-derived, since the lint provably does not catch `rgba()` (Section 3, finding 8b).
- **D4 — Stamp trigger, scope boundary.** No week-completion action exists anywhere in the codebase. `week.state` is derived at fetch time (`src/lib/roadmap.ts:90-107`) from `enrollment.completed_at`, so a week arrives already 'completed' on first render with no in-session transition; the only real user-initiated completion event is lesson-level (`src/pages/LearnDetailPage.tsx:212-215`); the reference's D.3 artboard shows a "Stamp week 3 complete" button that does not exist here. Issue #34's criterion is that the stamp *supports* the animation, not that a new completion action is wired. Resolved: ship the stamp as a presentational component with an explicit prop/class animation contract so a future issue can wire it. No new completion action, backend surface, or user flow.
- **D5 — IpNotice.** Listed in the adoption plan's file list with zero acceptance criteria and zero reference coverage; resolved as no functional change in scope.
- **D6 — Stamp rotation.** The reference caption (§B, `DS.dc.html:257`) says "±8°," but specimens drift (`:254` +6deg, `:401` -6deg, `:743` -5deg) — drift repeated across multiple in-context instances, not one isolated slip. Resolved as a systematic ±8° mirror with the canonical caption as tie-breaker over any single specimen's literal value.
- **D7 — Folio.** The reference caption says the week number is "centred," but the markup is a two-child flex `space-between`. Resolved by keeping the proven two-child `space-between` structure, which also degrades better when Spanish band labels wrap (space-between tolerates wrap; literal centering would visually collide the wrapped label against the week-number sibling).
- **D8 — Dot matrix.** `ADOPTION-PLAN.md:117-118` calls all nine devices "all decorative," but device 09 applies its treatment to load-bearing text. Resolved by reading that framing as covering only the scanline flourish, not the text's semantics — the text stays real and is not `aria-hidden`, because hiding real content to satisfy a blanket framing would be a WCAG regression.
- **D9 — SpotIllustration sizing.** Keep the shipped 140px `max-width` rather than the reference's 132px, to avoid fragmenting a shared multi-consumer contract over 8px.
- **D10 — Density.** §B line 214 implies a quiet-vs-full density mode, but no density token, class, or setting exists anywhere in `src/`. Treated as implied-but-undefined and out of scope for #34.

**Standing constraints preserved:** TDD-first; non-standard dev-server port; never weaken Docker or host security; `browser_ui_validation` required; no-native-dialog invariant.

**Assumptions carried from the design handoff (all labelled, needing confirmation at implementation):**
- Index card's 22px ruled-body stripe color is assumed `var(--color-paper-300)` (the reference specifies pitch and structure but not stripe color).
- Folio row `align-items: flex-start`.
- `--border-width-strong` chosen over `--border-width-thin` for 2px structural borders (both numerically 2px, no documented semantic distinction).
- SVG arc sweep-flag direction is to be visually confirmed once implemented.
- A single global stylesheet entry point for `journal-devices.css` is assumed — this is unverified against the actual entry-point structure and must be checked at implementation time (note: `src/main.tsx` imports no CSS, and the repo convention is per-component self-import; the writer should confirm the correct import location before assuming a global entry point exists).

**Staleness note.** The live issue #34 body was supplied by the orchestrator this session and satisfies the pre-flight staleness check; it was not re-fetched during this planning pass. Where the issue body conflicts with the ratified reference and adoption plan, the ratified documents prevail. Three such conflicts are recorded in Section 3: `SpotIllustration.tsx` already exists, `IpNotice.tsx`/`.css` already exist, and the spot-asset filenames differ from what the issue body states.

---

## 12. Risks and rollback

- **HIGH — removal-test validity.** Structural-vs-decorative class coupling already invalidated the first design revision; if the writer merges structural declarations back into a removable class, the primary acceptance criterion becomes untestable. Mitigation: the enforced `.journal-index-card-frame`/`.journal-index-card-trim` and `.journal-deckle-host`/`.journal-deckle-edge` splits, plus the computed-style assertions in Section 8.1.
- **HIGH — the build-breaking token lint.** Any raw hex, non-zero border-radius, blurred box-shadow, or unresolved `var()` fails the build. Mitigation: Section 6's per-device declarations are pre-verified lint-clean; run the lint test early and often during implementation, not only at the end.
- **MEDIUM — BandRoadmap regression.** `getByText` matches a single node, so splitting the preserved sentence across props breaks `BandRoadmap.test.tsx:87-91`. Mitigation: the exact specified instantiation (Section 6.3) with `eyebrow` omitted.
- **MEDIUM — SpotIllustration contract.** Four test files assert its rendered class list. Mitigation: use it unmodified.
- **MEDIUM — `color-mix()` browser support** (Chrome/Edge 111+, Firefox 113+, Safari 16.4+). Mitigation: the specified solid `var(--token)` fallback declaration immediately preceding each `color-mix()` (Section 6.5).
- **MEDIUM — bilingual overflow** in fixed-geometry devices (Tabs 34×46px `vertical-rl`, Folio band labels, Stamp `.22em` tracking). Mitigation: the specified min-height growth, natural wrap, and flex-start alignment (Section 6.10); journey 8 validates.
- **LOW — device 09's inert scanline** is a known, disclosed fidelity limitation, not a defect to "fix" by adding `-webkit-text-fill-color: transparent" — doing so would make roughly two-thirds of every glyph see-through and is explicitly forbidden (Section 6.9, 6.12).
- **ROLLBACK.** The work is purely additive except the BandRoadmap empty-state swap. Revert the `src/components/journal/` directory, its tests, and the single BandRoadmap hunk to restore the prior state; no data or schema migration is involved.

---

## 13. Dependencies

- Depends on shipped issues #31, #32, and #33 (token layer, lint, and prior Field Journal primitives already in the repo per Section 3 findings).
- Depends on `src/tokens/field-workbook.generated.css` and `src/App.css :root` continuing to expose the token names cited in Section 6.5 unchanged.
- Depends on `src/__tests__/tokenFallbackAuditLint.test.ts` and `src/__tests__/fieldJournalTokens.test.ts` remaining the governing lint/test files.
- Depends on `SpotIllustration.tsx`'s contract remaining unchanged (this plan does not modify it).

---

## 14. Required approvals

This plan requires **explicit user approval**, relayed by the orchestrator, before any T1/T2 engineering writer begins implementation. This document, by itself, grants no authority to write code, run destructive commands, or modify the repository. Once approved, the status header at the top of this document must be updated to reflect approval before T1 is dispatched, per the standing plan-approval workflow.

---

## 15. Engineering mode and downstream owner

- **Engineering mode:** standard.
- **Downstream owner:** engineering-fleet — ordinary work routes to T1; evidence-backed remediation escalates to T2 per the two-counted-gate-failure rule; Engineering Lead/T3 advisory checkpoints are available only through explicit authorization, consistent with `docs/BUILD-CONTRACT.md`.
- **Verification:** an independent Verifier pass is required after T1/T2 completion; a Browser Validator pass (Section 9) is required given this is browser-rendered UI. Neither writer nor judge evidence alone constitutes completion.
