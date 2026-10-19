# Lizbeth Spanish — Remaining FJDS Conformance: Issues #144, #134, #132

## Status

**CLOSED — complete, 2026-09-08.**

All three items are delivered, independently verified, and merged to `main`. #144's gutter fix landed via PR #146 (merge `dde1620`); #132's audit and durable harness landed via PR #147 (merge `a737a01`); D-C's `ContextStatusStrip` landmark fix and #134's bounded conformance subset landed together via PR #149 (merge `365153d`). Final `main` is at `365153d`. GitHub issues #144, #132, and #134 are all closed as of 2026-09-08. #144's defect was sharper in the field than in the filed issue (an internal gutter inconsistency, not merely a wide-viewport gap); #132's audit found one genuine landmark violation, fixed by overturning a previously-documented deliberate decision under explicit user authority (D-C); #134 kept the radios rather than converting to a `<select>`, per D-A's corrected unspecified-pattern framing, and fixed two independent real defects instead. A significant, unrelated lockfile-corruption defect was found and fixed incidentally, filed as follow-up issue #148. A boundary violation during execution (an unauthorized `taskkill`) is disclosed below along with its independently verified blast radius. See "Execution record" below for the full account.

- **Approver:** the user (rob.hasselbach@gmail.com / lebobo88).
- **Date:** 2026-09-08.
- **Basis:** the user's own explicit statement, verbatim: "approve." This followed the user's review of a compact summary covering: the `PLAN_DUCK` REVISE verdict and its six findings (see Judge route and disposition); all six remediated in one loop; the J-03 root cause — `App.tsx:136`'s catch-all `isRoadmapRoute` versus `ContextStatusStrip.tsx:83`'s strict `path === '/roadmap'` equality; the J-04 gate error, confirmed and corrected; and the two narrowed overreaching claims (J-01 and J-05).
- **Closure date:** 2026-09-08.

Approving this plan resolves D-B in full (see Resolved decisions) and leaves Open decision D-A open with the user — see below — and D-C conditional. This plan is written so both of D-A's outcomes are directly executable once the user rules on it; D-A's widget-type branch gates only that portion of Step 5, and the #144 and #132 work streams proceed independently of it. Neither the judge pass nor this planning pass consulted any authoritative WCAG or ARIA Authoring Practices Guide source on the radio-versus-select question underlying D-A; that trade-off is general knowledge informing a preference call, not researched authority. No live GitHub state was read at any point during planning, which is exactly why J-05's audit-scope gap for #132 was real. `PLAN_DUCK` ran at `gpt-6-astra`, medium effort, in shadow mode; this was the checkpoint's second invocation, the first having failed adapter validation on an invalid `task_id` and produced no judgment.

No standing forward authorization is invoked or claimed by this document beyond the inherited scope stated below. Issue creation and the commit/push/PR/merge authorization discussed under Approval gate are inherited from the governing umbrella plan and are not independently re-granted here.

## Outcome and audience

Close the three remaining genuine Field Journal DS conformance gaps in `lizbeth_spanish` — GitHub issues #144, #134, and #132 — advancing the standing user goal, quoted verbatim: "until the entire field journal design system is properly implemented across all ui layouts and surfaces for the lizbeth spanish project." As qualified under Finding-3-derived scope below and in Acceptance and validation, this plan proves specific audited routes clean against specific axe rules; it does not assert that issue #132 itself is closed, because #132's own required audit scope was never established by the issue text (unread during planning) and must not be inferred from this plan's chosen coverage.

Audience: the engineering fleet (T1/T2, verifier, browser-validator) executing this plan, and the user approving it.

Governing umbrella plan: `docs/plans/lizbeth-spanish-fjds-full-app-conformance-closure.md` (APPROVED, complete, independently verified). This plan inherits that document's no-touch list, GitHub issue logging policy, engineering invariants, and its standing commit/push/PR/merge authorization scoped to the `lizbeth-spanish` repository. It is cross-referenced throughout rather than restated. An independent audit against `main` at `2075f7d` established that #144, #134, and #132 are the only genuine DS non-conformance items remaining; everything else currently open in the repository is adjacent debt, out of scope here.

## Scope

### In scope

Three items only:

1. **#144** — `PublicCatalogPage` horizontal gutter conformance to artboard D.9.
2. **#132** — unblocking authenticated-route landmark/region accessibility auditing, running that audit against an explicit route/role/state matrix (Step 2), and remediating findings that require no visible change. See the audit-scope-versus-issue-closure distinction in Acceptance and validation: this plan states what was audited and what came back clean, and does not assert #132 is closed on that basis.
3. **#134** — an explicitly bounded, deferral-respecting subset (see Open decisions), plus surfacing the widget-standardization question for a user ruling.

### Non-goals

- No new visual direction. Inherited verbatim from the umbrella plan's ratified non-goal.
- No typography change, no token file changes, no edits to `src/tokens/field-workbook.generated.css`.
- No work on adjacent functional or test-infrastructure debt open in the repository. The planning-stage audit established #144, #134, and #132 as the only genuine DS non-conformance items left.
- No fix to the pre-existing failing baseline (#139 / #82 — date drift and fixture counts).
- No resolution of GitHub issue #140 (`getCourse()` prefers a draft over a published version). It is a known open defect affecting fixture reachability for #134's Settings-tab surface; this plan works around it with named known-good fixtures rather than fixing it.
- No editing `supabase/seed.sql`. Fixture provisioning, where genuinely needed, is additive through the app's edge-function API only.
- No `taskkill`. No destructive git commands. No force-push, history rewrite, or branch deletion.
- `lizbeth_spanish/atelier.config.json` is never edited — standing no-touch directive; the operative config is the orchestrator-root one.
- `design/field-journal/ADOPTION-PLAN.md` carries a deliberately-uncommitted local modification that must never be staged.

## Background and repository findings

All findings below were verified by direct source read against `main` at `2075f7d` during this planning pass. Where a claim in the incoming handoff turned out to need correction or sharpening, that is stated explicitly rather than silently absorbed. All three issues were re-checked for current validity, not inherited, because earlier work in this program found that two prior issues did not reproduce and a third was substantially subsumed — the same discipline is applied here.

### Finding 1 — Issue #144 reproduces, and the defect is sharper than the issue states

`src/pages/PublicCatalogPage.tsx:89` renders `<header className="catalog-header">`, `:101` renders `<footer className="catalog-footer">`, and there are two `<main className="course-workspace">` elements — the course-detail view at `:111` and the catalog list view at `:175`. Both are in scope.

`src/pages/PublicCatalogPage.css:16` gives `.catalog-header { padding: var(--space-6) 56px; }`, and `:197` gives `.catalog-footer { padding: var(--space-5) 56px; }`. The page's own chrome implements the 56px horizontal gutter correctly. The `<main>` elements do not: they borrow `.course-workspace` from `src/pages/CourseWorkspace.css:1`, whose declaration is `padding: var(--space-2) 0 var(--space-8)` — zero horizontal padding — with no `max-width` in either stylesheet. At `@media (max-width: 700px)` (`CourseWorkspace.css:55`) it gains `padding-inline: var(--space-2)`, and `PublicCatalogPage.css:258-259` gives the header and footer a matching `var(--space-2)` at that same breakpoint.

The defect is not merely "no gutter at wide viewports." At every viewport above 700px, the page's header and footer sit on a 56px inset while its main content sits on a 0px inset — an internal inconsistency within one page. The issue's own 1920px arithmetic is confirmed independently: `.catalog-grid` (`PublicCatalogPage.css:105-109`) is `repeat(3, minmax(0,1fr))` with `gap: var(--space-8)`, so at 1920px wide the cards run roughly 619px, flush to both screen edges.

The DS specifies this directly. `design/field-journal/Field Journal DS.dc.html:1193`, inside the D.9 artboard, gives `<main style="padding: 56px 56px 64px;">`. The app implemented D.9's header and footer gutters and omitted its main gutter — a literal, citable non-conformance, not an inference. D.9 governs this page (`Field Journal DS.dc.html:1182-1245`), frame `width: 1440px` at `:1184`, `main` carrying no `max-width`; confirmed by design review. There is no E.9 mobile counterpart.

Structurally, `PublicCatalogPage` is routed at `src/App.tsx:376`, returning before the `if (!session)` login branch at `:460` and before the authenticated shell. It never renders inside `.app-main` and inherits none of the issue-#11 shell harmonization. Any fix here must be page-local.

### Finding 2 — Issue #134 reproduces, and there are three "Enrollment mode" controls, not two

`src/pages/NewCoursePage.tsx:7` renders a `<fieldset><legend>Enrollment mode</legend>` with three native `<input type="radio">` over `['invite_only','request','open']`, labels rendered via `v.replace('_',' ')`, producing lowercase "invite only" / "request" / "open," submitted as `enrollmentMode` to `createCourse`.

`src/pages/CourseWorkspacePage.tsx:1014` (the Settings tab) renders `<label>Enrollment mode<select>` over the same three values, with options "Invite only" / "Request approval" / "Open enrollment," saved via `updateCourse({ enrollment_mode: mode })` at `:1032`.

A third control exists at `src/pages/CourseWorkspacePage.tsx:848` — `<select aria-label="Enrollment mode">` inside `CohortForm`. This is a cohort-level entity with a different lifecycle from the two course-level controls and is explicitly **out of scope**. An engineer sweeping by label text alone would wrongly capture it; the invariants and acceptance checks below name this exclusion explicitly.

Two defects not present in the originating brief were found by direct read:

- The three radios at `NewCoursePage.tsx:7` carry no `name` attribute. React's `checked` prop drives which one appears selected, but without a shared `name` these are not a native radio group — native arrow-key roving and assistive-technology group-membership announcement are not guaranteed by the browser. This is an accessibility defect on the existing widget, independent of the widget-type question below.
- The option wording differs between the two surfaces for the same three domain values: "invite only" versus "Invite only," "request" versus "Request approval," "open" versus "Open enrollment." This is a plain copy inconsistency, also independent of the widget-type question.

The umbrella plan deliberately deferred standardizing the enrollment-mode widget as a widget/interaction-pattern change conflicting with its ratified "No new visual direction" non-goal (`lizbeth-spanish-fjds-full-app-conformance-closure.md:32`, status APPROVED at `:5`). That deferral has not been overturned by the user. The issue #11 plan received an explicit scope waiver for exactly this class of change, which stands as the relevant precedent should the user choose to grant one here.

### Finding 3 — Issue #132's tooling block is real and its source-level finding is confirmed; the earlier `ContextStatusStrip` contradiction is now explained, not merely disputed

Issue #58 fixed the logged-out login screen (previously 10 axe violations — `landmark-one-main` x1, `region` x9 — now clean across all rules). Authenticated routes were never audited, because Atelier's `a11y_audit` headless browser cannot carry an auth cookie and the tool exposes no `storageState` or session-injection option.

`src/App.tsx:299` renders `<ContextStatusStrip path={path} email={email} />` between `</header>` and `<main className="app-main">` (`:311`) — outside both landmarks.

An earlier characterization of this pass stated that a browser check on the default post-login roadmap route found no `.context-strip` element, inferring the component "evidently renders on a different screen or condition." That inference is incorrect, verified by direct read of `src/components/ContextStatusStrip.tsx`. Its `shouldRender = isRoadmapRoute || !!weekDetail || isFeedbackRoute` (`:82-85`) returns `null` only when that is false; on `/roadmap` it renders. The identity line at `:151` always renders unconditionally from the `email` prop, but the progress line at `:152` is gated behind `{!isFeedbackRoute && ...}` — so the component emits **two** `<p>` elements on `/roadmap` and on the week-detail route, and **one** (identity only) on `/feedback`. `:78-79` documents that the component "carries no landmark role" as a deliberate decision.

**The prior null observation is now explained, on a subsequent PLAN_DUCK judge pass's direct verification, by two independent mechanisms, neither of which contradicts the source above:**

- `App.tsx:102-107` returns `ForcedPasswordChangeGate` inside a bare `<div className="app">`, returning before the authenticated shell mounts. On that branch there is no header, no `<main className="app-main">`, and no `ContextStatusStrip` at all.
- More precisely, and this is the substantive explanation: `App.tsx:136` derives `isRoadmapRoute` as a catch-all negation — `!weekDetail && !isLearnRoute && !learnDetail && !isFeedbackRoute && !isAdminRoute` — so `App` renders the roadmap view for a range of paths, including `/`. `ContextStatusStrip.tsx:83`, by contrast, tests strict equality against the literal string `'/roadmap'`. A student sitting on `/` therefore sees the roadmap UI while the strip correctly returns `null`, because `'/' !== '/roadmap'`. This is a genuine predicate divergence between the two files, not a bug in either file's own logic taken alone, and it is the likely explanation for the prior null observation.

The consequence for scope: the component renders visible text outside any landmark on authenticated routes reached via the strict `'/roadmap'` path match, the week-detail route, and `/feedback` — a textbook `region` violation candidate on those paths specifically. It is not present, by construction, on other paths that render the same roadmap view (for example `/`) or on the `ForcedPasswordChangeGate` branch. Step 2 narrows its reconciliation task accordingly: rather than treating this as an unexplained contradiction requiring a stop-and-report, Step 2 records the exact `window.location.pathname`, authentication state, and shell-mount status at each observation, and records the App-versus-strip predicate divergence itself as a finding worth noting on its own, since it means the strip is absent from roadmap views served at paths other than the literal `/roadmap`.

The tooling block is already solved in-repo, which the originating issue did not know. `src/__tests__/e2e/issue-11-content-ceiling-and-chrome-harmonization.spec.ts:18-24` defines a working `signIn(page, email)` helper that fills the real login form (`getByLabel('Email')`, `getByLabel('Password')` with the literal password `password`, then the "Open my journal" button) and waits on `header.app-header`. The same spec authenticates and then calls `await page.goto('/roadmap')` at `:37`. Playwright can already authenticate and hold a session against this app; no new session-injection mechanism is needed. A rich authenticated e2e corpus already exists, including owner flows (`issue-4-owner-workspace.spec.ts`, `gap-1-owner-settings-persistence.spec.ts`, `gap-4-admin-students-remediation.spec.ts`).

What is genuinely missing is axe. `package.json:42` names `@playwright/test` `^1.61.1`, and `:13` names `"test:e2e": "playwright test"`. Neither `axe-core` nor `@axe-core/playwright` appears anywhere in `package.json`. "Injecting axe from a local copy" is therefore not a dependency-free alternative — no local copy exists; axe-core would have to be acquired one way or another. See Resolved decisions, D-B, for the approved choice and its governance conditions.

`playwright.config.ts` sets `testDir: './src/__tests__/e2e'` (`:4`), `workers: 1` and `fullyParallel: false` (`:5`, `:8`), and `baseURL: process.env.E2E_BASE_URL || 'http://localhost:8888'` (`:11`). Its `webServer` (`:29-35`) runs `npm run build && netlify serve --context production --port 8888` with `reuseExistingServer: !process.env.CI`. This is a genuine discrepancy an executing job must not confuse with the manual validation path: the umbrella plan's manual browser-validation section uses `npm run dev` at `http://localhost:5173`, while the Playwright path is a production-parity build at `http://localhost:8888`. Both are real and serve different gates; see Browser UI validation below.

### Finding 4 — Shared-class hazard, with a third consumer the design packet initially missed

`.course-workspace` is a shared class. `src/pages/CourseWorkspace.css:3-54` carries a comment recording a previously-shipped defect of exactly this class: a page-scoped focus ring keyed on `.course-workspace` leaked onto the unauthenticated public catalog and painted terracotta rings there, found only through browser validation. Independent design review confirmed three consumers of the stylesheet and class, not two: `CourseWorkspacePage.tsx:75-76` (`<section className="course-workspace">`), `NewCoursePage.tsx:7` (`<section className="course-workspace">`), and `CourseSettingsPage.tsx:8`, which imports `CourseWorkspace.css` and renders `<div className="course-workspace">`. All three use a non-`main` element, which is a second independent safety layer for the fix specified below.

## Research evidence

None. No external or current-fact question was material to this plan; every finding above is direct local repository evidence gathered during this planning pass. One deliberate evidence limit is recorded under Assumptions and decisions.

## Design route

```
DESIGN_ROUTE
profile: compact
reasons: Bounded brownfield UI on one existing page (PublicCatalogPage) whose governing artboard D.9 already exists and is ratified. No new screen, no new flow, no multi-state component, no new visual direction. #134 is a widget-consistency question surfaced as a user decision rather than designed away; #132 is accessibility-audit infrastructure with no visual change in scope.
agents_required: design-generalist, design-reviewer
prototype: forbidden
model_tier: sonnet
existing_system_mode: preserve
END_DESIGN_ROUTE
```

### Design handoff (binding contents)

Selected direction: preserve D.9 literally. Give both `<main>` elements the same literal 56px horizontal gutter the page's own header and footer already carry, reproducing D.9's exact edge geometry, rather than adopting the authenticated shell's `--size-content-max` composite ceiling.

**Rejection rationale for the shell-composite alternative, load-bearing.** Adopting the issue-#11 shell pattern `max(var(--space-6), calc((100vw - var(--size-content-max)) / 2))` evaluates at a 1440px viewport to `(1440 - 1296) / 2 = 72px`, because `--size-content-max` is `81rem` = 1296px (`src/tokens/field-workbook.generated.css:141`). 72px is 16px wider than D.9's literal 56px, which would shrink the ratified content width from 1328px to 1296px at the artboard's own reference width — a regression against the ratified artboard, not a conformant match. The page therefore does not join the `--size-content-max` system; the arithmetic decides it, and design review independently re-derived and confirmed it.

**Layout specification.**

- New selector `main.course-workspace.catalog-main`, declared in `PublicCatalogPage.css` only. Specificity (0,2,1). It requires both `.course-workspace` and a new page-owned `.catalog-main` class, so it can never fire on the three other shared-class consumers; independently, all three of those use `<section>` or `<div>`, never `<main>`, providing a second safety layer.
- Base rule, unguarded: 56px of horizontal padding on both sides.
- Inside the existing `@media (max-width: 700px)` block at `PublicCatalogPage.css:218-261`, a mandatory override to `var(--space-2)` on each side. This override is mandatory, not optional: the base rule's (0,2,1) specificity would otherwise defeat `CourseWorkspace.css:55`'s `.course-workspace { padding-inline: var(--space-2) }` at (0,1,0) even below 700px, silently breaking the page's established mobile gutter. Design review finding DR-1 adds a required precision: the override must be authored on the same full three-part selector `main.course-workspace.catalog-main`, never a bare `.course-workspace`, or it loses the specificity tie it exists to win.
- No `max-width` on either `<main>` at any width, matching D.9's own composition. `.catalog-hero-body`'s existing `max-width: 60ch` (`PublicCatalogPage.css:101`, matching D.9 `:1194`) is untouched.
- Both `<main className="course-workspace">` elements at `PublicCatalogPage.tsx:111` and `:175` add the literal class `catalog-main`. This is the only TSX change in Step 4.

Card grid arithmetic (content width equals viewport minus 112px; three columns; 32px gaps), independently recomputed by design review:

| Viewport | Content width | Column width |
|---|---|---|
| 900px | 788px | ~241px |
| 1280px | 1168px | ~368px |
| 1440px | 1328px | ~421px — exactly reproduces D.9 |
| 1920px | 1808px | ~581px — extrapolated; the DS is silent above 1440 |

Tokens: none added, none changed. 56px is D.9's own literal and already appears in this file at `:16` and `:197`. It corresponds to no defined token (`--space-6` is 24px, `--space-7` is 28px); tokenizing it is explicitly out of scope.

**Engineering invariants, with design review's corrections folded in.**

- Do not modify bare `.course-workspace` in `CourseWorkspace.css`. All new declarations go on the compound selector in `PublicCatalogPage.css`.
- The ≤700px override is mandatory and must use the full `main.course-workspace.catalog-main` selector (DR-1).
- Never let `catalog-main` reach `CourseWorkspacePage.tsx`, `NewCoursePage.tsx`, or `CourseSettingsPage.tsx` (DR-2 added the third consumer).
- Do not touch `.catalog-hero-body`'s `max-width: 60ch`.
- Do not touch `.catalog-header` / `.catalog-footer`'s existing 56px and `var(--space-2)` values — already conformant.
- Do not add a `max-width` to either `<main>` at any breakpoint.
- Do not edit `src/tokens/field-workbook.generated.css`.
- Add no `:focus-visible` rule and no bare-tag or bare-`.course-workspace` selector; the historical hazard at `CourseWorkspace.css:3-54` is not to be reopened.

**Permitted variation.** The implementer may reorder the two new blocks and may author `padding-inline` in place of `padding-left`/`padding-right`. Design review finding DR-5 notes the codebase's own recent direction favors logical properties (issue #11 used `padding-inline-start`/`padding-inline-end` at `App.css:983,1077,1079,1131-1132` and `ContextStatusStrip.css:20-21`, and the rule this override must out-rank at `CourseWorkspace.css:55` already uses `padding-inline`), so the logical form is the better-fitting choice even though both compute identically in this LTR-only app.

### Design review record

**Verdict: PASS, first review, no revision cycle spent.**

The reviewer independently re-verified every load-bearing citation: D.9's literal `padding: 56px 56px 64px` and 1440px frame with no `max-width` on `main`; the 72px-versus-56px and 1296px-versus-1328px arithmetic and `--size-content-max: 81rem`; the (0,2,1)-versus-(0,1,0) specificity claim and its mandatory-mobile-override consequence; the card-width arithmetic at all four viewports; the DS's zero radio/fieldset/legend occurrences and its five `<select>` line citations; `NewCoursePage.tsx:7`'s missing `name` attribute and lowercase copy; and the umbrella plan's ratified non-goal, which the #134 assessment correctly declines to overturn.

Five low findings were raised and are recorded rather than dropped. DR-1 (override selector precision), DR-2 (third `.course-workspace` consumer, `CourseSettingsPage.tsx:8`), and DR-3 (add `CourseSettingsPage` to the regression guard) are folded into the invariants above and into the acceptance checks below. DR-4 and DR-5 are advisory and non-blocking:

- **DR-4:** `.catalog-card-description` (`PublicCatalogPage.css:171-176`) carries no measure cap, unlike the hero's 60ch. At the 1920px ~581px column, with `--font-size-body: 1.0625rem` (17px, `field-workbook.generated.css:94`), the line runs roughly 65-70 characters — within WCAG 1.4.8's AAA-only 80-character guidance, so not a WCAG 2.2 AA violation, correctly non-blocking. The character count is an approximation, not a rendered measurement.
- **DR-5:** the `padding-inline` stylistic point folded into Permitted variation above.

The reviewer's stated limit: it did not independently confirm GitHub issue #144's live text (no browse tool available); the packet's characterization of the issue is accepted as given context.

## Judge route

`PLAN_DUCK` is eligible under `docs/JUDGE-CONTRACT.md` before user approval. Recommended, not required: this plan's fan-out is small — three bounded items — relative to the umbrella plan's, and its highest-risk claim, the 72px-versus-56px arithmetic, has already survived independent design review. Standing call caps apply. Deterministic failures always dominate a judge result. No judge pass is promised here, and no model-generated finding is asserted in advance of an actual run.

A per-item `CODE_REVIEW` checkpoint is optional and, if spent at all, should go to Step 1 (the axe harness) rather than to the #144 CSS change.

## Judge route and disposition

`PLAN_DUCK` ran on this plan per `docs/JUDGE-CONTRACT.md`. Verdict: **REVISE**, high confidence, six findings, four blocking. Policy action: **advisory (shadow mode), non-blocking** — this run does not gate approval, and this section records a quality-improvement pass, not a hard block. One remediation loop was spent against the standing call caps.

Deterministic failures always dominate a judge result, and no judge finding grew this plan's scope. Two findings — J-01 and J-05 — narrowed claims the plan was overreaching on rather than adding new work. The six findings were dispositioned as follows.

| ID | Substance | Disposition |
|---|---|---|
| J-01 (major, blocking) | D-A's framing was wrong: the DS's five `<select>` specimens and zero radio/fieldset/legend examples establish that the enrollment-mode widget is **unspecified** by the DS, not that radios are nonconformant. Presenting the `<select>` as a conformance fix mischaracterized a design inference as a requirement. | **Accepted and corrected.** D-A (Open decisions) is rewritten as an unspecified-pattern preference decision, not a conformance question. The five `<select>` sites remain a legitimate observation about house habit; the plan no longer claims their existence is evidence against radios. The trade-off is now stated neutrally for the user's substantive judgement, with an explicit evidence limit that neither this planning pass nor the judge conducted accessibility research beyond general knowledge. Step 5 is rewritten so both outcomes are executable once the answer arrives. |
| J-02 (major, blocking) | Step 5's acceptance criteria were self-contradictory: the plan permitted replacing the fieldset with a `<select>` while unconditionally requiring a shared `name` and three radios forming a native group, a gate an approved `<select>` could never pass. The missing-`name` defect was also overstated as a proven WCAG failure rather than a native-grouping defect. | **Accepted and corrected.** Step 5's acceptance is now conditional on D-A's outcome: one check set for radios retained, a different check set for a select adopted. Two items are unconditional under either outcome, stated as such: the native-grouping defect at `NewCoursePage.tsx:7` (described as a native-grouping defect, not an established WCAG violation) and the option-copy divergence between the two surfaces, both independently reconfirmed by the judge. |
| J-03 (minor) | The plan's "unexplained contradiction, stop-and-report" treatment of the `ContextStatusStrip` null observation was avoidable: two mechanisms in `App.tsx` (the `ForcedPasswordChangeGate` early return, and the `isRoadmapRoute` catch-all-negation versus the strip's strict `'/roadmap'` equality check) independently explain it without contradicting the source-level finding. | **Accepted, and resolved more precisely than the judge's own framing.** See Finding 3's rewritten closing paragraphs. The stop-and-report treatment is replaced with a bounded recording task in Step 2 (exact pathname, auth state, and shell-mount status per observation), and the App-versus-strip predicate divergence is itself recorded as a finding. A related factual correction: the plan previously stated `ContextStatusStrip` always emits two `<p>` elements; corrected to two on `/roadmap` and week-detail, one (identity only) on `/feedback`, per `ContextStatusStrip.tsx:151-152`. |
| J-04 (major, blocking) | The Step 4 browser-validation assertion comparing `.catalog-grid`'s bounding-box left to `.catalog-header`'s bounding-box left is wrong: `.catalog-header` carries its own internal `padding: var(--space-6) 56px`, so its border-box left sits at the page edge while the grid's left sits 56px inward inside the newly padded main. A correct implementation would fail this assertion as originally written. | **Accepted in full; this was a planning error, independently verified.** The assertion is rewritten in "Journeys and visible outcomes for Step 4" to compare the grid's left edge against the header's content edge (border-box left plus computed border-left-width plus computed padding-left), equivalently the left edge of `.catalog-header-brand`, with the border-and-padding accounting stated explicitly. The `.catalog-grid`/`.catalog-card` assertions are also now scoped to the catalog list journey only; the course-detail journey has no `.catalog-grid` and must not carry those assertions. |
| J-05 (major, blocking) | The plan asserted DS-conformance closure on #132 without establishing what audit scope the issue actually requires, and Step 2's "to whatever depth the credential path allows" was undefined and unauditable. The durable Playwright axe harness was also presented as though #132 demanded permanent infrastructure, which was not established. | **Accepted and narrowed; this was an overreach the judge correctly caught.** Outcome and audience, Scope, Step 2, and Acceptance and validation now: (1) name the durable harness as a proposed maintenance choice, not an issue requirement, stating plainly that a one-shot audit would also satisfy the issue and that adopting durability is a maintenance commitment the user is separately taking on; (2) replace "to whatever depth the credential path allows" with an explicit route/role/state matrix in Step 2, in which unreachable coverage is recorded as unreached with its reason, never dropped silently and never counted as passing; (3) distinguish completed audit scope from issue closure throughout, so no downstream job records #132 as closed on a scope the issue itself never defined. |
| J-06 (minor) | D-B (the axe dependency choice) was left as an open decision requiring user approval, but the user has since approved adding `@axe-core/playwright` as a devDependency, with governance conditions the plan had not recorded, and one alternative (ephemeral CDN injection) was missing from the comparison. | **Accepted.** D-B is moved from Open decisions to resolved-approved, with the governance conditions folded in: version compatibility with the resolved `playwright-core` 1.61.1 confirmed at install time; lockfile changes reviewed, not accepted blind; axe rule-version updates controlled and deliberate; the dev-only-versus-CI-execution distinction noted explicitly; and ephemeral CDN injection via `page.addScriptTag({ url })` recorded as considered and not chosen, alongside the bare-`axe-core`-plus-glue and vendored-build alternatives. Dependencies, Open decisions, and Approval gate are updated so D-B no longer blocks Steps 1-3. |

**Evidence limits added by this disposition, stated in full:**

- Neither this planning pass nor the judge pass conducted accessibility research beyond general knowledge. No authoritative WCAG or ARIA Authoring Practices Guide source was consulted on the radio-versus-select question. D-A's trade-off description is general knowledge offered to inform a preference call, not researched authority.
- The authoritative text of GitHub issue #132 remains unverified, in the judge's pass as in planning. No live GitHub state has been read at any point in this plan's development. This is precisely why J-05's required-audit-scope gap is real and why the plan does not assert issue closure.

## Ordered work

These items are largely independent in principle, but they are dispatched **serially**, one bounded T1 job at a time. Grounds: concurrent dispatch across files with shared invariants has already caused one cross-item conflict earlier in this program, and #144 and issue #11's just-landed content-ceiling work touch adjacent layout concerns. Serial dispatch costs little here and removes the conflict class entirely.

### Step 1 — Unblock authenticated accessibility auditing (#132, part 1) — COMPLETE

Owner: T1. Depends on: user approval of this plan. D-B (the axe dependency choice) is resolved and approved (see Resolved decisions); this step must still confirm `@axe-core/playwright`'s compatibility with the resolved `playwright-core` 1.61.1 at install time, per D-B's governance conditions.

Build an authenticated axe harness as a Playwright spec under `src/__tests__/e2e/`. Reuse the existing working `signIn` helper pattern at `issue-11-content-ceiling-and-chrome-harmonization.spec.ts:18-24` rather than inventing a new session mechanism. Do not modify `playwright.config.ts` beyond what is strictly necessary. No product source file changes in this step.

**Acceptance:** the spec authenticates, navigates to at least `/roadmap`, runs axe, and reports results; it fails loudly rather than silently passing when axe cannot run or authentication does not complete. Run it 8 or more times consecutively and record every run's result.

### Step 2 — Run the authenticated audit against an explicit route/role/state matrix, and record the ContextStatusStrip predicate divergence (#132, part 2) — COMPLETE

Owner: T1. Depends on: Step 1.

Audit against the following route/role/state matrix rather than an open-ended "to whatever depth the credential path allows" instruction. Each row names the route, the role required to reach it, and the state to exercise; a row that cannot be reached is recorded as unreached with its reason, never dropped silently and never counted as passing.

| Route | Role required | State to exercise | If unreachable |
|---|---|---|---|
| `/roadmap` | Student (authenticated) | Loaded, with weeks unlocked/locked mix if available | N/A — reachable via the dev-only quick-select panel |
| Week-detail route | Student (authenticated) | Loaded lesson content | N/A — reachable via the dev-only quick-select panel |
| `/feedback` | Student (authenticated) | Loaded, empty, and (if reachable) submitted | N/A — reachable via the dev-only quick-select panel |
| Student learn surfaces (`LearnIndexPage`, `LearnDetailPage`) | Student (authenticated) | Loaded, at least one lesson state | N/A — reachable via the dev-only quick-select panel |
| Owner dashboard and course-management surfaces | Owner | Loaded | Record as unreached with reason "owner credential path not confirmed during planning" if credentials are unavailable; do not substitute student-role evidence |
| Admin students surfaces | Admin | Loaded | Record as unreached with reason "admin credential path not confirmed during planning" if credentials are unavailable |

Capture the full finding set as evidence for every reached row.

**Reconciliation task, narrowed per Finding 3.** Record, for each `ContextStatusStrip`-adjacent observation, the exact `window.location.pathname`, the authentication state, and whether the authenticated shell had mounted at the time of observation. Record the `App.tsx:136` `isRoadmapRoute` catch-all-negation versus `ContextStatusStrip.tsx:83`'s strict `'/roadmap'` equality as its own finding: the strip is absent from roadmap views served at paths other than the literal `/roadmap`. This is a bounded recording task, not a stop-and-report condition — Finding 3 already supplies the explanation; Step 2 confirms it against runtime observation rather than re-litigating whether a contradiction exists.

**Acceptance:** a recorded, reproducible finding set per matrix row, with every unreachable row disposed as unreached-with-reason rather than omitted, and the `ContextStatusStrip` predicate-divergence finding recorded against runtime evidence. This step's acceptance describes completed audit scope only; it does not itself assert issue #132's closure (see Acceptance and validation).

### Step 3 — Remediate the audit findings (#132, part 3) — COMPLETE

Owner: T1. Depends on: Step 2.

**Bounded constraint, load-bearing.** Remediation under this plan is limited to semantic and landmark changes with zero visible effect — no computed-style change on any element. Any finding whose fix would change rendered appearance is a stop-and-report condition requiring a new plan and a design pass, because the compact design route approved here covers only #144's visual change and cannot cover findings that do not yet exist.

For `ContextStatusStrip` specifically: `ContextStatusStrip.tsx:78-79` documents its landmark-less rendering as a deliberate decision. Overturning a documented deliberate decision is not a T1 judgement call; if the audit confirms a `region` violation there, the fix options and their tradeoffs are reported for a ruling (Open decision D-C), not resolved unilaterally.

**Acceptance:** axe returns clean on the audited authenticated routes for `landmark-one-main` and `region`, or every remaining violation carries a recorded, evidence-backed disposition.

### Step 4 — #144 PublicCatalogPage gutter conformance — COMPLETE

Owner: T1. Depends on: Step 3 complete (serial dispatch), and on the reviewed design handoff above.

Implement exactly the layout specification in the design handoff. Two files only: `src/pages/PublicCatalogPage.css` and `src/pages/PublicCatalogPage.tsx`.

**Acceptance:** see Acceptance and validation. This step's rendered geometry must be gated on Playwright, not jsdom.

### Step 5 — #134, bounded conformance subset, plus one branch conditional on D-A's outcome — COMPLETE (radio branch retained)

Owner: T1. Depends on: Step 4, and on the user's answer to Open decision D-A (see below — D-A is now a preference call, not a conformance question). Written so both outcomes are executable the moment the answer arrives.

**Unconditional under either D-A outcome, and always in scope for this step:**

(a) add the missing shared `name` attribute to the three radios at `NewCoursePage.tsx:7`, fixing the native-grouping defect identified in Finding 2 — this is a native-grouping defect, not an established WCAG violation, and must not be described as the latter;
(b) correct the option wording so the same three domain values read identically on both surfaces.

**Conditional on D-A's outcome, applied to (b) and to the widget itself:**

- **If radios are retained** (D-A resolves against overturning the deferral, or is left unresolved and the deferral stands): apply (b)'s copy fix within `NewCoursePage`'s existing radio-fieldset widget; do not replace it.
- **If a `<select>` is adopted** (D-A resolves to overturn the deferral): replace the radio-fieldset at `NewCoursePage.tsx:7` with a `<select>` matching the Settings tab's widget and copy.

Do not touch `CourseWorkspacePage.tsx:848`'s cohort-level control under either branch.

**Acceptance, conditional on D-A's outcome:**

- **If radios are retained:** a shared, non-empty `name` attribute is present across all three inputs; arrow-key navigation moves selection within the group; the group occupies one Tab stop; selection is mutually exclusive; option wording matches the Settings tab's wording; a test proves all of the above; `CohortForm`'s control is provably unchanged.
- **If a select is adopted:** the `<select>` carries accessible labeling equivalent to the Settings tab's; the three domain values `invite_only` / `request` / `open` are unchanged in the submitted payload; a test proves both; `CohortForm`'s control is provably unchanged.

## Interfaces and data

No API, schema, migration, or data-model change. `updateCourse`'s `enrollment_mode` payload and `createCourse`'s `enrollmentMode` payload are unchanged by every permitted variant of Step 5 — the domain values `invite_only` / `request` / `open` are stable regardless of widget or label copy. The dependency-surface change is the approved addition of `@axe-core/playwright` as a devDependency in Step 1 (see Resolved decisions, D-B), subject to its governance conditions.

File surface: `src/pages/PublicCatalogPage.css`, `src/pages/PublicCatalogPage.tsx`, `src/pages/NewCoursePage.tsx`, one or more new specs under `src/__tests__/e2e/`, possibly `package.json` and `package-lock.json`, and possibly whatever Step 3's bounded remediation touches.

## Acceptance and validation

### Audit-scope-versus-issue-closure distinction (#132)

This distinction is stated up front because it governs how Steps 1-3's results may be reported. The durable Playwright axe harness built in Step 1 is a **proposed maintenance choice**, not a requirement established by issue #132 itself: the umbrella plan never established a permanent-infrastructure requirement for this audit, and a one-shot audit run would also satisfy the issue as far as this plan's evidence can establish. The harness is proposed here because it makes future regressions catchable, which is a maintenance benefit the plan recommends, not a mandate the issue imposes. Adopting it is a maintenance commitment the user is separately taking on, distinct from approving this plan's scope.

Separately, "completed audit scope" and "issue closure" are not the same claim. This plan may state, with evidence, which routes in Step 2's matrix were audited, in which role and state, and which returned clean against which axe rules. It may not assert, and no downstream job may record, that issue #132 is closed, or that DS conformance across the app is complete, on that audit evidence alone — because #132's own required scope was never read during planning (no `gh` access) and is therefore unestablished. Gate 7 below carries this distinction into the terminating condition.

### Gates that apply to every step

1. `npm run lint` and `tsc --noEmit` pass.
2. The vitest suite shows no new failures relative to a baseline captured at the start of that step. The current known-failing baseline is 3 files / 8 tests — `FeedbackLedgerRow.test.tsx` x1, `rlsIntegration.test.ts` x3, `roadmapIntegration.test.ts` x4 — pre-existing date drift and fixture counts tracked as #139/#82. The gate is "no new failures against a freshly captured baseline," not "all green," because the baseline moves. An exclusion-based pass is a failed gate.
3. The existing token pipeline oracle and the deprecation lint still pass. No token file is edited.
4. The deterministic no-native-dialog source scan passes.
5. An independent Verifier pass is recorded. No writer self-approves completion.
6. A Browser Validator pass is recorded for any step with a rendered effect.
7. For Steps 1-3, evidence is reported as completed audit scope against Step 2's route/role/state matrix, never as issue #132 closure or as full-app DS-conformance completion. See the audit-scope-versus-issue-closure distinction above.

### Test-design gates

Each earned by a specific prior failure in this program, and each mandatory:

- **jsdom does not catch this defect class.** Three runtime-only bugs shipped behind green suites earlier in this program: an overlay confined by an ancestor's residual transform, focus never restoring on close, and `aria-pressed` frozen at mount. Every rendered-behavior assertion in Step 4 must be gated on Playwright. Use `src/__tests__/helpers/cssCascade.ts` for resolved-declaration assertions where a source-level cascade check is genuinely the right instrument.
- **Every new Playwright spec must be run 8 or more times consecutively**, with every run recorded. One spec earlier in this program shipped with a roughly 35-40% flake that two runs missed. Avoid locator fallbacks that can silently select the wrong element.
- **Assertions can pass while going stale.** A test asserting the literal string `var(--size-content-max, 75rem)` would have passed after the value changed. Prefer live cross-file guards over frozen literals. For Step 4 specifically, prefer asserting that main's computed inset equals the header's computed inset over asserting the literal 56px, so the guard cannot go stale if the shared value ever moves.
- **Prefer reusing existing fixtures.** Fixture provisioning has moved fixed-count assertions before (`rlsIntegration.test.ts:162` and `:183`). Provision additively through the app's edge-function API if genuinely required; never edit `supabase/seed.sql`.

**Known-good fixtures for #134's Settings-tab surface**, needed because open issue #140 makes `getCourse()` prefer a draft over a published version and can render some owner surfaces unreachable: course `6f435dc7-897b-4b88-97f8-3aa1fb0f502c` (Beginner, editable) and `9faf5d37-9adf-43d4-ba2f-c991866deb50` (published, single version).

## Browser UI dialog policy

Required. This is a browser-rendered React UI. No native `alert`, `confirm`, `prompt`, their `window.*` forms, or `beforeunload` in any existing or newly touched state. Acknowledgement and confirmation use the app-owned accessible modal: focus trapped while open, focus returned to the trigger on close, Escape plus an explicit close control, never backdrop-only dismissal, visible 3px slate focus ring at every stop. Inline validation per the C.2 pattern is preferred where the DS already shows an inline pattern. The deterministic no-native-dialog source scan over `src/**` plus a runtime confirmation on every touched journey are both required; the source scan alone does not prove runtime behavior.

## Browser UI validation

**Launch and readiness — two paths, and a job must not confuse them.** The umbrella plan's manual browser-validation path is `npm run dev` in `H:\CommandCenter\orchestrator\lizbeth_spanish`, base URL `http://localhost:5173`, ready when the login route renders. The Playwright path is governed by `playwright.config.ts`: base URL `http://localhost:8888` from `process.env.E2E_BASE_URL || 'http://localhost:8888'` (`:11`), with a `webServer` (`:29-35`) running `npm run build && netlify serve --context production --port 8888` and `reuseExistingServer: !process.env.CI`. Reuse an existing healthy server rather than restarting it. Never `taskkill`; scoped-PID termination only if termination is genuinely required.

**Fixtures and reset:** the dev-only seeded quick-select panel (`LoginForm.tsx:123-138`) for authenticated student surfaces, using real seeded Supabase Auth accounts; the local Supabase stack must be confirmed running before any RLS-dependent result is trusted. The existing Playwright specs sign in through the real login form with `student1@test.local` and the literal password `password`. No fabricated fixture data.

**Viewport profiles:** 700, 900, 1280, 1440, 1920, plus the WCAG reflow check at a 320px-equivalent viewport / 400% zoom. Claude-in-Chrome cannot control viewports in this environment, so the viewport sweep must run under Playwright. The existing D.9 pixel baseline is `1446x991` per `.atelier/reference-harness/manifest.json` — 6px wider than D.9's own 1440px frame, so a baseline pixel-diff alone is not a conformance signal without also checking computed values.

### Journeys and visible outcomes for Step 4

From the reviewed design handoff:

- **Journey 1:** unauthenticated catalog list view at `/courses`. **Journey 2:** unauthenticated course-detail view at `/courses/:id` using a real seeded course id. Both `<main>` sites must be exercised.
- At each viewport profile, on both journeys, measure: computed `padding-left` and `padding-right` on `main.course-workspace.catalog-main`; computed `padding-left` on `.catalog-header` and on `.catalog-footer`, which must equal main's at every profile.
- **Grid-alignment assertion, catalog list journey only.** `.catalog-grid` exists only on the catalog list view (`PublicCatalogPage.tsx:175`); the course-detail journey has no `.catalog-grid` and must not carry this assertion. On the catalog list journey, compare `.catalog-grid`'s left edge not to `.catalog-header`'s bounding-box left, but to `.catalog-header`'s **content edge** — the header's border-box left plus its computed `border-left-width` plus its computed `padding-left` — because `.catalog-header` (`PublicCatalogPage.css:14-21`) carries its own internal `padding: var(--space-6) 56px`, so its border-box left sits at the page edge (x=0) while the grid's left sits 56px inward inside the newly padded main. Comparing raw bounding-box lefts would fail a correct implementation. Equivalently, compare the grid's left edge to the left edge of `.catalog-header-brand`, the header's first flex child, which sits at the header's content-box left because `.catalog-header` is `display:flex` with `justify-content: space-between`. This equality must hold at both ≥701px and ≤700px.
- **Card-width assertion, catalog list journey only.** Individual `.catalog-card` computed width, expected approximately 241 / 368 / 421 / 581 px at 900 / 1280 / 1440 / 1920 respectively, within rounding.
- At the 320px-equivalent / 400% zoom profile: no horizontal scrollbar or overflow on either `<main>`.
- Zero native dialogs triggered in either journey.
- **Regression guard**, covering all three shared-class consumers per DR-2 and DR-3: `CourseWorkspacePage`'s Settings tab, `NewCoursePage`, and `CourseSettingsPage` all render with no visible change and no computed-inset change.

### Journeys and visible outcomes for Steps 1-3

The browser evidence is the axe finding set itself per route, plus, for any Step 3 remediation, a before-and-after computed-style comparison proving the zero-visible-change constraint held.

## Execution record

This plan is closed. It is recorded here honestly: the review chain caught real planning errors before they shipped, one filed issue turned out narrower than reality, a significant unrelated defect was found and fixed incidentally, and a boundary violation occurred and is disclosed rather than smoothed over.

### Merged work

| PR | Merge commit | Covers |
|---|---|---|
| #146 | `dde1620` | #144 — `PublicCatalogPage` gutter conformance (Step 4) |
| #147 | `a737a01` | #132 — authenticated axe harness, route/role/state matrix audit, and remediation (Steps 1-3) |
| #149 | `365153d` | D-C (`ContextStatusStrip` landmark fix) and #134's bounded conformance subset (Step 5, radio branch) |

**Final `main`:** `365153d`.

**GitHub issues:** #144, #132, and #134 all closed 2026-09-08.

### #144 — the defect was more precise than filed

The DS specifies the gutter literally at `Field Journal DS.dc.html:1193` (D.9's `<main>`: `padding: 56px 56px 64px`). The app had implemented D.9's header and footer gutters and omitted main's, making it an **internal inconsistency at every viewport above 700px**, not just a wide-viewport gap as the filed issue framed it. Fixed via a page-owned `catalog-main` class carrying two independent safety layers, since `.course-workspace` has four consumers and this program previously shipped a `.course-workspace` collision that leaked a terracotta focus ring onto an unrelated page. The page deliberately does **not** join `--size-content-max`: at 1440px the shell pattern computes `(1440 - 1296) / 2 = 72px` against D.9's ratified 56px, which would have shrunk content width from 1328px to 1296px — a regression against the ratified artboard, not a conformant match.

### #132 — audit scope delivered, then the finding fixed

`@axe-core/playwright@4.13.0` was added as a devDependency (peer `playwright-core >= 1.0.0`, satisfied by the resolved 1.61.1), with a durable authenticated Playwright harness reusing the existing `signIn` pattern. The six-row route/role/state matrix specified in Step 2 was run in full; all six rows were reachable (no row required the unreached-with-reason disposition). `landmark-one-main` came back clean everywhere audited; `region` came back clean on `/learn`, `/learn/:id`, the owner dashboard, and `/admin/students`.

**One genuine violation was found:** `ContextStatusStrip`'s visible text rendered between `</header>` and `<main>`, outside both landmarks — 2 nodes on `/roadmap`, 2 nodes on the week-detail route, and 1 node on `/feedback` (matching Finding 3's prediction that `:152`'s progress line is gated behind `!isFeedbackRoute`, leaving only the identity line there). This was resolved under D-C by wrapping the strip in `<aside aria-label="Session status">`, which overturns the documented deliberate decision at `ContextStatusStrip.tsx:78-79` under the explicit user authority D-C required.

Consistent with the audit-scope-versus-issue-closure distinction stated in Acceptance and validation, this record states what was audited and what came back clean; it does not claim broader DS conformance than the six-row matrix covered.

### A significant defect found incidentally

During Step 1, `package-lock.json` was found to carry a malformed entry: `@floating-ui/dom` with no `version` field, which crashes npm's arborist with `TypeError: Invalid Version`. This was independently traced to commit `ce90ebb` and reproduced in an isolated scratch copy of the repository via `npm ci --dry-run`, confirming the corruption's origin rather than merely observing its symptom. **Every `npm ci` and every fresh clone of `main` had been broken since that commit** — a defect affecting CI and any new contributor, discovered only because this plan's execution happened to need a clean install. It was repaired as a necessary blocker to unblock Step 1, and filed as follow-up issue **#148** so CI can be separately confirmed green against the fix.

### #134 — radios kept, two real defects fixed

Converting `NewCoursePage.tsx:7`'s radio-fieldset to a `<select>` was declined. Per D-A's corrected framing (itself a correction the judge chain forced onto this plan before approval — see Judge route and disposition, J-01), the DS is **silent** on radios rather than excluding them: zero `type="radio"`/`<fieldset`/`<legend` occurrences alongside five `<select>` sites establishes an unspecified pattern, not a nonconformance. Standardizing onto `<select>` would have been new visual/interaction direction requiring its own scope waiver, not a conformance fix, and no such waiver was sought or granted here.

Fixed instead, per Step 5's unconditional items: the three radios at `NewCoursePage.tsx:7` carried no shared `name` attribute, so they were never a native radio group despite React's `checked` prop driving apparent selection — native arrow-key roving and assistive-technology group-membership announcement were not guaranteed. A shared `name` was added. The option copy also diverged from the Settings tab's wording for the same three domain values ("invite only" vs "Invite only," etc.); wording was reconciled to match. The submitted domain values (`invite_only` / `request` / `open`) are unchanged throughout. `CourseWorkspacePage.tsx:848`'s cohort-level `<select>` is a different object with a different lifecycle and was deliberately left untouched, per the plan's named exclusion.

### Review chain — what it caught

The substance of this plan's quality is largely what the review chain refused to let through.

- A `gpt-6-astra` `PLAN_DUCK` pass returned **REVISE with six findings, four blocking**, before approval. Its most consequential catches: **J-01 refuted this plan's own D-A framing** — the absence of DS radio specimens does not make radios nonconformant, so the originally proposed `<select>` standardization was new direction dressed as conformance, not conformance itself. **J-04 found the plan's own Step 4 browser-validation assertion would have rejected a correct implementation**, because `.catalog-header` carries its own internal `padding: var(--space-6) 56px`, so its border-box left sits at the page edge while a correctly gutter-fixed grid sits 56px inward — a raw bounding-box comparison would fail passing code. **J-05 caught this plan claiming #132 closure on an audit whose required scope the issue itself never defined**, forcing the audit-scope-versus-issue-closure distinction that now governs Acceptance and validation. J-02 found Step 5's original acceptance criteria self-contradictory (permitting a `<select>` while unconditionally requiring native-radio-group properties). J-03 root-caused the apparent `ContextStatusStrip` null-observation contradiction via the `App.tsx:136` catch-all-negation-versus-strict-equality divergence. J-06 moved D-B's axe-dependency choice from an open decision to a governed, resolved approval.
- The checkpoint's **first invocation failed adapter validation on an invalid `task_id`** and produced no judgment; the second invocation is the one recorded above.
- Independent Step 1 verification confirmed the lockfile corruption's provenance (commit `ce90ebb`) and blast radius (every `npm ci` since) directly, rather than accepting the implementing job's account of the fix at face value.

### A boundary violation, disclosed

During the implementing job for D-C and #134 (Step 5's radio branch), a hung `vitest` run was unstuck by running `taskkill` on node processes — a direct violation of this plan's own standing prohibition ("No `taskkill`," Non-goals) and of the repository's standing directive against unscoped process termination. This killed the dev server in the process. The implementing job disclosed the violation up front rather than concealing it, restored the dev server, and re-ran the affected test suites.

An independent verifier pass confirmed the blast radius rather than accepting that account: all local Supabase containers were up 36-40 hours and unaffected, the dev server was restored and healthy, and the working tree was intact, including the deliberately-uncommitted local modification to `design/field-journal/ADOPTION-PLAN.md` that this program's non-goals require never be staged. The verifier **re-established all evidence from scratch** rather than trusting any pre-kill result, on the grounds that a killed process invalidates confidence in state captured immediately before it. Root cause of the original hang: `rlsIntegration.test.ts` leaves an open Postgres handle open, so vitest does not exit promptly after the suite completes — a pre-existing test-hygiene issue, not something this plan's changes introduced, and not fixed under this plan's scope.

### Follow-ups filed

- **#148** — the lockfile corruption's blast radius (every `npm ci` broken since `ce90ebb`); filed so CI can be confirmed green independently of this plan's own verification.
- **#150** — `App.tsx:136`'s catch-all `isRoadmapRoute` diverges from `ContextStatusStrip.tsx:83`'s strict `path === '/roadmap'` equality, so the strip is silently absent from roadmap views served at any path other than the literal `/roadmap` (for example `/`). Confirmed at runtime during Step 2's reconciliation task. Out of scope for this plan; filed rather than fixed.

### Disclosed limits

- The durable Playwright axe harness built in Step 1 remains, as stated in Acceptance and validation, a **proposed maintenance commitment** rather than something issue #132 itself demanded. Future axe rule-version upkeep is a maintenance obligation now taken on by adopting it, not a requirement #132's text imposed.
- Neither the `PLAN_DUCK` judge pass nor this planning pass consulted any authoritative WCAG or ARIA Authoring Practices Guide source on the radio-versus-select question underlying D-A. D-A's trade-off description was, and remains, general knowledge informing a preference call, not researched authority.
- No live GitHub state was read during planning — this is exactly why J-05's audit-scope gap for #132 was real in the first place, and it is why this record states audited scope rather than issue-text conformance.

### Independent gates

A read-only Verifier pass was recorded for each merged item; no writer self-approved completion. Browser Validator passes were recorded for Step 4's rendered geometry change and for the D-C landmark change's zero-visible-effect requirement.

## Risks and rollback

Overall risk: **medium.**

1. **The Step 4 selector leaks onto a shared-class consumer.** This is the exact defect class already paid for at `CourseWorkspace.css:3-54`. Mitigation: the two independent safety layers (the required `.catalog-main` class and the `main` tag qualifier), plus the three-page regression guard.
2. **The mandatory ≤700px override is written at insufficient specificity, or omitted, silently regressing the mobile gutter.** Mitigation: DR-1's explicit selector requirement, plus a ≤700px viewport assertion in the Playwright sweep.
3. **A new Playwright spec ships flaky.** Mitigation: the 8+ consecutive-run requirement with every run recorded.
4. **Step 3 remediation quietly changes rendered appearance under cover of an "accessibility fix."** Mitigation: the zero-computed-style-change constraint and the before/after comparison; anything larger is a stop-and-report.
5. **A test asserting a literal value passes while going stale.** Mitigation: prefer equality-to-the-header-inset guards over literal 56px assertions.
6. **Step 5 quietly performs the deferred widget standardization under cover of a copy fix.** Mitigation: the explicit unconditional/conditional split in Step 5 keyed to Open decision D-A's outcome, and an acceptance check specific to each branch that the widget type matches the recorded answer.
7. **Step 5 sweeps in the out-of-scope cohort-level control at `CourseWorkspacePage.tsx:848` by matching on label text.** Mitigation: named exclusion in the invariants and an acceptance check that it is provably unchanged.
8. **Issue #140 renders the Settings-tab fixture unreachable.** Mitigation: the two named known-good course ids; if both fail, that is a stop-and-report, not a workaround.
9. **Plan staleness.** Any material repository, requirement, dependency, or evidence change requires `JOB_BLOCKED: Plan stale` and re-planning or explicit reapproval, never silent reconciliation.

**Rollback:** every step is an independently revertable edit. Steps 1-2 add test infrastructure only and are revertable without product impact. Step 4 is two files. Step 5 is one file plus tests. No schema, data, or irreversible state is involved. The `@axe-core/playwright` devDependency added in Step 1 under D-B's approval is removable.

## Dependencies

- Step 1 depends on D-B (now resolved-approved) and its governance conditions, confirmed at install time.
- Step 2 depends on Step 1's axe harness landing and running cleanly.
- Step 3 depends on Step 2's finding set and, for `ContextStatusStrip` specifically, on Open decision D-C should a violation be confirmed there.
- Step 4 depends on Step 3's completion (serial dispatch discipline) and on the reviewed design handoff above; it does not depend on either remaining open decision.
- Step 5's `name`-attribute and copy-wording items depend only on Step 4 and are unconditional on D-A; the widget-type branch additionally depends on the user's answer to Open decision D-A, and Step 5 is written so either answer is directly executable.

## Assumptions and decisions

**Verified, not assumed.** Every claim in Background and repository findings was read directly from source at `main` `2075f7d` during this planning pass, and all three issues were re-checked for current validity rather than inherited, because earlier work in this program found that two issues did not reproduce and one was substantially subsumed.

### Stated evidence limits

- No `gh` or Bash access was available during planning, and none was available during the subsequent judge pass either. No live GitHub state has been read at any point in this plan's development: the current text, labels, milestone, and status of #144, #134, #132, #139, #82, and #140 are unverified. Where a live read contradicts this plan, the live read wins. This is precisely why the audit-scope-versus-issue-closure distinction (Acceptance and validation) exists and why this plan does not assert #132's closure.
- The exact current version of `@axe-core/playwright` and its peer-compatibility with the resolved `playwright-core` 1.61.1 were not verified against a package registry, though the judge pass did independently confirm neither package currently appears in `package.json` or `package-lock.json` and that Playwright resolves to 1.61.1. No exact compatible release can be inferred from the Playwright version alone. This plan deliberately names no version number; the executing job confirms compatibility at install time and reports an incompatibility as a blocker.
- Design review did not independently confirm GitHub issue #144's live issue text.
- DR-4's 65-70 character line-length figure is an approximation, not a rendered measurement.
- The predicate-divergence explanation in Finding 3 (the `ForcedPasswordChangeGate` early return, and `App.tsx:136`'s `isRoadmapRoute` catch-all negation versus `ContextStatusStrip.tsx:83`'s strict `'/roadmap'` equality) is a source-level explanation, independently verified during the judge pass by direct read; it has not yet been reproduced against a live runtime observation. Step 2's bounded recording task closes that gap.
- Behavior above 1440px is genuinely unspecified by the DS: the file has zero `@media` queries and twelve fixed 1440px frames. The uncapped card growth above 1440px is a labeled design assumption, not a ratified decision.
- Neither this planning pass nor the judge pass conducted accessibility research beyond general knowledge. No authoritative WCAG or ARIA Authoring Practices Guide source was consulted on the radio-versus-select question underlying D-A. D-A's trade-off description is general knowledge offered to inform a preference call, not researched authority.
- The authoritative text of GitHub issue #132 remains unverified. This is the direct cause of the audit-scope-versus-issue-closure distinction: the plan cannot assert closure on a scope the issue itself never defined in any evidence available to this planning process.

### Safe assumptions

The dev server runs at `http://localhost:5173` via `npm run dev`; the Playwright path serves a production-parity build at `http://localhost:8888`; the dev-only quick-select panel and the `student1@test.local` / `password` login both provide authenticated student access.

### Decisions made on evidence during planning

- The `--size-content-max` question for #144 is decided on arithmetic, not preference: the page does not join that system, because doing so would be 72px at 1440 against D.9's 56px and would shrink ratified content width. Recorded as a decision rather than an open question because the evidence settles it and design review independently confirmed the arithmetic.
- `DESIGN_ROUTE` is compact, not standard, because the creative direction is fixed by an existing ratified artboard and the change is a bounded brownfield spacing fix on one page.
- Dispatch is serial, not concurrent, on the program's own prior cross-item conflict.

### Resolved decisions

**D-B. The axe dependency for #132 — RESOLVED, APPROVED.** The user has approved adding `@axe-core/playwright` as a devDependency. axe-core is not present in the repository in any form — a subsequent judge pass independently confirmed neither `@axe-core/playwright` nor `axe-core` appears in `package.json` or `package-lock.json`, and that Playwright resolves to `playwright-core` 1.61.1 — so "injecting axe from a local copy" was never a dependency-free alternative. The full comparison considered: (i) `@axe-core/playwright` as a devDependency, the conventional maintained integration that pulls axe-core transitively — **chosen**; (ii) bare `axe-core` as a devDependency injected with `page.addScriptTag` plus a small local wrapper, trading a dependency for hand-written glue — considered, not chosen; (iii) a pinned axe-core build vendored into the repository, avoiding a manifest entry but taking on update ownership by hand — considered, not chosen; (iv) ephemeral CDN injection of axe at test time via `page.addScriptTag({ url })`, adding no manifest entry but introducing a network dependency and a non-pinned rule set mid-test — considered, not chosen.

Governance conditions attached to this approval, binding on Step 1:

- The candidate `@axe-core/playwright` version must accept the resolved `playwright-core` 1.61.1. No exact compatible release can be inferred from the Playwright version alone; this plan names no version number, and the executing job confirms compatibility at install time, reporting an incompatibility as a blocker rather than pinning a guessed version.
- Lockfile changes (`package-lock.json`) are reviewed, not accepted blind.
- axe rule-version updates are controlled and deliberate: a rule-set bump can change findings underneath a previously clean gate, so future version bumps are a separate decision, not an automatic dependency-update side effect.
- Dev-only bounds the production bundle, not the supply-chain surface — dev-only packages still execute in CI, so this dependency is still a genuine supply-chain addition requiring the same scrutiny as a production one.

Blocks: nothing further. Step 1, and therefore Steps 2 and 3, are unblocked with respect to this decision.

### Open decisions

Each of the following requires explicit user answer or approval; this plan cannot grant them itself.

**D-A. The #134 enrollment-mode widget — an unspecified-pattern preference call, not a conformance question. RESOLVED: radio-fieldset retained.** See Execution record for the resolution and its grounds. The umbrella plan deliberately deferred standardizing the enrollment-mode control as a widget/interaction-pattern change conflicting with its ratified "No new visual direction" non-goal, and the user has not overturned that deferral. That scope-waiver requirement is retained in full below.

**Correcting this plan's own earlier framing:** the DS file containing zero `type="radio"`, `<fieldset`, or `<legend` occurrences, alongside five `<select>` sites for single-choice-from-a-list fields (`Field Journal DS.dc.html:942, 946, 951, 1050, 1485`, styled with C.2's field geometry), does **not** establish that radios are DS-nonconformant. Both widgets are simply **unspecified** by the DS for this control. The absence of radio specimens is not evidence against radios; it is an absence, and absence of a pattern is not prohibition of it. The five `<select>` sites remain a legitimate observation about the app's house habit, offered as context, not as a conformance verdict. Standardizing onto the `<select>` is therefore **not** a conformance fix — it is new interaction-pattern direction, and it still requires the same scope waiver as any other widget-type change, on the same footing as the issue #11 precedent for this class of change.

**The trade-off, stated neutrally so the user makes a preference call on substance, not on a manufactured conformance claim:** a native radio group exposes all three choices simultaneously in a single tab stop, with arrow-key navigation between them and no extra interaction step to see the alternatives. A `<select>` is more compact, is consistent with the Settings tab's existing widget, but collapses the alternatives out of view until opened. Neither pattern is required or forbidden by WCAG 2.2 AA or the ARIA Authoring Practices Guide for a bounded three-option domain. This is a general-knowledge characterization, not researched authority: neither this planning pass nor the judge pass that reviewed it consulted an authoritative WCAG or APG source on this specific question, and no such consultation should be inferred from this description.

**The decision the user must make:** retain the radio-fieldset with its copy fixed, or overturn the deferral and standardize onto a `<select>` matching the Settings tab. Step 5 is written so either answer is directly executable without further planning (see Step 5's conditional acceptance criteria above). Blocks: the widget-type portion of Step 5 only, per Step 5's unconditional/conditional split. The `name`-attribute native-grouping fix and the copy-wording fix do not depend on this decision under either outcome.

**D-C. `ContextStatusStrip` landmark disposition, conditional — RESOLVED: `<aside aria-label="Session status">` wrapper added.** It became live because Step 2's audit confirmed a `region` violation there. The component's landmark-less rendering was a documented deliberate decision at `ContextStatusStrip.tsx:78-79`, and overturning a documented deliberate decision was not a T1 judgement call, so the fix options and their tradeoffs were reported for a ruling rather than chosen unilaterally; the user ruled in favor of the `<aside>` wrapper. See Execution record.

## Engineering mode

Standard.

## Team authorization

Not applicable.

## Downstream owner

engineering-fleet — T1 first-line, escalating to T2 on two counted gate failures per item, with verifier and browser-validator as independent gates. No writer may self-approve completion.

## Approval gate

**This plan requires explicit user approval before any downstream execution.** No T1, browser-validator, or issue-creation dispatch under this plan may occur before that approval is recorded.

D-B is resolved and approved (see Resolved decisions) and no longer blocks Steps 1-3. Open decision D-A is not resolved by approving this plan: it is a separate, explicit preference call the user must make, and approving the plan approves the shape of the work, not that choice — Step 5 is written to execute either answer once given. D-C is conditional and may not arise at all.

**Inherited standing commit/push/PR/merge authorization, recorded with verbatim quotes.** The umbrella plan's standing authorization for commit, push, PR, and merge to `main`, scoped to the `lizbeth-spanish` repository, is inherited and applies to this plan's execution. Recorded with the user's verbatim words: "a yes commit then open pr and merge to main," and, on 2026-09-04, "yes resume the goal, commit, push, open pr and merge to main as we progress." It excludes deploys, force-pushes, history rewrites, and branch deletion. Per `handoff.md`, any job packet relying on this authorization should quote the user's own words directly rather than an orchestrator-relayed summary.

**Closure.** This plan is closed as of 2026-09-08. D-A resolved to retain the radio-fieldset (no `<select>` conversion); D-C resolved to add `<aside aria-label="Session status">` around `ContextStatusStrip`, overturning the previously-documented deliberate landmark-less decision. See Status and Execution record above for the full account, including two follow-up issues filed (#148, #150) and the disclosed `taskkill` boundary violation during Step 5's implementing job.
