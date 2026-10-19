
# Lizbeth Spanish, Issue #43: Screen — Brand + Catalog

**Status: Approved for engineering under standing authorization. Dated 2026-09-02.** See "Approval basis" immediately below for the basis and provenance of this approval.

## Approval basis

This plan was routed to engineering under the orchestrator's application of the user's standing authorization, not a user-verified per-plan approval. The record below is an orchestrator-applied inference, consistent with the Status line above, and follows the same provenance discipline the #31-#42 plans used.

- **Standing authorization quoted (verbatim, as relayed by the orchestrator):** "didn't i tell you to stop asking me for approval? i told you to keep going until all the gh issues are finished" and "don't stop until all the DS gh issues are implemented and browser validated." The orchestrator reports both statements as the user's own live-session standing authorization plus the explicit session goal, together covering this plan approval on the same basis already recorded on the #31-#42 plans.
- **Application:** the orchestrator applied this standing authorization to route this plan — issue #43 of `lebobo88/lizbeth-spanish`, the Field Journal DS milestone, the thirteenth of fourteen issues and the seventh issue in the screen-redesign batch, following #31-#42, all landed, verified, browser-validated, and design-reviewed PASS — to engineering without a further live per-plan checkpoint, because #43 is the next issue in the exact chain the user directed continuation through.
- **Pre-flight staleness check performed.** The orchestrator independently fetched the live GitHub issue #43 body via `gh issue view` and relayed it directly into Planner's context, satisfying the plan's pre-flight staleness check, consistent with the practice established for issues #40 through #42.
- **Two evidence-backed scope corrections to the issue body, found and applied during planning:**
  1. **Issue #43 incorrectly claims both screens are anonymous.** `BrandDesignPage.tsx` is actually owner-gated — mountable only inside the owner-gated `AdminShell` at `/admin/brand-design` — confirmed both by the code (`BrandDesignPage.tsx:16`'s `isOwnerUser` gate, `AdminShell.tsx:52`, `useRoute.ts:35`, `AdminShell.tsx:28-31`) and by the reference design itself, whose own eyebrow text literally reads "Owner desk · Brand" (`Field Journal DS.dc.html:1148`). Only `PublicCatalogPage` is genuinely anonymous-facing. No new anonymous route is created for the brand page.
  2. **The issue's "brand page should reflect the implemented token layer rather than a hand-maintained copy" criterion presumed a page that does not exist.** `BrandDesignPage` is actually a three-field owner settings form (primary color, secondary color, logo URL), not a token showcase or snapshot page. The criterion is met narrowly, via live-computed preview swatches sourced from the same clamp computation already backing the existing per-field `ColorPreview`, and via CSS expressed exclusively as existing design tokens, rather than by building a full token specimen gallery.
- **Two real defects caught and fixed by design review before engineering started**, both closed in the one `NEEDS_REVISION` cycle recorded in "Design review" below:
  1. A missing 390px header/footer padding reduction that would have left 112px of fixed padding at mobile width — the exact recurring overflow bug class already hit in #37, #39, #41, and #42.
  2. A CSS token (`--font-letter-spacing-eyebrow-wide`) claimed as already registered but with zero actual occurrences anywhere in the repo, which would have failed the build-breaking token lint at all four of its intended use sites.
- **`PLAN_DUCK` checkpoint deliberately not run.** Given this plan's moderate, bounded scope — a screen-level restyle across two already-existing files, with no data-model change and no new anonymous route — the orchestrator determined a `PLAN_DUCK` Codex judge checkpoint was not warranted, on the basis that this checkpoint is reserved for higher-risk, higher-blast-radius plans per this engagement's established pattern. The orchestrator proceeded directly to approval rather than requesting the checkpoint.
- Deterministic checks and the Verifier/Browser Validator passes in the ordered-work phase remain mandatory regardless of the `PLAN_DUCK` decision above.
- **Provenance label:** this basis reached Scribe entirely through the orchestrator's account of the session; Scribe has not independently observed the quoted user statements, the live issue fetch, the design-review cycle, or the two scope corrections beyond what is already recorded elsewhere in this document (see "Verified repository findings" and "Design review"). It is recorded here as an orchestrator-applied inference under standing authorization, NOT as a Scribe-verified per-document user approval.
- **Date:** 2026-09-02.

---

Plan ID: `lizbeth-spanish-issue43-brand-catalog-screens`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: `engineering-fleet`
Design route: standard (`design-director`, `ux-architect`, `visual-system-designer`, `design-reviewer`; prototype forbidden; model tier Sonnet; existing-system mode: preserve)

## Outcome and audience

GitHub issue #43, "Screen: Brand + Catalog" (labeled `role:anonymous`), thirteenth of fourteen issues in the Field Journal Design System milestone (#31-#44) and seventh of the screen-redesign batch.

Observable result: `src/pages/BrandDesignPage.tsx` (design source §D.8) and `src/pages/PublicCatalogPage.tsx` (§D.9) restyled to the Field Journal reference at 1440px, plus an authored-from-scratch 390px responsive composition for both, since no 390 artboard for either screen exists in the reference. §D.8 gains one net-new live preview block; §D.9 gains net-new header/footer chrome and an empty-catalog state using `JournalEmptyState`.

Audience: the T1/T2 engineer implementing this plan; the app owner (§D.8) and the anonymous site visitor (§D.9) who use the finished screens.

## Scope

**In scope:**

- `src/pages/BrandDesignPage.tsx` / (its stylesheet, `src/pages/OwnerSettingsPage.css`) — §D.8 restyle plus the net-new preview block.
- `src/pages/PublicCatalogPage.tsx` / its stylesheet — §D.9 restyle including net-new header/footer chrome, copy reconciliation, and the empty-catalog state.
- A from-scratch 390px reflow specification for both screens (breakpoint `max-width:700px`).
- `JournalEmptyState` (C.9) wired into the empty-catalog case, using existing, unmodified component API.
- A mandatory proactive source-level overflow audit before implementation.
- Browser validation at 1440x900 and 390x844.
- One optional new design token, `--font-letter-spacing-eyebrow-wide: .22em`, dual-written to both token files only if used (a `.22em` literal is the sanctioned alternative — see "Assumptions and decisions").

**Non-goals (binding — a writer must return `JOB_BLOCKED` rather than exceed these):**

- No new anonymous route for the brand page. `BrandDesignPage` remains owner-gated at its existing `/admin/brand-design` mount.
- No live full-token specimen showcase on the brand page.
- No migration of `BrandDesignPage` onto the shared `Control`/`Field` primitives — deferred, reasoned in "Assumptions and decisions."
- No 2-column tablet breakpoint for either screen.
- No change to `--control-height`'s shared default value.
- No restyle of `JournalEmptyState` itself; it is consumed as-is.
- No change to any other owner-area screen (`OwnerSettingsPage.css`'s edits are scoped to the classes `BrandDesignPage` itself uses).

## Verified repository findings

Grounded in a nested Researcher local-evidence pass (source ledger S1-S24, all paths with line numbers), independently re-verified by the design reviewer.

**CRITICAL SCOPE CORRECTION, evidence-backed.** Issue #43 states both screens are "the two screens an anonymous visitor sees." This is factually wrong for the brand half. `src/pages/BrandDesignPage.tsx:16` hard-gates on `isOwnerUser` and returns a permission-denied panel otherwise; it is mounted only inside `src/components/AdminShell.tsx:52` at `/admin/brand-design` (`src/hooks/useRoute.ts:35`), itself owner-gated at `AdminShell.tsx:28-31`. Decisively, the reference artboard agrees with the code, not with the issue body: §D.8's own eyebrow reads "Owner desk · Brand" (`Field Journal DS.dc.html:1148`) and depicts exactly the three fields already implemented. §D.8 is therefore scoped as a restyle of the existing owner-gated form. Only §D.9/`PublicCatalogPage` is genuinely anonymous-facing. No new route is created.

**SECOND SCOPE CORRECTION.** The issue's criterion that "the brand page reflects the implemented token layer rather than a hand-maintained copy" presumes `BrandDesignPage` is a token-snapshot page. It is not — it is a 3-field settings form (primary color, secondary color, logo URL). §D.8 depicts only those two owner-editable colors, not a token specimen. No token showcase is built. The criterion is satisfied narrowly: the net-new preview block renders live from the same computed clamp values already producing the existing per-field `ColorPreview`, and every CSS value in both screens is expressed as an existing `--token` custom property rather than a hardcoded snapshot.

**Stale line citations.** The issue cites approximately lines 145-165 (§D.8) and 157-134 (§D.9). Both are wrong, consistent with every prior issue in this milestone. Verified true locations: §D.8 = `design/field-journal/Field Journal DS.dc.html:1145-1179`; §D.9 = `:1183-1242`.

**No 390 artboard exists for either screen** — independently confirmed twice. Section E of the reference contains only E.1-E.6 (Sign in, Roadmap, Week detail, Flashcards, Feedback, Owner desk), none of them brand or catalog. The 390 spec in this plan is authored from A+B+C primitives, not transcribed from a mock.

**Locked test invariants (all currently green per baseline claim; these constrain the redesign absolutely and must not be weakened):**

- `src/__tests__/PublicCatalogPage-anonymous-access.test.tsx`: list H1 exactly "Explore courses"; cards must remain `<article>` elements; empty catalog renders zero `<article>`s; fetch failure text exactly "Catalog unavailable."; detail root must be `<main class="course-workspace">`; loading/error child order exactly `[0]` back button "← Browse courses", `[1]` `<h1>Course preview</h1>`, `[2]` `<p role="status">`; error text exactly "This course is not available."; loading text exactly "Loading preview…".
- `src/__tests__/publicCatalogEnrollment.test.tsx`: button accessible name matches `/request enrollment/i`; enrollment failure must be `role="alert"`, success passive; message strings are regex-asserted and must not be renamed.
- `src/__tests__/Issue4SettingsPages.test.tsx`: loading state = exactly one `role="status"`, zero buttons, zero textboxes; non-owner state = heading matching `/brand.*design/i` plus `role="alert"` matching `/permission/i`, zero buttons/textboxes; labels keep matching `/primary brand color/i`, `/secondary brand color/i`, `/logo url/i`; save button matches `/save brand/i`; an invalid field sets `aria-invalid="true"` plus `aria-describedby` pointing to `{fieldId}-error` and moves focus to the first offending field; save payload always carries all three keys; the form must stay mounted during a post-hydration `loading:true` refresh re-render.

**Build-breaking CSS lint, `src/__tests__/tokenFallbackAuditLint.test.ts`:** no `var(--x)` referencing an undefined custom property; no raw hex literal in any CSS outside `src/tokens/`, including inside `var(--x, #hex)` fallbacks; no non-zero `border-radius` anywhere; no `box-shadow` with non-zero blur. Any new token must be dual-written to `.atelier/tokens/field-workbook.tokens.json` and `src/tokens/field-workbook.generated.css` per the established convention, guarded by `fieldJournalTokens.test.ts` and `issue36Tokens.test.ts`.

**Overflow audit baseline (must be reconfirmed as ordered-work step 2, before implementation).** `.course-grid` is `repeat(auto-fit,minmax(240px,1fr))` — safe at 390. `.course-workspace h1,h2{overflow-wrap:anywhere;word-break:break-word}` already exists and covers catalog card titles. `.course-workspace` has no horizontal padding by default; `padding-inline:var(--space-2)` is added only inside `@media(max-width:700px)` (`CourseWorkspace.css:3`). `src/pages/OwnerSettingsPage.css` has zero `@media` queries and its inputs declare no `width` or `box-sizing` — a real, unclosed overflow gap. `.workspace-tabs` and `.admin-shell-nav ul` use deliberate contained `overflow-x:auto`; that pattern is sanctioned for those nav strips only and must never leak to the page body.

**`JournalEmptyState` (C.9) API**, confirmed at `src/components/journal/JournalEmptyState.tsx:5-10`: `{ illustrationSrc: string (required), eyebrow?: string, bodyText: string (required), className?: string }`. `PublicCatalogPage` currently has no empty state for `courses.length === 0`.

**Dev server:** `npm run dev` runs Vite, default port 5173 (`vite.config.ts:6-9`), overridable via `npm run dev -- --port <N>`.

## Research evidence and its limits

A nested Researcher pass returned a full local-evidence packet (source ledger S1-S24), grounded entirely in repository inspection; no web sources were used. Key sources: `src/pages/BrandDesignPage.tsx`; `src/pages/PublicCatalogPage.tsx`; `src/components/AdminShell.tsx`; `src/hooks/useRoute.ts:35`; `design/field-journal/Field Journal DS.dc.html:1145-1242`; `design/field-journal/ADOPTION-PLAN.md:110` (ratifies brass.300 `#dca250` at 6.80:1 on ink.900 as the dark-panel eyebrow ink); `src/tokens/tokenSystem.ts`; `src/tokens/field-workbook.generated.css`; the three locked test files listed above; `src/__tests__/tokenFallbackAuditLint.test.ts`; `src/pages/CourseWorkspace.css`; `src/pages/OwnerSettingsPage.css`; `src/pages/OwnerDashboardPage.css:69-78`; `src/components/ui/Control.tsx`/`Field.tsx`; `src/components/journal/JournalEmptyState.tsx`.

**One acknowledged research limit.** The Researcher's Bash allowlist blocked `npx vitest`, so the green baseline claimed above was NOT executed by any planning-stage agent. Establishing it is ordered-work step 1, mandatory and blocking.

## Design route and handoff

```
DESIGN_ROUTE
profile: standard
reasons: two screens, a multi-state catalog, net-new UI (D.8 preview block, D.9 header/footer chrome, empty state), and a from-scratch 390 composition with no reference artboard
agents_required: design-director, ux-architect, visual-system-designer, design-reviewer
prototype: forbidden
model_tier: sonnet
existing_system_mode: preserve
END_DESIGN_ROUTE
```

The full reviewed `DESIGN_HANDOFF`'s load-bearing content is reproduced below, verbatim in substance, after one evidence-backed `NEEDS_REVISION` cycle with 11 findings, all resolved (see "Design review").

### Screen §D.8, Brand (1440)

Eyebrow "Owner desk · Brand": `--color-brass-700`, mono 11px/600/`.22em`. H1: display-sm token group (Fraunces 900 52px) plus literal `line-height:.92`, `letter-spacing:-.035em`. Subhead: `--font-size-body` (17px) / `--font-line-height-body` / `--color-ink-700`.

**Net-new preview block** (explicitly new markup, state wiring, and component structure — not a restyle of existing DOM). Container: `border:var(--border-width-rule) solid var(--color-ink-1000); background:var(--color-paper-200); padding:var(--space-5); display:flex; align-items:center; gap:var(--space-5)`. 72x72 mark: `background:var(--color-ink-1000); border:var(--border-width-rule) solid var(--color-ink-1000)`, letterform Fraunces 900 34px `--color-brass-300`. The mark is the static system-default "L" — it does not derive from the color fields — and is `aria-hidden="true"` as decorative; the visible "Lizbeth Spanish" text carries the block's accessible meaning. "Preview" label: mono 10px/600/`--color-brass-700`/literal `.24em`. Brand-name line "Lizbeth Spanish": Fraunces 900 26px/1.1/`--color-ink-1000`, static (no `brand_name` field exists in this component's state), with `min-width:0` on its column. Two 22x22 live swatches: `border:var(--border-width-strong) solid var(--color-ink-1000); gap:var(--space-2)`, each driven by the same computed value already produced for that field's existing per-field `ColorPreview` — `clampColorForMultipleContrasts(value, BRAND_COLOR_SURFACE_CONSTRAINTS).hex`, never the raw input, so there is exactly one source of truth. Invalid/incomplete values reuse the existing `COMPLETE_HEX_PATTERN` gate and render a neutral `--color-paper-300` fill with a `--border-width-thin` dashed `--color-ink-700` border — never undefined, never a crash. The new block and the existing per-field `ColorPreview` coexist: `ColorPreview` stays exactly as implemented beneath each field and remains the authoritative per-field micro-feedback and screen-reader announcement.

**D.8 fields/controls.** Labels: mono `--font-size-label` (12px) / literal weight 600 (not `--font-weight-label`, which is 700) / `--font-letter-spacing-wider` / `--color-ink-1000`. Color swatch 48x48: `border:var(--border-width-rule)`. Input, idle: `flex:1;min-width:0;box-sizing:border-box;min-height:var(--control-height);padding:0 14px;background:var(--color-paper-100);color:var(--color-ink-1000);border:var(--border-width-rule) solid var(--color-ink-1000);border-radius:var(--radius-square)`, mono `--font-size-body`. Focus: `outline:var(--focus-ring-width) solid var(--color-focus); outline-offset:var(--focus-ring-offset)`. Invalid: `border-color:var(--color-status-error-border)`. Error line: mono `--font-size-caption`/`--color-status-error-text`, positioned after `ColorPreview`, `role="alert"` preserved verbatim. Logo helper text: mono 12px `--color-ink-700` literal `.1em`. Action row: `display:flex;align-items:center;gap:var(--space-5);flex-wrap:wrap`. Save button: `min-height:var(--size-control-height-submit)` (54px, scoped override only); `padding:0 var(--space-6);background:var(--color-ink-1000);color:var(--color-paper-50);border:var(--border-width-rule) solid var(--color-ink-1000);box-shadow:var(--shadow-brass)`, mono `--font-size-button-label`/`--font-weight-label`/literal `.14em`; hover `translate(-2px,-2px)` plus `--shadow-brass-press`; active `translate(3px,3px)` plus `--shadow-brass-none`; disabled reuses `Control.css`'s universal disabled pattern. Confirmation chip: `border:var(--border-width-strong) solid var(--color-ink-moss); background:var(--color-badge-tint-inclusive); color:var(--color-ink-moss)`, mono 12px/600/literal `.12em`, `padding:var(--space-2) var(--space-3)`.

**Existing-token corrections** (wrong tokens in use today, corrected by this pass):

- `.owner-settings-field input,textarea` — `border:1px solid var(--color-ink-800)` becomes `border:var(--border-width-rule) solid var(--color-ink-1000)`.
- `.owner-settings-color-swatch` — `1px solid var(--color-ink-800)` becomes `var(--border-width-strong) solid var(--color-ink-1000)`.
- `.owner-settings-save-button` — `2px solid var(--color-brass-600)` / `background:var(--color-brass-600)` / no shadow becomes `var(--border-width-rule) solid var(--color-ink-1000)` / `background:var(--color-ink-1000)` / `box-shadow:var(--shadow-brass)`.

### Screen §D.9, Catalog (1440)

Net-new header/footer chrome, implemented as landmark siblings of `<main>`, never children, so the locked `<main>` child order cannot be disturbed.

**Header:** `background:var(--color-ink-900); padding:var(--space-6) 56px; display:flex; align-items:center; justify-content:space-between; gap:var(--space-6)`. Mark 44x44: `background:var(--color-brass-300); border:var(--border-width-rule) solid var(--color-brass-300)`, Fraunces 900 `--font-size-logo-mark` `--color-ink-1000`. Wordmark: mono 12px/600/.22em/`--color-brass-300`. Sign-in button: `min-height:var(--hit-target-min)` (44px); `padding:0 var(--space-5); background:var(--color-brass-300); color:var(--color-ink-1000); border:var(--border-width-rule) solid var(--color-brass-300)`, mono `--font-size-caption`/`--font-weight-label`/literal `.12em`; hover becomes `--color-paper-50` background and border.

**Hero:** eyebrow mono 12px/600/.22em/`--color-brass-700`. H1: `--font-size-hero-lg` (88px)/900/Fraunces/literal `.88`/literal `-.04em`/`--color-ink-1000`. Body: `--font-size-header-subtitle` (18px)/`--font-line-height-body`/`--color-ink-700`, container `max-width:60ch`.

**Grid:** `repeat(3,minmax(0,1fr)); gap:var(--space-8)` at `>=701px`. Card: `background:var(--color-paper-50); border:var(--border-width-rule) solid var(--color-ink-1000); box-shadow:var(--shadow-sheet); display:flex; flex-direction:column`. Band header background = `--color-band-beginner` / `--color-band-intermediate` / `--color-band-advanced` per volume (mandated, exact hex match to the reference); `padding:var(--space-5) var(--space-6); border-bottom:var(--border-width-rule) solid var(--color-ink-1000)`; label mono `--font-size-label-small` (11px)/600/.22em/`--color-paper-50`. Card h2: Fraunces 900 literal 36px/1/`-.03em`/`--color-ink-1000`; remove the mock's hardcoded `<br>` and rely on the existing `.course-workspace h1,h2{overflow-wrap:anywhere}` rule — no new CSS needed. Card caption: mono `--font-size-label`/regular weight/literal `.14em`/color matches the corresponding `--color-band-*` token. Card body: `--font-size-body`/`--color-ink-900`, `flex:1; margin-bottom:var(--space-6)`. Card button: `width:100%; min-height:var(--control-height); background:var(--color-paper-100); border:var(--border-width-rule) solid var(--color-ink-1000); box-shadow:var(--shadow-card)`; hover `translate(-2px,-2px)` plus `--shadow-press`.

**Footer:** `border-top:var(--border-width-rule) solid var(--color-ink-1000); padding:var(--space-5) 56px; display:flex; justify-content:space-between`; spans mono 12px `--color-ink-700` literal `.2em`, left uppercase, right not.

**D.9 copy reconciliation** (both replacement strings are reference-artboard copy, not newly invented): eyebrow "Lizbeth Spanish" becomes "Three volumes · 78 weeks · A1 to C1"; body "Find your next Spanish learning journey." becomes "Each volume is twenty-six weeks. Weeks open on your own schedule, counted from the day you enrol — not on a fixed class calendar." The locked H1 "Explore courses" is unchanged. The detail view's "This preview shows the published learning experience. Sign in to enroll." is kept verbatim.

**Empty catalog:** render `JournalEmptyState` in the grid's position. Proposed copy requiring sign-off: eyebrow "Catalog empty", `bodyText` "No course volumes are published yet. Check back soon." Recommended `illustrationSrc`: `src/assets/spot-illustrations/spot-02-compass-pocket-watch.png` (verified to exist; `spot-03-open-book.png` is already claimed by the feedback/roadmap empty states, so reusing it would collide one illustration across two unrelated meanings). Do not restyle `JournalEmptyState` itself. Preserve the zero-`<article>` invariant.

### 390 responsive spec (authored, no reference artboard)

Breakpoint `max-width:700px` for both screens, chosen to match the existing `CourseWorkspace.css:3` convention rather than `OwnerDashboardPage`'s 50em/28em steps — that precedent is wrong here, since it targets a dense table, not a linear form/catalog.

- D.9 hero H1 becomes `--font-size-hero-sm` (46px).
- D.9 header: `flex-wrap:wrap; row-gap:var(--space-3)`; `header > div:first-child{min-width:0}`; wordmark `overflow-wrap:anywhere`; Sign-in `min-height` stays 44px.
- D.9 grid becomes `grid-template-columns:minmax(0,1fr)` — deliberately not a bare `1fr`, whose implicit floor is `auto`/min-content rather than 0.
- D.9 footer: `flex-wrap:wrap; gap:var(--space-2)`.
- **D.9 horizontal gutter fix** (caught by design review; this is precisely the milestone's recurring bug class). `main.course-workspace` already receives `padding-inline:var(--space-2)` free at `<=700px` from the existing rule, but the net-new header/footer were not covered by that rule and would have kept the reference's literal 56px per side — 112px of gutter at a 390px viewport. Required: `@media(max-width:700px){header,footer{padding-left:var(--space-2);padding-right:var(--space-2)}}`. Resulting content width at 390px = 390 − 16 = 374px; browser validation must measure this.
- D.8 preview block: `.owner-settings-preview-text{min-width:0}` unconditionally and `.owner-settings-preview-name{overflow-wrap:anywhere}`; the row layout never stacks, so no `@media` is needed for it.
- D.8 inputs (closes the real existing gap): `.owner-settings-field input,.owner-settings-field textarea{width:100%;box-sizing:border-box}` — additive, non-conflicting with the `display:flex;flex-direction:column` parent.
- D.8 action row: `flex-wrap:wrap`, confirmed to actually trigger at 390 given the success-chip copy length beside "Save brand".
- Guard list (elements already covered and requiring no further rule): D.8 preview text column and brand-name line; D.8 color-input flex rows keep the reference's `flex:1;min-width:0`; D.9 header wordmark; D.9 card h2 (already covered by the existing `overflow-wrap` rule); D.9 grid tracks (already `minmax(0,...)`).

### Contrast

Verified with a contrast tool, WCAG 2.x AA operative; independently re-verified by the reviewer.

- brass.300 `#dca250` on ink.900 `#2a2420` = 6.80:1 PASS — the ratified dark-panel eyebrow ink, per `ADOPTION-PLAN.md:110`.
- ink.1000 on brass.300 = 8.04:1.
- paper.50 on ink.1000 = 17.65:1.
- brass.600 `#866843` on paper.50 = 5.02:1.
- terracotta.600 `#a85e4a` on paper.50 = 4.688:1 — the tightest margin in either screen against the 4.5 floor at 13px caption size; treat as a hard floor, do not darken paper.50 or lighten terracotta.600.
- ink.slate `#3d5f6b` on paper.50 = 6.72:1.
- brass.700 `#7c6136` on paper.50 = 5.65:1.
- ink.700 on paper.50 = 8.64:1.
- ink.moss on `--color-badge-tint-inclusive` = 6.87:1.
- brass.700 on paper.200 `#f0ebe2` (the 10px "Preview" label, the smallest text in either spec) = approximately 4.88:1 PASS.

**Negative check, mandated by the issue.** No spec anywhere places brass.500 or brass.700 as text on ink.900/ink.1000. Tested defensively: brass.500 on ink.1000 = 4.8:1 and brass.700 on ink.1000 = 3.12:1 (fails AA), confirming the ratified brass.300 substitution is correct and must not regress.

### Proposed token, not yet added

`--font-letter-spacing-eyebrow-wide: .22em` — 4 uses: D.8 eyebrow, D.9 wordmark, D.9 hero eyebrow, D.9 band label. A repo-wide grep confirms zero occurrences today; `field-workbook.generated.css:45` defines only `--font-letter-spacing-eyebrow: .08em`, a different value. If used, it must be dual-written to `.atelier/tokens/field-workbook.tokens.json` and `src/tokens/field-workbook.generated.css` in the same change as the first referencing CSS rule, or the lint fails on an undefined custom property at all four sites. Sanctioned alternative: use the literal `.22em` at each site — letter-spacing literals are not covered by the lint — and treat the token as an optional follow-up.

### Control/Field non-migration (reasoned, deliberate)

`BrandDesignPage` does not migrate onto the shared `Control`/`Field` primitives in this pass, for three reasons: (1) `Field.tsx:87` renders the error `<div>` with no `role` attribute, so migrating would silently drop the tested `role="alert"` invariant; (2) `Field` has no slot for the interleaved `ColorPreview` between the input and the error line; (3) `Control` resolves height only via `--control-height` (48px, `Control.css:13`), never `--size-control-height-submit` (54px), so migration would render the Save button 6px short unless a scoped override is added anyway — buying nothing over direct token reuse. Full primitive migration is a legitimate separate follow-up once `Field` gains slotted content and a component-layer `role="alert"`.

### Deliberate, bounded override of the owner-area density note

`src/pages/OwnerSettingsPage.css:1-7` records a prior decision that the owner area is "deliberately more utilitarian than the student-facing surfaces." §D.8's ornate bookplate treatment overrides that note, consciously and narrowly, because: (a) §D.8's own ratified artboard depicts exactly this treatment for this screen, and matching it is a success criterion — a later, screen-specific decision; (b) the earlier note is a general density guideline aimed at the dense multi-field owner screens, not a blanket ban; (c) `BrandDesignPage` is small and its entire purpose is a visual brand preview, so an editorial treatment is contextually apt; (d) the override is scoped only to `BrandDesignPage`'s own classes and does not migrate to `OwnerSettingsPage`, `OwnerDashboardPage`, or any other owner-area screen.

### Disclosed normalizations (not verbatim transcriptions)

`--font-size-hero-lg` (88px) is used for the reference's 84px D.9 hero; its provenance comment (`field-workbook.generated.css:180-183`) shows it was calibrated against the D.1 login hero — a deliberate 4px reuse-over-new-token snap. Card button shadows snap one step up (reference 4px/6px becomes `--shadow-card` 5px / `--shadow-press` 7px) to avoid minting two single-use tokens. Vertical padding/gap snaps: preview block 22 to 20, swatch gap 6 to 8, action row 18 to 20, save button 26 to 24, D.9 header 26 to 24, band header 18 to 20, footer 18 to 20, error line 13 versus 12, hero body 18 versus 20, card line-height 1.55 versus 1.6. Card body margin 24px and grid gap 32px are exact, not snaps. The reference's `width:1440px` / `overflow:hidden` / `margin-bottom:56px` wrapper is the `.dc.html` document's artboard-canvas framing convention, applied identically to every comp in the file, and must not be implemented as app chrome.

## Design review

`DESIGN_REVIEW_RESULT` verdict PASS on the revised packet, after one evidence-backed `NEEDS_REVISION` cycle with 11 findings, all resolved. The revision fixed two genuinely blocking defects:

- **F3 (blocking).** The missing 390px header/footer gutter reduction — the milestone's own recurring overflow bug class, caught in review rather than in browser validation. Closed by the D.9 horizontal-gutter fix above.
- **F8 (blocking).** A phantom `--font-letter-spacing-eyebrow-wide` token claimed as already dual-written but with zero repo-wide occurrences — would have failed the build-breaking lint. Closed by explicitly marking the token as proposed-not-yet-added, with the `.22em` literal as the sanctioned alternative.

It also reclassified the D.8 preview block as net-new UI rather than a restyle (F1) and converted an undisclosed reversal of the utilitarian-owner-area decision into the explicit bounded override recorded above (F2).

The reviewer independently verified that `clampColorForMultipleContrasts`, `BRAND_COLOR_SURFACE_CONSTRAINTS` (`OwnerSettingsPage.tsx:7,10`), `COMPLETE_HEX_PATTERN` (`:27`), `--color-paper-300` (`field-workbook.generated.css:23`), `--border-width-thin` (`:7`), and `spot-02-compass-pocket-watch.png` all exist; that every other named token exists with the claimed values; and that the new bare `header,footer` tag selector does not regress the existing `.app-header`/`.app-footer`/`.ip-notice` elements, each of which already carries class-level horizontal padding that wins on specificity.

**One non-blocking robustness note, carried forward to engineering:** the `header,footer` selector introduced for the D.9 gutter fix is tag-level rather than class-scoped. Engineering may scope it to the new catalog chrome's own classes.

## Judge route

`PLAN_DUCK` eligible at the orchestrator's discretion before approval. No `CODE_REVIEW`/`VERIFICATION_CHALLENGE`/`VISUAL_REVIEW` trigger is mandatory: risk is medium, the change is CSS/markup-dominant with strong deterministic gates (three locked test files plus a build-breaking CSS lint plus browser validation at two viewports). Deterministic failures always dominate any judge finding. Standard call caps and shadow policy from `docs/JUDGE-CONTRACT.md` apply.

## Ordered work

Owner: T1 engineer, standard mode; escalate to T2 on two counted gate failures.

1. **Baseline first, before any edit (blocking; the Researcher could not run this).** Run `npx vitest run src/__tests__/PublicCatalogPage-anonymous-access.test.tsx src/__tests__/publicCatalogEnrollment.test.tsx src/__tests__/Issue4SettingsPages.test.tsx src/__tests__/tokenFallbackAuditLint.test.ts src/__tests__/fieldJournalTokens.test.ts` and record verbatim pass counts. If anything is already red, return `JOB_BLOCKED` rather than redesigning over a broken baseline.
2. **Proactive overflow audit, required before implementation** (this milestone hit this bug class in #37, #39, #41, and three times in #42 alone). Statically audit `BrandDesignPage.tsx`/`OwnerSettingsPage.css` and `PublicCatalogPage.tsx`/`CourseWorkspace.css` for: flex rows lacking `flex-wrap`; grid/flex children lacking `min-width:0`; fixed px widths; `white-space:nowrap` outside the two sanctioned nav strips; horizontal padding that can exceed 390px; and long unbroken strings. Record findings as evidence. Confirm and close the two known-in-advance findings: the 56px header/footer gutter and the missing `width`/`box-sizing` on the owner-settings inputs.
3. **TDD-first.** Write failing tests before production edits: an empty-catalog test asserting the `JournalEmptyState` eyebrow/body renders while zero `<article>`s remain; a test that the new D.8 preview block renders live swatches from the clamped values and shows the neutral placeholder for an incomplete hex; a test that the decorative mark is `aria-hidden`. Extend the existing suites rather than rewriting them. Never weaken or delete an existing assertion to make the redesign pass.
4. **Token step** (only if the proposed letter-spacing token is used). Dual-write to both token files in the same change as the first reference, or use the `.22em` literal.
5. **Implement §D.9 `PublicCatalogPage`:** net-new header/footer landmark siblings, hero, band-colored card grid, empty state, copy reconciliation. Preserve every locked string, role, `<article>` element, and the `<main>` child order.
6. **Implement §D.8 `BrandDesignPage`:** token corrections, the net-new preview block with its coexisting per-field `ColorPreview`, and the restyled fields/save/chip. Preserve the owner gate, the loading state's exact element counts, the label text, the validation focus/ARIA behavior, and the stays-mounted-during-refresh behavior.
7. **Implement the 390 reflow rules** for both screens exactly as specified, including the header/footer gutter reduction and `minmax(0,1fr)`.
8. **Re-run the full suite plus lint plus typecheck plus build.** All previously green tests must remain green.
9. **Independent Verifier pass** (read-only), re-running grounded checks and auditing the diff against approved scope.
10. **Browser Validator pass** at both 1440x900 and 390x844 across all 11 journeys below.

## Interfaces and data

No API, schema, migration, or data-contract change. `saveOwnerSettings` and its payload shape are unchanged (all three keys always sent). `getCatalog`, `getCoursePreview`, and `requestEnrollment` are unchanged. Anonymous reachability of `/courses` and `/courses/:id` is unchanged and explicitly re-verified. New CSS classes and the one optional new design token are the only additive interfaces.

## Acceptance and validation

- All three locked test files stay green with no assertion weakened or removed; `PublicCatalogPage-anonymous-access.test.tsx` staying green is an explicit issue criterion.
- `tokenFallbackAuditLint.test.ts` and `fieldJournalTokens.test.ts` stay green: zero raw hex outside `src/tokens/`, zero undefined `var()`, zero non-zero border-radius, zero blurred box-shadow.
- Typecheck, lint, and production build clean.
- Matches §D.8 (`Field Journal DS.dc.html:1145-1179`) and §D.9 (`:1183-1242`) at 1440 within the disclosed permitted variation and the disclosed normalizations above.
- Both screens reflow cleanly at 390 with no horizontal body scroll; header/main/footer content column measures approximately 374px.
- Eyebrow/label ink on ink.900 is brass.300 `#dca250`, never brass.500 or brass.700 — verified by source scan and visually.
- Empty catalog renders `JournalEmptyState` with zero `<article>` elements.
- Deterministic no-native-dialog source scan passes.
- Independent Verifier pass, then Browser Validator pass at both viewports. T1 cannot self-approve completion.

## Binding engineering invariants

- **§D.8 is a restyle of the existing owner-gated form. No new anonymous route is created.** `BrandDesignPage` stays mounted only at `/admin/brand-design` behind `isOwnerUser`.
- **The D.8 preview block's mark is `aria-hidden="true"`**; the visible "Lizbeth Spanish" text and the existing `ColorPreview` elements carry the accessible meaning, never the decorative mark.
- **The preview block's swatches read the same clamped value as the existing per-field `ColorPreview`** (`clampColorForMultipleContrasts(...).hex`) — never the raw input — so there is exactly one source of truth for the rendered color.
- **`ColorPreview` stays exactly as implemented** beneath each field; the new preview block is additive, not a replacement.
- **The `<main>` child order in `PublicCatalogPage`'s detail view is never disturbed.** The net-new header/footer are landmark siblings of `<main>`, never its children.
- **Every locked string, role, and element from the three named test files is preserved verbatim**, including the exact "Explore courses" H1, the `<article>` card element, and the exact error/loading copy.
- **The D.9 header/footer gutter reduction to `var(--space-2)` per side at `<=700px` is required**, not optional; omitting it reproduces the milestone's recurring overflow defect at a 112px scale.
- **No raw hex outside `src/tokens/`, no undefined `var()` reference, no non-zero `border-radius`, no blurred `box-shadow`** anywhere in the changed CSS.
- **If the optional letter-spacing token is used, it is dual-written to both token files in the same change as its first reference**; otherwise use the `.22em` literal.
- **No native browser dialogs** (`alert`, `confirm`, `prompt`, `window.*` forms, `beforeunload`) anywhere in either target file.

## Risks and rollback

| ID | Severity | Risk | Mitigation |
|----|----------|------|------------|
| R1 | High | The step-1 baseline was never executed by any planning-stage agent (Researcher's Bash allowlist blocked `npx vitest`) | Baseline capture is the mandatory first ordered-work step; a red baseline returns `JOB_BLOCKED` rather than proceeding |
| R2 | High | 390px horizontal overflow is this milestone's dominant recurring defect, and this issue has two known-in-advance instances (D.9 header/footer gutter, D.8 input width/box-sizing) | Mandatory pre-implementation static audit (step 2), the explicit gutter reduction, `minmax(0,1fr)`, the D.8 input fix, the guard list, and a measured 390 check in every browser journey |
| R3 | High | Silently breaking a locked test by renaming a string, changing a role, or reordering `<main>`'s children | Every invariant enumerated in this plan, TDD-first (step 3), and the step-1 baseline; rollback is a straight revert |
| R4 | Medium | The net-new D.8 preview block is real new component/state work, not a restyle, carrying genuine defect risk (double source of truth, crash on incomplete hex, decorative mark announced to screen readers) | Mandated reuse of the existing clamp computation and `COMPLETE_HEX_PATTERN` gate, the specified neutral placeholder, `aria-hidden` on the mark, and dedicated tests; the block is additive and removable without touching the form |
| R5 | Medium | Build-breaking CSS lint failure on a raw hex or an undefined token reference | Define-before-reference ordering, the `.22em` literal escape hatch, and running the lint in step 8 |
| R6 | Low | The tag-level `header,footer` selector is broader than strictly necessary | Reviewer verified non-regressive against `.app-header`/`.app-footer`/`.ip-notice`; engineering may scope it to the new chrome's own classes |
| R7 | Low | Contrast regression at the terracotta.600-on-paper.50 floor (4.688:1) | Treat as a hard floor; do not darken paper.50 or lighten terracotta.600 |

**Rollback.** Every change is confined to `BrandDesignPage.tsx`, `PublicCatalogPage.tsx`, their stylesheets, and tests, with no data, schema, or backend change. The redesign is presentation-layer and independently revertible by reverting the CSS/markup commit.

## Assumptions and decisions

**Binding Planner decisions:**

- **The issue's own stated premise for §D.8 (anonymous-facing, token-snapshot page) is corrected against the code and the reference artboard, both of which agree it is the existing owner-gated 3-field form.** No new route, no token showcase.
- **Breakpoint 700px** for both screens, matching the existing `CourseWorkspace.css` convention rather than `OwnerDashboardPage`'s 50em/28em steps.
- **No Control/Field migration** for `BrandDesignPage` in this pass, reasoned above; a legitimate separate follow-up once `Field` supports slotted content and a component-level `role="alert"`.
- **The ornate D.8 treatment is a bounded, disclosed override** of the general owner-area utilitarian-density note, scoped only to `BrandDesignPage`'s own classes.
- **The optional letter-spacing token is either dual-written or replaced by a `.22em` literal**; either is sanctioned, with the literal as the lower-risk default.

**Open, non-blocking items recorded for the implementer (each has a stated default; none gates the work):**

1. Confirmation-chip timestamp — default DEFER as new behavior.
2. Exact success-message wording — default KEEP the current shipped string; no test locks it.
3. Whether the D.9 detail view also gets the header/footer chrome — default YES for cross-page consistency, though the reference only depicts the list view.
4. Proposed empty-catalog copy — default SHIP the proposed strings, flagged for later copy-owner review.
5. Background-refresh visible indicator — default NONE.
6. Whether `sanitizeOwnerSettingsPayload`'s error ordering matches the visual field order so validation focus follows scan order — engineering-verifiable during implementation step 6.
7. Whether to add `--font-letter-spacing-eyebrow-wide` or keep the `.22em` literal — either is sanctioned.
8. `illustrationSrc` — default the recommended compass asset (`spot-02-compass-pocket-watch.png`).

**Safe assumptions applied:** §D.8 is owner-gated restyle work, not anonymous-facing work; the "implemented token layer" criterion is met via live-computed preview swatches plus exclusively tokenized CSS, not a live specimen showcase; standard design route with prototype forbidden; the plan's static findings are provisional until ordered-work step 1 confirms them.

## Required approvals

This plan document's engineering-dispatch approval is recorded in "Approval basis" at the top of this document, under the orchestrator's application of the recorded standing authorization. That record, not this section, is the operative approval statement. If the standing authorization is later withdrawn or found not to cover this issue, this plan reverts to requiring explicit per-document user approval before further T1/T2 work proceeds.

## Browser UI dialog policy

Required — browser-rendered React/Vite UI. Native `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload` prompts are prohibited absolutely in both target files. Both screens use inline validation and passive/alert status text today and must continue to; any acknowledgement or confirmation introduced must use the app-owned accessible modal (`src/components/ui/Modal.tsx`). A deterministic source scan for native dialogs is a required acceptance check, and every browser journey below doubles as a no-native-dialog check. Modal keyboard/focus behavior must be verified if any modal is introduced.

## Browser UI validation

**Launch/readiness:** `npm run dev -- --port 5741` in `H:\CommandCenter\orchestrator\lizbeth_spanish`. Port 5741 is deliberately non-standard, avoiding 4319, 5199, 5211, 5299, 5317, 5321, 5331, 5407, 5443, 5471, and 5613 used earlier in this session, and the 5173 default. Readiness = the Vite ready line plus a successful load of the base URL.

**Base URL:** `http://localhost:5741`

**Fixture/reset:** use the existing anonymous/owner fixtures and stubbed service responses used by the current test suites; reset browser state between journeys. The empty-catalog, catalog-error, detail-loading, detail-error, enrollment-success, and enrollment-failure states are reached by stubbing `getCatalog`, `getCoursePreview`, and `requestEnrollment`. The owner and non-owner states are reached by switching the authenticated session.

**Viewport profiles:** 1440x900 and 390x844. Both are required even though no 390 reference artboard exists for either screen — the 390 pass is judged against this plan's authored spec and the A+B+C primitives, not against a mock.

**Journeys and visible outcomes** (11 total, each run at both viewports, each including an explicit no-horizontal-body-scroll assertion at 390 and a no-native-dialog check):

1. **Catalog populated** — header bar, hero, three article cards in one row at 1440 / stacked single column at 390 with the hero H1 rescaled and header/footer padding reduced to 8px per side; footer readable without overlap.
2. **Catalog empty** — zero `<article>` elements; `JournalEmptyState` with dashed border, graph-paper ground, its eyebrow and body, and the spot illustration, occupying the grid's former position.
3. **Catalog fetch error** — `role="alert"` with the exact text "Catalog unavailable."; no grid and no empty-state box.
4. **Detail loading** — `<main>` child order exactly `[0]` back button "← Browse courses", `[1]` h1 "Course preview", `[2]` status "Loading preview…".
5. **Detail loaded** — h1 is the course title, the kept sign-in sentence, the "What you'll learn" panel, and the "Request enrollment" button.
6. **Enrollment success** — busy label then re-enable; `role="status"` with the approved-or-pending copy.
7. **Enrollment failure** — `role="alert"` with cause-specific copy.
8. **Brand form hydrated (owner)** — h1, the new preview block above the three fields (`aria-hidden` mark, static brand name, two live swatches reflecting current values), each field's existing `ColorPreview` intact beneath it, save button, no chip; at 390 the inputs are full-width with no overflow and the preview block keeps its row layout.
9. **Brand form validation error** — `aria-invalid`/`aria-describedby` on the offending field, the error rendered after its `ColorPreview`, focus lands there, and the corresponding preview swatch shows the neutral placeholder rather than a broken color.
10. **Brand form saved** — `role="status"` confirmation; at 390 the save-button-plus-chip row wraps to two lines without overflow.
11. **Non-owner permission denied** — h1, `role="alert"` permission text, zero buttons and zero textboxes.
