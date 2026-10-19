# Lizbeth Spanish — Phase 4 (E.3): Mobile Week-Detail Rebuild

## Status

**CLOSED — complete, 2026-09-06.** All ten ordered-work items (1 through 10, plus item 3.5) are complete, independently verified, and merged to `main`. Full browser validation passed with zero genuine defects and zero unexplained rendered-capture deltas: every difference against the E.3 DS baseline resolved to either a "ratified deviation" or a "content difference" under this plan's own four-category disposition scheme (see "Rendered-capture comparison against the E.3 baseline" above). See "Closure summary" below for the final `main` SHA, the merged-PR sequence, and the notable findings from execution.

All nine open decisions are resolved:

- **D4-1** — self-check and Quiz stay in the Lesson panel; `IpNotice` moves to the Files panel as its last item.
- **D4-2** — copy sign-off complete; the English "Week N" eyebrow form was chosen over the DS's Spanish placeholder, and all other user-facing strings (tab labels, Next's locked reason wording, "Mark complete") were approved as-is.
- **D4-3** — Next is omitted entirely at the terminal week, not rendered disabled.
- **D4-4** — the back link was moved into `WeekDetailPage`.
- **D4-5** — non-blocking; the `aria-current` nav-semantics alternative was rejected but recorded for the historical record.
- **D4-6** — non-blocking; the badge-tint DTCG alias question was resolved as engineering discretion.
- **D4-7** — the `SegmentLedger`/`LessonContentView` dangling-IDREF defect was fixed within Phase 4, per the user's explicit scope-override authorization.
- **D4-8** — non-blocking; accepted as document-level scroll and deferred.
- **D4-9** — the forced-colors shadow leak was fixed.

Across the session, the user approved: this plan in full ("approved proceed as planned," 2026-09-05); the subsequent judge-remediation revision; decisions D4-1, D4-2, and D4-3 in a walkthrough; and D4-7's explicit scope override authorizing item 3.5.

- **Governing umbrella plan:** `docs/plans/lizbeth-spanish-fjds-full-app-conformance-closure.md` (APPROVED). This document is Phase 4 of that plan's E.3 mobile information-architecture work item (umbrella plan scope item 3, "The E.3 mobile week-detail information-architecture (IA) change"). Read the umbrella plan first for overall program scope, the no-touch list, the GitHub issue logging policy, and the standing commit/push/PR/merge-to-`main` authorization. This document does not restate that material; it cross-references it and states only what is specific to Phase 4.
- **Standing authorization inherited from the umbrella plan:** commit, push, PR, and merge to `main` in the `lizbeth-spanish` repository only, as recorded in the umbrella plan's Scope section. This does not extend to deploys, force-pushes, history rewrites, or branch deletion, and it does not independently authorize this phase's execution — that still requires explicit approval of this document.

## Outcome and audience

Rebuild the sub-900px mobile presentation of the week-detail route (`/roadmap/:enrollmentId/week/:weekNumber`) so it conforms to Field Journal DS artboard E.3, at full content parity with the desktop D.3 artboard, per the umbrella plan's decision D-1 (RESOLVED: full parity). Desktop (>=900px) behavior, layout, and tokens are preserved unchanged and are treated as a first-class non-regression target, not an afterthought.

Audience: the engineering fleet (T1/T2, Verifier, Browser Validator) executing this plan, and the user approving it. This document is written to stand alone; a reader does not need access to the planning conversation that produced it, only this file and the umbrella plan it cross-references.

## Scope

### In scope

The sub-900px composition of the `available` ViewState only:

1. Header chrome — back link and progress indicator.
2. Title block — eyebrow and lesson-title `h1`.
3. A new accessible 3-way Lesson / Cards / Files tab control.
4. The Lesson panel's content, including a mobile-only register-badge callout treatment.
5. The Cards panel (flashcards).
6. The Files panel (non-flashcard resources plus the IP notice).
7. A persistent footer with Mark-complete and Next controls.
8. An additive mobile ARIA variant on the existing `SegmentLedger` component (radiogroup below the breakpoint, unchanged tablist at or above it).
9. New DTCG token additions listed in "Tokens" below.
10. Per-surface browser validation for this route.
11. (Added on plan revision, per resolved decision D4-7 — an explicit, narrow exception to this item's sub-900px framing.) The `LessonContentView` tabpanel-mounting fix at the desktop (>=900px) `SegmentLedger` path — DOM/ARIA structure only, not visual rendering, layout, or geometry. See ordered-work item 3.5 and the "Out of scope / no-touch" exception below.

### Out of scope / no-touch

- Desktop D.3 (>=900px) layout, tokens, geometry, and behavior. These must be provably unchanged; see "Desktop non-regression" under Acceptance and validation.
- **Exception, authorized by resolved decision D4-7:** Desktop D.3 tab-panel DOM/ARIA mounting strategy — the sole authorized exception to the desktop no-touch rule, per resolved decision D4-7. Visual rendering, layout, and geometry remain non-regression targets; only accessibility-tree structure changes. See ordered-work item 3.5.
- The 900px breakpoint's trigger value. This is engineering discretion; do not change it unless genuinely necessary, and if it is changed, record why and the new value in the executed plan record.
- `src/tokens/field-workbook.generated.css`. Never hand-edit. All token changes go through `.atelier/tokens/field-workbook.tokens.json` and the compilation pipeline (`scripts/verify-token-pipeline.mjs`).
- `lizbeth_spanish/atelier.config.json`. Standing no-touch directive carried from the umbrella plan; the operative config is the orchestrator-root `H:\CommandCenter\orchestrator\atelier.config.json`.
- Other phases, other artboards, and the token deprecation registry (umbrella plan Phase 1 territory).
- The four selectors the umbrella plan already found conformant: `.owner-settings-page`, `.admin-students-page`, `.admin-students-roster`, `.admin-students-detail`.
- `.admin-shell-nav` — preserve, do not touch.
- Any new visual direction. The design language is fixed and ratified by the Field Journal DS document (`lizbeth_spanish/design/field-journal/Field Journal DS.dc.html`).
- Commit, push, PR, or deploy beyond the umbrella plan's existing standing authorization (commit/push/PR/merge to `main` in the `lizbeth-spanish` repository only; excludes deploys, force-pushes, history rewrites, and branch deletion).
- `taskkill`, unscoped or otherwise, except scoped-PID termination when genuinely required (see "Browser validation" below).

## Cross-references

- Governing umbrella plan: `docs/plans/lizbeth-spanish-fjds-full-app-conformance-closure.md`.
- DS source for artboard E.3: `H:\CommandCenter\orchestrator\lizbeth_spanish\design\field-journal\Field Journal DS.dc.html`, lines 1382-1428.
- Reference harness page: `H:\CommandCenter\orchestrator\.atelier\reference-harness\field-journal-e3-week-detail-390.html`.
- Baseline capture: `H:\CommandCenter\orchestrator\.atelier\baselines\field-journal-e3-week-detail-390.png`.
- Dimensions manifest: `H:\CommandCenter\orchestrator\.atelier\reference-harness\manifest.json` (E.3 = 396x850; D.3 = 1446x1645).
- GitHub issue #102 (TabStack decorative-only finding; this plan closes part of it — see "Repository findings," Finding 5).
- GitHub `Field Journal DS` milestone.

## Repository findings

All findings below were gathered by direct, read-only inspection of the `lizbeth_spanish` repository during planning. No test was executed, no build was run, and no rendered capture was taken during this planning pass — every claim below is an observation of source text unless explicitly marked otherwise. Where planning could not confirm something (for example, live GitHub issue state), that limit is stated rather than assumed away.

### Finding 1 — Route and entry points (correction to an earlier framing)

The route is `/roadmap/:enrollmentId/week/:weekNumber`, not `:bandId`. Observed at `src/App.tsx:122` (`navigate(\`/roadmap/${enrollmentId}/week/${weekNumber}\`)`). `WeekDetailPage` receives `enrollmentId` and `weekNumber` as props (`src/pages/WeekDetailPage.tsx:20-23`) and is keyed at `src/App.tsx:322` as `key={\`${weekDetail.enrollmentId}-${weekDetail.weekNumber}\`}`, so every week-to-week URL change forces a full remount of the page component.

### Finding 2 — Back-link ownership crosses a file boundary

The back link is not rendered by `WeekDetailPage`. It is rendered by `src/App.tsx:314-320` as a `<button className="week-detail-back-link">` reading "← Back to roadmap", outside the page component, styled at `src/pages/WeekDetailPage.css:1-21` (inline-block, no border, underlined, ink-700). E.3 specifies a header-row treatment reading "← Roadmap" in mono 12px/700/.12em uppercase, no underline, min-height 40px, inside a paper-200 bar with a 3px ink border-bottom. Because the current element lives in a different file than the page it visually belongs to, ownership must be an explicit decision (see Finding 4/D4-4 below and item 4 of the ordered work), not something that drifts during implementation.

**Implemented in ordered-work item 4 (2026-09-05).** Per resolved decision D4-4, the back link was moved from `App.tsx:314-320` into `WeekDetailPage.tsx`. Desktop non-regression was engineered by construction, not verified after the fact: the new header markup renders as `display: contents` outside the mobile media query, so it generates no box at >=900px. The back link is also deliberately kept outside `.week-detail-sheet` to avoid newly inheriting the issue-#38 page-turn arrival animation.

### Finding 3 — Current mobile behavior has no tab control

`src/pages/WeekDetailPage.css:158-183`: at `@media (max-width: 56.24rem)`, `.week-detail-grid` becomes `display: block`, a linear stack, and the reading sheet's ornamental gutter collapses to edge padding. There is no tab control today. The desktop grid is `grid-template-columns: minmax(0, 1fr) 400px` with a 44px gap (`WeekDetailPage.css:117-122`).

### Finding 4 — Six ViewStates; E.3 draws only one

`src/pages/WeekDetailPage.tsx:97-103` defines `loading | not-available | locked | empty | error | available`. E.3 draws only the `available` state; the other five require gap-fill treatment (see "Other ViewStates below the breakpoint" under the design handoff).

### Finding 5 — The tab-component premise needs correction; this plan closes part of issue #102

GitHub issue #102 and prior program framing state that `src/components/journal/TabStack.tsx` is decorative-only and that a real accessible tab implementation must be built from scratch. The first half is confirmed by direct inspection: `TabStack` renders an `aria-hidden="true"` wrapper of `<span>` children, uses no `role`, and renders nothing focusable; its own docstring says so, and `src/__tests__/TabStack.test.tsx:46-49` asserts it.

The "from scratch" half is only partly right. `src/components/SegmentLedger.tsx` is already a complete and correct WAI-ARIA tab implementation in this same codebase: `role="tablist"` with `aria-label` (line 72), one `<button role="tab">` per item with `aria-selected`, `aria-controls`, and roving tabindex (lines 76-91), ArrowLeft/ArrowRight with wrapping, Home/End, and Enter/Space (lines 43-69), automatic activation, and a caller-rendered `role="tabpanel"` with `aria-labelledby` and `tabIndex={0}` at `src/components/LessonContentView.tsx:118-129`. That `tabIndex={0}` was itself added under a prior Codex CODE_REVIEW remediation (J-36-02) because no segment body begins with a focusable descendant. Tests exist at `src/__tests__/SegmentLedger.test.tsx`.

The correct statement, and the one this plan uses: no accessible tab **component** is directly reusable, because `SegmentLedger`'s geometry is hard-coded to duration-weighted proportional flex (`style={{ flexGrow: segment.minutes }}`, line 89), which does not fit three non-duration sections. But a proven, reviewed, tested accessible tab **pattern** exists in-repo and is the architectural basis for the new component this plan builds. This plan closes the E.3 half of issue #102 (a real accessible tab control now exists in the codebase) and explicitly does not close the other half — `TabStack`'s disposition (wire it to an intended surface, or delete it) remains owned by issue #102 and the umbrella plan's later closure inventory. Do not claim full closure of #102 from this plan's work alone.

### Finding 6 — Nested-tablist hazard (found during this planning pass; not previously recorded)

If the new outer Lesson/Cards/Files tablist wraps the Lesson panel, and the Lesson panel renders `LessonContentView`, then `SegmentLedger`'s own `role="tablist"` (Phrases/Q&A/Practice) sits nested inside the outer tabpanel — two roving-tabindex groups with arrow-key ambiguity. The resolution is specified under "Design handoff, (b)" below.

### Finding 7 — Duplicate Mark-complete (found during this planning pass; not previously recorded)

E.3's footer has a "Mark complete" control. `src/components/LessonContentView.tsx:203-221` already renders "Mark this lesson complete" with a four-state machine (idle / `Saving…` / `Lesson completed` with a `role="status" aria-live="polite"` confirmation and a one-time Stamp animation / `role="alert"` error with a "Try again" control), driven by `saveCompletion` at lines 95-105 and a mount-time progress fetch at lines 86-94. At full content parity, both would render simultaneously at 390px absent a fix. The resolution is specified under "Design handoff, (c)" below.

### Finding 7.1 — Heading duplication hazard flagged during item 4's implementation (found during implementation, not previously recorded)

`LessonContentView.tsx` still renders `<h2>{content.title}</h2>`. Once ordered-work item 5 mounts `LessonContentView` inside the new mobile Lesson tabpanel, this will visually duplicate the new mobile `h1`, which now also carries the lesson title per the design handoff and Finding 12. This must be resolved deliberately by item 5 — for example, by suppressing the `h2` below the breakpoint or by restructuring the heading hierarchy — and must not be left as a silently visible duplicate. This finding does not resolve the duplication; it records that item 5 must address it.

**Resolution, implemented in ordered-work item 5 (2026-09-05).** `LessonContentView` gains a `suppressTitle?: boolean` prop, defaulting to `false`, so every existing caller's rendered output is unchanged. The new mobile Lesson tabpanel call site is the only caller that passes `true`, which omits the component's own `<h2>{content.title}</h2>` there. Desktop's `h2` rendering is unchanged and is verified by a shared `lessonBody(suppressTitle)` function refactored out of the four content-status branches, so desktop and mobile render the Lesson body from one source rather than two hand-synced copies.

**Disclosed accessibility consequence.** Below the breakpoint, the visible heading run becomes h1 (title block) followed by `SegmentLedger`'s segment content, whose next heading level in this view is h3 — a skipped h2 level. This is accepted deliberately, on two grounds: WCAG 2.2's no-heading-level-skip guidance (technique G141) is an Advisory Technique, not a normative Success Criterion, so skipping a level does not itself fail a WCAG conformance test; and the "missing" h2's string content (the lesson title) is not lost information, because it is already carried by the h1 immediately above it in the same view.

### Finding 8 — "Next →" is net-new navigation, not a restyle

`src/pages/WeekDetailPage.tsx` line 34, inside a comment block spanning lines 25-49, states "no prev/next-week control exists anywhere in this app." E.3's "Next →" is therefore new navigation. The underlying data exists — `fetchLessonsForBand` and `computeWeekRoadmap` are already imported and used — but only inside the `resources.length === 0` branch (`WeekDetailPage.tsx:233-243`). The `available` branch (lines 210-222) does not call `computeWeekRoadmap` today. Wiring week+1's roadmap state inside the `available` branch is new wiring, not free reuse, and is called out that way in item 8 of the ordered work.

### Finding 9 — Cards and Files data sources, traced and confirmed by design review

`src/services/roadmapData.ts` supplies `ResourceRow`. `RESOURCE_LABEL` at `src/components/ResourcesPanel.tsx:15-20` enumerates resource types as `pdf`, `pptx`, `flashcards`, `vocabulary_review`. The internal `lesson_content` row is already excluded at the `WeekDetailPage` call site (`WeekDetailPage.tsx:398-399`).

- Cards = the `resource_type === 'flashcards'` row, signed-URL fetched and YAML-parsed by `ResourceRowView` (`ResourcesPanel.tsx:33-67`), rendered by the existing `src/components/FlashcardsViewer.tsx` (progress bar, "Card NN / NN", flip with `aria-live` announcement, badges, Previous/Next; empty state "No flashcards are available yet." at lines 87-89).
- Files = the remaining resource rows via `ResourcesPanel` (empty state "No resources published for this week yet." at lines 130-136) plus `src/components/IpNotice.tsx` last, matching its current desktop rail position (`WeekDetailPage.tsx:407`).

### Finding 10 — The full-parity / D-2 tension (recorded, not silently resolved)

Umbrella-plan decision D-2 is resolved as "self-check and copyright content appear nowhere on E.3, in any tab." But D-1 requires full content parity with desktop D.3, and desktop D.3 demonstrably contains both: `LessonContentView.tsx:174-193` renders "Self-check: I can…" and a Quiz inside the `qa` segment, and `IpNotice` renders the copyright notice in the rail. Full parity therefore requires placing content the DS artboard itself does not place. This is a net-new mobile decision, not a DS placement decision, and it is carried as decision D4-1 below. **Resolved on plan revision:** the user approved the design cycle's recommendation as recorded — keep self-check and Quiz in the Lesson panel's Q&A segment unchanged, and move `IpNotice` into the Files panel as its last item — see design handoff (d) and (e) and the decision table for the resolution record.

### Finding 11 — Token constraints (verified against the compiled CSS)

`src/tokens/field-workbook.generated.css`: line 36 `--border-width-accent: 6px`; line 37 `--border-width-hairline: 1px`; line 38 `--border-width-rule: 3px`; line 40 `--border-width-thin: 2px`; line 46 `--color-badge-tint-disabled: #fffbf8` (one member of a per-kind badge-tint family at lines 43-47); line 127 `--shadow-brass: 5px 5px 0 0 #a07e48`; line 130 `--shadow-card: 5px 5px 0 0 #1a1512`; line 135 `--shadow-sheet: 8px 8px 0 0 #1a1512`. No existing token matches E.3's compact shadow geometry.

`src/__tests__/tokenFallbackAuditLint.test.ts` check (b) fails the build on any raw hex outside `src/tokens/`, including `var(--x, #hex)` fallback literals, with exactly two narrowly-scoped self-documented `App.css` exceptions. Check (d) fails on any `box-shadow` with non-zero blur. A literal `box-shadow: 3px 3px 0 0 #a07e48` in a CSS file would break the build; `3px 3px 0 0 var(--color-brass-500)` would pass both checks. The design handoff below selects named DTCG tokens rather than raw values, for a single greppable source of truth.

### Finding 12 — E.3 measured values (transcribed directly from the harness file; supersede any looser restatement)

Frame 390x844, flex column.

- **Status bar** (harness line 18): decorative phone bezel, not app UI — must not be implemented.
- **Header row** (lines 19-23): background `#f0ebe2`, `border-bottom: 3px solid #1a1512`, padding `10px 18px`; back link min-height 40px, mono 12px/700/.12em uppercase `#1a1512`, `text-decoration: none`; progress "03 / 26" mono 11px/.14em uppercase `#7c6136`.
- **Title block** (lines 26-29): `border-bottom: 3px solid #1a1512`, padding-bottom 14px, margin-bottom 18px; eyebrow mono 11px/600/.2em uppercase `#7c6136`; `h1` Fraunces 900 36px, line-height .95, letter-spacing -.035em, `#1a1512`, carrying the lesson title (not "Week N").
- **Tab row** (lines 31-35): flex, gap 8px, margin-bottom 18px; each tab min-height 40px, padding `0 14px`, mono 11px/700/.1em uppercase; active background `#1a1512`, color `#fdfcf9`, no border declared; inactive background `#faf8f4`, `border: 2px solid #1a1512`, color `#1a1512`.
- **Intro paragraph** (line 37): 17px, line-height 1.6, `#2a2420`.
- **Vocab preview card** (lines 39-46): background `#f0ebe2`, `border: 2px solid #1a1512`, `box-shadow: 4px 4px 0 0 #1a1512`, padding `16px 18px`; rows flex column gap 8px, `border-bottom: 1px dotted #504940` plus 6px padding-bottom on all rows except the last; term Fraunces 700 18px `#1a1512`, gloss 16px `#504940`.
- **Register-note callout** (lines 48-51): `border-left: 6px solid #a85e4a`, top/right/bottom `2px solid #1a1512`, background `#fffbf8`, padding `14px 16px`; eyebrow mono 10px/600/.2em uppercase `#a85e4a`; body 16px/1.5 `#2a2420`.
- **Handwritten aside** (line 52): Caveat 700 21px `#7c6136`, margin `12px 0 0`, `transform: rotate(-.8deg)`.
- **Footer** (lines 55-58): `border-top: 3px solid #1a1512`, padding `14px 20px`, gap 10px, background `#faf8f4`; "Mark complete" `flex: 1`, min-height 48px, background `#1a1512`, color `#fdfcf9`, `border: 2px solid #1a1512`, `box-shadow: 3px 3px 0 0 #a07e48`; "Next →" min-height 48px, padding `0 16px`, background `#faf8f4`, color `#1a1512`, `border: 2px solid #1a1512`, `box-shadow: 3px 3px 0 0 #1a1512`; both mono 12px/700/.1em uppercase, `border-radius: 0`.

**Footer mechanism, stated precisely:** in the specimen, the footer is the last flex item of a fixed-height column whose content region carries `flex: 1; overflow: hidden`. It is not `position: sticky`. "Sticky footer" describes the visual effect, not the CSS property. Engineering must not implement `position: sticky` on the strength of looser prose.

**Ratified deviation — do not "correct":** both footer buttons use compact geometry (2px border, 3px/3px shadow offset) versus canonical C.1's 3px border and 5px/5px shadow offset. The 48px height and the tier fill/shadow pairing (ink fill + brass shadow for Mark-complete; paper fill + ink shadow for Next) still follow C.1.

**Disclosed deviation from item 4's implementation (2026-09-05).** At `max-width: 640px`, the header bar's padding-right does not match this Finding's literal 18px value. The fixed accessibility "Aa" settings button would otherwise overlap the new progress figure ("03 / 26"). This is the same occlusion hazard already documented at `App.css:918-924` for `.app-main h1` and the back link, now newly relevant because E.3's header places the progress figure where the old header had nothing. This is a deliberate, tested deviation, not an oversight.

### Finding 13 — Reference artefact locations are at the orchestrator root, not under `lizbeth_spanish/`

Harness page: `H:\CommandCenter\orchestrator\.atelier\reference-harness\field-journal-e3-week-detail-390.html`. Baseline PNG: `H:\CommandCenter\orchestrator\.atelier\baselines\field-journal-e3-week-detail-390.png`. Dimensions manifest: `H:\CommandCenter\orchestrator\.atelier\reference-harness\manifest.json` (E.3 = 396x850). DS source: `H:\CommandCenter\orchestrator\lizbeth_spanish\design\field-journal\Field Journal DS.dc.html`, lines 1382-1428.

## Design route

```
DESIGN_ROUTE
profile: standard
reasons: Full-screen mobile rebuild of an existing route; a genuinely new interactive
  multi-state accessible tab component; a user-flow and IA change; two architectural
  conflicts with already-shipped components. Creative direction is fixed by a ratified
  DS artboard, so no direction generation is required and Studio would be the wrong
  tool.
agents_required: design-director, ux-architect, visual-system-designer, design-reviewer
prototype: forbidden
model_tier: sonnet
existing_system_mode: preserve
END_DESIGN_ROUTE
```

## Design review history

The design cycle produced a reviewed `DESIGN_HANDOFF` at revision 2. The review history is recorded here honestly, as two cycles, not smoothed into a single clean pass.

**Cycle 1 — NEEDS_REVISION, eight findings, three HIGH.** The highest-value catch: the visual spec authored implementation-ready treatments for the vocab card, register note, and handwritten aside, none of which had any backing field in `lessonContent.ts` — an engineer would have had to invent content or silently drop the specs. Also caught: a conflict between requiring native `disabled` on Next and requiring its qualifier text to reach the user; the absence of any stated JS mechanism for the viewport-conditional ARIA role, together with a missing considered-alternatives trail for the packet's most consequential accessibility decision; an overstated claim that `computeWeekRoadmap` was already running in the `available` branch; a proposed `color.paper25` token duplicating the existing `--color-badge-tint-disabled` value; an overstated "mirrors" claim about the forced-colors precedent; an APCA "exemption" framing with no documented policy behind it anywhere in the repository; and one imprecise line citation. All eight were resolved in revision 2.

**Cycle 2 — PASS, four non-blocking findings, two of them material.** The two material findings are folded into the binding requirements below as acceptance criteria, not left as advisory notes:

1. A ~0.84px breakpoint mismatch between `window.matchMedia('(max-width: 899px)')` and the CSS breakpoint `max-width: 56.24rem` (899.84px at a 16px root) could produce two simultaneous tablists in that narrow band. Fixed by requiring one shared breakpoint constant/value for both the CSS media query and the JS `matchMedia` check.
2. `aria-live`/`role="status"` was misapplied to the persistently-rendered Next reason string, which does not change within the session at mount and should not be a live region. Fixed by specifying plain, non-live text in normal document order for that string.

A third finding is a proportionality note about how rarely the register-badge callout is reachable in the current content catalog, recorded under "Assumptions and evidence limits" below. A fourth finding asks that dropping `--border-width-accent` from this work be recorded as an explicit, disclosed consequence of the register-note re-mapping, which "Tokens" below does.

The reviewer independently confirmed as sound: the Cards/Files grounding against the actual components including exact empty-state copy; the honest surfacing of the D-1/D-2 tension; the four-state completion machine's preservation in the shared-hook lift; the page-turn remount citations; the borderless-active-tab technique as zero-layout-shift; the four compact shadow tokens as proportionate and traced pixel-for-pixel to the specimen's inline values; `color.badgeTint.register` joining the badge-tint family as the right home now that the element is badge-tier; the rejection of an `aria-current` nav-semantics alternative (`aria-current` indicates current location within a persistent structure, not switching among mutually exclusive panels); the `.week-detail-heading-numeral` class's page-exclusivity; and that no native dialogs are introduced anywhere in this work.

**Post-review note (added on plan revision):** three cross-vendor judge findings (J-PLAN-01, J-PLAN-02, J-PLAN-03; see "Judge route and disposition" below) arrived after this design review had already passed. They were dispositioned by the planner as judge remediation against the existing reviewed handoff, not by reopening the design cycle. No new design direction was introduced by this revision. The ARIA and keyboard model was already fully specified in the reviewed handoff; this revision changes the tab architecture's stated provenance (built from the APG pattern directly rather than treating `SegmentLedger` as a conformance reference), fixes the tabpanel mount strategy, and adds tests.

## Design handoff (binding on execution)

The following is the binding content of the reviewed `DESIGN_HANDOFF` revision 2. Downstream execution treats it as authoritative alongside the measured values in Finding 12.

### (a) Tab architecture

**Provenance, corrected on plan revision (see J-PLAN-01 in "Judge route and disposition" below).** Build a new component (illustrative name `WeekSectionTabs`; exact name and file location are permitted variation) as a sibling to `SegmentLedger` — not an extension, with no shared class names or merged CSS. It is built from the W3C WAI-ARIA Authoring Practices Guide (APG) Tabs pattern directly, verified against the live specification (see the citation table below), and does NOT inherit `SegmentLedger`'s specific implementation. `SegmentLedger` is cited as prior art for the keyboard model only — it demonstrates that this codebase can implement roving tabindex, wrapping arrow navigation, and automatic activation correctly — and is explicitly NOT cited as a conformance reference, because `SegmentLedger` itself carries an unresolved ARIA defect (see J-PLAN-01's disposition) that this new component must not inherit.

It carries `role="tablist"` / `role="tab"` / `role="tabpanel"` with `aria-selected`, `aria-controls`, `aria-labelledby`, roving tabindex (active 0, others -1), ArrowLeft/ArrowRight with wrapping, Home/End, Enter/Space, and automatic activation that must never itself trigger a network fetch. No auto-focus into panel content on switch. A panel receives `tabIndex={0}` only when its current-state content has no focusable descendant (the existing J-36-02 rule, evaluated per panel and per state). Lesson is the default active tab on every fresh mount and is never persisted.

The outer control is `role="tablist"` unconditionally whenever it renders. It renders only below the breakpoint, because at >=900px the unchanged two-column grid shows the reading sheet and rail simultaneously with no selector, so the outer control has no desktop existence and needs no viewport-conditional role.

**Tabpanel mount strategy, fixed by this revision and no longer engineering discretion (see J-PLAN-02 below).** All three tabpanels (Lesson, Cards, Files) mount simultaneously on first render of the `available` state; inactive panels are hidden with the native HTML `hidden` attribute rather than conditionally unmounted. This is a binding requirement, not a permitted variation: an unmount-on-switch implementation is out of conformance with this plan. Grounds are given in full under J-PLAN-02's disposition below; in summary, it preserves `FlashcardsViewer` and `ResourceRowView` local state across tab switches with no state-hoisting rewrite of either already-shipped component, and it independently guarantees every `aria-controls` IDREF on the new component resolves to a real, present DOM element in every tab state, which is what makes the J-PLAN-01 disposition sound by construction.

**Citation table — binding each keyboard/ARIA requirement in this section to its source and its gating test.** Verified by a read-only research pass against the live W3C WAI-ARIA APG Tabs pattern at `https://www.w3.org/WAI/ARIA/apg/patterns/tabs/` (confirmed canonical, no redirect, accessed 2026-09-05; the APG is a living, undated page, so this is a point-in-time verification, not a permanent citation).

| Requirement | Status | Source | Gating test (ordered work item 2) |
|---|---|---|---|
| `role="tablist"`, `role="tab"`, `role="tabpanel"`; `aria-selected` true on the active tab and false on all others; `aria-controls` on each tab referring to its tabpanel; `aria-labelledby` on each tabpanel referring to its tab | APG-mandated (quoted directly from the Roles, States, and Properties section) | APG Tabs pattern | Role/attribute wiring test; IDREF-resolution tests (new, see item 2 below) |
| Roving tabindex, active tab at `tabindex="0"`, others at `tabindex="-1"` | APG technique (not quoted on the Tabs pattern page itself; lives in the APG's general "Developing a Keyboard Interface" guidance) | APG keyboard-interface guidance | Roving-tabindex test |
| ArrowLeft/ArrowRight move focus with wrapping from first to last and last to first | APG-mandated (Keyboard Interaction section) | APG Tabs pattern | Arrow-wrapping test |
| Automatic activation on arrow movement | Optional path under APG's own wording ("Optionally, activates the newly focused tab") | APG Tabs pattern | Automatic-activation test |
| Home and End move focus to the first/last tab | **Not APG-mandated.** Both are explicitly parenthetically labeled "(Optional)" in the live Keyboard Interaction text. This is a correction to this plan's earlier, looser characterization. Treat as a local UX decision this plan chooses to keep, not a standards requirement | APG Tabs pattern (optional bullets) | Home/End test (kept for parity with `SegmentLedger`'s existing behavior) |
| Enter/Space activate the focused tab | APG-specified only as the manual-activation fallback ("Activates the tab if it was not activated automatically on focus"); under this plan's automatic-activation choice, this is a redundant path by the APG's own wording | APG Tabs pattern | Enter/Space test (kept for keyboard-model completeness, matching `SegmentLedger`) |
| Automatic activation is appropriate when panels are preloaded without noticeable latency | APG-mandated, quoted verbatim: "It is recommended that tabs activate automatically when they receive focus as long as their associated tab panels are displayed without noticeable latency. This typically requires tab panel content to be preloaded. Otherwise, automatic activation slows focus movement, which significantly hampers users' ability to navigate efficiently across the tab list." This plan's choice meets that criterion because the mount-all-panels-with-`hidden` decision above means all three panels are preloaded and present, and no panel fetches on activation | APG Tabs pattern | Automatic-activation test; no-network-fetch-on-activation test |
| No auto-focus into panel content on tab activation | Inference, not a directly quotable sentence. The APG's Tab-key bullet describes an explicit, separate Tab press moving focus out of the tablist into the panel, which implies arrow activation alone does not move focus into the panel. This is the standard uncontested reading of the documented model, not a quoted requirement | APG Tabs pattern (inferred) | No-auto-focus test |
| Conditional `tabindex="0"` on a tabpanel with no focusable descendant | APG-mandated, quoted verbatim: "When the tabpanel does not contain any focusable elements or the first element with content is not focusable, the tabpanel should set `tabindex="0"` to include it in the tab sequence of the page." This exactly matches the rule already applied at `LessonContentView.tsx:128` under the prior J-36-02 remediation, which this plan carries forward | APG Tabs pattern (Keyboard Interaction section note) | Per-panel `tabIndex={0}` rule test |

`TabStack` disposition: it is not used, not extended, and not deleted by this phase. It may serve as a visual reference only. Its disposition (wire it to an intended DS surface, or delete it) remains owned by GitHub issue #102 and the umbrella plan's later closure inventory. This plan closes the E.3 half of #102 (a real accessible tab control now exists in the codebase) and must not be represented as closing the dead-component half.

**Update on plan revision — D4-7 resolved.** The `SegmentLedger`/`LessonContentView` dangling-IDREF defect referenced above is no longer deferred. The user has explicitly overridden this plan's original deferral recommendation and authorized fixing it now, within Phase 4, as ordered-work item 3.5, in addition to filing it as a GitHub issue for the historical record. See open decision D4-7's resolution below and item 3.5's task, gate, and dependencies.

### (b) Nested-tablist resolution

Give `SegmentLedger` an additive mobile-only ARIA variant: it keeps `role="tablist"` / `role="tab"` / `aria-selected` at >=900px exactly as shipped, and renders `role="radiogroup"` / `role="radio"` with `aria-checked` below the breakpoint. Visual geometry, roving tabindex, the arrow/Home/End/Enter/Space keyboard model, and `aria-controls` pairing are unchanged at both viewports — only the ARIA role vocabulary differs. `src/__tests__/SegmentLedger.test.tsx` must stay green unmodified; new coverage is added for the variant, never substituted. Net effect: exactly one `role="tablist"` exists on the page at any viewport.

Because CSS media queries cannot set `role` or `aria-*`, the switch is driven by a JS viewport check using this codebase's existing idiom: a `useState` lazy initializer reading `window.matchMedia(...).matches` at mount, plus a `useEffect` that syncs once immediately and registers `addEventListener('change', sync)` with a matching `removeEventListener` cleanup — precedented at `src/pages/CourseWorkspacePage.tsx:145,148` and `src/components/FeedbackForm.tsx:96-97,145-151`. The previously selected segment is preserved across the switch. Implement the layout switch and the ARIA role switch from one shared boolean, not two independently checked breakpoints that could disagree.

**Binding correction from cycle-2 design review:** use the identical breakpoint value and unit in both the CSS media query and the JS `matchMedia` check (for example, `window.matchMedia('(max-width: 56.24rem)')`, which is valid `matchMedia` syntax), or derive both from one shared constant/token. This is a binding acceptance criterion, not a suggestion, and it is gated directly in the ordered work below.

### (c) Duplicate Mark-complete resolution

The footer "Mark complete" is the sole visible completion control below the breakpoint; `LessonContentView`'s own instance is not rendered there, via a suppression prop that defaults to today's rendered behavior. The four-state completion machine and its `saveCompletion` handler are lifted into a shared hook consumed by both the footer and `LessonContentView`, so `LessonContentView`'s >=900px behavior is unchanged. Every existing state and announcement is preserved exactly: idle; `Saving…` with native disabled; `Lesson completed` with native disabled plus the `role="status" aria-live="polite"` confirmation and the one-time Stamp; and the `role="alert"` error with an inline "Try again".

The footer's Stamp instance must be one stable mount across all three tabs for the `WeekDetailPage` instance's lifetime. If the footer's completion block is conditionally rendered or rekeyed per active tab, the fire-once contract breaks and the Stamp could replay on tab switch.

**Stamp occlusion risk, flagged and requiring closure:** `Stamp.css`'s keyframes overshoot to `scale(1.9)` before settling, combined with a `rotate(±8deg)` resting transform. Today it only ever renders inside unconstrained scrollable content. The footer container hosting it must use `overflow: visible` and must not cap height below the Stamp's rotated and overshot bounding box, or the Stamp must be stacked on its own row below the button if the footer must stay fixed-height.

### (d) Cards and Files panel content

Cards = the flashcards resource row through its existing `ResourceRowView` states into `FlashcardsViewer`, or the existing "No flashcards are available yet." empty state. Files = `ResourcesPanel`'s non-flashcard rows (the `lesson_content` row is already excluded at the call site) plus `IpNotice` as the last item, reusing the existing "No resources published for this week yet." empty state. All three tabs always render regardless of per-week content; none is hidden or disabled.

### (e) Lesson panel content and the three mockup-only elements

`src/content/lessonContent.ts` was read in full during the design cycle: `LessonContent` / `PhraseGroup` / `ContentBadge` expose only `ruleBox`, `example`, `translationTask`, `dialectNote`, and short badge `label` strings. There is no vocabulary/gloss/term-list field and no free-text aside field anywhere in the data model. Consequently:

- The "Vocabulario · NN fichas" vocab-preview card is declared mockup-only decorative sample content and is not implemented at any viewport. Grounds: no backing field; the Cards tab already serves the vocabulary-review job with real data. This is a recorded, labeled deviation from E.3's literal frame, not a silent omission.
- The handwritten Caveat aside is likewise not implemented, for the same reason. The Caveat font-face import is dropped with it (see "Tokens" below).
- The register-note callout is mapped to real data: for each phrase group, if `group.badges` contains a `register`-kind `ContentBadge`, that one badge — normally `<li className="lesson-content-badge lesson-content-badge--register">` inside `<ul className="lesson-content-badges">` (`LessonContentView.tsx:137-141`) — receives an elevated accent-bordered callout treatment below the breakpoint in place of its small-chip rendering, using `badge.label` verbatim with no prefix (matching the existing `BADGE_KIND_LABEL['register'] === null` convention, so no new copy is authored). Zero, one, or several callouts may appear per lesson. All other badge kinds keep the existing chip treatment at every viewport.
  - Layout mechanism: `.lesson-content-badges` is already `display:flex; flex-wrap:wrap; gap:var(--space-2)` (`LessonContentView.css:238-247`), so at mobile widths `.lesson-content-badge--register` receives `flex: 1 0 100%`, which cannot share a line and therefore forces its own full-width row at its own document-order position. Siblings before it keep flowing on their own line(s); siblings after it continue on the next. No `order` property is used, so DOM, reading, and keyboard order are preserved.
  - The override must target `.lesson-content-badge--register` only and never `.badge--register`, which belongs to the structurally distinct `src/components/ui/Badge.tsx` component.
  - **Implementation status (2026-09-05).** The register-badge callout is implemented and gated on: an exact `.lesson-content-badges .lesson-content-badge--register` compound selector, never the structurally distinct `.badge--register` owned by `src/components/ui/Badge.tsx`; the `--border-width-rule`, `--color-terracotta-600`, and `--color-badge-tint-register` tokens; no `order` property anywhere in the rule; and it is tested against the real `beginnerWeek01` content artifact — the one week in the current catalog carrying real register-kind content — in addition to a synthetic multi-badge case.
- Q&A and Practice sub-segments are unchanged, including the self-check list and quiz.
- The `.week-detail-heading-numeral` decorative numeral may be suppressed or shrunk below the breakpoint to reclaim vertical space; the class was confirmed page-exclusive by design review, so the shared-class-name hazard does not apply.

### (f) "Next →" control

**Updated on plan revision — decision D4-3 resolved, opposite of this plan's original recommendation.** The user has explicitly chosen to omit Next entirely at the terminal week, not the disabled-but-present treatment this plan originally recommended. Two states, not three: enabled (roadmap entry for week+1 is unlocked/current; navigates, and must call `markForwardNavigationToWeekDetail()` immediately before navigating so the existing page-turn arrival animation fires, mirroring the existing `RoadmapPage` call site), and disabled-locked (roadmap entry for week+1 exists but is locked). There is no third, terminal state: when there is no week+1 roadmap entry, the Next control does not render at all — it is omitted from the DOM, not merely hidden or disabled. The disabled-locked state uses the native `disabled` attribute, consistent with the load-bearing contract documented at `src/components/ui/Control.tsx:16-24`, whereby disabled requires the native attribute so that disabled and focused stay mutually exclusive. Because a natively disabled button is unfocusable and its accessible name may never reach a screen-reader user, a redundant, always-perceivable reason string is rendered near the footer for the disabled-locked state only, not dependent on focus ever reaching Next, stating the locked reason. There is no terminal reason string, because there is no terminal-state button to attach one to. Next renders only in the `available` state, and only when either the enabled or disabled-locked condition applies.

**Footer layout at the terminal week.** When Next is omitted, the footer shows Mark-complete alone. Mark-complete's `flex: 1` sizing (Finding 12) already means it fills the available width on its own, so no new layout rule is needed for the single-control case: a flex row with one `flex: 1` child and no sibling simply gives that child the full content width inside the footer's existing padding. This reasoning holds against the footer's `gap: 10px` flex-row structure (Finding 12) without modification, because `gap` only inserts space between multiple flex items and has no effect when a single child is present — there is no leftover gap to collapse or redistribute. No conditional CSS is required for the terminal-week case beyond omitting the Next element itself.

Data: a new invocation, for week+1, of `fetchLessonsForBand` / `computeWeekRoadmap` inside the `available` branch — new wiring, not free reuse (see Finding 8).

**Binding correction from cycle-2 design review:** render the redundant reason string as plain, non-live text in normal document order — not `role="status"` and not `aria-live="polite"`. A live region provides no announcement benefit for text already present at initial render and can produce a spurious mount-time announcement; `role="status"` also already implies `aria-live="polite"`, so pairing both is redundant. Reserve the live-region treatment for content that genuinely changes within the session, such as the existing Mark-complete states.

### (g) Borderless active tab — layout stability

E.3's active tab declares no border while inactive tabs carry 2px, which would make the active tab 4px smaller and shift the row on every switch. Resolution, confirmed by design review as technically sound with zero layout shift: every tab carries an identical `border: var(--border-width-thin) solid transparent` at rest on `box-sizing: border-box`. Inactive overrides `border-color` to ink-1000. Active leaves the border transparent and sets `background-color` to ink-1000, with `background-clip: border-box` painting under the transparent border so the active tab still reads as a solid borderless ink block while every tab occupies an identical border-box.

Forced-colors mode requires an explicit override, because forced-colors replaces `background-color` and `color` but not a `transparent` border. This extends `SegmentLedger.css:87-103`'s existing forced-colors pattern with one additional `border-color: Highlight` declaration on the active tab, which the cited precedent does not itself contain (`SegmentLedger`'s segments always keep a visible border, so that component never had this problem).

### (h) Tokens

All additions are authored only in `.atelier/tokens/field-workbook.tokens.json` and compiled through the pipeline; `field-workbook.generated.css` is never hand-edited, and the `verify-token-pipeline` oracle must stay green. Canonical C.1 tokens and geometry are never modified, aliased, or redefined app-wide. The compact footer geometry is delivered by new sibling tokens plus one additive `.control--compact` modifier scoped to the mobile footer, changing only border-width and shadow-token references atop unmodified base `.control` / `.control--primary` / `.control--secondary` / `.control:disabled` rules.

**New shadow tokens**, four, each with a confirmed consumer:

- `shadow.brassCompact` = `3px 3px 0 0 {color.brass.500}` — footer Mark-complete, rest state.
  **Corrected 2026-09-05.** This entry originally read `{color.brass.700}`, a transcription
  error in this derived handoff text. Finding 12, the direct transcription of the measured
  E.3 artboard, states `box-shadow: 3px 3px 0 0 #a07e48`, and `#a07e48` is `color.brass.500`
  (`.atelier/tokens/field-workbook.tokens.json:18`), not `color.brass.700` (`#7c6136`, line 21).
- `shadow.brassCompactPress` = `5px 5px 0 0 {color.brass.500}` — same correction, same reason.
- `shadow.inkCompact` = `3px 3px 0 0 {color.ink.1000}` — footer Next, rest state.
- `shadow.inkCompactPress` = `5px 5px 0 0 {color.ink.1000}`.

All four are zero-blur (lint check (d) passes) and reference tokens rather than hex literals (lint check (b) passes).

**Dropped, and must not be reintroduced without a real named consumer:** `shadow.cardCompact` (4px/4px ink) — its only consumer was the deleted vocab card — and the Caveat typeface.

**New color token:** `color.badgeTint.register` = `#fffbf8`, added to the established per-kind badge-tint family (`archaic`, `citedSource`, `dialect`, `disabled`, `inclusive` at `field-workbook.generated.css:43-47`). It deliberately shares its value with `badgeTint.disabled`, stated in the token description; the two semantic names stay distinct regardless, because `-disabled` carries disabled-state semantics that a callout which is never disabled must not imply. Whether the two share one primitive alias at the DTCG source tier is engineering discretion (see open decision D4-6).

**`--border-width-accent` (6px) is not used.** Once the register note was re-mapped to a badge-tier element rather than E.3's standalone callout, its left border is specified as 3px terracotta-600 in the new component token, consistent with the 2px/4px left-border weights its siblings in that file already use. Design review confirmed this as the right call for internal consistency. This is recorded here as a disclosed consequence of the re-mapping, and this plan does not resolve umbrella-plan decision D-6 (the broader `--border-width-accent` permitted-context documentation gap), which remains open elsewhere.

### (i) Responsive structure

Below the breakpoint the `available` state is a flex column of three children: a non-scrolling header; one scrollable region (`overflow-y: auto`, `flex: 1 1 auto`) holding the title block, the tab row, and all three tabpanels (mounted simultaneously, inactive ones hidden via the native `hidden` attribute per (a) above); and a non-scrolling footer as an ordinary `flex-shrink: 0` last child — not `position: sticky`, matching the measured specimen. The specimen's literal `overflow: hidden` on the content region is deliberately not copied, because real content is variable-length. The title block and tab row scroll away with content; an independently sticky tab row was considered and explicitly rejected to respect the DS's authored structure.

**Permitted-variation correction (this revision).** The tabpanel mount strategy is fixed as mount-all-with-`hidden`, per (a) above and J-PLAN-02's disposition. It is not engineering discretion, and a "mounted-but-hidden versus unmount-on-switch" choice is no longer available as permitted variation.

### (j) Other ViewStates below the breakpoint

- `loading`, `not-available`, `error`: back-link-only chrome with no title, tabs, or footer; existing `role="status"` / `role="alert"` messages unchanged.
- `locked`: back link plus progress and the title block with a fallback `h1`; no tabs or footer; keeps the existing `SpotIllustration` and unlock-date message.
- `empty`: same chrome as `locked` with its existing message.
- The `h1` falls back to "Week {weekNumber}" whenever the real lesson title is unavailable, which includes `locked`, `empty`, and every non-success `content.status` sub-state.

### (k) Copy — all placeholder pending product sign-off

The DS specimen's Spanish sample strings are placeholder, never production copy. The eyebrow's Spanish-versus-English form ("Semana 03 · Beginner" versus the app's existing "Week N" plus a real band name) is a copy decision. The tab labels, Next's locked reason wording (there is no terminal reason string; see design handoff (f) and resolved decision D4-3), and the "Mark complete" label are all placeholder. The progress indicator is the current week ordinal over the total lesson count from `fetchLessonsForBand(...).length`, zero-padded to match the app's existing convention.

## Judge route and disposition

### Planned judge route

```
judge_route: PLAN_DUCK eligible and RECOMMENDED before user approval,
  model: gpt-5.6-terra, effort: medium
reasons: The cross-layer accessibility architecture, the viewport-conditional ARIA
  decision, and the new interactive widget make this materially higher-risk than the
  prior phases' token swaps.
targeted_code_review: recommended specifically on the new tab component and the
  SegmentLedger ARIA variant, not on the whole phase, mirroring the prior C.1 Primary
  work's use of a targeted checkpoint rather than blanket judge calls. This phase
  introduces genuinely new interactive UI, unlike prior phases the umbrella plan
  explicitly exempted from per-issue CODE_REVIEW.
call_caps: standard eligible task, at most two calls; high-risk, at most four calls;
  one checkpoint repeatable after remediation, per standing policy.
shadow_mode: findings from any non-required checkpoint remain advisory.
authority_order: deterministic failures (lint, tests, type-check, oracle) always
  dominate any judge result. No judge pass is promised by this plan and no
  model-generated finding is asserted in advance of an actual run.
```

### Run record and disposition (added on plan revision)

`PLAN_DUCK` ran against this plan per `docs/JUDGE-CONTRACT.md`. Verdict: **REVISE**, high confidence, one critical finding and two major findings. The resulting policy action is advisory under shadow mode and therefore non-blocking on its own; this revision spends one judge-driven remediation loop against the standing call caps recorded above. As always, deterministic evidence (lint, tests, type-check, oracle) and this plan's own specification evidence dominate any judge result — none of the three findings below overrides a deterministic gate, and one of them (J-PLAN-01) had its stated severity partially rebutted by a targeted, read-only research pass against the live accessibility specifications. That rebuttal changed the finding's **citation basis** (specification tier versus linter tier) but did not change its **disposition** (the new tab component is still built independent of the `SegmentLedger` precedent, and the precedent's defect is still tracked, not silently absorbed).

| ID | Severity | Finding | Disposition |
|---|---|---|---|
| J-PLAN-01 | Critical (severity partially rebutted on specification evidence; original disposition superseded by user decision, see below) | `SegmentLedger`'s `aria-controls` on inactive tabs references tabpanel IDs absent from the DOM, because `LessonContentView` renders only the active segment's panel. `LessonContentView.test.tsx:51`'s singular `getByRole('tabpanel')` assertion actively locks in that single-panel structure. A targeted research pass found this is not a WAI-ARIA APG or ARIA 1.2 conformance violation (the W3C ACT rule for ID-reference values does not require the referenced element to exist, and the narrower rule that would require it is deprecated/proposed and scoped to `combobox`/`scrollbar`, not `tab`); it is flagged by axe-core's `aria-valid-attr-value` rule, whose proposed softening (dequelabs/axe-core PR #4204 against issue #4202) was closed unmerged. The practical basis for treating this as worth fixing is therefore the linter tier, not the specification tier — both authorities are recorded rather than one being silently preferred. This linter-tier-versus-specification-tier finding stands unchanged; only the scheduling decision below changed. | **Original planner disposition (superseded, kept for the record):** the new E.3 tab component is built from the APG pattern directly and does not inherit `SegmentLedger`'s implementation (see design handoff (a) above). `SegmentLedger`'s own defect is not fixed by this phase and is not absorbed into it; it is recorded as its own bounded follow-up (open decision D4-7) to be filed as a GitHub issue per the umbrella plan's logging policy, because fixing it would change desktop DOM structure or require editing an existing passing test, both of which this phase's charter forbids. **Updated disposition, after user review:** decision D4-7 has since been resolved to fix the defect now, within Phase 4 (ordered-work item 3.5), rather than defer it, as an explicit user override of the planner's deferral recommendation. The new tab component is still built independent of the `SegmentLedger` precedent as originally planned; what changed is that `SegmentLedger`'s own defect is now also fixed in this phase instead of deferred. The GitHub issue is still filed, per the umbrella plan's logging policy, documenting the original defect and its fix commit for the historical record, even though it is closed within this phase rather than deferred. |
| J-PLAN-02 | Major | Conditionally unmounting the Cards and Files tabpanels on tab switch would reset `FlashcardsViewer`'s local deck/flip state (`FlashcardsViewer.tsx:80-82`) and `ResourceRowView`'s local signed-URL state (`ResourcesPanel.tsx:30`), losing the student's place in the deck and re-fetching signed URLs already held. | Mount all three tabpanels simultaneously; hide inactive ones with the native HTML `hidden` attribute rather than unmounting. This preserves both components' state with no internal rewrite, and independently guarantees every `aria-controls` IDREF on the new component resolves, which is what makes the J-PLAN-01 disposition sound by construction. Verified consequence: eager mounting does not cause an eager network fetch, because `ResourceRowView` initializes to `{ kind: 'idle' }` and only requests a signed URL on user activation, and `FlashcardsViewer` renders only after that fetch resolves — so the design handoff's "automatic activation must never trigger a network fetch" requirement is satisfied trivially. Evidence limit: the research pass could not retrieve a directly quotable normative sentence confirming that `hidden`-attribute content is excluded from the accessibility tree and unfocusable; the retrieved WHATWG HTML excerpt confirms non-rendering and exclusion from all presentations "including, for instance, screen readers," but the passage on accessibility-tree/focus exclusion was truncated. This is treated as well-established accessibility practice, not a citation-verified claim, and is independently checked empirically by this plan's own browser-validation keyboard pass (inactive panels confirmed absent from the accessibility tree and unreachable by Tab). |
| J-PLAN-03 | Major | The plan asserted several APG keyboard/ARIA requirements without sourcing them individually, risking an unverifiable or overstated standards claim. | A research pass verified each requirement against the live APG Tabs pattern (`https://www.w3.org/WAI/ARIA/apg/patterns/tabs/`, confirmed canonical, accessed 2026-09-05) and produced the citation table under design handoff (a) above, which marks each requirement as APG-mandated, APG-optional, an APG technique, or a plan-local inference. This surfaced one correction to the plan's own prior assertion: Home/End are explicitly optional in the live APG text, not mandated, and are now recorded as a kept local UX decision rather than a standards requirement. |

## Ordered work

Eleven items (1 through 10, plus 3.5, added on plan revision per resolved decision D4-7), dependency-ordered. Each is bounded for one T1 job with its own gate. Items 1, 2, 7, and 8 are the highest-risk and the likeliest T2 escalations. No item may be dispatched before this plan is approved. Open decisions D4-1, D4-2, and D4-3 have since been resolved (see "Open decisions" below); D4-1 and D4-3 previously carried no-dispatch gates on items 5, 6, and 8, and those gates are now satisfied and lifted. D4-2 no longer gates dispatch of items 4, 6, or 8; it now gates item 10's closure instead (see item 10). No remaining named open decision blocks dispatch of any item in this list.

1. **Token additions and the shared breakpoint constant.** Author the four compact shadow tokens and `color.badgeTint.register` plus the register-callout component tokens in `.atelier/tokens/field-workbook.tokens.json`; compile through the pipeline; introduce one shared breakpoint constant consumed by both the CSS media query and the JS `matchMedia` check.
   - Gate: `verify-token-pipeline.mjs` and `tokenPipelineOracle.test.ts` green; `tokenFallbackAuditLint` checks (b) and (d) green; the compiled CSS is genuine compiler output; the CSS and JS breakpoint values are provably identical.
   - Depends on: nothing.

2. **The accessible outer tab component.** Build the new sibling component with the full ARIA and keyboard model from design handoff (a), plus the borderless-active-tab treatment and forced-colors override from (g), and the mount-all-with-`hidden` tabpanel strategy fixed by J-PLAN-02.
   - Gate: unit tests proving `role="tablist"`/`"tab"`/`"tabpanel"` wiring, `aria-selected`, `aria-controls`/`aria-labelledby`, roving tabindex, ArrowLeft/ArrowRight wrapping, Home/End, Enter/Space, automatic activation, no auto-focus into panel content, and the per-panel `tabIndex={0}` rule; a test proving zero layout shift between active and inactive tab box dimensions; measured conformance to the E.3 tab values (min-height 40px, padding 0 14px, gap 8px, mono 11px/700/.1em uppercase, active ink fill with paper text, inactive paper fill with 2px ink border).
   - New gates (added on plan revision, per J-PLAN-01's disposition): a test asserting every `aria-controls` IDREF on the new component resolves to a real DOM element in every tab state (all three panels mounted, only visibility differs via `hidden`); and a reciprocal test asserting every tabpanel's `aria-labelledby` resolves to its own tab.
   - Depends on: 1.

3. **The `SegmentLedger` mobile ARIA variant.** Add the additive radiogroup variant with live `matchMedia` resync per design handoff (b), using the shared constant from item 1.
   - Gate: the existing `SegmentLedger.test.tsx` suite green unmodified; new tests proving `role="radiogroup"`/`role="radio"`/`aria-checked` below the breakpoint and `role="tablist"`/`role="tab"`/`aria-selected` at or above it, an unchanged keyboard model at both, live resync on a `change` event with the selected segment preserved, and listener cleanup on unmount; an explicit test that exactly one `role="tablist"` exists at both viewports and at the exact breakpoint boundary.
   - Depends on: 1, 2.

3.5. **(Added on plan revision, per resolved decision D4-7 — explicit user override.) Fix the `SegmentLedger`/`LessonContentView` dangling-IDREF defect within Phase 4.** Fix `LessonContentView`'s tabpanel-mounting so every rendered `SegmentLedger` tab's `aria-controls` resolves to a real, present DOM element at the desktop (>=900px) tablist path — by applying the same "mount all panels, hide inactive ones via the native `hidden` attribute" strategy already mandated for the new E.3 component in design handoff (a)/J-PLAN-02, so the fix is architecturally consistent with the rest of this phase's work rather than a one-off patch.
   - **Explicit override note.** This item contradicts this plan's own "Out of scope / no-touch" list, which states "Desktop D.3 (>=900px) layout, tokens, geometry, and behavior. These must be provably unchanged." The user has explicitly authorized this specific, narrow exception. The boundary is precise and must not be blurred: desktop's **visual rendering, layout, and geometry** remain a hard non-regression target, unchanged; desktop's **accessibility-tree/DOM structure** for `LessonContentView`'s tab panels changes (from one mounted panel to three, with two hidden) as a deliberate, authorized exception. A visual regression at desktop width is still a failed gate under this override — only the DOM-structure change is authorized.
   - **The forbidden test edit, now authorized.** `LessonContentView.test.tsx:51` uses `getByRole('tabpanel')` singular, which throws on multiple matches, and actively locks in the defective single-panel structure. Rewriting this pre-existing test is authorized as part of this override, correcting this plan's earlier statement (Finding 5 / design handoff (a)) that editing it was forbidden. Rewrite it to use `getAllByRole('tabpanel')` (or equivalent) and assert on the *active* panel specifically, plus new assertions that all three panels are present in the DOM (two of them `hidden`) and that every tab's `aria-controls` resolves.
   - Gate: `LessonContentView.test.tsx` passes with the rewritten assertions; a new test proving every `SegmentLedger` tab's `aria-controls` IDREF resolves to a real DOM element at desktop width; visual/pixel non-regression at desktop width independently confirmed (screenshot or computed-layout comparison before/after showing zero visual difference, since only DOM structure and ARIA wiring change, not rendering); no state-loss regression introduced by the new mount-all-with-hidden strategy at desktop width — confirm whether `LessonContentView`'s segment content holds meaningful per-segment state that could be lost when hidden/re-shown, or whether it never held such state, and state which is true in the executed record, consistent with the same concern J-PLAN-02 raised for the new mobile component.
   - Depends on: 3 (so the mobile radiogroup variant is confirmed clean of the defect first, and is not built on top of an unresolved fix mid-flight). Blocks: nothing downstream structurally, but is sequenced before item 5 (Lesson panel wiring), since item 5 mounts `LessonContentView` and should mount the corrected version.

4. **Mobile header chrome and title block.** The header row (back link, progress indicator) and the title block (eyebrow, lesson-title `h1` with its documented fallback), including the explicit decision on back-link ownership between `App.tsx` and `WeekDetailPage` (open decision D4-4), and the heading-numeral suppression.
   - Gate: measured conformance to the E.3 header and title values; the `h1` fallback correct in every non-success state; the progress figure zero-padded and derived from real lesson count; the decorative status bar provably not implemented; no shared-class-name leakage from any new selector.
   - Depends on: 1.

5. **Lesson panel wiring and the register-badge callout.** Mount `LessonContentView` inside the Lesson tabpanel and add the mobile register-badge callout per design handoff (e).
   - Gate: self-check and Quiz still render unchanged; the callout renders only for `register`-kind badges and only below the breakpoint, using `badge.label` verbatim with no new copy; sibling chips wrap around it without reordering and no `order` property is used; the override targets `.lesson-content-badge--register` and never `.badge--register`; the same lesson at desktop width still shows the ordinary chip.
   - Depends on: 2, 3, 3.5, 4.
   - **Honest interim-state note (updated 2026-09-05, item 6 implemented 2026-09-05).** As of item 6, the Cards and Files tabpanels are wired with real content per design handoff (d), superseding this note's earlier statement that they rendered `null`. Cards reaches the flashcards resource row through `ResourceRowView` into `FlashcardsViewer`, or its existing empty state when no flashcards resource exists. Files reaches `ResourcesPanel`'s non-flashcard rows plus `IpNotice` as the last item, or its existing empty state when no such rows exist. The attachments rail's previous standalone mobile position has been retired in favor of the Files tab. The J-PLAN-02 state-preservation guarantee (no reset of `FlashcardsViewer`'s deck/flip state, no re-fetch of `ResourceRowView`'s signed URL, across a Cards-to-Files-and-back tab round trip) is now exercised by this real content rather than only by item 2's synthetic test fixtures, and is verified by item 6's explicit round-trip test. What remains incomplete: footer geometry (padding, sizing, paper texture at mobile) is still pending items 7 through 9, so the mobile frame is not yet E.3's final composition.

6. **Cards and Files panels.** Wire both per design handoff (d), including per-tab empty states and `IpNotice` as the Files panel's last item.
   - Gate: the flashcards row reaches `FlashcardsViewer` with its existing states intact; the `lesson_content` row never surfaces; both empty states render with their existing copy; all three tabs render even when a panel is empty; no redundant re-fetch when a panel is re-activated.
   - New gate (added on plan revision, per J-PLAN-02): an explicit test that loads Cards, advances the flashcard deck past the first card, switches to Files, switches back to Cards, and asserts both that the deck position did not reset and that no duplicate signed-URL fetch occurred.
   - Depends on: 2.

7. **The shared completion hook and footer Mark-complete.** Lift the four-state completion machine into a shared hook and render the footer control per design handoff (c), including the Stamp stability invariant and the occlusion mitigation.
   - Gate: all four states preserved with their existing copy, `role="status" aria-live="polite"` confirmation, and `role="alert"` error with retry; `LessonContentView`'s desktop behavior provably unchanged; exactly one completion control visible below the breakpoint; the Stamp fires once and does not replay on tab switch; the Stamp is not clipped by the footer.
   - Depends on: 2.
   - **Implementation note (2026-09-05).** Item 7 built the shared completion hook and footer Mark-complete control per design handoff (c). During development, a real defect was found and fixed: deriving hook enablement from viewport state caused a duplicate "lesson opened" progress write on a viewport crossing mid-session. The fix has `WeekDetailPage` own exactly one completion-machine instance at both viewports, rather than one instance per viewport. While pinning the shadow tokens in a regression test, this work also discovered the brass-compact token transcription error documented in design handoff (h) above.

8. **The footer Next control.** Wire week+1 roadmap state inside the `available` branch and build the two-state Next control per design handoff (f) (updated per resolved decision D4-3: omit entirely at the terminal week, rather than the plan's originally recommended disabled-but-present treatment), including the `markForwardNavigationToWeekDetail()` call and the plain non-live redundant reason string for the disabled-locked state.
   - Gate: enabled Next navigates and the page-turn animation fires exactly once on the new mount; the disabled-locked state uses the native `disabled` attribute and is excluded from tab order, with its redundant reason string present, correctly worded, and perceivable without focus ever reaching the button, and not a live region; Next never renders outside the `available` state; at the terminal week (no week+1 roadmap entry), the footer container correctly omits the Next control entirely — it does not render in the DOM, not merely hidden or disabled — and Mark-complete alone still meets its own layout/geometry requirements (full available width, correct min-height, correct shadow/border treatment) when it is the only footer control.
   - Depends on: 1, 4.

9. **Footer geometry and the compact modifier.** Apply the `.control--compact` additive modifier and the footer container treatment per design handoff (h) and (i).
   - Gate: measured conformance to the E.3 footer values (border-top 3px, padding 14px 20px, gap 10px, both buttons 48px min-height, Mark-complete `flex: 1` with brass 3px/3px shadow, Next content-width with ink 3px/3px shadow, both 2px border, zero radius); the footer is a flex child and not `position: sticky`; canonical `.control` rules provably unmodified; no raw hex and no non-zero-blur shadow anywhere.
   - Depends on: 1, 7, 8.
   - **Implementation note (2026-09-05).** Item 9 applied the `.control--compact` modifier and the footer container treatment per design handoff (h) and (i). While doing so, it found and fixed three real defects in already-shipped items 7 and 8. All three were confirmed independently by a Verifier pass, including the specificity arithmetic below and the mechanism by which the pre-item-9 code happened to render correctly only by accident, via CSS import order, rather than by design.
     - **Press-feedback specificity collision.** Item 7's inline Mark-complete rule tied exactly with canonical `.control--primary`'s hover/active rules (both specificity (0,3,0)), resolved only by CSS import order (`Control.css` loads before `WeekDetailPage.css`), which meant Mark-complete had zero press feedback: it held its rest-state shadow through hover and press. Fixed by the new `.control--compact` modifier's compounded selectors, which outrank canonical C.1 by specificity, (0,4,0)/(0,5,0), rather than relying on fragile import order.
     - **Inert `flex-shrink: 0`.** Declared on the footer since item 7, but `.week-detail-page` was never actually a flex container until item 9 made it one. The declaration had zero effect and passed every prior source-text-level gate while doing nothing.
     - **A margin-collapse regression this surfaced.** The title block's Finding 12 `margin-bottom: 18px` (item 4) had been collapsing with `.week-detail-grid`'s desktop-era `margin-top: 28px` under block flow, silently rendering 28px instead of 18px, invisible to any declaration-level gate in items 4 through 8. Fixed once the page became a genuine flex column, since flex items never collapse margins, by zeroing the grid's mobile `margin-top`. The same collapse mechanism also affected the bare-`<p>` user-agent margins on `.week-detail-error`, `.week-detail-not-available`, and `.week-detail-empty`, fixed the same way; `.week-detail-locked` (a `<div>`) needed no fix.

**Items 1-9 status.** Items 1-9 complete and independently verified as of 2026-09-05. Item 10 (full-parity verification, browser validation, and closure) remains, gated on D4-8 and D4-9's disposition alongside its own stated acceptance criteria.

10. **Full-parity verification, browser validation, and closure.** Execute the parity method and the browser validation below, record the rendered-capture disposition, and close the phase.
    - Closure gate (per resolved decision D4-2): items 4, 6, and 8 may be structurally built and gate-passed against current placeholder copy (the DS's Spanish sample eyebrow text, the three tab labels as literally shown in the DS, and placeholder Next/locked reason wording). This item may not close the phase until actual copy sign-off for those three items' user-facing strings has been obtained and recorded in the executed plan record. Copy sign-off is a closure gate on this item, not a dispatch gate on items 4, 6, or 8.
    - Depends on: all prior items.

## Interfaces and data

No API, schema, migration, or data-model change. `LessonContent` and `PhraseGroup` are consumed as-is and are not extended — that is precisely why the vocab card and handwritten aside are unimplemented. Changes are confined to `.atelier/tokens/field-workbook.tokens.json` and its compiled output via the pipeline, `src/**/*.css`, `src/**/*.tsx` markup, one new component plus one new shared hook, `src/App.tsx` if back-link ownership moves, and test files. `lizbeth_spanish/atelier.config.json` is never edited.

Backward compatibility: `SegmentLedger`'s public props are unchanged if the variant is prop-driven with a safe default; `LessonContentView` gains one suppression prop defaulting to today's behavior so no other caller changes.

## Acceptance and validation

### Deterministic gates

- `npm run lint`, `tsc --noEmit`, and the full vitest suite pass with no exclusions. An exclusion-based pass is a failed gate — this program has a recorded prior incident in which a "full pass" was falsely claimed by silently omitting `rlsIntegration.test.ts`. The local Supabase stack must be confirmed running before any RLS-dependent result is trusted.
- `tokenFallbackAuditLint` checks (b), (c), and (d) pass.
- `verify-token-pipeline.mjs` and `tokenPipelineOracle.test.ts` pass.
- The umbrella plan's Phase 1 deprecation detector reports no new findings against the frozen 80/77 baseline.
- The existing `SegmentLedger.test.tsx` suite passes unmodified.
- The deterministic no-native-dialog source scan passes, and `src/__tests__/nativeDialogPolicy.test.ts` stays green.

### The single-tablist invariant

A first-class acceptance criterion in its own right: exactly one `role="tablist"` exists in the accessibility tree at desktop width, at mobile width, and at the exact breakpoint boundary, with the CSS and JS breakpoint values proven identical.

### Desktop non-regression

The >=900px D.3 rendering must be unchanged. Prove it by capturing the desktop viewport before and after and disposing of any delta, and by confirming every new CSS rule is scoped inside the existing media query.

### Full-parity verification method

This is the specific answer to the umbrella plan's D-1 full-parity requirement and must not be reduced to an impression. Build an explicit two-column content-inventory table enumerating every content element the desktop `available` state renders — from `LessonContentView` (title `h2`, `SegmentLedger`, all three segments, every phrase group's rule box / example / translation task / dialect note, every badge kind, the self-check list, the quiz, the practice summary, the completion control and its confirmation) and from the rail (`ResourcesPanel`'s rows by type, `IpNotice`). For each row, record where that element appears in the mobile composition and which panel it lives in.

The gate is that every desktop content element has a mobile home, with exactly three permitted exceptions, each individually justified in the executed plan record:

1. The vocab preview card (mockup-only, no data source, never rendered on desktop either, so not a parity loss).
2. The handwritten aside (same grounds).
3. Any element the resolved D-2 confirmation (decision D4-1, resolved as recommended: self-check/Quiz stay in the Lesson panel, `IpNotice` moves to the Files panel as its last item) explicitly relocates.

Assert this inventory as an automated test over the rendered mobile DOM wherever the element is deterministically identifiable, so parity is mechanically re-checkable rather than a one-time manual pass. A reduced mobile content set is a failed gate, not a design choice.

**Next's terminal-week omission is not a parity exception, because it is not a parity question at all.** Resolved decision D4-3 (omit Next entirely at the terminal week) does not appear in the exceptions list above and does not need to, because Next is net-new mobile navigation per Finding 8 — "no prev/next-week control exists anywhere in this app" — and therefore has no desktop equivalent in the D.3 content inventory. The full-parity gate measures whether every desktop content element has a mobile home; it does not require every mobile-only control to exist on desktop. A future reader should not misread Next's terminal-week omission as a parity gap.

### Rendered-capture comparison against the E.3 baseline

Capture the mobile route at the manifest's exact E.3 dimensions (396x850) and compare against `H:\CommandCenter\orchestrator\.atelier\baselines\field-journal-e3-week-detail-390.png`. Per this program's established authority ordering, `visual_diff` against a DS-derived baseline is non-authoritative for pass/fail and must never auto-fail a surface — it is structural signal only, because the reference shows idealized placeholder content while the app shows real data.

Every non-zero delta receives a written disposition in exactly one of four categories:

1. **Ratified deviation** — citing the specific clause that permits it (the compact footer geometry and the three unimplemented mockup elements are expected here).
2. **Content difference** — the reference shows placeholder text and the app shows real data.
3. **Genuine defect** — filed as a GitHub issue per the umbrella plan's logging policy.
4. **Unexplained** — a stop-and-report condition, never silently passed.

The authoritative signals remain the deterministic lint, the structural and located findings from this plan's own acceptance checks, and browser validation. Mask or hold constant every dynamic region (real student names, live dates, computed progress) before capture, so captures are comparable across runs and across the reference/app pair.

### Independent gates

A read-only Verifier pass is required; no writer may self-approve. A Browser Validator pass on this surface is required. Neither is discharged by source-level evidence alone; a browser-validation tooling failure is a blocking impediment to be reported, never grounds to accept the surface on source evidence alone.

## Browser UI dialog policy

Required. No native `alert`, `confirm`, `prompt`, any `window.*` form, or `beforeunload` anywhere in this browser-rendered React UI, in any existing or newly gap-filled state, including every destructive and validation path. E.3 as drawn introduces no dialog at all, and this phase introduces none — that is an affirmative finding from planning, not an omission.

Acknowledgement and confirmation, if ever added here, use the app-owned accessible modal: focus trapped while open, focus returned to the trigger on close, Escape plus an explicit close control, never backdrop-only dismissal, with the visible 3px slate focus ring at 2px offset at every stop. Inline validation per the C.2 pattern is preferred wherever the DS shows an inline pattern.

The gate has two halves, both required:

1. **Source scan** — a deterministic scan over `src/**` for `alert(`, `confirm(`, `prompt(`, their `window.*` forms, and `beforeunload`, run as a build gate and already enforced by `src/__tests__/nativeDialogPolicy.test.ts`.
2. **Runtime confirmation** — no native dialog fires on any journey enumerated below, including the Mark-complete error/retry path and both Next disabled states.

## Browser validation

**Launch and readiness:** `npm run dev` in `H:\CommandCenter\orchestrator\lizbeth_spanish`; ready when the login route renders. Reuse an existing healthy dev server rather than restarting it. Never `taskkill`; scoped-PID termination only if termination is genuinely required. This program has a recorded prior incident of an unscoped `taskkill /F /IM node.exe /T` causing collateral damage despite explicit instructions — every browser job under this plan must avoid repeating it.

**Base URL:** `http://[::1]:5173` per this program's standing requirement, falling back to `http://localhost:5173` if the IPv6 loopback form does not resolve. Both address the same Vite server on port 5173. Note which form was actually used in the executed record rather than silently choosing one.

**Fixture and reset:** the dev-only seeded quick-select panel at `src/components/LoginForm.tsx:123-138`, using real seeded Supabase Auth accounts; the local Supabase stack must be confirmed running; no fabricated fixture data. Required fixture coverage:

- Weeks reaching all six ViewStates.
- Within `available`: one week with and one without a flashcards resource; one with and one without non-flashcard resources.
- One week at the final roadmap position (Next-terminal). This fixture requirement stays relevant under resolved decision D4-3: the assertion at this fixture changes from "Next is disabled with reason text" to "Next does not render at all."
- One week immediately before a locked week (Next-disabled-locked).
- The beginner band's week 1 — the only week in the current 78-file catalog carrying a `register`-kind badge (see "Assumptions and evidence limits" below) — plus any other week to confirm no callout renders without one.

**Journeys:**

- J1: open an available week (header, title, tabs, and footer render; Lesson active by default; the page-turn animation fires once).
- J2: the locked, empty, not-available, and error states (reduced chrome, back link as the only exit, existing messages unchanged).
- J3: the Cards tab, with and without a flashcards resource, confirming `FlashcardsViewer` parity and the existing empty-state copy.
- J4: the Files tab, confirming the filtered `ResourcesPanel`, `IpNotice` last, and the empty-plus-IpNotice-only case.
- J5: Mark complete — idle to saving to completed, with the `aria-live` confirmation and a single non-replayed, non-clipped Stamp; and saving to error with retry.
- J6: Next — enabled re-triggers the page-turn on the new mount; the disabled-locked state is inert and excluded from tab order while the plain redundant reason string stays perceivable without focus; at the terminal week (updated per resolved decision D4-3), Next does not render at all and the footer shows Mark-complete alone, filling the available width.
- J7: the register-badge callout — the one real register-carrying week shows the accent-bordered callout at mobile width in place of the chip, with sibling badges wrapping around it and not reordered, and the same week at desktop width shows the ordinary chip.
- J8: desktop non-regression — the >=900px D.3 rendering unchanged.
- J9 (added on plan revision, per J-PLAN-02): Cards state survives a tab round trip — advance the flashcard deck past the first card, switch to Files, switch back to Cards, and confirm the deck position visibly survives the round trip with no reset and no duplicate signed-URL fetch.

**Keyboard and focus:** full traversal of the outer tablist (ArrowLeft/ArrowRight with wrapping, Home, End, Enter, Space, roving tabindex, no focus jump into panel content); traversal of the inner `SegmentLedger` at both viewports, confirming via the accessibility tree that it is a tablist at desktop and a radiogroup at mobile while its keyboard behavior is unchanged; confirmation that exactly one `role="tablist"` exists in the accessibility tree at desktop width, at mobile width, and at the exact breakpoint boundary; confirmation that both disabled Next variants are excluded from tab order while their reason string remains perceivable; and a mid-session resize or zoom across the breakpoint confirming the inner control's exposed role live-resyncs with the active segment preserved and no unexpected focus loss.

**Viewport profiles:** 396x850 for the E.3 comparison, matching `manifest.json` exactly rather than a blanket 390-wide profile; at least one width immediately either side of the breakpoint plus the boundary itself for the single-tablist check; and 1446x1645 for the D.3 desktop non-regression capture, matching the manifest's D.3 entry.

**Visible outcomes:** captures at both mobile and desktop widths for every ViewState; the active tab visibly does not shift size or position relative to inactive tabs on switch; the Stamp is visibly not clipped inside the footer; the register callout visibly forces a full-width line break among sibling chips without reordering them; the footer's two buttons show the compact 2px border and 3px offset shadow with brass on Mark-complete and ink on Next; the decorative phone status bar is visibly absent; and a contrast spot-check on the register callout and the tab control.

**Cross-cutting:** the 3px slate focus ring visible at 2px offset outside the shadow on every focusable control on this surface. Under `prefers-reduced-motion`, the page-turn transition and the completion-stamp animation show an instant state change, explicitly not an opacity-only fade; tab switching is instant in both motion regimes.

## Risks and rollback

Overall risk: **medium-high** — higher than the umbrella plan's other phases, because this is the first genuinely new interactive accessible widget rather than a token swap.

1. **The breakpoint mismatch reintroduces two simultaneous tablists.** Mitigation: the shared-constant requirement in item 1 and the explicit boundary test in item 3.
2. **The viewport-conditional ARIA role means a screen-reader user is told something different about the same content depending on window width, and a desktop low-vision user zooming across the threshold sees the announced interaction model change mid-session.** Mitigation: live resync with the selected segment preserved. Residual: the reviewer accepted the mechanism but recorded the `aria-current` nav-semantics alternative as genuinely close and not fully foreclosed (open decision D4-5).
3. **The Stamp's fire-once contract breaks and it replays on tab switch, or is clipped by the footer.** Mitigation: the stable-mount invariant and the `overflow: visible` requirement, both gated in item 7.
4. **The shared completion-hook lift regresses `LessonContentView`'s desktop behavior.** Mitigation: the suppression prop defaults to today's behavior, and desktop non-regression is an explicit gate.
5. **A mobile-only override leaks to desktop or to another page through a shared class name.** This is a documented cascade-collision root cause in this app, in both directions. Mitigation: every new rule scoped inside the existing media query, and class exclusivity verified before any override is scoped to a shared name.
6. **"Full parity" degrades silently into a reduced mobile set.** Mitigation: the mechanical content-inventory gate described above.
7. **Browser validation is unavailable.** The umbrella plan records this status as genuinely uncertain, with three prior Claude-in-Chrome failures against a healthy dev server and more recent successes using tab reuse. This blocks surface acceptance and is reported, never worked around.
8. **An unscoped `taskkill` causes collateral damage** — a recorded prior incident in which Browser Validator twice ran a broad `taskkill /F /IM node.exe /T` despite explicit instructions. Every browser job under this plan must reuse the existing dev server rather than restarting it and must use scoped-PID termination only if termination is genuinely required.
9. **Plan staleness across a multi-item execution.** Any material repository, requirement, dependency, or evidence change requires `JOB_BLOCKED: Plan stale` and re-planning or explicit reapproval, never silent reconciliation.
10. **The tab architecture's original grounding turned out to be a defective in-repo precedent (see J-PLAN-01).** Mitigation: the new component is rebuilt from the live APG specification directly rather than from `SegmentLedger`'s implementation, and the new IDREF-resolution gates in ordered-work item 2 make the defect this plan avoids mechanically checkable rather than a one-time claim. **Updated on plan revision, per resolved decision D4-7:** the underlying `SegmentLedger`/`LessonContentView` defect itself is no longer deferred to a separate job. The user has explicitly authorized fixing it now, within Phase 4, as ordered-work item 3.5, in addition to filing it as a GitHub issue for the historical record. Rollback note: item 3.5's fix is, like the rest of this phase, an independently revertable, additive-pattern change (mount-all-with-hidden), so it can be reverted as its own unit without touching the new E.3 component or any other item.
11. **Eager-mounting all three tabpanels increases the initial DOM size on this route (see J-PLAN-02).** Mitigation: the research pass verified no eager network fetch results from eager mounting, and the increase is bounded by the panels' existing content (no new data source is introduced by the mount-strategy change itself).

**Rollback:** every item is an independently revertable CSS, token, or component edit. The token pipeline oracle makes a bad token change immediately detectable. The new tab component and the shared hook are additive; the `SegmentLedger` variant is additive behind a default-safe prop. No schema, data, or irreversible state is involved. The highest-coupling revert is item 7's completion-hook lift, which touches an already-shipped component and should be reverted as a unit with item 9.

## Assumptions and evidence limits

**Safe assumptions.** The dev server runs via `npm run dev` from `H:\CommandCenter\orchestrator\lizbeth_spanish`, with Vite configured for port 5173 (a stale claim of 5174 exists in the root README and is separately noted in `handoff.md`). The dev-only seeded quick-select panel at `src/components/LoginForm.tsx:123-138` provides authenticated student access using real seeded Supabase Auth accounts and does not render outside development mode.

**Evidence limits, stated plainly.** Planning was read-only: no test was executed, no build was run, and no rendered capture was taken during this pass. Every acceptance check in this document is specified, not yet demonstrated. `gh` was not available on the read-only planning tool surface, so live GitHub state for issue #102 and the `Field Journal DS` milestone was not read; where a live read contradicts this plan, the live read wins. The design cycle did not inspect the DTCG source `.atelier/tokens/field-workbook.tokens.json` directly, only the compiled CSS, so the primitive/semantic split for the new tokens is proposed by convention and must be confirmed against the source at implementation time (see open decision D4-6).

**Judge-remediation research pass (added on plan revision).** One bounded, read-only research pass was run for this revision, in response to the `PLAN_DUCK` findings recorded under "Judge route and disposition" above. Its subject was specification verification only (the live W3C WAI-ARIA APG Tabs pattern, the W3C ACT rules for ID-reference values, and the WHATWG HTML spec's `hidden`-attribute behavior); it did not re-inspect the repository. It produced two outcomes worth flagging explicitly: one correction to this plan's own prior assertion (Home and End are optional in the live APG text, not mandated, and are now recorded as a kept local UX decision rather than a standards requirement), and one severity correction to a judge finding (J-PLAN-01's dangling-IDREF defect is real but sits at the linter tier, not the specification-conformance tier, because no live W3C ACT rule requires an existing `tab`'s `aria-controls` target to resolve). The research pass could not obtain a directly quotable, untruncated citation for the `hidden` attribute's accessibility-tree and focus-exclusion behavior; that claim is treated as well-established practice and is independently checked empirically by this plan's own browser-validation keyboard pass, not asserted as citation-verified.

**A material proportionality finding, recorded so QA is not surprised.** Design review grepped all 78 production content files under `lizbeth_spanish/content-source/` (26 beginner, 26 intermediate, 26 advanced) for `kind: 'register'` and found exactly one occurrence in the entire catalog: `beginnerWeek01.ts:98`, `{ kind: 'register', label: 'tú / usted / voseo' }` — a 19-character label, not the prose-length body text E.3's drawn register-note implies. Two consequences bind implementation: size the callout's typography and padding for short-tag-length content rather than paragraph-length content, and expect the treatment to be reachable on roughly one week of the shipped catalog, so its rarity in manual testing is expected rather than a defect. This also means the register-callout work item carries real infrastructure cost for a currently very thin surface, recorded transparently rather than smoothed away.

## Open decisions requiring resolution before dependent items are dispatched

Each open decision below was originally a no-dispatch gate on its named item, mirroring the umbrella plan's decision-register convention. **Update on plan revision:** the user has since resolved D4-1, D4-2, D4-3, and D4-7 (see the Status column). D4-4, D4-5, and D4-6 remain open, non-blocking, and unresolved by this plan; it records them precisely enough to be resolved without re-litigating the underlying evidence.

| ID | Decision | Owner | Blocks | Status |
|---|---|---|---|---|
| D4-1 | The D-2 full-parity placement: whether self-check/Quiz stay in the Lesson panel and `IpNotice` moves to the Files panel, as the design cycle recommends, or some other placement. This is a net-new mobile decision, not a DS placement, because the DS artboard places neither element on E.3 at all. | User or product (whoever owns umbrella-plan decision D-2) | Formerly items 5, 6 (no-dispatch gate now satisfied and lifted) | **RESOLVED — approved as recommended, 2026-09-05.** Self-check and Quiz stay in the Lesson panel unchanged; `IpNotice` moves to the Files panel as its last item, per design handoff (d) and (e). |
| D4-2 | Copy sign-off: the eyebrow's Spanish-versus-English form, the three tab labels, Next's locked reason wording, and the "Mark complete" label. All current text is placeholder. | User or product | Closure of item 10 (final acceptance of items 4, 6, 8 copy); no longer a dispatch gate on items 4, 6, or 8 | **RESOLVED — build against placeholder, sign-off gates closure, 2026-09-05.** Structural work on items 4, 6, and 8 may proceed against current placeholder copy. Final acceptance of those three items' user-facing strings still requires actual copy sign-off before item 10 may close the phase. |
| D4-3 | Next's terminal-week treatment: a permanently disabled Next at the final week, versus omitting it entirely. No existing precedent in this app. | User or product | Formerly item 8 (no-dispatch gate now satisfied and lifted) | **RESOLVED — omit entirely at terminal week (opposite of the plan's stated recommendation; explicit user override, recorded 2026-09-05).** Next has two states, enabled and disabled-locked; at the terminal week it does not render at all. See design handoff (f), item 8's gate, and Journey J6. |
| D4-4 | Back-link ownership: whether the E.3 header treatment moves the back link into `WeekDetailPage` or restyles the existing `App.tsx` element in place. | Engineering (informational, not blocking) | Item 4 (must be recorded as a decision, not left to drift) | **RESOLVED — moved into `WeekDetailPage`, 2026-09-05.** `WeekDetailPage` has exactly one caller (`App.tsx`, single call site); the back link was already 1:1 coupled to the page's render lifetime; `navigate` is a plain module-level export requiring no prop threading; and E.3's header bar structurally requires data (`weekNumber`, lesson count) that only `WeekDetailPage` has — restyling the button in place at `App.tsx` could not have produced the header row at all. |
| D4-5 | The ARIA-architecture alternative: `aria-current` nav-link semantics instead of the viewport-conditional tablist/radiogroup switch. Rejected on the grounds that `aria-current` indicates current location within a persistent structure rather than switching among mutually exclusive panels, but recorded as genuinely close, not fully foreclosed. | Design reviewer or user (not blocking; flag for sign-off if the trade-off matters to a stakeholder) | None | Open, non-blocking |
| D4-6 | DTCG alias confirmation: whether `color.badgeTint.register` and `color.badgeTint.disabled` share one primitive alias at the source tier. The semantic names stay distinct regardless. | Engineering (not blocking) | None | Open, non-blocking |
| D4-7 (added on plan revision, per J-PLAN-01) | Is the `SegmentLedger`/`LessonContentView` dangling-IDREF fix (inactive tabs' `aria-controls` referencing tabpanel IDs absent from the DOM) in scope for Phase 4, or its own bounded job? This plan's original recommendation was its own bounded job, filed as a GitHub issue and sequenced independently, because fixing it changes desktop DOM structure or requires editing an existing passing test (`LessonContentView.test.tsx:51`), both forbidden by this phase's charter, and because the defect is linter-tier rather than a specification-conformance violation, so it was not judged urgent enough to justify widening Phase 4. | User | New item 3.5 (fix now, within Phase 4); a GitHub issue is also filed per the umbrella plan's logging policy, documenting the original defect and its fix commit for the historical record, even though it is closed within this phase rather than deferred | **RESOLVED — fix now within Phase 4 in addition to filing the issue (explicit user override of the plan's deferral recommendation, recorded 2026-09-05).** This is a genuine, deliberate scope expansion, not something the plan always intended. See ordered-work item 3.5, the updated "Out of scope / no-touch" exception, and J-PLAN-01's updated disposition above. |
| D4-8 (added on plan revision, found during item 9) | Design handoff (i)'s scrollable region is not fully realized. The mobile flex column and non-sticky footer now hold (item 9), but no `overflow-y: auto`/`flex: 1 1 auto` scroll region exists: the title block and tab row sit outside any scroll container, and `.week-detail-header` remains a sibling of `.week-detail-sheet` rather than a child of the flex column (item 4 deliberately fixed the header in place for desktop non-regression). Fully realizing the scrollable region would require either moving the header inside the column, or a global `App.css` height-chain change — `.app` is `min-height: 100vh` with no bounding height, so `overflow-y: auto` could never actually activate without one — which is outside this plan's stated no-touch boundary (`App.css` is explicitly out of scope). | User or engineering lead | Item 10's full-parity verification and rendered-capture comparison, since the mobile page currently cannot internally scroll if content exceeds the viewport height; record whether this is acceptable for this phase's closure or must be resolved first | Open |
| D4-9 (added on plan revision, found during item 9) | Forced-colors mode: `Control.css`'s `box-shadow: none` override for `.control--primary` under `@media (forced-colors: active)` is specificity (0,1,0); the compact footer shadow rules (item 9) are (0,4,0)/(0,5,0) and outrank it, so both footer buttons' shadows still paint under forced colors, contrary to the app-wide forced-colors convention established elsewhere in this migration (for example, design handoff (g)'s tab forced-colors override). Confirmed pre-existing since item 7, not introduced by item 9's consolidation. | User or engineering lead | Nothing structurally, but should be resolved or explicitly deferred before item 10 closes the phase, since it is a real accessibility-mode inconsistency on a newly-built surface | Open |
| — | Carried forward, not resolved here: umbrella-plan decision D-6, the broader `--border-width-accent` permitted-context documentation gap. This plan does not use that token, so it neither resolves nor depends on D-6. | Umbrella plan | N/A | Carried forward |

## Engineering mode and ownership

- Engineering mode: standard.
- Team authorization: not applicable.
- Downstream owner: the engineering fleet — T1 first-line, escalating to T2 on two counted gate failures per item, with Verifier and Browser Validator as independent gates. No writer may self-approve completion.

## Closure summary

This phase is complete. It closed on 2026-09-06.

**Final `main` SHA after all Phase 4 work:** `2bb5a27f77b1ada1209608da73c92037ad3b2151`.

**Merged PRs, in order:**

| PR | Ordered-work item(s) covered |
|---|---|
| #109 | Items 1-2 |
| #111 | Items 3-3.5 |
| #112 | Item 4 |
| #113 | Item 5 |
| #114 | Item 6 |
| #115 | Item 7 |
| #116 | Item 8 |
| #117 | Item 9 |
| #118 | Item 10 (non-browser portion) plus D4-9 |
| #119 | D4-2 eyebrow copy |

**A genuinely dormant test-infrastructure bug found and fixed during item 10.** `cssCascade.ts` silently corrupted and dropped multi-line selectors from cascade resolution. This bug was confirmed to have never actually caused a false pass anywhere in this codebase's history, but it was fixed during item 10 as a forward safeguard against a future false pass it could otherwise have produced.

**Three real defects item 9 found in already-shipped items 7 and 8**, recorded in item 9's implementation note above: the press-feedback specificity tie between item 7's inline Mark-complete rule and canonical `.control--primary`, the inert `flex-shrink: 0` declaration on a non-flex footer container, and the resulting margin-collapse regression on the title block. Each of these was independently confirmed by a Verifier pass that did not merely trust the writer's own testing — a concrete demonstration of why this plan's multi-layer verification discipline (independent Verifier passes per item, judge review of the plan, and browser validation at closure) mattered: all three defects had already passed source-level and declaration-level gates in the items that introduced them, and surfaced only because later independent verification did not stop at the writer's own claim of correctness.

**One item found out of this plan's scope, left untouched.** During D4-2's copy-sign-off closure, an unrelated "Semana" placeholder eyebrow was found on `WeekCard.tsx`, a different component belonging to `RoadmapPage`, not the week-detail route this phase covers. It was correctly left untouched as out of scope for this plan. It is flagged here as a candidate for its own small follow-up if the user wants full-app copy consistency; this document does not authorize or schedule that follow-up.

**Relationship to the umbrella plan.** This document closes Phase 4 of the umbrella plan, `docs/plans/lizbeth-spanish-fjds-full-app-conformance-closure.md`. The umbrella plan's own closure inventory — the remaining `Field Journal DS` milestone issues #42, #74, and #102, and the eventual Phase 6 flip of the token-deprecation lint from advisory to build-breaking — is unaffected by this document's closure and remains tracked in the umbrella plan, not here.

## Approval

This plan recommends work. It does not grant authority, add scope, approve dependencies, or replace explicit user approval. It requires explicit user approval before item 1 (or any later item) is dispatched to T1, and it requires the specific open decisions above to be resolved before their named dependent items are dispatched, even after overall plan approval.

**Approval record:** The user explicitly approved this plan in full, in the interactive orchestrator session, on 2026-09-05, stating "approved proceed as planned." The approval covers the entire document as revised, including all four resolved open decisions (D4-1, D4-2, D4-3, D4-7) exactly as recorded in the "Open decisions" table above. This approval authorizes dispatch of ordered-work item 1 onward, subject to each item's own no-dispatch gates; those four decisions' no-dispatch gates are now satisfied per their resolutions above.

Across the session, the user separately approved: the judge-remediation revision to this plan; decisions D4-1, D4-2, and D4-3 in a walkthrough; and D4-7's explicit scope override authorizing ordered-work item 3.5. All nine open decisions (D4-1 through D4-9) are now resolved, as recorded in "Status" above and the "Open decisions" table. This phase is closed as of 2026-09-06; see "Closure summary" above for the final `main` state and the merged-PR sequence.
