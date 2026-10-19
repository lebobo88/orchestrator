# Lizbeth Spanish, Issue #35: DS components C.1-C.3 — controls, fields, marks & stamps

Status: Drafted, routed to engineering under the user's standing authorization. This document has not itself been separately approved by the user; the user has granted standing authorization ("keep going until all the gh issues are finished") that the orchestrator applies to route this plan to engineering, per the Approval basis recorded below. Approval of this document authorizes only issue #35's scope; it does not authorize any of issues #36-#44.

Plan ID: `lizbeth-spanish-issue35-controls-fields-marks`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: `engineering-fleet`
Design route: standard (`design-director`, `ux-architect`, `visual-system-designer`, `design-reviewer`; prototype forbidden; model tier Sonnet; existing-system mode: extend)

## Approval basis

This plan was routed to engineering under the orchestrator's application of the user's standing authorization, not a user-verified per-plan approval. The record below is an orchestrator-applied inference, consistent with the Status line above, and follows the same provenance discipline the #31, #32, #33, and #34 plans used.

- **Standing authorization quoted (verbatim, as relayed by the orchestrator):** "didn't i tell you to stop asking me for approval? i told you to keep going until all the gh issues are finished," reinforced by an explicit session goal, "don't stop until all the DS gh issues are implemented and browser validated."
- **Application:** The orchestrator applied this standing authorization to route this plan (issue #35 of `lebobo88/lizbeth-spanish`, the next issue in the dependency chain the user directed continuation through, after #31, #32, #33, and #34) to engineering without a further live per-plan checkpoint.
- **Provenance label:** This basis reached Scribe entirely through the orchestrator's account of the session; Scribe has not independently observed the quoted user statements. It is recorded here as an orchestrator-applied inference under standing authorization, NOT as a Scribe-verified per-document user approval.
- **Additional gate not present on #31-#34: `PLAN_DUCK` Codex cross-vendor judge checkpoint.** Given this plan's high blast radius (`Modal.tsx`'s consumers app-wide, `LoginForm`, `RegisterStudentModal`, `AdminStudentModals`, `AccessibilitySettings` (full rebuild), and `ForcedPasswordChangeGate`, plus closure of issue #28), a Terra-tier `PLAN_DUCK` Codex judge pass was run against the drafted plan in advisory/shadow mode, not policy-blocking, per `docs/JUDGE-CONTRACT.md`. It returned high confidence and a `REVISE` verdict with seven findings (J-01-1 through J-05-2). Planner adopted six on their merits against direct repository evidence (scope boundary for the interim two-tier state; the Primary-tiering rule's over-breadth; modal stacking and background inertness, independently reconfirmed against current source; issue #28's closure-verification gap; the auth-form migration non-regression contract; the forced-colors gate for new controls) and refuted one: J-03-2 claimed `--color-surface-interactive-default` is undefined in `Modal.css`, which direct repository evidence disproved — the token is defined at `App.css:46` and consumed live at 14 sites across 10 files; the judge had evidently searched only the generated token file (`src/tokens/field-workbook.generated.css`) rather than the full stylesheet set. The full disposition table and the refutation's supporting evidence are recorded in this plan's own "Judge review and disposition" section. Deterministic repository evidence, not judge authority, governed both the adoptions and the refutation.
- **Issue #28 live-body verification, additional to the plan's original draft.** The orchestrator independently fetched issue #28's live GitHub body (`gh issue view`) and relayed it to Planner. The fetch found #28 requires BOTH scroll-fit AND functional-controls verification: "Fix it properly with atelier mcp so it can be used properly by users as intended. Make sure all the controls and widgets in the popup also work as expected and as intended." This is broader than #35's own paraphrase, which named only the 390px/1440px scroll-fit criterion. Planner incorporated the full #28 body as a plan requirement: closure of #28 requires live verification against both #28's actual body (fit, scroll, and every control functionally verified) and #35's operationalized scrolling criterion, not inference from implementing #35 alone. This is recorded in the plan's "Research evidence and its limits" section (closure gate) and carried through to "Acceptance and validation" and Browser UI validation Journey A.
- **Design gate.** The design route was Standard (director, UX architect, visual system designer, reviewer; prototype forbidden). The first design review cycle returned `NEEDS_REVISION` with six findings; all six were resolved in revision 2, and the reviewer returned `DESIGN_REVIEW_RESULT: PASS`. No design re-review was performed for the subsequent judge-driven plan edits; per this plan's own "Design route and handoff" disposition, six of the seven judge findings are engineering, plan-structure, or verification-gate matters outside visual specification, and the two design-adjacent findings (forced-colors gate, modal stacking/inertness) require conformance to invariants already established and shipped by issue #34, not new visual direction.
- **Date:** 2026-09-01.

---

## Outcome and audience

GitHub issue #35, "DS components C.1-C.3: controls, fields, marks & stamps," is the fifth issue in the 14-issue Field Journal Design System milestone (#31-#44). It delivers the three primitive component families every screen in the app is built from: Control (C.1), Field (C.2), and the three C.3 mark/stamp components, plus the AccessibilitySettings rebuild that closes GitHub issue #28. Issue #36 depends on this issue landing.

Audience: the T1/T2 engineering fleet implementing this plan, then Verifier and Browser Validator gating it.

## Scope

**In scope** — the issue's literal file list plus four review-mandated regression fixes:

1. New `src/components/ui/` primitives: Control (C.1, five tiers), Field (C.2, single-line + textarea + counter), and the three separate C.3 mark components (content badge, week stamp, account-status pill).
2. `src/components/Modal.css` — exactly two token substitutions (see Interfaces and data). `src/components/Modal.tsx` logic is NOT modified.
3. `LoginForm.tsx`/`.css`, `RegisterStudentModal.tsx`/`.css`, `AdminStudentModals.tsx`/`.css`, `AccessibilitySettings.tsx`/`.css` (full rebuild), `ForcedPasswordChangeGate.tsx`/`.css`.
4. `src/components/journal/Stamp.tsx` + `Stamp.css` — add the third `in-hand` state only.
5. `src/pages/AdminStudentsPage.tsx` — Primary-count regression fix only. This file is not in the issue's literal list, but the fix is required by the issue's own "EXACTLY ONE Primary per view" constraint; scope-limited to className/tier swaps.

**Non-goals** — explicitly deferred, each with a stated reason:

- Reconciling the roughly 18 other files carrying button styling (approximately 117 `<button>` elements across 24 non-test `.tsx` files; 19 CSS files). Per `design/field-journal/ADOPTION-PLAN.md`, milestone steps 6 ("Components C.4-C.8") and 14 ("Derived screens") already own most of them. Widening #35 now would over-fragment the milestone and delay #36. The `src/components/ui/` primitives MUST be built so those files can adopt them later without modification to the primitives themselves.
- **Acceptable interim inconsistency, defined (added per judge finding J-01-1; see Judge review and disposition).** The two-tier interim state on landing is bounded, not open-ended:
  - Acceptable: an unmigrated surface continues to render its current `.demo-button` or bespoke styling consistently within its own screen, remains fully keyboard operable, and retains visible focus.
  - NOT acceptable, and therefore a defect even though the file is out of #35's scope: a control that renders with NO styling at all. Concrete instances found: `CourseWorkspacePage.tsx` has several entirely unstyled `<button>` elements with no `className` (around lines 71, 75, 158 (three), 651, 715), covering "Try again" and the Bold/Italic/Bullets toolbar controls, receiving only browser-default styling.
  - Resolution: the roughly 18 remaining files stay assigned to milestone steps 6 ("Components C.4-C.8") and 14 ("Derived screens") per `design/field-journal/ADOPTION-PLAN.md`. The unstyled `CourseWorkspacePage` controls should be raised now as a tracked defect against the milestone rather than left to be discovered later. Labeled assumption, not fact: #36 is the correct home for that tracked defect, since it is the next issue in the chain and the natural adoption gate — #36's body has not been read by this plan.
- `AdminStudentsPage.css` lines 224-267 and 436-440: bare-element `button.destructive`/`.caution`/`.small` rules that are very likely dead CSS (specificity 0,0,1 losing to the `.demo-button caution small` class selectors actually used in the TSX). Flag as a tracked follow-up; do not delete without browser-verified confirmation.
- `LoginForm`'s missing loading/disabled state on its async "Sign in" call.
- Reconciling the specimen's `-6deg` LOCKED stamp rotation against the shipped `+8deg`.
- `Modal.css`'s remaining legacy undefined token beyond `--color-focus-ring`: `--typography-fontSize-2xl`. Note `--text-size-multiplier` is legacy-named but confirmed live-wired at `AccessibilityContext.tsx:59` — it is NOT dead, do not remove it. `--color-surface-interactive-default` was checked by judge finding J-03-2 and confirmed defined and live (see Judge review and disposition); it is NOT in this non-goals list as an undefined token.
- One combined `ADOPTION-PLAN.md` doc correction for two inaccurate acceptance-criteria checkboxes: line 241 says Primary = "ink.900" where the specimen markup uses ink.1000, and line 249 says the C.2 label is ".2em" where the specimen's actual field label is ".18em".

## Verified repository findings

- Token layer `src/tokens/field-workbook.generated.css` (approximately 60 entries) is ground truth from issues #31-#33. Confirmed present: `--border-color-default` (line 3, = ink-1000), `--border-width-rule: 3px` (line 5), `--color-focus: #3d5f6b` (line 14), `--font-line-height-body: 1.55` (line 46), `--hit-target-min: 44px` (line 57), `--shadow-sheet: 8px 8px 0 0 #1a1512` (line 89), `--space-3: .75rem` (line 105). No shipped value in this file may be altered by this plan.
- Specimen `design/field-journal/Field Journal DS.dc.html`: C.1 is at lines 329-361, C.2 at 363-384, C.3 at 386-404. C.3 is not a standalone card — it is the second grid column of C.2's outer card. The specimen uses literal hex only; it contains no `var(--...)` references, so every token name in this plan is a mapping onto the shipped token file, not a name present in the specimen.
- `Modal.tsx`'s focus trap, Escape-to-close, focus restoration, and the J-003 decision (the dialog container is the one-time initial-focus target but is excluded from the Tab cycle) are covered by four existing test files: `Modal.test.tsx`, `Modal-FocusTrap-ShiftTab.test.tsx`, `Modal-FocusTrap-Boundaries.test.tsx`, `RegisterStudentModal-FocusRestore.test.tsx` (the last includes a trigger-remount regression case tracing to a real T2-found production defect). These are a pure no-regression gate; they must pass unmodified.
- `Modal.css`: `.modal-content` (NOT `.modal-body`) is the real scroll container — `flex: 1; min-height: 0; overflow: auto;`, capped at `max-height: 90vh` (95vh under a 640px breakpoint). `.modal-body` carries typography only. `--color-focus-ring` appears at exactly two sites, `.modal:focus` and `.modal-close-button:focus`, and does not exist in the token file — a live WCAG 2.4.7 visible-focus gap.
- `AccessibilitySettings.css` currently carries two parallel button conventions in one file (`.accessibility-button` and `.button-primary`) and references `--color-accent-primary`, `--color-accent-secondary`, `--color-focus-ring` — none of which are present in the shipped token file, confirming the file predates the #31 migration. Slider thumbs are 1.25rem/20px (lines 70-71, 90-91) and `.radio-label` padding is `--space-2`/8px, both failing the 44px hit-target floor today.
- `journal/Stamp.tsx` ships `StampState = 'done' | 'locked'` with a documented Decision D4 deferring the third state. The #34 removal-test structural/decorative CSS-split convention applies to devices 06 and 08 only, NOT to Stamp (device 04) — the new `--in-hand` variant follows Stamp's existing combined transform+color+border pattern.
- `journal-devices.css` carries repo-wide CSS invariants that apply here: no `-webkit-text-fill-color: transparent`, no `forced-color-adjust: none`, mandatory `@media (forced-colors: active)` blocks for the named classes, and `color-mix()` fallback-declaration ordering.
- A reversibility audit of existing confirm/destructive flows found NO existing misclassification: Disable/Reset/Revoke/Re-issue are correctly reversible, Hard delete/Wipe Save correctly irreversible, Unassign correctly not a caution tier (its own copy states progress is preserved and it can be re-assigned). The one exception is ConfirmEmailModal, fixed in this plan (see Interfaces and data, regression tier swaps).
- **Modal stacking, verified directly against current source (judge finding J-03-1, adopted; see Judge review and disposition).** `AccessibilitySettings.css:15` sets the "Aa" trigger to `z-index: 1000`. `Modal.css:18` sets `.modal` to `z-index: 999`; `Modal.css:9` sets `.modal-backdrop` to `z-index: 998`. The trigger therefore renders ABOVE both the modal and its backdrop, staying visible and clickable while any modal is open — a real focus-trap escape and interaction defect, not a cosmetic z-order nit. Relevant prior history: `App.css:268` carries a dedicated `.modal:focus { z-index: 999 }` rule that exists because App.css's blanket `button:focus, [tabindex]:focus { position: relative; z-index: 10 }` rule (lines approximately 228-231) had once collapsed the modal's stacking to 10, making every confirmation modal's primary button unclickable on first click. That regression is documented in `src/__tests__/e2e/gap-4-admin-students-remediation.spec.ts` around line 25 and guarded by `src/__tests__/FixedOverlayFocusPosition.test.ts`. This area has already caused one production defect; changes here must not disturb those guards. `ForcedPasswordChangeGate.css:12` is also `z-index: 1000`, but that is a full-page gate rendered instead of the app shell rather than over a modal, so it is not the same defect; any stacking scheme must not break it. `Modal.tsx`'s docstring already claims "Inert background: background is non-interactive when modal open," but no existing test asserts it — this is a real gap between documented and actual behavior.
- **`--color-surface-interactive-default`, checked and refuted as undefined (judge finding J-03-2, refuted; see Judge review and disposition).** It is defined at `App.css:46` as `--color-surface-interactive-default: var(--color-paper-100);` and consumed at 14 sites across 10 files, including `WeekCard.css`, `AdminStudentsPage.css`, `FlashcardsViewer.css`, `BandRoadmap.css`, `ResourcesPanel.css`, `OwnerSettingsPage.css`, `RegisterStudentModal.css`, and `ForcedPasswordChangeGate.css`. There is no transparency risk to `Modal.css`'s opaque-sheet requirement. One minor, non-defect observation: the variable lives in `App.css` rather than the generated token layer, so it is an app-level variable rather than a design token — a possible future consolidation for the milestone, explicitly out of scope for #35.

## Research evidence and its limits

A nested Researcher packet was consumed directly by Planner (deep profile, architecture mode; source ledger S1-S15, all local repository reads with file paths and line numbers).

**RESIDUAL LIMIT, as originally recorded.** The live GitHub bodies of issues #28 and #35 could NOT be fetched by Researcher (private repo, no authenticated fetch available). Issue #35's body was supplied verbatim by the orchestrator to Planner and is treated as authoritative for this plan.

**#28 verified since the original draft (judge finding J-04-1, adopted; see Judge review and disposition).** Issue #28's live body has since been fetched by the coordinator and is recorded here as verified content, replacing the earlier unverified assumption:

- Title: "Reading & Accessibility Settings Popup Modal doesn't scroll or fit on the page properly".
- Body, verbatim and complete: "Fix it properly with atelier mcp so it can be used properly by users as intended. Make sure all the controls and widgets in the popup also work as expected and as intended."
- Labels: `blocked:field-journal-ds` ("Parked until the Field Journal DS milestone lands; re-triage after"). State: OPEN, no milestone directly assigned.
- Disposition: no staleness block. #28's body is thinner than #35's paraphrase but does not contradict it; #35's "Modal content scrolls within the viewport at 390px and at 1440px" is a faithful operationalization of #28's "doesn't scroll or fit."
- **Important addition: #28 has a second requirement that #35's paraphrase does not fully capture** — "make sure all the controls and widgets in the popup also work as expected and as intended." Scrolling alone does not close #28. Every control in the settings popup must be verified functional, not merely visible and reachable: Text Size, the four Typography radios, Line Height, Letter Spacing, and Reading Measure must each be verified to actually change the rendered result, with `--text-size-multiplier` confirmed live-wired at `AccessibilityContext.tsx:59` (see Acceptance and validation and Journey A in Browser UI validation below).
- **Closure gate.** Before #28 is marked closed, the implementation must be verified against BOTH #28's actual body (fits, scrolls, and every control works) and #35's operationalized 390px/1440px criterion. Closure may not be inferred from planning or from implementing #35 alone.
- #28's "Fix it properly with atelier mcp" cannot be satisfied literally, because the Atelier MCP compiler gap is the disclosed, user-authorized limitation already recorded in this plan (see Design route and handoff and Assumptions and decisions). The functional outcome the user asked for is what must be delivered and verified; this substitution is disclosed explicitly here rather than made silently.

## Design route and handoff

```
DESIGN_ROUTE
profile: standard
reasons: Three primitive component families every screen is built from; multi-state components with four control tiers plus focused/disabled and full field error states; a modal criterion change and an AccessibilitySettings rebuild that closes #28. Not studio — the visual direction is already fixed by the shipped specimen and the #31-#33 token layer, so no safe/refined/novel selection exists to make. Not compact — far beyond a bounded single-surface change.
agents_required: design-director, ux-architect, visual-system-designer, design-reviewer
prototype: forbidden
model_tier: sonnet
existing_system_mode: extend
END_DESIGN_ROUTE
```

**Design handoff: PASSED.** Full reviewed `DESIGN_HANDOFF` (revision 2) from design-director, retained in the planning chain. Its load-bearing content is reproduced in Interfaces and data below.

**Design review: PASSED.** `DESIGN_REVIEW_RESULT verdict: PASS` from an independent design-reviewer, on revision 2, after one evidence-backed `NEEDS_REVISION` cycle. The first review raised six findings, all resolved in revision 2:

1. `Modal.css` failing the 3px-rule half of the shadow.sheet criterion, plus the undefined `--color-focus-ring`.
2. The `.18em`/`.2em` label-tracking conflict resolved silently in revision 1.
3. Deferral of three known in-scope Primary-count violations.
4. 14px mispresented as a deviation when it is a direct specimen match (now tokenized as `--font-size-button-label`).
5. A missed page-level multi-Primary case in `AdminStudentsPage`'s StudentDetailView.
6. Hit targets asserted without values.

The reviewer independently recomputed four contrast figures by WCAG relative-luminance math and confirmed all four matched the design handoff's stated figures.

**Two non-blocking carry-forward notes for engineering**, recorded by the reviewer and explicitly NOT blockers:

- (i) The stated `12+20+12=44px` radio-row arithmetic does not reflect the true height driver: `.radio-label` resolves to a 16px fallback with roughly 1.5 line-height, so the roughly 24px text line governs in a flex `align-items: center` row, yielding roughly 48px. This overshoots the 44px floor and is compliant, but engineering should verify the actual rendered row height rather than trust the arithmetic literally.
- (ii) A literal 44x44px visible thumb on an 8px track is compliant but will read as visually oversized against the Field Journal's thin-rule language. A transparent padded hit-area around a visually smaller thumb satisfies WCAG 2.5.8 with less visual disruption and is the preferred approach.

The reviewer also could not verify the three new browser-validation journeys (B2, E, F) at full step detail; they are specified at full step detail in Browser UI validation below.

The disclosed, user-authorized Atelier MCP compiler gap is NOT a review finding: `mcp__atelier__tokens_validate` returns "no token sources configured" for this repository. It is recorded here honestly as a tool gap, never as a pass. See Assumptions and decisions for the precedent this follows.

**Design re-review disposition.** No design re-review was performed for the judge-driven revision recorded in Judge review and disposition below. The design packet already holds a `DESIGN_REVIEW_RESULT: PASS` after one evidence-backed revision cycle, which is the design contract's limit for this plan. Six of the seven judge findings are engineering, plan-structure, or verification-gate matters that do not alter the visual specification. The two that touch design-adjacent territory — the forced-colors gate (J-05-2) and modal stacking/inertness (J-03-1) — are conformance to invariants ALREADY established and shipped in this repository by issue #34 and enforced by existing tests, not new visual direction. Requiring conformance to an existing invariant needs no new design authority. No new colour, geometry, token, or component behavior was introduced by any of the seven judge-driven edits; the eight additive tokens and every visual value in this plan are unchanged from the original draft.

## Judge route

`PLAN_DUCK` is eligible after Scribe returns this draft and before user approval, per `docs/JUDGE-CONTRACT.md`, justified by high risk and cross-cutting blast radius. The orchestrator owns that call, not this plan. Deterministic failures always dominate any judge finding.

## Judge review and disposition

A `PLAN_DUCK` Terra-tier judge pass was run against this plan in advisory/shadow mode, not policy-blocking, and returned `REVISE` with seven findings. Findings were adopted into this plan on their merits, evaluated against direct repository evidence, not because a judge raised them. Deterministic evidence dominates judge findings; one finding was refuted by direct repository evidence and is recorded as refuted, not adopted.

| ID | Topic | Disposition | Where reflected in this plan |
|----|-------|-------------|-------------------------------|
| J-01-1 | Scope boundary for the two-tier interim state | ADOPTED | Scope, non-goals: "Acceptable interim inconsistency, defined" |
| J-02-1 | Primary rule too syntactically broad | ADOPTED with refinement | Interfaces and data: "EXACTLY ONE Primary per view" rule |
| J-03-1 | Modal stacking and background inertness | ADOPTED, independently confirmed against current source | Verified repository findings; Ordered work Phase 4; Acceptance and validation; Browser UI validation Journey A |
| J-03-2 | Claimed undefined token `--color-surface-interactive-default` | REFUTED, not adopted | Scope, non-goals; Verified repository findings |
| J-04-1 | Issue #28 closure verification | ADOPTED, live issue body now available | Research evidence and its limits; Acceptance and validation; Risks and rollback (R5); Browser UI validation Journey A |
| J-05-1 | Auth-form migration non-regression contract | ADOPTED | Ordered work Phase 4 |
| J-05-2 | Forced-colors gate for new controls | ADOPTED | Ordered work Phases 1-3; Acceptance and validation; Browser UI validation |

The refuted finding, J-03-2, claimed `var(--color-surface-interactive-default)` in `Modal.css:24` is undefined with no fallback and could render the modal surface transparent, breaking the opaque-sheet requirement. Direct repository evidence refutes this: the variable is defined at `App.css:46` as `--color-surface-interactive-default: var(--color-paper-100);` and consumed at 14 sites across 10 files. There is no transparency risk and no defect; the #33 token fallback audit was correct not to flag it. The likely cause of the false positive is a search scoped only to `src/tokens/field-workbook.generated.css` rather than the whole stylesheet set. See Scope, non-goals and Verified repository findings for the full disposition.

## Ordered work

Four sequenced phases within ONE plan and ONE engineering job.

**Phasing rationale, recorded explicitly.** This issue is the largest and most cross-cutting in the milestone, but splitting it into four separately approved plan documents would multiply approval cycles and delay #36, which depends on this landing. Narrowing scope to the literal file list, rather than the roughly 24-file button surface, already removes the bulk of the risk. Each phase has its own gate and is individually revertible.

Owner for every step: T1, escalate to T2 on two counted gate failures. TDD-first — RED evidence is required before any production edit in every phase.

**Forced-colors gate, applies across Phases 1-3 (judge finding J-05-2, adopted).** Every new `src/components/ui/` control and field, and AccessibilitySettings' custom range input and thumb styling in Phase 4, must include a `@media (forced-colors: active)` block, following the pattern issue #34 already established and that existing tests enforce for the journal device CSS set. The substantive reason: this design system's meaning is carried almost entirely by border, shadow, and fill. In forced-colors mode, `box-shadow` is dropped and system colors override author colors, so the hard-offset shadows that distinguish the tiers and the fills that distinguish Caution-reversible from Caution-irreversible both disappear. Each tier must therefore remain distinguishable in forced-colors mode by a non-colour, non-shadow means, and the disabled state must remain visibly disabled. The custom range thumb (Phase 4) is the highest-risk element, because a custom-painted thumb can vanish entirely in forced-colors mode; it must remain visible and operable. Reconfirm the existing prohibitions still apply to all new CSS: no `-webkit-text-fill-color: transparent` and no `forced-color-adjust: none`.

**Phase 1 — Foundations.**
- Add the eight new tokens (see Interfaces and data) to the token layer, additively.
- Build `src/components/ui/` Control with all five tiers and every state.
- Gate: `npx tsc` clean; `npm test` green; new Control tests cover all five tiers plus base/hover/active/focus-visible/disabled; a deterministic source scan confirms the native `disabled` attribute is used rather than a CSS-only class; a deterministic source scan confirms the new Control CSS file contains a `forced-colors` block (see Forced-colors gate above).

**Phase 2 — Fields.**
- Build `src/components/ui/` Field (single-line, textarea, counter) with all states.
- Gate: a test asserts the error state changes BOTH the rule colour and the mono error line — a colour-only change must fail the test. A test asserts the counter renders zero-padded `0041 / 5000`. A test asserts the label renders above the field, never inside it. A deterministic source scan confirms the new Field CSS file contains a `forced-colors` block.

**Phase 3 — Marks and stamps.**
- Build the three separate C.3 components (content badge, week stamp, account-status pill).
- Extend `StampState` to `'done' | 'locked' | 'in-hand'` and add the `--in-hand` CSS variant.
- Gate: tests cover all five badges' verbatim vocabulary, all three stamp words (DONE, IN HAND, LOCKED), and all three glyph+word account states; a test asserts stamps are `aria-hidden` while badges and pills are not; existing `Stamp.test.tsx` and `journalDevicesRemovalTest.test.tsx` pass unmodified; a deterministic source scan confirms the new C.3 CSS files contain a `forced-colors` block.

**Phase 4 — Consumer adoption, Modal, and the #28 fix.**
- Apply the two `Modal.css` token substitutions.
- Rebuild `AccessibilitySettings` on C.1/C.2 geometry, including the concrete hit-target fixes for the range thumb and `.radio-label` (see Interfaces and data).
- **Modal stacking and background inertness (judge finding J-03-1, adopted).** Correct the stacking so no app control renders above an open modal — specifically, the "Aa" trigger's `z-index: 1000` in `AccessibilitySettings.css:15` must not sit above `.modal`'s `z-index: 999` (`Modal.css:18`) or `.modal-backdrop`'s `z-index: 998` (`Modal.css:9`) while a modal is open. Make background content genuinely non-interactive while a modal is open, closing the gap between `Modal.tsx`'s documented "Inert background" claim and actual behavior. This change must not disturb `App.css:268`'s `.modal:focus { z-index: 999 }` rule, the blanket `button:focus, [tabindex]:focus` stacking rule at `App.css` lines approximately 228-231, or `ForcedPasswordChangeGate.css:12`'s independent `z-index: 1000` (a full-page gate, not a modal overlay). `src/__tests__/e2e/gap-4-admin-students-remediation.spec.ts` and `src/__tests__/FixedOverlayFocusPosition.test.ts` must continue to pass unmodified.
- **Auth-form migration non-regression contract (judge finding J-05-1, adopted).** Applies to `LoginForm`, `RegisterStudentModal`, `AdminStudentModals`, and `ForcedPasswordChangeGate`, since these are live authentication and account-administration flows.
  - Existing tests for these flows must pass UNCHANGED: `LoginForm.test.tsx`, `RegisterStudentModal.test.tsx`, `RegisterStudentModal-FocusRestore.test.tsx`, `RegisterStudentModal-StaleError.test.tsx`, `AdminStudentModals.test.tsx`, `ForcedPasswordChangeGate.test.tsx`, `AuthContext.test.tsx`, `AuthContext-EmailNotConfirmed.test.tsx`, and `step4b-email-not-confirmed-flow.test.tsx`. If any test genuinely must change, the change requires explicit written justification in the PR describing why the new behavior is correct; silently loosening, deleting, or weakening an assertion is a job failure, not a passing gate.
  - The new `Control` and `Field` primitives must forward refs, since focus management in these flows depends on reaching the underlying DOM node.
  - Native semantics that must be preserved through the migration, enumerated so an implementer cannot lose them incidentally: `type="submit"` behavior and Enter-key form submission; the native `disabled` attribute rather than a CSS-only disabled class; `aria-invalid` on a field in its error state; `aria-describedby` wiring a field to its error line; the accessible name and its association with the visible label; `autoComplete` attributes on credential inputs; and `type="password"` on password inputs.
  - Error focus movement must be preserved: where a flow currently moves focus to the first errored field on submit, it must continue to do so.
  - The existing typed-confirmation disabled gates on Delete and Wipe must remain functional, staying disabled until the typed value exactly matches.
  - A migration that changes visual tier while altering submission, validation, or focus behavior is out of contract; this phase is a restyle plus the four named tier swaps, not a behavior change.
- Migrate `LoginForm`, `RegisterStudentModal`, `AdminStudentModals`, `ForcedPasswordChangeGate` onto the new primitives, subject to the contract above.
- Apply the four Primary-count tier swaps (see Interfaces and data).
- Gate: the four existing Modal test files pass UNMODIFIED; the nine named auth-flow test files pass UNCHANGED per the contract above; a deterministic source scan confirms no interactive control's `z-index` exceeds the modal's; `AccessibilitySettings`' new CSS contains a `forced-colors` block covering the custom range thumb; full suite green; then Verifier, then Browser Validator.

## Interfaces and data

No API, schema, migration, or persistence change in this issue. `StampState`'s union widens from `'done' | 'locked'` to include `'in-hand'` — additive and non-breaking for existing callers. The `src/components/ui/` primitives are new public component interfaces that later milestone steps (6 and 14) will adopt; their props must be general enough to serve the roughly 18 currently out-of-scope files without later modification to the primitives themselves.

**Eight new additive component tokens** (no collision with, and no alteration of, any shipped value):

| Token | Value |
|---|---|
| `--font-size-label` | `0.75rem` |
| `--font-size-button-label` | `0.875rem` |
| `--shadow-brass-press` | `7px 7px 0 0 var(--color-brass-500)` |
| `--shadow-brass-none` | `0 0 0 0 var(--color-brass-500)` |
| `--color-badge-tint-dialect` | `#eef3f4` |
| `--color-badge-tint-archaic` | `#fef5e7` |
| `--color-badge-tint-inclusive` | `#eef5f0` |
| `--color-badge-tint-disabled` | `#fffbf8` |

**Seven resolved open questions from the design review cycle:**

1. Primary fill = `--color-ink-1000`, following the specimen markup over `ADOPTION-PLAN.md` prose, which conflict (see Non-goals doc-correction item).
2. Badge tints are delivered as four literal tokens, not `color-mix()`. The "⚠ Sensitivity note" badge uses solid `--color-amber-200`, not a tint.
3. `brass.700` is permitted for the "IN HAND" stamp on paper-50/100/200 (WCAG 5.65/5.47/4.89:1). LOCKED/terracotta stays restricted to paper-50/100, since paper-200 fails at 4.05:1.
4. LOCKED rotation keeps the shipped `+8deg` (the specimen's `-6deg` reconciliation is a stated non-goal).
5. `--font-size-label` (12px) stays distinct from `--font-size-caption` (13px, error line only) — the specimen deliberately uses two mono sizes in C.2.
6. Caution tier easing is normalized to `--motion-easing-standard`; the specimen omits it with no stated product reason.
7. Field/counter labels use `.18em` tracking; `.2em` belongs to section-eyebrow headers only. Verified as a real two-tier specimen pattern across multiple independent elements.

**C.1 Control — universal geometry:** `min-height: var(--control-height)` (48px); `border: var(--border-width-rule) solid` (3px); `border-radius: var(--radius-square)` (0); transition `transform, box-shadow var(--motion-duration-press) var(--motion-easing-standard)` (120ms).

Five tiers:

- **Primary** — ink-1000 fill, paper-50 text, `--shadow-brass`; hover `translate(-2px, -2px)` + `--shadow-brass-press`; active `translate(3px, 3px)` + `--shadow-brass-none`.
- **Secondary** (the default tier) — paper-100 fill, ink-1000 shadow; hover paper-200 + `--shadow-press`; active `--shadow-none`.
- **Caution-reversible** — amber-200 fill, ink-1000 text at 13.22:1. Amber never carries paper/white text.
- **Caution-irreversible** — terracotta-600 fill, paper-50 text at 4.69:1; supports the typed-confirmation disabled gate.
- **Quiet** — no background or border; brass-700 at 5.65:1; persistent 2px underline at 4px offset; hover moves colour to terracotta-600 AND thickens the underline to 3px as a non-colour cue.

**Universal Disabled**, across all five tiers: paper-200 background, ink-700 text at 7.47:1, `border: 3px dashed var(--color-ink-700)` (the only dashed border anywhere in C.1), `cursor: not-allowed`, no shadow. Disabled REQUIRES the native HTML `disabled` attribute rather than a CSS-only class — this is what makes disabled and focused mutually exclusive by construction.

**C.2 Field:** mono label, weight 700, `--font-size-label` (12px), `.18em` tracking, uppercase, ink-1000, `margin-bottom: var(--space-2)`, positioned ABOVE the field and never inside it. 3px ink-1000 rule; paper-100 inset fill; 48px min-height; padding `0 14px`; `--font-size-body` (17px) text. Error state changes TWO things: border-colour to `--color-status-error-border` AND adds a mono `--font-size-caption` (13px) error line in `--color-status-error-text`. A colour-only change is a failing implementation. Textarea: padding `12px 14px`; rows-driven height; `resize: vertical`; line-height `--font-line-height-body` (1.55). Counter: mono, `--font-size-label` (12px), `.14em` tracking (kept literal, single-use), ink-700, right-aligned, format `0041 / 5000` (4-digit zero-padded numerator).

**C.3 marks and stamps** — three structurally separate components, never interchangeable:

- **Badges** annotate a phrase group and carry the accessible name.
- **Stamps** are `aria-hidden` decorative verdicts on a whole week.
- **Pills** are the accessible name for an admin-row account state.

Merging them risks hiding content that must stay in the accessibility tree.

Five badges, verbatim vocabulary: "Register · tú" (ink-1000/paper-200, 15.25:1); "Dialect · Rioplatense" (ink-slate/tint-dialect, 6.16:1); "Old / modern" (brass-700/tint-archaic, 5.37:1); "Inclusive language" (ink-moss/tint-inclusive, 6.87:1); "⚠ Sensitivity note" (ink-1000/amber-200 solid, 13.22:1). All badges: 2px border, mono 12px, weight 600 (700 for the alert badge), `.1em` tracking, uppercase, padding `6px 10px`.

Three stamps at the shipped 15px, weight 700, `.22em` tracking, padding `var(--space-2) 14px`, opacity `.88` isolated to the `::before` decorative layer ONLY, never text or border paint — reproducing opacity on text/border would undo a previously fixed 3.77:1/3.34:1 contrast failure. States: DONE at `-8deg`, ink-moss (unchanged); LOCKED at `+8deg`, terracotta-600 (unchanged); IN HAND at `+4deg`, brass-700 (new).

Three pills, padding `4px 8px` (the geometric differentiator from badges): "✓ Active" (ink-moss/tint-inclusive); "◔ Pending first login" (brass-700/tint-archaic); "✕ Disabled" (terracotta-600/tint-disabled, 4.68:1).

**"EXACTLY ONE Primary per view" rule, refined per judge finding J-02-1 (adopted with refinement; see Judge review and disposition).** "View" = controls simultaneously rendered AND interactive within one focus/tab scope — what a reviewer can screenshot and count. Two composing sub-rules on the view boundary, unchanged from the original packet:

- (a) Multi-phase modals count per rendered phase, since phases are separate `<Modal>` mounts via mutually exclusive branches whose DOM trees never coexist.
- (b) The modal boundary is a view boundary — the page's Primary is `aria-hidden`/non-interactive behind an open modal, so a modal's sole CTA may be Primary independently of the page behind it.

**Primary test, the governing rule:** a control may be Primary only if it is the view's single most important forward-progress action, verified per screen.

**Repetition presumption:** an action instantiated N times by a `.map()` is presumed NOT Primary, because N is data-dependent and a tier that flips with row count is neither reviewable nor testable. Default it to Secondary or the appropriate Caution tier.

**Named exception, rebutting the presumption:** a repeated action MAY be Primary where repetition is bounded to exactly one by construction rather than by data — either (i) the collection is guaranteed at most one element by a structural invariant (for example, a single pending-approval row that the surrounding logic permits only one of), or (ii) the repeated row IS the view, as in a list-detail pattern where the row expands into its own detail scope with its own view boundary. This exception preserves the property the design reviewer specifically valued in the original rule: it stays type-based, not runtime-count-based, so tiering never flips with data. Any use of the exception must be recorded in this plan or the implementing PR with the specific invariant that bounds it to one.

**Confirmed disposition under the refined rule, unchanged:** `AdminStudentsPage.tsx:768` Re-assign instances stay Secondary — preserved enrollments are genuinely unbounded, so no exception applies — and `:809` "Assign a new band" stays Primary as the view's single non-repeated action.

**Four regression tier swaps**, className-only, no logic change:

- `RegisterStudentModal.tsx:264` — Copy button, Primary → Secondary (Done at line 293 remains the phase's sole Primary).
- `AdminStudentModals.tsx:667` — ReissueAccessModal Copy, Primary → Secondary (Done at line 697 remains Primary).
- `AdminStudentModals.tsx:507` — ConfirmEmailModal confirm, → Caution-irreversible, justified by its own copy at line 494 ("It can't be undone, and once confirmed you won't be able to run this again for this student").
- `AdminStudentsPage.tsx:768` — all Re-assign instances → Secondary, while `:809` "Assign a new band" stays Primary as the view's single non-repeated action.

**`Modal.css`, exactly two token substitutions:**

- `.modal` border: `1px solid var(--color-ink-800)` → `var(--border-width-rule) solid var(--border-color-default)`. This satisfies the issue's "shadow.sheet (3px rule + 8px offset)" criterion; the shadow half was already correctly wired.
- `--color-focus-ring` → `--color-focus`, at both occurrence sites (`.modal:focus`, `.modal-close-button:focus`).

**AccessibilitySettings rebuild, closing #28.** Root cause: NOT the Modal wrapper, which already scrolls correctly, but `AccessibilitySettings`' own layout — five setting-groups at `--space-8` gaps plus a fieldset plus Done, especially under the modal's own 200% Text Size applied to itself. Five structural fixes:

1. Single-scroll-container invariant — the rebuilt markup introduces no second `overflow` or fixed-height boundary anywhere, so `.modal-content`'s existing scroll stays the only mechanism and Done is always reachable.
2. Inter-group gap `--space-8` → `--space-6` (both shipped tokens), aiding 200%-zoom reflow per WCAG 1.4.10.
3. Concrete hit targets: range `<input>` gets `min-height: var(--hit-target-min)` via padding around a visually thin track; thumb `::-webkit-slider-thumb`/`::-moz-range-thumb` sized to `var(--hit-target-min)`; `.radio-label` vertical padding `--space-2` → `--space-3`.
4. Button tier consolidation, retiring `.accessibility-button` and `.button-primary` in favour of Quiet and Primary.
5. No sticky header/footer — Modal's header is outside this component's boundary.

## Acceptance and validation

**Deterministic gates, all required:**

- `npx tsc` clean.
- `npm test` (vitest) green, with the four Modal test files unmodified.
- A deterministic source scan across `src/` proving zero occurrences of native `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload`.
- A source scan proving no shipped token value in `field-workbook.generated.css` was altered, and that all eight new tokens are additive.
- A source scan proving no `-webkit-text-fill-color: transparent` and no `forced-color-adjust: none` were introduced.
- A source scan proving no interactive control's `z-index` exceeds the modal's (`.modal`'s `z-index: 999`), following the existing source-scan pattern the project already uses because its vitest config runs jsdom with no CSS pipeline and cannot resolve stylesheet cascades. (Judge finding J-03-1.)
- A source scan proving every new `src/components/ui/` control/field CSS file, and `AccessibilitySettings`' new CSS, contains a `@media (forced-colors: active)` block. (Judge finding J-05-2.)
- Every control in the AccessibilitySettings popup verified functional, not merely visible and reachable: Text Size, the four Typography radios, Line Height, Letter Spacing, and Reading Measure each verified to actually change the rendered result, with `--text-size-multiplier` confirmed live-wired at `AccessibilityContext.tsx:59`. (Judge finding J-04-1, part of the #28 closure gate.)

**Issue-literal criteria to grade against, each individually checkable:**

- One C.1 geometry across all tiers (3px ink.1000 rule, zero radius, 48px, shadow.card).
- Exactly one Primary per view on every screen in scope, counted per the three-part rule above.
- Caution mapped by reversibility, not severity; amber never carries the label text.
- Quiet/disabled/focused distinct without colour alone.
- Press motion at 120ms with the stated translate and shadow values.
- C.2 mono label above the field.
- C.2 error state changing two things.
- Zero-padded counter.
- Full C.3 badge vocabulary.
- All three stamp words.
- All three glyph+word account states.
- Modals carrying shadow.sheet as a 3px rule plus 8px offset.
- No native dialog anywhere.
- Modal content scrolling at 390px and 1440px.

**Independent gates:** Verifier pass required before any completion claim; Browser Validator pass required after Verifier, since this changes core interactive UI app-wide.

## Risks and rollback

| ID | Severity | Risk | Mitigation |
|----|----------|------|------------|
| R1 | High | Scope discovery: the issue names six files, but the app's real button surface is roughly 117 `<button>` elements across 24 non-test `.tsx` files and 19 CSS files, with three partially-colliding styling systems (shared `.demo-button` tiers, bespoke per-component classes, and the likely-dead bare-element block in `AdminStudentsPage.css`). | Scope is held to the literal file list plus the four regression swaps; the remainder is assigned to milestone steps 6 and 14; the primitives are designed for later adoption without change. Accepted consequence, to be stated plainly to the user: on landing, the app will be visibly two-tier — migrated surfaces on the new primitives, the rest still on `.demo-button` or ad-hoc styling, including several entirely unstyled `<button>` elements in `CourseWorkspacePage.tsx`. |
| R2 | High | Shared-component blast radius: `Modal` is used app-wide. | `Modal.tsx` logic is untouched; `Modal.css` receives two pure token substitutions with no structural change; the four existing test files must pass unmodified as the no-regression gate. |
| R3 | Medium | Focus-trap regression: J-003 (dialog container excluded from the Tab cycle) and the trigger-remount restoration path were each found by earlier remediation. | The existing tests are the gate; they may not be weakened or rewritten to accommodate new code. |
| R4 | Medium | Accessibility regression from new colour pairings. | Every pairing in the design handoff carries a stated WCAG ratio; four were independently recomputed by the reviewer and matched. The APCA body threshold (Lc 75) fails for brass.700 on paper-100 and paper-200 and for Quiet-hover terracotta at Lc 71.28 — recorded as known and non-blocking, since this project's established gate is WCAG AA, not APCA. |
| R5 | Medium | Issue #28's live body is now verified (see Research evidence and its limits) and carries a second requirement beyond scrolling: every control in the settings popup must work as intended, not merely be reachable. Closing #28 on scrolling alone would under-deliver against its actual text. | The Acceptance and validation control-functionality checks and the #28 closure gate (Research evidence and its limits) require verifying every control's actual effect, not just its visibility, before #28 may be marked closed. |
| R6 | Low | `--space-8` → `--space-6` rhythm change alters the look of `AccessibilitySettings` beyond the scroll fix. | Accepted: it is a usage change between two shipped tokens, not a new value, and it serves 200%-zoom reflow. |

**Rollback.** Each phase is an independent revert. Phases 1-3 are purely additive (new tokens, new files) and revert cleanly with no consumer impact. Phase 4 carries all consumer risk; reverting it restores the prior UI while leaving the unused primitives in place harmlessly. The two `Modal.css` substitutions revert independently of everything else.

## Assumptions and decisions

**Labeled assumptions:**

- Issue #28's live body has since been fetched and verified (see Research evidence and its limits); its closure criterion is now the verified body text plus #35's operationalized scrolling criterion, not the earlier unverified assumption from the original draft.
- #36 is the correct home for the tracked `CourseWorkspacePage.tsx` unstyled-control defect raised under the acceptable-interim-inconsistency boundary (see Scope, non-goals). #36's body has not been read by this plan; this is a labeled assumption pending that read.
- Primary, Caution, and Field focus-visible states are generalized from the single literal "Focused" swatch the specimen shows only on Secondary.
- Field disabled and focus patterns are inferred; the C.2 specimen does not show them.
- Quiet renders borderless link-style at rest, hover, and focus.
- The `AdminStudentsPage.css` bare-element rules are dead by cascade specificity — inferred, not runtime-verified.

**Planner decisions recorded:**

- Scope is held to the literal file list plus four regression swaps, rather than the full roughly 24-file button surface.
- One plan with four internal phases, rather than four separate plan documents.
- `DESIGN_ROUTE` is standard rather than studio, because the visual direction is already fixed by the shipped specimen.
- The specimen's markup outranks `ADOPTION-PLAN.md`'s prose checkboxes wherever they conflict.

**Pre-authorized by the user and NOT to be re-litigated:** the disclosed Atelier MCP compiler gap, including hand-transcription of specimen values and the documented-manual substitute for the `visual_diff` verification requirement, per the precedent established in issues #31 and #34. This is recorded as a disclosed limitation in this plan's verification sections rather than as a silent pass.

**Standing constraints to record:** TDD-first throughout; the non-standard dev-server port specified in Browser UI validation below; never weaken Docker or host security; the no-native-dialog invariant.

**Approvals still required:** this plan is routed to engineering under the user's standing authorization rather than a separate per-plan approval; see Approval basis above and Status above.

## Browser UI dialog policy

REQUIRED and load-bearing. Native `alert`, `confirm`, `prompt`, every `window.*` variant, and `beforeunload` are prohibited across the entire app. Every acknowledgement or confirmation uses the app-owned accessible `Modal` with a working focus trap and Escape-to-close, or inline validation where that serves the user better. The prohibition is enforced by a deterministic source-level scan, not by assertion. `Modal.tsx`'s focus trap and Escape-to-close must be verified as still working, not merely claimed — the four existing test files passing unmodified is the mechanism.

## Browser UI validation

**Launch/readiness:** `npm run dev -- --port 5199 --strictPort` from the repository root. `package.json`'s `dev` script is bare `vite` with no pinned port, so the non-standard port must be passed explicitly; `--strictPort` makes readiness deterministic by failing rather than silently drifting to another port. Ready when the Vite dev server reports listening on 5199.

**Base URL:** `http://localhost:5199`

**Fixture/reset:** sign in via the dev quick-select as `owner@test.local`. For Journey D, a user with `force_password_change` set. For Journey B2, a student with two or more `preserved`-status enrollments plus at least one available band — if no such fixture exists, it must be created deterministically before validation rather than improvised.

**Viewport profiles:** 390px and 1440px mandatory; 768px recommended, as it exercises Modal's own 640px breakpoint.

**Journey A — AccessibilitySettings (#28 fix, the active deliverable).** Sign in; the "Aa" trigger is visible top-right; open it and the Modal appears titled "Reading & Accessibility Settings" with focus on the dialog container and the background dimmed; at 390px scroll `.modal-content` to the bottom and Done is fully visible and un-clipped with no horizontal scrollbar; repeat at 1440px; set Text Size to 200% via the modal's own slider and repeat at both viewports, with all five controls plus the fieldset plus Done still reachable by scrolling and nothing clipped; Tab from the first control through Text Size, the four Typography radios, Line Height, Letter Spacing, Reading Measure, to Done, each showing the 3px/2px-offset focus ring, with Tab from Done cycling back into the trap rather than escaping; Escape closes the modal and focus visibly returns to "Aa"; reopening and clicking Done does the same. **Modal stacking check (judge finding J-03-1):** while the settings modal is open, confirm the "Aa" trigger is not clickable, and confirm Tab from the last modal control does not reach it. **Control-functionality check (judge finding J-04-1, part of the #28 closure gate):** verify each control actually changes the rendered result, not merely that it is visible and reachable — Text Size changes rendered text size at at least one non-default setting; each of the four Typography radios changes the rendered typeface/style; Line Height, Letter Spacing, and Reading Measure each visibly change their respective rendered property. FAIL on any clipped or unreachable control, any horizontal scroll at 390px, any second overflow boundary inside `AccessibilitySettings`, any hit target under 44px, any skipped Tab stop, the "Aa" trigger remaining clickable while the modal is open, or any control that fails to change its rendered result.

**Journey G — forced-colors / high-contrast profile (judge finding J-05-2, adopted).** With a forced-colors or high-contrast OS/browser profile active, exercise the new Control tiers (Primary, Secondary, Caution-reversible, Caution-irreversible, Quiet, and Disabled), the new Field states, and the AccessibilitySettings popup. Confirm all five Control tiers remain distinguishable from one another by a non-colour, non-shadow means; confirm the Disabled state still reads as visibly disabled; confirm the custom range thumb in AccessibilitySettings remains visible and operable rather than vanishing.

**Journey B — admin roster Primary count.** At `/admin/students`, "Add Student" renders as the page's single ink-filled brass-shadowed Primary and the header nav is uniformly Secondary; opening "Aa" over the roster leaves "Add Student" visible behind the dimmed backdrop but not clickable.

**Journey B2 — StudentDetailView Primary count.** Open a student with two or more preserved enrollments and an available band; exactly one Primary-styled button is visible, "Assign a new band", and every "Re-assign" renders Secondary; clicking "Assign a new band" with no band selected shows it disabled per its existing gate.

**Journey C — login regression.** Signed out, exactly one enabled prominent "Sign in" and no "Aa" trigger; submitting an empty email shows an inline error under the email field with focus moving to it.

**Journey D — forced password change regression.** The full-page gate replaces the app shell with "Set password" as the sole Primary and "Sign out and come back later" as a lower-emphasis link; submitting mismatched passwords shows an inline mismatch error with focus moving to the confirm field.

**Journey E — Modal border and focus ring.** Open any app-owned Modal; the dialog container shows a visible outline in `--color-focus` (#3d5f6b) at 3px width and 2px offset rather than an invisible or browser-default ring; the modal's outer edge shows a 3px solid ink border matching every C.1/C.2/C.3 card, not the previous 1px hairline.

**Journey F — tier regressions.** Opening "Mark Email Confirmed" shows the confirm button as Caution-irreversible terracotta fill, not Primary; completing a Re-issue Access flow to its reveal phase shows exactly one Primary, "Done", with "Copy" rendering Secondary.

**FAIL condition, restated for emphasis:** any clipped or unreachable control, any horizontal scroll at 390px, any second overflow boundary inside `AccessibilitySettings`, any hit target under 44px, any skipped Tab stop, any Primary-count violation on any journey above, the "Aa" trigger remaining clickable while a modal is open, any AccessibilitySettings control that fails to change its rendered result, or any Control tier/state that is indistinguishable in the forced-colors profile in Journey G.
