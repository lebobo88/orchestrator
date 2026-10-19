# Lizbeth Spanish — Re-validate Issues #37 (Login / Sign in) and #43 (Brand + Catalog) Against the Shipped Screens

**Status: Approved for engineering under standing forward authorization. This specific plan, this session. Dated 2026-09-02.** See "Approval basis" immediately below for the basis and provenance of this approval.

## Approval basis

This plan was routed to engineering under the orchestrator's application of the user's standing forward authorization recorded in `docs/plans/lizbeth-spanish-fjds-issue31-33-revalidation.md` Section 16, not a fresh user-verified per-plan "approved"-style reply. The record below is an orchestrator-applied inference and follows the same provenance discipline as that section.

- **Standing authorization quoted (verbatim, as relayed by the orchestrator):** "didn't i tell you to stop asking me for approval? i told you to keep going until all the gh issues are finished" and "don't stop until all the DS gh issues are implemented and browser validated."
- **Forward authorization basis (`docs/plans/lizbeth-spanish-fjds-issue31-33-revalidation.md` Section 16, "Additional forward authorization"):** that grant covers backlog items 3-7 of the roadmap in `docs/plans/lizbeth-spanish-fjds-token-pipeline-reconciliation.md`, which includes item 4 (the unauthenticated routes #37/#43 addressed by this plan). It is explicitly bounded: it does not waive presenting each subsequent plan's summary to the user before execution begins, but it does waive the requirement to wait for a separate affirmative "approved" reply once that summary has been presented, absent a user objection.
- **This plan's summary presentation, satisfying that bound:** the orchestrator presented this plan's compact summary to the user in this session. Headline as relayed: issues #37 and #43 are overwhelmingly correctly implemented; one genuine defect was found (D1) — `BrandDesignPage`'s `.owner-settings-page--brand` container renders the wrong border and shadow because no such CSS rule exists anywhere in the codebase, so the styling falls through uncontested to the legacy shared `App.css` selector list, the same systemic pattern already tracked under issue #66 but arising from absence of a rule rather than a cascade-priority tie; the fix is approximately 10 lines in one file (`src/pages/OwnerSettingsPage.css`), wins purely by CSS specificity, and leaves `src/App.css` untouched; the independent design review required one revision, adding a forced-colors accessibility guard, and is now `PASS`. No user objection was raised following that presentation.
- **Application:** the orchestrator applied the standing forward authorization, satisfied by the summary presentation above, to route this plan — backlog item 4 of the Field Journal Design System revalidation sequence established in `docs/plans/lizbeth-spanish-fjds-issue31-33-revalidation.md` Section 16, covering the unauthenticated/anonymous route surfaces owned by issues #37 and #43 — to engineering without requiring a further live per-plan "approved"-style reply.
- **Approval provenance label:** this basis reached Scribe entirely through the orchestrator's account of the session. Scribe has not independently observed the quoted user statements, the summary presentation, the live `gh` fetches, or the design review beyond what is recorded elsewhere in this document. It is recorded here as an orchestrator-applied inference under standing forward authorization, NOT as a Scribe-verified per-document fresh user approval.
- **`PLAN_DUCK` checkpoint: eligible, not run, by orchestrator determination.** This plan changes one CSS file (~10 lines) plus one test file, has strong deterministic gates, and carries a passed independent design review. Deterministic failures always dominate any judge finding; the orchestrator assessed this scope as below the bar this engagement reserves for judge checkpoints.
- **Date:** 2026-09-02.

---

Plan ID: `lizbeth-spanish-issue37-43-revalidation`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: `engineering-fleet`
Design route: compact (`design-generalist`, `design-reviewer`; prototype forbidden; model tier Sonnet; existing-system mode: preserve)

## Outcome and audience

This is a **validation-and-remediation plan, not a rebuild.** It re-validates GitHub issues #37 ("Screen: Login / Sign in," §D.1 + §E.1) and #43 ("Screen: Brand + Catalog," §D.8 + §D.9) — backlog item 4 of the Field Journal Design System revalidation sequence, covering the unauthenticated/anonymous route surfaces — against the screens as actually shipped.

The headline result of this investigation: **both issues are overwhelmingly correctly implemented.** The investigation's value is threefold, and each part is recorded in full below rather than folded into a generic "all clear":

1. **One confirmed defect** (D1) — a real, narrow container-styling gap on the brand settings page, remediated by this plan.
2. **Several evidence-backed negative findings** (N1-N5) that close off suspected failure modes rather than confirming them. These are a primary deliverable of this plan, not incidental notes.
3. **An honest statement of what Planner could not verify** — Planner has no Bash tool and could not run the test suite, confirm the live `gh` issue state, or render either screen. Those checks are ordered as the first step of engineering work below.

Audience: the T1/T2 engineer implementing the remediation, then Verifier and Browser Validator gating it.

## Scope

**In scope** — exactly one confirmed defect and its validation:

1. **Defect D1.** Add the §D.8 container rule plus its forced-colors guard to `src/pages/OwnerSettingsPage.css`, per the reviewed design handoff in "Design route and handoff" below.
2. **A TDD-first regression guard test**, in the house style already established by the CASCADE-COLLISION REGRESSION GUARD in `src/__tests__/fjdsAuthenticatedScreensRemediation.test.ts`, asserting the compound-selector container rule exists and that `.owner-settings-page--brand` is not left to inherit `App.css:706`'s legacy print treatment.
3. **Full deterministic gate re-run** plus Verifier plus Browser Validator for both #37 and #43 surfaces.

**Non-goals (binding — a writer must return `JOB_BLOCKED` rather than exceed these):**

- No edit to `src/App.css`. The fix wins by specificity, never by editing the legacy shared list.
- No removal of `.owner-settings-page` (or any selector) from `App.css:706`'s shared list — that would restyle `OwnerSettingsPage.tsx` and `BusinessSettingsPage.tsx`, violating issue #43's own approved non-goal.
- No forced-colors coverage extended to the non-brand owner screens (recorded as backlog only, see B2 below).
- No re-implementation of #37 or #43. Both are confirmed conformant.
- No cleanup of the two dead selectors identified below (recorded as backlog only, see B1 below).
- No edit to `lizbeth_spanish\atelier.config.json`. No Docker or Supabase change. No `taskkill` at any point.

## Verified repository findings

Issue mapping confirmed from `design/field-journal/ADOPTION-PLAN.md:226` and `:232`: row 7 "Screen: Login / Sign in" maps to §D.1 + §E.1, files `LoginForm.tsx/.css` and `ForcedPasswordChangeGate.*`; row 13 "Screen: Brand + Catalog" maps to §D.8 + §D.9, files `BrandDesignPage.tsx` and `PublicCatalogPage.tsx`. This matches the mapping assumed at the start of this pass; nothing was assumed without independent confirmation.

### Confirmed defect D1

**Severity: medium** (visual conformance only; no functional or accessibility failure in default rendering, but a real forced-colors gap).

The §D.8 brand page container renders the wrong treatment.

- Reference §D.8 container, `design/field-journal/Field Journal DS.dc.html:1147`, verbatim: `background: #fdfcf9; border: 3px solid #1a1512; box-shadow: 10px 10px 0 0 #1a1512; padding: 40px 44px;`
- `src/pages/BrandDesignPage.tsx:44` renders root `<div className="owner-settings-page owner-settings-page--brand">`.
- `src/pages/OwnerSettingsPage.css:9` declares `.owner-settings-page` with only `max-width: 40rem; margin: 0 auto;`.
- There is **no** `.owner-settings-page--brand { }` root rule anywhere in `src/**/*.css`. Every existing `--brand` rule is descendant-scoped.
- The container's actual border/shadow therefore comes uncontested from the legacy shared list at `src/App.css:706`: `.login-form-container, .demo-section, .feedback-form, .admin-shell, .owner-settings-page, .admin-students-page { border-radius: var(--radius-square); border: var(--border-width-strong) solid var(--color-ink-800); box-shadow: var(--shadow-print); }`
- Resolved actual vs. specified: a 2px `#3d3530` border versus the specified 3px `#1a1512`; a `.3rem .3rem 0rem 0rem #a07e48` (an amber-tinted) shadow versus the specified hard black offset shadow; no paper-50 ground; no 40/44px padding.

**Significance.** This is a fifth instance of the systemic legacy-shared-selector pattern that backlog item 3 (`docs/plans/lizbeth-spanish-fjds-issue31-33-revalidation.md`'s sibling backlog sequence) identified: `.band-roadmap` and `.lesson-content-chunk` were already fixed, and `.week-card`, `.feedback-form`, `.admin-students-roster`, and `.admin-students-detail` were filed as issue #66. D1 differs in mechanism from those four: they are cascade-tie **collisions**, where a component rule exists but loses to `App.css` on import order; D1 is an **absence** — no component rule was ever written, so the legacy rule applies uncontested. D1 is recorded against issue #66's family, not opened as a standalone issue.

### Evidence-backed negative findings

Each of the following closes a suspected failure mode with direct evidence. Recording these explicitly is a primary deliverable of this plan.

**N1 — the App.css cascade-collision sweep found no collision affecting #37 or #43 beyond D1.** `.login-form-container` (`App.css:706`) has zero occurrences across `src/**/*.tsx`: issue #37 renamed the card to `.auth-sheet-card`, so the shared rule no longer matches it, meaning the documented "escape mechanism" genuinely works. `.gate-content` appears only in `App.css:779`'s list, which sets `border-radius` only, so it cannot override `ForcedPasswordChangeGate.css:25-36`'s border/box-shadow. The second `App.css` list at `:782-787` (the one that does set border/box-shadow) contains no selector owned by #37 or #43. `.course-workspace` and every `.catalog-*` class have zero occurrences anywhere in `App.css`.

**N2 — the token layer for #37/#43 is genuinely sound.** Every token these issues introduced is correctly dual-written in the DTCG source and matches the compiler output: `.atelier/tokens/field-workbook.tokens.json:130-133` (heroLg 5.5rem, heroSm 2.875rem, signinLg 2.75rem, signinSm 2rem), `:195` (sheet 8px), `:196` (brass 5px), `:199` (brassPress 7px), `:200` (brassNone), `:122` (logoMark), `:127` (buttonLabel), `:128` (labelSmall), `:161` (controlHeightSubmit 54px) — each matching `src/tokens/field-workbook.generated.css:99, 100, 105, 106, 132, 124, 126, 125, 103, 91, 102, 135`. The hypothesis that #37/#43's hand-added tokens were wiped by the #61 regeneration is disproven.

**N3 — issue #37 is fully implemented and already post-remediated.** `src/App.tsx:254-318` renders `.auth-split-layout`/`.auth-brand-panel` across both the `sessionError` and `!session` branches; `LoginForm.tsx:78` renders `.auth-sheet-card`; the ratified brass-500-to-brass-300 AA correction is present and annotated at `LoginForm.css:100-105, 113-116, 176-177`; forced-colors blocks are present at `LoginForm.css:183-211` and `:363-371`; a prior browser-validator remediation cycle's WCAG 1.4.10 reflow fix is documented at `LoginForm.css:221-247`.

**N4 — issue #43's catalog half (§D.9) is fully conformant.** `PublicCatalogPage.css` implements every binding invariant: card `border-width-rule`/`ink-1000`/`shadow-sheet` (`:111-118`); the three band tokens (`:125-127`); grid `repeat(3,minmax(0,1fr))` reflowing to `minmax(0,1fr)` (`:107`, `:239-241`); and, critically, the design-review F3 gutter fix at `:256-260`, scoped to the `.catalog-header`/`.catalog-footer` classes rather than bare tag selectors, honoring the reviewer's non-blocking robustness note from the #43 plan. `PublicCatalogPage.tsx:88-105` implements the header/footer as landmark siblings of `<main>`, preserving the locked `<main>` child order, and `:50-56, 209-215` carry the J-43-01 fix that prevents the empty state from flashing before the fetch resolves.

**N5 — band-label contrast holds against the three band tokens.** paper-50 on band-beginner (brass.600): 5.02:1; on band-intermediate (terracotta.600): 4.688:1; on band-advanced (ink.slate): 6.72:1. All three clear AA, with intermediate the tight floor already flagged and accepted in #43's approved plan.

### Backlog-only observations

Recorded, not fixed, in this plan.

- **B1 — two dead selectors.** `.login-form-container` (`App.css:706`) and `.owner-settings-form` (`App.css:779`) both have zero occurrences across `src/**/*.tsx`. Harmless today, but exactly the legacy debris that produced the #66 defect family. Recommendation: fold into issue #66.
- **B2 — latent forced-colors gap on the sibling owner screens.** `src/pages/OwnerSettingsPage.css` has zero `@media (forced-colors: active)` blocks file-wide, and `src/App.css` has none either, so `OwnerSettingsPage.tsx` and `BusinessSettingsPage.tsx` render `App.css:706`'s border/shadow with no forced-colors guard, unlike essentially every other sheet surface in the app. Surfaced by the design reviewer. Out of scope here; recommendation: open a new issue.

## Research evidence and its limits

No external or current-evidence question was material; every finding above is a local repository read, verified during this planning pass. **Recorded limit:** Planner has no Bash tool, so it could **not** run the test suite, could **not** run `gh` to confirm the live open/closed state of issues #37 and #43, and could **not** render either screen. Those checks are the implementing writer's and validators' responsibility and are ordered as the first step of engineering work below. No test baseline is claimed by this plan.

## Design route and handoff

```
DESIGN_ROUTE
profile: compact
reasons: one bounded brownfield container-level defect on an existing screen; target values already fixed by a ratified artboard and shipped tokens; no new screen, flow, or multi-state component
agents_required: design-generalist, design-reviewer
prototype: forbidden
model_tier: sonnet
existing_system_mode: preserve
END_DESIGN_ROUTE
```

The reviewed `DESIGN_HANDOFF`'s load-bearing content, reproduced below:

**Add one base rule** to `src/pages/OwnerSettingsPage.css`, inside the existing "Issue #43 (§D.8)" bounded-override section that begins at line 146:

```css
.owner-settings-page.owner-settings-page--brand {
  background: var(--color-paper-50);
  border: var(--border-width-rule) solid var(--color-ink-1000);
  box-shadow: var(--shadow-sheet);
  padding: var(--space-10) calc(var(--space-10) + var(--space-1));
  width: 100%;
  box-sizing: border-box;
}
```

**Add its forced-colors guard** in the same section:

```css
@media (forced-colors: active) {
  .owner-settings-page.owner-settings-page--brand {
    box-shadow: none;
    border-color: ButtonText;
  }
}
```

**Add inside the existing `@media (max-width: 700px)` block** at `OwnerSettingsPage.css:141-144`:

```css
.owner-settings-page.owner-settings-page--brand {
  padding: var(--space-6);
}
```

**The compound selector is load-bearing and must not be simplified.** `.owner-settings-page--brand` alone has specificity (0,1,0), which merely ties `App.css:706`'s `.owner-settings-page` (also (0,1,0)) and would then be decided by import order — the exact fragility that caused the #66 defect family. The compound form `.owner-settings-page.owner-settings-page--brand` is (0,2,0) and wins unconditionally.

`border-radius` is deliberately **not** re-declared: `App.css:706` already supplies `var(--radius-square)` (0px), which matches the reference.

No new token is introduced. The 44px horizontal padding is an exact match composed from existing primitives: `calc(var(--space-10) + var(--space-1))` = 2.5rem + 0.25rem = 2.75rem = 44px.

**Disclosed normalization (not silent).** The reference's literal `10px 10px 0 0 #1a1512` shadow is snapped down to the shipped `--shadow-sheet` (8px). This is justified by an already-ratified precedent: §D.9's own artboard at `Field Journal DS.dc.html:1184` specifies the identical 10px literal, and shipped `PublicCatalogPage.css:114` already normalizes it to `--shadow-sheet`. No single-use token is minted for this change.

**Disclosed assumption.** The `<=700px` padding value `var(--space-6)` is a design judgment; no mobile §D.8 artboard exists (reference section E contains only E.1-E.6, none of which are the brand or catalog screens).

**Contrast on the new paper-50 ground:** ink-1000 approximately 17.7:1; ink-700 approximately 8.6:1. Both clear AA and AAA.

**Forced-colors shape.** Deliberately matches the `AdminStudentsPage.css:484-497` / `OwnerDashboardPage.css:113-120` precedent family (`box-shadow: none; border-color: ButtonText;`, no `forced-color-adjust`), not the WeekCard/SegmentLedger/Control family, which adds `forced-color-adjust: auto`. That second family exists for gradient fills, progress/ledger visualizations, and interactive control chrome, none of which apply to a plain bordered container.

**Engineering invariants.**

- `src/App.css` is never edited, and no selector is removed from its shared list.
- The compound selector is preserved exactly in both the base rule and the forced-colors rule.
- Every value is a bare token `var()`, a `calc()` over token `var()`s, the literal `none`, or the `ButtonText` system-color keyword.
- `OwnerSettingsPage.tsx` and `BusinessSettingsPage.tsx` must render pixel-identical to today in both standard and forced-colors rendering.
- No native dialogs are introduced.

**Permitted variation.** Placement anywhere within the §D.8 section; any equivalent `calc()` composition resolving from existing tokens only; free-form comments.

## Design review

`DESIGN_REVIEW_RESULT verdict: PASS` on revision 1 from an independent design-reviewer, after one evidence-backed `NEEDS_REVISION` cycle carrying a single finding, accepted in full and closed:

- **DR-A11Y (medium)** — missing forced-colors guard against a test-enforced house convention. Closed by adding the forced-colors rule reproduced above.

On re-review the reviewer independently confirmed:

- `ButtonText` is invisible to the token-fallback-audit lint's hex regex `/#[0-9a-fA-F]{3,8}\b/g` and to its `var()` regex.
- `box-shadow: none` short-circuits the non-zero-blur check at `tokenFallbackAuditLint.test.ts:321` by construction.
- The compound selector cannot reach `OwnerSettingsPage.tsx:115, 176` or `BusinessSettingsPage.tsx:23, 24, 38`, which render only the bare `.owner-settings-page` class.
- The forced-colors shape correctly matches the plain-container precedent family, not the gradient/interactive-control family.

In the first review cycle, the reviewer also independently verified the specificity arithmetic, every token value, the 44px `calc()`, the §D.9 shadow-normalization precedent, the absence of any other container rule, the absence of a property collision in the 700px block, and recomputed both contrast ratios.

## Judge route

`PLAN_DUCK` eligible at the orchestrator's discretion. Not mandatory: this is a single-file, approximately 10-line CSS change with strong deterministic gates and a passed independent design review. Deterministic failures always dominate any judge finding. Standard call caps and shadow policy from `docs/JUDGE-CONTRACT.md` apply.

## Ordered work

Owner: T1 engineer, escalating to T2 on two counted gate failures.

1. **Baseline first, blocking, no edits.** Planner could not run tests. Run the full suite plus `npx tsc`. Record verbatim pass/fail counts. Also run `gh issue view 37` and `gh issue view 43` to confirm their live state and re-read their acceptance criteria for staleness. If anything is already red, return `JOB_BLOCKED` rather than absorbing it into this pass.
2. **TDD-first.** Add the failing regression guard test described in "Scope" item 2, in the house style of `fjdsAuthenticatedScreensRemediation.test.ts`'s CASCADE-COLLISION REGRESSION GUARD, before the CSS edit. It must fail for the right reason first: because the compound-selector rule does not yet exist.
3. **Apply the three CSS rules** exactly as specified in "Design route and handoff" above.
4. **Re-run** the full suite, the token/lint tests, `npx tsc`, and a production build. Everything previously green stays green.
5. **Deterministic source scans:** zero native `alert`/`confirm`/`prompt`/`window.*` forms/`beforeunload` across `src/`; `src/App.css` byte-unchanged; no raw hex outside `src/tokens/`; no undefined `var()`; no non-zero `border-radius`; no non-zero-blur `box-shadow`.
6. **File the backlog items.** Add B1 (the two dead selectors) to issue #66. Open a new issue for B2 (the sibling owner screens' latent forced-colors gap). Record D1 against the #66 family in the issue log. Per standing directive, log all work via `gh` issues.
7. **Independent Verifier pass.**
8. **Browser Validator pass**, per the brief below.

## Interfaces and data

No API, schema, migration, or data-contract change. CSS-only plus one test file.

## Acceptance and validation

- Full suite green; `npx tsc` clean; lint clean; production build clean.
- `tokenFallbackAuditLint.test.ts` and `fieldJournalTokens.test.ts` stay green.
- The new regression guard test passes and genuinely fails when the rule is removed.
- `src/App.css` provably byte-unchanged.
- `OwnerSettingsPage.tsx` and `BusinessSettingsPage.tsx` visually unchanged in both standard and forced-colors rendering — this is the primary regression check.
- The §D.8 container renders paper-50 ground, a 3px ink-1000 border, a hard black offset shadow with no amber tint, and reference-proportioned padding.
- Independent Verifier pass, then Browser Validator pass. T1 cannot self-approve.

## Binding engineering invariants

- **The compound selector `.owner-settings-page.owner-settings-page--brand` is never simplified** to a single class in either the base rule or the forced-colors rule; doing so reintroduces the import-order fragility that caused the #66 defect family.
- **`src/App.css` is never edited**, and no selector is removed from its shared list at `:706` — that list is also consumed by `OwnerSettingsPage.tsx` and `BusinessSettingsPage.tsx`.
- **`border-radius` is not re-declared** in the new rule; `App.css:706` already supplies the correct 0px value.
- **Every new value is a bare token `var()`, a `calc()` over token `var()`s, the literal `none`, or the `ButtonText` system-color keyword.** No raw hex, no undefined `var()`, no non-zero `border-radius`, no non-zero-blur `box-shadow`.
- **No native browser dialogs** (`alert`, `confirm`, `prompt`, `window.*` forms, `beforeunload`) anywhere in either target file.

## Risks and rollback

| ID | Severity | Risk | Mitigation |
|----|----------|------|------------|
| R1 | Medium | No test baseline was established at planning time (Planner has no Bash tool) | Ordered-work step 1 is blocking; a red baseline returns `JOB_BLOCKED` |
| R2 | Medium | An engineer "simplifies" the compound selector to a single class, silently reintroducing the import-order fragility that caused the #66 defect family | Stated as a binding invariant, enforced by the step-2 regression guard test |
| R3 | Medium | An engineer "fixes the root cause" by editing `App.css:706`'s shared list, silently restyling `OwnerSettingsPage` and `BusinessSettingsPage` | Binding non-goal, plus a byte-unchanged scan on `App.css` |
| R4 | Low | The 10px-to-8px shadow snap is later "corrected" back toward the artboard by a reviewer comparing against the reference | Recorded prominently as a disclosed, precedented normalization matching shipped §D.9 |
| R5 | Low | The `<=700px` padding value is a design assumption with no artboard | Disclosed; browser validation measures it at 390px |

**Rollback.** A straight revert of one CSS file and one test file. No data, schema, or backend change.

## Assumptions and decisions

- **Planner decision:** D1 is remediated by specificity, never by editing the legacy shared list, preserving issue #43's own approved non-goal.
- **Planner decision:** #37 and #43 are not re-implemented. Both are confirmed conformant; a rebuild would be unjustified churn.
- **Planner decision:** B1 and B2 are recorded as backlog, not folded into this plan, to keep the change auditable and independently revertible.
- **Disclosed:** the `<=700px` padding value and the shadow normalization, both described above.
- **Approval:** proceeding under the user's recorded standing forward authorization for this established backlog sequence (`docs/plans/lizbeth-spanish-fjds-issue31-33-revalidation.md` Section 16), presented in summary form, then executed without waiting for a fresh reply. This provenance is labeled honestly as an orchestrator-applied inference under standing forward authorization, not a Scribe-verified per-document fresh user approval, exactly as the sibling plans do.

## Required approvals

This plan document's engineering-dispatch approval is recorded in "Approval basis" at the top of this document, under the orchestrator's application of the recorded standing forward authorization, satisfied by the compact-summary presentation recorded there. That record, not this section, is the operative approval statement. If the standing forward authorization is later withdrawn or found not to cover this issue, this plan reverts to requiring explicit per-document user approval before further T1/T2 work proceeds.

## Browser UI dialog policy

Required — browser-rendered React/Vite UI. Native `alert`, `confirm`, `prompt`, every `window.*` variant, and `beforeunload` are prohibited. This change is CSS-only and introduces none; both target screens use inline validation and passive/alert status text today and must continue to. Enforced by a deterministic source scan, not by assertion.

## Browser UI validation

**Launch/readiness:** reuse the dev server already running at `http://localhost:5173` per the standing directive; do not start a competing server; never `taskkill`. Ready when the base URL loads.

**Base URL:** `http://localhost:5173`

**Fixture/reset:** an owner session for §D.8 `/admin/brand-design`; a non-owner session for the permission-denied state; anonymous/no session for §D.9 `/courses` and for #37's `/`; stubbed `getCatalog` for the empty and error catalog states; a `force_password_change` user for the gate; a dev build for #37's quick-select journey. Reset browser state between journeys.

**Viewport profiles:** 1440x900 and 390x844, both mandatory for every journey.

**Journeys:**

1. **§D.8 brand form as owner** — confirm the corrected container: cream ground, approximately 3px dark border, hard black offset shadow with no amber tint, reference-proportioned padding; the preview block, the three fields with their per-field `ColorPreview`, and the save row all intact.
2. **Primary regression check** — `/admin/settings` (`OwnerSettingsPage`) and the `BusinessSettings` screen must be visually unchanged, still showing the legacy amber-shadow treatment.
3. **§D.8 at 390** — no horizontal scroll, padding visibly tightened, border and shadow still visible.
4. **Forced-colors emulation at both viewports on §D.8** — the decorative shadow disappears, the border stays visible from the system `ButtonText` color, nothing becomes illegible.
5. **§D.9 catalog** populated, empty, and fetch-error states at both viewports, confirming N4's implementation renders as specified and the 390 header/footer gutter measures approximately 374px content width.
6. **#37 login at `/`** at both viewports — confirm the split panel, the brass-300 contrast correction is still visible and not reverted to brass-500, and keyboard-only sign-in works with a visible focus ring at every stop.
7. **A no-native-dialog check** across every journey.

**Visible outcomes:** full-page screenshots of §D.8 before/after at both viewports, the two unchanged sibling owner screens, one forced-colors screenshot per viewport, and the §D.9 and #37 journeys at both viewports.

**Note on tooling.** Because `/courses` and `/` are genuinely unauthenticated routes, unlike #38-#42's authenticated routes, they are reachable by Atelier's own screenshot/baseline tooling. Use `mcp__atelier__baseline_update`/`visual_diff` for those two routes where it adds real signal. §D.8 is owner-gated (issue #43's own recorded scope correction) and so still requires the interactive Browser Validator. Interaction states, focus order, and forced-colors emulation require the interactive validator regardless of route.
