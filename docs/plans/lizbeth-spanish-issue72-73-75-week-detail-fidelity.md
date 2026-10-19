# Lizbeth Spanish, Issues #72/#73/#75: Week-detail large-numeral motif, attachments staple mark, capture-limitation investigation

**Status: APPROVED.** Approved by the user via direct reply "yes proceed as planned" on 2026-09-02, in this session, in direct response to the orchestrator presenting this plan's compact summary (together with the sibling #71 header plan) and its three explicit decisions. T1/T2 engineering work may now begin under the ordered work section below.

**Approval record.**

- Approved by: the user (rob.hasselbach@gmail.com), verbatim reply "yes proceed as planned".
- Scope of approval: this plan (`lizbeth-spanish-issue72-73-75-week-detail-fidelity.md`) only, presented alongside the sibling #71 header plan in the same summary.
- Decisions resolved at approval:
  - Decision 1 (new `--typography-role-display-lg-*` token group): approved, per the plan's own recommendation.
  - Decision 2 (watermark retire vs. coexist): resolved as RETIRE — the existing issue #39 low-contrast watermark (`.week-detail-reading-sheet-numeral`) is removed rather than coexisting with the new 96px numeral, per the plan's own recommendation and the user's explicit confirmation.
  - Decision 3 (issue #73 row-level flattening, approval-time acknowledgement): acknowledged as out of scope — the frame fix uses the reference's actual staple-mark decoration (corrected during design review from an earlier tape-based misread), and row-flattening remains blocked by the locked tests identified in the plan (`fjdsAuthenticatedScreensRemediation.test.ts:221-226` and :606-612), deferred to its own future ticket.
  - Issue #75 disposition: confirmed as approved — close #75 as resolved (item (a) already tracked under issue #38's recorded decision), and file one new, properly scoped issue for the genuinely new E.3 mobile week-detail findings (lesson-title heading, "03/26" progress indicator, register-note callout, sticky bottom action bar), per ordered-work step 7.
- Related, separately resolved: issue #74's SRS mode is out of scope for this plan and was already resolved separately; it is not part of this plan's scope or approval.

---

Plan ID: `lizbeth-spanish-issue72-73-75-week-detail-fidelity`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: `engineering-fleet` (after explicit user approval)
Design route: compact (`design-generalist`, `design-reviewer`; prototype forbidden; model tier Sonnet; existing-system mode: preserve)

## Outcome

Closes GitHub issues #72 (week-detail large-numeral motif), #73 (attachments enclosing frame), and #75 (capture-limitation uncertainties) against Field Journal reference artboards D.3 and E.3. The audience is students on the week-detail screen.

Observable result: the `WeekDetailPage` heading gains an adjacent large decorative week numeral matching the reference typography, the attachments rail card gains a single staple corner mark, and issue #75's two named gaps are formally dispositioned — one recorded as already tracked under a prior decision, the other filed as a new, separately scoped issue.

## Scope

**In scope:**

- The inline week numeral beside the `WeekDetailPage` `<h1>`.
- The staple corner mark on the attachments rail card.
- The #75 investigation disposition with its follow-up issue filing.

**Non-goals, explicitly declared:**

- No change to `.resources-panel` or `.resources-panel-row` treatments.
- No change to routing, data, or `ResourcesPanel` behaviour.
- No work on the E.3 mobile gaps beyond filing them as a new issue.

## Repository findings

Verified by the nested Researcher and the compact design route (generalist plus reviewer), independently confirmed by design review:

- The heading is `<h1>Week {weekNumber}</h1>` at `WeekDetailPage.tsx:274`, inside `div.week-detail-page`, rendered for EVERY `ViewState` (loading, error, not-available, locked, empty, available) — outside the available-only grid.
- A different numeral already exists: `.week-detail-reading-sheet-numeral` (`WeekDetailPage.tsx:335-337`, CSS at `WeekDetailPage.css:127-150`) — a faint `--color-paper-300` watermark, `position:absolute` inside the reading sheet, `z-index 0`, `aria-hidden`, `display:none` below 56.24rem, rendering only in the available state. Introduced by issue #39.
- `.week-card-number` (`WeekCard.css:43-55`) is the established typographic pattern: display-sm family/weight/size with `calc(... * var(--text-size-multiplier, 1))` on font-size, plus `line-height:.8` and `letter-spacing:-.04em`, colour `--color-ink-1000`; dimmed to `--color-ink-700` in the locked state at `WeekCard.css:162-164`. `WeekCard.tsx:135` renders `{week.week_number}` unpadded.
- CORRECTION to the filed premise of issue #73: the enclosing frame ALREADY EXISTS. `.week-detail-rail-card` (`WeekDetailPage.css:163-170`) is `background-color --color-paper-200`, `border var(--border-width-rule, 3px) solid var(--color-ink-1000)`, `box-shadow var(--shadow-brass)`, `padding var(--space-6)`, wrapping the "Attached to this week" h2, the `ResourcesPanel`, and the `IpNotice` (`WeekDetailPage.tsx:373-391`), with a forced-colors override at `WeekDetailPage.css:178-183`. The only genuine remaining delta is the corner mark.
- No ancestor clips the mark: `.week-detail-rail-card` declares no `overflow`, and none of `.week-detail-rail`, `.week-detail-grid`, `.week-detail-page`, or `.app-main` sets `overflow:hidden`. The only `overflow:hidden` in `App.css` is on the unrelated `.app-header-tools`.
- Locked treatments that must not be reversed by this work: `fjdsAuthenticatedScreensRemediation.test.ts:221-226` locks `.resources-panel-row` to `border: var(--border-width-thin) solid var(--color-ink-1000)`; lines 606-612 lock `.resources-panel` to `border: var(--border-width-rule) solid var(--color-brass-500)` plus `box-shadow: var(--shadow-print)`.
- `weekDetailReadingSheetCss.test.ts:85-90` asserts `.week-detail-reading-sheet-numeral` exists and is `display:none` inside the `@media (max-width: 56.24rem)` block. `weekDetailReadingSheetCss.test.ts:48-50` asserts no CSS `order` property appears anywhere in that file.
- `journalDevicesRemovalTest.test.tsx:456-475` locks only `.journal-tape`'s `border-left` and `border-right` (dashed, brass-700, with color-mix fallbacks) and the absence of a bare/solid border or `border-top`/`border-bottom`; line 453's `ruleBody()` is an extraction helper, not an assertion. Nothing pins position, top, left, transform, width, height, or background. `journalDevicesRemovalTest.test.tsx:83-110` covers `.journal-staple`'s removal test; :604-609 asserts a CLOSED SET of exactly three forced-colors selectors — `.journal-index-card-trim`, `.journal-dot-matrix`, and `.journal-empty-state` — with neither Tape nor Staple in that set.
- The token pipeline is genuinely source-driven: `.atelier/tokens/field-workbook.tokens.json` is the DTCG source; `scripts/verify-token-pipeline.mjs` is the oracle that diffs `src/tokens/field-workbook.generated.css` against a compiled snapshot at `.atelier/tokens/field-workbook.css`; the generated CSS must never be hand-edited out of step with that snapshot. A new `typography.role.displayLg` DTCG entry flattens to `--typography-role-display-lg-*`.
- A same-class breakpoint token swap is an established precedent: `RoadmapPage.css:33-48` swaps `--font-size-roadmap-h1-sm` and `--font-size-roadmap-h1-lg` at min-width 56.25rem.

**Research evidence.** None — this is a local fidelity gap against in-repo reference artboards and locked tests; no external research question was involved.

## Reviewed design handoff

```
DESIGN_ROUTE
profile: compact
agents_required: design-generalist, design-reviewer
prototype: forbidden
model_tier: sonnet
existing_system_mode: preserve
END_DESIGN_ROUTE
```

**Design review status: PASSED**, on revision 1. Revision 1 corrected two HIGH findings — an inverted sizing premise, and the wrong decorative device — plus one MEDIUM overstatement of a test lock. The reviewer independently verified the corrected position arithmetic and the token-pipeline mechanism.

### Issue #72 — numeral

Field Journal `DS.dc.html:791-792` specifies the D.3 numeral literally as `font-family: Fraunces, serif; font-weight: 900; font-size: 96px; line-height: .8; letter-spacing: -.05em; color: #1a1512`, inside a `display:flex; align-items:baseline; gap:20px` container immediately before the `<h1>`. The filed issue's approximately 96px estimate was CORRECT. No existing token serves 96px: `--typography-role-display-sm-font-size` is 52px (`field-workbook.generated.css:164`), belonging to `.week-card-number` and the issue #39 watermark — itself an already-shipped, never-disclosed departure from this mockup. (Issue #39's plan at `docs/plans/lizbeth-spanish-issue39-week-detail-reading-sheet-attachments-rail.md` lines 212 and 270 disclosed only a coincidentally-identical 96px delta about the reading sheet's LEFT-PADDING GUTTER, 96px -> 81px — an unrelated property.)

**Resolution:** add a new `--typography-role-display-lg-*` token group (96px / 6rem, weight 900, Fraunces, line-height .8, letter-spacing -.05em) extending the same `typography.role.display` family that `.week-card-number` already established under issues #32 and #36. It must be added through the DTCG source and compiled via the token pipeline, never hand-edited into the generated CSS. Applied at >=56.24rem with the same `calc(... * var(--text-size-multiplier, 1))` accessibility-scaling pattern `.week-card-number` already uses. Below 56.24rem the same class switches, via a component-scoped media query, to the already-existing `--typography-role-display-sm-*` (52px) token — no new mobile-only token. That narrow-width fallback is a DISCLOSED, DELIBERATE departure from literal fidelity, justified because the mockup is a 1440-only artboard with no mobile numeral spec, because a 96px weight-900 numeral is roughly twice the glyph width of 52px and risks dominating or wrapping awkwardly at 390px, and because 52px is already shipped and accessible on this exact page family.

**Markup:** a new `<div className="week-detail-heading-row">` wraps the untouched `<h1>` plus a new `<span className="week-detail-heading-numeral" aria-hidden="true">`, matching the mockup's own flex structure: `display:flex; align-items:baseline; gap: var(--space-4, 1rem); flex-wrap:wrap`. The mockup's literal `gap:20px` maps to `--space-4` as a minor, permitted token-rounding. If content ever exceeds the row's width the numeral — the first DOM child, matching mockup order — wraps onto its own line above "Week N". No CSS `order` property is used, honouring the existing invariant at `weekDetailReadingSheetCss.test.ts:48-50`, so DOM and visual order stay identical.

**Digits:** zero-padded to two via `String(weekNumber).padStart(2, '0')`, matching the mockup's literal "03" and the retired watermark's own formatting. This deliberately diverges from `.week-card-number`'s unpadded `{week.week_number}` at `WeekCard.tsx:135`, which is a different consumer's own reviewed choice; only the typographic shape is reused, not the digit formatting.

**Colour and states:** `--color-ink-1000` (`#1a1512`), matching the mockup literal, in every `ViewState` except locked, which dims to `--color-ink-700` mirroring `WeekCard.css:162-164`. At both 96px and 52px at weight 900 the numeral qualifies as large text (>=24px bold, 3:1 floor) and clears WCAG AA with wide margin in every state including the dimmed locked variant; the ink-1000-on-paper pairing is already verified in-repo by `fjdsAuthenticatedScreensRemediation.test.ts` (ink-1000 `#1a1512` on paper-100 `#faf8f4` clearing AA normal-text). The numeral renders in ALL SIX `ViewState`s, not conditionally only in available, since the heading row sits outside the available-only grid. Locked dimming must be driven by the render site's existing `state.kind === 'locked'` branch, not a new global selector reaching into unrelated markup.

**Accessibility:** the h1's accessible name stays exactly "Week {weekNumber}". The numeral is an `aria-hidden`, non-focusable, role-less sibling INSIDE the new wrapping div, never nested inside the h1. WCAG 1.4.3's decorative-text exemption applies exactly as it did for the watermark being replaced. The heading row wrapper must not change the h1's tag, its text content, or its status as the page's sole h1.

**Watermark:** retire `.week-detail-reading-sheet-numeral` and its TSX span (`WeekDetailPage.tsx:335-337`, `WeekDetailPage.css:132-150`) — an explicit reversal of the issue #39 decision. See decision 2.

### Issue #73 — staple, not tape

Field Journal `DS.dc.html:860-862` shows the attachments-rail card containing exactly two `rotate(-32deg)`, 26x5px, `#504940` bars anchored at the TOP-LEFT corner only, at `top:12px/left:12px` and `top:24px/left:14px`. That is the Staple device — catalog lines 228-236: "02 · Staple... Two ink.700 bars at -32deg, top-left corner. Marks a stack: a lesson with attached resources, a multi-card set" — which is precisely the semantic content of this rail. Tape (catalog lines 218-225) renders everywhere in that file as a SINGLE top-center mark at one rotation, matching its sole existing consumer at `WeekCard.tsx:128`. No two-opposite-corner tape composition appears anywhere in D.3 or the device catalog; the earlier tape-based proposal was a misread and is withdrawn.

**Resolution:** one `.journal-staple` instance as the first child of the existing `.week-detail-rail-card` div, before its h2, positioned by the card's pre-existing `position:relative`, with a component-scoped compound-selector override in `WeekDetailPage.css`:

```css
.journal-staple.week-detail-rail-staple { top: 12px; left: 12px; z-index: 1; }
```

A compound selector is used deliberately so the override does not depend on bundling or import order. Rotation (-32deg), size (26x5px), and colour are inherited unmodified. `--color-ink-700` resolves to `#504940` (`field-workbook.generated.css:57`), an EXACT match to the mockup's literal staple colour, so zero colour change is required. The device's own `::after` already paints the second bar, so ONE consumer instance reproduces the mockup's two-bar mark.

**Position arithmetic, independently verified:** `.journal-staple` carries `position:absolute` and therefore establishes the containing block for its own `::after`, which sits at `top:12px/left:2px` relative to the parent; overriding only the parent to `top:12px/left:12px` shifts the two-bar unit rigidly, landing bar 1 at (12,12) and bar 2 at (24,14) — an exact match to the mockup's pair. The offsets do not compound incorrectly.

The base rule `.journal-staple` (`journal-devices.css:44-54`, including its `::after` at 55-64) must NOT be edited; only a component-scoped compound override may reposition it. No forced-colors override is added for this instance: `journalDevicesRemovalTest.test.tsx:604-609` locks the forced-colors carve-out as a closed set of exactly three selectors, and Staple — like Tape, and like Tape's existing `WeekCard` consumer — is deliberately outside it. This new instance inherits that same already-reviewed exclusion. No motion; reduced-motion is not implicated. The mark is `aria-hidden`, non-focusable, and contributes zero layout.

**Out of scope, explicitly:** `.resources-panel` and `.resources-panel-row` keep their current treatments. The filed issue's row-flattening premise is real — there is genuine three-layer nested bordering, rail-card -> resources-panel -> resources-panel-row — but both inner layers are locked, tested, prior-reviewed decisions (`fjdsAuthenticatedScreensRemediation.test.ts:221-226` and :606-612). Reversing them needs its own authorized ticket. See decision 3.

**Permitted variation:** the implementer may substitute `--space-3` for `--space-4` in the heading-row gap if Fraunces glyph metrics at 96px read too wide beside the h1, and may adjust the staple override's exact px offset by +/-4px for pixel registration provided it stays visually anchored to the card's top-left corner. No other numeral property (family, weight, size formula, line-height, letter-spacing, `padStart`, breakpoint fallback) and no staple property (rotation, size, colour) may vary without a new design pass.

**No dialog:** neither change introduces any dialog-like affordance; both are purely decorative markup and CSS with zero interactivity.

### Issue #75 — investigation resolved (planner-verified, no design or engineering work required beyond the issue hygiene below)

**(a) D.2's right-side band-switcher rail — ALREADY TRACKED, NOT NEW.** `RoadmapPage.css` lines 50-52 carries an explicit in-code decision: "Issue #38 (Phase 2): the band jump-list. A single wrapping flex chip row at every breakpoint -- the artboard's fixed @1440 rail / @390 bottom tab bar are both deliberately declined (plan section 4)." This is the same item, already a recorded and reviewed decision.

**(b) E.3's Lesson/Cards/Files segmented tabs and vocabulary-preview card — GENUINELY NEW**, and the gap is materially larger than #75 as filed. Field Journal `DS.dc.html:1399-1403` shows three segmented pills (Lesson selected on ink-1000, Cards and Files unselected on `#faf8f4` with 2px ink-1000 borders, all min-height 40px), and lines 1407-1414 show a "Vocabulario · 04 fichas" preview card with three dotted-rule term/gloss rows. Neither exists anywhere in the code: `WeekDetailPage.tsx` and `WeekDetailPage.css` contain no segmented-tab markup or CSS, and `vocabulary_review` appears only as a `RESOURCE_LABEL` entry at `ResourcesPanel.tsx:19`, never as a preview card. The same E.3 artboard additionally shows four further genuinely-new elements the filed issue did not mention: a "Semana 03 · Beginner" eyebrow (line 1395); an h1 that is the LESSON TITLE ("Family and Describing People," 36px Fraunces, line 1396) rather than the live app's "Week N"; a "03 / 26" progress indicator in the back-bar (line 1390); a terracotta-bordered "Register note" callout (lines 1416-1419) with a Caveat handwritten annotation (line 1420); and a sticky bottom action bar with "Mark complete" and "Next" buttons (lines 1423-1426).

**Disposition:** comment on and close #75, recording (a) as already tracked under issue #38's recorded decision and (b) as genuinely new, and file ONE new tracked issue for the E.3 mobile week-detail gap enumerating all six elements above. That new issue is NOT in this plan's scope — it is a Standard-design-route candidate in its own right, since it changes the mobile week-detail information architecture and the h1's very content.

**Note for decision 2:** E.3 shows NO large numeral at all on mobile — the mobile h1 is the lesson title. This independently supports the numeral's mobile size fallback above, and also flags that "Week N" as the h1 is itself a divergence from the reference, to be handled by the new E.3 issue rather than here.

## Interfaces and data

None. No data, service, or contract change. One new DTCG token group only.

## Ordered work

Owner for every step: T1 first-line, escalate to T2 on two counted gate failures.

1. Add the `typography.role.displayLg` group to `.atelier/tokens/field-workbook.tokens.json`, recompile through the token pipeline, and verify with `scripts/verify-token-pipeline.mjs`. Never hand-edit `src/tokens/field-workbook.generated.css`.
2. Add the `.week-detail-heading-row` wrapper and the `.week-detail-heading-numeral` span in `WeekDetailPage.tsx` around the existing untouched h1 at line 274, with `padStart(2,'0')` and `aria-hidden`.
3. Add the numeral CSS in `WeekDetailPage.css` with the display-lg / display-sm breakpoint swap at 56.24rem, the `text-size-multiplier` calc, and the locked-state ink-700 override driven by the existing `state.kind === 'locked'` branch.
4. Per decision 2, retire the `.week-detail-reading-sheet-numeral` span (`WeekDetailPage.tsx:335-337`) and its CSS block (`WeekDetailPage.css:132-150`), and delete or repoint the assertion at `weekDetailReadingSheetCss.test.ts:85-90`.
5. Add the single `.journal-staple week-detail-rail-staple` span as the first child of `.week-detail-rail-card`, plus the compound-selector override in `WeekDetailPage.css`.
6. Update and extend tests.
7. Issue hygiene: comment on and close #72, #73, and #75; file the new E.3 mobile week-detail issue.

## Acceptance and validation

- Full suite green with the single named exception at `weekDetailReadingSheetCss.test.ts:85-90` (only if decision 2 selects retirement) — any other failure is a real regression.
- Explicitly re-run `weekDetailReadingSheetCss.test.ts`, `weekDetailReadingSheetLayout.test.tsx`, `WeekDetailPage.test.tsx`, `ResourcesPanel.test.tsx`, `journalDevicesRemovalTest.test.tsx`, and `fjdsAuthenticatedScreensRemediation.test.ts`.
- Token pipeline verification must pass.
- `tsc --noEmit` clean.
- Independent Verifier pass, then a Browser Validator pass. Neither T1 nor T2 may self-approve completion.

## Browser UI dialog policy

REQUIRED. A deterministic no-native-dialog scan must confirm no `alert`, `confirm`, `prompt`, `window.*` variant, or `beforeunload` appears anywhere on this page as a side effect of either change.

## Browser UI validation

**Launch/readiness:** existing Vite dev server; base URL `http://localhost:5173`; dev quick-select login; browser tooling confirmed working with tab reuse.

**Viewports:** 1440x900 and 390x844, both required for every check.

**Numeral, all six ViewStates at both viewports:** renders beside "Week N" at the correct colour (ink-1000 in five states, ink-700 only in locked) and the correct size (96px display-lg at 1440, the 52px display-sm fallback at 390); no duplicate accessible numeral text is exposed, with the numeral `aria-hidden` and the h1's accessible name reading only "Week N" under axe or screen-reader inspection; the retired watermark is absent from the DOM in the available state at 1440 (or, under the coexistence fallback, both numerals render without visual collision at the corrected sizes); at 390 the heading row wraps cleanly for a two-digit-or-longer week number — the week-27 fixture at `WeekDetailPage.test.tsx:417,424` — with no horizontal scroll or clipping, and the validation must record which element sits on which line if wrapping occurs.

**Staple, available state only, both viewports:** exactly one `.journal-staple` instance inside `.week-detail-rail-card`, anchored at the visual top-left corner matching the mockup's `top:12px/left:12px` intent, rendering two ink-700 bars at -32deg via the shared device's own `::after`, `aria-hidden`, and overlapping neither the "Attached to this week" h2 text nor the first resource row's Control button; the mark stays visible and correctly anchored after the rail collapses to block flow at 390. A forced-colors pass confirms the rail card's border still renders as `ButtonText` per the existing override at `WeekDetailPage.css:178-183`, and that the staple's deliberate absence of a forced-colors rule — consistent with its existing `WeekCard` consumer — hides no pointer- or keyboard-reachable content.

**Fixtures:** no fabricated data; all resource names and labels remain live data, untouched by this work.

## Risks and rollback

LOW-MEDIUM. The only system-level change is one additive DTCG token group; everything else is scoped markup and CSS on a single page.

| Risk | Mitigation |
|------|------------|
| The token pipeline diff failing if the generated CSS is hand-edited instead of recompiled | `scripts/verify-token-pipeline.mjs` is a hard gate in ordered-work step 1 |
| Reversing issue #39's watermark decision without the user's explicit sign-off | Decision 2 below is an approval-time gate |
| The staple override colliding with the shared device rule | The compound selector, and leaving `journal-devices.css` untouched |

**Rollback.** Each ordered step is independently revertable.

## Assumptions and decisions requiring user approval

**Decision 1 — the new `--typography-role-display-lg-*` token group. RESOLVED: APPROVED.** This is a genuine token-system addition, not pure reuse. Resolved by the user's "yes proceed as planned" reply, accepting the plan's recommendation that no existing token serves the mockup's literal 96px and that the addition extends an existing family rather than inventing an unrelated value.

**Decision 2 — retire the issue #39 watermark, or let both numerals coexist. RESOLVED: RETIRE.** D.3 shows exactly one numeral device and a second faint background numeral reads as an unintentional leftover. This is an explicit reversal of a prior reviewed decision and requires deleting or repointing `weekDetailReadingSheetCss.test.ts:85-90`. IMPORTANT QUALIFICATION carried from the design review: the retire recommendation originally rested on the premise that both numerals were the same 52px size, which this work has now shown was never checked against the mockup. The user's approval confirms RETIRE with that qualification on record: the surviving inline numeral uses the corrected 96px / 52px-fallback sizing, and the coexistence alternative is no longer live.

**Decision 3 (approval-time acknowledgement) — issue #73's row-level flattening is deliberately OUT OF SCOPE here. ACKNOWLEDGED.** The premise is real but both inner layers are locked, tested, prior-reviewed decisions. If the literal D.3 row treatment is still wanted, it needs its own ticket that explicitly authorizes reversing `fjdsAuthenticatedScreensRemediation.test.ts:221-226` and :606-612.

**Open, non-blocking (does not require approval before implementation, may be resolved during build):** whether the mockup's literal `gap:20px` mapping to `--space-4` is acceptable rounding.

## Required approvals

This plan is APPROVED. The user explicitly resolved decisions 1 and 2 above by replying "yes proceed as planned" to the orchestrator's presented summary, and acknowledged decision 3 as stated. T1/T2 engineering work may proceed under the ordered work section. No standing authorization was invoked; this was the plan's first presentation to the user.
