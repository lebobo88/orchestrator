# Lizbeth Spanish, Issue #71: App header — compact single row + context status strip

**Status: APPROVED.** Approved by the user via direct reply "yes proceed as planned," given this session (2026-09-02) in direct response to the orchestrator presenting this plan's compact summary alongside the sibling #72/#73/#75 plan. The approval was for this specific plan. Decision 1 is explicitly resolved as recorded immediately below; decision 5 is acknowledged as non-blocking. See "Required approvals" for the status of decisions 2 through 4. `engineering-fleet` may now dispatch the Ordered work section.

**Decision 1 resolution (recorded at approval).** `branding.brand_name` is KEPT, not deleted. It is real, shipped, owner-configured functionality with its own Brand & Design admin screen and must not be silently dropped. It is relocated to a smaller, secondary spot in the compact header rather than removed, on the rationale that its absence from both reference artboards (D.2, E.2) does not outweigh its status as existing shipped functionality. This supersedes the plan's option-(a)/(b)/(c) framing in decision 1 below: the user's instruction is relocation within the header to a secondary position, not a move to the footer (option a) and not removal (option c). Engineering must implement this relocation as part of ordered-work step 4's header restructuring; the exact visual treatment (type scale, position relative to the eyebrow/title lockup) is left to implementation within the plan's existing typography and token constraints, consistent with decision 5's acknowledgement that some presentational specifics remain open.

**Focus-trap mechanism confirmation (recorded at approval).** Per the design review's correction, this plan extracts a shared `useFocusTrap` hook from the existing `Modal.tsx` component (ordered-work step 1) for reuse by the mobile Menu panel (step 5), rather than building a second, parallel focus-trap mechanism. This was already the plan's design as written; it is restated here as an explicitly confirmed condition of approval.

---

Plan ID: `lizbeth-spanish-issue71-app-header-compact-status-strip`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: `engineering-fleet` (after explicit user approval)
Design route: standard (`design-director`, `ux-architect`, `visual-system-designer`, `design-reviewer`; prototype forbidden; model tier Sonnet; existing-system mode: preserve)

## Outcome

GitHub issue #71 (medium-high priority) asks that the authenticated global app header come into fidelity with Field Journal reference artboards D.2 (desktop @1440) and E.2 (mobile @390): a compact single-row header plus a new dark context status strip, and a mobile header information architecture that no longer consumes the entire viewport before content. The audience is every student and the owner, on every authenticated route.

Observable result: the header collapses to one fixed-height row at both breakpoints (approximately 83px desktop, approximately 71px mobile), a new non-decorative Context Status Strip renders as a sibling immediately after the header on `/roadmap`, the week-detail route, and `/feedback`, and the mobile nav becomes a single "Menu" trigger opening a full-screen accessible panel instead of the current 2x2 button grid.

## Scope

**In scope:**

- Restructuring the `AuthenticatedApp` header markup in `App.tsx` and its corresponding rules in `App.css`.
- A new Context Status Strip component with four states (loading, error, empty, populated) and a route allowlist.
- Replacing the mobile 2x2 nav grid with a hamburger-triggered full-screen panel.
- Extracting a shared `useFocusTrap` hook from `Modal.tsx`.
- Adding a `control--nav` `Control` tier and a fixed-square `menu-trigger` variant.
- Adding three additive token aliases (no renames, no removals).
- Retargeting the `.app-header h1` accessibility-trigger clearance selector.
- Resolving how the App shell accesses enrollment/band/week state for the strip.

**Non-goals, explicitly declared:**

- No change to routing, auth, or RLS.
- No change to any routed page's own content or its own `<h1>`.
- No change to the unauthenticated `auth-split-layout` screens.
- No redesign of `AdminShell`.
- No removal or renaming of any already-shipped token.

## Repository findings

Verified by the nested Researcher and the standard design route (director, UX architect, visual-system designer), independently confirmed by design review:

- Production header markup: `App.tsx`, function `AuthenticatedApp()`, lines 117-171. Structure: `header.app-header` > `div.app-header-brand-lockup` (`p.app-header-eyebrow` "Lizbeth Spanish · Field Workbook"; `h1` "Learn in the open"; `p.subtitle` "Owner workspace / Student workspace"; `p.app-header-brand-name` `{branding.brand_name}`) plus `<BrandLogo>` plus `div.app-header-tools` (`nav.app-nav` with Roadmap/Learn/Feedback/[Owner workspace] plus Sign out). Nav buttons currently use the legacy `demo-button secondary` class.
- Header CSS: `App.css` 357-445 (base), 634-644 (mobile padding), 686-689 (later overrides including `border-bottom:0` and the `::after` full-bleed rule), 739-764 (`@media min-width 56.25rem`, 3-column grid `brand logo tools`), 766-776 (`@media max-width 56.24rem` — `.app-header-tools` becomes a 2-column grid with `.app-nav` set to `display:contents` and full-width buttons; this is the current 2x2 mobile nav grid that consumes the viewport).
- Confirmed live defect: `App.css:442-445` — `.app-nav button[aria-current='page']` sets `background-color: var(--color-paper-200)`, identical to the header's own `--color-surface-chrome-default` ground, so the current-page background paints nothing visible.
- Existing accessible modal (must be reused, not duplicated): `src/components/Modal.tsx` — `role="dialog"`, `aria-modal="true"`, an Escape effect at lines 36-47, a focus-trap/Tab-cycle/restore effect at lines 50-130, backdrop click-to-close, trigger-focus restoration at 118-129. Consumed by `RegisterStudentModal.tsx`, `AdminStudentModals.tsx`, `AccessibilitySettings.tsx`, `AdminStudentsPage.tsx`, `CourseWorkspacePage.tsx`. Covered by `Modal.test.tsx`, `Modal-FocusTrap-ShiftTab.test.tsx`, `Modal-FocusTrap-Boundaries.test.tsx`, `ModalStackingAndInertness.test.ts` — the last documents adopted judge finding J-03-1 and is a source-level scan of static z-index literals across `.css` files that explicitly excludes `Modal.css`'s own selectors; it asserts nothing about `Modal.tsx`'s JS, so a behavior-preserving hook extraction of lines 36-130 cannot affect it.
- Enrollment data is NOT available at `App.tsx` level today. `fetchEnrollmentsWithBand()` (`src/services/roadmapData.ts:60`) is called independently and redundantly by `RoadmapPage.tsx:40`, `WeekDetailPage.tsx:194`, and `FeedbackForm.tsx:111`. No shared enrollment context or hook exists. Current-week derivation additionally requires `computeWeekRoadmap()` (`src/lib/roadmap.ts`) and `fetchLessonsForBand()`.
- `session.user.email` is available in the header today via `useAuth()`.
- Owner/admin users have zero enrollments (`isOwnerUser`, `App.tsx:85`) and are redirected to `/admin/dashboard` (`App.tsx:88`). Students may hold multiple band enrollments (`RoadmapPage` renders one `BandRoadmap` per enrollment and shows a jump-list at 2+).
- `FeedbackForm.tsx` holds compose state — `content` at line 78, plus `feedbackType`/`courseId`/`lessonId` — purely in local React state with no draft-save mechanism anywhere in the file.
- Two pre-existing transient branches render a status paragraph with no `<h1>`: `App.tsx:195-196` (owner-redirect) and `CourseWorkspacePage.tsx:73` (pre-load). Both are currently masked by the header's `<h1>`.
- `Control.tsx`'s `ControlTier` union has exactly 6 members: `primary`, `secondary`, `caution-reversible`, `caution-irreversible`, `quiet`, `quiet-outline`. `Control.css`'s forced-colors block spans lines 154-197 with `ButtonFace`/`ButtonText`/`Highlight` role assignments.
- `--color-focus-ring` is defined at `App.css:40` as `var(--color-ink-slate, #3d5f6b)`, with consumers at `App.css:212` and `App.css:788`. `--color-focus` (same hex) lives at `field-workbook.generated.css:55`.
- `HeadingAccessibilityButtonClearance.test.ts` locks `.app-header h1` (`App.css` 638-640) and `.app-main h1` (`App.css` 655-657) as two separate clearance targets. The "Aa" trigger is a viewport-fixed sibling mounted independently in `App.tsx`.

**Research evidence.** None — this is a local fidelity gap against in-repo reference artboards; no external research question was involved.

## Reviewed design handoff

```
DESIGN_ROUTE
profile: standard
agents_required: design-director, ux-architect, visual-system-designer, design-reviewer
prototype: forbidden
model_tier: sonnet
existing_system_mode: preserve
END_DESIGN_ROUTE
```

**Design review status: PASSED**, on revision 1. Revision 1 corrected five findings: one HIGH (a false claim that no modal primitive existed), two MEDIUM (`.app-main h1` clearance wrongly declared dangling; a blanket "no unsaved work" claim contradicted by `FeedbackForm`), two LOW (`--color-focus-ring` citation; an overreaching one-h1-per-route claim). The reviewer independently recomputed every contrast ratio and confirmed every cited token exists at the claimed value.

### Header row, all breakpoints

`<header>` remains the sole banner landmark (implicit, no `aria-label` — only one instance per page). DOM/visual order: logo mark, then title lockup ("Lizbeth Spanish" eyebrow `<p>` plus "Field Journal" `<p>`, neither a heading), then inline nav (desktop >= 56.25rem: Roadmap / Learn / Feedback / [Owner workspace, owner-only]), then Sign out (desktop) or a single Menu trigger (mobile < 56.25rem, replacing nav and Sign out in the row entirely).

### Height budgets

Desktop 83px = `--space-4` (16px) + `--space-4` (16px) + `--control-height` (48px) + `--border-width-rule` (3px), within 1px of the approximately 84px D.2 target. Mobile 71px exactly = `--space-3` (12px) x2 + a 44x44px Menu-trigger box (`--hit-target-min`) + `--border-width-rule` (3px). `Control`'s 48px `--control-height` is a system-wide invariant: the header budget was fit to it, not the reverse. `--size-header-control-height` (2.25rem / 36px) is superseded for header nav and Sign out because it is below the 44px minimum touch target, and must not persist as a competing cascade value.

### Strip DOM position

Sibling AFTER `</header>`, before `<main>` — not nested inside the banner landmark.

### Heading semantics

Retire `<h1>Learn in the open</h1>` entirely; "Field Journal" and "Lizbeth Spanish" become non-heading `<p>`. Resulting outline: `/roadmap` -> single h1 "Your roadmap" (`RoadmapPage.tsx:83`, unchanged); `/roadmap/:id/week/:n` -> single h1 "Week {n}" (`WeekDetailPage.tsx:274`, unchanged). Every ready/error-state authenticated route already carries its own route-level h1. Two transient exceptions are named and ACCEPTED as pre-existing residual states, not fixed by this issue: `App.tsx:195-196` and `CourseWorkspacePage.tsx:73`.

### Strip route allowlist

Renders only on `/roadmap`, `/roadmap/:id/week/:n`, and `/feedback`. Does not render on `/learn` or anywhere in `/admin/*`.

### Strip states (four, sharing one visual container so layout never shifts)

- **Loading** — identity line renders immediately (email is synchronous via `useAuth`); band/week line shows a neutral placeholder sized and positioned identically to the populated line.
- **Error** — identity line still renders; band/week shows a neutral degraded fallback, non-blocking; the rest of the route renders normally.
- **Empty** (authenticated, zero enrollment rows — a real state distinct from loading) — identity line plus a "no active enrollment" fallback.
- **Populated single** — desktop two lines ("STUDENT · {email}" / "{BAND} · WEEK {n} OF {total}"), mobile one condensed progress-only line with the identity line dropped uniformly across all four states at that breakpoint.

### Strip multi-enrollment, route-specific

- `/roadmap` (no `:id`) shows an aggregate ("{N} BANDS ENROLLED"), never guessing one band.
- `/roadmap/:id/week/:n` shows that specific band and week since the URL disambiguates.
- `/feedback` shows the identity line only, no band/week line, because band selection there is an in-form control and asserting one would mislead.

### Strip semantic role

A plain non-live container — explicitly NOT `aria-live`, NOT `role="status"`, NOT any landmark role. It is persistent chrome the user already attends to via route navigation; a live region would duplicate the route's own heading-change signal.

### Mobile nav

A single "Menu" trigger (`aria-label="Menu"`, 44x44px minimum, 3-bar `aria-hidden` glyph) opens a full-screen app-owned overlay panel (`position:fixed; inset:0; background --color-surface-interactive-default`). Close control top-right (`Control` secondary); items as a vertical stack of full-width `Control` secondary rows with Sign out last; same `aria-current` logic as desktop. The panel's keyboard trap behavior MUST REUSE a shared `useFocusTrap` hook extracted from `Modal.tsx` lines 36-130 — Tab/Shift+Tab cycling, Escape-to-close, and trigger-focus restoration — NOT a parallel inert-based mechanism. Only the visual choice differs (full-viewport rather than centered dialog plus backdrop), justified by avoiding partial-clip focus-trap edge cases at 390px and by matching E.2's full-row-replacement idiom. Escape or Close returns focus to the Menu trigger; activating a nav item both navigates and closes. Height invariant: with nav and Sign out off-canvas the header row height no longer depends on item count (owner 4 vs student 3), fixed at approximately 71px; total mobile chrome is a bounded approximately 100-103px, replacing today's unbounded stacked block plus 2x2/2x3 grid.

### Dispositions

"Learn in the open" h1 retired. "Owner workspace / Student workspace" subtitle dropped (absent from both artboards; redundant with the conditional "Owner workspace" nav item). `branding.brand_name` is UNRESOLVED and must not be silently dropped — see decision 1.

### Sign out

No confirmation on `/roadmap`, the week route, `/learn`, or admin routes — low-cost and reversible, server-persisted data, nothing client-buffered at risk. SCOPED EXCEPTION on `/feedback` only: when Sign out is activated while `content.trim()` is non-empty or a non-default selection has been made, `FeedbackForm` shows an INLINE disclosure ("Your feedback isn't submitted yet.") with two buttons, "Sign out anyway" and "Keep editing." This is not a dialog, not `role="alertdialog"`, and has no page-wide focus trap. Focus moves to "Keep editing" by default; Escape or "Keep editing" dismisses and returns focus to Sign out; "Sign out anyway" proceeds. No native `confirm`/`alert`/`window.*` in either case.

### Tab order

Logo (skip) -> title lockup (skip) -> nav items left-to-right -> Sign out -> [mobile: the Menu trigger while the panel is closed] -> strip (non-interactive, no tab stop) -> first focusable element in `<main>`.

### Accessibility-trigger clearance

ONLY `.app-header h1` (`App.css` 638-640) dangles once the header h1 is retired; it must be removed or retargeted to the header's rightmost interactive control (Sign out on desktop, Menu trigger on mobile), along with its paired case in `HeadingAccessibilityButtonClearance.test.ts`. `.app-main h1` (`App.css` 655-657) and its paired test case are UNAFFECTED and must be left exactly as-is.

### Zoom/reflow

The single mobile treatment answers 320px CSS-px at 200% zoom; no separate ultra-narrow layout. The title lockup and the strip's single line truncate with ellipsis rather than wrapping, preserving the fixed height, via `white-space:nowrap; overflow:hidden; text-overflow:ellipsis`, with the full untruncated string preserved for assistive tech through a component-scoped visually-hidden clip-rect span reusing the technique already shipped in `FlashcardsViewer.css` — not a `title` attribute.

### Typography

Header eyebrow reuses the `.app-header-eyebrow` voice (IBM Plex Mono, `--font-size-caption` 13px, `--font-weight-label` 700, `--font-letter-spacing-eyebrow`, uppercase, `--color-ink-700`). Title "Field Journal": Fraunces, `--font-size-header-title` (35.2px desktop) / `--font-size-header-title-mobile` (24px mobile), weight 900, line-height 1.1, -.02em letter-spacing (component-local, single-consumer). Nav and Sign out labels: IBM Plex Mono, `--font-size-button-label` (0.875rem, Control's own scale, deliberately not shrunk to the reference's literal 13px), `--font-weight-label` 700, uppercase scoped only to the nav and menu-trigger variants, never the base `Control`. Strip text: IBM Plex Mono, `--font-size-label-small` (0.6875rem / 11px) at every breakpoint, `--font-weight-label` 700, `--font-letter-spacing-wider` (.18em), uppercase, line-height 1.4.

### Color and contrast (all independently recomputed by the reviewer and confirmed within rounding)

- Header background `--color-surface-chrome-default` (= `--color-paper-200` `#f0ebe2`, exact reference match); nav text ink-1000 on paper-200 = 15.25:1.
- Nav hover fill: the reference's literal `#ffd699` is byte-identical to the existing `--color-amber-200`, so there is no token gap — do not introduce a second, slightly different hover-fill token. Text on fill, ink-1000 on amber-200 = 13.22:1.
- The amber-200-vs-paper-200 edge alone is only 1.15:1, below the 3:1 non-text boundary requirement; this is resolved because every nav Control carries a PERMANENT ink-1000 border (15.25:1 against paper-200) that is load-bearing for that requirement — engineering must never make that border conditional on hover.
- Focus ring `--color-focus-ring` (`App.css:40`): 5.80:1 against paper-200, 5.03:1 against the amber-200 hover fill.
- `aria-current="page"`: background steps to `--color-paper-100` (fixing the `App.css:443` no-op defect) and the border thickens from 3px to 6px (`--border-width-accent`) solid ink-1000 as the required non-color cue (WCAG 1.4.1).
- Sign out desktop: Control secondary unmodified, ink-1000 on paper-100 = 17.07:1.
- Strip ground `--color-ink-1000` (`#1a1512`, exact reference match); populated text `--color-brass-300` (`#dca250`) = 8.04:1.
- COMPUTED AND EXCLUDED — do not use on the strip: `--color-brass-700` on ink-1000 = 3.12-3.14:1 (fails AA); `--color-status-neutral-text` (= ink-700) on ink-1000 = 2.04-2.05:1 (fails badly).
- Muted strip states use the new alias `strip.text.muted` -> the existing `--color-paper-300` = 13.17:1, distinct from the populated brass-gold by hue AND by differing literal text, never by color alone.
- Mobile Menu trigger: dashed ink-700 border on paper-200 = 7.48:1, with icon bars overridden to ink-1000 (15.25:1) rather than `quiet-outline`'s default brass-700.

### Seam

Reuse the header's existing self-owned `::after` full-bleed border-bottom technique (`App.css` 687-688) verbatim for both the strip-present and strip-absent cases. Add no second border or shadow at the strip's own top edge.

### New tokens (additive only, nothing renamed or removed)

`color.strip.text.muted` -> alias of the existing `paper.300`; `color.nav.hover-fill` -> alias of the existing `amber.200`; `color.nav.current.background` -> alias of the existing `paper.100`.

### New component work

A `control--nav` `Control` tier (a source-level `Control.tsx` union addition) because none of the 6 shipped tiers fit a flat, border-left-only nav link — primary/secondary/caution-* all carry a full-box border plus shadow, `quiet` carries inline-prose-link semantics, and `quiet-outline` carries a dashed-toggle semantic built for `aria-expanded` affordances. Its states: default (transparent, ink-1000 text, 3px left border) / hover (amber-200 fill) / focus-visible (`--color-focus-ring`) / active-pressed (paper-300 background step) / `aria-current` (6px left border plus paper-100 background). Plus a fixed-square `menu-trigger` variant of `quiet-outline` (44x44px, icon-color override), needing either a small new component or a documented one-off override since `Control` has no icon-only fixed-square mode. Both additions are additive; no existing `ControlTier` consumer is affected.

### Forced colors (new — the strip has no existing handling)

```css
.context-strip { background: Canvas; border-top: 1px solid CanvasText; }
.context-strip__line, .context-strip__line--muted { color: CanvasText; }
```

`control--nav` and `menu-trigger` follow `Control.css`'s existing forced-colors block pattern at lines 154-197 with the same `ButtonFace`/`ButtonText`/`Highlight` role assignments already proven correct there.

### Motion

The panel's open/close uses the already-shipped `--motion-duration-page-turn` (320ms) and `--motion-easing-standard`, which already collapse to 0ms under the app's existing root-level `prefers-reduced-motion` block. Any JS-orchestrated focus-move-after-animation must independently branch on `matchMedia('(prefers-reduced-motion: reduce)')`.

### Engineering invariant

The strip is real, non-decorative content and must NOT be authored as a `journal-devices.css` "device" — those are `aria-hidden`, zero-layout-affecting, and purely decorative.

## Interfaces and data

The strip requires App-shell access to current-route enrollment, band, and week state. Today that data is fetched independently and redundantly per page (`RoadmapPage.tsx:40`, `WeekDetailPage.tsx:194`, `FeedbackForm.tsx:111`) with no shared hook or context. Three options exist: lift the fetch into a shared context/provider, introduce a shared hook, or accept a fourth independent App-shell fetch. Separately, the `/feedback` Sign-out safeguard requires `FeedbackForm` to intercept or veto the header's global Sign out based on its own local draft state; candidate mechanisms include a guard callback or ref registered with the App shell, or a shared dirty-state hook. Neither is resolved by the design packet — see decisions 3 and 4 below.

## Ordered work

Owner for every step: T1 first-line, escalate to T2 on two counted gate failures.

1. Extract `useFocusTrap` from `Modal.tsx` lines 36-130 (Escape effect, Tab/Shift+Tab cycling, focus restoration) as a behavior-preserving refactor. `Modal.tsx` becomes its first consumer. `Modal.test.tsx`, `Modal-FocusTrap-ShiftTab.test.tsx`, `Modal-FocusTrap-Boundaries.test.tsx`, and `ModalStackingAndInertness.test.ts` must all pass unchanged.
2. Add the three additive token aliases through the DTCG source and the token pipeline; add the `control--nav` `ControlTier` and the `menu-trigger` variant with their full state and forced-colors coverage.
3. Resolve the App-shell enrollment/band/week data access per decision 3 and implement the Context Status Strip component with all four states, the route allowlist, and the multi-enrollment rules.
4. Restructure the `AuthenticatedApp` header markup and `App.css` rules to the compact single row; retire the h1, the subtitle, and (per decision 1) `branding.brand_name`; migrate nav and Sign out off `demo-button secondary` onto `Control`; fix the `App.css:443` `aria-current` no-op.
5. Build the mobile Menu trigger and the full-screen panel on `useFocusTrap`; delete the `App.css` 766-776 2x2 nav grid rules.
6. Retarget the `.app-header h1` clearance selector and its paired test case; leave `.app-main h1` untouched.
7. Implement the `/feedback`-scoped inline Sign-out disclosure per decision 4.
8. Update affected tests and add coverage for the strip's four states, the route allowlist, and the mobile panel's focus behavior.

## Acceptance and validation

- Full test suite green with only the deliberately updated `.app-header h1` clearance case changed; any other failure is a regression.
- `tsc --noEmit` clean.
- Token pipeline verification (`scripts/verify-token-pipeline.mjs`) passing after the alias additions.
- Independent Verifier pass, then a Browser Validator pass. Neither T1 nor T2 may self-approve completion.

## Browser UI dialog policy

REQUIRED. Native `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload` are prohibited. Sign out uses no dialog on the general routes; the `/feedback` exception is an inline non-modal, non-focus-trapped disclosure. The mobile panel is an app-owned overlay with keyboard and focus behavior supplied by the shared `useFocusTrap` hook.

## Browser UI validation

**Launch/readiness:** the project's existing Vite dev server; base URL `http://localhost:5173`; browser tooling confirmed working with tab reuse and dev quick-select login.

**Fixture/reset:** dev quick-select login; use labeled fixture data only (for example `STUDENT · student1@test.local` and `BEGINNER · WEEK 03 OF 26`) — never fabricate real student data.

**Viewports:** 1440x900 and 390x844, plus a 320 CSS-px / 200% zoom reflow spot-check on both the header row and the strip's single line.

**Desktop journeys:**

1. `/roadmap` single enrollment — one fixed-height approximately 83px row with no wrapping regardless of label or item count; strip shows two lines in brass-300 on ink-1000; the header `::after` bottom rule sits flush against the strip with no added gap or shadow.
2. `/roadmap` multi-enrollment — the aggregate line, not a specific band's week count.
3. `/roadmap/:id/week/:n` — that specific band and week.
4. `/feedback` — identity line only.
5. `/learn` and any `/admin/*` route on an owner session — the strip does not render, the header is identical, and route content begins flush below the header rule.
6. Strip loading with a throttled fetch — the placeholder matches the populated size and position, zero layout shift on resolve.
7. Strip error with a forced reject — the neutral fallback shows and the route stays fully interactive.
8. Strip empty with zero enrollment rows — the "no active enrollment" fallback.
9. Keyboard-only pass over the full tab order, with `aria-current` showing the 6px-border plus paper-100 non-color cue rather than fill colour alone, focus-ring contrast checked on both the plain ground and the amber-200 hover fill, and the nav hover's permanent border staying visible.
10. Sign out fires directly with no native dialog on every route without a draft.
11. On `/feedback` with non-empty content, Sign out shows the inline disclosure (not a modal, no page-wide trap), focus lands on "Keep editing," Escape and "Keep editing" both dismiss and return focus to Sign out, and "Sign out anyway" proceeds; with an empty draft it behaves exactly like the general case.
12. Computed-style contrast spot-checks at nav-default, nav-hover, `aria-current`, strip-populated, strip-muted, and the focus ring against both grounds, confirming >=4.5:1 text and >=3:1 non-text.

**Mobile journeys:**

1. `/roadmap` — a single approximately 71px row holding only logo, truncated title lockup, and the Menu trigger, with no inline nav or Sign out and no 2x2 or 2x3 grid anywhere; header plus strip resolve to a bounded approximately 100-103px with route content visible without scrolling past chrome.
2. The strip renders as a single condensed line across all four states.
3. Activating Menu opens the full-screen panel with focus on the visible Close control, the background page including the "Aa" trigger and `<main>` verifiably non-focusable and non-interactive, the same `aria-current` logic as desktop, and Tab/Shift+Tab cycling behaving identically to the existing `Modal` component since both now share one mechanism.
4. Escape and Close each close the panel and return focus exactly to the Menu trigger.
5. Activating a nav item both navigates and closes.
6. Repeat open/close under `prefers-reduced-motion: reduce` with no perceptible animation and no focus-move delay gated behind it.
7. An owner session's header row height is identical to a student's despite one extra panel item.
8. At 320 CSS-px / 200% zoom the header does not wrap or grow, the title lockup and strip line truncate with ellipsis, and the full untruncated strip string is still reachable via the visually-hidden span.
9. On `/feedback` at mobile width with a non-empty draft, Sign out from inside the panel shows the same inline disclosure with no native dialog.
10. Confirm existing `Modal` consumers elsewhere (the Register student flow, Accessibility Settings) are unaffected by the `useFocusTrap` extraction — spot-check at least one still opens, traps, and restores focus.

**Forced-colors pass:** on either viewport, confirm the strip renders with the Canvas/CanvasText fallback rather than invisible dark-on-dark, and that `control--nav` and `menu-trigger` follow the pattern already proven in `Control.css`.

**Non-goals for validation:** do not validate `branding.brand_name` placement or the logo real/decorative synthesis — both are unresolved product decisions and must not be treated as implementation-ready until the user confirms them.

## Risks and rollback

MEDIUM-HIGH. This is a global chrome change affecting every authenticated route, plus a behavior-preserving refactor of accessibility-critical shared focus-trap logic, plus a new architectural data path.

| Risk | Mitigation |
|------|------------|
| The `useFocusTrap` extraction silently regressing one of the five existing `Modal` consumers | The four existing `Modal` test files must pass unchanged; browser-validation mobile item 10 spot-checks a live consumer |
| `--size-header-control-height` persisting as a competing cascade value (App.css has prior documented cascade-collision defects of exactly this shape) | Explicit removal/override called out in ordered-work step 4 |
| The App-shell data path introducing a fourth redundant fetch or an over-broad refactor | Decision 3 below scopes the choice before implementation begins |

**Rollback.** Each ordered step is independently revertable, and steps 1 and 2 are additive and safe to land first. Containment: land step 1 and verify all `Modal` consumers before any header markup changes.

## Assumptions and decisions requiring user approval

**Decision 1 — RESOLVED at approval.** `branding.brand_name` disposition: this is real owner-configured, persisted content with its own Brand & Design admin screen, currently rendered at `App.tsx:127`. Neither reference artboard shows it in the header. The design packet had presented three options — (a) move to the footer, (b) admin-preview only, (c) retire with no replacement — and explicitly declined to decide. The user resolved this at approval: KEPT and relocated to a smaller/secondary spot within the header (not the footer, not removed), because it is real shipped functionality. See the Status section above for full wording. Implementation is ordered-work step 4.

**Decision 2 (user must decide at approval) — logo treatment.** The real-logo / decorative-fallback hybrid in the compact row is a UX synthesis not literally shown in either artboard. Confirm before implementation.

**Decision 3 (user must decide at approval) — App-shell enrollment data path.** Options: lift the fetch into a shared context/provider, introduce a shared hook, or accept a fourth independent App-shell fetch. Recommended: a shared hook or context, since it also removes the existing triple redundancy.

**Decision 4 (user must decide at approval) — the `FeedbackForm` / App-shell Sign-out interception mechanism.** Options: a guard callback or ref registered with the App shell, a shared dirty-state hook, or another approach. Recommended: the smallest mechanism that keeps the guard owned by `FeedbackForm` rather than special-casing the header.

**Decision 5 (approval-time acknowledgement) — placeholder copy.** Exact copy strings for the strip's four states and for the inline Sign-out disclosure are placeholders; the state model is settled, the wording is not.

**Accepted residual (not a decision, recorded for transparency):** `App.tsx:195-196` and `CourseWorkspacePage.tsx:73` render transiently with no h1 after the header h1 is retired. Both were already heading-less before this change and are not fixed by this issue.

**Open, non-blocking (does not require approval before implementation, may be resolved during build):** whether `control--nav`'s active-pressed state should reuse other tiers' translate-based press pattern given nav has no rest-state shadow; whether one 11px strip type token at all breakpoints is acceptable versus the reference's literal 11px/10px split; and slide-versus-fade for the panel's open transition (either satisfies reduced motion equally).

## Required approvals

**APPROVED.** The user approved this plan by direct reply "yes proceed as planned," this session (2026-09-02), in response to the orchestrator presenting this plan's compact summary together with the sibling #72/#73/#75 plan. Decision 1 (`branding.brand_name`) is explicitly resolved as KEPT and relocated to a smaller/secondary header spot, per the Status section and the resolved decision 1 above, as the specific decision the user's approval addressed by name. The orchestrator's presentation to the user covered this plan in compact-summary form; if decisions 2 through 4 were not each individually restated to the user at that time, their stated options/recommendations in this document remain the standing basis for implementation and should be confirmed with the user if any material ambiguity surfaces during build. Decision 5 is acknowledged as non-blocking placeholder copy. `engineering-fleet` may now dispatch the Ordered work section below; T1 is the first-line owner of every step, escalating to T2 on two counted gate failures, per this plan's existing acceptance and validation gates.
