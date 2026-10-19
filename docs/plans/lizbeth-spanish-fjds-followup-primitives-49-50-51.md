# Lizbeth Spanish — Design System Follow-Up Primitives (Issues #49, #50, #51)

## Status

**CLOSED — complete, 2026-09-08.**

All four work items are delivered and merged to `main`: Item 0 (baseline capture and cohort fixture provisioning, no PR), Item 1 (#51 labelled access-control row, PR #141), Item 2 (#50 asset-card grid, PR #142), and Item 3 (#49 rich-text editor surface with the new eighth `Control` tier, PR #143). Final `main` at `5a79578`. GitHub issues #49, #50, and #51 are all closed, 2026-09-08. Independent review caught three runtime-only defects, a flaky Playwright spec, and a missing regression test that the writer's own evidence did not surface; all are fixed and now guarded. See "Execution record" below for the full account.

- **Approver:** the user (rob.hasselbach@gmail.com / lebobo88).
- **Date:** 2026-09-08.
- **Basis:** the user's own explicit statement, verbatim: "approved, proceed as planned and continue autonomously until the entire field journal design system is properly implemented across all ui layouts and surfaces for the lizbeth spanish project". This followed the user's review of a compact summary covering: the `PLAN_DUCK` REVISE verdict and its three major findings; the remediation of all three; the eighth-tier correction; the verified cohort-fixture limit; and the disclosed fact that the J-02 error contract was not re-reviewed by `design-reviewer`.
- **Judge record:** `PLAN_DUCK` ran at `gpt-5.6-terra`, medium effort, shadow mode, returning REVISE at high confidence with three major findings (J-01 Control architecture, J-02 editor error state, J-03 accessibility validation gap). All three were accepted and remediated, each independently re-verified against the repository rather than inherited from the judge's claim. Policy action was advisory under shadow mode.

  Operational note: two prior `PLAN_DUCK`/`CODE_REVIEW` invocations in this program returned `ABSTAIN`/`unassessed` because the Codex adapter's Windows sandbox failed with `helper_unknown_error: apply deny-read ACLs`. This was root-caused to `windows.sandbox="elevated"` requiring OS elevation the session lacked, and fixed by switching the adapter to `windows.sandbox="unelevated"` (verified 3/3 clean, including a large-read-surface test against `lizbeth_spanish`). The successful run recorded above was the first after that fix.
- **Disclosed limit not covered by this approval's review:** the J-02 error contract was composed under judge remediation and was **not** re-reviewed by `design-reviewer` — the design PASS covers the handoff as it stood before that addition.

No downstream dispatch — to T1, verifier, browser-validator, design-reviewer, or any issue-creation action — may occur before this approval is recorded. This approval record authorizes dispatch of Item 0 onward per the ordered work below, subject to each item's own no-dispatch gates.

## Outcome and audience

Ship the three "design system follow-up" component primitives disclosed by GitHub issue #44: #49 (rich-text editor surface), #50 (asset-card grid), #51 (labelled access-control row). These close primitive gaps that #44 identified but could not close under its own hard constraint that no new component may be invented mid-issue.

Audience: the engineering fleet (T1/T2, verifier, browser-validator) executing this plan, and the user approving it.

## Governing umbrella

This plan is a follow-on to `docs/plans/lizbeth-spanish-fjds-full-app-conformance-closure.md` ("the umbrella plan"), which remains authoritative for the Field Journal design system's token registry, engineering invariants, no-touch list, GitHub issue logging policy, browser-validation infrastructure notes, and standing authorizations. This document cross-references that plan rather than restating its content. Where this plan is silent on a governing rule (token deprecation registry, cascade-collision hazard class, issue-logging conventions, authority ordering between lint and visual diff), the umbrella plan's rule applies.

## Scope

### In scope

Exactly three GitHub issues: #49, #50, #51. All three are OPEN, labelled `enhancement`, no milestone, filed 2026-09-02, no comments, per the information supplied to planning (see Assumptions and decisions for the stated evidence limit on this). All three share one root cause: issue #44 (`docs/plans/lizbeth-spanish-issue44-derived-owner-pages.md`) hit genuine primitive gaps, applied foundation-only interim treatments, and disclosed the gaps as follow-ups.

### Non-goals

- **GitHub issue #11** ("desktop view for students") is explicitly **not** in this plan. It is in scope for the umbrella program's standing goal but is a different kind of work — a responsive-layout initiative across five student pages, not a component primitive — and is being planned separately. Do not fold it in.
- **No new visual direction.** Inherited verbatim from the umbrella plan's non-goals and binding here as an explicit acceptance check (see Acceptance and validation), not merely a principle. All three primitives must be composed from the ratified Field Journal DS language.
- No re-litigation of the ADOPTION-PLAN's ratified deviations.
- No token-source or pipeline change. The reviewed design handoff requires no new DTCG token. `.atelier/tokens/field-workbook.tokens.json` is not edited and no pipeline run is needed.
- No change to #51's `<select>`, revoked-hint, or either Modal confirmation — all three already compose fully from shipped primitives and need no follow-up. Only the row/container shape is bespoke.

### No-touch list

Inherited from the umbrella plan, plus plan-specific additions:

- Never hand-edit `src/tokens/field-workbook.generated.css`.
- Never regenerate `docs/token-deprecation-baseline/phase1-baseline.json`.
- `design/field-journal/ADOPTION-PLAN.md` carries a deliberately uncommitted local modification that must never be staged. Read-only.
- `lizbeth_spanish/atelier.config.json` is never edited — standing directive; the operative config is the orchestrator-root one.
- Destructive git commands are prohibited. Never `taskkill`; scoped-PID termination only, and reuse an existing healthy dev server.
- Do not modify the LOCKED rule `.tiptap-editor .ProseMirror:focus { outline: 3px solid var(--color-focus-ring); outline-offset: 2px; }` at `src/pages/CourseWorkspace.css:146`, guarded by `src/__tests__/courseWorkspaceDisabledHoverAndTiptapFocus.test.ts` (issue #107).

## Background and repository findings

All findings below were verified by direct read against current `main` at 9d1a20f during planning.

- All three issues land in the same two files: `src/pages/CourseWorkspacePage.tsx` and `src/pages/CourseWorkspace.css`. This shared file surface drives the serial-sequencing decision in Ordered work.
- `CourseWorkspace.css` is written in a dense, near-minified one-rule-per-line style. The relevant declarations are on lines 144-146 and 265-279. Line-numbered edits must account for this style and should be re-verified against the file at implementation time rather than trusted as fixed offsets after prior edits land.

### #49 — rich-text editor surface

- `function Editor` is at `CourseWorkspacePage.tsx:160`; `function LessonEditor` at :158; `TiptapDocument` imported at :10; `EditorContent, useEditor` from `@tiptap/react` at :2.
- The toolbar is three plain `<button type="button">` elements carrying only `aria-label` and `title`. There is **no `aria-pressed`, no `role="toolbar"`, and no active-mark styling at all.**
- Chrome at `CourseWorkspace.css:146`: `.editor-toolbar` (paper.200, 2px ink.1000 border, `border-bottom:0`); `.editor-toolbar button` (`min-height:44px; min-width:82px; border:1px solid ink.1000; background:paper.100; font-weight:700`); `.tiptap-editor .ProseMirror` (paper.100, 2px ink.1000 border, min-height 220px, padding 16px).
- **Correction of record — issue #49's body is stale.** It states the focus ring is "3px terracotta.600." Current `main` is slate `--color-focus-ring` (`#3d5f6b`, defined at `src/App.css:40` as `var(--color-ink-slate, #3d5f6b)`), remediated under issue #107. This correction must carry into the implementation so no engineer "restores" terracotta.
- **Confirmed live accessibility gap:** the `readOnly` prop already exists and is threaded through `Editor`/`LessonEditor`, but produces no visual treatment whatsoever. The published-version read-only branch is genuinely reachable via the existing `.studio-readonly` banner at `CourseWorkspacePage.tsx:155`.

### #50 — asset-card grid

- The asset-library `<li className="asset-card">` is inside the single long line `CourseWorkspacePage.tsx:155`.
- CSS at `CourseWorkspace.css:144`: `.asset-library ul` is `grid-template-columns:repeat(3,minmax(0,1fr))`; `.asset-card` is `display:flex;flex-direction:column;gap:var(--space-2);border:1px solid var(--color-ink-700);padding:var(--space-2)`. Collapses to `1fr` at max-width 700px (`:145`).
- Remove (`caution-reversible`) and Copy reference (`secondary`) are already the `Control` primitive; only the container is bespoke.
- **Richer than the issue body states:** there is a **third** `<small>` provenance line ("Inherited from published version" / "Checksum verified" / "Legacy asset · checksum unavailable"), and an `inherited` asset suppresses its Remove action entirely.
- **Additional finding:** `CourseWorkspace.css:144`'s shared selector `.studio-actions button,.asset-card button,.asset-header label{min-height:44px}` down-overrides the card's action Controls from 48px to 44px, breaking C.1's one-geometry invariant.

### #51 — labelled access-control row

- `StudentRoster` at `CourseWorkspacePage.tsx:275`; `.roster-lesson-row` rendered at :398 (no-entitlement branch) and :411 (live branch).
- CSS at `CourseWorkspace.css:266`: `display:grid;grid-template-columns:1fr auto;gap:var(--space-3);align-items:start;padding:var(--space-2) 0;border-top:1px solid var(--color-ink-1000)`; collapses to `1fr` at 700px (`:279`).
- Revoked differentiation is weight-only (`:271`), never colour alone — already correct.
- **Class-name collision, confirmed:** the same `.roster-lesson-row` class is reused at `CourseWorkspacePage.tsx:657` for an unrelated cohort **member-list `<li>`** (`{member.student_display_name} — {memberStatusLabel(member.status)}`), inside a `.roster-lesson-list` region name that is also shared. Two different shapes wearing one class name. This program has already shipped one class-name-collision defect (`.course-workspace` shared across two unrelated pages, leaking a terracotta focus ring — see the umbrella plan), so this is a known recurring failure mode here, not a hypothetical.
- **Collision-split safety, independently verified by design-reviewer line-by-line.** The evidence, not just the conclusion: the three roster test files — `issue5-phase3-student-roster.test.tsx`, `issue5-phase4-revoked-rendering.test.tsx`, and `issue5-phase4-revoke-action.test.tsx` — were read line-by-line, and every `.roster-lesson-row` query resolves via lesson titles ("Greetings," "Numbers," "Colors"), never via member names. **Scope of the search that grounds this, added during judge remediation:** a repository search found no `.roster-lesson-row` consumers beyond `CourseWorkspace.css`, the two render sites at `CourseWorkspacePage.tsx:398` and `:411`, the member `<li>` at `:657`, and those three test files. **Residual limit, stated plainly:** a dynamically constructed or partial-string selector would not be caught by that search, so this is a bounded search result, not a proof of absence. Renaming only the member `<li>` breaks no test found by that search. Renaming the entitlement row instead would be the higher-risk direction.
- Governing precedent for #51: `src/components/FeedbackLedgerRow.tsx:51-54` records issue #41 decision D3 — when an existing primitive's prop shape does not fit, the resolution is a **disclosed sibling primitive, not a forced fit**. Its header docblock is also the house model for disclosing a deliberate deviation with reasons.

### Existing primitive conventions

- `src/components/ui/Control.tsx:25-49` — seven tiers: `primary`, `secondary`, `caution-reversible`, `caution-irreversible`, `quiet`, `quiet-outline`, `nav`. `caution-reversible` (amber) vs `caution-irreversible` (terracotta) is split by reversibility, not severity; disabled requires the native `disabled` attribute, never a CSS-only class; forwards ref. **Correction, added during judge remediation:** `Control.css:1-7`'s own header comment says "five tiers" — that comment is itself stale and must not be propagated. `Control.css:161-165` documents `.menu-trigger` as a deliberate one-off override applied alongside `control--quiet-outline`, not a new tier, so it does not change the seven-tier count. The `toggle` tier introduced by this plan (see Design handoff) is therefore the **eighth** tier, not the seventh — every occurrence of "seventh" elsewhere in this document has been corrected to "eighth."
- `src/components/ui/Field.tsx` (C.2) — mono label above, never placeholder-only; error changes two things, colour alone is a failing implementation; typed `input|textarea` only — exactly the gap #49 names.
- `src/components/OwnerLedgerRow.tsx` (C.7).

### Test infrastructure

- Playwright is established and working: `playwright.config.ts` (`testDir: './src/__tests__/e2e'`, chromium project, `npm run test:e2e`), 16 existing `.spec.ts` files, and a `src/__tests__/e2e/browser-validation-artifacts/` screenshot corpus from prior cycles.
- **Two distinct base-URL paths exist and must not be conflated.** `playwright.config.ts` defaults `baseURL` to `http://localhost:8888` and, absent `E2E_BASE_URL`, starts `npm run build && netlify serve --context production --port 8888`. This is a production-parity path, not the `npm run dev` / port 5173 interactive-validation path used elsewhere in this program.
- `src/__tests__/helpers/cssCascade.ts` (`resolveCascade`, `describeDeclaration`) is the repository's real cascade resolver, used for resolved-declaration assertions rather than source-text matching. `src/__tests__/helpers/resolveCssToken.ts` resolves tokens to hex.

### Repository-state note

`src/components/journal/` currently contains only `ClipRing`, `JournalEmptyState`, and `Stamp`. `Folio` and `TabStack`, recorded as unwired in the umbrella plan's five-vector legacy inventory, are no longer present. This is recorded as an observation of current repository state at planning time, not a claim about how or when they were removed.

## Research evidence

One nested Researcher pass, primary sources only, for #49's toolbar/contentEditable accessibility. Its value is as much in what the authorities do **not** say as in what they do — this program has a recorded incident of shipped code citing a nonexistent authority (a "WCAG/ARIA APG data-loss exception" absent from the actual APG), so this section preserves every negative finding and every gap rather than smoothing them into confident prose.

- **APG Toolbar pattern** (https://www.w3.org/WAI/ARIA/apg/patterns/toolbar/): the container "has role toolbar"; the tab sequence includes one stop for the toolbar, with arrow keys moving focus among its controls; `aria-orientation: vertical` only when vertical. The pattern prose does **not** name "roving tabindex" as required — it is one of two techniques, the other being `aria-activedescendant`. **APG is a non-normative W3C Working Group Note, not a Recommendation.**
- **APG Button pattern** (https://www.w3.org/WAI/ARIA/apg/patterns/button/): for a toggle button, "specify a value for the attribute `aria-pressed`," and "it is critical the label on a toggle does not change when its state changes." `aria-checked`/`menuitemradio` belong to mutually-exclusive selection widgets, not independent formatting toggles.
- **WCAG 2.2** (normative Recommendation, https://www.w3.org/TR/WCAG22/): the only normative requirements are the success criteria themselves — 2.1.1 Keyboard (A), 2.4.7 Focus Visible (AA), 2.4.11 Focus Not Obscured Minimum (AA), 2.5.8 Target Size Minimum (AA, 24x24 CSS px), 4.1.2 Name Role Value (A), 3.3.1 Error Identification (A), 3.3.3 Error Suggestion (AA). 4.1.2 requires that whatever pressed state exists be programmatically exposed; it does not itself mandate `aria-pressed` as the only conforming technique.
- **Tiptap's own accessibility guide** (https://tiptap.dev/docs/guides/accessibility, first-party): the editor "should have the `role=\"textbox\"`" and the toolbar "should have the `role=\"toolbar\"`." **Explicit negative finding:** it does not mention `aria-multiline`, does not address `aria-label`/`aria-labelledby`, and does not discuss toggle-button state.
- **Forced colors (MDN):** `box-shadow` is forced to `none` and colours to system colours under `forced-colors: active`; preserving a custom pressed state or focus outline requires system colour keywords in a `@media (forced-colors: active)` block. MDN frames `forced-color-adjust: none` as a narrow-use exception with real cross-browser support caveats, not a default. `accent-color` applies only to native `<input type=checkbox|radio|range>` and `<progress>` — irrelevant to a custom button, but it is the mechanism a native `<select>`/checkbox relies on.

**Three open evidence gaps, carried forward verbatim and not closed by inference:**

1. The WAI-ARIA 1.2 normative `aria-pressed` definition was not fetched directly (404 on the attempted anchor), so the APG Button pattern is the citable source and the raw spec is not yet re-verified.
2. No first-party prosemirror.net page was fetched, so `role="textbox"` rests on Tiptap's guide alone.
3. WCAG 3.3.1/3.3.3's applicability to a contentEditable rich-text region is an inference from generic success-criteria wording, not a cited authority statement about rich-text editors specifically.

**Binding framing rule for implementation and documentation:** roving tabindex and `aria-pressed` must be presented as **APG guidance voluntarily adopted** — satisfying WCAG 2.1.1/4.1.2 by a documented technique — and never as "WCAG requires." `aria-multiline` must be stated as not vendor-documented, not as a cited requirement.

## Design route

```
DESIGN_ROUTE
profile: standard
reasons: Three net-new, multi-state, user-visible component primitives extending a ratified in-repo design system. Each carries a real state matrix; one (#49) carries a composite toolbar-plus-editable-region interaction model. Not compact (three components, multi-state, shared file surface). Not studio — the creative direction is already fixed and ratified by the Field Journal DS, and the umbrella plan's "No new visual direction" non-goal makes safe/refined/novel directions the wrong tool.
agents_required: design-director, ux-architect, visual-system-designer, design-reviewer
prototype: forbidden
model_tier: sonnet
existing_system_mode: extend
END_DESIGN_ROUTE
```

### Design handoff (binding contents)

A complete reviewed `DESIGN_HANDOFF` was produced by design-director with ux-architect and visual-system-designer. Its contents are recorded here as authoritative alongside the design-review record below.

**Selected direction: no new visual direction.** All three primitives compose from ratified FJDS vocabulary (A.3 elevation table, A.4 paper stocks, A.6 invariants, C.1 tiers — see the umbrella plan for the full table). Zero new colours, radii, shadows, or type roles. No new DTCG token; no pipeline run.

#### #49 toolbar button — a new disclosed C.1 sub-tier, `toggle`

None of the seven shipped `Control` tiers carries a persistent `aria-pressed` concept. This follows the exact precedent by which `quiet-outline` (#36) and `nav` (#71) were disclosed as new sub-tiers.

- Resting paint reuses `.control--secondary` verbatim (`Control.css:50-55`).
- **Geometry is corrected, not preserved.** The bespoke `min-height:44px; min-width:82px; border:1px solid` is rejected because A.6 rule 3's 44px is a stated floor, not a target, and C.1 commits every tier to "one geometry: 3px rule-black outline, zero radius, ... 48px tall" (`Field Journal DS.dc.html:332`). Corrected to `min-height: var(--control-height)` (48px), `border-width: var(--border-width-rule)` (3px), no `min-width`.
- Full state set: default; hover (`:hover:not(:disabled):not([aria-pressed="true"])`); focus-visible; pressed (`[aria-pressed="true"]:not(:disabled)` → `transform: translate(3px,3px); box-shadow: var(--shadow-none)`, a shape-and-position cue, never colour alone, per A.6 rule 1); disabled (native `:disabled` only); empty-content.
- Hover is deliberately suppressed while pressed so lift and sink cues never compete — a disclosed decision, not a DS citation.

**Architecture decision, resolved during judge remediation — SHARED. The `toggle` tier is the eighth `Control` tier, not a page-scoped equivalent.** The plan previously left this as an either/or engineering choice, which left no conformance boundary and made the acceptance gates undecidable. Grounds for closing it as a shared tier:

- The specified resting paint is `.control--secondary`'s recipe verbatim (`Control.css:50-55`), and the pressed geometry is `.control--secondary:active`'s verbatim (`Control.css:61-64`). A page-scoped copy would duplicate C.1 geometry in a second location.
- Duplicating C.1 geometry into a page stylesheet is precisely the cascade-collision hazard class this program has already shipped twice — `.course-workspace` shared across two unrelated pages, and `.workspace-panel .demo-button.primary` scoped on a class that `PublicCatalogPage` also uses (see the umbrella plan). A shared tier keeps one source of truth.
- The universal `.control:disabled` and `.control:focus-visible` rules already deliver two of the six required states for free; a page-scoped button would have to re-implement both, including the forced-colors block.

**Selector precedence and state interaction, specified from a direct read of `Control.css`:**

- Source-order placement: the `.control--toggle` rules go with the other tier blocks, before the universal `.control:focus-visible` (`:177-180`), `.control:disabled` (`:183-191`), and `@media (forced-colors: active)` (`:193-250`) blocks, matching the file's existing all-tiers-then-universals-then-forced-colors structure.
- `.control:disabled` is specificity (0,2,0) and is declared after every tier base rule (0,1,0), so it wins over `.control--toggle`'s base paint. This is the existing mechanism for all seven prior tiers and is preserved, not re-engineered.
- **Binding engineering invariant: the pressed rule must carry its `:not(:disabled)` guard.** `.control--toggle[aria-pressed="true"]` alone is (0,2,0) — identical specificity to `.control:disabled` — so a disabled-but-pressed button could resolve to pressed paint instead of disabled paint depending on declaration order. Writing it as `.control--toggle[aria-pressed="true"]:not(:disabled)` (0,3,0) makes the guard structural rather than order-dependent.
- The hover rule `.control--toggle:hover:not(:disabled):not([aria-pressed="true"])` is (0,4,0) and therefore also survives ordering; the deliberate suppression of hover while pressed, described above, is preserved by this specificity.
- **Focus-ring token note**, recorded because it looks like an inconsistency and is not one: `.control:focus-visible` (`:178`) uses `--color-focus` while `.control--nav:focus-visible` (`:150`) uses `--color-focus-ring`. Both resolve to slate `#3d5f6b`. `toggle` inherits the universal `.control:focus-visible` and declares no override.

**Forced-colors for `.control--toggle`** — extends the `Control.css:193-250` precedent: `ButtonText`/`ButtonFace` for resting paint; `[aria-pressed="true"]` adds `border-style: double` as a redundant non-colour cue because `box-shadow` is auto-forced to `none` while `transform` survives; `:disabled` uses `border-style: dotted` + `GrayText`; `:focus-visible` uses `outline-color: Highlight`. No `accent-color`, no `forced-color-adjust: none` anywhere.

**Regression coverage for the existing seven consumers, added to Item 3's acceptance below:** resolved-cascade assertions via `cssCascade.ts` proving that adding the `toggle` tier changes nothing for the existing seven tiers at rest, hover, active, focus-visible, and disabled, and that the existing forced-colors block is unaltered. Adding a tier to a shared primitive is the one part of this plan that can regress surfaces outside `CourseWorkspacePage`, and the gate says so explicitly.

**#49 ProseMirror body:** default unchanged. The focus rule is LOCKED and preserved verbatim (see No-touch list). Read-only adds one new declaration only — `.tiptap-editor .ProseMirror[aria-readonly="true"] { background-color: var(--color-paper-200); }` — citing A.4's "card · flat paper.200 → index cards, locked states, tabs" (`Field Journal DS.dc.html:172-173`); border unchanged. `--shadow-muted-card` is explicitly declined (the body has no elevation to mute). Empty-content gets no placeholder: A.6 has no rule requiring one, and placeholder copy is a product decision (see Open decisions).

**#49 semantics:** `role="toolbar"` on the container; `aria-pressed` on each of the three buttons bound to `editor.isActive(...)`; roving tabindex (one tab stop, Left/Right among the three, wrapping — wrapping is convention, not APG-mandated); `role="textbox"` added explicitly to the body; existing `aria-label` preserved verbatim; `aria-multiline="true"` added as a labelled inference, **not vendor-documented**; `aria-readonly="true"` when read-only, with the role kept, not removed.

**#49 error state, added during judge remediation.** Issue #49's own verbatim follow-up ask names "focus/error states" as in scope; the plan's original draft specified toolbar and read-only states but left the error journey unspecified. Closed here as a composition from C.2's already-ratified, already-reviewed two-channel pattern — not a new visual direction and not a new token.

- **Verified current-repository finding:** there is no error condition wired to the editor today. `Editor` and `LessonEditor` accept no `error` prop. The only error surfaces in this component tree are page-level: the save failure at `CourseWorkspacePage.tsx:70` (`setError`, "Save failed. Your local recovery copy is retained.") and the `TabBoundary` error boundary at `:77`; plus `Content`'s `assetError` for asset/proofreading/export failures, rendered as a page-level `<p role="alert">`. The only field-level validation in the authoring surface is `validateOffsetInput` (`src/lib/courseAuthoring.ts:45-48`), which belongs to the Outline tab's `Field`, not to the editor.
- **Specification:** optional `error?: string` prop, mirroring `Field.tsx`'s existing signature. Two channels, never colour alone — a terracotta rule on the ProseMirror body plus a mono error line beneath it, reusing the existing `.field__error` treatment rather than inventing a second error visual. This is C.2's binding rule as already implemented in `Field.tsx`'s docblock and `Field.css`: "error state changes TWO things: the border colour AND a mono error line — a colour-only change is a failing implementation." Semantics mirror `Field.tsx:56-64` exactly: `aria-invalid="true"` when in error, `aria-describedby` pointing at a generated `${id}-error` node, and the error node rendered as a real element carrying the message text. The error clears when the caller clears the prop; the primitive owns no error state of its own, the same ownership model as `Field`.
- **Interaction with the other states:** error and read-only are independent axes; the error rule must not override the read-only paper.200 ground, and the locked focus rule at `CourseWorkspace.css:146` continues to win at focus regardless of error state.
- **Gating, honestly scoped.** Because no call site supplies `error` today, this is gated by unit tests plus resolved-cascade assertions via `cssCascade.ts`, not by a browser journey — there is no reachable rendered error state to photograph, and no journey below claims to cover it.
- **New open decision, added under this item** (see Open decisions): whether a call site should exist — specifically whether the page-level save failure at `CourseWorkspacePage.tsx:70` should surface at the editor instead of, or in addition to, page level. Genuinely open; does not block Item 3.
- **Disclosure limit, stated plainly:** this error-state specification was added by the Planner under judge remediation, composed from the already-ratified C.2 pattern. It was **not** re-reviewed by `design-reviewer`, whose PASS (see Design review record) covers the handoff as it stood before this addition.

#### #50 asset-card grid

**Verdict on the 1px ink.700 hairline: a defect, corrected to A.3's `rule.thin`.** A.3 lists exactly four named weights, none 1px; `rule.thin` = 2px ink.1000, no shadow, scoped to "inputs, list rows, inline chips" — and an asset-card grid item is exactly a list row. The shipped `1px solid var(--color-ink-700)` matches none of the four named weights: wrong width and wrong colour role. Corrected to `border: var(--border-width-thin) solid var(--color-ink-1000)`.

`--border-width-thin` was independently confirmed to genuinely resolve to 2px (`field-workbook.generated.css:40`) — the whole verdict depends on this and it was checked.

The DS "card" elevation tier (3px + 5px hard shadow) was explicitly considered and **rejected** as an alternative target: it would add a shadow this component has never had, which is a redesign, not a correction, and is foreclosed by the no-new-visual-direction non-goal.

Other specifications:

- Name as `<strong>` at `--font-size-body` (17px, A.4's stated floor) with explicit `--font-weight-label`.
- Both metadata `<small>` lines as IBM Plex Mono at `--font-size-label-small` in `--color-ink-700`, matching the shipped `.owner-ledger-row-progress-figure` treatment and DS device B.9's "machine facts: dates, counts, IDs, states."
- Action slot is a wrapping flex row tolerating 0-2 caller Controls.
- No card-level hover and no card-level focus — the card has no `onClick` and whole-card hover would falsely imply clickability.
- Inherited/legacy are metadata-content differences only, no distinct chrome.
- Recommend dropping `.asset-card button` from the shared 44px selector at `CourseWorkspace.css:144`.

**Decorative thumbnail/type-icon slot: declined.** No file-type iconography exists anywhere in A.3/A.4/C.1/C.2/C.7 or in the current markup; inventing one would be new visual direction. If product later authorizes one, `OwnerLedgerRow`'s `AttentionIcon` (aria-hidden, decorative, text carries the meaning) is the pattern to imitate.

#### #51 labelled access-control row

Same defect class as #50, corrected the same way: `border-top: 1px` → `var(--border-width-thin)` (2px); colour is already correct at ink.1000. Grid, gap, and padding are unchanged — no defect found there. `.revoked-hint` weight-only differentiation is preserved verbatim, already compliant.

**Class-collision verdict: the cohort-member row is an unrelated shape, not a second legitimate consumer of `.roster-lesson-row`.** An access-control row's defining contract is "one interactive control, one confirmable state machine, per lesson per student"; a membership-status `<li>` has none of that, and forcing them together would repeat the exact forced-fit failure #41 D3 already corrected. Resolution: give the cohort-member `<li>` its own class (illustrative name `.cohort-member-row`; the literal string is an implementation choice) with its own minimal rule — `border-top: var(--border-width-thin) solid var(--color-ink-1000); padding: var(--space-2) 0;` — no grid columns, no 700px collapse rule. Rendered layout may stay visually near-identical; selector identity must differ.

**Forced-colors on the three non-interactive borders** (`.asset-card`, `.roster-lesson-row`, `.cohort-member-row`): `border-color: CanvasText; forced-color-adjust: auto`. Framed honestly and deliberately: CanvasText fits structural non-interactive content chrome, but forced-colors usage in this codebase is genuinely **mixed** between CanvasText and ButtonText for non-interactive borders (compare `ContextStatusStrip.css:54` to `MetricPlate.css:96`), so this is a semantic choice, not an invocation of a uniform prior rule. An earlier draft of this handoff overclaimed a "9+ files convention" and was corrected on design review; this framing must be preserved exactly and not re-upgraded to a stronger claim.

#### Engineering invariants from the handoff

- Do not modify the locked ProseMirror focus rule when adding the `[aria-readonly]` background rule — add a separate, non-overlapping declaration.
- The `toggle` tier's disabled paint must come from the native `:disabled` pseudo-class only.
- The toolbar buttons are wired through the shared `Control` component as a literal eighth tier (resolved during judge remediation — see the architecture decision above); this is no longer an either/or engineering choice. The tier must be disclosed the way #36/#71 were.
- The #50/#51 border corrections are pure token substitutions requiring no markup change.
- Do not hand-edit the generated CSS.
- Do not extend `--shadow-muted-card` to any selector in this plan.
- The native `<select>` is never replaced with a custom control anywhere — a prior design review in this project rejected a custom control mark precisely because dropping native `accent-color` would silently lose forced-colors support, a convention held across 49 files.

### Design review record

**Verdict: PASS, on revision 1.** Recorded honestly rather than as a clean single pass, matching the umbrella plan's own disclosure style.

The design-director's packet initially asserted its own internal review. Per `docs/DESIGN-CONTRACT.md`, the Planner ran `design-reviewer` independently against primary sources; that independent gate is the one recorded here.

The first independent review returned **NEEDS_REVISION** with one MEDIUM finding (DR-EVIDENCE): the spec justified `CanvasText` by claiming a "9+ files established convention" of CanvasText-for-plain-content vs ButtonText-for-controls. Sampling contradicted the claimed binary — `MetricPlate.css:93-96` uses `border-color: ButtonText` on a confirmed non-interactive `.metric-plate`, and `LoginForm.css:363-365` does the same on the plain `.auth-sheet-card`. The value was not wrong; the citation was. Remediated to the accurate mixed-usage framing recorded above, value unchanged. Re-review discharged it.

Two advisory findings, both discharged:

- (LOW, DR-A11Y) The `toggle` tier's persistent pressed cue reuses what `Control.css:61-64` shows is the system's momentary `:active` geometry, so a toggled-on button could read ambiguously as a resting state at a glance. Accepted as residual risk closing via browser-validation journey 1, not a spec change. The related worry that focus visibility depends on the pressed state's removed shadow was checked and dismissed, since `outline`/`outline-offset` (`Control.css:177-180`) are independent of `box-shadow`.
- (LOW, DR-HANDOFF) The reviewer initially could not verify the validation brief because it reached them as a Planner paraphrase; the verbatim text was supplied and all nine journeys were assessed as genuine rendered-outcome checks.

The reviewer independently verified, and the plan may rely on: every named token exists in `field-workbook.generated.css` with the claimed value (critically, `--border-width-thin` = 2px); `--border-width-strong` and `--color-ink-800`-as-border are confirmed prohibited by `tokenDeprecationLint.test.ts` and neither is used here; the A.4-for-background / A.3-for-border split is applied correctly, not conflated; `quiet-outline` (#36) and `nav` (#71) genuinely exist as disclosed sub-tiers; the class-collision split breaks no test found by the bounded search recorded above (a search result, not a proof of absence); and the umbrella plan's "no new visual direction" non-goal is confirmed verbatim at `lizbeth-spanish-fjds-full-app-conformance-closure.md:32`.

**Scope limit on this review record, added during judge remediation:** this PASS covers the design handoff as it stood at review time. The #49 error-state specification and the `toggle`-tier architecture decision below were added afterward, under judge remediation, and were not independently re-reviewed by `design-reviewer`. Each carries its own disclosure of that limit at the point it appears in this document.

**One advisory limit carried forward, not discharged, and load-bearing for Browser UI validation:** journey 4 (the slate focus-ring check) is the journey most likely to be shortcut during implementation into a `getComputedStyle(...).outlineColor` assertion. The Browser Validator must confirm it is executed as an actual pixel-sampled or screenshot check — this is the exact defect class (a locked focus ring silently regressing) that source-only assertions have missed on this project before.

## Judge route

`PLAN_DUCK` is eligible and recommended before user approval, per `docs/JUDGE-CONTRACT.md`, because this is net-new component design rather than the conformance remediation the rest of the program has consisted of — a different risk profile, and a completeness-and-correctness challenge on the three primitive specifications has real value.

A per-item `CODE_REVIEW` checkpoint is optional and should be reserved for work item 3 (#49, the `toggle` tier and toolbar semantics), not spent on the two border-token corrections.

Standing call caps apply per `docs/JUDGE-CONTRACT.md`. Deterministic failures always dominate any judge result. No judge pass is promised by this plan and no model-generated finding is asserted in advance of an actual run.

## Judge route and disposition

`PLAN_DUCK` ran on this plan per `docs/JUDGE-CONTRACT.md`. Verdict: **REVISE, high confidence, three major findings.** Policy action: **advisory (shadow mode), non-blocking** — this run does not gate approval, and this section records a quality-improvement pass, not a hard block. One judge-driven remediation loop was spent against the standing call caps.

Each finding was re-verified directly against the repository before acceptance; the groundings recorded throughout this document are the Planner's own verification, not asserted as the judge's discovery of a defect in the shipped code. These are plan-specification gaps, not code defects.

Deterministic failures always dominate a judge result, and no judge finding altered this plan's three-issue scope. The three findings below were dispositioned as follows, each cross-referenced to the section of this document where the remediation now lives.

| ID | Substance | Disposition |
|---|---|---|
| J-01 | Control tier count and architecture: the plan called the new tier "seventh" when `Control.tsx:25-49` enumerates seven existing tiers, making the new one the eighth; separately, the plan left the toggle tier's implementation as an undecided either/or (shared `Control` tier vs. page-scoped CSS), leaving no conformance boundary for the acceptance gates. | **Accepted in full.** Every "seventh" occurrence corrected to "eighth" (Existing primitive conventions). Architecture resolved to a shared eighth tier with selector-precedence and state-interaction specification, including the binding `:not(:disabled)` guard invariant (Design handoff, #49 toolbar button subsection). Regression coverage for the existing seven consumers added to Item 3's acceptance criteria. Open decision 6 resolved to "shared eighth tier," with only the disclosure-record obligation remaining open. |
| J-02 | Error-state scope gap: issue #49's own follow-up ask names "focus/error states" as in scope, but the plan specified toolbar and read-only states while leaving the error journey unspecified. | **Accepted in full.** Error-state contract specified as a composition of the already-ratified C.2 two-channel pattern (Design handoff, #49 error state subsection, added after the #49 semantics paragraph), with the verified finding that no error call site exists today, a new open decision on whether one should, and an explicit disclosure that this addition was not independently re-reviewed by design-reviewer. |
| J-03 | Accessibility-gate coverage: journeys 1-4 test keyboard, focus, and read-only visuals but never inspect the programmatic accessibility-tree state, and the toolbar's own forced-colors rules had no exercising journey. | **Accepted in full.** Four new journeys added (10-13) covering accessibility-tree exposure, live `aria-pressed` transitions bound to `editor.isActive(...)`, `aria-readonly` exposure paired with the existing visual check, and toolbar forced-colors across four states — see Browser UI validation. Acceptance and validation's Playwright requirement now names journeys 10-13 as part of its mechanism rather than stating accessibility-tree coverage abstractly. |

Two additional items were tightened during this same remediation pass, at the judge's and the remediating agent's instruction, though not counted among the three major findings: the cohort-fixture prerequisite was re-verified against current `main` and split by which journey-half it actually blocks (see Browser UI validation), and the class-collision test-safety claim was restated as bounded search evidence rather than an unqualified conclusion (see #51 — labelled access-control row, and the Design review record).

## Ordered work

**Sequencing decision, with reasons.** Three separate work items, three GitHub issues, dispatched strictly serially to a single writer at a time; never concurrently. Grounds:

1. All three land in the same two files, and concurrent dispatch across files with shared invariants has already caused one cross-item conflict in this program (see the umbrella plan's cascade-collision risk history).
2. They remain three items rather than one merged item because they are independently valuable, independently revertable, and the umbrella plan's issue-logging policy requires one issue per bounded T1 job — merging them would produce exactly the mega-issue that policy forbids.
3. Order is smallest-and-most-contained first, so the two mechanical token corrections merge quickly and the largest item lands on a settled base.

Each item rebases on the prior item's merge before starting.

### Item 0 — Baseline capture (prerequisite, blocking, no production edit)

Owner: T1. Depends on: nothing.

Record the current failing-test set before any edit, rather than assuming a fixed count. The known baseline at planning time is 3 files / 6 tests failing — `FeedbackLedgerRow.test.tsx` x1, `rlsIntegration.test.ts` x1, `roadmapIntegration.test.ts` x4 — all confirmed date-relative seed drift, tracked as issue #139. **The gate is "no new failures beyond the recorded baseline," never a fixed count**, since the baseline is date-relative and may grow.

Confirm the local Supabase stack is running before trusting any RLS-dependent result; an exclusion-based pass is a failed gate.

**Fixture sub-task, added under judge remediation:** attempt to provision a cohort-plus-enrollment fixture for local browser validation (see Browser UI validation's cohort-fixture prerequisite) and record what was provisioned. If provisioning fails, record that as an unmet limit rather than a silent skip; the dependent halves of journeys 7 and 8 are then reported as blocked, not marked passed.

Observable result: a recorded baseline the later gates are measured against, plus a recorded fixture-provisioning outcome.

### Item 1 — #51 labelled access-control row primitive, plus the class-collision split

Owner: T1. Depends on: Item 0.

Smallest and most contained; also removes a live collision hazard before two other items edit the same files.

Steps:

- Extract the entitlement row into a disclosed sibling primitive per the #41 D3 precedent, with a header docblock in the `FeedbackLedgerRow` house style recording why it is a sibling and not a forced fit.
- Correct `border-top` from `1px` to `var(--border-width-thin)`.
- Give the cohort-member `<li>` at `CourseWorkspacePage.tsx:657` its own class and its own minimal rule.
- Add the forced-colors rules for both.
- Do not touch the `<select>`, the revoked-hint, or either Modal.

Acceptance (TDD-first): new/updated tests assert the resolved cascade via `cssCascade.ts` (not source text) for the 2px top rule on the entitlement row and for the member row's separate selector; the three existing roster tests still pass unchanged; a rendered check confirms the two classes are distinct in the live DOM.

### Item 2 — #50 asset-card grid primitive

Owner: T1. Depends on: Item 1 merged.

Mechanically similar container extraction.

Steps:

- Extract the card container into a primitive with a thumbnail/type-icon slot **declined and documented as declined**, a metadata block carrying all three existing `<small>` lines verbatim, and a caller-provided action slot.
- Correct the border from `1px ink.700` to `var(--border-width-thin) solid var(--color-ink-1000)`.
- Apply the specified typography.
- Add the forced-colors rule.
- Drop `.asset-card button` from the shared 44px selector at `CourseWorkspace.css:144` so the action Controls keep C.1's 48px geometry.

Acceptance (TDD-first): resolved-cascade assertions for the corrected border and for the action Controls resolving to 48px rather than 44px; the 3-column/1-column reflow preserved; an inherited asset renders no Remove action while Copy reference remains.

### Item 3 — #49 rich-text editor surface primitive

Owner: T1. Depends on: Item 2 merged.

Largest, most accessibility surface, and the only item that may touch the shared `Control` primitive — so it lands last, on a settled base.

Steps:

- Introduce the `toggle` tier as the shared eighth `Control` tier per the spec, disclosed the way #36/#71 were.
- Correct the toolbar button geometry to 48px/3px and drop `min-width`.
- Add `role="toolbar"`, roving tabindex, and `aria-pressed` bound to `editor.isActive(...)`.
- Add `role="textbox"`, `aria-multiline`, and `aria-readonly` to the body, preserving the existing `aria-label` verbatim.
- Add the single `[aria-readonly="true"]` background declaration without touching the locked focus rule.
- Add the `error?: string` prop and its two-channel error treatment per the #49 error-state subsection, with no call site wired yet (see Open decisions).
- Add the forced-colors block, including the toggle tier's `border-style: double` pressed cue and the disabled/focus-visible forced-colors rules.
- Wire the disabled state to the existing `readOnly` prop via the native `disabled` attribute.

Acceptance (TDD-first): resolved-cascade assertions for the toggle tier's six states; resolved-cascade assertions proving the existing seven `Control` tiers are unchanged at rest, hover, active, focus-visible, and disabled, and that the existing forced-colors block is unaltered; unit and resolved-cascade assertions for the error-state contract (no browser journey, since no call site exists yet); the issue #107 focus test still passes unchanged; **Playwright** journeys 1-4 and 10-13 below for pressed-state persistence, roving-tabindex traversal, read-only rendering, the slate focus ring, accessibility-tree exposure, live `aria-pressed` transitions, `aria-readonly` exposure, and toolbar forced-colors across four states.

## Interfaces and data

No API, schema, migration, or data-model change. No DTCG token source change and no pipeline run — every value the design specifies already exists in the compiled token layer. Changes are confined to `src/pages/CourseWorkspacePage.tsx`, `src/pages/CourseWorkspace.css`, new per-primitive component and stylesheet files following the shipped one-component-one-stylesheet convention, `src/components/ui/Control.tsx` + `Control.css` for the `toggle` tier (resolved as a shared eighth tier, not page-scoped — see the architecture decision in Design handoff), and the corresponding test files.

Public prop shapes for the three new primitives are the design handoff's contract above. Each new component carries a header docblock in the `FeedbackLedgerRow`/`OwnerLedgerRow` house style recording its DS grounding and any disclosed deviation.

## Acceptance and validation

- **The no-new-visual-direction constraint is an explicit acceptance check, not background.** Every visual value in the diff must trace to a ratified token, an A.3/A.4/A.6/B.9/C.1/C.2/C.7 specimen, or a shipped in-repo precedent — or be a labelled assumption already disclosed in this plan. A new colour, radius, shadow, or type role in the diff is a failed gate.
- `npm run lint`, `tsc --noEmit`, and the full vitest suite with **no exclusions**; gate is no new failures beyond Item 0's recorded baseline.
- The existing token-deprecation lint and `tokenFallbackAuditLint` pass; `scripts/verify-token-pipeline.mjs` and `tokenPipelineOracle.test.ts` pass, proving the generated CSS was not hand-edited.
- Anything about rendered geometry, focus behaviour, or accessibility-tree exposure is gated on **Playwright**, asserting rendered outcomes, not computed style alone and not source-text matching. Concretely, this means journeys 1-9 for visual/keyboard/focus/dialog outcomes and journeys 10-13 for accessibility-tree exposure, live `aria-pressed` transitions, `aria-readonly` exposure, and toolbar forced-colors — added under judge remediation so this requirement is discharged by named journeys rather than stated abstractly (see Browser UI validation). jsdom has repeatedly missed real defects in this program — see the umbrella plan's recorded incidents of two blockers shipping past 2,800+ green tests. Resolved-declaration assertions use `src/__tests__/helpers/cssCascade.ts`.
- Forced-colors support is preserved on every new interactive surface; no `forced-color-adjust: none`; no native control replaced by a custom mark.
- The deterministic no-native-dialog source scan passes, plus runtime confirmation on every journey.
- An independent Verifier pass, then a Browser Validator pass. No writer self-approves completion.

## Browser UI dialog policy

Required. No native `alert`, `confirm`, `prompt`, their `window.*` forms, or `beforeunload` in any state of any of the three primitives.

Confirmation uses the existing app-owned accessible `Modal` (`src/components/Modal.tsx`): focus trapped while open, focus returned to the trigger on close, Escape plus an explicit close control, never backdrop-only dismissal, visible 3px slate focus ring at every stop.

#51's Released and Revoked confirmations already use `Modal` with `suppressDismiss={false}` and are therefore Escape-closable — they are not respecified and must not be changed.

Both halves of the gate are required: a deterministic source scan over `src/**` for the prohibited forms, and live runtime confirmation that no native dialog fires on any journey.

## Browser UI validation

- **Launch/readiness:** `npm run dev` in `H:\CommandCenter\orchestrator\lizbeth_spanish`, ready when the login route renders. Base URL `http://localhost:5173`. Reuse an existing healthy dev server; never `taskkill`; scoped-PID termination only if genuinely required.
- **Do not conflate the two Playwright base-URL paths.** `playwright.config.ts` defaults to `http://localhost:8888` via `npm run build && netlify serve` unless `E2E_BASE_URL` is set. Set `E2E_BASE_URL=http://localhost:5173` to run specs against the dev server rather than starting a second production-parity server.
- **Fixture/reset:** a course-authoring fixture with at least one draft lesson carrying rich-text content, one published version (for the read-only journey), at least one inherited and one non-inherited asset, a student with a mix of automatic/held/revoked lesson-access states, and at least one cohort with member-list data. Reset between journeys so a toggled Bold mark or a revoked lesson does not leak into the next. No fabricated fixture data.
- **Known prerequisite gap, re-verified against current `main` during judge remediation:** `supabase/seed.sql` contains zero occurrences of "cohort," confirming the umbrella plan's recorded zero-cohort seed condition (the same gap issue #100 recorded when four `CourseWorkspacePage` modals proved untestable) is still true. **The impact splits by journey half, and the two halves are not equally blocked:** journey 7's entitlement-row half and journey 8 both need a published version with an enrolled student carrying mixed automatic/held/revoked states, which is reachable without a cohort; journey 7's cohort member-list half needs an actual cohort with members, which the seed does not provide. Item 0 must include a bounded fixture sub-task to provision a cohort-plus-enrollment fixture for local validation and record what was provisioned. **Honest fallback, and this is the operative instruction:** if the fixture cannot be provisioned, journey 7's cohort-half and any dependent check are recorded as an unmet limit and reported as a blocker — never marked passed, and never worked around by accepting source-level evidence alone. The umbrella plan's own rule that a browser-validation impediment is reported rather than routed around governs here.
- **Viewports:** desktop >=1024px and the 700px mobile breakpoint wherever a layout collapse is claimed.

### The thirteen journeys and their visible outcomes

Journeys 1-9 are reproduced verbatim from the reviewed design handoff. Journeys 10-13 were added under judge remediation (finding J-03) to close a gap where the existing journeys tested keyboard, focus, and read-only visuals but never inspected programmatic accessibility-tree state, and the toolbar's own forced-colors rules had no exercising journey — the same failure class that has shipped twice in this program, a visually plausible implementation with wrong programmatic state, invisible to jsdom and to cascade-only assertions.

1. Toolbar toggle pressed-state persists after the click completes, not only during `:active`, and returns on a second click, verified per button.
2. Keyboard traversal: one visible ring at a time, ArrowRight advances, wraps last-to-first, and one further Tab moves the ring into the ProseMirror body.
3. Read-only: all three buttons in disabled paint and un-clickable, body visibly on the paper.200 locked ground and distinguishable from the editable paper.100 ground, and Tab skips all three buttons, confirmed by screenshot sequence rather than source inspection.
4. The ProseMirror focus ring renders slate `#3d5f6b`, not terracotta — and per the design review's advisory limit, this must be executed as an actual pixel-sampled or screenshot check, not shortcut into a `getComputedStyle` assertion.
5. Asset-card grid at both breakpoints with a visibly crisp 2px rule rather than a faint 1px hairline, plus an inherited card rendering no Remove while Copy reference remains.
6. Asset library under OS/browser forced-colors remains legible, borders and action-button text included.
7. Entitlement rows show a crisp 2px top rule, and the cohort member row's class is confirmed distinct in the rendered DOM/accessibility tree, not in source text. **The cohort member-list half of this journey is contingent on the fixture prerequisite above** and must be reported as a blocker, not skipped silently, if that fixture cannot be provisioned.
8. Released and Revoked modals render above page content and are not clipped or confined by any ancestor, Escape closes, and focus visibly returns to the triggering control. **Contingent on the fixture prerequisite above.**
9. Live confirmation via browser automation, not grep, that no native dialog is ever produced.
10. **Accessibility-tree exposure, rendered.** Inspect the live accessibility tree (Playwright's accessibility snapshot or ARIA-role locators, not source text and not `getAttribute` on a detached node): the toolbar container exposes `role="toolbar"`; each of the three buttons exposes an accessible name and a pressed state; the ProseMirror body exposes `role="textbox"`, its `aria-multiline` value, and its existing accessible name preserved verbatim.
11. **`aria-pressed` transitions, rendered.** Assert the pressed state transitions in the accessibility tree, not merely that the attribute exists: with the caret in unformatted text all three read unpressed; apply Bold and Bold alone reads pressed while Italic and Bullets stay unpressed; move the caret out of the bold run and Bold returns to unpressed. This is what proves the binding to `editor.isActive(...)` is live rather than a static attribute — a static `aria-pressed="false"` would pass a naive presence check and be wrong.
12. **`aria-readonly`, rendered.** On a published version, the body exposes `aria-readonly` true in the accessibility tree while retaining `role="textbox"` (the role is kept, not removed), and the three toolbar buttons expose a disabled state. Pairs with journey 3's visual check rather than replacing it.
13. **Toolbar forced-colors, rendered, four states.** With OS/browser forced-colors active, screenshot the toolbar in default, pressed, disabled, and focus-visible states and confirm each is visibly distinguishable from the others and legible. Confirms two specific things: that the pressed state is still distinguishable once `box-shadow` is forced to `none` — the design handoff's `border-style: double` is the intended redundant cue and the `transform` survives — and that no state renders as an illegible blob, the exact failure `Control.css:198-203` records from a prior remediation cycle where background and foreground were swapped from their conventional forced-colors roles on a real browser/OS combination.

## Execution record

This plan is closed. It is recorded here honestly: three runtime-only defects, a flaky test, and an untested fix shipped past the writer's own evidence, and were caught by the review chain rather than by the writers. That the chain caught them is the story of this execution, not a footnote to a clean narrative.

### Merged work

| Item | Substance | PR |
|---|---|---|
| Item 0 | Baseline capture and cohort-plus-enrollment fixture provisioning | none — no production edit |
| Item 1 | #51 labelled access-control row, plus the class-collision split | #141 |
| Item 2 | #50 asset-card grid | #142 |
| Item 3 | #49 rich-text editor surface, including the new eighth `Control` tier | #143 |

**Final `main` merge commit:** `5a79578`.

**GitHub issues #49, #50, #51:** all closed 2026-09-08.

### Three runtime-only defects no static check would have caught

None of these were visible in source review, `tsc`, lint, or the jsdom-backed vitest suite. Each required driving the surface in a real browser, or an independent second reader, to find.

1. **Tiptap v3's `useEditor` does not rerender on transaction by default.** Without an explicit opt-in, the toolbar's `aria-pressed` state would have shipped permanently `false` regardless of the actual formatting under the caret — code that looks correct in any static diff or DOM snapshot, and is wrong the moment a user actually clicks Bold. Found only by driving the toolbar in a real browser and watching the pressed state fail to update. Fixed with `shouldRerenderOnTransaction: true`.
2. **`editable: !readOnly` was read once at mount and never re-applied.** Toggling the `readOnly` prop on an already-mounted editor changed the ARIA-facing `aria-readonly` attribute without changing the editor's actual editability underneath it — an accessibility-tree lie about the real interactive state. This was not caught by the test suite; it was found by the `gpt-6-astra` `CODE_REVIEW` checkpoint on Item 3.
3. **The toolbar's `onMouseDown` stole ProseMirror's selection before the formatting command ran.** Clicking a toolbar button collapsed or moved the editor's text selection before the Bold/Italic/Bullet command executed against it, so the command applied to the wrong range or no range. Fixed with the standard Tiptap pattern, `event.preventDefault()` in the mousedown handler, which keeps the selection intact until the click's own command runs.

### Judge and review record

`PLAN_DUCK` (`gpt-5.6-terra`, medium effort, shadow mode) returned **REVISE** with three major findings before approval: J-01, a `Control` tier miscount (calling the new tier "seventh" instead of "eighth") compounded by an undecided shared-versus-page-scoped architecture question; J-02, an editor error state that issue #49's own text named as in scope but that the draft plan left unspecified; and J-03, accessibility gates (journeys 1-4) that exercised keyboard, focus, and read-only visuals but never inspected the actual programmatic accessibility-tree state, leaving the toolbar's forced-colors rules with no exercising journey at all. All three were remediated before user approval; see the plan's own "Judge route and disposition" table above for the accepted disposition of each.

`CODE_REVIEW` on Item 3 (`gpt-6-astra`, medium effort, shadow mode) returned **REVISE** with three major and two minor findings during execution. All five were accepted; none was rebutted. The majors included cascade tests that under-tested what they claimed to test: a test named "rest, hover, pressed, and disabled" never actually applied a `:hover` pseudo-class, and the disabled-and-pressed combination asserted only `background-color`, never the `transform`/`box-shadow` pair that the pressed rule is specifically supposed to change. The `editable: !readOnly` staleness defect above (defect 2) was also a `CODE_REVIEW` finding, not a self-discovered one.

### What independent verification caught that the writer's own evidence missed

- **Item 1's Playwright spec shipped with a flaky rate of roughly 35-40% (failed 5 of 8 runs on independent re-verification), invisible in the writer's own 2 runs.** The cause was a name-filtered Playwright locator that, on failure to match, silently fell through to an unscoped `.first()` call — a fallback that intermittently resolved to the Cohorts section's own toggle control rather than the intended access-control row. This was not a timing flake to be waited out; the fallback itself was structurally wrong and was removed rather than patched with a longer timeout.
- **Item 3's `setEditable` fix shipped with no regression test**, reproducing the same separate-mounts blind spot that let the original defect through in the first place — a test that mounts a fresh editor per state change cannot exercise a bug that only appears when the same mounted instance changes state. A single-mounted-instance React Testing Library test was added and RED-proven: it was confirmed to fail against the unfixed code (asserting on `contenteditable`) while the pre-existing `aria-readonly` assertion continued to pass, demonstrating the new test catches a defect class the existing suite did not.

### Corrections made rather than ported verbatim

- **`toggle` is the Control component's eighth tier, not its seventh.** `Control.css`'s own header comment claiming "five tiers" was itself stale and unrelated to the current seven-then-eight count; both the plan's "seventh" references and the CSS header comment were corrected.
- **Items 1 and 2 each corrected a literal `1px` border to `rule.thin`.** A.3 defines exactly four named border weights and none of them is 1px, so the interim `1px` values inherited from issue #44's foundation-only treatment were defects to fix, not ratified deviations to preserve.
- **Item 1 resolved a latent `.roster-lesson-row` class-name collision** serving two unrelated shapes (the lesson entitlement row and an unrelated cohort member-list `<li>`), splitting them into distinct classes per the plan's #41 D3 precedent.
- **Issue #49's own body describes a terracotta focus ring; current `main` is slate `#3d5f6b` per issue #107.** The stale terracotta description was not reintroduced during implementation.

### Deliberate declines, recorded so they are not mistaken for omissions

- **#50's decorative thumbnail/type-icon slot was declined**, not built. No file-type iconography exists anywhere in the ratified Field Journal DS vocabulary or in the current markup; inventing one would have been a new visual direction, which the umbrella plan's non-goals forbid.
- **#49's error contract has no call site, by design.** The `error?: string` prop and its two-channel treatment ship on the primitive, gated by unit and resolved-cascade tests, without any page wiring a real error into it — there was no reachable rendered error journey to invent, so none was.

### Disclosed limits

- **The live `readOnly` toggle could not be exercised end-to-end in a real browser.** `Editor` is keyed by a version id, so the only path that actually changes `readOnly` on a mounted instance also remounts the component under that key, which means the specific "same instance, prop changes" scenario the `setEditable` fix targets was verified only at the unit level, not via a Playwright journey.
- **The J-02 error contract was composed under judge remediation and was never independently re-reviewed by `design-reviewer`.** The design PASS on record covers the handoff as it stood before that addition; this gap was disclosed in the plan before approval and remains disclosed here at closure.
- **Journey 13's forced-colors pixel-variance assertions are a real but weak signal.** They rule out a uniform-blob rendering failure, not a wrong-but-non-uniform one — a toolbar that rendered with two states swapped, for instance, would still show pixel variance and could pass the assertion. Direct visual inspection during browser validation supplemented the automated check rather than replacing it.

### Environment and fixture notes

- **Item 0 provisioned the cohort fixture through the app's own edge-function API rather than by editing `seed.sql`.** This also unblocked a journey the plan had recorded as unreachable given the zero-cohort seed condition. An early provisioning attempt created a second enrollment for `student1`, which broke three cross-student isolation assertions elsewhere in the suite; the cause was traced and the fixture was repaired by re-provisioning against a fresh user with no seeded enrollment instead.
- **The failing-test baseline moved from 6 to 8 during execution.** The original 6 were pre-existing date-drift failures tracked as issue #139. The additional 2 were fixed-count assertions that any fixture provisioning necessarily moves once new rows exist. This is recorded plainly as a structural property of the current test suite: count-based assertions of this kind are hostile to the fixture provisioning that real browser validation in this program requires, and future fixture work should expect the same friction.
- **The Codex judge adapter was non-functional at the start of this plan.** Two checkpoint attempts returned `ABSTAIN`/`unassessed` on `helper_unknown_error: apply deny-read ACLs`, root-caused to `windows.sandbox="elevated"` requiring OS elevation the session lacked. Fixed by switching the adapter to `windows.sandbox="unelevated"`, verified 3/3 clean including against a large read surface. The adapter was subsequently extended to allow the `gpt-5.6-sol` and `gpt-6-astra` models and `high` effort, beyond what was available when this plan was first drafted.
- **Issue #140 was filed during execution, not anticipated by planning.** `getCourse()` prefers a draft version over a published one, so a course owner cannot reach the Students roster for any course that has a newer, non-published version — and at the time this was found, every content-bearing course in the environment was in that state. This is a defect in existing behavior surfaced by this plan's work, filed separately rather than folded into #49/#50/#51's scope.

## Risks and rollback

Overall risk: **medium.**

1. **This is net-new component design, not conformance remediation** — a materially different risk profile from everything else in this program. Mitigation: the standard design route with an independent review gate ran before this plan, and no-new-visual-direction is an explicit acceptance check.
2. **The shared file surface causes a cross-item conflict.** Mitigation: strict serial dispatch, one writer at a time, each item rebasing on the prior merge.
3. **A new class-name collision, or a botched split of the existing one.** Mitigation: the reviewer's line-by-line confirmation that the three roster tests query only lesson titles, plus browser journey 7 asserting distinctness in the rendered DOM.
4. **jsdom green-but-broken.** Mitigation: Playwright gating on all rendered geometry, focus, and accessibility-tree claims; `cssCascade.ts` for resolved declarations.
5. **Forced-colors regression on a new interactive primitive.** Mitigation: explicit forced-colors rules for every new surface, no `forced-color-adjust: none`, no native control replaced; journey 6 validates rendered legibility.
6. **The `toggle` tier's persistent pressed state reads as a resting state.** Carried from the design review as accepted residual risk; closes via journey 1.
7. **An accessibility claim grounded in an authority that does not say it.** Mitigation: the three open evidence gaps are recorded rather than closed by inference, and the APG/WCAG normative-versus-non-normative framing is binding on any comment or docblock the implementation writes.
8. **The cohort fixture is absent**, blocking journey 7's cohort member-list half and journey 8, re-verified against current `main` (`supabase/seed.sql` has zero cohort occurrences) during judge remediation. Journey 7's entitlement-row half does not depend on a cohort and is not blocked by this. Mitigation: a bounded fixture sub-task in Item 0 attempts provisioning; a genuine absence is reported as a blocker for the dependent halves specifically, never worked around by source-level evidence alone.
9. **Plan staleness.** A material repository, requirement, or evidence change requires `JOB_BLOCKED: Plan stale` and replanning or explicit reapproval, not silent reconciliation.

**Rollback:** every item is an independently revertable component/CSS/test change. No schema, data, migration, or irreversible state is involved. The token pipeline oracle makes any accidental generated-CSS edit immediately detectable.

## Assumptions and decisions

**Safe assumptions.** The dev server runs at `http://localhost:5173` via `npm run dev`. Playwright is available and working, evidenced by 16 existing spec files and a prior screenshot corpus.

**Stated evidence limit.** `gh` was not on the read-only planning tool surface, so no live GitHub state was read. The open status, labels, and absence of comments on #49/#50/#51 are as supplied to planning, not independently verified. Where a live read contradicts this plan, the live read wins.

**Research evidence gaps remain open and are not resolved by this plan** (see Research evidence above).

### Open decisions

Each of the following must be resolved before the specific work item that depends on it. None blocks approval of this plan.

1. New accessible-name copy for the #49 toolbar — no existing string covers it, needs product sign-off (blocks Item 3).
2. Whether the read-only #49 body should carry placeholder copy — declining is the safe default requiring no new string, but it is a product call (Item 3).
3. Whether product wants a decorative thumbnail/type-icon slot on the #50 card at all — this plan declines to design one, and authorizing it would require its own icon-authoring pass plus a short follow-up UX pass (Item 2).
4. Whether to add a loading sentinel to the #50 asset grid, mirroring `StudentRoster`'s `students === null` pattern — a scope decision beyond what #50 asked for (Item 2).
5. The literal class-name string for the cohort-member row — the verdict that it must not reuse `.roster-lesson-row` is final, only the string is open (Item 1).
6. **Resolved during judge remediation: the `toggle` tier is a shared eighth `Control` tier, not page-scoped CSS.** What remains open under this item is only the disclosure obligation — the literal new tier must get its own disclosure record the way #36 (`quiet-outline`) and #71 (`nav`) did (Item 3).
7. Two engineering checks that must be performed rather than assumed: whether the ProseMirror root stays keyboard-focusable once `contenteditable` is off, and whether #51's native `<select>` meets WCAG 2.5.8's 24x24 CSS px minimum at shipped default styling (Items 3 and 1 respectively).
8. **Added under judge remediation:** whether a call site for the #49 editor's new `error` prop should exist — specifically whether the page-level save failure at `CourseWorkspacePage.tsx:70` should surface at the editor instead of, or in addition to, page level. Genuinely open; does not block Item 3, since the primitive ships the contract regardless of whether a caller uses it yet.

### Commit authority

The umbrella plan records a standing user authorization covering commit, push, PR, and merge to `main` in the `lizbeth-spanish` repository only, excluding deploys, force-pushes, history rewrites, and branch deletion — see that plan's Approval gate for the verbatim quotes. Per `handoff.md`, any job packet relying on that authorization quotes the user's own words directly rather than an orchestrator-relayed summary.

## Engineering mode

Standard.

## Team authorization

Not applicable.

## Downstream owner

engineering-fleet — T1 first-line, escalating to T2 on two counted gate failures per item, with verifier and browser-validator as independent gates. No writer may self-approve completion.

## Approval gate

**This plan requires explicit user approval before any downstream execution.** No standing forward authorization is invoked or claimed by this document for the work described here. No T1, browser-validator, design-reviewer, or issue-creation dispatch under this plan may occur before that approval is recorded.

Upon approval, update this file's status header from DRAFT to APPROVED, with the approval record (approver, basis, date) filled in at that time, before dispatching Item 0.
