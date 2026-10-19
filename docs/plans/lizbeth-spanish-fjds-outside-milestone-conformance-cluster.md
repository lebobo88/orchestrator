# Lizbeth Spanish — Outside-Milestone Conformance Cluster (GH#52, #54, #55, #56, #57, #58)

## Status

**CLOSED — complete, 2026-09-07.**

All six ordered-work items are delivered, independently verified, and merged to `main` (final `main` at `fbe2d21`). Five of the six filed issues (#54, #55, #56, #57, #58) were confirmed as real defects and fixed; the sixth (#52) was re-measured and found fully stale, closed without a code change. Two of the six issues did not match their filing once measured against real source and rendered geometry — #52's cited overlap does not exist at any width, and #54's filed clipping mechanism does not reproduce, though a different real overlap defect involving the accessibility button does. Independent verification and two design-review rounds together rejected two writer proposals before they shipped, and design review caught two would-be regressions on #57 before any code was written. See "Execution record" below for the full account, including the process corrections independent review required during execution.

- **Approver:** the user (rob.hasselbach@gmail.com / lebobo88).
- **Approval date:** 2026-09-07.
- **Basis:** the user's own explicit statement, verbatim: "approved." This followed the user's review of a compact summary covering: the per-issue validity classification (#56/#58/#55/#57 still-valid, #54 valid plus an uncited third breakpoint site at `MobileNavPanel.css:40`, #52 likely stale and planned as measure-first); the finding that #56 is a cascade collision at `CourseWorkspace.css:68` rather than a token error; the design gate's history (two review rounds each rejecting a proposed #57 fix — the first would have made modals inert themselves since `Modal` never portals and 14 of 15 call sites nest inside `.app-main`, the second would have disabled backdrop dismissal app-wide); and the three orchestrator rulings recorded in the Decision register (D-1 through D-3) below.
- The design gate closed on a user ruling over a reviewer-supplied remediation, not on an unqualified `PASS`. That distinction is preserved and must not be recorded downstream as a clean pass. See Design review record above.
- **Closure date:** 2026-09-07.

## Outcome and audience

Resolve six open Field Journal design-system conformance defects — GH#52, #54, #55, #56, #57, #58 — that were filed outside the `Field Journal DS` milestone and were therefore missed by milestone-scoped searches under the governing umbrella plan, `docs/plans/lizbeth-spanish-fjds-full-app-conformance-closure.md` (APPROVED, see that plan's Status section for approver, date, and basis).

Audience: the engineering fleet (T1/T2, verifier, browser-validator) executing this plan, and the user approving it.

## Relationship to the governing umbrella plan

This plan is a bounded satellite of the umbrella plan and does not restate its content. It inherits, by reference rather than by copy:

- The umbrella plan's **no-touch list**: `lizbeth_spanish/atelier.config.json` must never be edited; the operative config is the orchestrator-root `H:\CommandCenter\orchestrator\atelier.config.json`.
- The umbrella plan's **GitHub issue logging policy** (granularity, title convention, labels, body template, invocation shape) for any new issue this plan's execution needs to file.
- The umbrella plan's **standing commit/push/PR/merge-to-`main` authorization**, scoped to `lebobo88/lizbeth-spanish` only, excluding deploys, force-pushes, history rewrites, and branch deletion — see this plan's Approval gate section below for the verbatim quote, reproduced rather than paraphrased per `handoff.md`'s instruction that authorization must be quoted directly.
- The umbrella plan's **engineering invariants** (design handoff section (e)): never hand-edit `field-workbook.generated.css`; migrate border + shadow + colour as one unit per call site; classify each site by A.3 elevation role before substituting; never add a page-specific selector to a shared multi-page rule list, and never scope an override to a shared class name without verifying that class name is exclusive to the intended page; never reintroduce the deprecated radius trio; do not conflate the focus ring's 3px width with `--border-width-rule`'s 3px; `.owner-settings-page`, `.admin-students-page`, `.admin-students-roster`, `.admin-students-detail` are already conformant and must not be re-touched; `.admin-shell-nav` is preserve-do-not-touch structurally.
- The umbrella plan's **D-8 brass-scope ruling**: `--shadow-brass` is scoped to the C.1 Primary control tier, owner tables, and download/export links only — never applied elsewhere, including here.
- The umbrella plan's **authority-ordering rules**: the deterministic lint/gate set is authoritative for "this is legacy"; Atelier `design_review`/`contrast_check`/`a11y_audit` are corroborating; `visual_diff` is non-authoritative for pass/fail; deterministic failures always dominate any judge or corroborating result.

Where this plan is silent on a governance question the umbrella plan already answers, the umbrella plan's answer applies. Where the two plans could be read as conflicting, this plan's explicit text controls for its own six items only, and any apparent conflict is a stop-and-report condition, not a silent reconciliation.

## Scope

### In scope

Exactly six issues in `lebobo88/lizbeth-spanish`:

- **#52** — header logo/nav overlap (measurement-first; disposition may be fully-stale, partly-stale, or still-valid).
- **#54** — header nav overflow, no responsive fallback across three breakpoint sites.
- **#55** — unstyled native form controls at three locations.
- **#56** — "Create course" WCAG contrast failure (cascade collision).
- **#57** — modal backdrop not inert.
- **#58** — login screen landmark failures.

### Explicitly out of scope — do not fold in

- **#49, #50, #51** — design-system follow-up primitives (access-control row, asset-card grid, Tiptap editor surface). Net-new component work; collides with the umbrella plan's "No new visual direction" non-goal; awaits a separate user scope decision.
- **#11** (`blocked:field-journal-ds`) — desktop view for students.
- **#82, #81, #80, #79, #63, #53, #48** — functional/test-infrastructure defects, not design-system work.
- The **GH#55 Enrollment-mode radios-to-`<select>` standardization** — explicit user ruling this pass; see Decision register D-2.

### Non-goals

Inherited from the umbrella plan and restated because they bind this cluster directly: no new visual direction; no new design tokens; no typography or layout/density change; no schema, Docker, or Supabase change; no re-touch of `.owner-settings-page`, `.admin-students-page`, `.admin-students-roster`, `.admin-students-detail`, or `.admin-shell-nav`.

## Background and repository findings

### Per-issue validity classification

The umbrella plan's own #76 item proved a filed issue can already be fully delivered by the time it is worked. Each of the six issues here was re-derived against current `main` (3e6aafd213b807291b2be9c86db591bd0e6c2198) rather than trusted as filed.

| Issue | Filed status | Re-derived disposition |
|---|---|---|
| #52 | Header logo/nav overlap | **UNVERIFIED, likely partly-or-fully stale.** Cited line numbers are stale post-GH#71 header rebuild. Must be browser-re-measured before any fix is planned. |
| #54 | Header nav overflow, no fallback | **STILL-VALID, source-confirmed.** Functional lockout at measured widths; three breakpoint sites involved, one previously uncited. |
| #55 | Unstyled native form controls, 3 locations | **STILL-VALID, all three locations confirmed.** One location initially misreported as already-delivered; corrected below. |
| #56 | "Create course" WCAG contrast failure | **STILL-VALID**, root cause more precise than filed: a cascade-specificity collision, not a missing style. |
| #57 | Modal backdrop not inert | **STILL-VALID, exactly as filed.** Docstring/comment claim inertness the implementation does not provide. |
| #58 | Login screen landmark failures | **STILL-VALID as filed**, with a disclosed audit-coverage limit (logged-out screen only). |

#### #52 — header logo/nav overlap

The issue (filed 2026-09-02) cites `.app-header-logo-placeholder` at `src/App.css:412-422` and a grid at `App.css:707-731`, with the logo fixed at 56x56. Those line numbers are stale: the header was materially rebuilt under GH#71 after filing.

Re-derived against current `main`: `App.tsx:70` renders `<span className="app-header-logo app-header-logo-placeholder" aria-hidden="true">L</span>`, carrying both classes, so it already inherits `grid-area: logo` plus `--control-height` sizing from `App.css:1090` inside `@media (min-width: 56.25rem)`. The filed mechanism does not reproduce from source at desktop.

**Recorded correction, stated honestly:** the initial planning hypothesis for this issue (placeholder lacks `grid-area`/sizing) was wrong. It was corrected during the design pass rather than carried forward silently.

A genuine residual gap, separate from the filed one, was found instead: below 900px neither the logo nor the placeholder has explicit width/height. Only the unconditional border/radius/shadow rule at `App.css:977` applies, so the box is content/font-size driven at mobile widths.

Given the mismatch between the filed mechanism and current source, disposition cannot be settled from source reading alone — see item 4 of Ordered work.

#### #54 — header nav overflow, no responsive fallback

`App.css:1092` sets `.app-nav { grid-area: nav; flex-wrap: nowrap; }` inside an `auto`-sized grid track (`App.css:1083`), with five non-wrapping controls (Roadmap, Learn, Feedback, Owner workspace, Sign out — `App.tsx:255-284`), no `overflow-x`, and no width cap. The rescuing off-canvas nav switches off at the same 900px breakpoint where the inline row still cannot fit.

Measured clipping occurs at approximately 1258-1295px CSS viewport width. No horizontal scrollbar appears, and clipped controls, including "Sign out," are genuinely unreachable by mouse — a functional lockout, not a cosmetic defect.

**Third breakpoint site, previously uncited and load-bearing.** `App.css:1093` (`.app-header-menu-trigger { display: none; }`) hides only the trigger button; the panel body is governed separately by `MobileNavPanel.css:40-44` (`@media (min-width: 56.25rem) { .mobile-nav-panel { display: none; } }`). Widening only the two `App.css` blocks would leave a visible-but-non-opening hamburger across the 900-1300px band, reproducing the lockout in a new location.

**Evidence gap, carried honestly.** The issue's claim that this "reproduces logged-out on the public course-detail dark header" could not be confirmed. `PublicCatalogPage.tsx` uses its own `.catalog-header` with a single "Sign in" button and never uses `.app-nav`. Independently confirmed by the design reviewer. Do not extend the fix to that file on this claim alone; the browser sweep (item 5 of Ordered work) resolves it.

#### #55 — unstyled native form controls, three locations

1. `/admin/courses/new` "Enrollment mode": native radios in a bare native `<fieldset>`/`<legend>` (`NewCoursePage.tsx`).
2. Course editor Settings tab: "Require manual lesson release" native checkbox plus a bare fieldset for "Prerequisite course/version" (`CourseWorkspacePage.tsx:779,805,848`; the only existing rule, `CourseWorkspace.css:181`, targets `code.field-hint`).
3. Global AccessibilitySettings "Typography" radios.

**Recorded correction, stated honestly.** Planning initially reported location 3 as already-delivered, because `AccessibilitySettings.css:77-84` contains `appearance: none`. That was a false positive: those lines belong to `.setting-range` (the text-size slider) and its `::-webkit-slider-thumb`. The radios at `.radio-label input[type='radio']` (`AccessibilitySettings.css:180-186`) set only cursor, width, height, `accent-color`, and `flex-shrink`, with no `appearance` reset. Location 3 stands as filed.

#### #56 — "Create course" WCAG contrast failure

Route `/admin/courses/new`, the "Create course" submit button: computed `color: rgb(253,252,249)` (paper-50) on `background-color: rgb(250,248,244)` (paper-100) yields WCAG 1.03:1, APCA Lc 0. The button is not disabled. The issue as filed carries no class name.

Traced: `NewCoursePage.tsx:7` uses `<Control tier="primary" type="submit">`, resolving to className `control control--primary` (`Control.tsx:62`). `.control--primary` (`Control.css:27-39`) is itself correct (ink-1000 fill / paper-50 text, approximately 17:1).

The break is a cascade collision. `CourseWorkspace.css:68`'s rule `.workspace-panel>button:not(.text-button):not(.primary){...background:var(--color-paper-100);...}` excludes the legacy literal class `primary` but never matches `control--primary`, a different class token. At specificity **(0,3,1)** — one class for `.workspace-panel`, one class-equivalent per `:not()` argument, one type selector for `button` — it outranks `.control--primary`'s (0,1,0) background declaration, while `color: paper-50` is untouched and survives, producing exactly the measured pairing. The submit button is a direct child of `<form className="workspace-panel">`, matching the selector. Independently verified by design review.

**Recorded correction, stated honestly.** An earlier statement of this specificity gave (0,4,1); it is corrected here to (0,3,1). The conclusion (the rule outranks `.control--primary`'s background declaration) is unaffected by the correction.

#### #57 — modal backdrop not inert

`src/components/Modal.tsx` claims inertness twice — docstring line 28 ("Inert background: background is non-interactive when modal open") and JSX comment line 59 — but implements only `<div className="modal-backdrop" onClick={handleBackdropClick} aria-hidden="true" />` (lines 60-64). `aria-hidden` sits on the decorative backdrop itself, not on the rest of the document. `useFocusTrap.ts` intercepts only the Tab key; it never sets `inert`/`aria-hidden` on siblings and never blocks pointer events.

Live-verified with the "Disable Student Account" modal open: on `.app-header`, `pointer-events: auto`, `aria-hidden: null`, `inert: false`. Header nav including "Sign out" stays genuinely interactive while the modal is open.

**Modal mount structure — load-bearing for #57.** `Modal` never portals: no `createPortal` call exists anywhere in `src`. It renders inline at its call site, as a DOM descendant of `<main className="app-main">`, at `AdminStudentModals.tsx:49,126,250,320,426,536,648,715,837`, `RegisterStudentModal.tsx:191,255`, and `CourseWorkspacePage.tsx:248,439,454,726`. Only the AccessibilitySettings modal (`App.tsx:358`) is a true top-level sibling after the footer. Additionally, `Modal.tsx:58-64` renders `.modal-backdrop` and the dialog as adjacent siblings inside one Fragment; `Modal.css` gives both independent `position: fixed` and z-index (998/999) with no `+`/`~` selector depending on their adjacency.

#### #58 — login screen landmark failures

`src/components/LoginForm.tsx` has no `<main>`, no `role="main"`, no `aria-label`. `<main className="app-main">` exists at `App.tsx:311` but mounts only inside `AuthenticatedApp`, never in the unauthenticated `AuthGate` branch.

axe-core via Atelier `a11y_audit` against `http://localhost:5173/` reported 10 moderate violations across 2 rules: `landmark-one-main` (1 node) and `region` (9 nodes: brand wordmark, "Learn in the open" h1, tagline, footer row, "Access"/sign-in eyebrow).

**Coverage limit, stated plainly.** The audit tool could not carry an auth cookie, so only the logged-out login screen was audited. Similar landmark/region issues may exist on authenticated routes and are unverified. Recorded as a known limit and a recommended follow-up (D-7), not as in-scope work.

## Research evidence

None. No external or current-fact question was material to this plan. All findings are direct local repository evidence plus live GitHub issue text and live computed-style measurements supplied via the coordinator; the Planner does not carry `gh` on its tool surface and did not read live GitHub state directly.

## Design route

```
DESIGN_ROUTE
profile: compact
reasons: Six bounded brownfield conformance defects on existing surfaces against an already-ratified, fixed design system; no new screens, no multi-state components, no user-flow change; umbrella plan's "No new visual direction" non-goal governs.
agents_required: design-generalist, design-reviewer
prototype: forbidden
model_tier: sonnet
existing_system_mode: preserve
END_DESIGN_ROUTE
```

### Design handoff (binding contents)

Produced by `design-generalist`, reviewed independently by `design-reviewer` (two rounds — see Design review record below).

- **#52.** `.app-header-logo` is the sole geometry-owning class for both the real logo and the placeholder, at both the unconditional/mobile rule and the desktop override; `.app-header-logo-placeholder` may add paint only (background `--color-paper-200`, border `--color-ink-700`, color `--color-ink-800`, already >=7:1), never width/height/margin/grid-area/box-generating display. Add explicit sizing at the unconditional rule (`--hit-target-min`, 44px) as well as the existing desktop override (`--control-height`, 48px), and add `overflow: hidden` so the glyph cannot exceed its box at any width. **Conditional on the measurement outcome — see item 4 of Ordered work.**
- **#54.** Widen the same shared breakpoint constant across all three sites in one commit: `App.css:1070` (min-width grid-shape switch), `App.css:1097` (max-width hamburger-visible / `.app-nav`-hidden switch), and `MobileNavPanel.css:40` (min-width panel-hidden switch). Recommended value approximately 1300px/81.25rem, to be confirmed against the measured max-content width of the five-control row (Decision D-4). All three sites must move together; none may be widened independently. **Explicitly rejected as primary fix:** `overflow-x: auto` on `.app-nav` — a primary nav containing "Sign out" must not require undiscoverable scroll (unlike `.admin-shell-nav ul`'s scoped sub-nav, which legitimately uses that pattern). Documented fallback if widening regresses another dependency: keep 900px for the grid shape but show/open the hamburger across 900-1300px — the same three-site coordination requirement applies to the fallback.
- **#55.** DS evidence: C.2 Fields (`Field Journal DS.dc.html:363-383`) specifies text input/error/textarea only; there is no radio or checkbox specimen.
  1. Enrollment mode: restyle the existing native `<fieldset>`/3-radio group in place, keeping the widget type.
  2. Manual-release checkbox: re-skin via the `.setting-range` precedent's mechanics only — `appearance: none`, `--hit-target-min` padded hit area, `2px solid var(--color-ink-1000)`, `--radius-square`, unchecked `--color-paper-100`, checked `--color-ink-1000` fill with a checkmark glyph via `::after` in `--color-paper-50` (checkbox semantics; never colour-only).
  3. Both fieldsets: box chrome already exists via `CourseWorkspace.css:68`'s `.workspace-panel fieldset` rule; only `<legend>` needs a rule — mono, uppercase, 0.18em tracking, `--color-ink-1000`, reusing `App.css:974`'s `.app-header-eyebrow` token set.
  4. **Both radio sites keep native `input[type='radio']` + `accent-color: var(--color-accent-primary)`. Do not apply `appearance: none` or a custom mark to radios** — a checkmark is checkbox semantics, not the filled-dot exclusivity cue conventional for radios, and dropping native `accent-color` would silently remove automatic forced-colors support against this repo's own convention (49 source files carry explicit `forced-colors` rules, e.g. `WeekSectionTabs.css:123`). Layer only the `.radio-label` wrapper treatment, already DS-correct at `AccessibilitySettings.css:153-178`. **`--shadow-brass` and a custom-mark use of `--color-accent-primary` are explicitly excluded from #55** — carrying the slider's brass/accent fill onto a form control would violate the umbrella plan's D-8 brass-scope ruling (brass is C.1 Primary tier, owner tables, and download/export links only).
- **#56.** Add `:not(.control--primary)` alongside the existing `:not(.primary)` on both the rest-state selector and its paired hover/disabled rules at `CourseWorkspace.css:68`, restoring `.control--primary`'s ink-1000/paper-50/brass-shadow pairing untouched. No inline override, no new class, no `!important`.
- **#57 — user-ruled remediation, option (b).** Wrap `.modal-backdrop` and the dialog in a single unstyled `<div className="modal-root">` inside `Modal.tsx`, then implement the shared inertness walk once in `useFocusTrap` (or one shared helper both `Modal` and `MobileNavPanel` call). Algorithm: on open, walk up from `.modal-root` to `document.body`; at each level apply native `inert` to every other child of that level's parent, leaving the ancestor-on-the-path and everything below it untouched. On close, remove `inert` only from nodes this effect added it to (a tracked set, never a blind repo-wide strip). Never a hardcoded sibling list; never duplicated per call site. Do not portal `Modal` — option (a)-by-refs and portaling were both rejected; see Decision register D-1 for the full rationale. Focus trap, Escape, and focus-restoration behavior are already correct and unchanged.
- **#58.** Wrap the unauthenticated split-layout (brand panel plus sign-in form together, since "Learn in the open" h1/tagline is primary content, not decorative) in a single `<main>`, and the footer row in `<footer>`. **A distinct wrapper class is required, not optional:** `.app-main` (`App.css:553-559`) imposes `padding: var(--space-8) var(--space-6); max-width: 900px; margin: 0 auto`, whereas `.auth-split-layout` (`LoginForm.css:9-20`) is a full-bleed `min-height: 100vh` split panel whose own source comment documents deliberately avoiding artboard-frame styling because it would clip content at 200% zoom. Wrapping it in `.app-main` verbatim would visibly pad/center/cap an intentionally edge-to-edge layout, itself a regression. Landmark semantics (one `<main>`, one `<footer>`) are the invariant; the class name is not. No `aria-label` needed — confirmed correct, since `AuthGate` renders exactly one tree or the other, never both concurrently.

Zero new tokens. Tokens reused: `--control-height`, `--hit-target-min`, `--radius-square`, `--border-width-rule`, `--color-ink-1000`, `--color-paper-50`, `--color-paper-100`, `--color-paper-200`, `--color-accent-primary` (radios' native `accent-color` only), `--focus-ring-width`/`--focus-ring-offset`/`--color-focus-ring`, `--font-size-label`, `--font-letter-spacing-eyebrow`.

### Design review record

Independent, two rounds. Recorded honestly — each round caught a real bug that would otherwise have shipped.

- **Round 1: NEEDS_REVISION, 8 findings (2 HIGH).** F1: the original fix (hardcode `inert` onto `.app-header`/`.app-main`/`.app-footer`) would have made the modals themselves inert, because `Modal` never portals and renders as a descendant of `.app-main` at 14 of 15 call sites. F2: `MobileNavPanel.css:40` was an uncited third breakpoint site whose omission would reproduce the #54 lockout in a new band. F3-F8 covered specificity notation, the select-swap scope question, the radio forced-colors regression, brass-scope token leakage, the `.app-main` incompatibility, and a missing mobile viewport check.
- **Round 2 (single permitted re-review): BLOCKED, F1-REOPEN (HIGH).** The revised runtime ancestor-walk still had a structural hole: because `Modal.tsx:58-64` renders backdrop and dialog as adjacent siblings in one Fragment, the walk's first level would target the backdrop, and since `inert` suppresses pointer hit-testing, `handleBackdropClick` (`Modal.tsx:51-55`) would stop firing for every modal in the app — a universal regression to backdrop dismissal, independent of mount depth. F2-F8 all returned `status: CLOSED`.
- **Resolution.** Per `docs/DESIGN-CONTRACT.md`, a BLOCKED verdict is a user decision. The user resolved the single blocking finding by adopting the reviewer's own verified remediation (b) — the `modal-root` wrapper — which the reviewer had already verified safe against `Modal.css`. All other findings were closed. **The design gate is closed on a user ruling over a reviewer-supplied remediation, not on a clean PASS. This is stated precisely here and must not be recorded downstream as an unqualified PASS.**
- Reviewer's remaining limits: source-static review only; no Playwright run, no axe-core execution, no runtime contrast measurement.

## Execution record

Recorded honestly. This cluster shipped two writer proposals that independent review rejected, one factually wrong code comment, and a fixture-mutating test run. The review chain working, not a clean sweep, is the story.

### Merged work

PR #130 (#56), #131 (#58), #133 (#55), #135 (#54), #136 (#57). Final `main` at `fbe2d21`. Issues #54, #55, #56, #57, #58 closed 2026-09-07; #52 closed separately as verified-stale.

### Two of six issues did not match their filing, both caught by measurement, not assumption

- **#52 fully stale.** Filed as a logo/nav overlap of approximately 20px at 1440x900. Re-measurement found a **628px gap**, an order of magnitude the other way. The header had been rebuilt under #71 after filing, replacing the cited `'brand logo tools'` grid. Swept 900-1920px, three routes, owner and student sessions, and short/long brand names: no overlap under any condition. Closed without code change. Same pattern as #76, closed earlier the same day.
- **#54 filed mechanism did not reproduce; a different real defect did.** The reported 1258-1295px nav clipping does not happen: `.app-header-title-lockup` sits on a `minmax(0, 1fr)` track and absorbs pressure via `text-overflow: ellipsis` before `.app-nav` shrinks. What does reproduce: the fixed-position `.accessibility-button` (48x48px, docked `top/right: 1rem`) overlaps the rightmost nav control continuously from 900px to a measured **1328px** (matching `1200 + 2x64px`), plus a pre-existing collision with the hamburger trigger at 700-899px. Fixed by reserving `--a11y-trigger-footprint` clearance in both bands, using the existing token, no new token.

### Root causes worth preserving

- **#56 was a cascade collision, not a token error.** `CourseWorkspace.css`'s `:not(.primary)` guard excluded the legacy literal class but never matched `control--primary`, the class `Control.tsx:62` actually emits. At specificity (0,3,1) it beat `.control--primary`'s (0,1,0) background, forcing paper-100 while `color: paper-50` survived, exactly the measured 1.03:1. Two buttons were affected; the second (`CourseWorkspacePage.tsx:881`, "Save settings") was missed on the first attempt and caught by independent verification, which also found the writer's shipped completeness comment factually wrong. Now 17.65:1 at both.
- **#57's `Modal` docstring and JSX comment both claimed inertness the implementation never had.** Background was never `inert` and never removed from the accessibility tree.

### Design review prevented two shipped bugs on #57, before any code was written

- Round 1 rejected inerting `.app-header`/`.app-main`/`.app-footer`: `Modal` never portals and most call sites render inside `.app-main`, so it would have made the modals themselves inert.
- Round 2 rejected a naive ancestor-walk: backdrop and dialog were adjacent siblings in one Fragment, so the walk's first level would have inerted the backdrop, **killing backdrop dismissal for every modal in the app**. The adopted `modal-root` wrapper exists specifically so the walk sees one node to protect.

### Independent verification rejected two writer proposals that would have shipped

- On **#54**, a first attempt moved the header breakpoint 900px to 1400px. Verification judged it disproportionate and **empirically proved the narrower alternative**, reserving the button's footprint, resolves the overlap at every width 900-1366px with no nav-fit regression. Without that, the entire 900-1399px band, including common laptop widths (1280, 1366), would have been converted from desktop inline nav to mobile hamburger nav to fix a 48px button overlap.
- On **#55**, design review rejected replacing radios with a custom mark, because dropping `accent-color` silently loses forced-colors support, a convention held across 49 files. Radios keep the native widget; only the checkbox uses a custom mark, with a forced-colors media block. Real forced-colors validation confirmed checked/unchecked remain distinguishable (`Field`/`ButtonText` unchecked vs. `Highlight` fill with a `HighlightText` checkmark glyph).

### Judge availability, stated plainly

The Codex `CODE_REVIEW` checkpoint this plan recommended for #57 returned `ABSTAIN`/`unassessed`: the adapter hit an ACL error and could not read the repository. **Recorded as unassessed, not as a pass.** An independent verifier performed the adversarial DOM-shape and cleanup review in its place. `PLAN_DUCK` was deliberately skipped per this plan's own recommendation.

### Environment and tooling notes

- Claude-in-Chrome proved unusable throughout: `resize_window` floors around 500x665 and synthetic clicks stop registering as trusted after a resize. Playwright was the reliable backend for every rendered check.
- The test-suite noise baseline **shrank from approximately 14 files to 3 files / 5 tests** mid-cluster, when a browser-validation run found the `supabase_edge_runtime_lizbeth_spanish` container had crashed hours earlier and restarted it. Final baseline: `FeedbackLedgerRow.test.tsx` x1, `rlsIntegration.test.ts` x1, `roadmapIntegration.test.ts` x3 (seed-date drift).
- Validating #57's reveal-phase modal **rotated `student2@test.local`'s seeded password**, silently breaking `issue5-phase5-learn-edge-live.test.ts`'s cross-student isolation assertion. Caught by a pre-landing suite check, repaired with a targeted local-only admin-API reset. Filed as issue #137.

### Follow-ups filed

#132 (authenticated-route landmark coverage unaudited, `a11y_audit` cannot carry an auth cookie), #134 (Enrollment-mode control inconsistent across two pages; the `<select>` standardization was deliberately deferred as a widget change against the "No new visual direction" non-goal), #137 (re-issue-access validation mutates a fixture account).

## Ordered work

**Sequencing rationale.** #56 is first: it is a genuinely one-line, isolated, highest-confidence fix that proves the whole pipeline (dispatch, gate, verifier, browser-validator, commit) end to end cheaply. #52's measurement must run before #54's fix, because #54 changes header breakpoints and would otherwise contaminate or mask #52's measurement against unmodified `main`. #57 and #58 are independent of the header work and of each other.

Each item is one bounded T1 job. Every item's gates must include: the extended deprecation lint for the touched files, `npm run lint`, `tsc --noEmit`, the deterministic no-native-dialog source scan, an independent Verifier pass, and a Browser Validator pass on that item's journeys. No writer self-approves completion.

1. **#56 — restore "Create course" primary-button contrast.** Files: `src/pages/CourseWorkspace.css` (rule at line 68 and its paired hover/disabled rules). Add `:not(.control--primary)` alongside `:not(.primary)`. Acceptance: computed color/background on the `/admin/courses/new` submit button resolve to ink-1000/paper-50, contrast >=7:1 measured in a real browser; hover/active/disabled(`saving`) still animate per C.1; no regression to any other `.workspace-panel` button — explicitly re-check the `PublicCatalogPage` `.workspace-panel` consumer at `PublicCatalogPage.tsx:125`, per the umbrella plan's shared-class-name hazard (risk item 4 below). Dependencies: none.
2. **#58 — login screen landmarks.** Files: `src/components/LoginForm.tsx`, `src/components/LoginForm.css` (new wrapper class). Wrap split-layout in `<main>` via a new distinct class carrying landmark semantics only (no width/padding/centering), footer row in `<footer>`. Acceptance: axe-core `landmark-one-main` and `region` both resolve to 0 nodes at 1440x900 and 390x844 logged out; exactly one `<main>`; the edge-to-edge presentation is pixel-unchanged from pre-fix captures at both viewports (the regression guard for the `.app-main` trap). Dependencies: none.
3. **#55 — DS chrome for native form controls, 3 locations.** Files: `src/pages/NewCoursePage.tsx` + its CSS, `src/pages/CourseWorkspacePage.tsx` + `src/pages/CourseWorkspace.css`, `src/components/AccessibilitySettings.css`. In-place restyle only; radios keep native widget + `accent-color`; custom `appearance: none` treatment confined to the manual-release checkbox; legend rule added. Acceptance: all three locations render DS chrome; every control keyboard-operable with a visible 3px slate focus ring at 2px offset; checkbox checked state distinguishable by glyph, not colour alone; **forced-colors emulation check passes at all three locations** (the explicit guard against the regression the reviewer caught); no `appearance: none` introduced on any radio. Dependencies: none. Note the `.workspace-panel fieldset` box chrome already exists; do not duplicate it.
4. **#52 — browser re-measurement first, then conditional action.** This item does not begin as a fix. Step 1: measure at 1440x900 (and adjacent informative widths, plus 390x844) on current `main`, authenticated, with no owner logo configured, then repeat with a configured logo. Step 2: classify into exactly one of — **fully-stale** (close the issue with recorded evidence, no code change); **partly-stale** (fix only the genuinely-remaining part, most likely the mobile sizing gap below 900px, where neither logo nor placeholder has explicit width/height); **still-valid** (fix as filed per the design handoff). Acceptance depends on the branch taken and must be recorded before any code is written. A speculative fix for a defect that may not exist is prohibited. Dependencies: must complete before item 5 so the measurement is taken against unmodified header geometry.
5. **#54 — header nav overflow responsive fallback.** Files: `src/App.css` (blocks at 1070 and 1097) and `src/components/MobileNavPanel.css` (line 40) — **all three sites move to the identical shared breakpoint constant in the same commit.** Acceptance: at every width in {900, 1000, 1100, 1200, 1258, 1295, 1300, 1440}, either the full inline nav is unclipped and reachable, or the hamburger trigger opens a panel containing all five items reachably — never a state with a visible trigger whose panel stays hidden, and never a state where neither affordance is active. "Sign out" reachable by mouse and keyboard at every width. Also resolve the standing evidence gap by loading logged-out `/courses` and `/courses/:id` at the same widths. Dependencies: item 4 complete.
6. **#57 — genuine modal inertness (shared fix).** Files: `src/components/Modal.tsx` (add the `modal-root` wrapper), `src/hooks/useFocusTrap.ts` (or one shared helper). Implement the user-ruled option (b) plus the ancestor-walk described in the design handoff. Acceptance, at both nesting shapes — (i) "Disable Student Account" from `AdminStudentModals.tsx:49`, deep-nested inside `.app-main`, and (ii) the AccessibilitySettings modal at `App.tsx:358`, a true top-level sibling: background siblings compute `inert` while open; clicking header "Sign out" produces no navigation or state change; **the modal's own content remains fully interactive** (the exact round-1 regression); **backdrop click still dismisses** (the exact round-2 regression); Tab from `document.body` never leaves the modal; Escape closes and returns focus to the trigger; `inert` is fully removed from every node it was applied to after close, with no residual inert nodes. Dependencies: none, but see the GH#100 sequencing note under Risks and rollback. A `CODE_REVIEW` judge checkpoint is recommended on this item — see Judge route.

## Interfaces and data

No API, schema, migration, or data-model change. Changes confined to `src/**/*.css`, `src/**/*.tsx` markup, `src/hooks/useFocusTrap.ts`, and `src/components/Modal.tsx`. Zero token changes: `.atelier/tokens/field-workbook.tokens.json` and `src/tokens/field-workbook.generated.css` are not touched by this plan. Never hand-edit the generated CSS. Never regenerate the frozen baseline at `docs/token-deprecation-baseline/phase1-baseline.json`. `lizbeth_spanish/atelier.config.json` is never edited.

## Acceptance and validation

**A hard-won lesson this plan's gates must encode, inherited from the umbrella plan's own recorded incident.** The umbrella plan's E.4 work shipped two blocker defects while 2745+ unit tests were green, because jsdom computes neither layout/containing blocks nor real focus semantics. One was a `position: fixed` overlay silently confined by an ancestor's residual animation transform; the other was focus never restoring on close. Both were caught only by real-browser validation asserting rendered geometry and actual `document.activeElement`, not computed style. Four of the six issues here (#52 overlap, #54 overflow, #57 inertness, #58 landmarks) are exactly that class of defect. **State explicitly: a jsdom-only test is insufficient evidence for #52, #54, #57, and #58. Each requires Playwright-asserted rendered outcomes.** The two design-review rounds independently caught two more defects of the same family (modal self-inerting; backdrop losing hit-testing), both invisible to jsdom.

**Browser backend: Playwright.** `@playwright/test`@1.61.1, `playwright.config.ts`, `testDir: './src/__tests__/e2e'`. Claude-in-Chrome's `resize_window` cannot reach mobile viewports in this environment, and its synthetic clicks stop registering as trusted after a resize — it must not be used for the viewport-sweep or click-dependent gates here.

**Pre-existing test noise — gate criteria must account for this rather than assuming a clean full-suite pass.** Approximately 14 files fail on Supabase Edge Functions returning 503/BOOT_ERROR (Edge Functions are not served locally); 3 seed-date-drift failures in `roadmapIntegration.test.ts`; one `FeedbackLedgerRow.test.tsx` failure. The gate is: no new failures relative to a baseline run captured immediately before the item's first edit. An exclusion-based "full pass" is a failed gate, per the umbrella plan's recorded prior incident.

**Reuse, do not reinvent.** `src/__tests__/helpers/cssCascade.ts` — a real CSS cascade resolver used for outcome-asserting tests — is particularly apt for #56, whose defect is a cascade collision. The token pipeline oracle (`scripts/verify-token-pipeline.mjs`, `src/__tests__/tokenPipelineOracle.test.ts`) must still pass. Atelier `contrast_check`, `a11y_audit`, `design_review` are corroborating, not authoritative, per the umbrella plan's authority ordering; deterministic failures always dominate.

### Per-issue browser-validation journeys

| Surface | Journey | States/checks | Viewports | Pass criteria |
|---|---|---|---|---|
| `/admin/courses/new` submit button (#56) | Load new-course form, inspect submit button | rest, hover, active, disabled (`saving`) | 1440x900 | Contrast >=7:1 at rest; hover/active/disabled animate per C.1; `PublicCatalogPage.tsx:125` `.workspace-panel` consumer unaffected |
| Login screen (#58) | Load `/` logged out | default | 1440x900, 390x844 | `landmark-one-main` and `region` both 0 nodes; exactly one `<main>`; edge-to-edge layout pixel-unchanged from pre-fix capture |
| `/admin/courses/new` Enrollment mode; Course editor Settings tab; AccessibilitySettings Typography (#55) | Tab through each control group with keyboard; toggle checked states | default, focus, checked/unchecked, forced-colors emulation | 1440x900 | DS chrome renders; 3px slate focus ring at 2px offset; checkbox glyph-distinguishable; forced-colors emulation passes at all three locations; no `appearance: none` on any radio |
| Header logo/placeholder (#52) | Load authenticated view with and without owner logo configured | desktop, mobile, adjacent informative widths | 1440x900, 390x844, plus informative widths | Measurement and three-way classification recorded before any code change; if code changes, box does not overflow at any measured width |
| Header nav (#54) | Load authenticated view; attempt to reach every nav item including "Sign out" | inline row, hamburger trigger, hamburger panel open | {900, 1000, 1100, 1200, 1258, 1295, 1300, 1440} | At every width, either the inline row is unclipped and reachable, or the hamburger opens a panel with all five items reachable; "Sign out" reachable by mouse and keyboard at every width |
| Logged-out `/courses`, `/courses/:id` (#54 evidence-gap resolution) | Load each route logged out | default | same sweep as above | Confirms or refutes the issue's cross-surface claim; `.catalog-header` behavior recorded either way |
| "Disable Student Account" modal (#57) | Open modal from `AdminStudentModals.tsx:49` | open, background-interaction attempt, backdrop click, Escape, close | 1440x900 | Background `inert`; modal content interactive; backdrop click dismisses; Escape closes and returns focus; no residual `inert` after close |
| AccessibilitySettings modal (#57) | Open modal from `App.tsx:358` | same as above | 1440x900 | Same as above, confirming the top-level-sibling nesting shape independently of the deep-nested shape |

## Risks and rollback

Overall risk: **medium** (elevated from low by #57's shared-helper blast radius).

1. **#57's shared helper regresses every modal in the app.** Two successive designs were wrong in exactly this way. Mitigations: the `modal-root` wrapper makes the protected subtree one explicit node rather than encoding sibling shape into the helper's contract; both nesting shapes are gated; backdrop dismissal is explicitly pinned; a `CODE_REVIEW` checkpoint is recommended.
2. **A speculative #52 fix for a defect that no longer exists.** Mitigation: item 4 is measurement-first with a mandatory three-way classification before any code.
3. **#54 widened at two of three sites**, producing a visible-but-non-opening hamburger. Mitigation: the three-site same-commit invariant, and a validation step that opens the panel rather than asserting trigger visibility alone.
4. **A page-scoped override keyed on a shared class name leaks across pages.** `.workspace-panel` is shared between `CourseWorkspacePage` and `PublicCatalogPage.tsx:125` — the same hazard class the umbrella plan records as risk item 8 there. Directly relevant to item 1. Mitigation: explicit cross-page re-check in that item's acceptance.
5. **Forced-colors support silently lost** if an implementer restyles radios with `appearance: none`. Mitigation: the explicit #55 invariant plus a forced-colors emulation gate.
6. **Destructive git commands.** `reset --hard`, `checkout --`, and `clean` are prohibited, per the umbrella plan's recorded incident of destroyed uncommitted work. `design/field-journal/ADOPTION-PLAN.md` carries a deliberately uncommitted modification that must never be staged.
7. **Environment.** Docker Desktop is running; the local Supabase stack is up and healthy; a `npm run dev` server is running at `http://[::1]:5173`. Reuse them. Never `taskkill`; scoped-PID termination only if genuinely required.
8. **Plan staleness.** Any material repository or evidence change requires `JOB_BLOCKED: Plan stale` and re-planning or explicit reapproval.

**Rollback.** Every item is an independently revertable CSS/TSX edit with no schema, data, or irreversible state. Issue actions are reversible.

## Assumptions and decisions

**Stated evidence limits.**

(a) GitHub issue text and the live computed-style measurements for #56, #52, #54, and #57 were supplied via the coordinator, not read directly by the Planner — `gh` is not on the Planner or Researcher tool surface. Where a live re-read contradicts this plan, the live read wins.

(b) Design review was source-static: no Playwright run, no axe-core execution, no runtime contrast measurement.

(c) #58's audit covered only the logged-out login screen; authenticated routes are unaudited.

### Decision register

Each row carries an explicit no-dispatch gate where applicable.

| ID | Decision | Resolution |
|---|---|---|
| D-1 | #57 remediation shape | **RESOLVED by user ruling: option (b), the `modal-root` wrapper.** Alternatives were (a) a two-node `{backdrop, dialog}` exemption set passed as refs, and portaling `Modal` to a top-level container. Rationale: (b) is structurally more robust because a two-node exemption set encodes `Modal`'s current internal sibling shape into the shared helper's contract, so any future change to that structure would silently break the walk again; (b) makes the protected subtree a single explicit node and is self-maintaining. Portaling was rejected because it changes the mount structure of every existing consumer, requiring regression review of `Modal.css`'s z-index paint-order assumptions and of tests asserting rendered DOM position. The reviewer verified (b) safe against `Modal.css`. Adds no visual change whatsoever. |
| D-2 | #55 Enrollment-mode widget | **RESOLVED by user ruling: in-place radio restyle; the radios-to-`<select>` swap is out of this plan**, and is not carried as a sign-off-gated option inside it either, to keep scope clean. The cross-surface inconsistency (native radios on `/admin/courses/new` vs. a DS-styled `<select>` on the Settings tab) is recorded as a **separate follow-up for a later scope decision**. Grounds: the swap is a widget/interaction-pattern change (all options visible vs. hidden behind a dropdown), not a paint/token fix, and collides with the umbrella plan's "No new visual direction" non-goal. |
| D-3 | #52 disposition | **RESOLVED as a method, not an outcome:** browser-re-measurement first, with a mandatory three-way classification (fully-stale / partly-stale / still-valid) recorded before any code is written. No-dispatch gate: no #52 code change may be dispatched until the measurement and classification are recorded. |
| D-4 | #54 exact breakpoint value | **RESOLVED.** The breakpoint stays at 900px (`56.25rem`); no value change was needed. The filed clipping mechanism (nav overflow at 1258-1295px) did not reproduce, so the recommended widen-the-breakpoint remediation was never the right fix. The real, measured defect was the fixed-position `.accessibility-button` overlapping the rightmost nav control from 900px to 1328px, plus a pre-existing hamburger-trigger collision at 700-899px. Verification rejected a first attempt that moved the breakpoint to 1400px as disproportionate and proved the narrower fix, reserving the button's footprint via `--a11y-trigger-footprint`, resolves the overlap at every affected width with no nav-fit regression. |
| D-5 | GH#100 `suppressDismiss` semantics | **OPEN, carried as a recorded limit, not resolved by this plan.** #57 deliberately did not touch dismiss semantics. #100 was closed 2026-09-05T18:20:34Z by lebobo88 with no comment and no recorded decision, verified via both `--json comments` and the timeline API; the close event body is null. Its stated acceptance criterion was a recorded decision (plan amendment or code change) for how five modals reconcile with the "Escape plus explicit close" pattern, applied consistently across all five sites, and no such record is retrievable from GitHub. The five sites are `AdminStudentModals.tsx:135,407,623,667` and `RegisterStudentModal.tsx:244`. **Closure may mean resolved, superseded, or simple backlog cleanup; this plan does not assert which.** Sequencing collision for item 6: #57's inertness fix is semantically orthogonal to dismiss semantics, but both land in `Modal.tsx`/`useFocusTrap.ts`. The #57 job must not "helpfully" change Escape/dismiss behavior at those five sites along the way. The user is surfacing the #100 question separately. |
| D-6 | #55 checkbox visual treatment | Extrapolated from `.setting-range`'s mechanics because the DS specifies no checkbox specimen. Labeled an assumption; flagged for eventual DS-owner ratification. Non-blocking. |
| D-7 | #58 authenticated-route landmark coverage | **Tracked as GitHub issue #132.** Not in scope for this plan; `a11y_audit` cannot carry an auth cookie. |

**Safe assumptions.** The dev server is reachable at the running instance; the dev-only seeded quick-select panel (`LoginForm.tsx:123-138`) provides authenticated student access; owner/admin surfaces require the credential path recorded as an open item in the umbrella plan's Finding 8.

## Judge route

`PLAN_DUCK` is eligible per `docs/JUDGE-CONTRACT.md` but judged **low value** here: this is a small, six-item, mechanically-verifiable defect cluster that has already absorbed two independent design-review rounds, which caught two real correctness bugs. **Recommend skipping `PLAN_DUCK`** for this plan.

A `CODE_REVIEW` checkpoint **is recommended** for the #57 work item specifically (item 6 of Ordered work) — the shared inertness helper is the only non-trivial logic in the cluster and has already produced two wrong designs across the two design-review rounds.

Standing call caps apply per `docs/JUDGE-CONTRACT.md`. Deterministic failures always dominate. No judge pass is promised by this plan.

## Browser UI dialog policy

Required, inherited from the umbrella plan's Browser UI invariant and CLAUDE.md's Browser UI invariant section. No native `alert`, `confirm`, `prompt`, their `window.*` forms, or `beforeunload` anywhere in this browser-rendered React UI, in any existing or newly-touched state. Acknowledgement and confirmation use the app-owned accessible modal: focus trapped while open, focus returned to trigger on close, Escape plus an explicit close control, never backdrop-only dismissal, visible 3px slate focus ring at 2px offset at every stop. #57's fix strengthens this contract rather than altering it; #57's fix must not silently change Escape/dismiss behavior at the five `suppressDismiss={true}` sites named in D-5.

A deterministic no-native-dialog source scan over `src/**` plus runtime confirmation on every touched journey is a required gate on every item.

## Browser UI validation

- **Launch/readiness:** `npm run dev` in `H:\CommandCenter\orchestrator\lizbeth_spanish`; ready when the login route renders. A server is already running at `http://[::1]:5173` — reuse it; never restart or `taskkill`.
- **Base URL:** `http://localhost:5173` (equivalently the running `http://[::1]:5173`).
- **Fixture/reset:** dev-only seeded quick-select panel (`LoginForm.tsx:123-138`) using real seeded Supabase Auth accounts; local Supabase stack confirmed running. Owner/admin credential path per the umbrella plan's Finding 8. No fabricated fixture data. Mask or hold constant dynamic regions (real student names, live dates, computed progress) before capture.
- **Backend:** Playwright (`playwright.config.ts`, `testDir: './src/__tests__/e2e'`). Not Claude-in-Chrome, for the reasons recorded in Acceptance and validation above.
- **Journeys, viewports, and visible outcomes:** per the per-item acceptance criteria and the Per-issue browser-validation journeys table above. Viewport profiles: 1440x900, 390x844, and the {900, 1000, 1100, 1200, 1258, 1295, 1300, 1440} sweep for #54.

## Engineering mode

Standard.

## Team authorization

Not applicable.

## Downstream owner

engineering-fleet — T1 first-line, escalating to T2 on two counted gate failures per item, with verifier and browser-validator as independent gates. No writer self-approves completion.

## Approval gate

**This plan requires explicit user approval before any downstream execution.** No T1, browser-validator, design-reviewer, or issue-creation dispatch under this plan may occur before that approval is recorded.

**Standing commit/push/PR/merge authorization, inherited from the umbrella plan and quoted verbatim rather than relayed.** The umbrella plan (`docs/plans/lizbeth-spanish-fjds-full-app-conformance-closure.md`, Approval gate section) records: in the interactive session, authorizing the prior consolidation, the user wrote: "a yes commit then open pr and merge to main." On 2026-09-04, the user wrote: "yes resume the goal, commit, push, open pr and merge to main as we progress." Together these constitute a standing authorization scoped to the `lizbeth-spanish` repository, covering commit, push, PR, and merge to `main`. It excludes deploys, force-pushes, history rewrites, and branch deletion. This plan's execution items may rely on that same standing authorization once this plan itself is approved by the user; it does not independently re-authorize anything beyond what the umbrella plan already recorded, and per `handoff.md`'s instruction, any job packet relying on it should quote the user's own words directly rather than a relayed summary.

Upon approval, update this file's status header from DRAFT to APPROVED, with the approval record (approver, basis, date) filled in at that time, before dispatching item 1 of Ordered work.
