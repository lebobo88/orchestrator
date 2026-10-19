# Lizbeth Spanish, App.css Cascade Collision, Remediation Cycle 4

**Status: Proposed — awaiting explicit user approval.**

This plan does not carry standing forward authorization. Unlike the #31-#44 Field Journal DS milestone plans, this task is not one of the GitHub issues that standing authorization named — it is newly discovered defect remediation, surfaced by direct repository inspection rather than by a milestone issue. The coordinator (orchestrator) directed this plan's creation and its two-phase scope (Option A, the cascade fix, sequenced before Option B, the GitHub bookkeeping reconciliation). No user statement approving this specific plan has been relayed to Scribe. Explicit user approval is required before any engineering writer (T1/T2) begins work on it.

---

Plan ID: `lizbeth-spanish-appcss-cascade-collision-cycle4`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: `engineering-fleet`
Design route: compact (`design-generalist`, `design-reviewer`; prototype forbidden; model tier Sonnet; existing-system mode: preserve)

## Outcome and audience

Correct the seventh confirmed instance of a recurring `App.css` cascade-collision defect class in this codebase. The immediate user-facing effect: GitHub issue #42's already-design-reviewed roster/detail surface treatment for `AdminStudentsPage` (rule-width border + `--shadow-sheet`) currently loses a same-specificity cascade tie to a legacy `App.css` rule and does not actually render in a real browser, despite having passed issue #42's own browser validation. This plan also removes two unopposed legacy page-wrapper treatments that have no design justification, and one fully dead selector, then reconciles stale GitHub bookkeeping on issues #41, #42, and #66.

Audience: the T1/T2 engineer implementing this plan; the owner/admin users of `AdminStudentsPage`, `OwnerSettingsPage`, and `BusinessSettingsPage`, whose surface treatments this plan corrects.

## Scope

**In scope:**

- `src/App.css` selector-list edits at line 706, lines 790-795, and lines 796-801.
- `src/pages/OwnerSettingsPage.css` comment correction at lines 143-158, plus one optional zero-visual-effect hardening declaration (explicit `border-radius: var(--radius-square);` on `.owner-settings-page.owner-settings-page--brand`).
- A new CASCADE-COLLISION REGRESSION GUARD added to `src/__tests__/fjdsAuthenticatedScreensRemediation.test.ts`, following that file's existing cycle-2/cycle-3 convention.
- Phase 2: re-validation of GitHub issue #42's roster/detail surface treatment now that the collision is fixed.
- Phase 3 (Option B, bookkeeping, sequenced after Phase 1 and Phase 2): update GitHub issue #66 with corrected findings; reconcile the unchecked acceptance/verification checkboxes on GitHub issues #41 and #42 against landed evidence, via `gh`.

**Non-goals (binding — a writer must return `JOB_BLOCKED` rather than exceed these):**

- No markup, component, React logic, or design-token-file change anywhere in this task.
- No redesign of issue #42's already-reviewed roster/detail treatment. This plan restores its rendering; it does not change its values.
- `.owner-settings-form` is confirmed dead (no `className="owner-settings-form"` found in `src`) but is explicitly OUT of scope and must be left untouched at `App.css:793`.
- The roughly 21 other `--shadow-print` consumers project-wide remain untouched, consistent with the scope boundary already established on issue #42's own plan.
- Out-of-scope selectors whose rendered appearance must not change under any circumstance: `.login-form-container`, `.demo-section`, `.admin-shell`, `.resources-panel`, `.register-student-modal`, `.owner-settings-page.owner-settings-page--brand` (this last one must not change in rendered appearance, though its CSS source and an adjoining comment do change — see D2/D4 below).

## Repository findings

Grounded entirely in direct static source reads relayed by the coordinator (orchestrator) as this task's dispatching context. No nested Researcher pass was run for this plan; the coordinator's own repository reads are the evidentiary basis. No planning-stage agent executed the test suite or rendered a page — see "Research evidence and its limits" below.

**A critical premise correction must be recorded prominently, exactly as the coordinator relayed it.** This plan was originally dispatched on the premise that GitHub issues #41 and #42 were deferred and never planned or executed. That premise is FALSE and was disproven by direct repository read. Both plans exist and were approved on 2026-09-01: `docs/plans/lizbeth-spanish-issue41-feedback-screen.md` and `docs/plans/lizbeth-spanish-issue42-owner-dashboard-roster-screen.md` (the latter carrying a "Post-approval correction (2026-09-02)" section). Both were implemented, with two remediation cycles already consumed: `AdminStudentsPage.css:221` is annotated "Issue #42, remediation cycle 2 (Browser Validator, BROWSER_NEEDS_FIX...)" and `MetricPlate.css:60` records "Issue #42 remediation cycle 1 (Codex CODE_REVIEW...)". Shipped artifacts include `src/components/MetricPlate.tsx`, `src/components/FeedbackLedgerRow.tsx`, `src/__tests__/AdminStudentsPage-issue42-screenComposition.test.tsx`, `src/__tests__/AdminShell-issue42-navTabTreatment.test.tsx`, all carrying #41/#42 decision IDs D1-D17. The unchecked GitHub acceptance checkboxes on #41/#42 are a BOOKKEEPING GAP, not evidence of unimplemented work. `ADOPTION-PLAN.md:230-231` confirms adoption item 11 = #41 Feedback, item 12 = #42 Owner dashboard + Roster.

### Defect A: equal-specificity cascade collision (the one with real rendered user impact)

`src/App.css:796-801` declares `border: var(--border-width-strong) solid var(--color-ink-800); box-shadow: var(--shadow-print);` for a selector list including `.admin-students-roster` and `.admin-students-detail`. Both selectors are live: `AdminStudentsPage.tsx:415` and `AdminStudentsPage.tsx:587`. `AdminStudentsPage.css:434-438` separately declares `border: var(--border-width-rule) solid var(--color-ink-1000); box-shadow: var(--shadow-sheet);` for the same two selectors — this is issue #42's reviewed D2/D10 shadow-zone reassignment.

Both declarations are single-class selectors at identical specificity (0,1,0). Cascade order therefore decides the outcome, and `App.css` is injected later in the module graph, so `App.css` wins in a real browser and issue #42's reviewed treatment does not render, despite existing correctly in source.

Cascade order was verified directly by tracing the actual import chain, not inferred by analogy to prior instances: `App.tsx` imports `AdminShell` (line 19) before `'./App.css'` (line 40); `AdminShell.tsx` imports `AdminStudentsPage` (line 6) before `'./AdminShell.css'` (line 13); `AdminStudentsPage.tsx` imports `'./AdminStudentsPage.css'` at line 33; no `React.lazy` or other dynamic import exists anywhere in app code that would split this into a separate chunk and change load order. `AdminStudentsPage.css` has no other border/box-shadow rule for these two selectors outside lines 434-438 — the `forced-colors` `box-shadow: none` override at lines 484-494 is unrelated and does not compete.

### Defect B: unopposed legacy rule (a different mechanism — no competing rule exists at all)

`src/App.css:706` applies `border` + `--shadow-print` to a selector list including `.admin-students-page` and `.owner-settings-page`. Unlike Defect A, this is not a cascade tie; it is an orphaned legacy rule with nothing else in the cascade contesting it, so it always wins by default.

`.admin-students-page` is live (`AdminStudentsPage.tsx:175,184,191`). `AdminStudentsPage.css:1-3` sets only `padding: 2rem` on it, and `AdminStudentsPage.css:426` sets only padding/font-size/line-height — nothing else in the codebase declares a competing border or shadow for this selector.

`.owner-settings-page` is live (`OwnerSettingsPage.tsx:115,176`; `BusinessSettingsPage.tsx:23,24,38`; `BrandDesignPage.tsx:40,41,44`). `OwnerSettingsPage.css:9-12` sets only `max-width`/`margin` on the base selector — again, nothing competes.

**Important nuance, not a defect in itself.** `OwnerSettingsPage.css:159-166` separately declares `.owner-settings-page.owner-settings-page--brand` with `border` + `--shadow-sheet` at specificity (0,2,0). This compound selector already outranks `App.css:706`'s single-class (0,1,0) rule today, so `BrandDesignPage` is currently rendering correctly and must not regress from this plan's changes.

### Defect C: dead selector (corrects a wrong claim in GitHub issue #66)

`.feedback-form` appears in all three `App.css` selector lists at line 706, lines 790-795, and lines 796-801, but it is DEAD: no `className="feedback-form"` exists anywhere in `src`. `FeedbackForm.tsx:156` renders `.feedback-form-container`, and every other usage in that file is a distinct compound class (`.feedback-form-row`, `-group`, `-submit`, and similar). GitHub issue #66 currently claims `.feedback-form` is a live collision; that claim is factually wrong and must be corrected in Phase 3.

### Prior instances of this defect class

This is the SEVENTH instance. All six prior instances are already fixed and documented in `App.css`'s own inline comment trail at lines 694-705 and 764-789: `.band-roadmap`, `.lesson-content-chunk` (twice), `.week-card`, `.lesson-content-view`, `.flashcards-viewer`.

### Radius (no conflict, no action needed)

`--radius-square` resolves to zero per the design source's §A.3 policy, so the radius-only selector list at `App.css:790-795` is NOT itself a conflict and is left as-is. Leaving `.admin-students-roster`, `.admin-students-detail`, and `.feedback-form` in that radius-only list would be inert (zero-radius either way), matching the precedent already documented at `App.css:777-789` — but Defect C's `.feedback-form` removal still applies there too, since it is dead regardless of which list it sits in.

## Research evidence and its limits

No nested Researcher pass was dispatched for this plan; findings above are the coordinator's own direct static source reads, relayed into planning context.

**Material limit, recorded prominently, exactly as directed.** No planning-stage agent could execute the test suite or render a page. `.claude/hooks/validate-researcher-bash.ps1` blocks `npm test`, `npx vitest`, and `git -C`. Every current-behavior claim in this plan — including the cascade-order trace above — is source-level and static, never runtime-verified by a browser. This is precisely the failure mode that let this defect ship through issue #42's own prior browser validation: a source-level correctness check cannot see which same-specificity rule a real browser cascade actually renders. Step 0 below requires a baseline capture and a fresh grep sweep before any edit; a genuine browser render only happens at the Browser Validator step (Step 9), after the fix is applied.

**A second limit.** The live current text of GitHub issues #41, #42, and #66 was not fetched during planning, because Planner has no `gh` access. This plan uses `ADOPTION-PLAN.md` as the specification of record for what #41/#42 covered. Phase 3 (Steps 10-11) must begin by fetching the live issue bodies via `gh` and reporting any divergence from what this plan assumes, before editing them.

## Design route and handoff

```
DESIGN_ROUTE
profile: compact
reasons: bounded brownfield CSS-only fix with exactly one genuinely open surface-treatment decision (D2, the two orphaned page-wrapper selectors); no new component, no new token, no markup change; two design-generalist plus one independent design-reviewer cycle is proportionate.
agents_required: design-generalist, design-reviewer
prototype: forbidden
model_tier: sonnet
existing_system_mode: preserve
END_DESIGN_ROUTE
```

The full passed `DESIGN_HANDOFF` is reproduced below in substance, including the revision that closed the first review cycle's finding.

### D1 (Defect A fix)

Remove `.admin-students-roster` and `.admin-students-detail` from `App.css:796-801`'s selector list. `AdminStudentsPage.css:434-438` becomes the sole surviving declaration for both selectors — issue #42's D2/D10-reviewed value (rule-width border + `--shadow-sheet`).

### D2 (Defect B fix — the one fresh design decision, resolved as a plain wrapper)

Remove `.admin-students-page` and `.owner-settings-page` from `App.css:706`'s selector list, with NO replacement declaration. Rationale:

1. `AdminStudentsPage`'s D.7 Roster reference screen specifies bordered zones at the roster/detail level only; no wrapper-level border/shadow treatment is documented anywhere in that reviewed work.
2. `OwnerSettingsPage`/`BusinessSettingsPage` have no reference screen at all, and per `ADOPTION-PLAN.md:144-146` must be "composed strictly from A + B + C primitives." The C.2 field primitive already supplies rule geometry on every input (`OwnerSettingsPage.css:37-41`, matching `ADOPTION-PLAN.md:124`'s "3px rule"), so nothing in the A+B+C primitive set calls for an additional full-page sheet wrapper around a settings form.
3. `OwnerDashboardPage`'s `.owner-dashboard` DOES carry a border plus `--shadow-sheet` nested outside `.dashboard-panel`'s own inner zones (`OwnerDashboardPage.css:1-10`), but that is a documented, purpose-specific, reviewed exception — explicitly commented as "Issue #42 (D7)... intentional nested shadow layering," paired with a `.paper-stock--graph` console-framing purpose and outer/inner shadow-token differentiation (see the issue #42 plan's "Tokens" subsection). No equivalent purpose-specific rationale exists for the two wrappers in this task; their treatment arrived only as an unopposed side effect of a legacy selector list originally built for `.login-form-container`/`.demo-section`. A nested border-in-border IS a defect here, in contrast to the `OwnerDashboardPage` pattern, which is not a defect; the distinguishing test is the presence of a documented, purpose-specific design decision, which `.owner-dashboard` has and these two wrappers do not.

Wrapper padding is retained exactly as-is; only the border and box-shadow declarations are removed for these two selectors.

### D3 (out of scope, explicitly unchanged)

`.admin-shell` (already neutralized at `App.css:710` with `border:0; box-shadow:none`), `.login-form-container`, `.demo-section`, `.resources-panel`, `.register-student-modal`.

### D4 (radius policy)

`--radius-square` is zero per the design source's §A.3, so the radius-only list at `App.css:790-795` is not itself a conflict and stays as-is except for Defect C's `.feedback-form` removal (a no-op there since radius is zero either way). Leaving `.admin-students-roster`/`.admin-students-detail` in that list is inert and matches the precedent already documented at `App.css:777-789`.

### Defect C fix

Remove `.feedback-form` from all three `App.css` selector lists (line 706, lines 790-795, lines 796-801). A pure no-op on rendered output, since the selector is dead.

### Engineering invariants (all must be preserved verbatim by the implementing engineer)

- Zero border-radius on every affected selector, always (§A.3).
- `.admin-students-roster` and `.admin-students-detail` must render `--border-width-rule` + `--shadow-sheet` after the fix, with no competing rule remaining anywhere in the cascade.
- `.roster-item` and `.roster-item--disabled` overrides remain untouched.
- `.admin-students-page` and the base `.owner-settings-page` must end with NO border and NO box-shadow anywhere in the cascade.
- `.owner-settings-page.owner-settings-page--brand` must retain zero border-radius, sourced either from the browser's `0` initial value or from the new explicit declaration if the optional hardening line is added — never from `App.css:706`, which no longer supplies it after this fix.
- `.feedback-form` must not reappear in any of the three `App.css` lists.
- No design-token definitions change anywhere in this task.

**Mandatory comment correction.** `OwnerSettingsPage.css:143-158` currently asserts that "border-radius is deliberately not re-declared: App.css:706 already supplies var(--radius-square) (0px)." That assertion becomes FALSE once `.owner-settings-page` leaves `App.css:706`. The comment must be corrected in the same change to state that zero radius now comes from the browser's default initial value (or from the new explicit declaration, if the optional hardening line is added) and NOT from `App.css:706`. This correction is required regardless of whether the optional hardening declaration is added. Rationale, stated plainly: this repository's inline comment trail exists specifically to stop load-bearing rationale from going stale; leaving it uncorrected risks a future engineer concluding radius is unsupplied and re-adding `.owner-settings-page` to `App.css:706`, recreating this exact collision as an eighth instance.

Also required: add a new guard to `src/__tests__/fjdsAuthenticatedScreensRemediation.test.ts` following that file's existing "CASCADE-COLLISION REGRESSION GUARD" cycle-2/cycle-3 convention. The engineer must reconcile this task's "cycle4" identifier against the test file's own internal cycle numbering rather than assuming the two numbering schemes already match — confirm by reading the file's existing guard comments before naming the new one.

Preserve `App.css`'s existing inline-comment documentation convention (lines 684-705, 764-789) for the new fix, without fabricating a plan filename that does not exist. This plan's real, only correct path is `docs/plans/lizbeth-spanish-appcss-cascade-collision-cycle4.md`; the new App.css comment must cite that exact path if it cites a plan file at all.

### Permitted variation

- Exact comment wording and placement in `App.css`.
- Whether to add `border-radius: var(--radius-square);` explicitly to the `--brand` rule (recommended) and optionally to the two wrappers — both are zero-visual-effect either way, but the `OwnerSettingsPage.css:143-158` comment correction is required regardless of which option is taken, and must be worded to match whichever option was actually taken.
- Order of selector removal across the three `App.css` lists.
- Exact test-file cycle naming, once reconciled against the file's own internal numbering.

## Design review

PASS, on the second review cycle. The first cycle returned `NEEDS_REVISION` with one blocking finding at MEDIUM severity and one non-blocking LOW finding; both were closed in one bounded revision.

**Finding 1 (MEDIUM, closed).** The first handoff left the `OwnerSettingsPage.css:143-158` comment's stale assertion unaddressed — it would have gone false the moment `.owner-settings-page` left `App.css:706`, without any correction instruction. Closed: the revised handoff now requires the comment correction as mandatory, worded to be independent of which optional-hardening choice the engineer makes, with the recreated-collision risk stated as the rationale.

**Finding 2 (LOW, non-blocking, closed).** The first handoff's browser-validation brief did not explicitly instruct driving keyboard Tab order, only render/hover states. Closed: the browser-validation brief below now requires explicit keyboard Tab-order verification at each interactive element in every journey, confirming the focus ring at each stop.

The reviewer independently re-verified findings 1, 3, 4, 5, and 6 above (Defect A's cascade-tie claim, Defect B's unopposed-rule claim, the `--brand` selector's already-winning specificity, the dead-selector claim for `.feedback-form`, and the `.owner-dashboard` counter-example distinction) by direct read, notably tracing the actual module-import order end-to-end (`App.tsx` -> `AdminShell.tsx` -> `AdminStudentsPage.tsx`) rather than relying on precedent-by-analogy to the six prior instances of this defect class. The reviewer judged the handoff's disclosed limits — no live browser render occurred at either planning stage, jsdom-based tests cannot see cascade order — as accurately stated rather than understated.

**Remaining limits carried forward to browser validation**, none blocking: no page was rendered by any planning-stage agent; the actual rendered cascade outcome for the three defects is confirmed only at Step 9 (Browser Validator), not before.

## Judge route

`PLAN_DUCK` eligible at the orchestrator's discretion before approval. Given the bounded, CSS-only, purely subtractive nature of Phase 1, a Codex checkpoint is not strongly indicated on complexity grounds alone. However, `CODE_REVIEW` is worth considering, because this defect class has now recurred seven times and a Codex `CODE_REVIEW` checkpoint is exactly what caught the last scope violation on issue #42 (the `.metric-plate--dark` shadow correction, recorded in that plan's "Post-approval correction" section). Deterministic checks plus the independent Verifier and Browser Validator passes remain mandatory regardless of the judge-route decision. Standard call caps and shadow policy from `docs/JUDGE-CONTRACT.md` apply; deterministic failures always dominate the judge.

## Ordered work

Owner: T1 engineer, standard mode; escalate to T2 on two counted gate failures. TDD-first throughout — write the failing regression guard before the corresponding production edit.

0. **Mandatory baseline, before any edit.** Capture the real baseline: full `npm test` results and `tsc`. No planning-stage agent could execute the test suite or render a page, so every current-behavior claim in this plan is source-level and static, never runtime-verified. Return `JOB_BLOCKED: Plan stale` if the observed baseline diverges materially from this plan's static findings. Also re-grep to confirm no third stylesheet declares a competing border/shadow rule for `.admin-students-page` or the base `.owner-settings-page` that this plan's static read might have missed.
1. Apply D1: remove `.admin-students-roster` and `.admin-students-detail` from `App.css:796-801`.
2. Apply D2: remove `.admin-students-page` and `.owner-settings-page` from `App.css:706`.
3. Apply Defect C: remove `.feedback-form` from `App.css:706`, `App.css:790-795`, and `App.css:796-801`.
4. Correct the `OwnerSettingsPage.css:143-158` comment; optionally add the explicit `--brand` radius declaration, wording the comment to match whichever choice is made.
5. Add the `App.css` inline comment documenting Defects A, B, and C, following the file's existing documentation convention at lines 684-705 and 764-789.
6. Add the new CASCADE-COLLISION REGRESSION GUARD to `src/__tests__/fjdsAuthenticatedScreensRemediation.test.ts`, reconciling this task's cycle identifier against the file's own internal cycle numbering.
7. Run deterministic checks: `tsc`, `npm test`, `mcp__atelier__tokens_validate`, `design_review`, `contrast_check`, `a11y_audit`.
8. Independent Verifier pass (read-only).
9. Browser Validator pass against the "Browser UI validation" brief below. This is the re-validation of issue #42 that this plan requires, because #42's original browser validation passed over a defect that hid its own changes from the rendered page.
10. **Phase 3 (Option B, bookkeeping), sequenced after Steps 1-9 because Phase 1's actual result determines what this step should say.** Fetch the live GitHub issue #66 body via `gh`, report any divergence from this plan's assumptions, then update issue #66 with corrected findings: `.feedback-form` is DEAD, not a live collision as #66 currently claims; `.admin-students-roster`/`.admin-students-detail` were genuine live cascade collisions, now fixed; `.admin-students-page`/`.owner-settings-page` were two previously untracked unopposed-legacy defects, now fixed.
11. Fetch the live GitHub issue #41 and #42 bodies via `gh`, report any divergence from this plan's assumptions, then reconcile both issues: tick the acceptance and verification checkboxes against landed evidence (`tsc`, tests, `tokens_validate`, `design_review`, `contrast_check`, `a11y_audit`, screenshot/`visual_diff`, Codex judge findings if run), citing this plan's Step 7-9 results for issue #42's re-validated items specifically, and close the issues via `gh` if the evidence supports it. This follows the standing directive to log all work through GitHub issues.

## Interfaces and data

None. No API, data-model, migration, or compatibility surface is touched. This task edits CSS and one test file only.

## Acceptance and validation

Deterministic gates, all must pass: `tsc` clean; `npm test` green, including the new regression guard; `mcp__atelier__tokens_validate`; `design_review`; `contrast_check`; `a11y_audit`; independent Verifier pass; Browser Validator pass at both defined viewports.

The design source's §A.6 fixed criteria must remain preserved throughout: no state conveyed by color alone; text contrast at least 4.5:1; hit targets at least 44px; a 3px `ink.slate` focus ring at 2px offset, drawn outside the shadow; decorative elements inert or `aria-hidden`; zero border-radius; no raw hex value outside the token layer; `prefers-reduced-motion` collapses animation.

## Binding engineering invariants

The following must all hold in the delivered code, verbatim, without exception, carried directly from the design handoff:

- `.admin-students-roster` and `.admin-students-detail` render `--border-width-rule` + `--shadow-sheet` after the fix, with no other rule in the cascade contesting it.
- `.admin-students-page` and the base `.owner-settings-page` carry NO border and NO box-shadow anywhere in the cascade after the fix.
- `.owner-settings-page.owner-settings-page--brand` renders pixel-identical to before this change — its own `border`/`--shadow-sheet` declaration at `OwnerSettingsPage.css:159-166` is untouched and already outranks `App.css:706`.
- `.owner-settings-form` at `App.css:793` is left completely untouched; it is confirmed dead but explicitly out of scope.
- `.feedback-form` does not reappear in any of the three `App.css` selector lists.
- The `OwnerSettingsPage.css:143-158` comment is corrected to no longer attribute zero radius to `App.css:706`.
- No design-token definitions change anywhere in this task.
- `.login-form-container`, `.demo-section`, `.admin-shell`, `.resources-panel`, and `.register-student-modal` render pixel-identical to before this change.
- No native browser dialog (`alert`, `confirm`, `prompt`, their `window.*` forms, `beforeunload`) is introduced anywhere by this change; this is a CSS-only task and must introduce no dialog affordance.

## Risks and rollback

| ID | Severity | Risk | Mitigation |
|----|----------|------|------------|
| R1 | High, and stated prominently | This is the seventh instance of this defect class reaching this point, and jsdom-based source scans are structurally blind to it by construction — `AdminStudentsPage-issue42-screenComposition.test.tsx:46` states in its own words that "jsdom applies no real CSS cascade, so a source-level scan" cannot determine cascade winners. A source scan can confirm selector lists and comment text match this plan, but it cannot determine which same-specificity rule the browser's cascade actually renders. This is precisely why the defect shipped through issue #42's own validation the first time. | Both the design generalist and the independent reviewer disclosed this limit accurately, and neither executed a live browser render. Step 9 (Browser Validator) is the mandatory point where the actual rendered outcome is confirmed, and it is not optional or deferrable. |
| R2 | Tooling constraint, coordinator-directed | Claude-in-Chrome has failed repeatedly this session with rendering/screenshot errors while the dev server was confirmed healthy; a Playwright-fallback approval request went unanswered by the user. | As directed by the coordinator, proceed with the deterministic-evidence substitute for this specific CSS-only fix, consistent with the established pattern already used this session, while recording this constraint plainly rather than silently working around it. |
| R3 | Low | A hidden third stylesheet could declare a competing rule for `.admin-students-page` or the base `.owner-settings-page` that this plan's static read did not find. | Step 0's re-grep sweep mitigates this before any edit is made. |
| R4 | Low | Removing a wrapper border could in principle affect focus-ring visibility around elements near the former wrapper edge. | The browser-validation brief's keyboard/focus journey (J5 below) covers this explicitly at both viewports. |

**Follow-up recommendation, explicitly not a blocker for this plan.** The project should consider either repairing the Claude-in-Chrome tooling or adding a genuine automated visual-regression check to CI — a real headless-browser test, not jsdom — so that an eighth instance of this defect class does not ship silently the way this seventh instance did.

**Rollback.** This change is small, subtractive, and confined to two CSS files plus one test file. A `git revert` of the single commit fully restores prior behavior. No data or schema risk exists anywhere in this task.

## Assumptions and decisions

**Binding decisions, resolved during planning:**

- **D1** Remove `.admin-students-roster`/`.admin-students-detail` from `App.css:796-801` so `AdminStudentsPage.css:434-438`'s issue-#42-reviewed value becomes the sole surviving declaration.
- **D2** Remove `.admin-students-page`/`.owner-settings-page` from `App.css:706` with no replacement declaration — resolved as a plain, borderless, shadowless wrapper, because neither selector's underlying reference material (or lack thereof) calls for a wrapper-level treatment, in contrast to `OwnerDashboardPage`'s documented, purpose-specific `.owner-dashboard` exception.
- **D3** `.admin-shell`, `.login-form-container`, `.demo-section`, `.resources-panel`, and `.register-student-modal` are out of scope and unchanged.
- **D4** The radius-only selector list at `App.css:790-795` is not a conflict (zero-radius policy) and is left as-is except for Defect C's `.feedback-form` removal.
- **Defect C** `.feedback-form` is dead and is removed from all three `App.css` lists as a pure no-op.

**Assumed safe:** no state-specific CSS keys off the wrapper's border/shadow presence for `.admin-students-page` or `.owner-settings-page` — grepped directly, found none. Browser-default `border-radius: 0` already matches `--radius-square`, so the optional hardening declaration is visually inert either way.

**Unverified at planning time, explicitly disclosed:** the current live text of GitHub issues #41, #42, and #66 was not fetched during planning, because Planner has no `gh` access. This plan uses `ADOPTION-PLAN.md` as the specification of record. Steps 10-11 must begin by fetching the live issue bodies and reporting any divergence before editing them.

**Still required:** explicit user approval of this plan before any engineering writer begins. See "Required approvals" below.

## Required approvals

This plan is NOT covered by the standing forward authorization recorded on the #31-#44 Field Journal DS milestone plans, because it is not one of the GitHub issues that authorization named — it is newly discovered defect remediation, not milestone issue work. The coordinator directed this plan's creation and its Option A / Option B sequencing, but that direction is not a substitute for user approval. Explicit user approval of this plan document is required before T1 or T2 begins any work under it. If approval is later given, record it here with the date and the approving statement, following the same provenance discipline used elsewhere in this repository's plans; do not infer approval from silence or from the coordinator's dispatch of this planning task.

## Browser UI dialog policy

Required — this touches browser-rendered React/Vite UI surfaces. Native `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload` prompts are prohibited absolutely. This change is CSS-only and must introduce no dialog affordance of any kind. A deterministic no-native-dialog source scan across the changed files is a required acceptance check, even though no dialog logic is expected to be touched.

## Browser UI validation

**Launch/readiness:** the dev server already running at `http://localhost:5173` — reuse it, do not start a second one, and never `taskkill` it. No Docker or Supabase required.

**Base URL:** `http://localhost:5173`

**Fixture/reset:** sign in as an owner/admin account with at least one enrolled student and one disabled/revoked student, so `.roster-item` and `.roster-item--disabled` both render.

**Viewport profiles:** 1440 and 390. Both are mandatory and must be recorded separately.

**Journeys:**

- **J1 roster and detail** — owner/admin opens Students, views the roster list (`.admin-students-roster`), opens a student's detail panel (`.admin-students-detail`), returns to roster.
- **J2 settings surfaces** — opens Course settings (`OwnerSettingsPage`); opens Business settings (`BusinessSettingsPage`); opens Brand design (`BrandDesignPage`) to confirm no regression on the `--brand` variant.
- **J3 states** — `AdminStudentsPage` permission-denied / loading / error / normal roster + detail states (`AdminStudentsPage.tsx:175/184/191/415/587`) all show the page wrapper with no border/shadow, and roster/detail cards with `--border-width-rule` + `--shadow-sheet`; `.roster-item` normal and `--disabled` shadows unaffected. `OwnerSettingsPage`/`BusinessSettingsPage` permission-denied / loading / normal-form / validation-error / save-success / save-error states all show a borderless page wrapper with only individually bordered fields. `BrandDesignPage`'s `--brand` variant is pixel-identical to before.
- **J4 mobile and control** — at both viewports, `.admin-students-roster`/`.admin-students-detail` show a visibly thinner rule and tighter hard-offset shadow, distinct from the heavier legacy look retained by `.resources-panel`/`.register-student-modal` (unchanged, serving as a visual control). `.admin-students-page` and the base `.owner-settings-page` show no border/shadow around the whole page, with only inner elements carrying depth. No nested "box inside a box" remains on Students or Settings. The `--brand` variant is unchanged. No native browser dialog appears in any journey.
- **J5 keyboard and focus, both viewports** — the validator must explicitly drive keyboard Tab order, not just render/hover states, to reach each interactive element in J1-J3: roster row links, detail-panel controls, settings form fields, and save buttons. Confirm the focus ring is visible, 3px slate, drawn outside each element's own shadow, at each Tab stop.

**Non-blocking note.** D3 leaves `.register-student-modal` and `Modal` untouched, so no modal-focus-trap surface is introduced by this task and no modal-specific keyboard journey is required.

**Visible outcomes required at both viewports:** the rule-versus-legacy-shadow distinction described in J4; the borderless-wrapper outcome for `.admin-students-page` and base `.owner-settings-page`; pixel-identical `--brand` rendering; zero native dialogs; and the keyboard-focus outcomes in J5.
