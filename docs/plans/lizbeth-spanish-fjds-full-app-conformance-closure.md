# Lizbeth Spanish — Full App Conformance Closure

## Status

**APPROVED.**

- **Approver:** the user (rob.hasselbach@gmail.com / lebobo88).
- **Date:** 2026-09-03.
- **Basis:** approved after a `PLAN_DUCK` cross-vendor judge pass (verdict REVISE, six major findings, advisory under shadow mode) and one spent remediation loop, plus a walkthrough of the D-1, D-3, and D-4 product decisions. The compact summary presented to the user covered: the overturned migration assumption (the token layer is already flipped, so this is conformance closure, not migration); the measured legacy universe (zero deprecated tokens in production `.tsx`, seven inline styles, all dynamic); the judge's highest-value catch (gate 9 could have been recorded green without validating nine surfaces); and the domain-legacy versus design-legacy disambiguation trap.

No standing forward authorization is invoked or claimed for this plan. Issue creation in the `lizbeth-spanish` repository is now **ACTIVE**, scoped to that repository only (see GitHub issue logging policy); it does not extend to commits, pushes, PRs, or deploys, and it does not extend to any other repository.

## Outcome and audience

Drive every remaining user-visible surface of the `lizbeth_spanish` app off residual legacy design vocabulary and onto ratified Field Journal tokens and components, with a deterministic, non-subjective terminating condition proving "100% off legacy."

Audience: the engineering fleet (T1/T2, verifier, browser-validator) executing this plan, and the user approving it.

## Scope

### In scope

1. Extending the existing deterministic CSS lint into a machine-enforceable token deprecation registry derived from the reviewed design verdict.
2. Migrating every remaining legacy-trio call site (`--border-width-strong` / `--color-ink-800`-as-border / `--shadow-print`) to its role-correct ratified replacement.
3. The E.3 mobile week-detail information-architecture (IA) change.
4. Specifying and implementing the state gap-fills the reference never covered: loading, empty, error, disabled, hover, focus, active, validation.
5. GitHub issue logging for every discrepancy found.
6. Per-surface browser validation.

### Non-goals

- No new visual direction. The design language is fixed and ratified by the Field Journal DS document.
- No re-litigation of the ADOPTION-PLAN's ratified deviations.
- No re-remediation of `.owner-settings-page`, `.admin-students-page`, `.admin-students-roster`, `.admin-students-detail` — already conformant per the design review's findings (see Finding 4 and design-review record).
- No reopening of closed issues #31-#44.
- No typography or layout/density change.
- No commit, push, PR, or deploy unless the user explicitly requests it. **The user has now explicitly requested exactly that.** On 2026-09-04, in the interactive session, the user wrote: "yes resume the goal, commit, push, open pr and merge to main as we progress." This standing authorization covers commit, push, PR, and merge to `main` in the `lizbeth-spanish` repository only. It does **not** extend to deploys, to any other repository, or to force-pushes, history rewrites, or branch deletion.
- No Docker or Supabase schema change.
- Never `taskkill`.

### No-touch list

- `lizbeth_spanish/atelier.config.json` must never be edited — standing directive; it is the misleading duplicate. The operative config is the orchestrator-root `H:\CommandCenter\orchestrator\atelier.config.json`.

## Background and repository findings

All findings below are the planning-stage evidence supplied for this closure plan. Findings 1-10 restate the planning record faithfully; nothing here has been re-verified independently by this document beyond transcription accuracy.

### Finding 1 — The request's bounded assumption is overturned

The originating brief proposed an incremental surface-by-surface migration behind the token layer, with legacy and Field Journal vocabulary coexisting until a final cutover. Repository evidence contradicts this: the token layer has already flipped. `.atelier/tokens/field-workbook.tokens.json` is a single DTCG source compiled to `src/tokens/field-workbook.generated.css`, with `scripts/verify-token-pipeline.mjs` as a hard oracle and `src/__tests__/tokenPipelineOracle.test.ts` enforcing it. There is no dual token layer to migrate behind and no cutover to stage.

**Recommended alternative, on that evidence:** a defect-driven conformance closure loop — detect, log, fix, verify, per surface — terminating on an all-green gate set, not a migration with a flip date. This reframing governs the entire ordered-work sequence below.

### Finding 2 — This is not greenfield

Prior Field Journal work is extensive and largely landed. `design/field-journal/ADOPTION-PLAN.md` decomposed the system into 14 issues (#31-#44) under a `Field Journal DS` milestone; all are recorded closed. `docs/plans/lizbeth-spanish-fjds-milestone-closure-summary.md` closed that milestone with a deliberately calibrated verdict: "substantially achieved at the token and source level, with rendered-fidelity verification incomplete and specific known defects outstanding." Four subsequent App.css cascade-collision remediation cycles ran. `docs/plans/lizbeth-spanish-fjds-reference-artboard-pixel-diff.md` built the reference-baseline mechanism used in this plan's validation approach.

This plan supersedes nothing wholesale. It is the continuation that closes the rendered-fidelity gap the closure summary honestly disclosed. Completed work is not re-planned here.

### Finding 3 — A deterministic legacy detector already exists, and its precise gap is identified

`src/__tests__/tokenFallbackAuditLint.test.ts` is a build-breaking lint over every `src/**/*.css` file. It currently fails on: undefined `var(--x)`; raw hex outside `src/tokens/` (two narrowly-scoped ratified exceptions, both self-documented in App.css); any non-zero border-radius including `50%`/`999px`, all four physical and all four logical corner longhands, and vendor-prefixed forms; and any `box-shadow` with non-zero blur. It computes 1-based line numbers from character offsets, so it remains correct even on minified single-line files.

What it cannot catch is semantic legacy token **choice**: `--shadow-print` and `--border-width-strong` are validly defined, zero-blur, zero-radius tokens, so they pass the existing lint while still being legacy vocabulary. Closing that specific gap is the core deliverable of this plan (Phase 1).

### Finding 4 — The residual legacy surface is bounded and measured, not exhaustively enumerated

A grep for the legacy/ambiguous token set returns 231 occurrences across 52 files. This figure must not be quoted as the work-item count: it overcounts, including ratified uses (`--color-ink-800` as text colour is correct), already-deprecated-and-annotated radius tokens, and test-file assertions.

The genuinely open sites named by the design review include:

- `.app-header-logo`, `.demo-button` (+ `.primary`/`.secondary`), `.login-form-container`, `.demo-section` at `src/App.css:788-792,833`.
- `button.destructive, button.caution` at `src/pages/AdminStudentsPage.css:469`.
- `.admin-shell-link` at `src/components/AdminShell.css:27`.

An exhaustive enumeration is ordered work under Phase 1, not a planning-time claim.

### Finding 5 — The compiled token layer self-documents part of the deprecation

`src/tokens/field-workbook.generated.css:119,122,124` carry literal `DEPRECATED — retired by the Field Journal token spec (issue #31); do not use in new code` comments on `--radius-medium`, `--radius-pill`, `--radius-small`. `--border-width-strong` (line 39) and `--shadow-print` (line 134) carry no such annotation.

The deprecation registry (Phase 1) must preserve this distinction between **file-confirmed** and **reference-inferred** deprecation, and this plan does the same throughout.

### Finding 6 — Non-circular reference baselines exist, with a stated coverage limit

`.atelier/reference-harness/` holds an extraction script, tests, a dimension `manifest.json`, and 8 standalone harness HTML pages extracted directly from the DS file (bypassing `support.js`, `<x-dc>`, `<helmet>`). `.atelier/baselines/` holds 8 PNGs captured from those harness pages, not from the app: D.1, D.2, D.3, D.4, D.9, E.2, E.3, E.4. Font parity between reference and app was confirmed at source level (see the pixel-diff plan's Finding 4).

**Coverage limit, stated plainly:** D.5, D.6, D.7, D.8, E.1, E.5, E.6 and every derived page have no pixel baseline. Those surfaces are validated by textual/structural criteria only, not by numeric visual diff.

### Finding 7 — The config points at the compiled source, not the DS extraction

The operative `H:\CommandCenter\orchestrator\atelier.config.json` sets `tokens.sources` to `lizbeth_spanish/.atelier/tokens/field-workbook.tokens.json`, and a 5-entry `review.allowlist` covering only the token files plus `src/App.css`. It does not reference `design/field-journal/extracted/tokens.field-journal.json` — the DTCG extraction of the DS's section A — and its allowlist does not cover the drifted per-component CSS. `ADOPTION-PLAN.md` Step 4 called for both.

This is a genuine open gap. The two token files must be reconciled via `tokens_diff` and any divergence adjudicated explicitly, never blind-swapped, since the compiled source is what the app and its oracle currently depend on (Phase 0).

### Finding 8 — Dev server and fixtures

`package.json` gives `npm run dev` (Vite). Base URL `http://localhost:5173` (`vite.config.ts` sets `port: 5173`; the root README's claim of 5174 is stale and separately noted in `handoff.md`). `predev` runs `scripts/ensure-lesson-assets-bucket.ts`.

Authenticated student surfaces are reachable via the dev-only seeded quick-select panel in `src/components/LoginForm.tsx:123-138`, which fills real seeded Supabase Auth accounts (not a mocked session) and does not render outside development mode.

Owner/admin surfaces are gated by `AdminShell.tsx:30`'s permission check; prior sessions did capture owner surfaces successfully (`.atelier/screenshots/lizbeth-owner-dashboard.png`), so owner access is achievable, but the exact credential path was **not** confirmed during this planning pass and is an explicit open item, not an assumption.

The local Supabase stack must be confirmed running before any RLS-dependent test result is trusted — `handoff.md` records a prior incident where a "full pass" was falsely claimed by silently excluding `rlsIntegration.test.ts`.

### Finding 9 — A known environmental impediment, carried forward honestly

`docs/plans/lizbeth-spanish-fjds-final-closure.md` Section 13 records browser validation failing three times via Claude-in-Chrome with the dev server confirmed healthy each time. More recent plans (issue #71, #72/#73/#75) record browser tooling working with tab reuse. Status is therefore **uncertain**, not resolved. A browser-validation tooling failure under this plan is a blocking impediment to be reported, never grounds to accept a surface on source-level evidence alone.

### Finding 10 — A standing process hazard

`handoff.md` records browser-validator twice running a broad `taskkill /F /IM node.exe /T`, causing collateral damage despite explicit instructions, with no hook guardrail in place. Every browser job under this plan must instruct scoped-PID termination explicitly and must reuse the existing dev server rather than restarting it.

### The complete legacy universe (five vectors)

Added after a PLAN_DUCK judge pass (see Judge route and disposition below) identified that the authoritative detector as originally scoped covers only `src/**/*.css` token references, leaving other styling-bearing source forms unproven. That gap is real and must close. However, a re-verification run during the same pass found the legacy universe does **not** grow as a result: the additional vectors are measured empirically as empty or narrow, not merely assumed empty. The plan's scope is unchanged; what was missing is proof, not migration work.

The complete legacy universe is defined as five vectors:

1. **Token references in `src/**/*.css`.** Covered by the extended lint (Phase 1).
2. **Token references in `.tsx`.** Measured at **zero** in production code. Every match for `--shadow-print`, `--border-width-strong`, and the radius trio inside `.tsx` files is confined to `src/__tests__/` and is an assertion of *absence* — for example `fjdsFreshAuditFindingA.test.tsx:114,173-175` and `AdminStudentsPage-issue42-screenComposition.test.tsx:54-59`. To be **pinned** at zero by a new deterministic guard in Phase 1, not merely assumed to stay that way.
3. **Inline `style={{}}`.** Measured at **seven** occurrences across six files, and every one carries a dynamic runtime value with no static design vocabulary: `BrandDesignPage.tsx:31` and `OwnerSettingsPage.tsx:48` set `backgroundColor` from a user-chosen brand hex (application data, not a design token); `FlashcardsViewer.tsx:133`, `BandRoadmap.tsx:190,194`, and `OwnerLedgerRow.tsx:101` set a computed percentage `width`; `SegmentLedger.tsx:89` sets `flexGrow` from segment minutes. To be pinned by a Phase 1 guard that fails on any inline style containing a static colour, border, shadow, or radius literal, while permitting computed values.
4. **CSS-variable indirection**, where a ratified token is aliased to a deprecated one through an intermediate custom property. The lint must resolve token references transitively, not only by direct match, or an aliased deprecated token could pass undetected.
5. **Deprecated, dead, or unwired components**, addressed via an adjudicated inventory rather than a name sweep (see below).

**Disambiguation warning for vector 5.** A naive name-based sweep for `legacy` produces false positives, because the token `legacy` appears in class names for two unrelated reasons:

- **Domain-legacy** names describe old business data and are **not** design defects: `.legacy-schedule-notice` (`CourseWorkspace.css:45-46`), `.enrollment-card-legacy-note` (`LearnIndexPage.css:85`), and Badge's `legacy-materialization` variant.
- **Design-legacy** names describe pre-FJDS treatment: `.learn-detail-legacy-panel` and `.learn-detail-legacy-cta` (`LearnDetailPage.css:35,56`). Note that `.learn-detail-legacy-cta` has **already** been remediated to C.1 Primary values, per the assertions at `fjdsFreshAuditFindingA.test.tsx:101-114` — its name is stale, not its styling.
- **Design-dead or unwired** — a third category, added from a browser-validation pass (2026-09-04), for components or selectors that render nothing at all rather than legacy-styled content. Found by a zero-consumer `grep` across `src/**/*.tsx` excluding tests, not by a name sweep:
  - `Folio` and `TabStack` (`src/components/journal/`) — built, never imported anywhere in production code.
    **Correction, 2026-09-04:** an earlier version of this entry stated `TabStack` was very likely the E.3 "Lesson / Cards / Files" segmented control and that Phase 4 should wire it rather than build new. That is wrong. Concurrent characterization work read `src/components/journal/TabStack.tsx`'s own docstring: it is decorative-only, states it "never uses `role='tab'`/`'tablist'`," and "never renders a focusable element." E.3's Lesson/Cards/Files control requires a real, accessible, focusable tab implementation (see the E.3 structural inventory in Phase 4). `TabStack` may serve as a visual reference only; it does not satisfy the requirement, and Phase 4 must build the interactive control.
  - `.admin-shell-tab` / `.admin-shell-tab.active` (`App.css` ~887-901) — already migrated to ratified tokens, but zero rendered elements carry these classes; only `.admin-shell-link` renders.
  - `button.destructive` / `.demo-button.destructive` — zero consumers; the Disable/Delete actions now use the `Control` primitive instead. `.demo-button.caution` retains exactly one consumer, the Revoke-access modal button.

  Disposition for every entry in this category: **wire to its intended DS surface, or delete — decision recorded**, not left as dead code. Feeds the Phase 6 closure inventory. Tracked as GitHub issue #102.

Phase 0 must produce an adjudicated component inventory classifying every `legacy`-named symbol as domain-legacy (out of scope; rename optional) or design-legacy (in scope), rather than sweeping by name. The design-dead-or-unwired inventory above is a separate, zero-consumer-grep-based deliverable feeding the same Phase 0/Phase 6 inventory, not a name sweep.

**The completion claim, stated precisely.** With the guards above added, "100% off legacy" means every styling-bearing source form in `src/` is mechanically proven free of deprecated design tokens and out-of-context token use, plus an adjudicated component inventory. It does **not** prove pixel-identity to the reference artboards, and it cannot, for the reasons given in Acceptance and validation's authority-ordering subsection. Both halves of this claim hold simultaneously; neither substitutes for the other.

## Research evidence

None. No external or current-fact question was material to this plan; every finding above is direct local repository evidence from the planning pass. This document does not introduce new research.

## Design route

```
DESIGN_ROUTE
profile: standard
reasons: System-wide conformance of every user-visible surface to an already-decided externally authored design system; multiple screens and multi-state components; genuine gap-filling for states and surfaces the reference never specified; one screen (E.3) requires an information-architecture change.
agents_required: design-director, ux-architect, visual-system-designer, design-reviewer
prototype: forbidden
model_tier: sonnet
existing_system_mode: preserve
END_DESIGN_ROUTE
```

Studio was explicitly not used: the creative direction is fixed by the Field Journal DS document, so presenting safe/refined/novel directions would have been the wrong tool.

### Design handoff (binding contents)

A full reviewed `DESIGN_HANDOFF` was produced by design-director with ux-architect and visual-system-designer. Its binding contents are recorded here in full; downstream execution must treat this section as authoritative alongside the design-review record below.

**(a) Page-to-artboard mapping.** All 15 pages under `src/pages/`.

Governed by an artboard:

| Page | Artboard |
|---|---|
| RoadmapPage | D.2 + E.2 |
| WeekDetailPage | D.3 + E.3 |
| FeedbackPage | D.5 + E.5 |
| OwnerDashboardPage | D.6 + E.6 |
| AdminStudentsPage | D.7 (desktop-only) |
| BrandDesignPage | D.8 (desktop-only) |
| PublicCatalogPage | D.9 (desktop-only — no E.9, confirmed at `PublicCatalogPage.css:216`) |

Derived from A+B+C primitives with no artboard: `OwnerFeedbackPage`, `CourseWorkspacePage`, `CourseSettingsPage`, `NewCoursePage`, `BusinessSettingsPage`, `OwnerSettingsPage` — all six ratified by ADOPTION-PLAN issue #14 and not reopened — plus two new additions to that derived set:

- `LearnIndexPage` and `LearnDetailPage`, grounded in both pages postdating the ADOPTION-PLAN's enumeration (they come from `docs/plans/lizbeth-spanish-issue5-phase5-student-learn-surface.md`) and in `LearnIndexPage.tsx:20-21` describing the surface as "strictly additive." The design reviewer independently confirmed this grounding is real, not convenient.

**(b) The E.3 mobile week-detail IA change.** The live 390px render does not conform. `Field Journal DS.dc.html:1382-1428` specifies:

- a Lesson/Cards/Files 3-way segmented tab control (tab row at 1400-1402);
- a condensed Lesson composition including a "Vocabulario · 04 fichas" preview card (1408) absent from D.3;
- a register-note callout (1416-1419);
- a "03 / 26" progress indicator (1390);
- a lesson-title `h1` rather than "Week N" (1396);
- a sticky "Mark complete"/"Next" footer (1423-1426).

Current code (`WeekDetailPage.css:111-183`) does a `display:block` linear stack at a 900px breakpoint with no tab control. The 390px endpoint must conform to the DS spec above; the 900px breakpoint trigger value itself is engineering discretion. The design reviewer independently verified this against both files.

**(c) The token deprecation registry.** This is the machine-readable verdict that becomes the authoritative legacy detector under Phase 1.

| Status | Token(s) | Disposition |
|---|---|---|
| DEPRECATED (file-confirmed) | `--radius-small`, `--radius-medium`, `--radius-pill` | Migrate to `--radius-square`. |
| DEPRECATED (reference-inferred; not file-annotated — do not overstate as file-confirmed) | `--border-width-strong` | Role-dependent replacement: `--border-width-thin` for fine dividers, or `--border-width-rule` for elevated surfaces. Always re-pair with `--color-ink-1000`. |
| DEPRECATED (reference-inferred) | `--shadow-print` | Role-dependent per-site classification, not a blanket swap. `--shadow-brass` only for owner tables and download/export links; otherwise `--shadow-card` or `--shadow-sheet` by component role. |
| CONTEXTUAL | `--color-ink-800` | Permitted as text/foreground colour only; prohibited as border, outline, or box-shadow colour. |
| CONTEXTUAL | `--shadow-muted-card` | Muted/disabled card variant only, never the default. |
| RATIFIED | `--border-width-thin`, `--border-width-rule`, `--border-width-hairline`, `--border-width-accent` | The latter two carry a flagged caveat: no A.3 row names their context explicitly — this is inferred, not fabricated. |
| RATIFIED | `--shadow-card`, `--shadow-sheet`, `--shadow-none`, `--shadow-press`, `--shadow-brass-none`, `--shadow-brass-press` | — |
| RATIFIED | `--radius-square` | Sole ratified radius. |
| RATIFIED | `--radius-none` | Legitimate DTCG alias. |
| RATIFIED | `--color-focus` | Dual-named with `--color-ink-slate`, explicitly sanctioned. |

**Answering the brief's specific question about `--shadow-brass`:** it is ratified-but-narrow, not fully retired. A.3's "brass" row is annotated "(legacy print)" and names owner tables and download links as its scope. `--shadow-print` is the unrationalized predecessor of that same value and is the deprecated one.

**Flagged duplicate-token defect class:** `--border-width-strong`/`--border-width-thin` and `--shadow-print`/`--shadow-brass` are unlinked same-or-near-value literals rather than aliases — the lint must alias-detect this pattern. By contrast, `--radius-none`/`--radius-square` **is** a proper alias, and `--color-focus`/`--color-ink-slate` is sanctioned dual-naming. Not every same-value pair is a defect; the registry must not conflate the two categories.

**(d) State gap-fill spec**, in 8 grouped patterns:

1. **C.1 controls** — hover `translate(-2px,-2px)`, shadow 5→7px; active `translate(3px,3px)`, shadow 0; 120ms transition; disabled = dashed border + muted ink-700 + no shadow (a shape change, never colour-only); caution split by reversibility: amber for reversible, terracotta for irreversible.

   **Hover/active state specification, added from a DS investigation (2026-09-04).** The DS carries these as `style-hover`/`style-active` HTML attributes (a Claude Design canvas convention interpreted by `support.js`), not native CSS pseudo-class rules — the document's only real pseudo-class rule is `a:hover { color: #a85e4a; }`. Read directly off the specimens:
   - **Primary**: hover `transform: translate(-2px,-2px); box-shadow: 7px 7px 0 0 #a07e48`; active `transform: translate(3px,3px); box-shadow: 0 0 0 0 #a07e48`. **No fill change on hover** — the ink fill is constant.
   - **Secondary**: hover `transform: translate(-2px,-2px); box-shadow: 7px 7px 0 0 #1a1512; background: #f0ebe2`; active `transform: translate(3px,3px); box-shadow: 0 0 0 0 #1a1512`.
   - A hover fill change is therefore a **per-tier exception belonging to Secondary only**, not a general rule. C.1 line 332 ("Hover lifts onto the shadow; press sinks into it") is the only prose on the subject and says nothing about fill.
   - **Confirmed discrepancy for Phase 5 / gate 9, not a candidate finding:** the app's `.demo-button.primary:hover` sets `background-color: var(--color-accent-secondary)` (terracotta-500), which the DS does not specify for Primary. The correct fix per the DS is to **remove the hover background-color override entirely** so the ink fill persists, not to substitute a different colour.
2. **C.2 fields** — error state changes two things: a terracotta rule and a mono error line. Colour alone is a failing implementation. Counter is zero-padded.
3. **C.3 badges/stamps/account states.**
4. **C.4 week cards**, four states, locked showing a real unlock date, never a placeholder; `LearnDetailPage`'s 8-state lesson model extends C.4 with five new copy strings, all flagged as assumptions needing product sign-off.
5. **Modal surfaces** — focus trap, focus return to trigger, Escape plus explicit close, never backdrop-only dismissal.
6. **Loading/empty/error** — `LearnIndexPage` as the canonical existing pattern, `JournalEmptyState` reuse, `role=alert` on error.
7. **Offline/permission-denied** — explicitly not evidenced in the DS; flagged assumption, with `AdminShell.tsx:30`'s existing permission-denied pattern as the tone/structure precedent.

**(e) Engineering invariants.**

- Never hand-edit `field-workbook.generated.css`. All token changes go through the DTCG source and the pipeline.
- Migrate border + shadow + colour as one unit per call site. Never swap colour while leaving the legacy width/shadow; never swap width/shadow while leaving `--color-ink-800` as a border colour.
- Classify each site by A.3 elevation role before substituting. Do not default every site to `--shadow-brass` merely because `--shadow-print` happened to carry brass colour.
- Never add a page-specific selector to a shared multi-page rule list — this is the documented root cause of the App.css cascade-collision history.
- Never scope an override to a shared class name without first verifying that class name is exclusive to the intended page — the mirror image of the hazard above. A browser-validation pass (2026-09-04) found `CourseWorkspace.css:11` scoping `.workspace-panel .demo-button.primary` while `.workspace-panel` is also used by `PublicCatalogPage.tsx:125`; see Risks and rollback for the full finding.
- Never reintroduce the deprecated radius trio.
- Do not conflate the focus ring's 3px width with `--border-width-rule`'s 3px — same number, different token, different purpose.
- Consolidate `--border-width-strong` at the DTCG source level as one canonical rename/split, rather than leaving both primitives compiled indefinitely.
- `.owner-settings-page`, `.admin-students-page`, `.admin-students-roster`, `.admin-students-detail` are already conformant — do not re-touch them.
- `.admin-shell-nav` (`AdminShell.tsx:44`, `AdminShell.css:14-46`) is the already-conformant structural implementation of the D.6/E.6 nav specimen and is preserve-do-not-touch; only its legacy token usage is in migration scope.
- Correct or remove the stale comment at `App.css:775-777` ("Approved Field Workbook geometry"), which is incorrect relative to the ratified A.3 table and is very likely the historical source of the legacy trio's proliferation.
- Verify whether `.admin-shell`'s trio membership at `App.css:833` is already neutralized by the countermanding rule at `App.css:837` before spending a migration diff on it.

### Design review record

**Verdict: PASS, on revision 1.** Recorded honestly rather than as a single clean pass.

The first review returned `NEEDS_REVISION` with one MEDIUM finding: the OwnerDashboardPage/E.6 note framed the hamburger and the tab row as alternatives ("hamburger, not tab bar") when `Field Journal DS.dc.html:1507-1524` shows the hamburger (1518) and the Dashboard/Students/Inbox nav row (1520-1524) **coexisting** in the same 390px artboard — a real risk that an engineer would remove or hide already-conformant nav. The revision corrected this, and the reviewer confirmed the coexistence claim directly against the source file.

The reviewer also independently confirmed, down to exact line numbers, that this plan's inherited "known open defect" claims about `App.css:706` and `App.css:796-801` were **stale and already remediated**. That correction is load-bearing: it is why those four selectors (`.owner-settings-page`, `.admin-students-page`, `.admin-students-roster`, `.admin-students-detail`) are excluded from scope above.

**One low-severity finding remains open under the PASS and is recorded rather than dropped:** the design handoff cited `AdminShell.css:9,27,32` as legacy-trio consumption, but only line 27 (`.admin-shell-link`, `--border-width-strong` + `--color-ink-800`) actually matches the trio pattern.

- Line 9 (`.admin-shell-permission-denied`) uses `--border-width-strong` paired with `--color-terracotta-600` on a single-edge `border-left` callout — a deprecated width, but not the trio pattern. It must be cited and migrated separately and accurately, not folded into the trio work item.
- Line 32 is `color: var(--color-ink-800)` — a text colour, which the registry above rules ratified. Migrating it would be an error. No engineer should "fix" this already-conformant line.

## Ordered work

Sequenced as dependency-ordered phases. Each item is bounded enough for one T1 job with explicit acceptance checks; item-level acceptance checks are elaborated during issue logging (Phase 2), not fully pre-specified here.

### Phase 0 — Ground truth and reconciliation (blocking)

- Verify live GitHub state for the `Field Journal DS` milestone and open issues (#31-#44, #66/#67/#71-#75) via `gh`. Planning could not read this: `gh` is not on the read-only planning tool surface. State this limit explicitly in the execution report.
- Run `tokens_validate` on both token files.
- Run `tokens_diff` between `design/field-journal/extracted/tokens.field-journal.json` and `.atelier/tokens/field-workbook.tokens.json`. Adjudicate every divergence explicitly (Finding 7); never blind-swap.
- Confirm the dev server, the Supabase local stack, and browser tooling health (Finding 9) before anything downstream depends on them.
- **Static re-verification deliverable**, added after judge review (see Judge route and disposition). This is distinct from the environmental checks above and closes a self-consistency gap: this plan states that Findings 1-10 were not independently re-verified, yet relies on them for exclusion and preservation decisions. Before any migration work depends on an inherited claim, Phase 0 must re-confirm it directly against the current repository state, covering: the current selector and token inventory; an import and cascade review; and the page-to-route inventory. It must specifically re-confirm the four excluded selectors (`.owner-settings-page`, `.admin-students-page`, `.admin-students-roster`, `.admin-students-detail`) and the preserved `.admin-shell-nav` before any migration work depends on their conformant status. This is the same class of error the plan already caught once during design review — inherited claims about `App.css:706` and `796-801` were stale — which is precisely why this re-verification is a required deliverable rather than an assumption. Any discrepancy found here is a stop-and-report condition, not a silent reconciliation.

This phase blocks all subsequent phases. A failure here — including a static re-verification discrepancy, credential unavailability, or tooling failure — is reported, not worked around. Credentials and tooling gaps are discovery blockers to Phase 0 itself, not conditions requiring separate user approval to proceed past Phase 0's own gate.

### Phase 1 — The authoritative detector

- Encode the reviewed deprecation registry (design handoff section c) as a machine-readable manifest.
- Extend `tokenFallbackAuditLint.test.ts`, or add a sibling test, to fail on any DEPRECATED token reference and on any CONTEXTUAL token used outside its permitted context — specifically `--color-ink-800` appearing in a `border`, `outline`, or `box-shadow` position.
- Include alias-detection for unlinked same-value duplicates (`--border-width-strong`/`--border-width-thin`, `--shadow-print`/`--shadow-brass`) while correctly excluding sanctioned duplicates (`--radius-none`/`--radius-square`, `--color-focus`/`--color-ink-slate`).
- The lint must cite file and 1-based line, and must distinguish file-confirmed from reference-inferred deprecation in its message text.
- Run the extended lint in report-only mode first, to produce the complete, exhaustive enumeration of open sites. This enumeration, not the 231-occurrence grep, is the real work-item inventory for Phase 2.
- Extend the lint (or add sibling guards) to cover legacy-universe vectors 2 and 3 from the subsection above: pin zero deprecated-token references in `.tsx`, and fail on any inline `style={{}}` containing a static colour, border, shadow, or radius literal while permitting computed/dynamic values.
- Extend the lint's token resolution to be transitive (vector 4): a ratified token aliased to a deprecated one through an intermediate custom property must still be caught.

**Registry schema, added after judge review.** The deprecation manifest (design handoff section c) is specified with these fields per entry: token name; verdict (RATIFIED / DEPRECATED / CONTEXTUAL); evidence basis (file-confirmed versus reference-inferred); replacement or permitted context; and, for CONTEXTUAL entries, the machine-checkable rule expressed as permitted and prohibited CSS property positions.

**Operationalized contexts for the three currently-inferred CONTEXTUAL/RATIFIED entries that lacked one.** `--color-ink-800` already has an operational rule: permitted in `color` and foreground positions, prohibited in `border`, `outline`, and `box-shadow`. The equivalent must be written for the others before Phase 1 closes:

- `--shadow-muted-card`: permitted only on muted, disabled, or neutral card states; prohibited as a default card treatment.
- `--border-width-hairline` and `--border-width-accent`: where the A.3 table genuinely does not name a context for these — and it does not, per the design handoff's own flagged caveat — that absence is recorded explicitly, and the working rule is provisional pending the Phase 0 `tokens_diff` reconciliation (Finding 7). No context is invented and no field is left silently blank.

**Exception record format.** Any call site that cannot migrate under this plan's timeline requires a recorded exception with: file, selector, property, justification, approver, and expiry. An exception without an expiry is not permitted under this plan.

**Triage baseline.** The Phase 1 report-only run's complete output is captured and frozen as the baseline inventory before any migration begins in Phase 3, so migration progress in Phase 6's closure gate is measured against a fixed denominator rather than a moving one.

**Status: complete, independently verified.** The detector is report-only, per the report-only-first sequencing above. The frozen baseline records 80 findings / 77 open / 3 neutralized / 58 clusters, superseding the 231-occurrence grep (Finding 4) as the real work-item inventory.

A Codex `CODE_REVIEW` on Phase 1 returned seven false-negative findings: CSS-nesting parent declarations skipped, a mutable baseline, silent alias-depth truncation, CONTEXTUAL entries not transitively resolved, an unvalidated neutralization cascade, inline-style spread and computed keys not handled, and no forward duplicate detection. All seven were fixed with proving tests and independently re-verified. Policy action on this checkpoint was advisory under shadow mode, non-blocking; the findings were remediated anyway because each was a genuine false-negative path in the detector this plan treats as authoritative.

### Phase 2 — Issue logging

Log every open site from Phase 1's enumeration as a GitHub issue, per the GitHub issue logging policy below.

**Status: complete.** 12 issues were filed, #83 through #94, against the existing open `Field Journal DS` milestone rather than a new one — Phase 0 disproved this plan's original assumption that the milestone was closed (see the GitHub issue logging policy's Milestone note). The Phase 1 baseline's 57 open clusters were grouped by component or screen into these 12 issues, per the granularity rule above.

Two findings from this phase are preserved:

- The Phase 0 open question about the `Field Journal DS` milestone's second open issue is answered: it is **#74** ("Mobile flashcards (E.4) may be missing dedicated full-screen SRS mode"), alongside #42.
- Decision D-5 (`--border-width-hairline` permitted context, see Decision register) gates nothing in practice. The frozen Phase 1 baseline contains zero findings referencing that token: it is RATIFIED and is never flagged as legacy anywhere in the baseline, and the replacement target for `--border-width-strong` migration sites is `--border-width-thin` or `--border-width-rule`, never hairline. This is recorded as a verified absence so no future job invents a dependency between D-5 and Phase 3 dispatch. D-5 itself remains open as a documentation matter — its permitted context is still unconfirmed — but it is not a blocker.

### Phase 3 — Migration

Ordered tokens → primitives → composed components → screens, one bounded T1 job per issue, each with its own gate (lint pass for that site, relevant unit/visual checks, no regression on already-conformant neighbours).

### Phase 4 — The E.3 IA change

The largest single item; carries its own design-specified acceptance criteria per design handoff section (b).

**E.3 structural inventory, added from a DS investigation (2026-09-04) of `Field Journal DS.dc.html` and the extracted harness page `.atelier/reference-harness/field-journal-e3-week-detail-390.html`.** The design handoff's element list for E.3 (section (b)) was incomplete. This is the full top-to-bottom inventory Phase 4 must build from:

| Line(s) | Element | Text | Location |
|---|---|---|---|
| 1386 | Status bar | "9:41" / signal glyphs | Outside tabs — decorative phone chrome |
| 1388 | Back link | "← Roadmap" | Outside tabs — header row |
| 1390 | Progress indicator | "03 / 26" | Outside tabs — header row, right-aligned |
| 1395 | Eyebrow label | "Semana 03 · Beginner" | Outside tabs — title block |
| 1396 | `h1` | "Family and Describing People" (lesson title, not "Week N") | Outside tabs — title block |
| 1400-1402 | 3-way tab control | "Lesson" / "Cards" / "Files" | The tab control |
| 1405 | Intro paragraph | "This week you describe the people around you…" | Inside Lesson tab |
| 1407-1414 | Vocab preview card | "Vocabulario · 04 fichas" + 3 rows (la hermana/sister, el cuñado/brother-in-law, simpático/kind, likeable), dotted dividers between rows | Inside Lesson tab |
| 1416-1419 | Register-note callout | "Register note" + tú/usted paragraph | Inside Lesson tab |
| 1420 | Handwritten aside | "ask Lizbeth about vos!" (Caveat font, rotated −0.8°) | Inside Lesson tab |
| 1423-1426 | Sticky footer | "Mark complete" / "Next →" | Outside tab content — fixed footer |

Only the Lesson panel is drawn in the static specimen; Cards and Files render as inactive tab buttons with no visible panel, which is expected for a one-state mockup and is not itself a gap.

**Measured specifics the handoff omitted, also from this investigation:**

- **Active-tab mechanism is a fill/outline swap**, not an underline or border-weight change. Active ("Lesson," the default): `background-color: rgb(26, 21, 18)` ink fill, `color: rgb(253, 252, 249)` paper, **`border-width: 0`**. Inactive: `background-color: rgb(250, 248, 244)` paper-100, `color: rgb(26, 21, 18)`, `2px solid` border.
- **Sticky footer**: `border-top: 3px solid rgb(26, 21, 18)`, `background-color: rgb(250, 248, 244)`, `padding: 14px 20px`. "Mark complete" is Primary tier (ink fill `rgb(26, 21, 18)`, brass shadow), `flex: 1 1 0%`, `min-height: 48px`. "Next →" is Secondary tier (paper fill, ink shadow), content-width, `min-height: 48px`.
- **A deviation Phase 4 must not miss:** both footer buttons use a **compact geometry** — `2px` border and `3px 3px` shadow offset — not C.1's canonical `3px` border and `5px 5px` shadow. Height (48px) and the tier fill/shadow pairing still follow C.1. This is a context-scoped deviation, not an error to "correct" to canonical values.
- **Register-note callout**: `border-left: 6px solid rgb(168, 94, 74)` terracotta — the 6px magnitude matches `--border-width-accent`; `border-top: 2px solid rgb(26, 21, 18)`, with right and bottom the same by symmetric declaration; `background-color: rgb(255, 251, 248)` (`#fffbf8`), a distinct warm off-white that is **not** any of the surrounding paper tones (`#f0ebe2` header, `#faf8f4` footer and vocab card); `padding: 14px 16px`.

### Phase 5 — State gap-fills

Per design handoff section (d)'s 8 grouped patterns, each its own bounded T1 job.

**Finding, pattern 5 (modal surfaces), added from a browser-validation pass (2026-09-04):** the "Delete Student Permanently" dialog on `/admin/students/:id` (`role="dialog"`, `aria-modal="true"`) passes focus-trap (8 Tab presses), focus-return-to-trigger on Cancel, and correctly ignores backdrop clicks, but **does not close on Escape**, confirmed twice with focus on the dialog container.

**Refinement from concurrent characterization work, 2026-09-04 — this is not a straightforward defect.** `src/components/Modal.tsx` implements Escape-to-close correctly by default (`Modal.tsx:19,30,39,46,75`; `src/hooks/useFocusTrap.ts`). Escape is **deliberately suppressed** via `suppressDismiss={true}` at exactly five sites — `src/components/AdminStudentModals.tsx:135,407,623,667` and `src/components/RegisterStudentModal.tsx:244` — each citing a documented prior Codex CODE_REVIEW rationale (J-35-001) covering irreversible actions and one-time-secret-reveal flows. Every `CourseWorkspacePage.tsx` modal sets `suppressDismiss={false}` and is unaffected, though still untested locally for want of cohort fixtures (see Modal trigger enumeration). This is a **conflict between this plan's Browser UI invariant (Escape must close every modal) and a deliberate, documented safety decision**, and it awaits a user ruling rather than an engineering fix. Do not dispatch a Phase 5 T1 job to add Escape-close to these five sites until that ruling is made. Tracked as GitHub issue #100.

### Phase 6 — Closure

Flip the lint from report-only to build-breaking. Run the full gate set (Acceptance and validation section below). Prove termination.

## GitHub issue logging policy

- **Granularity:** one issue per bounded work item, sized to a single T1 job — per component or per screen for migration work. Never one mega-issue and never one issue per individual CSS line.
- **Title convention:** plain descriptive title, no `#N:` prefix, matching the convention recorded in `lizbeth-spanish-fjds-final-closure.md` Step 3.
- **Labels:** reuse existing `area:design-system`, `area:tokens`, `design:screen`.
- **Milestone:** a new one, since `Field Journal DS` is closed. Recommended name: `Field Journal DS — conformance closure`, subject to the Phase 0 live check confirming it does not collide with an existing milestone.
- **Body template:** reuse the ADOPTION-PLAN's template verbatim in structure — Reference (DS section + char offset or line), Scope (files), Acceptance criteria (section-specific, plus the seven fixed A.6 criteria every issue carries), Verification, Depends on.
- **Invocation shape:**

  ```
  gh issue create --repo lebobo88/lizbeth-spanish --title "<title>" --body-file <path> --milestone "<milestone>" --label area:design-system
  ```

- Each issue maps 1:1 to an ordered-work item and to one lint-reported site cluster.

**Authorization note, stated plainly:** issue creation is a write action. It is gated on the user's already-granted approval, scoped to the `lizbeth-spanish` repository only, and it does not extend to any other repository. Separately, and in addition, the user has explicitly authorized commit, push, PR, and merge to `main` in the `lizbeth-spanish` repository — see the Non-goals amendment and the Approval gate for the verbatim quote and date. Deploys remain excluded in both cases. Issue creation does not begin until this plan itself is approved (see Approval gate).

## Interfaces and data

No API, schema, migration, or data-model change. Changes are confined to:

- `.atelier/tokens/field-workbook.tokens.json` (DTCG source) and its compiled output via the pipeline;
- `src/**/*.css`;
- `src/**/*.tsx` markup, for the E.3 IA change and state gap-fills;
- the lint test file(s);
- possibly the orchestrator-root `atelier.config.json` (allowlist widening per Finding 7).

`lizbeth_spanish/atelier.config.json` is never edited.

## Acceptance and validation

### The terminating condition

"100% off legacy" is proven when **all** of the following are simultaneously green. This is the explicit, checkable gate set that answers the user's completion goal; it is not a subjective judgement.

1. The extended deprecation lint passes in build-breaking mode with zero DEPRECATED references and zero out-of-context CONTEXTUAL uses across every `src/**/*.css` file.
2. The pre-existing `tokenFallbackAuditLint` checks still pass: no undefined `var()`, no raw hex outside the two ratified exceptions, no non-zero radius, no blurred shadow.
3. `scripts/verify-token-pipeline.mjs` and `tokenPipelineOracle.test.ts` pass, proving the generated CSS is genuine compiler output and was not hand-edited.
4. `npm run lint`, `tsc --noEmit`, and the full vitest suite pass with no exclusions, and the Supabase local stack is confirmed running. An exclusion-based pass is a failed gate, per the recorded prior incident (Finding 8).
5. The deterministic no-native-dialog source scan passes.
6. Atelier `tokens_validate`, `design_review`, `contrast_check`, and `a11y_audit` return clean over a review allowlist widened to the real `src/**/*.css` surface.
7. Every issue in the closure milestone is closed with recorded evidence.
8. An independent Verifier pass is recorded.
9. A Browser Validator pass per surface against the per-surface visible outcomes (see Browser UI validation below) is recorded, **including a recorded rendered-capture disposition per the protocol below.** No surface is accepted on lint alone.

### Rendered-capture review protocol

Added after judge review: the lint proves token vocabulary is legacy-free, but nothing in the original gate set caught layout, cascade, spacing, or responsive regressions that could ship past a clean lint. This protocol is the compensating control, and it is required for gate 9, not optional polish.

- Every in-scope surface gets a rendered capture at each required viewport (see Browser UI validation), whether or not a pixel baseline exists for it.
- **Where a baseline exists** (D.1, D.2, D.3, D.4, D.9, E.2, E.3, E.4): run `visual_diff` for signal, not verdict, consistent with the authority ordering below. Every non-zero delta receives a written disposition in exactly one of four categories:
  - **Ratified deviation** — cite the specific ADOPTION-PLAN clause that permits it.
  - **Content difference** — the reference artboard shows idealized placeholder content while the app shows real data.
  - **Genuine defect** — file a GitHub issue per the logging policy.
  - **Unexplained** — a stop-and-report condition. An unexplained delta is never silently passed.
- **Where no baseline exists** (D.5, D.6, D.7, D.8, E.1, E.5, E.6, and all eight derived pages): require a side-by-side human or design-reviewer disposition of the capture against the governing artboard, or, for derived pages, against the A+B+C primitives. This disposition produces located findings — element, property, observed versus expected — never a diff percentage and never a vague impression.
- **Fixture masking, a prerequisite for the capture protocol:** mask or hold constant every dynamic region before capture — real student names, live dates, computed progress — so a capture is comparable across runs and across the reference/app pair.

**Coverage ledger, added from a browser-validation pass (2026-09-04).** These are disclosed gaps for Phase 6's artboard-by-artboard pass to close, framed as Phase 6 to-dos, not defects:

| Item | Status | Note |
|---|---|---|
| `.badge` on AdminStudentsPage | Not found | Not present on the pages visited during this pass; re-check during Phase 6. |
| `.course-card` / `.workspace-empty` | State not reached | The relevant states were not reached during this pass, the same cohort-fixture gap recorded in the Modal trigger enumeration. |
| `.owner-feedback-state` placeholder | Displaced before measurement | Real content displaced the placeholder before a computed-style measurement could be taken. |
| `.owner-ledger-row-progress-bar` | Not re-measured | Not re-measured during this pass. |
| `visual_diff` against D.7 | Not run | The validator could not identify which rendered element D.7's baseline is meant to cover. |

Phase 6 must resolve each row above to a located finding or a confirmed pass before gate 9 is recorded for the surfaces they belong to.

### Authority ordering

Stated explicitly because the user asked which engine is authoritative.

- The extended deterministic lint (gate 1 above) is **authoritative** for "this is legacy." It is the only mechanically complete, repeatable, non-subjective detector.
- Atelier `design_review`, `design_critique`, `contrast_check`, and `a11y_audit` are **corroborating**. They can raise findings the lint cannot, but do not by themselves establish legacy status.
- `screenshot` + `visual_diff` against the DS-derived baselines is **non-authoritative for pass/fail** and must never auto-fail a surface. The reference artboards show idealized placeholder content while the app shows real data, so a numeric diff conflates content difference with design defect. Its legitimate role is detecting structural divergence; its output routes to human/design triage against the ADOPTION-PLAN's ratified-deviations section. A delta that section already permits is recorded as ratified, not as a defect.
- Deterministic failures always dominate any judge or visual result.

## Risks and rollback

Overall risk: **medium.**

1. **The lint flips to build-breaking before every site is migrated, blocking all work.** Mitigation: the report-only-first sequencing in Phase 1.
2. **A blanket `--shadow-print` → `--shadow-brass` swap is applied without per-site elevation classification**, which would be wrong at most sites. Mitigation: the explicit engineering invariant (design handoff section e) and the documented classification pass.
3. **Re-remediating already-conformant selectors on the strength of stale plan documents.** Mitigation: the recorded stale-claim correction in the design review record and the Phase 0 re-verification requirement.
4. **Browser validation is unavailable (Finding 9).** This blocks surface acceptance and must be reported, never worked around by accepting source-level evidence alone.
5. **An unscoped `taskkill` causes collateral damage (Finding 10).** Mitigation: mandatory scoped-PID instruction and dev-server reuse.
6. **A falsely-reported full test pass via silent exclusion.** Mitigation: gate 4's explicit no-exclusions requirement.
7. **Plan staleness across a long multi-issue execution.** Any material repository or evidence change requires `JOB_BLOCKED: Plan stale` and re-planning or explicit reapproval, not silent reconciliation.
8. **A page-scoped override keyed on a shared class name leaks across pages**, found by a browser-validation pass (2026-09-04): `CourseWorkspace.css:11` scopes `.workspace-panel .demo-button.primary` to protect the owner page, but `.workspace-panel` is a shared class, and `PublicCatalogPage.tsx:125` also wraps the unauthenticated "Request enrollment" button in it — the only live `.demo-button.primary` consumer in the app. This is an instance of the documented cascade-collision hazard class, mirrored: instead of a page-specific selector in a shared rule list, it is a shared class name captured by a page-scoped rule. Mitigation: the C.1 Primary fix in progress (D-8 amendment above) is expected to make this override moot once both `.demo-button.primary` occurrences carry identical brass treatment, at which point the scoped override can be deleted. Tracked as GitHub issue #101.

**Rollback:** every migration step is an independently revertable CSS/token edit. The token pipeline oracle makes a bad token change immediately detectable. Issue actions are reversible. No schema, data, or irreversible state is involved.

## Assumptions and decisions

**Stated evidence limit.** `gh` is not on the read-only planning tool surface, so no live GitHub state was read during planning. The closure status of #31-#44, the current state of #66/#67/#71-#75, the existing label and milestone inventory, and the correct next issue numbers are all unverified. Phase 0 resolves this and is a stop-and-report gate, not an assumption to proceed past. Where a live read contradicts this plan, the live read wins.

**Safe assumptions.** The dev server runs at `http://localhost:5173` via `npm run dev`. The dev-only quick-select panel provides authenticated student access.

**Explicit open items, not assumptions.**

- The owner/admin credential path was not confirmed during planning (Finding 8).
- Browser tooling health is uncertain (Finding 9).
- Eight unresolved decisions carried from the design handoff: E.3 Lesson-tab content parity vs. reduction; self-check/copyright placement within the E.3 tabs; exact copy for the five new `LearnDetailPage` state strings; offline-behaviour policy; `--border-width-hairline` and `--border-width-accent` contexts; `--shadow-muted-card` context; the per-site `--shadow-print` elevation classification pass; and the disposition of the stale `App.css:775-777` comment.

None of these open items block approval of this plan; all must be resolved before the specific work item that depends on them.

### Decision register

Added after judge review: the eight deferred decisions above had no owner, deadline, or gate, and Phase 4 (E.3) is required work while its central IA decision stays open. Each row below carries an explicit no-dispatch gate: no T1 job depending on a given decision may be dispatched until that decision is resolved.

| ID | Decision | Owner / required approver | Alternatives | Blocks | No-dispatch gate |
|---|---|---|---|---|---|
| D-1 | E.3 mobile Lesson-tab content: full parity with D.3 desktop content, or a deliberately reduced condensed set | User (product) | Full parity; reduced set | Phase 4 (E.3), critical path — this decision materially changes Phase 4's scope and cannot be resolved by engineering judgement | **RESOLVED: full parity.** The E.3 mobile Lesson tab carries full content parity with the D.3 desktop content, not a reduced condensed set. This is the larger of the two alternatives and sets Phase 4's scope accordingly. The no-dispatch gate on Phase 4 is lifted for this decision and for D-2 — see D-2's own resolution below. |
| D-2 | Self-check/copyright placement within the E.3 tabs | User (product) | Within Lesson tab; within Files tab; standalone | Phase 4 (E.3) | **RESOLVED, 2026-09-04: not present on E.3.** A DS investigation of `Field Journal DS.dc.html` — full rendered `innerText` extraction of the E.3 artboard plus a direct read of source lines 1382-1428 — found self-check content and the copyright/legal notice appear **nowhere on E.3**: not in the Lesson tab, not in Cards or Files, not in the header or sticky footer. No occurrence of "self-check," "quiz," "check your understanding," "copyright," "rights reserved," or "©" anywhere in the artboard. Consequence, stated precisely: this decision was framed as a placement question among three alternatives, and **all three are wrong** — the DS does not place this content on mobile at all. If Phase 4 needs it, that requirement must come from the D.3 desktop artboard or be recorded as a net-new mobile decision, not treated as a DS-specified placement. The no-dispatch gate on Phase 4 is lifted. |
| D-3 | Exact copy for the five new LearnDetailPage state-copy strings | User (product) | N/A — copy authoring | Phase 5 (LearnDetailPage 8-state lesson model) | **RESOLVED.** These five strings are not unwritten copy — they are already live in `src/pages/LearnDetailPage.tsx`, so this decision ratifies existing strings rather than authoring new ones. Per-string disposition, with current source locations: (1) `on-hold` — label "Paused by your instructor" (`LearnDetailPage.tsx:100`), body at line 86, RATIFIED AS-IS; note the `get_student_learn_course` RPC deliberately merges `held` and `revoked` into a single calm `paused` value server-side (documented at lines 17-19), so a student whose access was revoked sees "paused" — the user was shown this explicitly and ratified it. (2) `prerequisite-incomplete` — label "Not yet available" (line 103), hint "Requires "X" first" (line 245), body "Complete "X" first to unlock this lesson." (line 88), RATIFIED AS-IS, including the acknowledged hint/body redundancy. (3) `unavailable-unspecified` — label "Not yet available" (line 103), body "This lesson is not currently available." (line 90), RATIFIED AS-IS, including the acknowledged lack of an actionable next step. (4) `unlocked-pending-quiz` — **CHANGE REQUIRED.** Current note is "No action needed here." (`LearnDetailPage.tsx:251`); the defect is that this state means the lesson completes via its quiz rather than the Mark-complete button (`deriveLessonState`, line 60, on `completion_rule !== 'view'`), so "No action needed here" misleads the student into thinking the lesson needs nothing from them when it does. Proposed replacement, to be confirmed by the user or product before the Phase 5 T1 job lands it: "This lesson completes when you finish its quiz." The label "Available now" is unchanged; only the note string changes; the exact replacement wording remains adjustable, and the binding requirement is that the string must not imply the lesson requires no action from the student. (5) `date-locked-cohort` — label "Locked" (line 98), hint (lines 237-239), body "This lesson unlocks on {date}, when your cohort's course starts." (line 83), RATIFIED AS-IS, including the ratified distinction whereby the locked-by-date family labels "Locked" while the prerequisite and unspecified states label "Not yet available." |
| D-4 | Offline-behaviour policy (not evidenced in the DS) | User (product) | Explicit offline state; degrade silently; block interaction | Phase 5 (offline/permission-denied pattern) | **RESOLVED: fold offline into the existing error state.** No distinct offline state, no `navigator.onLine` detection, no new design vocabulary. A connectivity failure surfaces through the existing single error path at `LearnDetailPage.tsx:336-353` — the `role="alert"` message "This course page could not be loaded. Please try again, or return to your courses list." Grounds: it keeps one error surface, introduces no pattern the Field Journal DS does not specify, and matches the `AdminShell.tsx:30` permission-denied precedent that the design handoff already names as the tone and structure model. Accepted tradeoff: a student who is offline gets a generic failure message rather than a diagnosis of their connectivity. |
| D-5 | `--border-width-hairline` permitted context | Design reviewer, pending Phase 0 `tokens_diff` reconciliation | Context as inferred in Phase 1's operationalized-contexts subsection; alternative context if `tokens_diff` surfaces one | Phase 1 closure; any Phase 3 site using this token | No Phase 3 T1 job migrating a hairline-border site dispatched until the provisional context is confirmed or replaced |
| D-6 | `--border-width-accent` permitted context | Design reviewer, pending Phase 0 `tokens_diff` reconciliation | Same as D-5 | Phase 1 closure; any Phase 3 site using this token | No Phase 3 T1 job migrating an accent-border site dispatched until the provisional context is confirmed or replaced |
| D-7 | `--shadow-muted-card` permitted context | Design reviewer | Muted/disabled/neutral-only (stated as the working rule in Phase 1); broader use | Phase 1 closure; any Phase 3 site using this token | No Phase 3 T1 job migrating a muted-card-shadow site dispatched until confirmed |
| D-8 | Per-site `--shadow-print` elevation classification pass | Design reviewer | Per-site classification per A.3 elevation role (no blanket swap permitted regardless of outcome) | Phase 3, every `--shadow-print` migration site | **RESOLVED, all 12 of 12 sites cleared.** The 9 sites (8 token-substitution sites plus row 7's three-way disposition) cleared during planning remain cleared and unchanged by this amendment. The 3 previously gated sites (`App.css:604`, `App.css:609`, `CourseWorkspace.css:15`) cleared on 2026-09-04 via the C.1 Primary ruling. See the "D-8 resolution" subsection and the "D-8 amendment — C.1 Primary ruling" entry immediately below this table for the full classification and the ruling record. The no-dispatch gate is lifted for all 12 sites. |
| D-9 | Disposition of the stale `App.css:775-777` comment | Engineering (T1/T2), informational only | Correct the comment; remove it | Phase 3, `App.css` cleanup | Not blocking; may be resolved opportunistically during any `App.css` migration job |

#### D-8 resolution — per-site `--shadow-print` classification (design review PASS)

Resolved during planning by the design fleet: classification produced by the compact design role and independently gated by design-reviewer, which returned PASS after one evidence-backed revision cycle. As with the rest of this plan, `--shadow-print`'s deprecated status is **reference-inferred** from design review, not file-annotated; this section does not upgrade that status to file-confirmed.

The authoritative site list is the frozen enumeration in `lizbeth_spanish/docs/token-deprecation-baseline/phase1-baseline.json`, which contains exactly 12 `--shadow-print` findings.

**A.3 elevation table**, quoted from `lizbeth_spanish/design/field-journal/Field Journal DS.dc.html` lines 137-155 (restated at `ADOPTION-PLAN.md` lines 66-72):

| Level | Spec | Used by |
|---|---|---|
| rule.thin | 2px ink.1000, no shadow | inputs, list rows, inline chips |
| card | 3px rule + 5px 5px 0 0 ink.1000 | week cards, panels, index cards |
| sheet | 3px rule + 8px 8px 0 0 ink.1000 | page sheets, modals, dashboards |
| brass | 3px rule + 5px 5px 0 0 brass.500 | owner tables, download links (legacy print) |

**CLEARED for Phase 3 T1 dispatch — token substitution (8 sites).**

| File | Line | Selector | A.3 elevation role | Replacement | Grounds |
|---|---|---|---|---|---|
| `src/App.css` | 362 | `.app-header` | none of card/sheet/brass — page chrome | **remove the `box-shadow` declaration entirely** | No A.3 "Used by" list covers a chrome bar; independently, `App.css:787` (`.app-header { border-bottom: 0; box-shadow: none; }`) is a later same-specificity rule already setting `box-shadow: none`, so line 362's shadow is dead in the shipped cascade. |
| `src/App.css` | 592 | `.demo-button` (base rule) | card — default control tier | `--shadow-card` | `ADOPTION-PLAN.md:240` (corrected 2026-09-04) — "one geometry for all four tiers: 3px rule, zero radius, 5px hard shadow, 48px tall," with shadow colour split per-tier: Primary brass, all other tiers ink. Base unmodified `.demo-button` is the shared default (Secondary) tier geometry before modifiers, which takes the ink/`--shadow-card` shadow both before and after the correction. Not an owner table or download link. |
| `src/App.css` | 790 | `.demo-button` (compact-header override) | card | `--shadow-card` | Same rule and role as line 592; a later-cascade restatement of identical base button geometry. |
| `src/App.css` | 789 | `.app-header-logo` | card | `--shadow-card` | A.3's card row covers badge/mark-scale bordered elements ("week cards, panels, index cards"); not a page sheet/modal/dashboard, not an owner table or download link. rule.thin is dismissed because it specifies no shadow, whereas this selector declares one. See caveat 1. |
| `src/pages/AdminStudentsPage.css` | 469 | `button.destructive, button.caution` | card — non-Primary control tier | `--shadow-card` | `ADOPTION-PLAN.md:240` (corrected 2026-09-04 to state the shadow-colour split explicitly — Primary brass, all other tiers ink — rather than one shared `shadow.card`) still covers the Caution tier under the shared-geometry statement; Caution is not Primary, so it takes the ink/`--shadow-card` shadow both before and after the correction. Neither tier is C.1's Primary (the only tier assigned brass, at line 241, unchanged), and neither is an owner table or download link, so brass is excluded on both grounds. |
| `src/pages/CourseWorkspace.css` | 1 | `.course-card, .workspace-panel, .workspace-empty, .authoring-block` | card | `--shadow-card` | A.3's card row explicitly lists "week cards, panels, index cards"; two of the four selectors (`.course-card`, `.workspace-panel`) match literally, and `.workspace-empty`/`.authoring-block` share the same rule's declarations by construction. |
| `src/components/ResourcesPanel.css` | 21 | `.resources-panel` | brass | `--shadow-brass` | The file's own header comment (lines 1-15) identifies this as a rail of download links, matching A.3's brass scope ("owner tables, download links (legacy print)"); its border was already corrected to `--border-width-rule` + `--color-brass-500` in a prior cycle. The one unambiguous brass site in the baseline. Rendered value is unchanged, but token identity must still move because `--shadow-print`/`--shadow-brass` are unlinked near-identical literals, not aliases. |
| `src/pages/OwnerFeedbackPage.css` | 63 | `.owner-feedback-list, .owner-feedback-detail, .owner-feedback-state` | sheet | `--shadow-sheet` | The border at this line is already migrated to `--border-width-rule` + `--color-ink-1000` — not brass-coloured, itself evidence against brass. These three selectors form the full-page two-column owner-feedback dashboard layout (`grid-template-columns: minmax(0,3fr) minmax(0,2fr)` at line 54), matching A.3's sheet row ("page sheets, modals, dashboards") rather than the embedded-panel card tier. |

**CLEARED — row 7, `src/App.css:833` `.login-form-container, .demo-section, .admin-shell` (one compound rule). Three-way disposition; none requires a token substitution:**

- `.admin-shell` — neutralized by the countermand at `App.css:837` (`.admin-shell { border: 0; box-shadow: none; }`). No action.
- `.login-form-container` — **DEAD.** A repo-wide grep across `src/**/*.tsx` and `src/**/*.ts` returns zero DOM/className consumers; the only hits are this CSS declaration and test files regex-matching raw CSS text. `LoginForm.tsx:78` shows the live login container class is `.auth-sheet-card`, which carries its own independent already-migrated rule at `LoginForm.css:243-245`. Remove from the shared selector list per the precedent documented at `App.css:807-819` for `.admin-students-page` and `.feedback-form`. Do **not** assign it a shadow token.
- `.demo-section` — **DEAD.** Same zero-consumer evidence, same disposition, same precedent. Do **not** assign it a shadow token.

**GATED — ruling required before dispatch (3 sites):** `src/App.css:604` `.demo-button.primary:hover`; `src/App.css:609` `.demo-button.primary:active`; `src/pages/CourseWorkspace.css:15` `.workspace-panel .demo-button.primary`.

Blocking question of record: `ADOPTION-PLAN.md:240` assigns `shadow.card` to "all four [C.1] tiers" while line 241 assigns Primary a `brass.500` shadow. C.1 does not resolve this — it is the source of the contradiction. D-8's binding constraint separately restricts `--shadow-brass` to owner tables and download/export links, which a Primary action button is not. A ruling must decide either (a) Primary is a sanctioned narrow exception to the brass-scope restriction, or (b) `ADOPTION-PLAN.md:241` is corrected to `shadow.card` to match line 240. This is a design-system content ruling, not an engineering judgment call; **T1 must not resolve it unilaterally.**

**Paired border and colour migration — does D-8 change it?** No. D-8 fixes shadow-token identity only. The co-located `--border-width-strong` and `--color-ink-800`-as-border findings at these call sites remain separate open baseline items with their own token targets, and the engineering invariant "migrate border + shadow + colour as one unit per call site" still governs: the executing job must land shadow, border-width, and border-colour together at each live site. Specifics: the sites at `App.css:592`/`790`, `App.css:789`, and `AdminStudentsPage.css:469` each pair a live `--shadow-print` with a `--border-width-strong` and/or `--color-ink-800`-as-border finding at the same line and must be migrated together, never shadow-only. `CourseWorkspace.css:1` pairs with a `--color-ink-800`-as-border finding at the same nominal line; the gated `CourseWorkspace.css:15` pairs with one at adjacent line 14. `ResourcesPanel.css:21` and `OwnerFeedbackPage.css:63` already had border and colour migrated in prior cycles, so no paired border work is needed there — shadow token only. Row 7's two dead selectors are exempt: removing them from the shared list sheds their border and shadow declarations together, resolving their co-located findings as a side effect rather than leaving them open.

**Recorded caveats:**

1. `.app-header-logo` (App.css:789) ships as classified, but one stated ground is factually wrong and is corrected here: the packet claimed the selector's 3px border width was inconsistent with rule.thin. `src/tokens/field-workbook.generated.css:39` defines `--border-width-strong: 2px`, which in fact matches rule.thin's "2px ink.1000" spec. Only the presence of a box-shadow is genuinely inconsistent with rule.thin. The `--shadow-card` assignment stands on the A.3 badge/mark-scale reading; the border-width argument should not be relied on.
2. Possible baseline status discrepancy at `App.css:362`: a later same-specificity override at line 787 already sets `box-shadow: none`, structurally identical to the `.admin-shell` 833/837 pattern that the baseline marks "neutralized," yet this finding is marked "open." Flagged for the baseline owner to re-verify. The baseline's authoritative status field was not altered.

#### D-8 amendment — C.1 Primary ruling (2026-09-04)

Resolved by direct investigation of `lizbeth_spanish/design/field-journal/Field Journal DS.dc.html`, per the user's delegation of this ruling to that investigation rather than to a choice between the plan's two prior options (a)/(b) recorded in the "GATED" note above.

**Evidence, verbatim from the DS file:**

- Line 332, C.1 section prose: "Four tiers, one geometry: 3px rule-black outline, zero radius, 5px hard shadow, 48px tall. Hover lifts onto the shadow; press sinks into it."
- Line 336, Primary specimen inline style: `box-shadow: 5px 5px 0 0 #a07e48;` (brass). Line 337 caption: "Ink fill, brass shadow. One per view."
- Line 341, Secondary specimen: `box-shadow: 5px 5px 0 0 #1a1512;` (ink). Line 342 caption: "Paper fill, ink shadow. The default."
- Lines 347-348, both Caution specimens: ink shadow; only fill differs (amber reversible, terracotta irreversible, per line 350).
- Rendered and measured in Chromium: the Primary specimen computes to `rgb(160, 126, 72) 5px 5px 0px 0px`; Secondary/Caution/Focused all compute to `rgb(26, 21, 18) 5px 5px 0px 0px`.
- A.3 elevation table, lines 152-154: the brass row is labelled "brass · legacy print," scoped to "owner tables and download links." Its swatch computes to `rgb(160, 126, 72) 5px 5px 0px 0px` — bit-identical to the C.1 Primary specimen. The card swatch computes to `rgb(26, 21, 18) 5px 5px 0px 0px`.
- App tokens, `src/tokens/field-workbook.generated.css`: `--shadow-brass` = `5px 5px 0 0 #a07e48` (exact match to the Primary specimen); `--shadow-card` = `5px 5px 0 0 #1a1512`; `--shadow-print` = `.3rem .3rem 0rem 0rem #a07e48` = 4.8px at a 16px root, a brass-toned near-equivalent that is not the DS value.

**Ruling:**

- Line 332's "one geometry" is a shape claim only — 5px offset, zero blur, zero radius, 48px height shared across all four tiers — not a token/colour claim. The per-tier specimens diverge deliberately in shadow colour: brass for Primary, ink for every other tier. Read as written, the DS is internally consistent on this point.
- `ADOPTION-PLAN.md:240` mis-transcribed the geometry statement as "`shadow.card` applies to all four tiers." Line 241 ("Primary = `ink.900` fill + `brass.500` shadow") is correct as written. The adoption plan does not contradict the DS twice; line 240 was wrong and line 241 was right. Line 240 is corrected in this same pass (see `ADOPTION-PLAN.md` edit record); line 241 is untouched.
- A.3's brass-row annotation under-scopes actual usage: it names owner tables and download links only, but C.1 independently and explicitly assigns the same brass value to the Primary control tier. Where A.3 and C.1 disagree on scope, **C.1 governs for buttons** because it is the component specification and its rendered specimen is unambiguous. A.3's "legacy print" note is preserved as a warning against *spreading* brass beyond Primary, owner tables, and download links — not as a prohibition on Primary.

**Disposition — the 3 previously gated sites now clear to brass:**

| File | Line | Selector | Disposition |
|---|---|---|---|
| `src/App.css` | 604 | `.demo-button.primary:hover` | `--shadow-brass-press` (C.1 hover-lift state on the brass family) |
| `src/App.css` | 609 | `.demo-button.primary:active` | `--shadow-brass-none` (C.1 press-sink state on the brass family) |
| `src/pages/CourseWorkspace.css` | 14-15 | `.workspace-panel .demo-button.primary` | `--shadow-brass` at rest |

The state-to-token mapping follows the in-repo precedent at `.learn-detail-legacy-cta` (`src/pages/LearnDetailPage.css:56-78`), previously remediated "to C.1 PRIMARY tier values verbatim" using exactly these three tokens — `--shadow-brass`, `--shadow-brass-press`, `--shadow-brass-none` — confirmed present in that file. The executing T1 job confirms the exact mapping against that precedent and the C.1 text at implementation time.

**Rest-state consequence, in scope for the same fix:** `.demo-button` base (`App.css:592`) was correctly migrated to `--shadow-card` under D-8's original 8-site clearance (Secondary is "the default," per the C.1 Secondary line in `ADOPTION-PLAN.md`). Consequently `.demo-button.primary` no longer inherits a brass shadow at rest through the cascade and must declare `--shadow-brass` explicitly at rest, not only at hover/active.

**Brass-scope count correction:** the D-8 resolution table above lists exactly one brass site (`ResourcesPanel.css:21`). That count is superseded by this ruling: brass scope is now the Primary control tier (3 sites — `App.css:604`, `App.css:609`, `CourseWorkspace.css:14-15`) plus `ResourcesPanel.css:21`, four sites total across the 12-site `--shadow-print` baseline.

**Risk-register and judge-history status:** risk item 2 above ("a blanket `--shadow-print` → `--shadow-brass` swap ... would be wrong at most sites") and the D-8 resolution's original finding (9 of 12 sites cleared to non-brass tokens, 3 gated) both stand unchanged. This ruling adds the Primary control tier to brass scope on C.1-specific, DS-grounded evidence; it does not reopen or alter the card/sheet dispositions for any of the other 9 cleared sites.

**D-8 status: fully resolved.** All 12 of 12 baseline `--shadow-print` sites now carry a design-system-grounded disposition. No `--shadow-print` migration site remains gated.

Phase 0 remains the stop-and-report gate for credentials and tooling health specifically (Finding 8, Finding 9); those are discovery blockers, not approval prerequisites, and this placement was confirmed correct during judge review. The decision register above is a separate, additional gate layered on top of Phase 0, governing product and design decisions rather than environmental readiness.

**Decision — the request's incremental-migration-behind-the-token-layer assumption is overturned on evidence** (Finding 1) and replaced by a defect-driven conformance closure loop.

**Decision — `DESIGN_ROUTE` is standard, not studio**, because the creative direction is already fixed.

## Judge route

`PLAN_DUCK` is eligible and recommended before user approval, per `docs/JUDGE-CONTRACT.md`. This is a high-fan-out plan whose deprecation registry becomes machine-enforced across 52 files, so a completeness-and-correctness challenge — is any token unclassified, is any verdict wrong — has real value, mirroring the ADOPTION-PLAN's own successful plan-judgement checkpoint.

A per-issue `CODE_REVIEW` checkpoint is optional and should be reserved for the token-registry lint change (Phase 1) and the E.3 IA change (Phase 4) specifically, not spent on routine per-site token swaps.

Standing call caps apply per `docs/JUDGE-CONTRACT.md`. Deterministic failures always dominate the judge. No judge pass is promised by this plan, and no model-generated finding is asserted here in advance of an actual judge run.

## Judge route and disposition

`PLAN_DUCK` ran on this plan per `docs/JUDGE-CONTRACT.md`. Verdict: **REVISE**, six major findings. Policy action: **advisory (shadow mode), non-blocking** — this run does not gate approval, and this section records a quality-improvement pass, not a hard block. One judge-driven remediation loop was spent against the standing call caps.

Deterministic failures always dominate a judge result, and no judge finding altered this plan's scope. The six findings below were dispositioned as follows, each cross-referenced to the section of this document where the remediation now lives.

| ID | Substance | Disposition |
|---|---|---|
| J-01 | Termination-universe: the authoritative detector originally covered only `src/**/*.css` token references, leaving other styling-bearing source forms (`.tsx` token references, inline styles, CSS-variable indirection, deprecated components) unproven. | **Accepted as a proof gap; the judge's implication that the legacy universe may be materially larger is rebutted on measurement.** Re-verification during this pass found deprecated-token references in production `.tsx` at **zero** (all matches are in `src/__tests__/` and assert absence, e.g. `fjdsFreshAuditFindingA.test.tsx:114,173-175`, `AdminStudentsPage-issue42-screenComposition.test.tsx:54-59`) and inline `style={{}}` sites at **seven** across six files, every one a dynamic runtime value (e.g. `BrandDesignPage.tsx:31`, `FlashcardsViewer.tsx:133`, `SegmentLedger.tsx:89` — full list in the legacy-universe subsection). Scope does not grow; the gap is proof, not migration work. See "The complete legacy universe (five vectors)" (Background and repository findings) and the Phase 1 pinning-guard additions. |
| J-02 | Visual-compensation: nothing replaced `visual_diff` after it was demoted to non-authoritative, so layout, cascade, spacing, and responsive regressions could ship past a clean lint. | **Accepted in full.** See "Rendered-capture review protocol" (Acceptance and validation), including the four-category disposition scheme for baseline surfaces, the located-findings requirement for non-baseline surfaces, and the fixture-masking prerequisite. Gate 9 now explicitly requires a recorded capture disposition; no surface is accepted on lint alone. |
| J-03 | Registry-exceptions: the deprecation registry lacked a formal schema, operationalized contexts for three inferred entries, an exception mechanism, and a fixed triage denominator. | **Accepted, not deferred** — report-only-first sequencing was judged sound and stands; the gap was specification, cheap to close before Phase 1. See the registry schema, operationalized-context rules, exception record format, and triage baseline added to Phase 1 (Ordered work). |
| J-04 | Browser-coverage: the per-surface validation table omitted six derived pages and the D.1/E.1 and D.4/E.4 baseline-backed surfaces, and named modal-focus and reduced-motion checks globally without enumerating the specific journeys/transitions they apply to. | **Accepted in full — the highest-value fix.** See the nine new rows added to the Browser UI validation table, the Modal trigger enumeration, the Reduced-motion transition enumeration, and the two-part No-native-dialog gate (source scan plus runtime confirmation), all under Browser UI validation. |
| J-05 | Stale-evidence-reverify: the plan states Findings 1-10 were not independently re-verified, then relies on them for exclusion/preservation decisions, while Phase 0 only checks GitHub state, tokens, and environment health. | **Accepted in full.** See the Static re-verification deliverable added to Phase 0 (Ordered work), covering selector/token inventory, import/cascade review, and page-to-route inventory, with explicit re-confirmation of the four excluded selectors and the preserved `.admin-shell-nav` before any dependent migration work. |
| J-06 | Open-decision-governance: the eight deferred decisions from the design handoff had no owner, deadline, or gate, and Phase 4 (E.3) is required work while its central IA decision stays open. | **Accepted.** See the Decision register (Assumptions and decisions), with D-1 (E.3 full-versus-reduced mobile Lesson tab) marked critical path, and the user named as required approver for the five copy strings and the offline policy. The judge separately confirmed Phase 0's placement as the stop-and-report gate for credentials and tooling is correct and that those are discovery blockers rather than approval prerequisites; that agreement is recorded in the Decision register's closing note. |

## Browser UI dialog policy

Required. No native `alert`, `confirm`, `prompt`, their `window.*` forms, or `beforeunload` anywhere in this browser-rendered React UI, in any existing or newly gap-filled state, including every destructive and validation path.

Acknowledgement and confirmation use the app-owned accessible modal: focus trapped while open, focus returned to trigger on close, Escape plus an explicit close control, never backdrop-only dismissal, visible 3px slate focus ring at every stop. Inline validation per the C.2 pattern is preferred wherever the DS already shows an inline pattern.

A deterministic no-native-dialog source scan plus modal keyboard/focus verification is a required gate on every browser UI job under this plan.

## Browser UI validation

- **Launch/readiness:** `npm run dev` in `H:\CommandCenter\orchestrator\lizbeth_spanish`; ready when the login route renders. Reuse an existing healthy dev server rather than restarting it; never `taskkill`; scoped-PID termination only if termination is genuinely required.
- **Base URL:** `http://localhost:5173`.
- **Fixture/reset:** dev-only seeded quick-select panel (`LoginForm.tsx:123-138`) for authenticated student surfaces, using real seeded Supabase Auth accounts. Local Supabase stack must be confirmed running. Owner/admin credential path is an open item to be resolved at Phase 0 — if real credentials are required and absent, that is a blocker for owner-surface validation specifically, to be reported rather than guessed around. No fabricated fixture data.
- **Baseline coverage limit (Finding 6), stated plainly:** pixel baselines exist only for D.1, D.2, D.3, D.4, D.9, E.2, E.3, E.4. D.5, D.6, D.7, D.8, E.1, E.5, E.6 and every derived page have no pixel baseline and are validated by textual/structural criteria only.

### Per-surface journeys, viewports, and visible outcomes

Viewports: 1440-wide for D.x surfaces, 390-wide for E.x surfaces. Where a captured baseline exists, use the exact `.atelier/reference-harness/manifest.json` dimensions rather than a blanket 1440x900: D.2 1446x1041, D.3 1446x1645, D.9 1446x991, E.2 396x850, E.3 396x850.

| Surface | Journey | States to exercise | Viewport | Pass criteria |
|---|---|---|---|---|
| D.2/E.2 Roadmap | Load roadmap as authenticated student | loaded, empty (no cohort), locked/unlocked weeks | 1446x1041 / 396x850 | Conforms to ratified tokens; no legacy trio; states render per C.4 |
| D.3/E.3 Week detail | Open a week, navigate lesson content | loaded, locked, progress states | 1446x1645 / 396x850 | Desktop conforms; mobile (E.3) implements the tab control, progress indicator, register-note callout, and sticky footer per design handoff (b) |
| D.5/E.5 Feedback | View/submit feedback | loading, empty, error, success | 1440x900 (no baseline) / 390x* (no baseline) | Structural/textual conformance only; states per Phase 5 spec |
| D.6/E.6 Owner dashboard | Owner views dashboard and nav | loaded, hamburger + tab-row coexistence on E.6 | 1440x900 (no baseline) / 390x* (no baseline) | Hamburger and nav row both present per design-review correction; no legacy trio |
| D.7 Admin students | Admin views roster (desktop only) | loaded, empty, error | 1440x900 (no baseline) | Already-conformant per Finding 4/design review; no re-touch beyond confirmed legacy sites |
| D.8 Brand design | View brand reference page (desktop only) | loaded | 1440x900 (no baseline) | No legacy trio |
| D.9 Catalog | Unauthenticated catalog browse (desktop only) | loaded | 1446x991 | Conforms; no E.9 counterpart exists |
| LearnIndexPage / LearnDetailPage | Student learn flow | loading, empty (JournalEmptyState reuse), error (role=alert), 8-state lesson model | 1440x900 / 390x* (no baseline; derived pages) | States per design handoff (d); five new copy strings flagged for product sign-off before final acceptance |
| D.1/E.1 Sign-in | Unauthenticated sign-in, including the dev quick-select panel | default, validation error, submitting | 1440x900 (baseline exists) / 390x* (no baseline for E.1) | Conforms; no legacy trio. Reachable unauthenticated, so this is the cheapest genuine end-to-end check in the set — run first as the mechanism proof for the rest of this table. |
| D.4/E.4 Flashcards | Student reviews a flashcard deck | loaded, empty deck, card flip/advance | 1440x900 (baseline exists) / 390x* (baseline exists) | Conforms; no legacy trio |
| OwnerFeedbackPage | Owner views submitted feedback | loading, empty, error, loaded | 1440x900 (no baseline) | Structural/textual conformance; depends on Phase 0 owner-credential resolution |
| CourseWorkspacePage | Owner edits a course's lessons | loaded; lesson removal (immediate, unconfirmed — `caution-reversible` tier, no modal); Apply-reconciliation / "Release this lesson?" / "Revoke access to this lesson?" / ModeSwitchModal (all untested — see Modal trigger enumeration) | 1440x900 (no baseline) | No legacy trio; lesson-removal action is correctly unconfirmed per C.1's reversibility split, not a gap; the four cohort-gated modal journeys require a cohort-plus-enrollment fixture (Phase 6 prerequisite) before their modal checks can be completed; depends on Phase 0 owner-credential resolution |
| CourseSettingsPage | Owner edits course settings | loaded, validation error, saved | 1440x900 (no baseline) | No legacy trio; depends on Phase 0 owner-credential resolution |
| NewCoursePage | Owner creates a course | empty form, validation error, submitting | 1440x900 (no baseline) | No legacy trio; depends on Phase 0 owner-credential resolution |
| BusinessSettingsPage | Owner edits business settings | loaded, validation error, saved | 1440x900 (no baseline) | No legacy trio; depends on Phase 0 owner-credential resolution |
| OwnerSettingsPage | Owner edits account/brand settings | loaded, brand-colour picker (dynamic inline style, not a token site) | 1440x900 (no baseline) | No legacy trio; depends on Phase 0 owner-credential resolution |

### Modal trigger enumeration

Named globally in the prior draft but not made checkable. The following journeys open a modal and each requires the full check below: focus moves into the modal on open; focus is trapped while open; focus returns to the triggering element on close; Escape closes it; an explicit close control exists; backdrop-only dismissal does **not** occur; the 3px slate focus ring is visible at every stop.

- AdminStudentsPage delete-student confirmation. **Escape does not close this dialog**, found by a browser-validation pass (2026-09-04); focus-trap, focus-return-to-trigger, and backdrop-click rejection all pass. Refined by concurrent characterization work: this is a deliberate `suppressDismiss={true}` safety decision (documented prior Codex rationale J-35-001), not an unintentional gap — see Phase 5's pattern-5 entry for the full finding and the conflict it raises against this plan's Browser UI invariant. Awaiting user ruling. Tracked as GitHub issue #100.
- ~~CourseWorkspacePage delete-lesson confirmation.~~ **CORRECTED, 2026-09-04: does not exist.** A browser-validation pass against `CourseWorkspacePage.tsx` (~line 139) found lesson removal in the Outline tab is an immediate, unconfirmed action at tier `caution-reversible`, not a modal-gated one. This is **consistent with C.1**, not a gap: C.1 splits caution by reversibility ("Amber = reversible. Terracotta = not."), and reversible actions do not require confirmation. Row struck.
- ~~CourseWorkspacePage unsaved-changes confirmation.~~ **CORRECTED, 2026-09-04: does not exist.** No unsaved-changes modal is present in `CourseWorkspacePage.tsx`. Row struck.
- CourseWorkspacePage **Apply reconciliation** modal. **Status: untested.** Added 2026-09-04. The local seed has zero cohorts (`select * from cohorts` → 0 rows), so the browser validator could not reach this journey.
- CourseWorkspacePage **"Release this lesson?"** confirmation modal (~`CourseWorkspacePage.tsx:480`). **Status: untested**, added 2026-09-04, same cohort-fixture gap.
- CourseWorkspacePage **"Revoke access to this lesson?"** confirmation modal (~`CourseWorkspacePage.tsx:480`). **Status: untested**, added 2026-09-04, same cohort-fixture gap.
- CourseWorkspacePage **ModeSwitchModal** (cadence mode switch). **Status: untested**, added 2026-09-04, same cohort-fixture gap.
- ~~Any "Why locked?" or "Why isn't this available?" disclosure that resolves to a modal rather than an inline expansion.~~ **RESOLVED, not applicable.** Read directly from `src/pages/LearnDetailPage.tsx` during the approval walkthrough: `LockedDisclosure` (`LearnDetailPage.tsx:168-202`) is an inline expansion using `aria-expanded` / `aria-controls` against a `role="region"` panel, with Escape handling that returns focus to the toggle. It does not resolve to a modal. This row is struck. Phase 0 no longer needs to confirm it.

**Corrected count, 2026-09-04:** the modal-trigger list is the five genuine modal triggers enumerated above — one on AdminStudentsPage (reached and checked, with the Escape defect noted) and four on CourseWorkspacePage (Apply reconciliation, "Release this lesson?", "Revoke access to this lesson?", ModeSwitchModal — all untested pending the fixture below). The two previously listed CourseWorkspacePage rows (delete-lesson, unsaved-changes) do not correspond to real modals and are struck, not merely unconfirmed.

**Phase 6 prerequisite, added from this validation pass:** reaching the Apply-reconciliation, Release, Revoke, and ModeSwitch modals requires a cohort-plus-enrollment fixture in the local seed data — the current seed has zero cohorts. Without it these four modal checks cannot be completed, and they must not be marked passed on the strength of the struck delete-lesson/unsaved-changes rows that turned out not to exist.

### Reduced-motion transition enumeration

Named globally in the prior draft but not made checkable. Under `prefers-reduced-motion`, the following specific animated transitions must show an instant state change, explicitly **not** an opacity-only fade:

- The C.1 control press (hover/active translate-and-shadow sequence).
- The A.5 page-turn transition.
- The week-completion stamp animation.

### No-native-dialog gate, both halves

The Browser UI invariant is checked two ways, and both are required — the source scan alone does not prove runtime behaviour:

1. A deterministic **source** scan over `src/**` for `alert(`, `confirm(`, `prompt(`, their `window.*` forms, and `beforeunload`, run as a build gate.
2. A **runtime** confirmation that no native dialog fires on any enumerated destructive or validation journey in this table, including every modal-trigger journey above.

**Resolved by direct source reading during the approval walkthrough:** the LearnDetailPage mark-complete path is already conformant with this policy at the source level. `MarkCompleteControl` (`LearnDetailPage.tsx:115-166`) is an inline two-step Confirm/Cancel control with explicit focus management across its trigger/confirming/saving steps, and carries a binding no-Modal decision in its own source comment. This is a source-level observation only and does not discharge the runtime half of the gate above; runtime confirmation on this journey is still required.

### Other cross-cutting per-surface requirements

- The 3px slate focus ring visible at 2px offset outside the shadow on every focusable control, on every surface in this table.
- The rendered-capture review protocol (Acceptance and validation) applies to every row in this table, including the newly added rows.

## Engineering mode

Standard.

## Team authorization

Not applicable.

## Downstream owner

engineering-fleet — T1 first-line, escalating to T2 on two counted gate failures per item — with browser-validator and verifier as independent gates. No writer may self-approve completion.

## Approval gate

**This plan requires explicit user approval before any downstream execution.** No standing forward authorization is invoked or claimed for this document. No T1, browser-validator, design-reviewer, or issue-creation dispatch under this plan may occur before that approval is recorded.

Issue creation in the `lizbeth-spanish` repository has been pre-authorized by the user in principle, scoped to that repository only (see GitHub issue logging policy). That pre-authorization does not itself activate issue creation: issue creation does not begin until this plan is approved.

Upon approval, update this file's status header from DRAFT to APPROVED, with the approval record (approver, basis, date, and the compact summary presented) filled in at that time, before dispatching Phase 0.

**Standing commit/push/PR/merge authorization, recorded with verbatim quotes.** In the interactive session, authorizing the prior consolidation, the user wrote: "a yes commit then open pr and merge to main." On 2026-09-04, the user wrote: "yes resume the goal, commit, push, open pr and merge to main as we progress." Together these constitute a standing authorization for the duration of this plan's execution, scoped to the `lizbeth-spanish` repository, covering commit, push, PR, and merge to `main`. It excludes deploys, force-pushes, history rewrites, and branch deletion. Per `handoff.md`, any job packet relying on this authorization should quote the user's own words directly rather than relying on an orchestrator-relayed summary; agents in this project correctly refuse to treat relayed authorization alone as sufficient.
