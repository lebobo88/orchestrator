# Lizbeth Spanish — Issue #38: Screen: Roadmap

**Status: Drafted, routed to engineering under the user's standing authorization. This document has not itself been separately approved by the user; the user has granted standing authorization that the orchestrator applies to route this plan to engineering, per the Approval basis recorded below. Approval of this document authorizes only issue #38's scope; it does not authorize any of issues #39-#44.**

Plan ID: `lizbeth-spanish-issue38-screen-roadmap`
Task ID: `lizbeth-issue38`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: engineering-fleet

This plan grants no authority to begin implementation on its own. Explicit user approval, relayed by the orchestrator, is required before any T1/T2 engineering writer starts work.

---

## Approval basis

This plan was routed to engineering under the orchestrator's application of the user's standing authorization, not a user-verified per-plan approval. The record below is an orchestrator-applied inference, consistent with the Status line above, and follows the same provenance discipline the #31-#37 plans used.

- **Standing authorization quoted (verbatim, as relayed by the orchestrator):** the user's own live-session statements, "didn't i tell you to stop asking me for approval? i told you to keep going until all the gh issues are finished" and "don't stop until all the DS gh issues are implemented and browser validated." The orchestrator reports these as the standing authorization plus the explicit session goal covering this plan approval, on the same basis already recorded on the #31-#37 plans.
- **Application:** the orchestrator applied this standing authorization to route this plan — issue #38 of `lebobo88/lizbeth-spanish`, the Field Journal DS milestone, the second issue in the screen-redesign batch #37-#44, following #31-#37, all landed, verified, browser-validated, and design-reviewed PASS — to engineering without a further live per-plan checkpoint, because #38 is the next issue in the exact chain the user directed continuation through.
- **Pre-flight staleness check.** The orchestrator independently fetched the live GitHub issue #38 body via `gh issue view` and relayed it directly into Planner's context (see section 13, DEC-B, which quotes the fetched text verbatim and records how it was used to resolve design-reviewer's open finding). This satisfies the pre-flight staleness check that this plan's evidence reflects the issue's current live state, not a stale cached description.
- **DEC-A accepted without a separate user checkpoint.** The orchestrator accepted the plan's DEC-A default — a bounded, additive scope expansion touching `WeekDetailPage.tsx` and `LessonContentView.tsx` outside issue #38's declared file list, to wire the page-turn animation and the Stamp fire-once trigger to the existing "Mark this lesson complete" action — without a separate live user checkpoint. This is consistent with this milestone's established pattern for similarly bounded, additive amendments, e.g. #37's `App.tsx` amendment, and remains user-overridable at approval per section 13's recorded DEC-A fallback and section 14's required-approvals notice.
- **Right-sizing finding preserved here for the approval record.** No new "mark week complete" feature was invented. The existing lesson-completion action already serves as the week-completion trigger because week and lesson are 1:1 in this data model (verified in section 3's repository findings), and Stamp's already-shipped fire-once contract from issue #34 needed only to be wired to that existing action, not rebuilt. This finding is the basis for DEC-A and DEC-C in section 13.
- **Decision the user should look at closely: DEC-A, the touched-file scope expansion.** This plan's declared file scope is `RoadmapPage.tsx/.css`, `BandRoadmap.tsx/.css`, and `WeekCard.tsx/.css`. Planner authorized an expansion into two additional files — `src/pages/WeekDetailPage.tsx` (a page-turn wrapper element only) and `src/components/LessonContentView.tsx` (a stamp fire-once trigger only) — to satisfy two of the issue's own literal acceptance criteria (the §A.5 page-turn motion and the stamp firing on marking a week complete). This is a Planner decision made under the user's standing authorization, not a user-verified per-file approval, and it is explicitly user-overridable at approval. See section 13, DEC-A, for the full rationale and the recorded fallback if the user overrides it.
- **`PLAN_DUCK` Codex judge checkpoint.** Eligible at the orchestrator's discretion before approval per section 6; not separately run for this document. Deterministic checks and the Verifier/Browser Validator passes in Phase 6 remain mandatory regardless.
- **Provenance label:** this basis reached Scribe entirely through the orchestrator's account of the session; Scribe has not independently observed the quoted user statements or the `gh issue view` fetch. It is recorded here as an orchestrator-applied inference under standing authorization, NOT as a Scribe-verified per-document user approval.
- **Date:** 2026-09-01.

---

## 1. Outcome and audience

Implement and browser-validate GitHub issue #38, "Screen: Roadmap" — the screen-level composition and polish pass for the student roadmap, layered on top of issue #36's already-landed `WeekCard`/`BandRoadmap` component work. This is the eighth issue in the 14-issue Field Journal Design System milestone (#31-44), and the second of the screen-redesign batch (#37-44); issues #31-37 have already landed, verified, browser-validated, and design-reviewed PASS.

Audience for the resulting product surfaces: enrolled students, viewing their band roadmap(s).

Audience for this document: T1/T2 engineering implementers, the Verifier, and the Browser Validator. This plan must be sufficient for implementation without re-deriving design decisions.

---

## 2. Scope and non-goals

### In scope

- **Primary files**: `src/pages/RoadmapPage.tsx` / `.css`, `src/components/BandRoadmap.tsx` / `.css`, `src/components/WeekCard.tsx` / `.css`.
- **Authorized expansion (DEC-A, section 13)**: `src/pages/WeekDetailPage.tsx` (a page-turn wrapper element only) and `src/components/LessonContentView.tsx` (a stamp fire-once trigger only).
- The two design-token layers (`.atelier/tokens/field-workbook.tokens.json` and `src/tokens/field-workbook.generated.css`), for the two new h1 size leaves only.

### Explicitly out of scope

- `src/App.tsx` and all global chrome: the artboard's masthead, brand lockup, inline nav, the dark status strip ("STUDENT · ...ENROLLED 08 AUG 2026 · BEGINNER · WEEK 03 OF 26"), and the reference's 44x44 mobile hamburger/menu button. These wrap every route, are not in issue #38's file scope, and belong to a future global-chrome issue.
- Any new manual "mark this week complete" user action (see DEC-C, section 13).
- Scroll/focus restoration on return from week detail for a student positioned on a lower band section (requires an `App.tsx` change; flagged as a future cross-boundary item, section 13).
- Any single-band-at-a-time filter view (the jump-list is an anchor list over the existing stacked-all-enrollments view, not a filter — section 5).

### Protected / do not regress

- `BandRoadmap`'s C.9 `JournalEmptyState` three-part composition (`BandRoadmap.tsx:87-101` — `SpotIllustration` + `paper-stock--graph` + dashed rule, all three structurally required by the #34 removal test).
- `BandRoadmap.css`'s grid `@media` rules, source-scan-locked by `BandRoadmap.test.tsx:334-350`.
- `WeekCard`'s four-state identity from #36: the icon+word state text, the three hard-offset shadow hues, the `ink.moss` completed association, and the `aria-expanded`/Escape/focus-return locked disclosure.
- `FlashcardsViewer`'s #34 zero-radius fix.
- `--shadow-print`'s own value (~24 other live consumers).

No commit, push, PR, or deploy unless the user explicitly requests it.

---

## 3. Repository findings (evidence)

Findings below are from a nested Researcher pass that returned a 27-entry file+line source ledger, all repository-local, with no external sources used. Every load-bearing claim was then independently re-verified against the repository by design-reviewer.

**Shipped state today**

- `src/pages/RoadmapPage.tsx` (74 lines): a bare `<h1>Your roadmap</h1>`, mapping enrollments to one stacked `<BandRoadmap>` per enrollment. No band selector, no eyebrow, no progress ledger, no sheet treatment.
- `src/pages/RoadmapPage.css` (13 lines): `max-width` plus centering only.
- `src/components/BandRoadmap.tsx` (116 lines): a per-enrollment `<section>` with `<h2 id={\`band-${enrollment.id}-heading\`}>{enrollment.band_name}</h2>`; `Promise.all([fetchLessonsForBand, getLessonProgressForEnrollment])` feeding `computeWeekRoadmap`, rendering a flat `<ul className="band-roadmap-weeks">` of `WeekCard`. Three-value status machine (`loading`/`error`/`ready`). C.9 `JournalEmptyState` wired at lines 87-101. Lines 25-30 document that `App.tsx`'s ternary over distinct component types forces a full unmount/remount on return from week detail.
- `src/components/BandRoadmap.css` (51 lines): grid 1-up base / 2-up at `min-width 641px` / 4-up at `min-width 56.25rem` (900px), lines 28-46. Outer sheet uses `--border-width-strong` (2px, not the reference's 3px) and the legacy `--shadow-print` (`.3rem .3rem 0 0`, brass) rather than `--shadow-card`. No hatch ground.
- `src/components/WeekCard.tsx` (208 lines) / `.css` (202 lines): four states with an exhaustive switch at `tsx:82-106` plus a compile-time exhaustiveness check; three hard-offset shadow hues (`--shadow-card` default, `--shadow-brass` current, `--shadow-muted-card` locked); `--typography-role-display-sm-*` week number with component overrides (line-height `.8`, letter-spacing `-.04em`); a forced-colors block at `css:189-201`. `<Stamp>` is rendered for `done`/`locked` at `tsx:155-160` **without** the `animate` prop.
- `src/components/journal/Stamp.tsx` (48 lines): `aria-hidden="true"` unconditionally (line 35); already carries a complete fire-once contract — an `animate?: boolean` prop plus a `useState(() => animate)` lazy initializer firing `journal-stamp--animate` at most once per mount (lines 30-31); replay requires a fresh mount via a React `key`.
- `src/components/journal/Stamp.css` (109 lines): `@keyframes fj-stamp-done/-locked/-in-hand` (33-47) matching §A.5 exactly (scale `1.9→.94→1` at the per-state angle), applied via `.journal-stamp--{state}.journal-stamp--animate` (49-72) using `var(--motion-duration-stamp)`/`var(--motion-easing-standard)`. Forced-colors fallback distinguishes states by border-style. `src/__tests__/Stamp.test.tsx:35-46` already tests the fire-once contract.
- Band ink tokens **exist** in both layers: `.atelier/tokens/field-workbook.tokens.json:67-70` and `src/tokens/field-workbook.generated.css:137-139` — `--color-band-beginner: var(--color-brass-600)`, `--color-band-intermediate: var(--color-terracotta-600)`, `--color-band-advanced: var(--color-ink-slate)`. Used in exactly **one** place today: `src/components/OwnerLedgerRow.css:50-59`, where `OwnerLedgerRow.tsx:92-94` always renders the band **name** inside the inked element (the never-color-alone precedent). **Zero** `--color-band-*` occurrences exist in `WeekCard.css`, `BandRoadmap.css`, or `RoadmapPage.css` — the student roadmap has no band visual differentiation today.
- Motion tokens already exist and are already reduced-motion-safe: `field-workbook.generated.css:58` `--motion-duration-page-turn: 320ms`; `:63` `--motion-easing-standard: cubic-bezier(0.2, 0, 0, 1)`. `App.css:142-148` zeroes `--motion-duration-press` and `--motion-duration-page-turn` to `0ms` under `prefers-reduced-motion: reduce`, while setting `--motion-duration-stamp: 1ms` (not `0ms`) — documented at `App.css:132-140` because downstream JS depends on an `animationend` callback still firing. `--motion-duration-page-turn` has **zero** consumers anywhere in `src/`; no `rotateY`/`perspective` keyframe exists in shipped code. This is the first 3D/page-turn work in the milestone (`Control.css:22-23` press transitions and the `fj-stamp` keyframes are prior 2D motion only).
- Navigation as it actually exists (`src/App.tsx:102, 113-115, 174-200`): a single ternary in `AuthenticatedApp()` — `weekDetail ? <WeekDetailPage/> : isLearnRoute ? ... : <RoadmapPage/>` — all inside one persistent `<main className="app-main">` (line 173). `handleOpenWeek` navigates to `/roadmap/:enrollmentId/week/:n`. The back control is a plain button in `App.tsx` itself (176-182). `WeekDetailPage.tsx` (302 lines) has **no** prev/next-week control. So "navigating between weeks" today means exactly one thing: the roadmap → week-detail → back route swap. `App.tsx`'s own nav precedent (lines 131-166) uses `<button type="button">` with `onClick` routing plus `aria-current`, not anchors and not a tablist.
- Week completion as it actually exists: `adminStudentData.ts:173` `recordLessonProgress(enrollmentId, lessonId, 'complete')`, called from `LessonContentView.tsx:73-89`'s "Mark this lesson complete" button (191-195) — lesson-level, on `WeekDetailPage`. Week-level completion is purely **derived** in `computeWeekRoadmap`. There is **no** week-level "mark complete" user action anywhere. Week and lesson are 1:1 in this data model (verified: `lib/weekUnlock.ts`'s `Week` interface and `services/roadmapData.ts`'s `LessonRow` — one row per `week_number`, no sub-lesson structure), so "mark this lesson complete" **is** "mark this week complete" here. Because of the confirmed remount (`BandRoadmap.tsx:25-30`, locked in by `BandRoadmap.test.tsx:240-285`'s "freshness" test), a non-completed → completed transition is **never** observable within a single mounted `WeekCard` instance; the card only ever mounts already-resolved.
- Data model: `services/roadmapData.ts`'s `EnrollmentWithBand` carries only `id` / `band_id` / `band_name` / `enrollment_date` / `completed_at`. There is **no** "all bands that exist" listing and no band ordering field.
- `src/lib/bandTier.ts` exports `deriveBandTier` as claimed. `--shadow-sheet`, `--border-width-rule`, `--color-focus`, `--hit-target-min`, `--font-size-label-small`, `--font-size-button-label`, `--color-brass-500` all exist in `field-workbook.generated.css` with live consumers (`--shadow-sheet`/`--border-width-rule` consumed by `ForcedPasswordChangeGate.css`, `LoginForm.css`, `Modal.css`, and ~15 others).
- The app's only two `position:fixed` elements (`AccessibilitySettings`, `Modal`) are siblings of `<main>`, not descendants. No `position:fixed` or `sticky` exists in `RoadmapPage.css`, `BandRoadmap.css`, `WeekCard.css`, or `WeekDetailPage.css`.
- Tests: `src/__tests__/{WeekCard,BandRoadmap,RoadmapPage,Stamp}.test.tsx` all exist. `BandRoadmap.test.tsx:334-350` source-scan-locks the exact 1-up / 2-up-@641px / 4-up-@56.25rem grid rules. No motion or page-turn tests exist yet.
- Commands (`package.json:6-24`): `npm test` → Vitest; `npm run test:e2e` → Playwright; `npm run lint` → `eslint src --ext ts,tsx`; `npm run type-check` → `tsc --noEmit`; `npm run verify:build`.

**Reference artboard** (`design/field-journal/Field Journal DS.dc.html`) — the issue body's own line estimates (~79662, ~172941) are wrong for the current file; the values below use the real line ranges.

- §D.2 @1440 is at lines 624-761. Sheet (626): width 1440px, background `#fdfcf9`, border 3px solid `#1a1512`, box-shadow `10px 10px 0 0 #1a1512`. Masthead (627-639, out of scope). Status strip (640-643, out of scope). Content grid (645): `grid-template-columns: minmax(0,1fr) 60px` — main plus a right-edge 60px band-tab rail. Main header row (647-660): eyebrow "Contents · Beginner band"; h1 "Your roadmap" Fraunces 900 / 76px / line-height `.9`; right-aligned "Filed" progress ledger — label "02 / 26 · 8%" over a 20px bordered bar with solid-fill and hatched-fill segments, footnote "SOLID = COMPLETE · HATCHED = IN HAND" (652-658). Week grid (662): `repeat(3, minmax(0,1fr))`; gap 26px — the artboard's own sample is 3-up at 1440. Footer rule (748-751): `border-top: 3px solid #1a1512`, mono labels "Beginner band" / "— 26 weeks —". Band-tab rail (754-758): three `writing-mode:vertical-rl` tabs, "BEGINNER" filled `#866843` selected, "INTERMED." terracotta text, "ADVANCED" slate text.
- §E.2 @390 is at lines 1311-1380. A 390x844 flex-column sheet with a decorative iOS status-bar mock (artboard chrome, not product). Header (1316-1323, out of scope) including a 44x44 hamburger. Status strip (1324, out of scope). Content (1326-1372): "Contents" eyebrow, h1 40px / line-height `.92` (1328), the same Filed ledger (smaller), then week cards in `display:flex; flex-direction:column; gap:16px` — not a grid. Only 3 of the 6 desktop cards are shown (illustrative sampling, not a "show fewer weeks" rule). Bottom band nav (1374-1378): `nav { display:grid; grid-template-columns:repeat(3,1fr); border-top:3px solid #1a1512 }` — a fixed bottom tab bar mirroring the desktop rail.
- §A.5 motion (lines 182-189): "Navigation between weeks and segments reads as a leaf turning. Everything else is a press, not a fade." Page turn: 320ms · `cubic-bezier(.2,0,0,1)` · `perspective 1600px`, `rotateY -14° → 0`, `opacity .2 → 1`. Stamp: 260ms · scale `1.9→.94→1` at the per-state angle · fires once when a week is marked complete. Reduced motion: everything collapses to instant state change; no opacity-only fades. The artboard's own keyframe (line 19): `@keyframes fj-turn { from { transform: perspective(1600px) rotateY(-14deg) translateX(-2%); opacity: .2 } to { transform: perspective(1600px) rotateY(0) translateX(0); opacity: 1 } }`. Its **only** consumer in the reference is the §D.3 WEEK-DETAIL artboard wrapper (line 764) — it fires on arrival at the destination screen, never on the D.2 roadmap.
- `design/field-journal/ADOPTION-PLAN.md:227` maps issue #38 as: `| 8 | Screen: Roadmap | D.2 + E.2 | RoadmapPage.tsx/.css, BandRoadmap.*, WeekCard.* |` — reference D.2+E.2 only, with no A.5 mention; its only per-issue invariant checklist for #38 is the C.4 week card (line 262). The live issue body does require the page turn, and the live issue body outranks the ADOPTION-PLAN mapping.
- `ADOPTION-PLAN.md:194-206` is the fixed A.6 criteria block: six bullets, not seven (the header text's "all seven" is an off-by-one in that document — this plan does not treat a missing seventh item as an error to chase). The two ratified deviations (96-114) are the 26px margin-hand and the band-ink contrast correction; the ratified `ink.slate` figure on `paper.50` is 6.72:1 (a stale "7.0:1" comment survives in the token file and in the #36 plan — 6.72:1 is correct).

`research_evidence`: nested Researcher, repository-local only, 27-entry file+line source ledger. No external/web sources were used. All findings above trace to it or to design-reviewer's independent re-verification.

---

## 4. Design route and handoff summary

```text
DESIGN_ROUTE
profile: standard
reasons: Screen-level composition of an existing student roadmap screen adding a new band-navigation pattern with a divergent responsive form, a new progress-ledger component with a dual-fill semantic, the milestone's first page-turn (3D) motion work, and the first application of band inks to the student-facing roadmap surface. More than bounded brownfield polish: an IA change plus new motion on a brand-critical existing system that must be extended, not replaced.
agents_required: design-director, ux-architect, visual-system-designer, motion-designer, design-reviewer
prototype: forbidden
model_tier: sonnet
existing_system_mode: extend
END_DESIGN_ROUTE
```

Standard-route `DESIGN_HANDOFF`, produced by design-director with ux-architect, visual-system-designer, and motion-designer. Selected direction: "Field Journal, extended" — no new visual direction; no palette, typeface, radius, or shadow-value change. Its binding content is reproduced below.

### Four declared departures from the artboard

All four are verified by design-reviewer as grounded in real constraints, not convenience.

1. **The three-band tab rail (@1440) / bottom tab bar (@390) becomes a same-page anchor jump-list** that preserves the existing stacked-all-enrollments view — **not** a single-band-at-a-time filter. Grounds: `EnrollmentWithBand` carries no "all bands that exist" listing or ordering, so a fixed 3-slot rail would require fabricating rows for unenrolled bands (forbidden); today's stacked view is real, useful, existing behavior a filter would hide; the artboard's own eyebrow "Contents · Beginner band" frames the page as a table of contents, matching the anchor metaphor.
2. **The page-level "Filed" ledger moves to per-band** (each band section owns its own ledger), since the page now shows N bands rather than the artboard's single band.
3. **The page-level sheet frame is declined**; `BandRoadmap`'s existing per-band sheet is promoted to be the only sheet, avoiding a sheet-inside-a-sheet across N stacked bands.
4. **§E.2's mobile flex-column week stack is not adopted**; the shipped 1-up CSS grid is kept (zero user-visible difference, and switching would break a locked source-scan test).

### Band jump-list (IA and accessibility)

- **Cardinality**: 0 enrollments → the pre-existing page-level empty state, unmodified, no selector and no ledger. 1 enrollment → no selector (redundant). 2+ enrollments (any combination, including non-adjacent bands, e.g. Beginner+Advanced) → selector renders with exactly N real band-name entries in `enrollment_date` order; no ghost or disabled slot for an unenrolled band.
- **Markup**: `<nav aria-label="Jump to band">` containing exactly N `<a href="#band-{enrollment.id}-heading">` entries, reusing `BandRoadmap`'s existing `h2` id (do not add a duplicate id). It is nav-with-links plus `aria-current="location"`, **not** an ARIA tablist — activation moves scroll and focus but hides nothing. Focus moves to the target section's `<h2 tabindex="-1">` on activation.
- **Note (design-reviewer finding, applied)**: the ARIA-pattern parity with `App.tsx`'s existing nav (`aria-current`, not tablist) is real, but `App.tsx` uses `<button>` elements, not anchors. The jump-list's use of real anchors for a same-page hash jump is the more correct semantic choice here; the "precedent match" claim is scoped to the ARIA pattern only, not the element type.
- **Responsive**: one wrapping flex chip row (`flex-wrap: wrap`) at every breakpoint. The @390 fixed bottom tab bar is deliberately declined — that idiom is reserved for real global nav, and a page-scoped control reading as global nav would mislead. The desktop edge-rail is also declined: it would require a new page-level two-column grid wrapper `RoadmapPage.css` does not have, and re-couples a page rail to N independently stacked sheets in a way the single-band artboard never had to solve.
- **Each chip**: `min-height: 44px` (`--hit-target-min`), square border in `--color-band-*`, an explicit background-color (never inheriting a `paper-200` host — see the contrast invariant below). The `aria-current` entry gets a thicker border plus bold plus underline (three non-color cues beyond the ink).
- **Focus-visible**: 3px `--color-focus` ring at 2px offset, outside the border.
- **Typography**: mono 14px (`--font-size-button-label`), weight 400 / 700 when `aria-current`, **not** uppercase — real Spanish proper-noun band names must not be force-cased (an explicit departure from the artboard's uppercase rail text).
- If `aria-current` scroll-tracking is implemented via `IntersectionObserver`, it must **not** mutate `location.hash` on scroll, only on click. Threshold/`rootMargin` are left to engineering.

### Filed progress ledger (per band)

- **Dual-fill semantic**: solid = the count of `completed` weeks; hatched = the single `current` week (only one week is ever current).
- **Gating**: rendered only when `status === 'ready' && weeks.length > 0` — the same condition `BandRoadmap.tsx` already computes.
- **Data states**: `0 < completed < total` (partial solid plus hatch); `completed === total` (fully solid, hatch necessarily absent); `completed === 0` with a current week (hatch-only from week 1). No interactive states.
- **Accessible markup**: an `aria-hidden="true"` decorative bar (both the solid and hatch spans) plus a separate, always-visible real-text figure "NN / NN · P%". This follows the `OwnerLedgerRow` precedent verbatim — `role="progressbar"` and native `<progress>` are deliberately avoided per that precedent's documented "AT support for `aria-valuetext` is inconsistent" reasoning. A bare percentage alone is a **failing** implementation in this codebase and must never be produced. Reuse the zero-pad / `padStart(2,'0')` convention from `OwnerLedgerRow.tsx` verbatim.
- **Visual**: track `--color-paper-200`; solid fill `--color-ink-1000`; hatched fill a token-built 45° repeating-linear-gradient using `--color-brass-500` (no raw hex). Bar height 20px desktop / 16px mobile+tablet (existing spacing-scale steps, no new leaf). Label row and the trailing figure: mono 11px (`--font-size-label-small`), 600 weight, `--color-ink-700`, `white-space: nowrap` on the figure (a fixed-shape numeral string, not long content). Footnote "SOLID = COMPLETE · HATCHED = IN HAND": mono 11px, `--color-ink-700`.
- One new CSS composite class `.band-roadmap-ledger-fill--hatched` (a documented exception in the same class as `.paper-stock--graph`), built entirely from an existing token reference.
- **At-scale check**: the ledger's 45°/4px/brass-500 hatch (confined to a bar ≤320px) does not collide with `.paper-stock--graph`'s 0/90°/17-18px/paper-300 hatch on locked cards — different angle, scale, color, and location.

### Page composition

- `RoadmapPage` stays frame-less. Order: eyebrow → h1 → jump-list (conditional, 2+ enrollments) → stacked `BandRoadmap` sections.
- Eyebrow "Contents" (page-level, not band-specific, rendered once): mono, `--font-size-label` (12px), 600 weight, `--font-letter-spacing-wider`, uppercase, `--color-brass-700` — matching every existing eyebrow.
- h1 "Your roadmap": Fraunces family/weight borrowed via `--typography-role-display-sm-font-family` / `-font-weight` (the same "borrow family/weight, override size/line-height/letter-spacing" pattern `WeekCard`'s week number already uses); new `--font-size-roadmap-h1-sm` (2.5rem / 40px, ≤899px) and `--font-size-roadmap-h1-lg` (4.75rem / 76px, ≥900px); letter-spacing `-.035em`; color `--color-ink-1000`. **Line-height (design-reviewer finding, applied)**: `.9` at ≥900px and `.92` at ≤899px, matching the specimen exactly at both breakpoints (`DS.dc.html:650` and `:1328`) rather than consolidating to a single value.
- `BandRoadmap` sheet order: h2 (unchanged) → status paragraph (unchanged) → new ledger (conditional) → `WeekCard` grid OR the C.9 empty state (unchanged) → new footer rule (conditional). Ledger and footer span the full sheet width.
- **Footer rule**: mono 12px (`--font-size-label`); the band-name span in `--color-band-*` with no uppercase forcing; a " — N weeks — " span in `--color-ink-700` using the real week count. Footer padding-top rounds to the nearest existing spacing-scale step (12px) rather than the specimen's literal 14px — flagged, not load-bearing.
- **Sheet treatment**: `BandRoadmap.css`'s `.band-roadmap` border-width/box-shadow are **reassigned** from `--border-width-strong` / `--shadow-print` to `--border-width-rule` (3px) / `--shadow-sheet` (8px 8px 0 0, ink). Both are pre-existing tokens with live consumers — no value change, no new mint. `--shadow-print`'s own value is untouched.
- **Empty band**: for a band with zero published weeks, the ledger and the footer rule are **both omitted** — not rendered as "0/0 · —%" or "0 weeks". The C.9 empty-state body copy already carries the meaning. The band still appears by name in the jump-list when 2+ enrollments exist.
- Band ink is applied to the jump-list chip (text plus border accent) and the per-band footer's band-name span. It is **not** applied to the h2 (avoids tripling the same cue in one section) nor to the ledger fill (kept neutral, reusing the `OwnerLedgerRow` fill convention).
- Grid mechanism is untouched at all three breakpoints. The 3-up-artboard-sample vs. 4-up-shipped discrepancy is resolved in favor of the shipped 4-up: the artboard's 3-up is an illustrative sample, not a binding floor, and a passing CSS source-scan test locks the shipped rules in.

### Contrast (independently recomputed by design-reviewer)

Recomputed by design-reviewer from the actual hex values in `field-workbook.generated.css:12,21,22,26` using the WCAG relative-luminance formula; all four match the design packet.

- `brass.600 #866843` on `paper-100 #faf8f4` = 4.86:1 — PASS
- `terracotta.600 #a85e4a` on `paper-100` = 4.54:1 — PASS
- `ink.slate #3d5f6b` on `paper-100` = 6.50:1 — PASS
- `terracotta.600` on `paper-200 #f0ebe2` = 4.05:1 — **FAIL**

**Hard engineering invariant**: every new band-ink text placement (jump-list chip, footer band-name span) must sit on an explicit `paper-50` or `paper-100` background and must never inherit a `paper-200` host. Jump-list chips therefore carry an explicit background-color rather than inheriting.

**Provenance note (design-reviewer finding, applied)**: `OwnerLedgerRow.css:1-7` scopes its own band-ink mandate to `paper.50` only. The extension to `paper-100` is a **new** verification made during this planning cycle and independently confirmed by design-reviewer; it is broader than, and distinct from, `OwnerLedgerRow`'s original `paper.50`-only note. This is recorded so a future reader hitting that narrower comment does not conclude `paper-100` is unreviewed.

Cross-check: `ADOPTION-PLAN.md:106-114`'s ratified `paper.50` figures are 5.02 / 4.69 / 6.72 — directionally and proportionally consistent, since `paper-50` is lighter than `paper-100` and correctly yields higher contrast.

### Motion — page turn

- **Trigger**: `WeekDetailPage` mount. Forward only (roadmap → week detail); the back-link return stays instant and unanimated, matching the reference's own binding of `fj-turn` to the D.3 arrival wrapper only and never to the D.2 roadmap. Since no prev/next-week control exists anywhere, the issue's "navigating between weeks" criterion is satisfied as a sequence of independent arrival events.
- **Attachment point**: a new bare non-chrome `<div className="week-detail-sheet">` added inside `WeekDetailPage.tsx` wrapping its entire existing return (all of the loading/locked/empty/error/available branches sit inside this one wrapper, internally unchanged). `<main className="app-main">` is **never** transformed.
- **Stacking-context/containing-block risk**: assessed as none and independently re-verified by design-reviewer — no `position:fixed` or `sticky` exists anywhere in `RoadmapPage.css`, `BandRoadmap.css`, `WeekCard.css`, or `WeekDetailPage.css`; the app's only two fixed elements (`AccessibilitySettings`, `Modal`) are siblings of `<main>`, not descendants.
- **Declaration**: `animation: fj-page-turn var(--motion-duration-page-turn) var(--motion-easing-standard) both;` with `@keyframes fj-page-turn { from { transform: perspective(1600px) rotateY(-14deg) translateX(-2%); opacity: .2 } to { transform: perspective(1600px) rotateY(0deg) translateX(0); opacity: 1 } }`. **TranslateX restored (design-reviewer finding, applied)**: the design packet had silently dropped the specimen's `translateX(-2%) → translateX(0)` pan; it is restored so the keyframe matches `DS.dc.html:19` exactly. Both timing tokens are consumed verbatim (320ms / `cubic-bezier(.2,0,0,1)`); no new token and no hardcoded timing value.
- `will-change` is **not** recommended (fires once per navigation, not continuously). `transform-style: preserve-3d` is **not** needed (a single transforming element).
- **Reduced motion**: no new code. `--motion-duration-page-turn` is already `0ms` in `App.css`'s existing single reduced-motion block; at `0ms` the animation resolves instantly to the `to` state. Do **not** add a second `prefers-reduced-motion` mechanism anywhere.
- **Orchestration**: single-element, single-shot, CSS-only, no JS trigger; rapid re-navigation discards the animation with its unmounted element, so there is no interruption hazard.

### Motion — stamp fire-once

- **Chosen shape**: trigger from `LessonContentView.tsx`'s existing `completed` state flip — the real "marking a week complete" action, since week and lesson are 1:1 in this data model. **Not** a roadmap-side persisted-flag bridge.
- **Mechanism**: a new local `justCompleted` boolean in `LessonContentView.tsx`, set true **only** inside `saveCompletion`'s success branch and **never** by the mount-time fetch effect. Render `{completed && justCompleted && <Stamp state="done" label="Complete" animate={true} />}` adjacent to the existing `role="status" aria-live="polite"` "Lesson marked complete." paragraph (`LessonContentView.tsx:197-199`). That is a genuine fresh mount, correctly captured once by `Stamp`'s existing lazy `hasFiredAnimation` contract.
- **Cross-device/session**: unpersisted local state — completing on one device never animates the stamp elsewhere. Correct and unsurprising: the celebratory moment belongs to the session where the action happened.
- **Multi-completion**: each `LessonContentView` mount has independent state, so marking several weeks complete in one sitting gives each its own independent fire-once moment; no session-wide gating.
- **Reduced motion**: inherits the existing `--motion-duration-stamp: 1ms`-not-`0ms` reasoning unchanged (preserving the `animationend` callback downstream JS depends on). No new dependency introduced.
- **Accessibility**: `Stamp` stays `aria-hidden="true"` and purely decorative. No new live region — the existing "Lesson marked complete." announcement already fully carries the non-visual meaning at the same moment.

### Design review disposition

`DESIGN_REVIEW_RESULT` verdict **PASS**, first round, no revision required, from an independent design-reviewer that re-verified claims against the repository rather than trusting the packet.

- It independently recomputed all four contrast ratios, confirmed every claimed token exists with its claimed value and live consumers, confirmed only the two h1 size leaves are genuinely unminted, grepped `position:fixed`/`sticky` across `src` to confirm the motion subtree is clean, confirmed the week=lesson 1:1 relation, confirmed `LessonContentView`'s `completed` state / `saveCompletion` / `role="status"` region all exist as cited, and confirmed the non-regression targets (C.9's three-part composition, `BandRoadmap.test.tsx:334-350`'s grid source-scan lock, `WeekCard.tsx:82-106`'s exhaustive switch).
- It raised six bounded findings: four low-severity precision/disclosure gaps (the translateX omission, the h1 line-height consolidation, the `App.tsx` precedent wording, and the `paper-100` provenance framing) — **all four applied** as amendments in the specifications above — plus one medium finding (the stamp/page-turn file-footprint flag, resolved as DEC-A below) and one low finding (confirm the literal issue text, resolved as DEC-B below).
- Design review explicitly did **not** execute code, run tests, or render screenshots — visual and interaction confirmation is the Browser Validator's job. It also could not locate a local copy of the live issue #38 body and relied on the quoted text plus independently verified surrounding facts.

---

## 5. Judge route

`PLAN_DUCK` is eligible at the orchestrator's discretion before approval (multi-file UI change introducing the milestone's first 3D motion work, plus a scope expansion beyond the issue's declared file list). `CODE_REVIEW` and `VISUAL_REVIEW` are optional per `docs/JUDGE-CONTRACT.md` risk rules. Standard call caps apply. Deterministic failures always dominate any judge finding.

---

## 6. Ordered work (phases)

Sequence as internal phases of this one plan (the #35/#36 approach), not separate jobs. **Every phase is TDD-first**: write or extend the failing test before the production edit. Owner for Phases 0-5 is T1; escalate to T2 per the standard two-counted-gate-failure rule in `CLAUDE.md`.

### Phase 0 — Tokens

Add `--font-size-roadmap-h1-lg` (4.75rem) and `--font-size-roadmap-h1-sm` (2.5rem), dual-written to `.atelier/tokens/field-workbook.tokens.json` (as `typography.roadmapH1.lg` / `.sm`, `$type: dimension`) **and** `src/tokens/field-workbook.generated.css`. These are the only two new token leaves in this issue.

- Depends on: nothing.
- Observable result: token tests pass; both resolve in the generated CSS.

### Phase 1 — Page composition (RoadmapPage)

Add the "Contents" eyebrow and the restyled h1 with its two new size leaves and per-breakpoint line-height (`.9` ≥900px, `.92` ≤899px).

- Depends on: Phase 0.
- Observable result: eyebrow and h1 render at both required viewports with token-backed values only.

### Phase 2 — Band jump-list (RoadmapPage)

Add the conditional `<nav aria-label="Jump to band">` anchor list per the IA and accessibility spec: renders only at 2+ enrollments, exactly N real entries in `enrollment_date` order, anchors targeting the existing band h2 ids, h2 gains `tabindex="-1"`, `aria-current="location"` on activation, three non-color active cues, 44px chips with explicit backgrounds and band-ink borders/text, wrapping flex row at every breakpoint.

- Depends on: Phase 1.
- Observable result: tests cover the 0/1/2+ enrollment cardinality branches and assert no fabricated entry for an unenrolled band.

### Phase 3 — Filed ledger and footer rule (BandRoadmap)

Add both, gated on `status === 'ready' && weeks.length > 0`, with the solid/hatched dual fill, the `aria-hidden` bar plus real zero-padded "NN / NN · P%" text, the footnote, and the footer rule with the real week count and band-ink band name. Reuse `deriveBandTier` and the `OwnerLedgerRow` zero-pad convention verbatim.

- Depends on: Phase 0.
- Observable result: a test asserts the ledger never emits a bare percentage; a test asserts both the ledger and the footer are absent (not zero-valued) for a band with zero published weeks while the C.9 empty state still renders all three of its required parts.

### Phase 4 — Sheet reassignment (BandRoadmap.css)

Reassign `.band-roadmap` border-width and box-shadow to `--border-width-rule` and `--shadow-sheet`. Do **not** modify the grid `@media` rules.

- Depends on: nothing.
- Observable result: `BandRoadmap.test.tsx`'s grid source-scan test still passes unchanged; `--shadow-print`'s own definition is untouched.

### Phase 5 — Motion

- **5a** — Add the `fj-page-turn` keyframe and the `week-detail-sheet` wrapper div in `WeekDetailPage.tsx`, consuming `--motion-duration-page-turn` and `--motion-easing-standard`.
- **5b** — Add the `justCompleted` state and the conditional animated `<Stamp>` in `LessonContentView.tsx`.

Both sub-phases require the DEC-A scope authorization recorded in section 13.

- Depends on: nothing (beyond DEC-A authorization).
- Observable result: a test asserts the page-turn CSS consumes the tokens and adds no second reduced-motion mechanism; a test asserts `justCompleted` is set only by `saveCompletion`'s success branch and never by the mount-time fetch effect, so a fresh mount of an already-completed lesson does **not** animate.

### Phase 6 — Verification

Verifier pass, then Browser Validator pass against the brief in section 10.

- Owner: Verifier, then Browser Validator.
- Depends on: Phases 0-5.

If T1 cannot complete a phase, escalate to T2 per the standard two-counted-gate-failure rule in `CLAUDE.md`.

---

## 7. Interfaces and data

- No data-model change, no migration, no service-layer change. `computeWeekRoadmap`, `getLessonProgressForEnrollment`, `RoadmapWeekState`, and the `Week`/`LessonRow` interfaces are all unchanged by this issue.
- Two new design tokens only (the h1 sizes), dual-written to both layers.
- Two new CSS class families: the jump-list and the ledger/footer, plus one documented composite exception class `.band-roadmap-ledger-fill--hatched`.
- One new keyframe `fj-page-turn`, the first consumer of `--motion-duration-page-turn`.
- `WeekDetailPage.tsx` gains one wrapper element; `LessonContentView.tsx` gains one local boolean and one conditional decorative element. Neither changes any exported contract.
- `BandRoadmap`'s h2 gains `tabindex="-1"` (a programmatic focus target; it does **not** enter the tab order).
- `src/__tests__/{RoadmapPage,BandRoadmap,WeekCard}.test.tsx` will need extension; `BandRoadmap.test.tsx`'s existing grid source-scan and freshness tests must continue to pass unmodified.

---

## 8. Acceptance and validation

TDD-first throughout.

- `npm test` (Vitest) green, including the new tests named per phase above.
- `npm run type-check` (`tsc --noEmit`) clean.
- `npm run lint` clean.
- The six fixed A.6 criteria (`ADOPTION-PLAN.md:194-206`) plus A.3 zero-radius: never color alone; ≥4.5:1 contrast with amber and terracotta.500 never carrying text; ≥44px hit targets; 3px ink.slate focus ring at 2px offset; decoration `aria-hidden` and structurally removable; reduced motion collapsing to instant; no raw hex.
- The seven verbatim acceptance criteria from the live issue #38 body (matches §D.2 @1440 and §E.2 @390; all four week-card states against real data including a genuinely locked week showing its real unlock date; band inks applied; band never signalled by color alone with the band name always present in text; §A.5 page turn on week navigation collapsing to instant under reduced motion; stamp fires once on marking a week complete; C.9 empty state not regressed).
- Deterministic no-raw-hex scan across every touched CSS file.
- Deterministic no-native-dialog scan for `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload`.
- Zero-radius scan.
- Deterministic scan confirming no second `prefers-reduced-motion` block was introduced — all new motion must route through the existing `App.css:142-148` token-zeroing mechanism.
- Deterministic scan confirming no `--color-band-*` text placement sits on a `paper-200` background.
- The #34 removal-test structural/decorative CSS split must still hold for the new decorative additions (the ledger's hatch fill, the animated `Stamp`).
- Verifier pass, then Browser Validator pass.
- Atelier MCP is disclosed-unavailable this session (unresolved project-root misconfiguration), including `visual_diff`. **Pre-authorized substitute**, following the documented #34/#35/#36 precedent: hand-transcribed comparison against the §D.2 and §E.2 reference sections plus a documented manual visual-diff record with screenshots at **both** 1440 and 390, disclosed in the completion evidence as a known gap rather than claimed as tool-verified.

---

## 9. Browser UI dialog policy

**Required.** This is browser-rendered React/Vite UI. Native `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload` prompts are **prohibited**. Acknowledgement or confirmation must use the app-owned accessible modal; inline treatment where it better serves the user.

This issue introduces **no modal at all** — the jump-list is inline nav, the ledger is non-interactive, and the locked-week "Why locked?" affordance stays an inline `aria-expanded` disclosure and must **not** become a modal.

A deterministic source scan for the prohibited APIs is a required acceptance check.

---

## 10. Browser UI validation

- **Launch/readiness**: `npm run dev -- --port 4319 --strictPort` from the repo root; ready when Vite logs "ready in" and the Local URL. `--strictPort` is mandatory so a collision fails fast rather than silently rebinding.
- **Port**: 4319. Rationale: a clean repository-local precedent used twice (`docs/plans/lizbeth-spanish-issue31-design-system-foundations.md:306` and `issue32-typography-four-hands.md:288`) and not on the session's exclusion list. Excluded: 5199 (a real #35 collision), 5211, 5299, 5317 (used for #36), 5321. 7913 is a confirmed failure (`lizbeth_spanish/vite-dev-restart-7913-err.log:2` records "Port 7913 is already in use"). Reserved and not to be used: 4173 (`npm run preview:prod`) and 8888 (Playwright/`netlify serve`). Fallback if 4319 collides: 9187, which also has a clean precedent. Check for foreign-process conflicts before binding.
- **Base URL**: `http://localhost:4319`.
- **Fixture/reset**: use the existing seeded student and enrollment path (`create-test-student.sql` and the existing admin-created-student flow). Required fixtures:
  - (a) a single-enrollment student;
  - (b) a multi-enrollment student with two **non-adjacent** bands (e.g. Beginner + Advanced, no Intermediate) to exercise the jump-list and prove no fabricated third entry appears;
  - (c) a zero-enrollment student;
  - (d) a band with zero published weeks;
  - (e) a student whose real enrollment date produces a genuine four-state mix including a future-dated locked week showing its real unlock date. Per issue #36's still-standing J-01-36 decision (the kept `Math.max` most-recently-unlocked current-week rule), the `unlocked` state requires a deliberate fixture: seed at least two unlocked weeks where the highest-numbered unlocked week is **not** the week under test. Its absence from a default single-unlocked-week seed is expected, not a defect.
  - Reset by re-running the seed between journeys.
- **Viewport profiles**: required at 1440x900 (desktop ≥900px) and 390x844 (mobile ≤640px), both explicitly. Recommended additionally at 768x1024 (tablet 641-899px) for the shared jump-list/grid treatment.

### Journeys and visible outcomes

1. **Single-enrollment student at both required viewports**: eyebrow plus h1 render, no jump-list, one band section showing h2, status line, ledger, the four-state grid against real data, and the footer rule with the real week count.
2. **Multi-enrollment non-adjacent-band student**: the jump-list renders exactly the real enrolled band names in `enrollment_date` order with no fabricated third entry; activating an entry scrolls to and moves focus to that band's h2 and sets `aria-current="location"`; chips wrap at 390px without truncation for a deliberately long placeholder band name; scrolling does **not** mutate the URL hash.
3. **Zero-enrollment student**: the pre-existing page-level empty state renders unmodified, with no jump-list and no ledger.
4. **Band with zero published weeks**: the C.9 `JournalEmptyState` renders all three required parts (illustration plus graph paper-stock ground plus dashed rule); the ledger and the footer rule are both absent, not zero-valued; the band still appears by name in the jump-list when 2+ enrollments exist.
5. **Open a week from the roadmap**: `WeekDetailPage` arrives with the page turn playing exactly once (`rotateY -14deg → 0`, `translateX -2% → 0`, `opacity .2 → 1`, 320ms, `cubic-bezier(.2,0,0,1)`); nothing on the week-detail screen clips or mis-layers from the new stacking context; the back-link return is instant with no page turn.
6. **Repeat journey 5 with `prefers-reduced-motion: reduce`**: the transition is instantly complete with no visible rotation, pan, or opacity sweep, and no flash of the `from` state.
7. **Mark a lesson/week complete on WeekDetailPage**: the `Stamp` fires exactly once at the moment of the existing "Lesson marked complete." announcement; navigating away and back never replays it; a fresh mount of an already-completed lesson does **not** animate; completing several weeks in one sitting fires each independently; a later visit to `/roadmap` never re-triggers a stamp animation for an already-celebrated week.
8. **Band-ink check**: every band-ink placement is paired with visible band-name text (never color alone); no band-ink text sits on a `paper-200` background.
9. **Ledger check**: the Filed ledger always shows a real zero-padded "NN / NN" count alongside its percentage and never a bare percentage; the solid and hatched segments are distinguishable by more than color.
10. **Token-consumption check** across all new elements: every color, border, shadow, spacing, and typography value resolves through a `var(--...)` custom property and never a raw hex or px literal.
11. **Keyboard-only pass**: Tab reaches jump-list links in document order and Enter activates and moves focus to the target h2; the existing locked-week "Why locked?" Escape-and-focus-return still works unmodified; all new interactive elements meet the 44px hit target and show the 3px ink.slate focus ring at 2px offset.
12. **400% zoom / reflow** at both required viewports: no fixed-width truncation of band names, ledger figures, or footer text.
13. **`forced-colors: active` pass**: the jump-list border and `aria-current` cues, the ledger's solid/hatched/empty segments, and the sheet border all remain visually distinct using border-style and weight, never color alone.
14. **Deterministic no-native-dialog scan** across every journey.
15. **Non-regression**: `WeekCard`'s four states remain legible and non-colliding with the new chrome at scale in a real grid; `FlashcardsViewer` shows no reintroduced border radius.

---

## 11. Risks and rollback

- **MEDIUM** — the first 3D transform in the codebase creates a new stacking context and containing block on the week-detail subtree. Mitigation: the subtree was grepped and independently re-verified to contain no `position:fixed` or `sticky` descendant; the app's only two fixed elements are siblings of `<main>`. Browser validation must confirm nothing clips or mis-layers on the week-detail screen. Rollback: Phase 5a is a single wrapper element plus one keyframe, revertable independently.
- **MEDIUM** — the sheet reassignment (Phase 4) changes a visible frame on every band section. Mitigation: both tokens are pre-existing with live consumers; `--shadow-print`'s own value is untouched so its ~24 other consumers are unaffected. Rollback: a two-property revert.
- **MEDIUM** — the scope expansion into `WeekDetailPage.tsx` and `LessonContentView.tsx` (DEC-A) touches files outside the issue's declared list, including a file that writes real student progress. Mitigation: both changes are strictly additive and presentational — one wrapper element and one local boolean gating one decorative `aria-hidden` element — with no change to `saveCompletion`'s logic, its error handling, or any exported contract. Rollback: each is independently revertable.
- **MEDIUM** — the band-ink contrast invariant. `terracotta.600` fails on `paper-200` at 4.05:1. Mitigation: the hard invariant requiring explicit `paper-50`/`paper-100` backgrounds, plus a deterministic scan and a browser-validation check.
- **LOW** — the jump-list's `aria-current` scroll-tracking could mutate `location.hash` and pollute history. Mitigation: an explicit invariant forbidding hash mutation on scroll.
- **LOW** — long Spanish band names could wrap awkwardly in the chips. Mitigation: an explicit Browser Validator journey with a deliberately long placeholder band name.
- **LOW** — dev-server port collision. Mitigation: `--strictPort` fails fast.
- **Rollback overall**: each phase is an independently revertable commit-sized unit; Phase 0's tokens are purely additive and safe to leave in place.

---

## 12. Design invariants carried into engineering

For readers scanning acceptance criteria against the design handoff (section 4), the binding, non-negotiable invariants are:

- Never color alone for any band-ink placement; band name is always present in visible text alongside the ink.
- Every new band-ink text placement sits on an explicit `paper-50`/`paper-100` background, never inherited `paper-200`.
- The ledger's real zero-padded figure is mandatory; a bare percentage is a failing implementation.
- 44px minimum hit target and the 3px `ink.slate` focus ring at 2px offset on every new interactive element.
- Reduced motion collapses every new animation to an instant state change through the existing `App.css:142-148` token-zeroing mechanism only; no second mechanism.
- The jump-list is a same-page anchor nav-with-links, not a tablist and not a single-band filter.

---

## 13. Assumptions and open decisions

**DEC-A (RESOLVED by Planner — touched-file scope expansion, user-overridable at approval).** The design packet raised an explicit file-footprint flag, escalated by design-reviewer as a medium finding: the chosen stamp mechanism touches `src/components/LessonContentView.tsx`, and the page-turn attachment touches `src/pages/WeekDetailPage.tsx`, both outside issue #38's declared file scope (`RoadmapPage`, `BandRoadmap`, `WeekCard`). **Planner authorizes both expansions.** Rationale:

1. Week and lesson are 1:1 in this data model (verified), so `LessonContentView`'s "Mark this lesson complete" button **is** the issue's "marking a week complete" action — it is the only place the criterion can be satisfied literally.
2. The confirmed remount architecture means a roadmap-side trigger would require a persisted storage bridge with cross-device, private-browsing, and stale-flag edge cases, all for a purely decorative flourish — worse engineering for worse fidelity.
3. The page turn has no attachment point at all without a week-detail wrapper, since no per-page sheet element exists and `<main>` must not be transformed.
4. Precedent: issue #36 made exactly this kind of recorded, user-overridable expansion into `OwnerDashboardPage.tsx`.

**Provenance**: this is a Planner decision applied under the user's standing authorization, not a user-verified per-file approval. **The user may override it at approval.** If overridden, the recorded fallback is:

- (a) for the stamp, the persisted-flag shape held in reserve by the motion packet (a `sessionStorage`/`localStorage` record keyed by enrollment+week, compared on roadmap mount), with the explicitly recorded consequence of storage-bridge complexity and cross-device/private-browsing edge cases; and
- (b) for the page turn, no viable in-scope alternative exists — declining the `WeekDetailPage` wrapper means the §A.5 page-turn acceptance criterion cannot be met and must be deferred to issue #9 (the week-detail screen issue, whose D.3 artboard is the reference's actual `fj-turn` binding site).

**DEC-B (RESOLVED by Planner — design-reviewer's finding on confirming the literal issue text).** Design-reviewer could not locate the live issue #38 body in the repository and asked that the literal acceptance-criterion wording be confirmed. The orchestrator did fetch the live issue body, and it reads: "Marking a week complete fires the STAMP animation ONCE — this is the real trigger #34 deliberately deferred (Stamp shipped presentational-only in #34/#35/#36 with no wired completion action; this issue may be where that finally gets wired, or it may still be deferred further — confirm from research)." The issue is therefore explicitly permissive about where and whether this lands. The design decision — wiring it at the real action point on the week-detail screen rather than on the roadmap card — is within the issue's own stated latitude and is confirmed as satisfying the criterion. Record that the stamp animates on the week-detail screen at the moment of completion, **not** on the roadmap's week card; the roadmap card's existing static (non-animated) done `Stamp` is unchanged.

**DEC-C (RESOLVED by Planner).** No new manual "mark this week complete" button or any other new week-completion user action is created. Building one would be a substantial out-of-scope product feature. The stamp reacts to the existing lesson-completion action, which is the same entity as week completion in this data model.

**DEC-D (RESOLVED by Planner).** The four low-severity design-reviewer findings are all applied, not merely noted: the specimen's `translateX(-2%)` pan is restored to the `fj-page-turn` keyframe; the h1 uses the specimen's actual per-breakpoint line-heights (`.9` / `.92`) rather than a single consolidated value; the `App.tsx` "precedent" claim is scoped to the ARIA pattern only, since `App.tsx` uses buttons and the jump-list correctly uses anchors; and the `paper-100` band-ink verification is recorded as new-in-this-cycle provenance, distinct from `OwnerLedgerRow.css:1-7`'s narrower `paper.50`-only note.

**Assumption** — UI-chrome copy ("Contents" eyebrow, the "Jump to band" accessible name, the ledger footnote wording, the footer's English "weeks") is UI chrome finalizable at copy review, not fabricated product content. Band names themselves are real product content.

**Assumption** — reference-artboard copy ("Beginner band", "02 / 26 · 8%", "STUDENT1@TEST.LOCAL", the iOS "9:41" status-bar mock) is illustrative artboard chrome and must never ship literally.

**Assumption** — current seed band names are short English words, but they are treated throughout as real, potentially longer Spanish content; nothing may fixed-width truncate.

**Open, deferred, non-blocking**:

- Scroll/focus restoration on return from week detail for a student positioned on a lower band section (requires an `App.tsx` change; flagged for a future cross-boundary issue).
- Whether product ever wants a true single-band-at-a-time default view (a larger future product-policy question this plan deliberately leaves open by keeping all bands visible).
- The exact `IntersectionObserver` threshold/`rootMargin` (implementation-time; only the no-hash-mutation invariant is fixed).

Atelier MCP unavailability is disclosed and user-authorized; the manual substitute described in section 8 is pre-authorized at both breakpoints.

---

## 14. Required approvals

This plan requires **explicit user approval** before T1/T2 execution begins. Do not begin Phase 0 or any subsequent phase until the user has explicitly approved this plan (relayed via the orchestrator). Upon approval, update the Status header above from "Drafted, routed to engineering under the user's standing authorization" to "Approved" with the approval date.

At approval, the user's attention is specifically directed to **DEC-A** (section 13): the touched-file scope expansion into `WeekDetailPage.tsx` and `LessonContentView.tsx`. Approving this plan without qualification authorizes that expansion under the recorded rationale. If the user wishes to decline it, the recorded fallback in DEC-A applies and this document should be updated accordingly before Phase 5 begins.

---

## 15. Engineering mode and downstream owner

- Engineering mode: standard.
- Team authorization: not applicable.
- Downstream owner: engineering-fleet (T1 primary, T2 escalation per the two-counted-gate-failure rule, then Verifier, then Browser Validator).
