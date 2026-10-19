# Lizbeth Spanish — E.4: Mobile Flashcards Full-Screen SRS-Style Review Mode

## Status

**CLOSED — complete, 2026-09-07.**

All seven ordered-work items are delivered, independently verified, and merged to `main`. Browser validation passed (`BROWSER_PASS`) across all 14 journeys. GitHub issue #74 is closed. Two genuine defects that only real-browser validation caught were found and fixed during execution (an overlay viewport-coverage failure on the forward-navigation path, and a three-part focus-restoration failure on all three close paths); both are now guarded by dedicated Playwright regression tests. Open decisions OD-1 through OD-4 are resolved; OD-5 remains open and non-blocking, not authorized by this plan. See "Execution record" below for the full account, including the process corrections independent review required during execution.

- **Approver:** the user (rob.hasselbach@gmail.com / lebobo88).
- **Approval date:** 2026-09-06.
- **Basis:** the user explicitly approved this plan in full, in the interactive orchestrator session, in the user's own words: "approved". This followed the user's review of a compact summary covering: the full-screen overlay architecture decision (an app-owned, opaque, full-viewport overlay lifted out of the tabpanel, holding the existing `FlashcardsViewer` unchanged); the shared-`FlashcardsViewer`-call-site resolution (the desktop attachments-rail and mobile Cards-tab paths share call site 1, requiring the plan to be explicit per call site rather than treating the component as single-purpose); the `PLAN_DUCK` remediation covering J-001 through J-005 (native-`<dialog>`/portal-inert alternatives evaluated and rejected for cause, an open-overlay DOM-state test added, an opaque overlay background specified, the "Ficha vs Card" citation corrected, and the E.4 harness-path finding rebutted on evidence); and the qualified design-review status, with no formal PASS recorded across either review cycle and both residual findings — the background-inertness disclosed gap (F1) and the footer previous-sibling-assertion gap (F2) — explicitly decided by the user rather than closed by a further review cycle.
- **Open-decisions copy sign-off:** the user approved the recommended defaults verbatim: "recommendations are good, proceed as planned." See the resolved "Open decisions" table below.
- **Closure date:** 2026-09-07.
- This authorized dispatch of ordered-work item 1 onward per the ordered work below, subject to each item's own no-dispatch gates. Open decisions OD-1 through OD-4, which gated item 7's closure rather than item 1's dispatch, are now resolved; see below.

- **Governing umbrella plan:** `docs/plans/lizbeth-spanish-fjds-full-app-conformance-closure.md` (APPROVED). Read the umbrella plan first for overall program scope, the no-touch list, the GitHub issue logging policy, and the standing commit/push/PR/merge-to-`main` authorization. This document does not restate that material; it cross-references it and states only what is specific to this closure item.
- **Standing authorization inherited from the umbrella plan:** commit, push, PR, and merge to `main` in the `lizbeth-spanish` repository only, as recorded in the umbrella plan's Scope section. This does not extend to deploys, force-pushes, history rewrites, or branch deletion. **This inheritance does not independently authorize execution of this document** — execution still requires explicit approval of this specific plan file, separate from the umbrella plan's own approval.
- This document is a standalone closure item under the umbrella plan's `Field Journal DS` milestone, addressing GitHub issue #74. It is not a new phase of the E.3 mobile week-detail rebuild (`docs/plans/lizbeth-spanish-fjds-phase4-e3-mobile-week-detail.md`, CLOSED); it is a separate, smaller, dependency-adjacent item that reuses E.3's shipped Cards tab as its launch point.

## Outcome and audience

Closes GitHub issue #74, "Mobile flashcards (E.4) may be missing dedicated full-screen SRS mode," under the `Field Journal DS` milestone. The observable result: below the 900px breakpoint, a student reviewing a week's flashcards gets a dedicated full-viewport review surface conforming to Field Journal DS artboard E.4 — an app-owned overlay with its own top bar and back/close control, holding the existing `FlashcardsViewer` unchanged — launched from the Cards tab that Phase 4 (E.3) already shipped. Desktop (>=900px) behavior is provably unchanged and is a first-class non-regression target, not an afterthought.

Audience: the engineering fleet (T1/T2, Verifier, Browser Validator) executing this plan, and the user approving it. This document is written to stand alone: a reader needs only this file and the umbrella plan it cross-references, not the planning conversation that produced it.

## Scope

### In scope (sub-900px only)

1. A new full-viewport overlay component and its CSS (root, top bar, back/close control, scrollable content wrapper).
2. A `presentation` / `onFlashcardsReady` prop pair on `ResourcesPanel`/`ResourceRowView` turning the mobile Cards-tab flashcards row into the overlay's launcher.
3. `WeekDetailPage` wiring: overlay open state and held deck, lift point, JSX ordering, and a local inertness toggle on its own four sibling elements while the overlay is open.
4. Browser-back close via a same-URL history sentinel.
5. An `App.css` `:focus` override adding `.flashcards-overlay`, plus the matching test extension.
6. Tests and per-surface browser validation for this route.

### Out of scope / no-touch — hard boundaries

A writer must return `JOB_BLOCKED` rather than exceed these:

- **No spaced-repetition scheduling, no self-assessment, no review-outcome semantics of any kind.** The user explicitly resolved that E.4's "Again"/"Got it" become Previous/Next, matching current desktop behavior exactly. This restates an already-binding non-goal at `docs/plans/lizbeth-spanish-issue40-flashcards-screen.md:51`.
- **No data-model change.** `FlashcardRecord` and `src/lib/flashcardsFormat.ts` are untouched. No backend, schema, migration, or RPC change.
- **No swipe gestures** (binding non-goal, `docs/plans/lizbeth-spanish-issue40-flashcards-screen.md:54`).
- **Zero changes to `src/components/FlashcardsViewer.tsx` and `FlashcardsViewer.css`.** This is the load-bearing constraint the whole architecture rests on.
- No change to `src/components/WeekSectionTabs.tsx`.
- No desktop (>=900px) change of any kind.
- No new visual direction; the design language is fixed by the ratified DS.
- `src/tokens/field-workbook.generated.css` is never hand-edited.
- `lizbeth_spanish/atelier.config.json` is never edited (standing directive; the operative config is the orchestrator-root `H:\CommandCenter\orchestrator\atelier.config.json`).
- No commit/push/PR/deploy beyond the umbrella plan's existing standing authorization (commit/push/PR/merge to `main` in `lizbeth-spanish` only; excludes deploys, force-pushes, history rewrites, branch deletion).
- Never `taskkill`; scoped-PID termination only if genuinely required.

## Cross-references

- **Governing umbrella plan:** `docs/plans/lizbeth-spanish-fjds-full-app-conformance-closure.md` (APPROVED). Read it for program scope, the no-touch list, the GitHub issue logging policy, and the standing commit/push/PR/merge authorization, all of which this document inherits rather than restates.
- **Structural precedent:** `docs/plans/lizbeth-spanish-fjds-phase4-e3-mobile-week-detail.md` (CLOSED). This document follows its conventions, section ordering, and evidence discipline, at a much smaller scope, and reuses its shipped Cards-tab launch surface. It is not extended or reopened by this document.
- **Origin plan:** `docs/plans/lizbeth-spanish-issue40-flashcards-screen.md`. Several binding non-goals and decisions (Again/Got-it→Previous/Next semantics; "no swipe gestures"; the "Ficha" vs "Card" resolution; the 48px/3px button geometry) originate there and are carried forward, not reopened, by this document.
- **DS source:** `lizbeth_spanish/design/field-journal/Field Journal DS.dc.html`, lines 1430-1467 (artboard E.4) and lines 524-545 (§C.7, the progress-bar-with-figure rule).
- **Reference harness page:** `H:\CommandCenter\orchestrator\.atelier\reference-harness\field-journal-e4-flashcards-390.html`.
- **Baseline capture:** `H:\CommandCenter\orchestrator\.atelier\baselines\field-journal-e4-flashcards-390.png`.
- **Dimensions manifest:** `H:\CommandCenter\orchestrator\.atelier\reference-harness\manifest.json` (E4 cssContent 390x844, capture 396x850, needsCrop true).
- **GitHub issue #74** and the **`Field Journal DS` milestone**. Treat #74 as open per current planning-time evidence (see Finding 12 below); confirm live via `gh` at execution time, since `gh` was not available on the read-only planning tool surface.

## Repository findings

All findings below were gathered by direct, read-only inspection of the `lizbeth_spanish` repository during planning. No test was executed, no build was run, and no rendered capture was taken during this planning pass — every claim below is an observation of source text unless explicitly marked otherwise. `gh` is not on the read-only planning tool surface, so live GitHub state for issue #74 was NOT read; that is an explicit limit, not an assumption. Where a live read contradicts this document, the live read wins.

### Finding 1 — Two production call sites, and the desktop/mobile path is shared

`FlashcardsViewer` is reached from exactly two places: `src/components/ResourcesPanel.tsx:106` (`state.kind === 'ready-flashcards'`), and `src/pages/WeekDetailPage.tsx:899` (`<FlashcardsViewer cards={[]} />`, the mobile Cards-tab empty state). Call site 1 serves BOTH the desktop attachments rail (`WeekDetailPage.tsx:1018`, passing `attachableResources`) and the mobile Cards tab (`WeekDetailPage.tsx:896-897`, passing `flashcardsResources`). The split is at `WeekDetailPage.tsx:833-841`. This shared path is why the plan must be explicit per call site (see design handoff (b) below).

### Finding 2 — The E.3/E.4 header collision is the crux, and it is real

Phase 4's shipped mobile week-detail header carries "← Roadmap" plus a week-level progress figure "03 / 26" (`WeekDetailPage.tsx:590,640`). E.4's header carries a different back target ("← Week 03", pointing back TO the week) and a card-level counter ("Ficha 02 / 12"). Both cannot occupy the same mobile page header. E.4's back-link target is positive evidence that E.4 is a screen reached FROM the week-detail screen, not a panel within it.

### Finding 3 — An existing full-screen mobile takeover pattern already ships

`src/components/MobileNavPanel.tsx` / `MobileNavPanel.css` (GitHub issue #71): `position: fixed; inset: 0; z-index: 40`, no backdrop, reusing `src/hooks/useFocusTrap.ts` for Tab/Shift+Tab cycling, Escape-to-close and trigger-focus restoration, hidden at `@media (min-width: 56.25rem)`. This is the only existing pattern of its class; the new overlay is its sibling, not a first-of-its-kind invention.

### Finding 4 — No portals exist, which forces the lift point out of the tabpanel

A repository-wide search for `createPortal` in `src/` returns zero results; `MobileNavPanel` is instead rendered at App-shell level. Combined with `WeekSectionTabs.tsx:194-206`'s binding mount-all-panels-with-`hidden` strategy (Phase 4's J-PLAN-02), an overlay rendered inside the Cards tabpanel would be hidden with its ancestor on a tab switch. This forces the lift point out of the tabpanel — verified independently by design review as genuinely escaping the hidden-ancestor problem.

### Finding 5 — E.4 measured values, transcribed directly from the harness (supersede any looser restatement)

Source `H:\CommandCenter\orchestrator\.atelier\reference-harness\field-journal-e4-flashcards-390.html`, extracted from `lizbeth_spanish/design/field-journal/Field Journal DS.dc.html:1430-1467`. Manifest `H:\CommandCenter\orchestrator\.atelier\reference-harness\manifest.json`: E4 cssContent 390x844, capture 396x850, needsCrop true. Baseline `H:\CommandCenter\orchestrator\.atelier\baselines\field-journal-e4-flashcards-390.png`.

- **Frame** (harness line 17): 390x844, background `#f0ebe2` plus the 20px repeating-linear-gradient grid, `border: 3px solid #1a1512`, `box-shadow: 8px 8px 0 0 #1a1512`, `overflow: hidden`, flex column. Artboard chrome, not app UI.
- **Status bar** (line 18): `background #1a1512`, padding `8px 18px`, mono 11px/600/.12em, `#dca250`. Decorative phone bezel — must NOT be implemented, same disposition as E.3's Finding 12.
- **Top bar** (lines 19-22): `background #faf8f4`, `border-bottom: 3px solid #1a1512`, `padding: 10px 18px`, flex, align-items center, justify-content space-between. Back link (line 20): `min-height: 40px`, inline-flex, mono 12px/700/.12em uppercase, `#1a1512`, `text-decoration: none`, "← Week 03". Counter (line 21): mono 11px, letter-spacing `.16em`, uppercase, `#7c6136`, "Ficha 02 / 12" — note weight is NOT declared (inherits 400), unlike the back link's 700.
- **Content region** (line 24): `flex: 1`, `padding: 28px 20px`, flex column.
- **Progress bar** (line 25): `height: 12px`, `border: 2px solid #1a1512`, `background #fdfcf9`, `margin-bottom: 26px`; inner fill `width: 17%`, `height: 100%`, `background #1a1512`. Fill-only, no figure inside it.
- **Card stack** (lines 27-41): rect 1 `inset: 14px -8px -12px 12px`, `background #e3dbcd`, `border: 2px solid #1a1512`; rect 2 `inset: 7px -4px -6px 6px`, `background #eee7da`, `border: 2px solid #1a1512`; card `background #fdfcf9`, `border: 2px solid #1a1512`, `box-shadow: 6px 6px 0 0 #1a1512`, `padding: 30px 22px`, `min-height: 300px`, flex column; decorative vertical margin rule (line 31) `position: absolute; top:0; left:44px; bottom:0; width:2px; background: rgba(168,94,74,.35)`; rotated "SEMANA 03" stamp (line 39) `top:18px; right:18px; rotate(7deg); border: 2px solid #7c6136; color #7c6136; mono 10px/700/.16em; padding 4px 7px; opacity .8`.
- **Card content** (lines 32-38): part-of-speech eyebrow "Sustantivo · f." mono 10px/600/.2em uppercase `#7c6136`; term "la cuñada" Fraunces 900 44px/1 letter-spacing -.03em `#1a1512`; IPA "/ ku·ˈɲa·ða /" mono 13px/.1em `#504940`; then `border-top: 2px dashed #504940; margin-top: 26px; padding-top: 16px` holding gloss "sister-in-law" 18px/1.45 `#2a2420` and a Caveat 700 20px `#a85e4a` mnemonic. Every content item carries `padding-left: 20px`, clearing the margin rule.
- **Action row** (lines 43-47): a `flex: 1` spacer above; row `display:flex; gap:10px; margin-bottom:12px`. Left ("Again" -> Previous): `flex: 1`, `min-height: 52px`, `background #faf8f4`, `color #1a1512`, `border: 2px solid #1a1512`, `border-radius: 0`, `box-shadow: 4px 4px 0 0 #1a1512`. Right ("Got it" -> Next): `flex: 1`, `min-height: 52px`, `background #1a1512`, `color #fdfcf9`, `border: 2px solid #1a1512`, `border-radius: 0`, `box-shadow: 4px 4px 0 0 #a07e48` (brass). Both mono 12px/700/.1em uppercase.
- **Hint** (line 48): mono 10px/.14em uppercase `#504940`, centered, "Tap card to flip · swipe to skip".

### Finding 6 — The current implementation, and what it already owes to E.4

`FlashcardsViewer.tsx` (216 lines) holds `index`/`flipped`/`flipStatus` state, `goTo()`, `toggleFlip()`, a card-stack with two decorative rects, a Grid-stacked two-face flip on a single `rotateY`, badges, an optional note, and Previous/Next disabled at the bounds. Issue #40 already consumed E.4 as a source: `FlashcardsViewer.css` cites `E.4:1444-1445`, `E.4:1451`, and reconciled "D.4's 48px and E.4's 52px mocks" to the shared 48px `--control-height`. So E.4 conformance is partly already shipped at the card level; the genuine gap is the full-screen page composition.

Today's progress treatment (`FlashcardsViewer.tsx:129-139`, `.css:27-63`) is a SINGLE row combining a 12px bordered decorative fill bar and a zero-padded `Card NN / NN` figure with `aria-live="polite"`. E.4 splits these apart. See Finding 7 below.

### Finding 7 — C.7 governs the progress split, cited from the DS not from a code comment

`design/field-journal/Field Journal DS.dc.html:525` (§C.7, lines 524-545) reads: "Progress is a filled bar with the raw figures beside it. Never a percentage alone." Its literal prohibition targets a figure without its paired bar. E.4's layout would strand the counter alone in the top bar, which that text does forbid. `FlashcardsViewer.css:27-29`'s comment is an implementation-side paraphrase, not the source of truth. Design review confirmed this correction.

### Finding 8 — Locked tests that constrain this work, all verified to exist

`src/__tests__/FlashcardsViewer.test.tsx` holds deterministic source scans (no `opacity` anywhere in the CSS; no own `prefers-reduced-motion` block; no `transitionend`/`animationend`; Grid-stacked faces never `position: absolute` in the flip ancestor chain; no native dialog invocation) — all stay green untouched under a zero-change architecture, and design review confirmed the file contains no assertion dependent on external DOM ancestry.

`src/__tests__/weekDetailFooterGeometry.test.tsx:336,339` asserts both `page.lastElementChild === footer` AND that the footer's `previousElementSibling.className` contains `week-detail-grid`.

`src/__tests__/FixedOverlayFocusPosition.test.ts:49-53,58-65` documents a real shipped defect: a blanket `App.css` rule `[tabindex]:focus { position: relative; z-index: 10; }` silently overrides `position: fixed` on any focused element unless that selector carries its own `:focus` override — today only `.accessibility-button:focus, .modal:focus` does — and the test matches the literal two-selector compound via a hardcoded regex, so a three-selector rule requires updating the test itself.

`src/__tests__/weekDetailBreakpointConsistency.test.ts` fails the build on any new `matchMedia` in the ~900px band not byte-matching `WEEK_DETAIL_MOBILE_MEDIA_QUERY`.

### Finding 9 — No inertness mechanism exists anywhere

`src/hooks/useFocusTrap.ts` implements only Escape-close, Tab/Shift+Tab cycling and focus restoration, with zero `aria-hidden`/`inert` logic outside `containerRef`. `src/components/Modal.tsx:28,59-64`'s "Inert background" comment applies `aria-hidden="true"` only to its own empty `.modal-backdrop` div, never to real sibling content. `MobileNavPanel` inerts nothing, relying on z-index occlusion plus the focus trap. A repository-wide search for `\binert\b` in `src/` returns no functional usage. Decisively, `AuthenticatedAppShell` (`src/App.tsx:224-311`) renders the app header/nav and the fixed "Aa" accessibility trigger as an ANCESTOR of `WeekDetailPage` — an ancestor cannot be `aria-hidden` without hiding the dialog itself, and no ref/prop/context path exists today from `WeekDetailPage` up to that chrome.

However — and this is the resolved D1 decision (see design handoff (c) below) — `WeekDetailPage` renders four elements ITSELF that are siblings, not ancestors, of the overlay's lift point: `.week-detail-header` (`WeekDetailPage.tsx:582`), `.week-detail-heading-row` (:627), `.week-detail-grid` (:959), `.week-detail-footer` (:1064). These can be inerted today with one local boolean and zero new plumbing.

### Finding 10 — The browser-back sentinel is verified sound, not assumed

`src/hooks/useRoute.ts:17-20,161-175` — React's `useState` setter bails out on an unchanged string value, so the app's existing global `popstate` handler is genuinely idempotent on an identical-path pop; no forced `WeekDetailPage` remount occurs when the sentinel's pop resolves to the same pathname. Independently verified by design review.

### Finding 11 — Token and geometry facts, verified

`src/tokens/primitives.json:4-5`: `paper.50 = #fdfcf9`, `paper.100 = #faf8f4` — distinct primitives, do not conflate. `src/tokens/semantic.json:9`: `color.surface.interactive.default -> paper.100`. Confirmed present with the claimed values: `--border-width-thin: 2px`, `--border-width-rule: 3px`, `--shadow-card: 5px 5px 0 0 #1a1512`, `--shadow-brass-press: 7px 7px 0 0 #a07e48`, `--hit-target-min: 44px`, `--space-5: 1.25rem`, `--space-7: 1.75rem`, and the focus-ring tokens. `MobileNavPanel.css:11` is `z-index: 40`, safely above `.accessibility-button`'s `z-index: 1` (`AccessibilitySettings.css:25`). `WeekDetailPage.css:248-253` documents the precedent for authoring off-scale dimension literals rather than minting tokens.

### Finding 12 — A prior document's "already resolved" claim about #74 is ambiguous and must not be relied on

`docs/plans/lizbeth-spanish-issue72-73-75-week-detail-fidelity.md:14` states "issue #74's SRS mode is out of scope for this plan and was already resolved separately." Read against `issue40-flashcards-screen.md:51`, that almost certainly refers to issue #40's non-goal declaring Again/Got-it unbuilt — not to #74 being closed. `docs/plans/lizbeth-spanish-fjds-full-app-conformance-closure.md:305` records #74 as still OPEN. Treat #74 as open; confirm live via `gh` at execution time.

## Design route

```
DESIGN_ROUTE
profile: standard
reasons: A new full-screen mobile screen composition for an existing shipped component;
  a net-new launch/dismiss user flow and IA change; a direct architectural conflict with
  a shipped mobile composition (Phase 4's E.3 Cards tab) sharing the same component;
  multi-state. Creative direction is fixed by the ratified E.4 artboard, so no direction
  generation is required and Studio would be the wrong tool.
agents_required: design-director, ux-architect, visual-system-designer, design-reviewer
prototype: forbidden
model_tier: sonnet
existing_system_mode: preserve
END_DESIGN_ROUTE
```

## Design review history

The design cycle produced a reviewed `DESIGN_HANDOFF` at revision 1. The review history is recorded here honestly, as two cycles, not smoothed into a single clean pass.

**Cycle 1 — NEEDS_REVISION, seven findings, one HIGH.** The highest-value catch (F1 in the reviewer's own numbering, distinct from this document's Finding numbering above): the handoff called background inertness "required, not optional" and used it as the whole justification for `aria-modal="true"`, when no inertness mechanism exists anywhere in the codebase and `AuthenticatedAppShell` is an ancestor that cannot be `aria-hidden` without hiding the dialog. Also caught: the lift point risked breaking `weekDetailFooterGeometry.test.tsx`'s footer-last-child assertion (reviewer's F2); the overlay root matched the exact profile of the shipped `FixedOverlayFocusPosition` defect class and no invariant covered it (reviewer's F3); the two specs contradicted each other on "Ficha vs Card," and both were wrong because it was already decided under issue #40 (reviewer's F4) — **correction, added by judge remediation J-004:** the "already decided under issue #40" framing itself overstated `issue40-flashcards-screen.md:325`, which is a Safe Assumption, not a decision record; see the corrected wording in "Assumptions and evidence limits" below, which is the operative statement, not this historical recap of the review's own (partly incorrect) reasoning; the handoff never stated whether the work closes #74 (reviewer's F5); C.7 was cited from a code comment rather than the DS source (reviewer's F6); and the Cards-tab row's rendering during `ready-flashcards` under overlay mode was unspecified, risking a duplicate `FlashcardsViewer` (reviewer's F7).

**Cycle 2 — NEEDS_REVISION, reviewer's F3 through F7 fully resolved, F1 and F2 partially.** The reviewer confirmed the `aria-modal` retention argument defensible and the residual gap honestly disclosed, but found the disclosed gap broader than necessary: four elements `WeekDetailPage` renders itself are siblings, not ancestors, and could be inerted for free. On F2 it confirmed the citation and found the "holds by construction" claim only half-true — it holds for the last-child assertion but not for the previous-sibling-class assertion at line 339 once the overlay renders a node. It stated explicitly that both are bounded, that neither requires reopening the architecture or restarting specialists, and that the disposition is a Director/Planner or user decision rather than a further review cycle.

**Disposition: the design revision budget was spent, so both were escalated to the user, who decided to apply the cheaper and more correct option in each case.** D1 is applied as the local inertness toggle in design handoff (c). D2 is applied as the documentation-accuracy correction in ordered-work item 4's gate. Neither changes the architecture or introduces new design direction. Reviewer-confirmed accurate and needing no change: no portals in `src/`; the lift point genuinely escapes the hidden-ancestor problem; every token, hex, and geometry citation; `z-index: 40` and its safety above `.accessibility-button`; every E.4 literal-geometry claim against the DS; the issue-#40 non-goal precedents; that `FlashcardsViewer.test.tsx` has no ancestry-dependent assertion; the popstate idempotency verification; and the 48px/3px geometry decision.

**Stated limit:** no test was executed and no live screen-reader session was run during review; the reviewer's F1, F2 and F3 are evidence-based static analysis of source and test files read in full, not runtime observation.

## Design handoff (binding on execution)

The following is the binding content of the reviewed `DESIGN_HANDOFF` revision 1, plus the two planner-applied remediations from review cycle 2 (recorded above as D1 and D2). Downstream execution treats it as authoritative alongside the measured values in Finding 5.

### (a) Architecture

Option (B): an app-owned full-viewport overlay. `position: fixed; inset: 0; z-index: 40`, no backdrop, launched from the existing mobile Cards-tab "View flashcards" control, containing exactly one canonical, byte-for-byte unmodified `FlashcardsViewer`. Lift point: `WeekDetailPage`'s own top-level render, a sibling of `.week-detail-grid`/`WeekSectionTabs`, still inside `<main>` — NOT lifted to `App.tsx`.

**Rejected (A) route-level screen.** `AuthenticatedAppShell` renders header/nav plus the fixed "Aa" trigger around every authenticated route unconditionally and E.4 shows no app header; no chrome-suppression mechanism exists and building one is out of scope. Separately, the deck fetch/parse/error/retry machine lives inside `ResourceRowView`, module-private and unexported — a route would have to fork or export it.

**Rejected (C) in-place restyle.** Cannot deliver full-screen; the mobile page header, the `WeekSectionTabs` tablist and the persistent footer would all remain visible around the card, and E.4's header cannot coexist with E.3's shipped header without redesigning a CLOSED Phase 4 artifact.

### (b) Shared-component disposition, per call site

The answer to the shared-component conflict identified in Finding 1.

- **Desktop attachments rail** (`ResourcesPanel.tsx:106` via `WeekDetailPage.tsx:1018`, `attachableResources`): UNCHANGED, byte-for-byte. `presentation` defaults to `'inline'`; desktop never passes the new prop pair.
- **Mobile Cards tab, non-empty** (`ResourcesPanel.tsx:106` via `WeekDetailPage.tsx:896-897`, `flashcardsResources`, `presentation="overlay"`): becomes the LAUNCHER, not a competitor. `idle`/`loading`/`error` render exactly as today, inline, unchanged. Under `presentation='overlay'` the `ready-flashcards` branch renders the row's stable re-open control — never an inline `FlashcardsViewer` — for that state's entire lifetime, before first open and whether the overlay is open or closed, so no duplicate instance can ever render alongside the overlay's canonical one. First entry into `ready-flashcards` additionally fires `onFlashcardsReady` once to open the overlay; later activations reopen with the held deck and no re-fetch.
- **Mobile Cards tab, empty** (`WeekDetailPage.tsx:899`): UNCHANGED, untouched, not an overlay entry point.
- **`FlashcardsViewer` and `WeekSectionTabs`:** zero changes. `panelContainsFocusableContent={hasFlashcardsRow}` (`WeekDetailPage.tsx:974`) unchanged and confirmed still valid for `idle`, `ready`-as-re-open-control, and `error`. It does NOT hold for the transient `loading` state (`ResourcesPanel.tsx:89-93` renders a bare `<p role="status">` with no focusable descendant) — design review confirmed this gap is unchanged from the already-CLOSED Phase 4 architecture, neither introduced nor worsened here. Record it; do not fix it under this plan.
- Single-tablist invariant holds: the overlay is `role="dialog"`, a distinct ARIA category mounted outside the tab/tabpanel hierarchy.

### (c) UX and accessibility

- **Entry:** Cards tab -> "View flashcards" -> existing "Preparing your flashcards…" -> on success the overlay opens with a fresh `FlashcardsViewer` mount (index 0, unflipped), focus moves to the back/close control, and a same-URL history sentinel is pushed. On failure, the existing inline error and "Retry" show; the overlay never opens.
- **Exit:** the back/close control, Escape, or the first browser-back press all invoke one shared `closeOverlay()`. The overlay unmounts (fresh remount at index 0/unflipped next time), focus returns to the Cards-tab re-open control via `useFocusTrap`'s `triggerElement`, and no route navigation occurs.
- **Modality:** `role="dialog" aria-modal="true"`, `useFocusTrap` reused exactly as `MobileNavPanel` uses it. Tab order inside: back/close -> card (flip) -> Previous -> Next -> note/badges.
- **D1 RESOLUTION (user-decided, applied).** While the overlay is open, `WeekDetailPage` toggles `aria-hidden`/`inert` on its own four sibling elements — `.week-detail-header` (:582), `.week-detail-heading-row` (:627), `.week-detail-grid` (:959), `.week-detail-footer` (:1064) — driven by the overlay's existing open/close boolean, with no new hook and no context plumbing, and releases them on close. The app-shell-level chrome (header/nav and the "Aa" trigger) genuinely cannot be inerted from here per Finding 9 and remains a disclosed residual gap: a screen-reader user in browse/virtual-cursor mode could still reach that chrome, since a focus trap intercepts only the real Tab key. That residual gap is PRE-EXISTING and shared identically with `MobileNavPanel`; it is not a regression introduced here. A joint `useInertSiblings` follow-up covering both surfaces together is recorded as a candidate future item (open decision OD-5, see below), not authorized by this plan.

#### Alternatives considered and rejected for background inertness (added by judge remediation J-001)

Two alternatives to the D1 local toggle were evaluated and rejected for cause, on direct evidence, not merely because precedent exists elsewhere.

**Alternative 1 — native `<dialog>` with `showModal()`.** This would obtain browser-native top-layer isolation and inertness for free, removing the need to inert siblings manually at all. Rejected for cause:

- This codebase has **zero** native `<dialog>` usage. A repository-wide search for `<dialog`, `showModal`, and `::backdrop` across `src/` returns no result in any production file.
- The app has a single, twice-shipped, deeply established convention instead: a `<div role="dialog" aria-modal="true">` driven by the shared `src/hooks/useFocusTrap.ts`. `src/components/Modal.tsx:39-47,67-75` is the general-purpose implementation and `src/components/MobileNavPanel.tsx` is the full-viewport one. Twenty-six files reference `Modal` or `useFocusTrap`, including eleven dedicated test files that lock this convention's exact behavior — `Modal.test.tsx`, `Modal-FocusTrap-Boundaries.test.tsx`, `Modal-FocusTrap-ShiftTab.test.tsx`, `RegisterStudentModal-FocusRestore.test.tsx`, `RegisterStudentModal-StaleError.test.tsx`, `AdminStudentModals-DismissPolicy.test.tsx`, `AdminStudentModals-DismissalRegression.test.tsx`, and `MobileNavPanel.test.tsx` among them.
- Introducing native `<dialog>` for this one surface would create a second, divergent modal mechanism alongside that convention, which is a shared-convention change, not a composition change for one issue.
- It would also bypass `useFocusTrap`'s `suppressDismiss` semantics, which are load-bearing elsewhere in this app under a documented prior Codex `CODE_REVIEW` rationale (J-35-001) and are the subject of an open, unresolved user ruling tracked as GitHub issue #100. Forking Escape-handling behavior while that ruling is outstanding would be actively unhelpful.
- `showModal()`'s top-layer placement and `::backdrop` would additionally interact with the `[tabindex]:focus { position: relative; z-index: 10; }` defect class documented at `src/__tests__/FixedOverlayFocusPosition.test.ts` and with the `z-index: 40` convention, in ways this plan has not characterised and would have to.
- Conclusion: genuinely out of proportion to issue #74. A `<dialog>` migration is a codebase-wide modal-convention decision that should be taken deliberately for `Modal.tsx` and `MobileNavPanel` together, if it is taken at all. Recorded as a candidate alongside OD-5, not adopted here.

**Alternative 2 — a portal-based inert boundary reaching app-shell chrome.** Rejected for cause:

- No portal exists anywhere: `createPortal` returns zero results across `src/` (Finding 4).
- Portalling the overlay to `document.body` would move it out of `WeekDetailPage`'s subtree entirely. Open state and the held deck would then need threading from `WeekDetailPage` up to a shell-level mount via new context or a callback chain, and the inert boundary would separately need to enumerate and toggle `AuthenticatedAppShell`'s own children. That is the cross-cutting architecture this issue's scope does not cover.
- It would also dissolve the lift-point reasoning this plan depends on: the overlay would no longer be a sibling of `.week-detail-grid`, so the footer-ordering analysis in ordered-work item 4 and the local D1 toggle would both need re-derivation.
- Conclusion: disproportionate here, but this is the correct *shape* for the OD-5 joint follow-up, which would fix `MobileNavPanel` and this overlay together. Cross-reference OD-5.

With both alternatives evaluated and rejected for cause, the D1 local toggle is adopted as the proportionate fix for the reachable half of the gap, and the app-shell-chrome half remains a disclosed residual — not because a similar gap exists elsewhere, but because the two mechanisms that would close it are each a codebase-wide change this issue is not scoped to make.
- **Progress and the counter:** do NOT split the bar from the counter. Keep `FlashcardsViewer`'s existing single combined row exactly as-is in the content region; the overlay's top bar carries NO counter. Grounds are Finding 7's DS text directly — splitting would strand the header's counter without its paired bar, which C.7 forbids. This is a deliberate, recorded deviation from E.4's literal layout, not a silent omission.
- **Browser back:** opening pushes a same-URL sentinel via `window.history.pushState` (not `navigate()`, which no-ops on an identical path). A `popstate` listener registered while open calls `closeOverlay()` on the first back press; a second back press navigates away normally; refresh or direct load always lands with the overlay closed. Verified sound per Finding 10 — not a flagged assumption. No new route, no query-string convention, never bookmarkable.
- **Keyboard:** flip/Previous/Next preserved exactly as shipped. No new shortcuts.
- **Reduced motion:** the overlay does NOT animate open or close — plain conditional mount/unmount, mirroring `MobileNavPanel.tsx:54`'s `if (!isOpen) return null`. `FlashcardsViewer`'s flip is unaffected and stays governed solely by `--motion-duration-flip`.
- **States to specify and test:** idle, loading, error+retry (all unchanged, inline, no overlay), empty-no-resource (unchanged, no entry point), empty-deck (overlay opens showing only the existing "No flashcards are available yet." paragraph), first card (Previous disabled), single-card deck (both disabled), last card (Next disabled), flipped, re-opened, reduced motion.

### (d) Visual system

- **Root `.flashcards-overlay`:** `position: fixed; inset: 0; z-index: 40; display: flex; flex-direction: column; outline: none`, `tabIndex={-1}`, and — added by judge remediation J-003 — an opaque `background-color: var(--color-paper-200)`. This mirrors `MobileNavPanel.css:8-17`, which likewise declares an opaque background on its own root (`background: var(--color-surface-interactive-default)`, `MobileNavPanel.css:12`); the omission here was a transcription gap in this plan, not a deliberate choice.

  **Background rationale, and why paper-200 rather than paper-100.** E.4's own frame is `background-color: #f0ebe2` (harness line 17), which is `--color-paper-200` — the same token issue #40 already mapped for the flashcards tray on genuine cross-mock agreement between `D.4:903` and `E.4:1433` (`docs/plans/lizbeth-spanish-issue40-flashcards-screen.md:134`). E.4's top bar is the lighter `#faf8f4` (paper-100), which the top-bar bullet already specifies. Using paper-200 on the root therefore matches the artboard's measured frame exactly and seats `FlashcardsViewer`'s own `background-color: var(--color-paper-200)` tray (`FlashcardsViewer.css:15-20`) against a continuous surface rather than a contrasting one. `.flashcards-overlay-content` still declares no background of its own; the root's paper-200 paints through it. The frame's repeating-linear-gradient grid texture is **not** implemented — it is artboard chrome, already excluded by deviation-ledger item 1, and this background specification does not reintroduce it.
- **`.flashcards-overlay-top-bar`:** flex row, align-items center, justify-content flex-start, `padding: 10px 18px` (literal), one child only; `border-bottom: var(--border-width-rule) solid var(--color-ink-1000)` — an exact match to E.4's measured 3px solid #1a1512. Background `var(--color-surface-interactive-default)` (-> paper.100, `#faf8f4`), an exact hex match to E.4's measured top bar and the same token `MobileNavPanel` uses.
- **`.flashcards-overlay-back-link`:** reuses `.week-detail-back-link`'s shipped mobile typography — mono, 12px, weight 700, letter-spacing `.12em` (literal), uppercase, ink-1000, no text-decoration — byte-identical to E.4's measured back-link typography. `min-height: var(--hit-target-min, 44px)`, a deliberate deviation from E.4's measured 40px because 40px sits below this project's ratified hit-target floor. Renders as a plain `<button type="button">`, not the boxed `Control`.
- **`.flashcards-overlay-content`:** `flex: 1; min-height: 0; overflow-y: auto; padding: var(--space-7) var(--space-5)` (28px/20px, both already on the scale), mirroring `Modal.css`'s `.modal-content` overflow pattern. `FlashcardsViewer` mounts as its sole unmodified child. No max-width or centering added; `FlashcardsViewer` already self-centers.
- **No new DTCG token of any kind.** Two off-scale measured values (top-bar padding `10px 18px`, letter-spacing `.12em`) are authored as literals per `WeekDetailPage.css:248-253`'s documented precedent. Lint compliance: no raw hex outside `src/tokens/`, no non-zero radius, and no `box-shadow` at all in the new chrome.
- **Contrast verified:** `#1a1512` on `#faf8f4` = WCAG 17.07:1 / APCA Lc 100.72; `#3d5f6b` (focus ring) on `#faf8f4` = WCAG 6.5:1 / APCA Lc 79.66.
- **Focus ring** on the new control: `outline: var(--focus-ring-width, 3px) solid var(--color-focus, var(--color-ink-slate)); outline-offset: var(--focus-ring-offset, 2px)`, declared at component level rather than relying on the global rule.
- **Previous/Next geometry:** accept the shipped 48px / 3px border / `--shadow-card` treatment as final. Do NOT reconcile toward E.4's literal 52px / 2px / 4px-4px. Grounds: the architecture bans any `FlashcardsViewer` change and overlay-scoped descendant overrides would fork the one shared button treatment; and the shipped pair is already the symmetric secondary/secondary treatment the equal-visual-tier position requires. This matches the already-made, not-reopened call at `issue40-flashcards-screen.md:334`. No new 4/4 or 6/6 shadow token is needed.
- E.4's asymmetric ink/paper Again/Got-it treatment is deliberately NOT ported: Previous/Next is a symmetric bidirectional navigation pair, so a primary/secondary split would assert a false hierarchy and would visually invert at the last card. The native disabled state carries the only legitimate asymmetry.

### (e) Deviation ledger

Every E.4 element not implemented, each disclosed with grounds. All items are consistent with precedent already disclosed and closed under issue #40, not a new departure.

1. Frame, bezel and status bar — not implemented; decorative artboard-only (same disposition as E.3's Finding 12).
2. Top-bar counter relocation, and with it E.4's standalone fill-only progress bar — not implemented; the counter and bar stay together in `FlashcardsViewer`'s existing combined row, per the C.7 grounding in (c).
3. "SEMANA 03" rotated stamp — not implementable under the zero-change architecture; it is positioned relative to the card face, owned by unmodified `FlashcardsViewer.css`. This continues a recorded deferral rather than a fresh omission: `docs/plans/lizbeth-spanish-issue40-flashcards-screen.md:339` already lists "A 'SEMANA 03'-style decorative corner tag (no field maps to it)" under that plan's own "Open, explicitly deferred, NOT blocking implementation" heading.
4. In-card vertical decorative margin rule — not implementable, same reason.
5. Part-of-speech eyebrow, IPA, and the Caveat-font mnemonic aside — mockup-only and unbuildable; `FlashcardRecord` exposes only `front`, `back`, `badges`, `note`. Already recorded at `issue40-flashcards-screen.md:50`.
6. Asymmetric ink/paper button treatment — not ported; see (d).
7. Literal 52px / 2px / 4px-4px button geometry — superseded by the shipped 48px / 3px / `--shadow-card` treatment; see (d).
8. Decorative stack-rect color split (E.4 uses paper-300 and an unmatched tone; D.4 uses paper-100) — already resolved and shipped as a single paper-100 treatment at both breakpoints under issue #40; cited, not reopened.
9. "swipe to skip" in the hint copy — cannot ship; "no swipe gestures" is binding. See open decision OD-2.

### (f) Verdict on issue #74 closure

Stated plainly, and independently agreed by design review. The structural and functional ask of #74, a dedicated full-screen review mode for mobile, IS genuinely delivered: a real full-viewport takeover reached from the existing launch action, reusing `FlashcardsViewer`'s interaction model exactly, with no scope creep into scheduling semantics. The declined visual-fidelity items in (e) are disclosed, precedented under closed issue #40, and non-blocking. The plan may therefore close #74 on this work rather than treating every mockup pixel as a requirement — while recording (e) honestly rather than claiming pixel conformance.

## Judge route and disposition

### Planned judge route

```
judge_route: PLAN_DUCK eligible and RECOMMENDED before user approval,
  model: gpt-5.6-terra, effort: medium
reasons: This is NOT trivial deterministic single-file work and does not qualify for
  the trivial-work exception: it makes a cross-layer architectural decision (full-
  viewport overlay versus route versus in-place), changes a component shared across
  three call sites and two breakpoints, adds a role="dialog" surface with focus-trap
  and history-manipulation semantics, and interacts with two locked test files
  (weekDetailFooterGeometry.test.ts, FixedOverlayFocusPosition.test.ts) plus a
  build-breaking breakpoint-consistency guard.
rubric_focus: whether the desktop non-regression claim genuinely holds given the shared
  ResourcesPanel.tsx:106 path; whether the history-sentinel mechanism can strand a user
  or double-fire; whether the local inertness toggle can hide the overlay itself or leak
  on unmount; whether the deviation ledger's #74-closure verdict is honest.
targeted_code_review: recommended specifically on the overlay component and the
  WeekDetailPage wiring (ordered-work items 1 and 4), not spent on the CSS or test items.
call_caps: standard eligible task, at most two calls; high-risk, at most four calls;
  one checkpoint repeatable after remediation, per standing policy in
  docs/JUDGE-CONTRACT.md.
shadow_mode: findings from any non-required checkpoint remain advisory.
authority_order: deterministic failures (lint, tests, type-check, oracle) always
  dominate any judge result. No judge pass is promised by this plan and no
  model-generated finding is asserted in advance of an actual run.
```

### Run record and disposition

`PLAN_DUCK` ran on this plan per `docs/JUDGE-CONTRACT.md`. Verdict **REVISE**, three major and two minor findings. Policy action: **advisory (shadow mode), non-blocking** — this run does not gate approval. One judge-driven remediation loop was spent against the standing call caps recorded above. Deterministic failures always dominate a judge result, and no judge finding altered this plan's architecture or scope.

| ID | Substance | Disposition |
|---|---|---|
| J-001 | The plan never evaluated a native `<dialog>` element or a portal-based inert boundary before settling on the disclosed-gap position for background inertness. | **Accepted as an evaluation gap; both alternatives are now evaluated and rejected for cause.** See the new "Alternatives considered and rejected for background inertness" subsection under design handoff (c). |
| J-002 | A corrected comment protects nothing; the open-overlay DOM state has no test. | **Accepted in full.** See ordered-work item 4's strengthened gate. |
| J-003 | No opaque background is specified anywhere on the overlay root or its content region. | **Accepted in full; a genuine defect caught before implementation.** See design handoff (d). |
| J-004 | The "Ficha vs Card" citation overstates what `issue40-flashcards-screen.md:325` says. | **Accepted in full.** Citation corrected in "Assumptions and evidence limits." |
| J-005 | The E.4 harness path could not be resolved. | **Rebutted on evidence; no change to the measurements or their provenance.** The judge's tooling searched `lizbeth_spanish/.atelier/reference-harness/`. That path does not hold the harness and never did. Every reference-harness citation in this document already points at the orchestrator root — `H:\CommandCenter\orchestrator\.atelier\reference-harness\field-journal-e4-flashcards-390.html` — at Cross-references and in Finding 5, and the file was confirmed present there during planning. The confusion is real but external to this plan: a `lizbeth_spanish/.atelier/` directory does exist and is cited in Interfaces and data, but it holds only `tokens/`, a genuinely different directory. This matches the location convention recorded at Finding 13 of the E.3 precedent plan (`docs/plans/lizbeth-spanish-fjds-phase4-e3-mobile-week-detail.md`), which states the reference artefacts live at the orchestrator root, not under `lizbeth_spanish/`. No path in this document is wrong, and the E.4 measurements in Finding 5 were transcribed by a planner with direct read access to the correct file. No correction applied. |

## Ordered work

Seven items, dependency-ordered, each bounded for one T1 job with explicit acceptance checks. Owner: engineering-fleet, T1 first-line, escalating to T2 on two counted gate failures per item. No item may be dispatched before this plan is approved.

1. **The overlay component and its CSS.** Build `.flashcards-overlay` (root, top bar, back/close control, scrollable content wrapper) per design handoff (d), with `role="dialog" aria-modal="true"`, `useFocusTrap` reused as `MobileNavPanel` uses it, focus to the back/close control on open, focus return to the trigger on close, Escape to close, and no open/close animation.
   - Gate: measured conformance to (d)'s values; no raw hex; no non-zero radius; no `box-shadow` in the new chrome; no new DTCG token; the focus ring declared at component level; `min-height: var(--hit-target-min)`; no `position: absolute` or `overflow: hidden` on any wrapper between the fixed root and `FlashcardsViewer`'s mount point; zero diff in `FlashcardsViewer.tsx`/`.css`; an opaque background is declared on the overlay root, and a rendered check confirms no week content or app-shell chrome is visible through the overlay at any scroll position (added by judge remediation J-003).
   - Depends on: nothing.

2. **The `App.css` focus override and its test extension** (Finding 8 / review cycle 2's F3). Add `.flashcards-overlay` to the `:focus` override selector list so it reads `.accessibility-button:focus, .modal:focus, .flashcards-overlay:focus { position: fixed; }`, declared after the blanket rule exactly as the existing pair is. Extend `FixedOverlayFocusPosition.test.ts`'s override-rule and cascade-order assertions to cover `.flashcards-overlay` — note the existing test matches the literal two-selector compound via a hardcoded regex, so the test itself must be updated, not only the CSS.
   - Gate: `FixedOverlayFocusPosition.test.ts` passes with the new assertions; the overlay root provably keeps `position: fixed` while focused.
   - Depends on: 1.

3. **The `ResourcesPanel` launcher prop pair.** Add `presentation?: 'inline' | 'overlay'` defaulting to `'inline'` and `onFlashcardsReady?: (cards) => void`. Under `presentation='overlay'`, the `ready-flashcards` branch renders the row's stable re-open control instead of an inline `FlashcardsViewer`, for that state's entire lifetime; `onFlashcardsReady` fires exactly once on first entry into the state.
   - Gate: desktop rendering byte-for-byte unchanged (no prop passed); `idle`/`loading`/`error` branches unchanged; a test proving no inline `FlashcardsViewer` ever mounts in overlay mode, including during the open state; a test proving `onFlashcardsReady` fires once and not per render; no signed-URL re-fetch on re-open.
   - Depends on: nothing.

4. **`WeekDetailPage` wiring.** Hold the overlay's open state and the fetched deck at the page's top-level render; render the overlay as a sibling of `.week-detail-grid`, **declared in JSX before `.week-detail-footer`, never after**; apply the D1 local inertness toggle to `.week-detail-header`, `.week-detail-heading-row`, `.week-detail-grid` and `.week-detail-footer` from the same open/close boolean, releasing on close and on unmount.
   - Gate: `weekDetailFooterGeometry.test.tsx` passes unmodified. **D2 correction, to be recorded verbatim in the executed plan record and in a source comment:** the `page.lastElementChild === footer` assertion (line 336) holds unconditionally, because the overlay returns `null` when closed and contributes zero DOM nodes, and because it is declared before the footer when open. The `footer.previousElementSibling.className` contains `week-detail-grid` assertion (line 339) holds only while the overlay is CLOSED; once the overlay renders a node between the grid and the footer, the footer's previous sibling is the overlay. This is a documentation-accuracy correction, not a behavior change — no live regression exists today, because the cited test never exercises the open state and `WeekDetailPage.css` contains no adjacent-sibling combinator between grid and footer (all footer rules are descendant-scoped). Any future test exercising the open state must assert the overlay itself as the footer's immediate previous sibling, not `.week-detail-grid` directly. Do not "fix" this by moving the overlay after the footer.
   - Also gate: the inertness toggle provably never applies to the overlay itself or to any of its ancestors; state and listeners are released on unmount; the mobile Cards-tab empty-state call site at `:899` is untouched.
   - **Open-state DOM structure test, required (added by judge remediation J-002).** A corrected comment protects nothing on its own; extend `weekDetailFooterGeometry.test.tsx` with genuine coverage of both states, not one tested and the other explained away:
     - Closed state: the existing assertions stay green unmodified — `page.lastElementChild === footer` (line 336) and the footer's `previousElementSibling.className` contains `week-detail-grid` (line 339). Both remain real invariants while the overlay is closed, because the overlay returns `null` and contributes zero DOM nodes.
     - Open state, new: with the overlay open, assert that `.week-detail-footer` is still `.week-detail-page`'s last element child, **and** that the footer's immediate previous element sibling is the overlay element itself — not `.week-detail-grid`. This is the assertion that actually enforces the "declared before the footer, never after" invariant; without it, an implementer who appended the overlay after the footer would pass every existing check.
   - Depends on: 1, 3.

5. **Browser-back close via the history sentinel.** Push a same-URL entry with `window.history.pushState` on open; register a `popstate` listener while open that calls `closeOverlay()`; remove it on close and on unmount.
   - Gate: the first back press closes the overlay without navigating away; a second back press navigates normally; refresh or direct load lands with the overlay closed; no listener leak; no `navigate()` call; no new route or query-string convention; `useRoute`'s existing handler provably not re-triggered into a remount (Finding 10).
   - Depends on: 1, 4.

6. **Tests.** Overlay accessibility and keyboard coverage (focus on open, trap, Escape, focus return, tab order); the deterministic no-native-dialog source scan extended over the new component; a single-`role="tablist"` assertion with the overlay open; a desktop non-regression assertion; and confirmation that every existing `FlashcardsViewer.test.tsx` scan and `SegmentLedger`/`WeekSectionTabs` suite stays green unmodified.
   - Gate: `npm run lint`, `tsc --noEmit` and the full vitest suite pass with NO exclusions — an exclusion-based pass is a failed gate, per the recorded prior incident in which a "full pass" was falsely claimed by silently omitting `rlsIntegration.test.ts`; the local Supabase stack must be confirmed running before any RLS-dependent result is trusted. `verify-token-pipeline.mjs` and `tokenPipelineOracle.test.ts` pass. `tokenFallbackAuditLint` checks (b), (c), (d) pass. The umbrella plan's Phase 1 deprecation detector reports no new findings against the frozen 80/77 baseline. `nativeDialogPolicy.test.ts` stays green.
   - Depends on: 1-5.

7. **Browser validation, rendered-capture disposition, and closure.** Execute the browser validation below, record the four-category capture disposition, resolve open decisions OD-1 through OD-4, and close the item.
   - Closure gate: items 1 and 4 may be structurally built and gate-passed against placeholder copy, but this item may not close until copy sign-off for OD-1 through OD-4 is obtained and recorded in the executed plan record. Copy sign-off is a closure gate on this item, not a dispatch gate on items 1 or 4. Confirm live GitHub state for #74 via `gh` before closing it (planning could not — see Finding 12).
   - Depends on: all prior items.

## Interfaces and data

No API, schema, migration, RPC, or data-model change. `FlashcardRecord` and `src/lib/flashcardsFormat.ts` are consumed as-is and are NOT extended — that is precisely why the part-of-speech, IPA and mnemonic fields are unimplemented.

Changes are confined to: one new component plus its CSS; `src/components/ResourcesPanel.tsx`; `src/pages/WeekDetailPage.tsx` and its CSS; `src/App.css` (the focus-override selector list only); and test files. `src/tokens/field-workbook.generated.css` is never hand-edited, and no DTCG token is added, so `.atelier/tokens/field-workbook.tokens.json` is untouched. `lizbeth_spanish/atelier.config.json` is never edited.

Backward compatibility: `ResourcesPanel`'s new props are optional with safe defaults, so no existing caller changes. `FlashcardsViewer` and `WeekSectionTabs` have unchanged public surfaces.

## Acceptance and validation

### Deterministic gates

As enumerated in ordered-work item 6.

### Desktop non-regression

The >=900px rendering must be provably unchanged. Prove it by capturing the desktop viewport before and after and disposing of any delta, and by confirming the desktop rail passes no new prop and that every new CSS rule is scoped below the breakpoint. This matters more than usual here because desktop and mobile share `ResourcesPanel.tsx:106`.

### Single-tablist invariant

Exactly one `role="tablist"` in the accessibility tree at desktop width, at mobile width, at the breakpoint boundary, and with the overlay open.

### Rendered-capture comparison against the E.4 baseline

Capture at the manifest's exact E.4 dimensions (396x850) and compare against `H:\CommandCenter\orchestrator\.atelier\baselines\field-journal-e4-flashcards-390.png`. Per this program's established authority ordering, `visual_diff` against a DS-derived baseline is NON-AUTHORITATIVE for pass/fail and must never auto-fail a surface — it is structural signal only, because the reference shows idealized placeholder content while the app shows real data.

Every non-zero delta receives a written disposition in exactly one of four categories:

1. **Ratified deviation** — citing the specific clause that permits it — every item in design handoff (e) is expected here.
2. **Content difference** — the reference shows placeholder Spanish sample content and the app shows real parsed deck data.
3. **Genuine defect** — filed as a GitHub issue per the umbrella plan's logging policy.
4. **Unexplained** — a stop-and-report condition, never silently passed.

Mask or hold constant every dynamic region before capture so captures are comparable across runs and across the reference/app pair.

**Authority ordering, restated:** the deterministic lint and test suite are authoritative; Atelier `design_review`/`contrast_check`/`a11y_audit` are corroborating; `visual_diff` is non-authoritative signal; deterministic failures always dominate any judge or visual result.

## Execution record

This item is closed. It is recorded here honestly, as a plan that shipped genuine defects caught by independent review rather than a clean narrative.

### Merged work

| PR | Ordered-work item(s) covered |
|---|---|
| #124 | Items 1-3 |
| #125 | Item 4 |
| #126 | Item 5 |
| #127 | Item 6 |
| #128 | OD copy reconciliation (OD-1 through OD-4) |
| #129 | Item 7 remediations |

**Final `main` merge commit:** `3e6aafd213b807291b2be9c86db591bd0e6c2198`.

**GitHub issue #74:** confirmed live via `gh` per Finding 12's requirement — it was genuinely OPEN, milestone "Field Journal DS," labels `enhancement`, `role:student`, `area:design-system`. Closed 2026-09-07.

### Two blocker defects only real-browser validation caught

These are this plan's most valuable execution lesson, and they are recorded prominently for that reason.

**1. The overlay never covered the viewport on the forward-navigation path.** `.week-detail-sheet--animate`'s `fj-page-turn` animation declares `animation-fill-mode: both`, which permanently held a non-`none` transform on the sheet after the animation completed. Per the CSS Transforms specification, any ancestor with a computed transform other than `none` becomes the containing block for `position: fixed` descendants — so the overlay, instead of being positioned against the viewport, was positioned against that transformed ancestor. Measured effect: the overlay rendered at `{x:16, y:186, 364x573}` instead of the expected `{0, 0, 396, 850}`. This was reproducible only via forward navigation (roadmap → week card), never via direct URL entry to the week-detail route, which is why it was not caught by any source-level gate or by testing that only loaded the route directly. Fixed by dropping the `--animate` class on the sheet's `animationend` event, so the transform no longer persists once the arrival animation finishes.

**2. Focus was never restored on close, on all three close paths.** `document.activeElement` was `<body>` after close via the back/close control, Escape, and browser back alike — a direct violation of the plan's own requirement, stated in design handoff (c) "Exit" and in ordered-work item 1, and exercised by journey J6. Root cause was three distinct, compounding defects, not one:

- `triggerElement={null}` was passed to `useFocusTrap`, so it had no element to restore focus to.
- The D1 inert toggle on `WeekDetailPage`'s four sibling elements ran inside a passive `useEffect`, so `inert` was still applied to the re-open control's ancestor when `useFocusTrap`'s cleanup called `.focus()` on it — focusing an element inside an `inert` subtree is a silent no-op per the HTML specification, so the call executed without error and without effect.
- A stale trigger-ref read occurred on the very first open: the flashcards deck resolves and the overlay opens in the same React commit that first mounts the ref's target element, so the ref read at that moment could not yet see the mounted node.

Fixed by threading a real `flashcardsTriggerRef` through to the "View flashcards" launcher control, converting the D1 inert toggle from `useEffect` to `useLayoutEffect` so sibling inertness is released before focus restoration runs, and splitting the open sequence across two React commits so the trigger ref is guaranteed mounted before the overlay reads it.

**The lesson, stated plainly.** The full test suite (2745+ passing tests) was green while both defects shipped, because jsdom computes neither real layout and containing-block resolution nor real focus semantics — it cannot reproduce either failure mode. Both are now guarded by dedicated real-browser Playwright regression tests: `src/__tests__/e2e/flashcards-overlay-forward-nav-viewport.spec.ts` and `src/__tests__/e2e/flashcards-overlay-focus-restoration.spec.ts`. The viewport test specifically asserts the rendered `boundingBox()` rather than the computed `position` CSS property — asserting `position: fixed` alone would not have caught this defect, since the element's declared `position` never stopped being `fixed`; only its effective containing block changed.

### Two process corrections during execution

Both were caught by independent review, not self-reported by the implementing pass.

1. An in-code comment shipped in item 4 described `triggerElement={null}` as an "accepted, non-regressive limitation," on the grounds that focus lands correctly on the overlay's own back control when it opens. That reasoning addressed focus on *open* only, and silently failed to address focus restoration on *close* — the actual requirement in design handoff (c) and journey J6. The comment was corrected once the gap was identified.
2. A first remediation attempt for the focus-restoration defect restored focus to the Cards *tab* button rather than the plan-specified Cards-tab re-open control, justified by a claim that the launcher control "genuinely unmounts mid-fetch." Independent verification rejected this: two pre-existing comments in the same files already stated the control is stable "for this state's entire lifetime... after it closes," directly contradicting the unmount claim. The attempt was treated as a silent requirement downgrade rather than accepted, and the correct fix — threading a real ref to the actual re-open control — was implemented instead.

### Browser validation

`BROWSER_PASS` via Playwright, at 396x850 (E.4 comparison) and 1024x768 (desktop non-regression), base URL `http://[::1]:5173`, against the seeded local Supabase stack. All 14 journeys (J1-J14) exercised and passed. Claude-in-Chrome was attempted first and proved unusable for this surface: its `resize_window` tool floored at 500x665, well above the 396-wide mobile target, and synthetic clicks stopped registering as trusted events after a resize. Playwright was the reliable backend used for the actual pass, consistent with this program's prior experience on other browser-validation jobs.

### Rendered-capture disposition

The plan's four-category disposition discipline was applied against the E.4 baseline. Result: all 9 deviation-ledger items (design handoff (e), items 1-9) disposed as ratified deviations; one content difference (the real seeded deck's first card, "madre" 01/38, versus the reference's placeholder "la cuñada" 02/12); zero unexplained deltas.

**Tooling limitation, disclosed.** Atelier `visual_diff` could not drive the authenticated forward-navigation sequence (login → roadmap → week card → Cards tab → View flashcards) needed to reach the overlay's open state, so the disposition above was produced by a manual side-by-side comparison against the baseline PNG rather than a tool-computed diff. This is a tooling gap in the automated pipeline, not a gap in the disposition itself.

### Disclosed testing limit

Journey J10 (empty deck) and the no-flashcards-resource state are unreachable in seeded local data. All four Beginner weeks (1-4) that carry a flashcards resource reference the identical `flashcards.yaml` file, and weeks 5 and beyond have no resources at all, so they never reach the `available` ViewState in which the Cards tab renders. A decision was made not to mutate seed data to manufacture this case.

Compensating coverage exists at the component level instead of the browser-journey level: `FlashcardsViewer.test.tsx:121-123` renders `cards={[]}` directly and asserts the exact empty-state copy; `weekDetailCardsFilesPanels.test.tsx:305-317` mounts the real `WeekDetailPage` tree for a week with no flashcards resource and asserts the empty-state copy renders with no "View flashcards" button present.

### Environmental note

The local Supabase stack was down for most of execution. Most ordered-work items were therefore gated using a stash-based isolation methodology — running the full test suite against the unmodified base, then comparing the set of failing files before and after the change — rather than an absolute pass-count comparison. After the stack was brought up for browser validation, approximately 14 test files fail on Supabase Edge Functions returning `503`/`BOOT_ERROR` (Edge Functions are not served in the local dev stack), plus 3 seed-date-drift failures in `roadmapIntegration.test.ts` and one pre-existing `FeedbackLedgerRow.test.tsx` failure. All of these are pre-existing and unrelated to this plan's work; none was introduced by it.

### Independent gates

A read-only Verifier pass is required and no writer may self-approve. A Browser Validator pass on this surface is required. Neither is discharged by source-level evidence alone; a browser-validation tooling failure is a blocking impediment to be reported, never grounds to accept the surface on source evidence alone.

## Browser UI dialog policy

Required. No native `alert`, `confirm`, `prompt`, any `window.*` form, or `beforeunload` anywhere in this browser-rendered React UI, in any existing or newly added state. This work introduces no dialog of that kind at all — an affirmative finding from planning and design review, not an omission.

Acknowledgement and confirmation use the app-owned accessible pattern: focus trapped while open, focus returned to the trigger on close, Escape plus an explicit close control, never backdrop-only dismissal, with the visible 3px slate focus ring at 2px offset at every stop. The new overlay satisfies all of these via `useFocusTrap`.

The gate has two halves, both required:

1. **Source scan** — a deterministic scan over `src/**` for `alert(`, `confirm(`, `prompt(`, their `window.*` forms, and `beforeunload`, run as a build gate and already enforced by `src/__tests__/nativeDialogPolicy.test.ts`, extended to cover the new component.
2. **Runtime confirmation** — no native dialog fires on any journey enumerated below.

## Browser validation

**Launch and readiness:** `npm run dev` in `H:\CommandCenter\orchestrator\lizbeth_spanish`; ready when the login route renders. Reuse an existing healthy dev server rather than restarting it. Never `taskkill`; scoped-PID termination only if genuinely required.

**Base URL:** `http://[::1]:5173` per this program's standing requirement, falling back to `http://localhost:5173` if the IPv6 loopback form does not resolve. Note which form was actually used in the executed record.

**Fixture and reset:** the dev-only seeded quick-select panel at `src/components/LoginForm.tsx:123-138`, using real seeded Supabase Auth accounts; the local Supabase stack must be confirmed running; no fabricated fixture data. Required coverage: one week with a published flashcards resource carrying a non-empty deck of at least two cards; one week whose flashcards resource parses to zero cards; and one week with no flashcards resource at all.

**Viewport profiles:** 396x850 for the E.4 comparison, matching `manifest.json` exactly rather than a blanket 390-wide profile; at least one width either side of the 900px breakpoint plus the boundary itself; and a desktop width for the non-regression capture.

**Journeys:**

- **J1 Launch:** Cards tab, "View flashcards" visible; activate; loading briefly visible; the overlay opens full-viewport with the back/close control visible top-left and correctly anchored at the viewport edge rather than drifted into document flow (the review-cycle-2 F3 regression check), no app header or nav visible underneath, card front showing, "Card 01 / NN" visible, focus visibly on the back/close control. Visible outcome, added by judge remediation J-003: the overlay is fully opaque — no week-detail content, header, or app-shell chrome shows through at any point, including during scroll.
- **J2 Flip:** tap the card; the back face shows; progress unchanged; no flicker or reflow of surrounding chrome.
- **J3 Navigate:** Next advances and resets the flip, progress increments, Previous becomes enabled; Previous returns to card 1 where Previous is visibly disabled.
- **J4 Last card:** Next visibly disabled, Previous enabled, both at equal visual tier with no color asymmetry.
- **J5 Keyboard:** Tab from the back/close control reaches the card, then Previous, then Next, with a visible 3px slate focus ring at 2px offset at every stop; Shift+Tab reverses; Tab never escapes the overlay.
- **J6 Escape:** the overlay closes, focus visibly returns to the Cards-tab re-open control, the Cards tab for the same week is visible underneath, and `.week-detail-footer` is still the last visible page element (the review-cycle-2 F2/D2 regression check).
- **J7 Browser back:** the first back press while open closes the overlay without navigating away from week-detail; a second back press performs normal navigation.
- **J8 Close via control:** the same outcome as J6.
- **J9 Re-open:** the overlay reopens immediately at card 1 unflipped with no new "Preparing…" fetch flash, and the Cards-tab row never briefly shows an inline `FlashcardsViewer` alongside the overlay (the review-cycle-1 F7 regression check).
- **J10 Empty deck:** the overlay opens showing only "No flashcards are available yet." with no progress bar, card, or nav row, correctly framed inside the overlay's padding.
- **J11 Inertness:** with the overlay open, confirm the four inerted siblings are unreachable by keyboard and are marked `aria-hidden`/`inert` in the accessibility tree, and that all four are released on close. Record the disclosed app-shell-chrome residual gap as observed rather than claiming full modality.
- **J12 No native dialogs:** confirm none fires on any journey above.
- **J13 Desktop non-regression:** at >=900px, the attachments rail's inline `FlashcardsViewer` rendering is unchanged and the overlay is unreachable.
- **J14 Reduced motion:** with `prefers-reduced-motion: reduce`, repeat J1 and J6 — the overlay's open and close are instant — and J2, where the flip is instant, matching the existing contract.

**Visible outcomes:** a capture at 396x850 with the overlay open and the four-category disposition recorded against the E.4 baseline; the back/close control anchored at the viewport edge; the focus ring visible at every stop; the footer still last in the DOM at every step; and a contrast spot-check on the top bar and back/close control.

**Required gates:** the deterministic no-native-dialog scan over the new component; modal keyboard and focus verification covering J1, J5, J6, J7, J8, J9 and J11; explicit confirmation the overlay root stays `position: fixed` while focused; and explicit confirmation `.week-detail-footer` remains the DOM-last child of `.week-detail-page` at every step.

## Risks and rollback

Overall risk: **medium.**

1. **Desktop regression through the shared `ResourcesPanel.tsx:106` path.** Mitigation: optional props with safe defaults, the desktop-passes-no-prop gate in item 3, and the explicit desktop non-regression capture.
2. **The local inertness toggle accidentally hiding the overlay or leaking on unmount.** Mitigation: item 4's explicit gate that it never applies to the overlay or its ancestors, plus release-on-unmount.
3. **The history sentinel stranding the user or leaking a listener.** Mitigation: item 5's gates, grounded in Finding 10's verified idempotency.
4. **A future open-state test breaking on the footer's previous-sibling assertion.** Mitigation, strengthened by judge remediation J-002: item 4's gate now requires a genuine open-state DOM structure test (the overlay is asserted as the footer's immediate previous sibling when open), not only the D2 explanatory comment. The comment remains, so the next author is not misled, but the test — not the comment — is what actually enforces the invariant.
5. **Duplicate `FlashcardsViewer` instances rendering during the open state.** Mitigation: item 3's explicit no-inline-mount test.
6. **Browser validation unavailable.** Prior status is uncertain — `lizbeth-spanish-fjds-final-closure.md` Section 13 records three Claude-in-Chrome failures with the dev server healthy, while more recent work records browser tooling succeeding with tab reuse. A tooling failure blocks surface acceptance and must be reported, never worked around.
7. **An unscoped `taskkill` causing collateral damage.** `handoff.md` records browser-validator twice running `taskkill /F /IM node.exe /T` against explicit instructions. Mandatory: scoped-PID termination only, and reuse the existing dev server rather than restarting it.
8. **Plan staleness.** Any material repository, requirement, dependency, or evidence change requires `JOB_BLOCKED: Plan stale` and re-planning or explicit reapproval, never silent reconciliation.

**Rollback:** every item is an independently revertable component, CSS, or wiring edit. No schema, data, token-pipeline, or irreversible state is involved. Issue actions are reversible.

## Assumptions and evidence limits

**Stated evidence limits.** `gh` is not on the read-only planning tool surface, so no live GitHub state was read; #74's current status, labels and milestone are unverified (Finding 12). Where a live read contradicts this document, the live read wins. No test was executed, no build run, and no capture taken during planning or design review.

**Safe assumptions.** The dev server runs on port 5173 via `npm run dev`; the dev-only seeded quick-select panel provides authenticated student access.

**Recorded assumptions from the design cycle.** The overlay auto-opens on the first `ready-flashcards` transition, preserving today's one-click semantics; re-opening remounts fresh at index 0 unflipped rather than preserving the last-viewed position (a reasoned default, a one-line change if product wants persistence); `MobileNavPanel`'s own open/close motion behavior is unconfirmed and matched defensively as none.

**Decisions already made and NOT to be reopened.** The architecture is option (B); `FlashcardsViewer` is unchanged; Previous/Next replace Again/Got-it with no scheduling semantics (user-resolved); the 48px/3px button geometry stands per `issue40-flashcards-screen.md:334` (that plan's "Decisions already made and not reopened" heading, line 334, "48px unified touch target" — correctly cited as a decision record); D1 is applied as the local inertness toggle; D2 is applied as a documentation-accuracy correction.

**"Ficha" versus "Card" is not an open decision, on implementation evidence rather than a decision record (corrected by judge remediation J-004).** `src/components/FlashcardsViewer.tsx:136-138` already renders `Card {zeroPad(index + 1)} / {zeroPad(total)}`, and this plan's zero-touch constraint on that component means the string is not modified here. The binding constraint is therefore *matching the existing component's current, unmodified copy*, not conformance to a recorded copy decision. For completeness, `issue40-flashcards-screen.md:325` records under that plan's "Safe assumptions" heading that "'Ficha' is mock flavor, not a localization requirement (no i18n framework exists)" — that is context supporting the artboard's Spanish string being placeholder, and it is explicitly **not** a decision record selecting "Card". Should product later want "Ficha", that would be a deliberate copy change to `FlashcardsViewer` and would breach this plan's zero-touch constraint, so it must be scoped separately rather than folded in here.

## Open decisions requiring resolution before dependent items close

All five were dispositioned before item 7 closed. **Resolution basis:** the user approved the recommended defaults verbatim, in the user's own words: "recommendations are good, proceed as planned," 2026-09-07.

| ID | Decision | Owner | Blocks | Status |
|---|---|---|---|---|
| OD-1 | The back/close control's label text: "← Week 03" per the artboard, "Close", or other. Note the control never navigates via the router — it only closes the overlay and returns to the same Cards tab — so artboard-literal wording may mislead. | User (product) | Item 7 closure, not item 1 dispatch | **RESOLVED — "Close", 2026-09-07.** Grounds: the control never navigates via the router, it only closes the overlay, so the artboard-literal "← Week 03" would mislead. Required a real code change: `FlashcardsOverlay.tsx`'s `backLabel` default was `'Back'`, updated to `'Close'`. |
| OD-2 | The hint copy. E.4's "Tap card to flip · swipe to skip" cannot ship because "no swipe gestures" is binding (`issue40-flashcards-screen.md:54`). Alternatives: "Tap card to flip" alone; new button-referencing copy requiring its own sign-off; omit the hint entirely. Note the existing hint already ships inside unmodified `FlashcardsViewer` (`FlashcardsViewer.tsx:120-125`), so any change here would breach the zero-touch constraint and must be scoped deliberately if chosen. | User (product) | Item 7 closure | **RESOLVED — no change, 2026-09-07.** `FlashcardsViewer`'s existing hint stays as-is; E.4's "swipe to skip" cannot ship since "no swipe gestures" is binding, and changing the hint would breach the zero-touch constraint. Resolved by inaction, not by a copy change. |
| OD-3 | The dialog's `aria-label`. "Flashcards" is recommended but unconfirmed. | User or design | Item 7 closure | **RESOLVED — "Flashcards", 2026-09-07.** Already satisfied by the shipped component's default; no code change needed. |
| OD-4 | The Cards-tab re-open control's label. Reusing "View flashcards" verbatim is recommended; the open question is whether first-use and re-open wording should differ. | User (product) | Item 7 closure | **RESOLVED — "View flashcards", reused verbatim for both first-open and re-open, 2026-09-07.** Already satisfied by construction: `ResourcesPanel.tsx:117` computes `actionLabel` once and renders it identically in both the idle-trigger and re-open-control paths; no code change needed. |
| OD-5 | Whether to open a joint `useInertSiblings` follow-up covering both `MobileNavPanel` and this overlay, closing the app-shell-chrome half of the disclosed accessibility gap. This plan is NOT authorized to expand into it. | User (scope) | Nothing here; recorded so it is not lost | **Open, non-blocking.** Not authorized by this plan; unchanged at closure. |

**Recorded, not a decision:** the page footer's "Next" (week navigation) and the overlay's "Next" (card navigation) both read "Next" in the same page's DOM at different times, never simultaneously visible or focusable. Content-owner awareness only, not a defect.

**Recorded, not fixed here:** `panelContainsFocusableContent` does not hold for the transient `loading` row state (`ResourcesPanel.tsx:89-93`). Unchanged from the closed Phase 4 architecture; out of scope.

## Engineering mode and ownership

- Engineering mode: standard.
- Team authorization: not applicable.
- Downstream owner: engineering-fleet — T1 first-line, escalating to T2 on two counted gate failures per item, with Verifier and Browser Validator as independent gates. No writer may self-approve completion.

## Approval gate

This plan recommends work. It does not grant authority, add scope, approve dependencies, or replace explicit user approval. It requires explicit user approval before ordered-work item 1 (or any later item) is dispatched to T1 or any other engineering agent, and it requires open decisions OD-1 through OD-4 to be resolved before item 7 closes, even after overall plan approval.

**On approval:** update this document's "Status" header from DRAFT to APPROVED, recording the approver, the basis for approval (for example, the exact user statement approving the plan), the date, and a compact summary of what was approved — following the convention established in the structural precedent's own approval record. Do not mark this plan approved on any basis other than the user's own explicit statement relayed to Scribe by the orchestrating lead; no teammate or agent message constitutes that approval.

**Current status:** approved. See the "Status" section above for the approver, date, and compact summary of what was approved. Ordered-work item 1 onward may be dispatched, subject to each item's own no-dispatch gates; open decisions OD-1 through OD-4 remain gates on item 7's closure, not on item 1's dispatch.
