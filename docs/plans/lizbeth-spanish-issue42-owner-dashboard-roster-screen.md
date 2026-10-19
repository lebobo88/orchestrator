# Lizbeth Spanish, Issue #42: Screen — Owner Dashboard + Roster

**Status: Approved for engineering under standing authorization. Dated 2026-09-01.** See "Approval basis" immediately below for the basis and provenance of this approval.

## Approval basis

This plan was routed to engineering under the orchestrator's application of the user's standing authorization, not a user-verified per-plan approval. The record below is an orchestrator-applied inference, consistent with the Status line above, and follows the same provenance discipline the #31-#41 plans used.

- **Standing authorization quoted (verbatim, as relayed by the orchestrator):** "didn't i tell you to stop asking me for approval? i told you to keep going until all the gh issues are finished" and "don't stop until all the DS gh issues are implemented and browser validated." The orchestrator reports both statements as the user's own live-session standing authorization plus the explicit session goal, together covering this plan approval on the same basis already recorded on the #31-#41 plans.
- **Application:** the orchestrator applied this standing authorization to route this plan — issue #42 of `lebobo88/lizbeth-spanish`, the Field Journal DS milestone, the twelfth of fourteen issues and the sixth issue in the screen-redesign batch, following #31-#41, all landed, verified, browser-validated, and design-reviewed PASS — to engineering without a further live per-plan checkpoint, because #42 is the next issue in the exact chain the user directed continuation through.
- **Pre-flight staleness check performed.** The orchestrator independently fetched the live GitHub issue #42 body via `gh issue view` and relayed it directly into Planner's context, satisfying the plan's pre-flight staleness check, consistent with the practice established for issues #40 and #41.
- **`PLAN_DUCK` checkpoint deliberately not run.** Given this plan's moderate, bounded scope — a screen-level composition tying together already-shipped component work across three files, with no data-model change — the orchestrator determined a `PLAN_DUCK` Codex judge checkpoint was not warranted, on the basis that this checkpoint is reserved for higher-risk, higher-blast-radius plans per this engagement's established pattern. The orchestrator proceeded directly to approval rather than requesting the checkpoint.
- **One design revision cycle WAS consumed this time**, unlike issue #41's clean first-pass review. The first design-review cycle returned `NEEDS_REVISION` with two blocking findings, the HIGH one being a **silently dropped acceptance criterion**: the first handoff correctly noted that the mock's graph-tile literal (20px/`#e8e1d4`) was not matched, but never issued the positive instruction to apply `.paper-stock--graph` to `.owner-dashboard` at all — so an engineer implementing the first packet literally would have shipped a dashboard failing a named acceptance criterion with nothing flagging the gap. This is recorded plainly, not smoothed over as a clean pass. Both findings were closed in one bounded revision; see "Design review" below for the full detail.
- **Notable Planner findings preserved here for the approval record:**
  1. **The issue body's own cited line numbers are stale and wrong**, as they have been on every prior issue in this milestone — off by roughly two orders of magnitude versus the design source's true locations.
  2. **The issue body also contains a factually incorrect premise**, stating that `AdminShell.tsx/.css` was touched by #35 for a z-index fix on the "Aa" trigger. `AdminShell.css` is 32 lines with no z-index declaration and no shadow declarations at all; the real fix lives in `AccessibilitySettings.css:19-25`, a component `AdminShell.tsx` does not render. This is recorded as a corrected premise, not carried forward as fact.
  3. **A new instance of the recurring 390px table/overflow bug class, proactively found via static analysis** — the exact bug class already named in this issue's own acceptance criteria and already hit in #37, #39, and #41 in this milestone: `AdminStudentsPage.css` has zero `@media` rules across its full 441 lines, and `.detail-header`/`.account-access-row` use `display:flex; justify-content:space-between` with no `flex-wrap` fallback.
  4. **The acceptance criterion's brass-shadow-on-download-links clause has no actual consumer in scope.** No CSV, download, or export affordance exists in any of the three target files — searched directly, zero matches. The clause therefore resolves in practice to the owner student-progress table alone. The plan's D2 decision deliberately overrides the reference mock's own literal shadow value (§D.6's mock renders the student-progress panel with `--shadow-sheet`, byte-identical to the attention-rules panel) to instead apply the ratified §A.3 legacy-brass exception to that table — an intentional divergence from the cited mock, disclosed explicitly rather than presented as fidelity.
  5. **A genuine, pre-existing, wider-than-#42 contradiction** between `--shadow-print`'s token-file justification comment (which claims it is the production shadow in wide use) and the ratified design source's §A.3 policy, which names a distinct `--shadow-brass` value for owner tables and download links. This plan resolves the contradiction only for the three files in scope and explicitly leaves the roughly 21 other `--shadow-print` consumers untouched.
  6. **No planning-stage agent could execute the test suite or render a page.** `.claude/hooks/validate-researcher-bash.ps1` blocks `npm test`, `npx vitest`, and `git -C`, so every "current behavior" claim in this plan is source-level and static, never runtime-verified. The first ordered step of this plan is accordingly a mandatory baseline capture before any edit.
- Deterministic checks and the Verifier/Browser Validator passes in the ordered-work phase remain mandatory regardless of the `PLAN_DUCK` decision above.
- **Provenance label:** this basis reached Scribe entirely through the orchestrator's account of the session; Scribe has not independently observed the quoted user statements, the live issue fetch, the design-review cycle, or the Planner findings beyond what is already recorded elsewhere in this document. It is recorded here as an orchestrator-applied inference under standing authorization, NOT as a Scribe-verified per-document user approval.
- **Date:** 2026-09-01.

## Post-approval correction (2026-09-02)

During implementation, a Codex cross-vendor code-review checkpoint found that this plan's original design handoff — `MetricPlate.css .metric-plate--dark: --shadow-brass (unchanged)`, in the "Tokens" subsection of "Visual system" below — violated GitHub issue #42's own explicit, stricter acceptance criterion: "Owner tables and download links keep shadow.brass — this is the one place the legacy print shadow survives." The dark dashboard metric plate (the "Total students" tile) is neither a table nor a download link; it is a dashboard metric, and the plan's own D2/D9 resolution otherwise moves every other affected zone toward `--shadow-card`/`--shadow-sheet`, leaving `--shadow-brass` at only the owner student-progress table (D2). The original design-review pass grounded its "unchanged" reading in §D.6's own mock literal rather than in the issue's "one place" wording; the GitHub issue's acceptance criterion is the higher-authority source here, over the plan's own secondary reading of a reference mock's literal pixel value.

**Corrected decision:** `.metric-plate--dark` now uses `--shadow-card`, matching the `--default`/`--attention` siblings (D9), so that `--shadow-brass` survives in exactly the one place the issue names — the owner student-progress table (D2). The orchestrator directed T1 to apply this fix, overriding the plan's original resolution on this specific point. This correction supersedes only the `.metric-plate--dark` shadow decision recorded below; it does not alter any other part of the design handoff, and the original text is preserved inline with an explicit correction marker rather than rewritten silently. This was corrected during implementation, after the plan had already been approved and dispatched, following the Codex code-review checkpoint that caught the scope violation.

---

Plan ID: `lizbeth-spanish-issue42-owner-dashboard-roster-screen`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: `engineering-fleet`
Design route: standard (`design-director`, `ux-architect`, `visual-system-designer`, `design-reviewer`; prototype forbidden; model tier Sonnet; existing-system mode: preserve)

## Outcome and audience

GitHub issue #42, "Screen: Owner dashboard + Roster" (labels: `enhancement`, `role:owner`, `area:dashboard-data`, `design:screen`; depends on #36, already landed). This is the twelfth of fourteen issues in the Field Journal Design System milestone (#31-#44) and the sixth of the screen-redesign batch.

Observable result: the owner dashboard and student roster become the final screen-level composition of the milestone — graph paper stock and a container-level sheet treatment on the dashboard frame, C.8 metric plates with correct shadows and no bare percentage, C.7 ledger rows meeting real data, three correct glyph+word account states, the deliberate §A.3 legacy-brass exception applied to the owner table, Control-tier destructive/reversible semantics by construction, forced-colors coverage across all three files, and no page-body horizontal scroll at 390.

Audience: the owner using these screens; the T1/T2 engineer implementing this plan.

## Scope

**In scope:**

- `src/pages/OwnerDashboardPage.tsx` / `OwnerDashboardPage.css`
- `src/pages/AdminStudentsPage.tsx` / `AdminStudentsPage.css`
- `src/components/AdminShell.tsx` / `AdminShell.css`
- A bounded, additive change to `src/components/MetricPlate.tsx` / `MetricPlate.css` (a new optional `supportingFigure` prop plus `box-shadow` on the default/attention tones only)
- A bounded, disclosed update to the pinned assertions in `src/__tests__/AdminStudentsPage-status-label.test.tsx:103-120`
- New/extended tests for all of the above

**Non-goals (binding — a writer must return `JOB_BLOCKED` rather than exceed these):**

- No conversion of the roster to a `<table>`. It stays a div-based card list (decision D4).
- No change to any of the roughly 21 other `--shadow-print` consumers outside these three files (decision D2).
- No change to `AdminShell`'s dark header bar, brass "L" logo mark, or Sign-out chrome — a different, out-of-scope component (decision D3).
- No backend, Supabase edge-function, data-model, or RLS change. The completion-rate raw figures are derived client-side (decision D1).
- No change to `Control.tsx`/`.css` tier definitions. Only raw-button consumers migrate onto `Control`.
- No change to `OwnerLedgerRow.tsx`/`.css`, `AccountStatusPill.tsx`/`.css`, or `App.css`'s `.paper-stock--graph` definition.
- No new design token minted. No new palette, type scale, shadow value, or component geometry.
- No user-facing copy change beyond the account-state label required by D5 and the roster eyebrow required by D14.
- No widening of the 28em mobile-table-collapse breakpoint (decision D15).

## Verified repository findings

Grounded in a nested Researcher pass plus direct Planner and design-reviewer reads. All independently re-verified against live source by the design reviewer.

**The issue body's own cited line numbers are stale and wrong**, as they have been on every prior issue in this milestone. Verified true locations in `design/field-journal/Field Journal DS.dc.html`: §A.3 shadow/elevation policy 137-156; §A.4 paper stocks 160; §A.6 fixed criteria 193-200; §C.7 ledger row 524; §C.8 metric plate 549; §D.6 owner dashboard @1440 header 963, body 965-1094; §D.7 roster @1440 header 1099, body 1096-1143; §E.6 owner desk @390 header 1507, body 1508-1571. The issue cited approximately 127223, 145165, and 198799 — all wrong by roughly two orders of magnitude.

**The issue body also contains a factually incorrect premise.** It states `AdminShell.tsx/.css` was touched by #35 for a z-index fix on the "Aa" trigger. `AdminShell.css` is 32 lines and contains NO z-index declaration and no shadow declarations at all. That fix actually lives in `AccessibilitySettings.css:19-25`, a component rendered globally from `App.tsx`, which `AdminShell.tsx` does not import or render. This is recorded as a corrected premise, not carried forward.

**§A.3 literal (137-156):** radius zero everywhere; `rule.thin` = 2px border, no shadow; `card` = 3px border + `5px 5px 0 0 #1a1512`; `sheet` = 3px border + `8px 8px 0 0 #1a1512`; `brass` = 3px border + `5px 5px 0 0 #a07e48`, captioned "legacy print · kept for owner tables and download links." That brass value is the EXACT literal value of `--shadow-brass`. `--shadow-print` is a DIFFERENT token (`.3rem .3rem 0rem 0rem #a07e48` = 4.8px brass) with roughly 24 live consumers and a token-file comment claiming it is the production shadow in wide use — a genuine, pre-existing, wider-than-#42 contradiction between the token file's own justification comment and the ratified design source. Recorded, deliberately not resolved beyond this issue's three files.

**§A.6 (193-200):** every state = shape or word, never colour alone; 4.5:1 text minimum; amber and terracotta.500 stay decorative; brass.600/.700 and terracotta.600 carry copy; 44px hit targets; 3px slate focus ring at 2px offset.

**§D.6 (963-1094):** outer frame graph-tiled (20px/`#e8e1d4` in the mock), 3px ink border + `10px 10px 0 0 #1a1512`. Nav: light chrome (`#f0ebe2`) tabs with a 5px ink BOTTOM-BORDER on the active tab. 4-metric grid: "Total students" ink-1000 background + `5px 5px 0 0 #a07e48` (exactly `--shadow-brass`, matching `MetricPlate--dark` today); the other three paper background + `5px 5px 0 0 #1a1512` (exactly `--shadow-card`) — but `MetricPlate--default`/`--attention` currently declare NO box-shadow at all (`MetricPlate.css:34-42,58-66`). "Completion rate" in the mock shows only "64%", no raw figures. Attention-rules panel AND student-progress table panel both `8px 8px 0 0 #1a1512` (`--shadow-sheet`, byte-identical, `:1013` and `:1045`). The inner data table has a plain 3px border and NO shadow of its own in the mock.

**§D.7 (1096-1143):** roster header "18 filed · 3 pending" eyebrow + Fraunces 900 56px "Students" h1. ROSTER ROWS ARE INDIVIDUAL CARDS, NOT A TABLE: 3px border + `--shadow-card` for active/pending; 3px `#504940` border + `5px 5px 0 0 #504940` (exactly `--shadow-muted-card`, `field-workbook.generated.css:171`) for the disabled row. Status badges verbatim: `✓ Active` (moss outline/tint), `◔ Pending first login` (brass-700 outline / `#fef5e7` tint), `✕ Disabled` (terracotta outline / `#fffbf8` tint).

**§E.6 (1508-1571):** 390x844 frame, same graph tile, 3px border + `8px 8px 0 0 #1a1512`. Metrics collapse to 2 columns (the app already does this at `OwnerDashboardPage.css:53`). MATERIAL DISCLOSURE: the student-progress table is NOT DEPICTED at 390 in the mock at all — §E.6 does not independently validate the app's card-collapse table pattern, which is the app's own prior remediation-cycle invention. This plan does not represent mobile table behavior as mock-sourced.

**Current `OwnerDashboardPage`:** `.owner-dashboard` is `{ color: var(--color-ink-900); }` ONLY (`.css:1`) — no background, no paper stock, no container shadow. `.tsx:29-32` renders four `MetricPlate`s; the fourth is `` value={`${Math.round(dashboard.summary.completion_rate)}%`} `` with no zero-pad — a bare percentage. `.tsx:39-51` renders a real `<table>` with `OwnerLedgerRow` rows. `.tsx:25,37` still use raw `<button className="demo-button primary">` for Retry and "Save rules" — ZERO `Control` usage on this page. `.css:5,27,74` use `--shadow-print`; borders are `--color-ink-800`, not ink-1000. `.css:26-30,45,59-82` has `table-layout:fixed` + `width:var(--size-student-column)` + `width:11rem` on column 3, with a <=28em card-collapse override and a documented CSS-specificity remediation comment at `:63-71` that MUST be preserved verbatim by any edit to those selectors. `.dashboard-metric` rules at `.css:5,6,7,53` are DEAD CSS since `MetricPlate` replaced that markup in #36.

**Current `AdminStudentsPage`:** the roster is ALREADY a div-based card list (`.roster-list`/`.roster-item`, `.css:37-44`) with no `<table>`, no `table-layout:fixed`, no `min-width`, and no fixed px widths — so the #41-class grid-on-table defect does NOT apply here. Status badge markup `<span className={`status-badge status-${status}`}>{icon} {label}</span>` at `.tsx:449-451`, reused via `accountStatusBadge()` at `.tsx:591-593`. The pending state is currently `◷` / "Awaiting first sign-in" — WRONG glyph and WRONG label versus §D.7 and the acceptance criteria — and `src/__tests__/AdminStudentsPage-status-label.test.tsx:103-120` actively PINS the wrong text. Disable/Delete/Re-issue and others at `.tsx:607-612,659,686-687,723-728,752,755-767,780-786` still render raw `demo-button caution`/`destructive`/`secondary`, NOT `Control`. `button.caution` fill = `--color-brass-600` (`.css:439`) — brass, NOT the ratified caution-reversible `--color-amber-200`; `button.destructive` fill = `--color-terracotta-500` (`.css:437`), not caution-irreversible's terracotta-600. Label text is ink-900 / paper-50 on both, so the acceptance criteria's "label text never amber" IS already satisfied today. `.css:420,436` use `--shadow-print`. Two `<Control tier="primary">` instances exist (Add Student `:416-423`, Assign `:825-832`) but on mutually exclusive views. J-007 focus-restoration at `.tsx:95-100,536-556` must be preserved.

**Newly surfaced 390px overflow risk** — the exact bug class already named in the acceptance criteria, which already hit #37, #39, and #41: `AdminStudentsPage.css` has ZERO `@media` rules in its full 441 lines, and `.detail-header` (`:141-149`) and `.account-access-row` (`:316-323`) use `display:flex; justify-content:space-between` with NO `flex-wrap`. A badge plus one or two 48px-min-height Controls side by side with no wrap path at 390px is a concrete overflow instance. Independently confirmed by the design reviewer by grep. Fix: add `flex-wrap: wrap` to both.

**Also newly surfaced, unresolved by static analysis:** `OwnerLedgerRow.css:74` declares `.owner-ledger-row-progress { min-width: 154px; }` — a fixed-px min-width that could leak overflow at exactly 390px once `.dashboard-table-wrap` deliberately drops its own overflow-x containment at <=28em. Flagged for browser validation, NOT asserted as a confirmed failure.

**No CSV, download, or export affordance exists** in any of the three target files — searched directly, zero matches. §A.3's "download links" clause therefore has no consumer in scope, and no regression was found where a prior issue moved an owner table or download link off brass onto ink. The acceptance criteria's brass clause resolves in practice to the owner student-progress table alone.

**Forced-colors:** present in `MetricPlate.css:68-81` and `OwnerLedgerRow.css:112-123`; genuinely ABSENT from all three target CSS files (grep-confirmed by the reviewer). Established consumer conventions: `WeekCard.css:189-193` uses `forced-color-adjust: auto`; `JournalEmptyState.css:27-31` uses `background-image: none`.

`--color-focus` (`Control.css`) and `--color-focus-ring` (`App.css:40`) both resolve to the identical `#3d5f6b` — a token-naming duplication, not a value mismatch. Non-blocking, noted for future consolidation. Focus tokens `--focus-ring-width` (3px) / `--focus-ring-offset` (2px) at `field-workbook.generated.css:41-42` already satisfy §A.6.

`MetricPlate` has exactly ONE real JSX consumer in `src/` (`OwnerDashboardPage.tsx:29-32`) — independently grep-confirmed twice by the reviewer, who also confirmed the `WeekDetailPage.css` hit is a code comment, not a second consumer. This is what makes decision D9 purely additive with no regression surface.

**NO native dialog API** (`alert`/`confirm`/`prompt`/`window.*`/`beforeunload`) appears in `OwnerDashboardPage.tsx`, `AdminStudentsPage.tsx`, `AdminShell.tsx`, or `AdminStudentModals.tsx`. Confirmation UI already uses the app-owned `Modal` (`src/components/Modal.tsx`), regression-guarded by `ModalStackingAndInertness.test.ts`. This must not regress.

**Existing tests touching these surfaces:** `OwnerDashboardPage.test.tsx`, `AdminStudentsPage.test.tsx`, `AdminStudentsPage-PrimaryControlMigration.test.ts`, `AdminStudentsPage-status-label.test.tsx` (pins the currently-WRONG glyph/label), `AdminShell.test.tsx`. No test currently asserts `--shadow-print` on these three files; the only `--shadow-print`-aware test anywhere is `issue38RoadmapScreen.test.ts:61-64`, a negative assertion on the unrelated `.band-roadmap`, which #42 does not touch. npm scripts: `dev`, `build` (`tsc && vite build`), `preview`, `preview:prod`, `test` (vitest), `test:e2e`, `test:ui`, `lint`, `type-check`, `verify:build`. `vite.config.ts:7` sets the dev port to 5173 (default).

## Research evidence and its limits

A nested Researcher pass returned a full evidence packet grounded entirely in local repository and design-source inspection; no web sources were used.

**Material limit, recorded prominently.** The Researcher COULD NOT EXECUTE THE TEST SUITE — `.claude/hooks/validate-researcher-bash.ps1` blocks `npm test`, `npx vitest`, and `git -C`. Every "current behavior" claim in this plan is source-level and static, never runtime-verified. No live rendering was observed by any planning-stage agent. Consequently the first ordered step of this plan is a mandatory baseline capture before any edit.

**A second limit:** the Researcher reported Glob returning empty/inconsistent results for this repository's `src/` and `design/` subtrees, so Grep and Read were used as primary evidence tools; this does not affect the accuracy of any line-numbered claim but means directory-listing completeness was not exhaustively enumerated.

**A third limit:** the backend `deriveAccountStatus()` logic in `supabase/functions/admin-student-operations/index.ts` was referenced but not independently re-read line by line; low risk, since the three-state contract is already consistently observed client-side.

## Design route and handoff

```
DESIGN_ROUTE
profile: standard
reasons: screen-level composition across three high-traffic files at two breakpoints; multi-state roster (active/pending/disabled) plus dashboard metric/table/panel composition; the design source and the issue's acceptance criteria genuinely conflict on one metric; a shipped primitive (MetricPlate) is missing a specified state; three CSS files lack forced-colors coverage; nav chrome treatment changes.
agents_required: design-director, ux-architect, visual-system-designer, design-reviewer
prototype: forbidden
model_tier: sonnet
existing_system_mode: preserve
END_DESIGN_ROUTE
```

Motion and asset specialists were deliberately NOT dispatched — no load-bearing motion, no new imagery. Selected direction: "Preserve-in-place" — Field Journal DS, no new visual direction. This is a screen-composition and token-plumbing pass tying already-ratified primitives (`Control`, `MetricPlate`, `OwnerLedgerRow`, `AccountStatusPill`) into two real screens at 1440/390. No new palette, type scale, shadow value, or component geometry is introduced; every token cited below already exists in `src/tokens/field-workbook.generated.css` or the design source's §A.3/A.6/C.7/C.8.

The full PASSED `DESIGN_HANDOFF`'s load-bearing content is reproduced below, verbatim in substance, including the revisions that closed the first review cycle's two blocking findings.

### Design brief

Audience: the app owner only (`isOwnerUser(session.user)` gate at both `AdminShell.tsx:28-31` and `AdminStudentsPage.tsx:172-180` — the shell gate fires first, the page gate is a defense-in-depth duplicate, not a second reachable state). Students never see these screens.

Problem: the owner dashboard and student roster are the final screen-level composition of a 14-issue design-system milestone; prior component work (`OwnerLedgerRow`, `MetricPlate`, `Control`) exists but is inconsistently applied on these two pages — raw un-`Control`'d buttons, a bare percentage KPI, a wrong pending-account glyph/label, an accidentally-shared shadow token between two structurally distinct panel types, a missing container-level paper-stock/shadow treatment on the dashboard frame itself, and zero forced-colors coverage across all three files.

Desired outcome: both screens match design source §D.6/§D.7 (1440) and §E.6 (390) within the binding deviations recorded below, with the reused primitives' contracts satisfied by construction rather than by convention.

Success measures: the issue's acceptance criteria, satisfied observably — dashboard carries graph paper stock and a shadow-sheet container treatment, no bare percentages, glyph+word account states, brass exception scoped to exactly the table zone, `Control` tiers correct by reversibility, roster never produces page-body horizontal scroll at 390, forced-colors parity across all three files.

Anti-goals: no table conversion of the roster (D4); no new palette/type scale/shadow value; no touch to the ~21 other `--shadow-print` consumers outside these three files; no touch to `AdminShell`'s dark header/logo/sign-out chrome (D3 scope boundary); no backend/edge-function changes (D1); no mock-literal paper-stock tile size (D7 — the shipped 17-18px/`#e3dbcd` wins over the mock's 20px/`#e8e1d4`).

Content rules: no fabricated data, no fabricated status fields, no placeholder copy invented where a real label exists in the source. Two real content gaps are disclosed, not silently resolved (see "Assumptions and decisions").

### Journeys

The primary user is the Owner only. One genuine cross-screen continuation exists: `OwnerLedgerRow`'s "student name" button (`OwnerLedgerRow.tsx:76-83`) navigates to the SAME student-detail view `AdminStudentsPage` renders — any state/`Control`-tier decision for "student detail" applies identically regardless of entry point (dashboard row vs. roster card).

**J1 dashboard** (entry: `AdminShell` "Dashboard"): loading -> loaded (read 4 metrics, optionally edit Attention rules -> Save -> inline saved/error, non-blocking) -> optionally open a ledger row -> shared student-detail surface. Recovery: initial-load failure -> full-page error + sole primary Retry `Control`.

**J2 roster** (entry: `AdminShell` "Students", or a dashboard ledger-row click): loading -> list (Add Student / Refresh / open a card) -> detail (Account Access actions, Enrollment actions, Account status actions). Delete exits to the roster list; every other action refreshes in place, preserving the existing focus-restoration pattern (`AdminStudentsPage.tsx:95-100,536-556` — J-007, must not be redesigned). Recovery: load failure -> full-page error + sole primary Retry `Control`; non-owner -> permission-denied (shell-level gate fires first; page-level gate is an unreachable duplicate, noted for visual/engineering so it isn't designed or tested twice).

### Information architecture

**Zone map, dashboard (both breakpoints):** OUTER FRAME (`.owner-dashboard` itself — carries the graph paper stock and its own container-level shadow-sheet treatment) > 4-metric grid (Total-students plate stays `tone=dark`/unchanged; Active/Attention/Completion plates are a new shared card-shadow zone) > Attention-rules panel (nested sheet-shadow zone, independent of the outer frame's own shadow) > Student-progress TABLE panel (brass-shadow zone, a NEW modifier class distinct from the attention-rules panel — today both wrongly share one class and one shadow) > mobile stacked row-cards at <=28em (card-shadow zone, replacing `--shadow-print`).

**Zone map, roster:** roster cards default/active/pending (card-shadow zone) > disabled roster card (NEW muted-card modifier zone, gated on `account_status==='disabled'` — no such per-card modifier exists today, only the inner badge carries status) > student-detail panels (`.detail-header`, `.detail-account-access`, `.enrollment-item`, `.detail-assign-new-band` — grouped with sheet-shadow, replacing `--shadow-print`).

**Completion-rate `MetricPlate` (resolves D1, the acceptance-criteria/mock conflict):** `MetricPlate` gains one new optional prop `supportingFigure?: string`, rendered as a second line beneath the existing figure. Data contract: client-side sum of `completed_lesson_count`/`lesson_count` across `dashboard.students[].enrollments[]` (the same fields `OwnerLedgerRow` already consumes per-row), zero-padded via the same `padStart(2,'0')` helper `OwnerLedgerRow.tsx:16-18` already uses — no backend change.

**Ledger row (C.7):** already compliant as shipped — bar + zero-padded "NN / NN" raw figure, never a bare percentage. No structural change.

**Account-state badges:** shared markup `<span class="status-badge status-${status}">{icon} {label}</span>` (`AdminStudentsPage.tsx:449-451`, reused via `accountStatusBadge()` at `:591-593`). Three states: `✓ Active` / `◔ Pending first login` / `✕ Disabled`. The pending glyph/label is WRONG today (`◷` / "Awaiting first sign-in") and must become `◔` / "Pending first login" (D5) — the associated pinned test (`AdminStudentsPage-status-label.test.tsx:103-120`) needs a disclosed, bounded update.

**`AdminShell` nav (D3, tabs only):** replace the filled-pill active treatment (`AdminShell.css:30`) with a light-chrome-at-rest-and-active treatment distinguished only by a bottom-border/underline, matching §D.6/§E.6. The dark header bar, brass logo, and Sign-out are a different, out-of-scope component — `AdminShell` renders only the `<nav>` and routed page sections, confirmed by direct read.

**`Control` tier mapping (every in-scope action, both screens):**

- Dashboard: Retry -> primary (error view, sole action). Save rules -> primary (loaded view, sole `Control`-tiered button — mutually exclusive with Retry, at-most-one-primary holds trivially).
- Roster list: Retry -> primary (error view). Add Student -> primary (already correct). Refresh -> secondary (co-present with Add Student; exactly one primary).
- Student detail (all rendered simultaneously — NOT mutually exclusive branches): Disable -> caution-reversible. Delete -> caution-irreversible. Re-enable/Cancel/Re-assign -> secondary. Mark-email-confirmed, Re-issue access -> caution-irreversible (pinned by decision D13, below). Toggle password-change-requirement -> caution-reversible (a true two-way toggle). Reset-Week-N / Confirm-reset -> caution-irreversible. Unassign -> caution-reversible (pinned by decision D13, promoted from its current plain-secondary styling). Wipe-Save -> caution-irreversible. Assign -> primary (sole primary on this view — confirmed at-most-one-primary holds across the full simultaneous action set).

### Responsive behavior

**Dashboard 1440:** the outer frame (`.owner-dashboard`) carries the graph paper stock and its own container shadow; a 4-column metric grid / 2-column panel grid nests inside it (existing `OwnerDashboardPage.css:4,8`). Keyboard order follows DOM source order (confirmed no CSS `order:` anywhere in the file, so no order/visual mismatch risk): nav -> [error: Retry] OR [loaded: rule inputs -> Save-rules `Control` -> search -> sort -> one ledger-row "open student" button per row].

**Dashboard 390:** `@50em` collapses metrics to 2-column and the panel grid to 1-column; `@28em` converts the table to stacked labeled cards (existing, documented pattern — `OwnerDashboardPage.css:56-82`, with an in-file comment referencing a prior "browser validation remediation cycle 3"). The outer frame's paper stock and container shadow persist unchanged through both collapses, since they belong to the root element, not the responsive grid. MATERIAL DISCLOSURE: §E.6's mock does NOT depict the student-progress table at 390 at all; the mock's mobile flow ends after the Needs-attention panel. The stacked-card collapse specified below is therefore the app's OWN pre-existing remediation pattern extended, not a mock-sourced fact — mobile table behavior is not represented as mock fidelity anywhere in this plan.

**Roster (both breakpoints):** already a div-based flex column of full-width cards (no fixed px widths found in `AdminStudentsPage.css`) — inherently safe, no breakpoint needed for the list itself. The detail view is the one place with a real risk: `.detail-header` and `.account-access-row` (`AdminStudentsPage.css:141-149,316-323`) use `display:flex; justify-content:space-between` with NO `flex-wrap`, and `AdminStudentsPage.css` has ZERO `@media` rules anywhere in its 441 lines — a badge plus one or two 48px-min-height Controls side by side with no wrap path at 390px is a concrete instance of exactly the recurring horizontal-scroll bug class named in this issue's own acceptance criteria (already hit #37, #39, #41). Fix: add `flex-wrap: wrap` to both selectors.

**`AdminShell` nav at 390:** convert `.admin-shell-nav ul` from `flex-wrap:wrap` to a single non-wrapping row with `overflow-x:auto` + `white-space:nowrap` on items, so the nav owns its own contained scroll region distinct from the page body — matching both §D.6/§E.6's own nav specimens (already `overflow-x:auto`) and `.dashboard-table-wrap`'s existing precedent. CORRECTED per independent design review: this conversion is motivated by mock fidelity, not a scroll-safety fix — `AdminShell.css:14`'s existing `flex-wrap:wrap` already wraps overflowing nav items to additional rows rather than causing page-body horizontal scroll, so it was never itself a defect. See "Binding engineering invariants" for the corrected framing.

### Accessibility

Focus ring: 3px slate ring at 2px offset per §A.6 — confirmed already correctly tokenized (`--focus-ring-width:3px`, `--focus-ring-offset:2px`, `field-workbook.generated.css:41-42`) and consistently applied. One non-blocking naming duplication: `Control.css` uses `--color-focus` while `AdminStudentsPage.css`/`AdminShell.css` use `--color-focus-ring` — both resolve to the identical hex (`#3d5f6b`), so there is no visual defect, only a token-naming duplication worth a future consolidation note.

Hit targets: `Control`'s shared geometry (48px) and `AdminShell` links already clear the 44px floor. Roster cards have no explicit min-height set — needs a browser-validator numeric confirmation, not resolvable from static analysis alone.

Zoom/reflow: `OwnerDashboardPage.css:29 width:var(--size-student-column)` and the literal `width:11rem` on the Progress column are absolute widths inside a `table-layout:fixed` table, reset at <=28em by a documented, fragile CSS-specificity match (lines 63-71, "(0,2,1)" comment) that MUST be preserved verbatim by any future edit to those selectors. A genuinely new finding this pass surfaced: `OwnerLedgerRow.css:74 .owner-ledger-row-progress { min-width: 154px; }` — a previously undisclosed fixed-px min-width that could theoretically leak overflow at exactly 390px once `.dashboard-table-wrap` deliberately drops its own overflow-x containment at <=28em. Cannot confirm or rule out an actual breach from static analysis alone; flagged as a needs-verification item for browser validation, not asserted as a confirmed failure.

A second disclosed gap: the acceptance criteria's 200%-zoom target commonly resolves to roughly 640-720px effective viewport, which crosses the 50em (800px) query but not the 28em (448px) query that gates the safe stacked-card table collapse — at that zoom the table stays in its desktop fixed-column form. This is degraded ergonomics (a horizontally-scrollable inner table, contained inside `.dashboard-table-wrap`'s own `overflow-x:auto`, never reaching the page body) but not a confirmed acceptance-criteria breach in the strict sense. Whether to widen the 28em breakpoint is an open engineering/product call, deliberately not resolved here (decision D15).

### States

Dashboard: loading (full-page substitution) / error-initial-load (full-page, Retry primary) / error-inline-save (non-blocking, existing data stays visible — a DIFFERENT state from initial-load error) / empty-vs-search-no-match (AMBIGUOUS TODAY — one shared copy string covers both a true zero-students dashboard and a filtered-to-nothing search; disclosed content gap, not silently resolved) / saving (Save-rules `Control` disabled, "Saving…") / saved ("Attention rules saved.") / needs-attention (`tone=attention` plate + icon+text row markers, never color alone).

Roster: loading / error (Retry primary) / empty (distinct, unambiguous "No students yet." copy, unlike the dashboard's overlapping empty/no-match copy) / search-no-match: NOT APPLICABLE — the roster has no search/filter input at all, disclosed rather than fabricated / saving (three separate in-flight flags: `isAssigning`, `isReenabling`, `resettingLesson`) / saved: ASYMMETRIC versus dashboard — no persistent success banner exists anywhere on roster/detail; success is communicated only implicitly via the post-action refresh changing badge/list state, a real cross-screen asymmetry, disclosed not smoothed over / disabled-account (`✕ Disabled` badge, Re-enable replaces Disable, muted-card zone) / pending-first-login (`◔` badge per D5) / permission-denied (shell-level gate fires first; page-level gate is an unreachable duplicate) / inline validation errors (`assignError`, `reenableError`, `resetError` — each its own `role="alert"` adjacent to its trigger, non-modal, consistent with the zero-native-dialog requirement).

### Visual system

Direction rationale: the system's own §A.3/§A.6/§C.8 rules and existing shipped primitives (`Control`, `MetricPlate`, `OwnerLedgerRow`, `AccountStatusPill`, `WeekCard`) already carry every color/shadow/typography value this screen needs; the task is applying ratified tokens to correctly distinguished zones, not inventing new ones.

**Typography.** `MetricPlate` label (unchanged, all tones): IBM Plex Mono, `--font-size-label-small` (11px), weight 600, letter-spacing .18em, uppercase — already satisfies C.8's "mono label" clause, confirmed by direct read of `MetricPlate.css`. `MetricPlate` primary figure (unchanged, all tones): Fraunces, `--typography-role-display-sm` (weight 900, 52px, line-height 1) — this IS the exact "large Fraunces figure" type-scale token C.8 requires. Zero-padded via the shared `padStart(2,'0')` helper for count-type plates; the completion-rate percentage string is correctly exempt from zero-padding (it is a rate, not a count) per the component's own doc comment.

NEW `supportingFigure` line (resolves D1's open call): rendered as a second `<p className="metric-plate-supporting-figure">` beneath the primary figure — IBM Plex Mono, `--font-size-label-small`, weight 400 (deliberately lighter than the label's 600), no letter-spacing, color `--color-ink-700`, `margin-top: var(--space-1)`. Value = zero-padded raw sum, e.g. "148 / 468", using `OwnerLedgerRow`'s exact grammar.

RESOLUTION of the completion-rate emphasis call: the percentage stays the visually dominant Fraunces figure; the raw fraction is the mono supporting line. Rationale: the grid's other three plates each show exactly one bold Fraunces number as their sole scannable figure — keeping completion-rate's dominant figure a number (the percentage) preserves that uniform "one dominant number" scan pattern across all four plates, while the mono supporting line resolves the acceptance-criteria requirement (raw counts must be inspectable, never percentage alone) without disrupting grid consistency, and reuses the exact visual vocabulary `OwnerLedgerRow` already established for raw figures elsewhere on the same screen.

Ledger row (C.7): confirmed compliant as shipped, no new tokens needed — filled bar + zero-padded "NN / NN" mono figure, ink-700. Band-tier legend colors (brass-600/terracotta-600/ink-slate) all sit at .600-or-darker steps; no §A.6 .500-decorative-for-copy violation found.

**Color and contrast.** Status badges reuse `AccountStatusPill`'s already-shipped triad exactly, not invented:

- Active: outline `--color-ink-moss`, tint `--color-badge-tint-inclusive` (`#eef5f0`), text `--color-ink-moss`. Independently reconfirmed contrast 6.87:1.
- Pending first login: outline `--color-brass-700`, tint `#fef5e7` (matches the verified research literal exactly), text `--color-brass-700`. Independently reconfirmed contrast 5.36:1, at the .700 step.
- Disabled: outline `--color-terracotta-600`, tint `#fffbf8` (matches the verified research literal exactly), text `--color-terracotta-600`. Independently reconfirmed contrast 4.67:1 — passes 4.5:1 narrowly; do not substitute a lighter tint or a .500 text step, both would fail.

Border geometry for all three: solid, `--border-width-strong` (2px), matching `AccountStatusPill`'s own geometry. `AdminStudentsPage`'s raw `.status-badge.status-*` classes currently render against a flat surface, not these tints — visually inconsistent with the already-shipped `AccountStatusPill`. Either re-point those three rules' `background-color` to the tints above, or swap the markup for `<AccountStatusPill>` directly; both achieve the same visual/acceptance-criteria outcome — engineering's choice (decision D12 resolves this to swapping the markup).

`Control`'s six-tier color contract (confirmed via direct read of `Control.tsx`/`Control.css`, unchanged, fully satisfies D6): primary — fill ink-1000, text paper-50, shadow `--shadow-brass`. secondary — fill paper-100, text ink-1000, shadow `--shadow-card`. caution-reversible — fill `--color-amber-200`, text ink-1000, NEVER amber text. caution-irreversible — fill `--color-terracotta-600`, text paper-50, NEVER amber text. quiet / quiet-outline — transparent, text brass-700 (terracotta-600 on hover for quiet). Confirmed: the researcher's finding of `button.caution` -> brass-600 fill / `button.destructive` -> terracotta-500 fill belongs to the OLD raw `.demo-button`-style classes `Control` is REPLACING per D6 — a structurally separate, pre-existing migration target, not a defect in `Control`'s own contract. No fix needed inside `Control.tsx`/`.css`.

`AdminShell` nav tabs (D3, tabs only): resting (unchanged, confirmed correct) — background paper-100, text ink-800, border ink-800; hover background paper-200. Active (new — replaces the filled pill): background/text UNCHANGED from resting (do not fill, do not invert to paper-50), border-color unchanged, plus a heavier single-edge border-bottom to read as the active underline. Independently reconfirmed contrast of the active tab's resting text/background pairing: 11.3:1. Border-bottom width/color resolves to `--border-width-accent` (6px, already used by `OwnerLedgerRow`'s band-tier left-border for the identical semantic role — a single-edge state marker) paired with `--color-ink-800` (matching the tab's own existing border, avoiding a second near-black shade) — decision D3b, a 1px deviation from the mock's literal 5px that is visually immaterial and stays inside the shipped token vocabulary. `aria-current="page"` (already present in markup) remains the accessible active-tab signal independent of this color/border choice.

Mobile overflow-x nav: plain `overflow-x:auto`, no fade/edge affordance — matches both the design source's own D.6/E.6 nav specimens and `.dashboard-table-wrap`'s existing in-app precedent, neither of which use a scroll-fade cue. CORRECTED framing (independent review): this conversion is a mock-fidelity choice, not a scroll-safety fix.

**Layout and density.** Unchanged — no grid, spacing, or breakpoint value is touched by this plan. `.paper-stock--graph` must be APPLIED to `.owner-dashboard` (the outer dashboard-frame element) at its shipped, unchanged 17-18px tile / `#e3dbcd` values (`App.css:120-125`) — this is how the acceptance criteria's "Dashboard uses GRAPH paper stock" clause is positively satisfied, using the ratified existing class rather than the mock's literal 20px/`#e8e1d4` tile (D7's own precedent: existing token values win). This is a NEW application: grep-confirmed neither `.paper-stock--graph` nor any equivalent class currently appears anywhere in `OwnerDashboardPage.tsx`/`.css` — engineering must add the class name to the page's root JSX element.

**Tokens.** CONTAINER-LEVEL TREATMENT (the dashboard's own outer frame, distinct from every nested panel-level assignment below): `.owner-dashboard` itself must receive `background`/`background-image` per `.paper-stock--graph` PLUS its own `box-shadow: var(--shadow-sheet)` and `border: var(--border-width-rule) solid var(--color-ink-1000)`. This directly satisfies the acceptance criteria's literal text — "Dashboard uses GRAPH paper stock AND shadow.sheet" — and is a SEPARATE, additional declaration from the nested panel-level shadows already specified (the attention-rules panel's own `--shadow-sheet`; the table panel's `--shadow-brass` per D2) — nested shadow layering, both intentional, not a duplication error. §D.6's own mock renders this outer frame with a literal 10px offset (`:965`), 2px heavier than the ratified `--shadow-sheet`'s 8px value; per D7's own established precedent (existing ratified tokens win over mock literals), this plan uses `--shadow-sheet` unchanged rather than minting a new 10px token — directly grounded by the acceptance criteria's own text, which names the token ("shadow.sheet"), not a literal pixel offset. This question is RESOLVED here, not left open.

Shadow-token assignment per nested zone, all values already defined in `field-workbook.generated.css`, nothing new minted:

- `MetricPlate.css .metric-plate--dark`: ~~`--shadow-brass` (unchanged)~~ — CORRECTED 2026-09-02: `--shadow-card`, matching `--default`/`--attention` (D9). Per issue #42's stricter acceptance criterion ("shadow.brass survives in exactly one place: the owner student-progress table"), `--shadow-brass` is retained only at the owner student-progress table (D2). This supersedes the original design-review pass's reading of §D.6's mock literal; see "Post-approval correction (2026-09-02)" above.
- `MetricPlate.css .metric-plate--default`, `--attention`: ADD `box-shadow: var(--shadow-card)` (D9).
- `OwnerDashboardPage.css .dashboard-panel` (attention-rules, base/shared): `--shadow-sheet`.
- `OwnerDashboardPage.css` NEW `.dashboard-panel--table` (modifier, additive): `--shadow-brass`. DISCLOSURE: §D.6's own mock (`:1045`) renders this same panel with `--shadow-sheet` — byte-identical to the attention-rules panel's own shadow at `:1013`. D2 deliberately diverges from that literal mock rendering to instead apply §A.3's legacy-brass-for-owner-tables exception (`:154`, "kept for owner tables and download links") — an intentional, binding difference from the cited mock, not a fidelity miss.
- `OwnerDashboardPage.css .dashboard-table-wrap table` (line 27, inner table element, separate from the wrapper shadow): reassigned to `--shadow-brass` alongside the new modifier, so no stray in-scope `--shadow-print` consumer is left behind (decision D11 resolves this by removing the inner shadow entirely rather than reassigning it — see D11).
- `OwnerDashboardPage.css .dashboard-table-wrap tr` (line 74, mobile stacked cards, @28em): `--shadow-card` (was `--shadow-print`).
- `AdminStudentsPage.css .roster-item` (active/pending): `--shadow-card` (was `--shadow-print`).
- `AdminStudentsPage.css` NEW `.roster-item--disabled` (modifier, gated on `account_status==='disabled'`): `--shadow-muted-card`, border-color `--color-ink-700` — mirrors `WeekCard.css:150-158`'s `.week-card--locked`, the one other real `--shadow-muted-card` consumer in the app, exactly.
- `AdminStudentsPage.css .detail-header`, `.detail-account-access`, `.enrollment-item`, `.detail-assign-new-band`: `--shadow-sheet` (was `--shadow-print`).

Border-width companion note (non-blocking): every other real consumer of these four shadow tokens in the codebase (`Control` secondary tier, `MetricPlate`, `WeekCard`, `BandRoadmap`, `WeekDetailPage`, `Modal`, `FeedbackForm`) pairs the shadow with a 3px `--border-width-rule` border, matching §A.3's own specimen caption — including the new `.owner-dashboard` container treatment above. This plan resolves that companion question with decision D10: the border-width bump lands in this issue for all reassigned zones, not filed as a fast-follow, so these three files do not become the app's only inconsistent place.

`MetricPlate` new prop (structural): `supportingFigure?: string`, rendered as `<p className="metric-plate-supporting-figure">{supportingFigure}</p>` — typography above.

**Components and states.** `.owner-dashboard` (outer frame, NEW): static container, no interactive states — carries background (paper stock), box-shadow, and border only. `MetricPlate` (`--default`/`--attention`): non-interactive display element, no hover/focus/active states; add `box-shadow:var(--shadow-card)` to resting state only. `--dark`: ~~unchanged~~ — CORRECTED 2026-09-02: also receives `box-shadow: var(--shadow-card)` (was `--shadow-brass`); see "Post-approval correction (2026-09-02)" above. `Control` (six tiers): default/hover/active/focus-visible/disabled states already fully specified in `Control.css` and unchanged by this plan; `:disabled` uses the native attribute only, already correct. Status badge/`AccountStatusPill`: three states per the color/contrast spec above; non-interactive, no hover/focus state. Roster card (`.roster-item`): default/hover/focus-within unchanged; the new `--disabled` state is shadow + border-color only, and this plan does not change whether the card remains clickable/focusable. `AdminShell` nav tab: resting/hover unchanged; active redefined per the color spec above; focus unchanged.

**Accessibility (visual layer).** Focus ring: `--focus-ring-width` (3px), `--focus-ring-offset` (2px) already applied consistently and correctly project-wide. `--color-focus` (`Control.css`) and `--color-focus-ring` (`App.css`) both resolve to the identical `#3d5f6b` ("slate") — a naming duplication, not a value mismatch, flagged for future consolidation, non-blocking here. All three status badges satisfy "shape or word, never colour alone" via glyph+word text content, confirmed by `AccountStatusPill`'s own shipped markup, reused verbatim.

Forced-colors (D8), specification for all three currently uncovered files, matching the established `MetricPlate.css:68-81` / `OwnerLedgerRow.css:112-123` convention:

- `OwnerDashboardPage.css`: neutralize `box-shadow -> none` on `.owner-dashboard` (the new container-level treatment), `.dashboard-metric`, `.dashboard-panel` (and the new `.dashboard-panel--table`), `.dashboard-table-wrap table`, and the mobile stacked `.tr` cards — box-shadow is pure depth decoration throughout, never the sole carrier of required info (each element's border is the shape signal and stays visible). Reassert `border-color:ButtonText` on the same full set including `.owner-dashboard`. Set `background-image: none` on `.owner-dashboard` under forced-colors — matching `JournalEmptyState.css:27-31`'s precedent for a full-bleed decorative background, the closer analog to this container's own full-frame role — so the graph tile pattern, purely decorative and carrying no information, does not render as a distracting pattern against a system-supplied background.
- `AdminStudentsPage.css`: neutralize `box-shadow -> none` and reassert `border-color:ButtonText` on the shared selector group (`.admin-students-roster`, `.admin-students-detail`, `.detail-assign-new-band`, `.detail-account-access`, `.detail-header`, `.reissue-access-warnings`, `.enrollment-item`, `.roster-item`, and the new `.roster-item--disabled`). The three status badges fall back to system colors for background/border (matching `AccountStatusPill.css`'s own precedent) since meaning is carried by glyph+word text, not tint — no forced-colors border-style differentiation needed between the three (unlike `Control`'s two caution tiers, which lack an accompanying glyph and DO need it).
- `AdminShell.css`: no box-shadow exists here today (flat-filled nav links), nothing to neutralize. Reassert `border-color:ButtonText` on `.admin-shell-link` (all states); for `.active`, preserve the border-bottom distinction under forced-colors via `border-bottom-color:Highlight`, matching `Control.css`'s own `:focus-visible{outline-color:Highlight}` precedent — a sighted-user parity nicety, not load-bearing since `aria-current` already carries the accessible signal independent of color.

### Engineering invariants carried from the design handoff

- D9 safety confirmed via direct grep: `MetricPlate` has exactly one real JSX consumer in the entire `src/` tree (`OwnerDashboardPage.tsx:29-32`) — adding `box-shadow` to `--default`/`--attention` is a clean, purely additive change (unset property becoming set) with no regression surface elsewhere.
- `.roster-item--disabled` and `.dashboard-panel--table` MUST be additive modifiers (composed alongside the base class), never replacements, so every other rule in the shared selector groups (padding, background, hover/focus-within behavior) keeps applying unchanged.
- Do not touch any of the ~21 other `--shadow-print` consumers outside these three files (D2's explicit scope boundary) — this plan's reassignments are exhaustive for the in-scope files' own `--shadow-print` usages, including the previously unlisted `.dashboard-table-wrap table` inner-element shadow, but touch nothing in `App.css` or elsewhere.
- Apply `.paper-stock--graph`, unchanged/unaltered at its shipped values, to the NEW `.owner-dashboard` container-level treatment (D7) — this is a new consumer being added by this pass, not a preservation of an existing reference; the shipped 17-18px/`#e3dbcd` values themselves must not be altered to match the mock's 20px/`#e8e1d4` literal.

### Permitted variation

- Exact names for the two new modifier classes, as long as they compose additively.
- Whether `AdminStudentsPage`'s raw status-badge markup is re-pointed to the tinted backgrounds directly or swapped for the existing `<AccountStatusPill>` component (resolved by decision D12 to swapping the markup, but the visual outcome is the binding requirement).
- Exact client-side summation implementation for the completion-rate `supportingFigure` — the contract fixes only the resulting figure's format (zero-padded "NN / NN") and placement.
- Exact `aria-label`/accessible-name string composition where not otherwise pinned.

## Design review

PASS, on the second and final review cycle. The first cycle returned `NEEDS_REVISION` with two blocking findings; one bounded revision was consumed, and both were closed.

**Finding 1 (HIGH).** The first handoff SILENTLY DROPPED the acceptance criteria's graph-paper-stock requirement: it correctly noted the mock's 20px/`#e8e1d4` literal was not matched but never issued the positive instruction to apply `.paper-stock--graph` to `.owner-dashboard`, so an engineer implementing literally would have shipped a dashboard failing a named acceptance criterion with nothing flagging the gap. Closed: the revised packet now instructs applying `.paper-stock--graph` at the shipped 17-18px/`#e3dbcd` values, resolves the outer-frame container shadow (§D.6:965's 10px maps to the shipped 8px `--shadow-sheet` under D7's ratified-token-over-mock-literal precedent), carries it into the engineering invariants, adds visible outcomes at both viewports, and corrects the now-false forced-colors claim by adding `background-image: none` on `.owner-dashboard` per the `JournalEmptyState.css:27-31` precedent.

**Finding 2 (MEDIUM).** D2's divergence from §D.6 was undisclosed. Closed: the packet now states explicitly that §D.6:1045 renders the student-progress panel with `--shadow-sheet`, byte-identical to the attention-rules panel at `:1013`, and that D2 deliberately diverges to apply §A.3's legacy-brass-for-owner-tables exception — an intentional difference, not a fidelity miss.

**Finding 3 (LOW, advisory, non-blocking).** `AdminShell.css:14` already has `flex-wrap:wrap` on `.admin-shell-nav ul`, which wraps rather than overflows, so the nav's overflow-x conversion is motivated by mock fidelity, not by fixing a scroll defect; the invariant's stated justification was reworded to reflect this.

The reviewer independently re-verified every sampled citation against live source and found them byte-accurate, confirmed `MetricPlate`'s single-consumer claim, recomputed all four contrast ratios (Active `#2f5d3f` on `#eef5f0` = 6.87:1; Pending `#7c6136` on `#fef5e7` = 5.36:1; Disabled `#a85e4a` on `#fffbf8` = 4.67:1, a real and narrow pass; `AdminShell` active tab ink-800 on paper-100 = 11.3:1), confirmed the `AccountStatusPill` tints match §D.7's literals exactly, confirmed forced-colors blocks are genuinely absent from all three files, and confirmed the `--color-focus`/`--color-focus-ring` hex identity. It judged the disclosed 200%-zoom gap NOT an acceptance-criteria breach: `.dashboard-table-wrap` (`OwnerDashboardPage.css:26`) has its own independent `overflow-x:auto`, so at the roughly 640-720px effective zoomed viewport the table's scroll stays contained in that element and never reaches the page body, within WCAG 2.2 SC 1.4.10's data-table exception. It also confirmed the new container-level 3px border introduces no new 390px overflow path, because `App.css:159-165` sets a universal border-box.

**Remaining limits carried forward**, all deferred to browser validation rather than a further design cycle: no page was rendered by any planning-stage agent; `OwnerLedgerRow.css:74`'s 154px min-width at exactly 390px; the `.roster-item` rendered height against the 44px floor (no explicit min-height in source); the Disabled badge's narrow 4.67:1 contrast margin under live measurement; and a visual sanity check of the new nested container-plus-panel double sheet shadow at both viewports.

## Judge route

`PLAN_DUCK` eligible at the orchestrator's discretion before approval. `CODE_REVIEW` recommended after implementation, given the three-file cross-screen migration, the shared-primitive `MetricPlate` change, and the bounded test-assertion update. `VISUAL_REVIEW` constrained by the disclosed Atelier unavailability. Standard call caps and shadow policy from `docs/JUDGE-CONTRACT.md` apply; deterministic failures always dominate the judge.

## Ordered work

Owner: T1 engineer, standard mode; escalate to T2 on two counted gate failures. TDD-first throughout — every step writes its failing test before the corresponding production edit.

1. **Baseline first, before any edit.** Run `npm test` and capture complete pass/fail totals; run `npm run type-check`, `npm run lint`, and `npm run build` and capture results; confirm via `git status`/`git diff` that the three target files and `MetricPlate` are clean in the working tree. Record as evidence. If the observed baseline diverges materially from this plan's static findings, return `JOB_BLOCKED` with `Plan stale` rather than proceeding.
2. Write failing tests for the dashboard container treatment: `.owner-dashboard` carries the graph paper stock and the container-level sheet treatment; `.dashboard-panel` uses `--shadow-sheet`; the new `.dashboard-panel--table` modifier uses `--shadow-brass`; the mobile stacked row-cards use `--shadow-card`; no `--shadow-print` remains in `OwnerDashboardPage.css`.
3. Implement the `OwnerDashboardPage.css` container and shadow-zone changes, including the 3px border-width bump (decision D10) and removal of the inner-table shadow (decision D11). PRESERVE VERBATIM the documented CSS-specificity remediation comment and rules at `:63-71` and the <=28em card-collapse block. Delete the dead `.dashboard-metric` rules (decision D16).
4. Write failing tests for, then implement, the `MetricPlate` change: `box-shadow var(--shadow-card)` on `--default` and `--attention`, `--dark` unchanged; and the new optional `supportingFigure` prop rendered per the design handoff's typography. Verify no other consumer regresses.
5. Write failing tests for, then implement, the completion-rate resolution (D1): derive the raw zero-padded sum client-side from `dashboard.students[].enrollments[]`'s `completed_lesson_count`/`lesson_count` using `OwnerLedgerRow`'s existing `padStart` helper, and pass it as `supportingFigure`. If the client-side sum cannot be reconciled with `summary.completion_rate` within rounding, return `JOB_BLOCKED` rather than render two disagreeing numbers (decision D17).
6. Migrate `OwnerDashboardPage.tsx`'s Retry and "Save rules" raw buttons onto `Control` per the handoff's tier mapping, preserving all existing behavior and states.
7. Write failing tests for, then implement, the account-state fix (D5): `◔` / "Pending first login", delivered by swapping the raw status-badge markup for the shipped `AccountStatusPill` (decision D12). Update the pinned assertions at `AdminStudentsPage-status-label.test.tsx:103-120` — a disclosed, bounded, intentional test change, not test weakening.
8. Write failing tests for, then implement, the D6 `Control` migration across `AdminStudentsPage.tsx`'s action buttons using the handoff's full confirmed tier mapping including decision D13. Assert label text is never amber and that at most one primary tier is visible per view.
9. Implement `AdminStudentsPage.css`'s shadow zones (roster cards `--shadow-card`; the new additive `.roster-item--disabled` modifier `--shadow-muted-card` + ink-700 border, mirroring `WeekCard.css:150-158`; detail panels `--shadow-sheet`), the 3px border bump, and the roster header eyebrow (D14).
10. Fix the newly surfaced 390px overflow risk: add `flex-wrap: wrap` to `.detail-header` and `.account-access-row`. Write a test asserting it.
11. Implement the `AdminShell` nav tab treatment (D3 scope only) per the handoff, using `--border-width-accent` + ink-800 (decision D3b), preserving `aria-current="page"`.
12. Add the `@media (forced-colors: active)` block to all three target CSS files per the handoff's per-file specification (D8), including `background-image: none` on `.owner-dashboard`.
13. Run the full gate: `npm run type-check`, `npm run lint`, `npm test`, `npm run build`. Whole-suite results must be no worse than the step-1 baseline in every respect.
14. Independent Verifier pass (read-only), then Browser Validator pass at BOTH viewports per the brief below.

## Interfaces and data

No backend, contract, migration, RLS, or data-model change. The only new public surface is `MetricPlate`'s optional additive `supportingFigure?: string` prop, rendered as a second line beneath the primary figure; omitting it leaves every existing render identical, and `MetricPlate` has exactly one real consumer today. Two new additive CSS modifier classes are introduced — `.dashboard-panel--table` and `.roster-item--disabled` — which MUST compose alongside their base class rather than replace it, so every other rule in the shared selector groups keeps applying. Exact modifier names are engineering's choice. `AccountStatusPill` is consumed as-is and not edited. `Control`, `OwnerLedgerRow`, `Modal`, and `App.css`'s `.paper-stock--graph` are all consumed unchanged.

## Acceptance and validation

Deterministic gates, all must pass: `npm run type-check`, `npm run lint`, `npm test`, `npm run build`. Whole-suite results must be no worse than the step-1 baseline.

Issue #42 acceptance criteria mapped: matches §D.6/§D.7 at 1440 and §E.6 at 390 within the disclosed deviations (D2's brass override, D7's graph tile values, and §E.6's non-depiction of the mobile table); dashboard uses graph paper stock AND a shadow-sheet container treatment; metric plates carry a mono label and a large zero-padded Fraunces figure; ledger rows show a filled bar PLUS raw zero-padded figures and no bare percentage appears anywhere, including the completion-rate plate; account states are glyph + word as `✓ Active` / `◔ Pending first login` / `✕ Disabled`; the owner student-progress table keeps `--shadow-brass` as the deliberate §A.3 legacy exception; destructive actions are terracotta and reversible ones amber with label text never amber; the roster is usable at 390 as reflowed rows and the PAGE BODY never scrolls horizontally; plus the standard fixed §A.6 criteria.

**Atelier / `visual_diff`.** The Atelier MCP compiler gap remains disclosed and user-authorized. The `visual_diff` requirement at BOTH 1440 and 390 is satisfied by the established precedent from issues #31-#41: hand transcription with a documented manual `visual_diff` substitute, performed and recorded separately for each breakpoint. This substitution is PRE-AUTHORIZED for this issue at both breakpoints; it is not a new deviation and needs no fresh approval.

## Binding engineering invariants

The following must all hold in the delivered code, verbatim, without exception:

- **`.owner-dashboard` carries `.paper-stock--graph`** at its shipped, unchanged 17-18px/`#e3dbcd` values, plus its own container-level `box-shadow: var(--shadow-sheet)` and `--border-width-rule` ink border — a NEW application, distinct from and additional to the nested panel-level shadow assignments.
- **The roster stays a div-based card list — never converted to a `<table>`** (D4).
- **`.paper-stock--graph`'s own shipped values are never altered** to match the mock's 20px/`#e8e1d4` literal (D7); applies equally to the new container-level usage.
- **Only these three files' `--shadow-print` usages are touched**; the ~21 other project-wide consumers are an explicit non-goal (D2).
- **`AdminShell` scope is nav-tab treatment only**; the dark header bar, brass logo mark, and Sign-out chrome belong to a different, out-of-scope component (D3) — do not touch or newly spec them.
- **`MetricPlate`'s `supportingFigure` prop is optional/additive**; the sole existing real JSX consumer is unaffected when the prop is omitted.
- **`.dashboard-panel--table` and `.roster-item--disabled` are additive modifier classes** composed alongside their base class, never replacements.
- **`Control`'s own tier CSS is not modified** — only raw-button consumers migrate onto it (D6).
- **`aria-current="page"` remains the accessible active-nav signal**, independent of the new border-bottom visual treatment.
- **Existing focus-ring tokens (3px / `#3d5f6b` / 2px offset) applied consistently, unchanged in value.**
- **The zero-pad grammar (`padStart(2,'0')`) is reused from `OwnerLedgerRow`, not reimplemented separately.**
- **The pending-account glyph/label becomes `◔` / "Pending first login" (D5)**; the pinned test at `AdminStudentsPage-status-label.test.tsx:103-120` requires a disclosed, bounded update alongside this fix — an intentional, scoped test change, not scope creep.
- **The page body must never scroll horizontally at 390 on either screen.** Overflow-x ownership stays scoped to `.dashboard-table-wrap` (dashboard, contained scroll region, deliberately dropped at <=28em once the table becomes stacked cards). The roster list needs no overflow-x owner; `.detail-header` and `.account-access-row` need `flex-wrap:wrap` added — a genuinely new, previously undisclosed risk this plan surfaces.
- **The `AdminShell` nav's conversion from `flex-wrap:wrap` to a single-row `overflow-x:auto`/`nowrap` treatment is motivated by §D.6/§E.6 mock fidelity, not a horizontal-scroll defect fix.** `AdminShell.css:14`'s existing `flex-wrap:wrap` already wraps overflowing nav items rather than causing page-body horizontal scroll, so it was never itself a scroll-safety defect. The conversion still stands as a reasonable, harmless change matching the mock's single-row contained-scroll nav treatment.
- **No native browser dialogs** (`alert`, `confirm`, `prompt`, `window.*` forms, `beforeunload`) anywhere in any of the three target files.

## Risks and rollback

| ID | Severity | Risk | Mitigation |
|----|----------|------|------------|
| R1 | High | The step-1 observed baseline differs materially from this plan's static findings, because no planning-stage agent could execute the suite or render a page | Baseline capture is the mandatory first ordered step and a material divergence is an explicit `JOB_BLOCKED` `Plan stale` condition, not something to work around |
| R2 | High | The 390px horizontal-overflow bug class has already hit #37, #39, and #41 in this milestone, and this plan surfaces two new candidate instances (`.detail-header`/`.account-access-row` with no `flex-wrap`, and `OwnerLedgerRow.css:74`'s 154px min-width) | An explicit `flex-wrap:wrap` fix with its own test, a dedicated J4 journey asserting no page-body horizontal scrollbar, and a named numeric browser-validation check for the 154px min-width |
| R3 | Medium | `MetricPlate` is a shared #36 primitive, so editing it could regress another consumer | It has exactly one real JSX consumer (independently grep-confirmed twice), the `box-shadow` addition is purely additive on a previously-unset property, and `supportingFigure` is optional; step 4 requires verifying no other consumer regresses |
| R4 | Medium | D2 deliberately overrides §D.6's own literal mock rendering for the student-progress panel | The divergence is explicitly disclosed in the design handoff with its §A.3 grounding, so a later reviewer checking mock fidelity finds the rationale rather than an unexplained discrepancy |
| R5 | Medium | The `OwnerDashboardPage.css` `:63-71` CSS-specificity remediation is fragile and was itself the product of a prior browser-validation cycle | A binding invariant to preserve it verbatim, plus existing `OwnerDashboardPage.test.tsx` coverage of the progress-column width and specificity |
| R6 | Medium | The plan updates pinned assertions in `AdminStudentsPage-status-label.test.tsx`, which could read as weakening a gate | Only the demonstrably wrong glyph/label assertions change, the design source's §D.7 literal is the authority, the rationale is recorded, and `CODE_REVIEW` is recommended |
| R7 | Low | The Disabled badge passes contrast at only 4.67:1 | A binding invariant forbidding a lighter tint or a .500 text step, plus a required live measurement during browser validation |
| R8 | Low | The wider `--shadow-print` versus `--shadow-brass` contradiction is left unresolved outside these three files, leaving the codebase in a mixed state | Deliberately scoped and disclosed; recorded as a candidate follow-up ticket, not silently ignored |

**Rollback.** Every change is confined to six source files plus tests, with no data, schema, or backend change, so rollback is a straight revert of the commit with no migration or state consequence.

## Assumptions and decisions

**Binding Planner decisions, all resolved during planning:**

- **D1** The acceptance criteria's "no bare percentages anywhere" governs over §D.6's literal "64%" mock. Resolved WITHOUT a backend change by deriving the raw figures client-side from data already loaded. The percentage remains the dominant Fraunces figure and the raw zero-padded fraction is a mono supporting line, preserving the uniform one-dominant-number scan pattern across all four plates.
- **D2** The owner student-progress table keeps a BRASS shadow, normalized to the ratified `--shadow-brass` rather than the 4.8px `--shadow-print`, preserving the acceptance criteria's deliberate legacy-print exception. Dashboard panels take `--shadow-sheet`; mobile row-cards and roster cards `--shadow-card`; the disabled roster card `--shadow-muted-card`. Scope is these three files only.
- **D3** `AdminShell` scope is the nav tab treatment only. D3b resolves its active indicator to `--border-width-accent` (6px) with ink-800, reusing an existing token for an identical single-edge state-marker role rather than minting a 5px token for exact mock fidelity.
- **D4** The roster REMAINS a div-based card list. §D.7's own mock shows individual cards, and converting to a table would newly create the exact 390px overflow risk class the acceptance criteria warns against. This is how "reflows to rows" is satisfied.
- **D5** `◷` / "Awaiting first sign-in" becomes `◔` / "Pending first login"; the pinned test assertions are updated as a disclosed bounded change.
- **D6** `AdminStudentsPage`'s caution, destructive, and secondary action buttons migrate onto the `Control` primitive so the amber/terracotta convention holds by construction rather than by convention. Label text is never amber.
- **D7** Use the SHIPPED `.paper-stock--graph` unchanged (17-18px / `#e3dbcd`), not the mock's 20px / `#e8e1d4`. Existing design-system values win. Disclosed deviation. The same precedent maps §D.6's 10px outer-frame shadow onto the shipped 8px `--shadow-sheet`.
- **D8** All three target CSS files gain a forced-colors block per the established per-component convention.
- **D9** `MetricPlate` `--default` and `--attention` gain `box-shadow var(--shadow-card)`; `--dark` unchanged.
- **D10** The 2px-to-3px border-width bump lands in this issue rather than as a fast-follow, because §A.3 specifies a 3px border for the card, sheet, and brass tiers, and every other consumer of those four shadow tokens pairs them with 3px; leaving 2px would make these three files the only inconsistent place in the app.
- **D11** The inner `.dashboard-table-wrap table` shadow is REMOVED rather than reassigned. §D.6's mock shows the inner table with no shadow of its own; the brass shadow lives on the new `.dashboard-panel--table` modifier. This both matches the mock and eliminates the wrapper-plus-inner double-shadow layering question.
- **D12** `AdminStudentsPage`'s raw status-badge markup is SWAPPED for the shipped `AccountStatusPill` rather than re-pointing its CSS, giving a single source of truth and removing the drift by construction.
- **D13** Tier assignments confirmed and pinned: Mark-email-confirmed and Re-issue-access are caution-irreversible; Unassign is promoted from plain secondary to caution-reversible; the password-change-requirement toggle is caution-reversible; Reset-Week-N, Confirm-reset, and Wipe-Save are caution-irreversible.
- **D14** The §D.7 roster header eyebrow ("N filed · N pending") IS in scope — both counts are derivable client-side from already-loaded data with no backend need. The "+Add student" and owner-view date copy variants are NOT in scope; shipped copy is kept.
- **D15** The 28em mobile-table-collapse breakpoint is NOT widened for 200%-zoom coverage. The design reviewer judged the gap a non-breach because `.dashboard-table-wrap` owns its own overflow-x containment. Recorded as a candidate follow-up ticket.
- **D16** The dead `.dashboard-metric` CSS rules, orphaned when #36 replaced that markup with `MetricPlate`, are deleted as part of this composition pass.
- **D17** If the client-side completion-rate sum cannot be reconciled with `summary.completion_rate` within rounding, the engineer returns `JOB_BLOCKED` rather than rendering two disagreeing numbers on the same screen.

**Disclosed content gaps carried forward, not silently resolved:** the dashboard's empty-state copy is ambiguous today, one shared string covering both a true zero-students dashboard and a filtered-to-nothing search; the roster has no search or filter input at all, so a search-no-match state is genuinely not applicable rather than missing; and the roster and detail views have no persistent success banner anywhere, communicating success only implicitly via post-action refresh — a real cross-screen asymmetry with the dashboard.

**Safe assumptions:** the design source's §C.2/§C.7/§C.8 canonical patterns outrank a single screen mock where they conflict; the existing owner-table conventions at `OwnerDashboardPage.css` are the right precedent for a second owner table; and the plan's static findings are provisional until step 1 confirms them.

**Standing user authorization.** The user has set an explicit session goal to implement and browser-validate all Field Journal DS issues without approval checkpoints, quoted by the orchestrator as "don't stop until all the DS gh issues are implemented and browser validated," consistent with the precedent recorded on the #31-#41 plans. This is recorded as the orchestrator's account, using the same provenance discipline and explicit inference labeling the #40 and #41 plans' "Approval basis" sections use. The orchestrator independently fetched the live issue #42 body and relayed it into Planner's context, satisfying the pre-flight staleness check.

## Required approvals

This plan document's engineering-dispatch approval is recorded in "Approval basis" at the top of this document, under the orchestrator's application of the recorded standing authorization. That record, not this section, is the operative approval statement. If the standing authorization is later withdrawn or found not to cover this issue, this plan reverts to requiring explicit per-document user approval before further T1/T2 work proceeds.

## Browser UI dialog policy

Required — browser-rendered React/Vite UI. Native `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload` prompts are prohibited absolutely anywhere in the three target files or their modals. All acknowledgement and confirmation UI uses the app-owned accessible `Modal` (`src/components/Modal.tsx`), with keyboard operation and focus trapping, already regression-guarded by `ModalStackingAndInertness.test.ts`. Researcher confirmed zero native dialogs exist today in these surfaces; this pass introduces none. A deterministic no-native-dialog source scan across the changed files is a required acceptance check.

## Browser UI validation

**Launch/readiness:** `npm run dev -- --port 5613 --strictPort` in `H:\CommandCenter\orchestrator\lizbeth_spanish`; ready when Vite reports the local URL and the base URL returns 200. Port 5613 is chosen deliberately to avoid 4319, 5199, 5211, 5299, 5317, 5321, 5331, 5407, 5443, and 5471, all used earlier in this session, and to avoid the 5173 default.

**Base URL:** `http://localhost:5613`

**Fixture/reset:** sign in as the owner account; the roster requires at least one Active, one Pending-first-login, and one Disabled student to exercise all three badge states and the disabled-card modifier. Use the existing owner/admin test fixtures; do not create production data.

**Viewport profiles:** desktop 1440x900 and mobile 390x844. BOTH are mandatory and must be recorded separately.

**Journeys and visible outcomes:**

- **J1 dashboard load and edit** — graph tile and container sheet framing visible; dark plate brass shadow; the other three plates card shadow; the completion-rate plate shows a dominant percentage PLUS a mono raw zero-padded fraction, never a bare percentage; attention-rules panel sheet shadow; table panel brass shadow visibly distinct from it; ledger rows filled bar plus zero-padded raw figures; Save rules the sole primary.
- **J1b dashboard error recovery** — a single primary Retry.
- **J2 roster list and states** — `✓ Active`, `◔ Pending first login` (NOT `◷ Awaiting first sign-in`), `✕ Disabled`; the disabled card shows a muted border and shadow distinct from active/pending; Add Student the sole primary, Refresh secondary; the roster header eyebrow renders real counts.
- **J3 student detail actions** — Disable renders amber-fill with ink text, Delete renders terracotta-fill with paper text, label text never amber, exactly one primary (Assign) among all simultaneously rendered actions, and the confirmation `Modal` is app-owned with no native dialog ever appearing.
- **J4 mobile reflow and nav at 390** — the page body never produces a horizontal scrollbar at any point; nav tabs scroll within their own contained region; `.detail-header` and `.account-access-row` wrap rather than overflow; the active tab shows a bottom-border indicator, not a filled pill; `aria-current="page"` present.
- **J5 keyboard and focus at both viewports** — no mouse-only path, visible focus everywhere, 44px-plus hit areas, a 3px slate ring at 2px offset, tab order matching DOM and visual order.
- **J6 forced-colors and 200% zoom on all three surfaces** — borders remain shape-distinguishing with shadows neutralized, badges remain distinguishable by glyph and word alone, and no page-body horizontal scroll appears at 200% zoom even if the table stays in desktop form.

**Explicit numeric checks required**, carried from the design review's open limits: `OwnerLedgerRow.css:74`'s 154px min-width at exactly 390px; the `.roster-item` rendered height against the 44px floor; live measurement of the Disabled badge's 4.67:1 contrast; and a visual sanity check of the new nested container-plus-panel double sheet shadow at both viewports.
