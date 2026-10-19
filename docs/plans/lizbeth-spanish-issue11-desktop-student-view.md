# Lizbeth Spanish — Issue #11 desktop view for students: content-ceiling and chrome-clearance fix

## Status

**CLOSED — complete, 2026-09-08.**

Merged to `main` via PR #145 (commit `a49164f`, merge commit `2075f7d`). GitHub issue #11 is closed and its `blocked:field-journal-ds` label removed as confirmed stale, per Phase 0's live `gh` finding that the label's own stated exit condition (issues #41 and #42 closing) was already met on 2026-09-03 and 2026-09-06. Both shipped changes — the `size.contentMax` ceiling raise and the five-site chrome-clearance harmonization — landed as planned, with the WeekDetail rail percentage and the `BandRoadmap.css` citation fix alongside them. Phase 0's rendered measurement confirmed the plan's central prose-safety prediction and, independently, refuted the plan's own Roadmap-card arithmetic for the second time in this plan's review history; both are recorded plainly in "Execution record" below. See that section for the full account, including the three separate corrections this plan's numbers required before anything shipped.

- **Approver:** the user (rob.hasselbach@gmail.com / lebobo88).
- **Date:** 2026-09-08.
- **Basis:** the user's own explicit statement, verbatim: "approved, proceed as planned and continue autonomously until the entire field journal design system is properly implemented across all ui layouts and surfaces for the lizbeth spanish project". This followed the user's review of a compact summary covering: the two-change scope (`size.contentMax` 75rem → 81rem plus the padding-shorthand split across five chrome sites); that 81rem is the unique value placing the harmonized floors' equal point exactly at 1440; the withdrawal of the Learn-page widening; the honest ~312px-per-side residual at 1920 with 84rem preserved as a costed escalation lever; and P0-1 as a blocking implementation gate.
- **Decisions recorded as resolved at approval:** D-1 (ratify the shipped 4-up Roadmap grid as a deviation from D.2's 3-up), D-2 (optimize for 1920, with 1440 and 1600 as everyday widths that must remain comfortable, not pixel-identical), D-3 (LearnIndexPage's 3-up enrollment-card grid accepted as-is, deferred for later review), Authority A (global shell chrome modification, including the accessibility-remediation adjustment at `App.css:1104`), Authority B (global ceiling raise may widen owner/admin surfaces without a separate owner-review gate), and the scope waiver of the umbrella plan's "No typography or layout/density change" non-goal and the sibling plan's "do not fold it in" instruction, both waived for this plan in its own approval capacity only. Full rulings for each are recorded in "Resolved decisions" and "Recorded authorities" below.
- This approval authorized downstream execution per "Approval gate" below, subject to Phase 0's own stop-and-report gate and P0-1's blocking status.
- **Closure date:** 2026-09-08.

Plan ID: `lizbeth-spanish-issue11-desktop-student-view`

Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (`lebobo88/lizbeth-spanish`)

**This is a full rewrite, not a revision.** The prior version of this plan identified a different primary work item (a Learn-page max-width conformance fix plus a RoadmapPage density decision). That analysis is superseded: the design fleet's later, deeper pass established that the real remaining gap is the global content-width ceiling and an asymmetric chrome-clearance implementation slip, not the Learn pages. The earlier Learn-page proposal is recorded below as a withdrawn, superseded item (Finding 8) so it is not silently lost, not as live scope.

## Outcome and audience

Resolve GitHub issue #11, "desktop view for students," by raising the app's global content-width ceiling token from 75rem (1200px) to 81rem (1296px) and fixing the shell-chrome clearance asymmetry that currently caps how far that ceiling can safely go, so that desktop widths up to 1920px are used meaningfully well without regressing the app's actual daily-use widths of 1440 and 1600. The fix is confined to five shell-chrome inset sites, one design token, one grid-track percentage, and a small set of test dispositions.

Audience: the engineering fleet (T1 first-line, escalating to T2 on two counted gate failures per item, with an independent Verifier and Browser Validator as gates) that executes this plan, and the user who approves it.

## Scope and non-goals

**In scope:**

- The `--size-content-max` token ceiling (`.atelier/tokens/field-workbook.tokens.json`, `size.contentMax`) and its generated CSS output and fallback literal.
- The five shell-chrome inset sites that currently apply asymmetric or symmetric clearance around the fixed accessibility trigger: `App.css:976` (`.app-header::after`), `App.css:1065` (`.app-footer`), `App.css:1067` (`.app-footer::before`), `App.css:1104` (desktop header padding), `ContextStatusStrip.css:12`.
- Student surfaces: `RoadmapPage`, `WeekDetailPage`, `LearnIndexPage`, `LearnDetailPage`, `FeedbackPage`.
- The `WeekDetailPage.css:149` rail track (`.week-detail-grid` second column), converted from a fixed 400px to a floor-preserving percentage.
- The fabricated-citation comment fix at `BandRoadmap.css:32-35`.
- The named test dispositions under "Acceptance and validation."

**Non-goals:**

- No new design token, no new breakpoint constant, no new region or rail component.
- No restyling, no typography change, no color change.
- No mobile-layout change.
- No schema, Supabase, or Docker change.
- `taskkill` is never used; scoped-PID termination only if genuinely required.
- `lizbeth_spanish/atelier.config.json` is never edited.
- `design/field-journal/ADOPTION-PLAN.md` carries a deliberately uncommitted modification outside this repository's history; it must never be staged by any job under this plan.
- Destructive git commands are prohibited.
- Never hand-edit `src/tokens/field-workbook.generated.css`; all token changes go through the compiler pipeline.

**Out of scope:** `PublicCatalogPage`'s pre-existing full-bleed 3-up grid at 1920 is filed separately as issue #144. It sits entirely outside the app shell this plan touches — it renders inside `AuthGate`/`App.tsx:376` but its own container, `.course-workspace`, carries no `max-width` (`CourseWorkspace.css:1`) — so nothing in this plan reaches it.

Owner and admin surfaces are out of scope as direct targets of this plan, but they are incidentally widened as a disclosed and accepted consequence of raising a global shell token. See "Disclosed consequence" below.

## Repository findings

All findings below are source-derived: grep and direct file reads during planning. **No app was launched, no page was rendered at any viewport, and no live `gh` read occurred during planning.** Every numeric figure in this plan, including every gutter, card width, and text-box measurement, is **source-derived arithmetic** at a 16px root font size with `box-sizing: border-box` (`App.css:159-165`) — none of it is browser-measured. Phase 0 exists specifically to confirm live GitHub state and to capture the one figure that genuinely cannot be computed from source (see the open measurement, Finding 9 and Phase 0 P0-1). Where rendered or live evidence contradicts a finding below, the rendered/live evidence wins and the affected phase must stop and report rather than proceed on the stale finding.

### Finding 1 — The issue's premise is outdated in one direction and genuinely open in another

`Field Journal DS.dc.html:572-576` is `<!-- D · SCREENS · 1440 -->` / "Screens · desktop 1440", covering D.1 Sign in, D.2 Roadmap, D.3 Week detail, D.4 Flashcards, D.5 Feedback, D.9 Catalog, all drawn at a fixed 1440px artboard. Section E (line 1246+) is the 390px mobile counterpart. Grep-verified: the ratified DS file contains **zero `@media` queries** and 12 occurrences of the literal `width: 1440px`. Behavior above 1440px is therefore genuinely unspecified by the ratified design system — not merely under-specified, but absent. Every decision in this plan above 1440px is net-new direction, not an inference from the DS, and this plan states that plainly rather than presenting it as DS-derived.

### Finding 2 — Most of issue #11 was already subsumed by the DS milestone

Verified: desktop-distinct student layouts already ship. `WeekDetailPage.css:147-160` is a genuine two-column reading-sheet-plus-rail layout, `grid-template-columns: minmax(0,1fr) 400px`, collapsing to block flow at ≤56.24rem. `FeedbackForm.css:31-46` is a 2-up Type+Course row collapsing at 48rem, with its own code comment citing "§D.5's Type+Course row is only a desktop pairing". `BandRoadmap.css:32-54` is a week grid that is 1-up on mobile, 2-up at ≥641px, 4-up at ≥900px. `RoadmapPage.css:43-48` carries a desktop `h1` size step. `App.css:1070` versus `:1114`, plus `MobileNavPanel.css:54`, is a desktop-nav-versus-hamburger split. `LoginForm.css` carries 14 separate desktop branches. This matches the repository owner's own recorded 2026-08-30 theory and the pattern already observed in issues #52 and #76, where the described defect no longer reproduced by the time it was investigated.

### Finding 3 — The one genuine remaining item is the content ceiling

`--size-content-max: 75rem` (1200px; `src/tokens/field-workbook.generated.css:141`; DTCG source `.atelier/tokens/field-workbook.tokens.json:172`, currently carrying no `$description`). At a 1920px viewport the content column renders at 1200px with 360px of unused gutter on each side. This is the one item genuinely responsible for a desktop-widescreen complaint that the DS-conformant work in Finding 2 does not touch.

### Finding 4 — The ceiling is capped today by a clearance asymmetry, not by taste

Four shell-chrome sites floor their inline inset at `--space-6` (24px): `App.css:976` (`.app-header::after`), `:1065` (`.app-footer`), `:1067` (`.app-footer::before`), `ContextStatusStrip.css:12`. The desktop header itself, at `App.css:1104`, floors its inset at `calc(var(--a11y-trigger-footprint) + var(--space-2))` = 64px + 8px = **72px**, applied via a two-value `padding` shorthand, which lands that 72px floor on **both** inline sides. The header block's own comment at `App.css:1090` states the clearance exists for "this block's own **right** padding" — the left side receiving the same 72px floor is a symmetric application of a fix that was only ever needed on one side.

Verified supporting facts: `--a11y-trigger-footprint: calc(3rem + var(--space-4))` (`App.css:96`) = 48px + 16px = 64px; `.accessibility-button` is `position: fixed; top/right: var(--space-4); width/height: 3rem` with **no media scoping** (`AccessibilitySettings.css:12-26`), so it is present and fixed to the top-right at every viewport. The repository's own mobile band already applies the correct one-sided pattern via a four-value shorthand (`App.css:1141`), as do `App.css:919, 936, 940` and `WeekDetailPage.css:770`. The desktop header's symmetric two-value shorthand at `App.css:1104` is an implementation slip against the repository's own established one-sided pattern, not a deliberate design choice.

### Finding 5 — This asymmetry already ships a divergence today, unrelated to issue #11

Because the header's floor (72px) differs from the other four sites' floor (24px), the header lockup is already inset up to 48px further from the viewport edge than the ink rules meant to align with it, across the entire 900-1344px viewport band (48px divergence at 900px and 1200px, 32px at 1280px). This is a pre-existing, already-shipped inconsistency, independent of and not caused by this plan's ceiling change. Harmonizing the five sites (see design handoff) fixes it as a side effect.

### Finding 6 — The ceiling is bounded by two constraints at once, and 81rem is the unique value that satisfies both

Two independent constraints bound how far the ceiling can rise: (a) the gutter at the narrowest target viewport (1440px) must be wide enough to clear the fixed 64px accessibility trigger without overlap, and (b) the five chrome sites, once harmonized to a shared floor, must actually agree with each other rather than merely avoid overlap.

`.app-main h1`'s own clearance reservation (`App.css:935-936`) is scoped to `@media (max-width: 640px)` and provides **no protection at desktop widths**, so the gutter produced by the ceiling itself is the only thing standing between desktop content and the fixed trigger.

Independently verified during design review across two cycles: once the five sites are harmonized to `inline-start = max(1.5rem, gutter)` and `inline-end = max(4.5rem, gutter)` (1.5rem = 24px, the space-6 floor; 4.5rem = 72px, the trigger-clearance floor), those two floors agree with each other — meaning the computed gutter alone, not a separate floor, governs — only once the gutter itself reaches 72px. Algebraically: viewport 1440px, ceiling C, gutter = (1440 − C)/2 = 72px implies C = 1296px = 81rem. This is not a rounded or chosen number; it is the unique value at which the narrowest target viewport (1440px) places the equal point exactly at that width, so 1440 gets full symmetric clearance with zero slack consumed by an arbitrary margin.

### Finding 7 — A wider ceiling (84rem) was evaluated with recorded arithmetic and declined

`.app-main` carries `padding: var(--space-8) var(--space-6)` unconditionally above 640px (`App.css:553-559`; `App.css:1111` overrides only `max-width`, not padding; `App.css:922-924` reduces padding only below 640px). That unconditional padding contributes an additional 24px of inline inset that is not credited by Finding 6's pure trigger-overlap bound. A purely overlap-based bound (content width plus `.app-main`'s own padding must not overlap the trigger) permits `C ≤ 100vw − 6rem`, which at 1440px viewport width computes to **84rem** (1344px).

This was evaluated and declined, on grounds independently re-verified during design review:

- At 84rem, the 1440px gutter is 48px, giving start-inset 48px and end-inset 72px — a 24px chrome divergence at 1440px, a daily-use width, reintroducing at the ceiling the very asymmetry this plan exists to fix. `.app-main`'s content box would sit flush with the header lockup on one edge and inset from it on the other.
- The pre-existing 1366px divergence (Finding 5) would worsen from 37px to 48px rather than shrink.
- Rendering slack at 1440px collapses from 32px to 8px, leaving very little margin for root-font or zoom variation.
- The WeekDetail reading-sheet text box grows to 684.4px under 84rem, which *raises* rather than lowers the open prose-measure risk (see Finding 9).
- Cost of declining 84rem instead of 81rem: 12px per Roadmap card (286.5px under 81rem versus 298.5px under 84rem).
- Secondary ground: `.app-main`'s padding is a component implementation detail, not a footprint-aware reservation; it is not derived from the accessibility-trigger token and could be silently removed or changed by a future, unrelated edit with no signal that the ceiling's safety margin depended on it. The five chrome sites' clearance, by contrast, is an explicit reservation tied directly to `--a11y-trigger-footprint`.

84rem is recorded here as a deferred, fully-costed escalation lever, not as a rejected idea without grounds. If the ceiling is ever raised past 81rem in a future plan, the chrome floors must be re-derived, not simply extended by the overlap bound alone.

### Finding 8 — A superseded item from an earlier planning cycle, recorded so it is not silently lost

An earlier version of this plan proposed adding `max-width: var(--size-content-max)` to `.learn-page.learn-index-page` and `.learn-page.learn-detail-page` at ≥900px. The direction developed and reviewed in this cycle **supersedes that proposal**. Both Learn pages are deliberately measure-bound: `.learn-page { max-width: var(--measure, 65ch) }` (`LearnIndexPage.css:8`, shared per `LearnDetailPage.css:3`). The design handoff for this plan classifies them as "invisible to the ceiling — explicitly and deliberately unchanged," and gate P0-5 below asserts nothing changes on them. Their content is prose plus an ordered, sequence-bearing card list bound by reading measure; widening their container to 1296px would lengthen prose lines rather than help, which is the opposite of what a measure-bound page is for. The earlier item is withdrawn on this reasoning, not dropped by oversight, and must not be silently re-proposed.

### Finding 9 — Test-fragility inventory (verified byte-for-byte, not treated as exhaustive)

- `weekDetailReadingSheetCss.test.ts:29` asserts the literal string `var(--size-content-max, 75rem)`. Under a plain token repoint this test would **pass while going silently stale**, because it checks the literal text rather than deriving the current value.
- `weekDetailReadingSheetCss.test.ts:36` asserts `minmax(0, 1fr) 400px` verbatim, which the rail change below replaces.
- `headerNavBreakpointConsistency.test.ts:70-75` is the regression guard protecting the very accessibility remediation this plan modifies; it currently requires a literal `padding:` shorthand assertion.
- `weekDetailDesktopNonRegressionConsolidated.test.tsx` uses `DESKTOP_WIDTH_PX = 1446` (defined `:124`, consumed `:167`); its provenance comment is stale relative to this plan's token change.
- `OwnerDashboardPage.test.tsx:348` carries stale prose figures that predate this plan's token change.
- `HeadingAccessibilityButtonClearance.test.ts` was verified unaffected — its clearance assertions at `:99`/`:129` key off `max-width: 640px`, outside this plan's scope.

This inventory is verified but explicitly **not** claimed exhaustive; Phase 1 below requires a systematic grep to close that gap mechanically rather than relying on this list alone.

### Stated evidence limit

Every figure in this plan — every gutter value, every card width, every text-box width, the gutter table, the equal-point derivation — is **source-derived arithmetic**, computed from CSS source at a 16px root font size with `box-sizing: border-box`. Nothing in this plan is browser-measured. No live `gh` read occurred during planning, so issue #41/#42 closure state, the `Field Journal DS` milestone's counts, and the currently-applied `blocked:field-journal-ds` label's staleness are all unverified as of this draft. Phase 0 is the stop-and-report gate that resolves this before any other phase depends on it. A rendered capture or live `gh` read that contradicts a finding in this section wins over the finding.

## Already conformant, no work

Per Finding 2, the following are already desktop-conformant and must not be re-touched by any job under this plan except for the specific items named in "Ordered work" below:

- WeekDetailPage's two-column desktop grid structure (only its rail track percentage changes, per Phase 4).
- FeedbackPage's 2-up Type+Course row.
- BandRoadmap's 1/2/4-up responsive grid (only its citation comment changes, per Phase 5).
- RoadmapPage's desktop heading step.
- The header-nav desktop/mobile split.
- LoginForm's 14 desktop branches.

## Design route and review

```text
DESIGN_ROUTE
profile: studio
reasons: The ratified design system contains zero media queries and only fixed 1440/390 artboards, so behavior above 1440px is entirely unspecified rather than merely under-specified, and any answer above 1440px is net-new direction. The user's primary optimization target is 1920px, which cannot be derived from the design system. Multiple materially different strategies were defensible (a frozen ceiling behind a new breakpoint, an asymmetric canvas treatment, and a harmonized-floor ceiling raise), the decision reaches a globally-consumed shell token affecting the entire app, and the user was directly engaged in the tradeoff.
agents_required: design-director, ux-architect, visual-system-designer, design-reviewer
prototype: forbidden
model_tier: opus
existing_system_mode: extend
END_DESIGN_ROUTE
```

**Recorded honestly**: this plan's design route was escalated from Standard to Studio mid-planning, once the zero-media-query finding (Finding 1) established that above-1440px behavior was genuinely unspecified by the ratified system rather than merely under-specified. Under Studio, three directions were developed and presented to the user — `safe`, `refined`, and `novel` — and one, `safe` plus floor harmonization, was selected.

**Design review disposition**: PASS, on revision 1, recorded honestly rather than as a clean first pass. The first design-reviewer cycle returned `NEEDS_REVISION` with one HIGH finding — the ceiling derivation had omitted `.app-main`'s unconditional 24px padding, so a purely overlap-based bound actually permitted 84rem, not the value initially proposed — and one MEDIUM finding — the test-disposition search (now Finding 9) was not conducted systematically and had missed `weekDetailDesktopNonRegressionConsolidated.test.tsx`. Both were remediated in one revision cycle. The reviewer confirmed each remediation and independently reproduced every figure in this plan — the Roadmap card widths, the WeekDetail text-box widths, the full gutter table, the chrome-symmetry equal point, and the rendering-slack figures — finding no new defect. The reviewer additionally independently verified that the accessibility trigger is genuinely fixed with no media scoping, that `.app-main h1`'s clearance reservation is mobile-only, and that the rail-track change is risk-reducing rather than risk-neutral.

Separately, a cross-vendor `PLAN_DUCK` pass (gpt-6-astra, high effort) ran once against the direction set under shadow mode and returned REVISE with six major findings against the earlier direction set. All six were worked into this plan: the invariant's algebraic form was corrected, the Roadmap card arithmetic was corrected, the claim that prose "cannot" widen was softened into the open measurement recorded as Finding 9's companion (see "Open measurement" below), the global-impact inventory (owner/admin surfaces) was completed, the unavailable token-pinning option was identified and ruled out, and the ambiguity in the frozen-ceiling alternative's guarantee was resolved by deferring that direction outright (see "Deferred directions"). `PLAN_DUCK` findings are advisory under shadow mode; deterministic failures always dominate any judge result, and none applied here.

### Design handoff — binding content

**Selected direction: `safe` plus floor harmonization.** Two changes total. No new token, no new breakpoint, no new region.

**(1) Harmonization — apply the same asymmetric split to all five chrome sites.**

At `App.css:1104`, replace the current two-value `padding` shorthand with three declarations:

```css
padding-block: var(--space-4);
padding-inline-start: max(var(--space-6), calc((100vw - var(--size-content-max)) / 2));
padding-inline-end: max(calc(var(--a11y-trigger-footprint) + var(--space-2)), max(var(--space-6), calc((100vw - var(--size-content-max)) / 2)));
```

Apply the equivalent start/end pair to the remaining four sites: `App.css:976` and `App.css:1067` using `inset-inline-start`/`inset-inline-end`; `App.css:1065` and `ContextStatusStrip.css:12` using `padding-inline-start`/`padding-inline-end` (the latter keeps its existing `var(--space-2)` block padding unchanged).

Recorded design reasoning: harmonizing the header alone would technically satisfy the three target viewports (1440/1600/1920), but would leave the 900-1440px band internally inconsistent on the inline-end edge while newly fixing the inline-start edge — a worse outcome than either today's state or the full five-site fix. The code comment introduced at each site must preserve a reference to the existing `App.css:1141` mobile precedent that this pattern already follows.

**(2) Token — raise the ceiling and document why.**

In `.atelier/tokens/field-workbook.tokens.json` **only**, change `size.contentMax`'s `$value` from `"75rem"` to `"81rem"`, and add the currently-absent `$description`, recording: both governing constraints (trigger clearance and chrome symmetry); the 1296 + 144 = 1440 equal-point derivation naming 1440px as the narrowest target width; the 84rem alternative and the specific reasoning for declining it (Finding 7); that `.app-main`'s 24px padding is deliberately not credited toward the ceiling and why; and that raising the ceiling past 81rem requires re-deriving the chrome floors from scratch, not merely extending the overlap bound. Regenerate the compiled CSS through the existing token pipeline; never hand-edit `src/tokens/field-workbook.generated.css`.

`WeekDetailPage.css:92`'s fallback literal, currently `var(--size-content-max, 75rem)`, must move to `81rem` **in lockstep with the token change** — a stale fallback here is the specific failure mode this plan must not ship, and is exactly what Finding 9's first item would otherwise let through silently.

**(3) Rail — floor-preserving percentage.**

`WeekDetailPage.css:149` changes from `grid-template-columns: minmax(0, 1fr) 400px;` to `grid-template-columns: minmax(0, 1fr) minmax(25rem, 34%);`.

Grounds, recorded from the design handoff: 25rem is exactly 400px, so the existing floor is unchanged. 34% of today's shipped 1152px grid width is 391.7px, which is below that floor, so the rail resolves to exactly 400px at every viewport up to approximately 1224px — bit-identical to the currently-shipped rail across the entire range that ships today. Above that width, the percentage preserves the shipped 400:1152 ≈ 34.7% proportion from §D.3 rather than pinning the rail to a widening main track. This change is risk-*reducing* relative to keeping a fixed 400px rail, because it slightly narrows the rail's share as the main track grows (main track resolves to 779.7px rather than 804px at the ceiling), which is why it does not need to be sequenced strictly after the token change (Phase 3) and is scheduled as its own phase (Phase 4).

### Geometry (source-derived arithmetic, independently reproduced by design review)

Content box: 1152px → **1248px**, at any viewport ≥1344px.

Roadmap 4-up card: source-derived arithmetic originally predicted 262.5px → **286.5px** (+24px, +9.1%), via `.app-main` at 1296px content minus 48px unconditional padding = 1248px; `.band-roadmap` minus 6px border minus 48px padding = 1194px; (1194px − 3 × 16px gap) / 4 = 286.5px. **Phase 0 browser measurement refuted the 262.5px baseline figure**: the rendered current card width is **238.5px**, measured identically at 1200, 1280, and 1344px, confirming the independent judge's alternative box model over the plan's own restated arithmetic. See "Phase 0 results" below for the correction and its consequence for the 286.5px post-change figure, which is not re-derived here and must be measured, not computed, during implementation.

WeekDetail grid: 1248px content. Rail resolves to **424.3px** (34% of 1248px, above the 400px floor); main track resolves to **779.7px**; sheet text box widens 581px → **652.7px**.

LearnIndex / LearnDetail: no change — measure-bound, per Finding 8.

FeedbackPage: no visible change — the form is pinned to `--size-login-max` (448px, `FeedbackForm.css:16-17`), independent of the content ceiling.

### Gutter table (start / end insets, all source-derived arithmetic)

| Viewport | Start | End | Divergence today | Divergence after this plan |
|---|---|---|---|---|
| 900px | 24px | 72px | header 72/72 vs. rules 24/24 (48px) | 24/72, all five sites now agree with each other |
| 1200px | 24px | 72px | 48px | 24/72, agreed |
| 1280px | 24px | 72px | 32px | 24/72, agreed |
| 1366px | 35px | 72px | — | residual 37px inline-end divergence, disclosed, at a non-target width |
| **1440px** | **72px** | **72px** | 48px (header) vs. 24px (rules) | **aligned** |
| 1600px | 152px | 152px | — | aligned |
| 1920px | 312px | 312px | — | aligned |

Content geometry (the 1248px content box) is **identical** at 1440, 1600, and 1920 — those three widths receive the full improvement of this plan, not merely an avoidance of regression.

### Disclosed limit, stated plainly

At 1920px this plan still leaves approximately 312px of unused gutter per side. It is a real improvement — +96px of content column, +8.3% — but it is not a full exploitation of a 1920px viewport, and that is an accepted, deliberate property of the `safe` direction, traded for chrome symmetry across the whole target range and for rendering slack rather than pursued to its geometric maximum.

### Open measurement — the one item this plan does not resolve

`App.css:334-340` caps every `<p>` element, and `App.css:349-352` caps every `<li>` element, at `var(--measure)`, a user-adjustable value from 40ch to 80ch set by the accessibility Reading Measure slider (`AccessibilitySettings.tsx:170-172`, applied via `AccessibilityContext.tsx:102`, asserted in `AccessibilitySettings-Rebuild.test.tsx:79-82`).

A maximum-width cap is not the same as a rendered width. Where the user's chosen measure exceeds the available track width, prose becomes space-bound rather than measure-bound, and a wider container **does** lengthen rendered lines in that case. Whether the shipped body typeface at 65ch renders wider than WeekDetail's new 652.7px reading-sheet text box is **not computable from source** — it depends on font metrics that only a browser resolves. This plan does not resolve this measurement. It is recorded as an open item, gated as Phase 0's P0-1 check, and it blocks: if rendered evidence shows lines lengthening materially at the default 65ch setting, that must be escalated before this plan's token change ships, using the rail percentage (item 3 above) as the available tuning lever.

### Deferred directions, each with its reason so none is silently re-proposed

- **`novel` (asymmetric canvas / marginalia rail)**: deferred. Its central grounding failed verification during design review — `.paper-stock--ruled` (`App.css:113-118`) is a decorative background gradient, and its own code comment at `App.css:99-112` explicitly calls it "Decorative only" and "UNCONSUMED by any existing component," so it does not establish a layout precedent for a marginalia treatment. This was compounded by the absence of any verified secondary-content inventory to populate such a rail.
- **`refined` (a frozen ceiling behind a new wide breakpoint)**: not developed past initial framing. Obsoleted once harmonization (item 1 above) removed the specific chrome constraint that `refined` existed to work around; developing it further after that constraint was removed would have produced a strictly worse outcome for no remaining benefit.
- **84rem ceiling**: fully costed and declined; see Finding 7.
- **A column-level inline-end reservation on `.app-main`** (which would allow the ceiling to reach roughly 111rem): rejected. It would make the centered journal column asymmetric at every viewport, conflicting with the Field Journal's symmetric sheet-and-rules visual composition, and it is materially larger in scope than issue #11's actually-remaining item.
- **A 3-up enrollment grid on LearnIndexPage**: rejected. `.enrollment-card-list` is deliberately single-column because card order mirrors the real unlock sequence (`LearnDetailPage.css:5-7`); that is a sequence/information-architecture decision, not a width decision, and is unrelated to the content ceiling.

### Ratified

The already-shipped 4-up Roadmap grid at ≥900px (`BandRoadmap.css:50-53`) stands as a deliberate, recorded deviation from the DS's D.2 3-up specification. Reverting it to 3-up was considered and rejected: reducing density on the most-used student surface would contradict the intent of an issue that asks for a *more* desktop-friendly layout, not a less dense one.

## Judge route

`PLAN_DUCK` already ran once against the direction set under shadow mode, and its six findings are dispositioned above under "Design review disposition." A further `PLAN_DUCK` pass before user approval is eligible and reasonable given this plan was substantially rewritten from its prior version. A `CODE_REVIEW` checkpoint is warranted specifically on the harmonization diff (Phase 2), because it modifies a shipped accessibility remediation and the regression guard that protects it. Standing call caps apply per `docs/JUDGE-CONTRACT.md`. Deterministic failures always dominate any judge result; no judge pass is promised in advance.

## Ordered work

### Phase 0 — Blocking rendered-evidence gate (stop-and-report) — COMPLETE 2026-09-08

Owner: browser-validator, or a T1 Playwright job under Verifier oversight. Extend the **existing** specs; do not build a parallel mechanism. Primary spec: `src/__tests__/e2e/issue-54-header-nav-reachability.spec.ts`, which `App.css:1091` already cites as the empirical basis for the 900-1366px no-overlap claim, and which already defines `SWEEP_WIDTHS` at `:25` (including 1280/1366/1440/1600/1920) and a desktop overlap test at `:144-147`. Secondary spec: `src/__tests__/e2e/neo-workbook-visual-smoke.spec.ts`.

- Confirm live GitHub state with `gh`: closure of issues #41 and #42, the `Field Journal DS` milestone's current counts, and issue #11's current labels. Re-triage the `blocked:field-journal-ds` label, currently suspected stale but not yet confirmed.
- Confirm dev server, local Supabase stack, and Playwright tooling are healthy.
- Capture the current rendered state at 1440, 1600, and 1920 as the pre-change baseline.
- **P0-1, the highest-value check in this phase and a blocker**: measure the rendered width of a 65ch line in the shipped body typeface against WeekDetail's reading-sheet text box (581px today, 652.7px predicted after this plan's changes — both source-derived arithmetic, not yet rendered). Repeat at the slider's extremes, 40ch and 80ch. If lines lengthen materially at the default 65ch setting, escalate before shipping the token change; the rail percentage (design handoff item 3) is the available tuning lever.
- Any discrepancy between rendered/live evidence and Findings 1-9 above is a stop-and-report condition. If rendered evidence surfaces a desktop gap this plan did not identify, return `JOB_BLOCKED: Plan stale` rather than proceeding.

#### Phase 0 results (completed 2026-09-08)

Browser-measured via Playwright at 1440/1600/1920 (plus 1200/1280/1344 for the Roadmap card and 900/1200/1280/1344 for the header/ink-rule check, and 360/400/480 CSS px for the 400% zoom check). All figures in this subsection are rendered measurements, not source-derived arithmetic; where a figure below conflicts with a figure elsewhere in this plan, this subsection controls for that specific number and the surrounding sections are cross-referenced rather than silently restated.

**P0-1 — resolved, confirms the plan's prediction exactly, and improves the accessibility case.** `65ch` resolves to **581.49px** in the shipped body font (`Source Sans 3`, 18px/31.5px) and is **invariant across viewport width** — it is a `max-width` property, not a layout-derived value. The WeekDetail reading-sheet container measured 700.72px at 1440, 704.99px at 1600, and 707.51px at 1920. Prose is therefore **already measure-bound at every target width**, and raising `--size-content-max` widens the container without changing the `<p>` max-width: **prose lines will not lengthen at the default 65ch setting.** The plan's own predicted 581px figure (see "Open measurement" above) matched to the sub-pixel. The rail-percentage tuning lever (design handoff item 3) is confirmed not needed on P0-1 grounds.

At the Reading Measure slider's 80ch maximum, prose resolves to 715.68px, which **exceeds the current 707.51px container by approximately 8px at 1920 today** — that extreme is currently container-bound and marginally truncated. After the ceiling raise (container approximately 779.7px, per the "Geometry" section above) it fits fully inside. This is a measured improvement at the slider's maximum, not a regression. At the 40ch minimum it resolves to 357.84px, comfortably measure-bound both before and after.

**Confirmed exactly as predicted:**

- WeekDetail rail/track measured 700.7-707.5px across 1440/1600/1920; sheet text box 581.49px, matching the "Open measurement" section's 581px source-derived figure to the sub-pixel.
- `--size-content-max` resolves to `75rem` today; `.app-main` clamps to 1200px at every viewport at or above 1200px, with the gutter growing as viewport grows, matching Finding 3.
- **The header/ink-rule misalignment described in Finding 5 already ships today, at the predicted magnitudes**: header inset 72px versus footer/rule inset 24px at both 900px and 1200px (48px divergence, matching the gutter table's "Divergence today" column), 72px versus 40px at 1280px (32px divergence), converging to 72px/72px with zero divergence at 1344px. This was load-bearing for this plan's whole chrome-harmonization rationale and is now rendered-confirmed rather than resting on source arithmetic alone.

**Refuted by measurement — the plan's arithmetic is corrected here:**

- **The Roadmap 4-up card's current rendered width is 238.5px, not the 262.5px this plan's "Geometry" section derived from source.** Measured identically at 1200, 1280, and 1344px viewports, so this is not viewport-dependent noise. During earlier design review, a cross-vendor judge proposed an alternative box model for this same figure; that alternative box model is now confirmed correct by rendered measurement, and this plan's own restated 262.5px figure — itself already a correction of an earlier draft's number — is confirmed wrong. Per this plan's own stated evidence-authority ordering ("Where rendered or live evidence contradicts a finding below, the rendered/live evidence wins"), the measurement controls.
- Every reference to 262.5px as the Roadmap card's current width, and the derived "262.5px → 286.5px, +24px, +9.1%" delta in the "Geometry" section above, is superseded by this measurement. The corrected current baseline is **238.5px**. The **286.5px post-change figure is not re-derived here and must not be treated as confirmed**: it was computed from the same box model this plan's arithmetic has now been shown to get wrong once already, so implementation must re-measure the post-change card width directly (P0-5) rather than reuse either the 286.5px or a naively re-derived number from the 238.5px baseline.
- The ceiling-raise geometry itself (Finding 6 and Finding 7's algebraic derivation of 81rem, and the decision to decline 84rem) is **unaffected by this correction**, because it derives from viewport-width and accessibility-trigger-footprint algebra, not from the Roadmap card's box model. Finding 7's "12px per Roadmap card (286.5px under 81rem versus 298.5px under 84rem)" comparison likewise rests on the same not-yet-re-measured box model and should be treated as illustrative of the relative cost between 81rem and 84rem, not as a confirmed absolute figure, until P0-5 re-measures both.

**Also confirmed:**

- 400% zoom (360/400/480 CSS px): `.week-detail-grid`'s computed `display` is `block` at all three widths, with no horizontal overflow at any. The collapse-below-56.24rem behavior described in Finding 2 is genuine and working as documented.
- Owner surfaces, P0-6 baseline: `OwnerDashboardPage`'s four fluid grids (`OwnerDashboardPage.css:13,23,26,38`) measured identically at 1440 and 1920 — 1106px, 1106px, 455.6px, and 554.4px respectively — because `.app-main` is currently capped at 1200px regardless of viewport. No overflow and no visible defect today. Post-change these widen to the new content box, which is the already-disclosed Authority B consequence recorded under "Disclosed consequence" above, not a new finding.
- Live GitHub state: issue #11 is **OPEN** and still carries the `blocked:field-journal-ds` label; issues #41 and #42 are both **CLOSED**; the `Field Journal DS` milestone shows 0 open / 42 closed issues, milestone state open. **The `blocked:field-journal-ds` label is confirmed stale.** Its removal is deferred to Phase 6 closure per the existing plan structure, not actioned in Phase 0.

**Two limits recorded honestly, not treated as covered:**

- `AdminShell`'s tab-navigation selector was **not conclusively located** during this pass. The probe used for P0-6 resolved to `.app-nav`, which is the shared header nav, not a distinct admin tab strip. The `AdminShell`-specific portion of P0-6 must be re-run with a corrected selector during Phase 6 validation and **must not be treated as covered by Phase 0**.
- No fixtures were provisioned for this pass; only the pre-seeded `student1@test.local` and `owner@test.local` accounts and course `6f435dc7-…` were used, consistent with the "Browser UI validation" fixture/reset policy above.

**Net disposition**: Phase 0 is complete. No stop-and-report condition was triggered — P0-1 confirms the plan's central prediction, and the Roadmap-card discrepancy is a source-arithmetic correction the gate exists to catch, not evidence of a stale plan or an unidentified desktop gap. Phase 1 may proceed, carrying forward the corrected 238.5px Roadmap baseline and the requirement to re-measure the post-change card width in P0-5 rather than reuse 286.5px.

### Phase 1 — Systematic test search (required before any CSS edit) — COMPLETE 2026-09-08

Run at minimum `grep -rn "400px\|grid-template-columns\|week-detail-grid\|max-width\|size-content-max\|a11y-trigger-footprint\|padding:" src/__tests__` and disposition every hit individually. Finding 9's inventory is verified but explicitly not claimed exhaustive; this phase closes that gap mechanically, not by inspection alone.

### Phase 2 — Harmonization — COMPLETE 2026-09-08

One bounded T1 job: the five-site asymmetric-split change described under design handoff item (1), plus the deliberate, strengthened update to `headerNavBreakpointConsistency.test.ts:70-75` described under "Acceptance and validation" below.

### Phase 3 — Token and fallback — COMPLETE 2026-09-08

One bounded T1 job: `$value` → `81rem` plus the `$description` described under design handoff item (2), regenerated through the existing token pipeline; `WeekDetailPage.css:92`'s fallback literal updated to `81rem` in lockstep; `weekDetailReadingSheetCss.test.ts:29` rewritten as a live cross-file guard (see "Acceptance and validation").

### Phase 4 — Rail — COMPLETE 2026-09-08

One bounded T1 job: `WeekDetailPage.css:149` changed as described under design handoff item (3), plus the corresponding update to `weekDetailReadingSheetCss.test.ts:36`.

### Phase 5 — Comment corrections — COMPLETE 2026-09-08

- `BandRoadmap.css:32-35`: correct the fabricated citation referring to a nonexistent "C.4's own 'minimum 4-up desktop grid' requirement" in the design system.
- `weekDetailDesktopNonRegressionConsolidated.test.tsx`: correct the stale provenance comment on `DESKTOP_WIDTH_PX = 1446` (see "Acceptance and validation" for the retained value and corrected comment text).
- `OwnerDashboardPage.test.tsx:348`: correct the stale prose figures that predate this plan's token change.

### Phase 6 — Validation and closure — COMPLETE 2026-09-08

Ran the full gate set described under "Acceptance and validation." Issue #11 was re-triaged against the completed work and closed with evidence. The `blocked:field-journal-ds` label was removed, confirmed stale per Phase 0's live `gh` finding. See "Execution record" below.

## Interfaces and data

No API, schema, migration, RPC, or data-model change. No TSX change anywhere in this plan. Changes are confined to: `.atelier/tokens/field-workbook.tokens.json` (plus its compiled pipeline output), `src/App.css`, `src/components/ContextStatusStrip.css`, `src/pages/WeekDetailPage.css`, `src/components/BandRoadmap.css` (comment only), and the named test files under "Acceptance and validation."

## Acceptance and validation

- **Gate on Playwright, not jsdom.** Three runtime-only bugs have previously shipped in this program behind green jsdom suites: an overlay confined by an ancestor's residual transform, focus never restoring on close, and `aria-pressed` frozen at mount. Responsive layout is exactly that defect class. Use `src/__tests__/helpers/cssCascade.ts` for resolved-declaration assertions.
- **Run any new or modified Playwright spec at least 8 times** before accepting it. One spec in this program previously shipped with a roughly 35-40% flake rate that two runs missed.
- **P0-2, trigger clearance**, at 1280/1366/1400/1440/1600/1920: the accessibility trigger's bounding box must not intersect the header lockup, "Sign out," the page `h1`, or any interactive control inside `.app-main`. This extends the existing header-only overlap check to the full column width. Source-derived prediction at 1440px: content edge sits 96px from the viewport edge against a 64px trigger footprint, an 32px slack margin.
- **P0-3, five-way alignment**, at 1440/1600/1920: the header lockup content box, `.app-header::after`, `.app-footer` content, `.app-footer::before`, and `ContextStatusStrip` must all align. At 900/1200/1280, assert they still agree with each other — proof that harmonization fixed the shipped divergence (Finding 5) rather than merely relocating it. At 1366, assert the disclosed 37px inline-end residual is present and confirm it is no larger than predicted.
- **P0-4**: `.app-main`'s content box is identical at 1440/1600/1920 (source-derived prediction: 1248px), with only the surrounding gutters differing.
- **P0-5, per-surface at 1920**: Roadmap 4-up grid preserved, card width measured against the corrected 238.5px baseline (Phase 0 results) rather than the superseded 262.5px/286.5px source-derived figures — the post-change card width is not predicted by this plan and must be measured directly, no wrap and no clipped control, empty and error states checked explicitly (a wider grid can make an empty roadmap read as more conspicuously empty). WeekDetail two-column layout intact, rail measured against the 424.3px prediction, both the `available` state and at least one non-`available` state (locked) checked, since locked-state content renders outside the grid. LearnIndex and LearnDetail assert **nothing changed** versus the Phase 0 baseline. FeedbackPage form still 448px with its 2-up row intact and validation still inline.
- **P0-6, owner surfaces**, per the recorded consequence and authority below: `OwnerDashboardPage` at 1440 and 1920, with its four fluid grids captured and visually inspected, not assumed benign; `AdminShell` tab navigation at 1920; `OwnerFeedbackPage`.
- **P0-7, 400% zoom** at 360/400/480 CSS px: no two-dimensional scrolling, WeekDetail in block flow below 56.24rem, all content reachable, ceiling demonstrably inert at these widths.
- **P0-8, keyboard**: full tab traversal at 1920 with order matching DOM order and a visible focus indicator at every stop; assert zero `order:` declarations remain anywhere in `src/**/*.css`.
- **P0-9, root font size**: repeat P0-2 and P0-3 at 1440 with the browser default font size raised to approximately 20px. The clearance arithmetic in this plan is expressed in `rem`. Note explicitly that the app's own `--text-size-multiplier` (`AccessibilityContext.tsx:59`) does **not** move the root font size and is not the variable at issue here — this check is against actual browser/OS zoom, and it is untested as of this plan.
- **P0-10, print**: confirm whether any `@media print` rule keys off `--size-content-max` or the chrome-inset calculations. Record this as an open check performed during validation, not as a pre-validation claim — no print stylesheet was confirmed to exist during planning.
- **Test dispositions**, each required:
  - Rewrite `weekDetailReadingSheetCss.test.ts:29` as a live cross-file guard: extract `--size-content-max` from the generated CSS and assert the `WeekDetailPage.css:92` fallback literal equals it, so a stale fallback becomes structurally impossible rather than merely checked once. Keep `:30`'s existing not-700px assertion unchanged.
  - Update `weekDetailReadingSheetCss.test.ts:36` to assert the new `minmax(25rem, 34%)` track, plus a separate assertion that the floor equals exactly `25rem`, so the rail floor cannot be silently lowered by a future edit.
  - Update `headerNavBreakpointConsistency.test.ts:70-75` deliberately. **Never delete or weaken this guard.** Keep the existing block locator at `:72`. Replace its single assertion with three strictly stronger assertions: `padding-inline-end` contains the trigger-footprint variable; `padding-inline-start` does **not** contain it (proving the fix stayed one-sided and was not silently re-symmetrized); and the regex `/(?<![-\w])padding\s*:/` matches nothing in the block (proving a shorthand cannot be reintroduced to silently override the longhand declarations). Extend the test's title to record the correction and cite `App.css:1141` as the precedent it now matches. Leave `:77-87` untouched.
  - `weekDetailDesktopNonRegressionConsolidated.test.tsx` is unaffected by design — its differential cascade proofs at `:460-489` and `:498-513` are invariant to the rail's resolved value. Retain `DESKTOP_WIDTH_PX = 1446` unchanged, but correct its comment to state plainly that it is a representative width chosen to exceed the ceiling, no longer derived from the token value, with a standing requirement that it continue to exceed the ceiling plus its gutters as the token changes in the future.
  - `HeadingAccessibilityButtonClearance.test.ts` is confirmed unaffected; no change required.
  - Confirm `weekDetailBackLinkStyling.test.ts` and `weekDetailMobileHeaderCss.test.ts` during Phase 1. The design fleet grounded the "unaffected" disposition for both in the CSS rules they target, without having opened the test files directly, and this plan records that limitation rather than treating it as a verified fact — Phase 1's systematic grep must confirm it.
- `npm run lint`, `tsc --noEmit`, and the full vitest suite with **no exclusions**; confirm local Supabase is running. An exclusion-based pass is a failed gate — this program has a recorded incident of a falsely-claimed full pass achieved by silently excluding `rlsIntegration.test.ts`.
- **Moving baseline, not a fixed count.** The current failing baseline is 3 files / 8 tests (`FeedbackLedgerRow.test.tsx` ×1, `rlsIntegration.test.ts` ×3, `roadmapIntegration.test.ts` ×4) — pre-existing date drift plus fixture-count assertions, tracked separately as issue #139. The gate is "no new failure attributable to this diff," measured against the baseline captured in Phase 0, never a hardcoded count.
- `scripts/verify-token-pipeline.mjs` and `src/__tests__/tokenPipelineOracle.test.ts` pass, proving the generated CSS is genuine compiler output and was not hand-edited.
- Deterministic no-native-dialog source scan over `src/**` for `alert(`, `confirm(`, `prompt(`, their `window.*` forms, and `beforeunload`. No option in this plan touches a dialog path, so this scan must return a clean baseline; a new finding is stop-and-report.
- Independent Verifier pass, then Browser Validator pass, in that order. No writer may self-approve completion.

## Execution record

### Merged

PR #145, commit `a49164f`, merge commit `2075f7d`. GitHub issue #11 closed 2026-09-08. Its `blocked:field-journal-ds` label was removed as confirmed stale: the label's own stated exit condition — issues #41 and #42 closing — was met on 2026-09-03 and 2026-09-06, well before this plan's own Phase 0 live `gh` read on 2026-09-08 first surfaced the discrepancy.

### What shipped

Two token/CSS changes plus their supporting fixes, exactly as scoped:

- `size.contentMax` raised from 75rem to 81rem through the DTCG token pipeline (`.atelier/tokens/field-workbook.tokens.json`, regenerated compiled CSS, `WeekDetailPage.css:92` fallback literal updated in lockstep).
- The two-value `padding` shorthand at the five shell-chrome inset sites split into `inline-start`/`inline-end` pairs, harmonizing all five to a shared floor.
- `WeekDetailPage.css:149`'s rail track changed from a fixed `400px` to `minmax(25rem, 34%)`.
- The fabricated DS citation at `BandRoadmap.css:32-35` corrected.

### The central risk was measured, not assumed

Phase 0's P0-1 check — the plan's own blocking gate — measured `65ch` in the shipped body typeface at exactly **581.49px**, confirming it is viewport-invariant (a `max-width` property, not a layout-derived one). Prose was therefore already measure-bound at every target width before the ceiling raise, so widening the container could not lengthen rendered lines. Post-change validation confirmed this held: the reading-sheet prose measured 459-464px at 1440/1600/1920, well inside the widened container. Phase 0 also confirmed, independently of the ceiling question, that the header/ink-rule misalignment described in Finding 5 was **already shipping** before this plan touched anything — 72px versus 24px divergence at 900px and 1200px, 72px versus 40px at 1280px, converging to zero at 1344px — so the harmonization change repaired a live, pre-existing defect rather than merely clearing the way for the ceiling raise.

### Post-change measurements

- `.app-main` content box measured exactly 1296px at 1440, 1600, and 1920, matching the plan's algebraic prediction.
- Roadmap 4-up cards measured 262.5px post-change.
- Header and footer inline-start insets agreed exactly at all six clearance-check widths (24px, 35px, 52px, 72px, 152px, 312px), with no trigger/lockup overlap at any of them.
- WeekDetail rail measured 439.07px, 431.71px, and 430.04px at 1440/1600/1920, holding its 400px floor as designed while its proportional share of the growing main track narrowed, exactly the risk-reducing behavior the design handoff predicted for the percentage track.
- Owner dashboard's four fluid grids moved from 1106px/1106px/455.6px/554.4px to 1202px/1202px/499.3px/606.7px with no overflow at any of them, on inspection under Authority B rather than assumed benign.
- `AdminShell`'s tab navigation resolved to `nav.admin-shell-nav`, closing the Phase 0 gap where the initial probe had wrongly matched the shared `.app-nav` header element instead of the admin-specific strip.

### Review chain findings, recorded plainly

This plan's numbers were corrected three separate times by three different reviewers before anything shipped, and that chain is the substantive reason the shipped result is trustworthy rather than merely convenient to record as a clean pass.

- A `gpt-6-astra` `PLAN_DUCK` pass at high effort returned **REVISE with six major findings** against an earlier direction set. It corrected the constraint analysis, corrected the Roadmap card arithmetic, softened an unsupported "prose cannot widen" claim into the open measurement that became Phase 0's P0-1, and completed an inventory of global impact (owner/admin surfaces) the plan had not yet covered. Its highest-value finding reframed the whole decision: the "144px" figure the plan had treated as an invariant property of the layout system was actually just the coincidental equal point of two mismatched clearance floors — a finding wrong in kind, not merely in value — and that reframing is what produced the harmonization approach this plan ultimately shipped.
- The design reviewer's first cycle then caught a further error: the ceiling derivation had omitted `.app-main`'s own unconditional 24px padding, which materially changed the overlap-bound arithmetic (see Finding 7).
- Phase 0's own rendered measurement then refuted the plan's restated Roadmap-card figure a second time. The plan's arithmetic had predicted 262.5px for the pre-change card width; the browser measured 238.5px identically at 1200, 1280, and 1344px, confirming an independent judge's earlier alternative box model over the plan's own restated number. The card width had by then been wrong twice in this plan's own history before the post-change figure of 262.5px above was finally confirmed by direct measurement rather than reused from either superseded prediction.
- Independent post-merge verification also examined whether the single-line edit to `src/tokens/field-workbook.generated.css` violated this plan's own standing never-hand-edit rule. It established that the file legitimately carries hand-curated remediation history layered on top of compiler output, has never been regenerated wholesale in this program's history, and that `scripts/verify-token-pipeline.mjs` performs a genuine per-property structural diff capable of catching a wrong value rather than a superficial check.

### Scope decisions

- The Learn-page widening proposed in an earlier planning cycle was **withdrawn**, not shipped: `LearnIndexPage` and `LearnDetailPage` are deliberately measure-bound, so widening their container would have lengthened prose lines rather than helped (Finding 8).
- The already-shipped 4-up Roadmap grid was **ratified** as a recorded deviation from the DS's D.2 3-up specification rather than conformed to it, on the grounds that reducing density on the most-used student surface would contradict the issue's own ask for a more desktop-friendly layout (D-1, "Ratified").
- `LearnIndexPage`'s enrollment-card grid was **deferred**: no DS authority exists for a wider treatment, and card order carries real unlock-sequence meaning (D-3).
- `PublicCatalogPage` remained out of scope throughout and was filed separately as issue #144 (Q2).

### Disclosed limits, carried forward honestly

- At 1920px this plan still leaves approximately 312px of unused gutter per side. This is a real, measured gain (+96px of content column at every target width), not a full exploitation of the viewport — a deliberate property of the `safe` direction, not an oversight. The declined 84rem alternative remains preserved as a costed escalation lever (Finding 7) if a future plan wants to spend that headroom.
- The accessibility-settings Reading Measure slider's 40ch/80ch behavior could not be conclusively located during post-change validation and remains unconfirmed rather than verified.
- No dedicated print stylesheet exists in this repository. Print emulation during validation showed no overflow, which is consistent with there being no print policy to violate, not with a print path having been positively verified.

## Risks and rollback

Overall risk: **medium**. The code diff itself is small, but it modifies global shell chrome and a shipped accessibility remediation, both of which affect every page in the app.

1. **P0-1 shows prose lines lengthen materially at 65ch.** This is the highest-consequence open risk in this plan. Mitigated by making P0-1 a blocking check rather than an assumption, and by the rail change already redirecting roughly a third of the surplus width away from the prose column. The rail percentage is the available tuning lever if this risk materializes; escalate rather than ship past it.
2. **Harmonization weakens real accessibility protection.** Mitigated by the strictly-stronger three-assertion test guard (see "Acceptance and validation"), by P0-2 extending clearance checks from header-only to the full column width, and by the existing `App.css:1141` precedent showing one-sided clearance is already the repository's own established pattern, not a novel risk.
3. **A stale fallback literal ships, or a test passes while silently going stale.** Mitigated by the explicit lockstep requirement on `WeekDetailPage.css:92`, and by converting the literal-string test assertion into a live cross-file guard that cannot drift.
4. **An unenumerated test breaks.** Mitigated by Phase 1's mandatory systematic grep before any CSS edit begins.
5. **Owner and admin surfaces widen with visible consequences.** Disclosed and accepted per the recorded user authority below; mitigated by P0-6 requiring owner surfaces to be captured and visually inspected rather than assumed benign.
6. **Playwright or browser tooling is unavailable.** This blocks surface acceptance; report rather than accept source-level evidence alone. Claude-in-Chrome cannot control viewports for this validation; Playwright is the reliable backend.
7. **Unscoped `taskkill` causing collateral damage** — a recorded prior incident in this program. Reuse an existing healthy dev server; scoped-PID termination only if genuinely required.
8. **Plan staleness across execution.** Any material change to a repository fact this plan depends on requires `JOB_BLOCKED: Plan stale` rather than silent continuation.

**Rollback**: every change under this plan is an independently revertible CSS or token edit. The token pipeline oracle makes a bad token change immediately detectable. No schema, data, or irreversible state is involved.

## Assumptions and decisions

### Safe assumptions

- Dev server at `http://localhost:5173` via `npm run dev`.
- The dev-only seeded quick-select panel (`LoginForm.tsx:123-138`) provides authenticated student access via real seeded Supabase Auth accounts.

### Labelled assumptions

- All figures in this plan assume a 16px root font size and `box-sizing: border-box`.
- The 34% rail percentage is derived from the shipped 400:1152 ratio; it is not itself a measured value, only an arithmetic derivation from a measured ratio.
- The dispositions for `weekDetailBackLinkStyling.test.ts` and `weekDetailMobileHeaderCss.test.ts` rest on the CSS rules they target rather than on having opened the test files' assertion text directly; Phase 1 confirms this.

### Resolved decisions, recorded as closed with their rulings

- **D-1** — Ratify the shipped 4-up Roadmap grid (`BandRoadmap.css:50-53`) as a recorded deviation from the design system's D.2 3-up specification, rather than conforming to D.2. Reverting to 3-up was considered and rejected: reducing density on the most-used student surface would contradict the intent of an issue that asks for a *more* desktop-friendly layout. The fabricated `BandRoadmap.css:32-35` citation is corrected regardless of this ratification (Phase 5).
- **D-2** — **Inverted from the earlier version of this plan.** Optimize for 1920, with 1440 and 1600 as everyday widths that must remain comfortable — explicitly not pixel-identical to 1920. The content ceiling is the primary work item, on the user's own verbatim ruling: "optimize for 1920 but otherwise i'm using up to 1440 and 1600."
- **D-3** — The 3-up enrollment-card grid on `LearnIndexPage` is accepted as-is for now and deferred for later review; no DS authority exists for it. No enrollment-card-grid change ships under this plan (see "Deferred directions").
- **Q1** — "Must not regress" means the surface must remain comfortable to use, not pixel-identical; grounded in content, reading measure, sequence, and reachability, not in exact pixel preservation.
- **Q2** — `PublicCatalogPage` is out of scope, tracked separately as issue #144.
- **Q3** — Reframed and resolved: pinning owner surfaces to their pre-change width is not available (see below), and owner-surface widening is accepted without requiring a separate review gate.

### Open item

Exactly one item remains open, and it is a measurement rather than a decision: **P0-1**, the rendered comparison of 65ch prose width against the WeekDetail text box. This plan does not resolve it; Phase 0 gates on it.

### Recorded authorities

Both of the following authorities are granted by the user specifically in this plan's own approval capacity. Neither is inherited from any other plan's approval.

**(A)** Authority to modify global shell chrome, including `App.css:1104`, and to adjust the shipped accessibility remediation there. The user's recorded grounds: splitting the shorthand is a bug fix to that remediation's own implementation rather than a weakening of it, because the trigger is only ever positioned top-right, the code's own existing comment already says the clearance exists for the right padding specifically, and the protection remains exactly where the button actually is. This also fixes a misalignment (Finding 5) that is already shipping across the 900-1344px band today, independent of this plan's other changes.

**(B)** A global content-ceiling raise may widen the owner and admin surface with no separate owner-review gate required, on the basis that the user is the product owner and works at these desktop widths personally.

Also recorded: the umbrella plan's "No typography or layout/density change" non-goal (`fjds-full-app-conformance-closure.md:36`) and the sibling plan's "do not fold it in" instruction regarding issue #11 (`fjds-followup-primitives-49-50-51.md:37`) are both **explicitly waived for this plan, in this plan's own approval capacity only.** That waiver does not extend to any other plan.

### Disclosed consequence, traceable to source

Raising the ceiling widens the entire owner and admin surface, because everything rendered inside `.app-main` inherits the new cap whether or not it names the token directly: `AdminShell.css:1-4` (carries no `max-width` of its own), `OwnerDashboardPage.css:13,23,26,38` (four fluid grids), `OwnerFeedbackPage.css:2`, and every other owner page reached through the shared shell.

**Pinning is unavailable and must not be attempted.** Pinning `OwnerFeedbackPage.css:2` to a literal `75rem` would not preserve its current geometry: after the ceiling repoint, its parent container offers 1248px of available width regardless, so a locally pinned 1200px cap would still widen that surface 48px relative to today's shipped 1152px, because the parent's own width changed. There is no local pin that reproduces today's exact geometry without also touching the parent chain, which is out of this plan's scope.

### Pre-existing, disclosed, not fixed by this plan

Below the ceiling's binding point, `.app-main` carries no accessibility-trigger reservation of its own while the header does, so content there can extend up to 48px further toward the inline-end edge than the header lockup. Separately, `.app-main h1`'s clearance reservation is mobile-only, so desktop headings between roughly 641px and the binding point have neither a protective gutter from the ceiling nor a per-element reservation of their own. This is not asserted as a currently-observed live defect — the accessibility trigger itself is fixed and any collision depends on heading length and scroll position — but it is flagged here for observation during validation, and it is explicitly not fixed by this plan.

## Browser UI dialog policy

Required. No native `alert`, `confirm`, `prompt`, their `window.*` forms, or `beforeunload` prompt anywhere in this browser-rendered React UI. Acknowledgement and confirmation use the app-owned accessible modal: focus trapped while open, focus returned to the trigger control on close, Escape plus an explicit close control available, never backdrop-only dismissal, and a visible 3px slate focus ring at every stop. Inline validation follows the C.2 pattern where the DS shows an inline pattern. No option in this plan touches a dialog path, so the deterministic source scan under "Acceptance and validation" must return a clean baseline; a new finding there is stop-and-report, not a fix folded silently into this plan.

## Browser UI validation

- **Launch/readiness**: `npm run dev` in `H:\CommandCenter\orchestrator\lizbeth_spanish`; ready when the login route renders. Reuse an existing healthy dev server; `taskkill` is never used; scoped-PID termination only if genuinely required.
- **Base URL**: `http://localhost:5173`.
- **Fixture/reset**: dev-only seeded quick-select panel (`LoginForm.tsx:123-138`), real seeded Supabase Auth accounts, local Supabase confirmed running. No fabricated fixture data. Owner-surface checks (P0-6) require the owner credential path — resolving access to that path is an open item for Phase 0; if credentials are genuinely unavailable, that specifically blocks P0-6 and must be reported, not guessed around.
- **Viewport profiles**: 1440, 1600, and 1920 as the primary desktop target set; 1280, 1366, and 1400 for the divergence and clearance checks; 900, 1200, and 1280 for the harmonization proof; 360, 400, and 480 CSS px for the 400% zoom check.
- **Journeys and visible outcomes**: as enumerated in P0-1 through P0-10 under "Acceptance and validation" above.
- **Cross-cutting**: tab order matches DOM order at every tested width; no CSS `order` property present anywhere in `src/**/*.css` (source scan); a visible 3px slate focus ring at 2px offset on every focusable control at every tested width; a captured screenshot at each named viewport, plus measured bounding boxes for P0-1 through P0-4. Deterministic failures dominate any judge or advisory result.

## Engineering mode and ownership

- `engineering_mode`: standard.
- `team_authorization`: not applicable.
- `downstream_owner`: engineering-fleet — T1 first-line, escalating to T2 on two counted gate failures per item, with an independent Verifier and Browser Validator as gates. No writer may self-approve completion.

## Approval gate

This plan requires explicit user approval before any downstream execution, including before any Phase 0 dispatch.

The umbrella plan's standing commit/push/PR/merge authorization for the `lizbeth-spanish` repository (excluding deploys, force-pushes, history rewrites, and branch deletion) is cross-referenced here, not restated. Per `handoff.md`, any job packet relying on that authorization must quote the user's own words directly rather than an orchestrator-relayed summary.
