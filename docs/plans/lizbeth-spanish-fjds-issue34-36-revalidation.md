# Lizbeth Spanish — Re-validate Issues #34, #35, #36 (Field Journal Design System Component Fidelity) Against the Shipped Screens

**Status: APPROVED — via the user's standing forward authorization, for this specific plan, in this session. Dated 2026-09-02; approval recorded 2026-09-03.** See "Approval basis" immediately below for the basis and provenance of this status.

## Approval basis

This plan is routed to execution under the user's standing forward authorization recorded in `docs/plans/lizbeth-spanish-fjds-issue31-33-revalidation.md` Section 16 ("Additional forward authorization granted by the same reply, scoped beyond this plan"). That authorization covers backlog items 3-7 of the roadmap in `docs/plans/lizbeth-spanish-fjds-token-pipeline-reconciliation.md`, of which this plan is backlog item 5 (component fidelity, issues #34-#36). Its two conditions were both satisfied for this specific plan in this session: (1) the orchestrator presented the compact plan summary to the user before execution began — headline: #34 and #35 are conformant and reclosed on evidence; #36 has three confirmed cascade-collision defects (`.week-card`, `.flashcards-viewer`, `.lesson-content-view`, all losing to a legacy App.css list), meaning §C.4's current-week/locked-week visual differentiation is currently invisible in the real browser, and `.week-card` is fixed here rather than deferred because it is within #36's own scope; and (2) no user objection was raised in response to that summary. Per Section 16's terms, the standing authorization therefore waives only the requirement for a separate affirmative "approved" reply after the summary; it does not waive the summary presentation itself, which occurred.

This is an orchestrator-applied standing authorization extended to this specific plan and this specific session, not a fresh per-plan "approved" reply from the user. Scribe has not independently observed the underlying user statements or the summary presentation and records this exactly as that provenance discipline requires: as an inference relayed by the orchestrator, applied here as the operative approval record for this document, not as a Scribe-verified transcript of the user's words.

- **Scope of this authorization.** Approval of this document authorizes only the #34/#35/#36 revalidation scope described below (backlog item 5 of the Field Journal Design System revalidation sequence). It does **not** authorize the remaining #66 instances (`.feedback-form`, `.admin-students-roster`, `.admin-students-detail`) or issue #67 (the forced-colors gap on sibling owner screens). Those remain deferred, as recorded in "Scope" and "Assumptions and decisions" below.
- **Engineering mode:** standard. **Team authorization:** not applicable. **Downstream owner:** `engineering-fleet`.
- **`PLAN_DUCK` checkpoint:** not run, by deliberate skip — see "Judge route" below for the stated reason.
- **Date:** plan drafted 2026-09-02; approval recorded 2026-09-03.
- **T1/T2 execution may now proceed** per the "Ordered work" section below, subject to its own sequencing (including the required Phase 0 pre-flight gate and the Phase 4 Verifier pass before any issue close).

---

Plan ID: `lizbeth-spanish-fjds-issue34-36-revalidation`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: `engineering-fleet`
Design route: compact (`design-generalist`, `design-reviewer`; prototype forbidden; model tier Sonnet; existing-system mode: conform)

## Outcome and audience

This is a **validation-and-remediation plan, not a rebuild.** It re-validates GitHub issues #34, #35, and #36 — Field Journal Design System component fidelity, backlog item 5 of the revalidation sequence — against the components as actually shipped.

The headline result: **#34 and #35 are conformant and are reclosed on evidence with no code change.** **#36 has three confirmed CSS cascade-collision defects**, all sharing one mechanism, that currently make issue #36's own C.4 week-card state geometry invisible in the real browser. This plan remediates all three by removing three selectors from one shared App.css rule, extends the existing regression-guard test to cover them, and validates the restoration in a real browser.

Audience: the T1/T2 engineer implementing the remediation, then Verifier and Browser Validator gating it.

## Scope

**In scope:**

1. Remove exactly three class selectors — `.week-card`, `.lesson-content-view`, `.flashcards-viewer` — from the App.css border/box-shadow rule at `src/App.css:782-787`. This is the **only** App.css edit authorized by this plan.
2. Extend the existing cascade-collision regression guard in `src/__tests__/fjdsAuthenticatedScreensRemediation.test.ts` (reuse its existing `findAppCssBorderShadowCollisions` helper and the guard pattern at lines 124-140) to cover these three selectors, exactly as `.band-roadmap` and `.lesson-content-chunk` are already covered from the two prior remediation cycles.
3. Evidence-based verification-and-reclose of #34 and #35. No code change is required for either — see "Verified repository findings" below.
4. Browser validation of the restored C.4 states.

**Non-goals (binding — a writer must return `JOB_BLOCKED` rather than exceed these):**

- Do **not** remove any other selector from either App.css list. Explicitly out of scope and must remain in the border/box-shadow list at `:782-787`: `.feedback-form`, `.resources-panel`, `.admin-students-detail`, `.admin-students-roster`, `.register-student-modal`, `.modal`, `.forced-password-change-gate .gate-content`, `.owner-settings-form`.
- Do **not** prune the radius-only list at `src/App.css:776-781`. This was a genuinely open question during design review: the handoff's original "optional hygiene" phrasing conflicted with the do-not-remove list above, because `.modal`, `.forced-password-change-gate .gate-content`, and `.owner-settings-form` exist **only** in that radius-only list and would be orphaned by touching it. Resolution adopted by design review: leave `src/App.css:776-781` entirely untouched; edit only `:782-787`.
- No new tokens. No edits to `src/tokens/field-workbook.generated.css`, `.atelier/tokens/`, or `lizbeth_spanish/atelier.config.json`.
- No changes to `journal-devices.css` or the index-card trim classes.
- No Docker or Supabase work. Never `taskkill`.
- Issue #67 (forced-colors gap on sibling owner screens) stays deferred.

## Verified repository findings

Issue-to-section mapping confirmed from `lizbeth_spanish/design/field-journal/ADOPTION-PLAN.md` (offset N+30): #34 = adoption issue 4 = §B journal devices + §C.9 empty state. #35 = adoption issue 5 = §C.1 controls, §C.2 fields, §C.3 marks & stamps. #36 = adoption issue 6 = §C.4 week card, §C.5 four-chunk anatomy, §C.6 segment ledger, §C.7 owner ledger row, §C.8 metric plate. Verbatim acceptance criteria at `ADOPTION-PLAN.md:239-290`.

### #34 — conformant; reclose, no code change

All nine §B section devices ship: `src/components/journal/` contains `ClipRing`, `Folio`, `Stamp`, `TabStack` as components, plus `journal-devices.css` providing `.journal-tape` (line 21), `.journal-staple` (44), `.journal-index-card-frame` (67), `.journal-index-card-trim` (73), `.journal-deckle-host` (106), `.journal-deckle-edge` (110), `.journal-dot-matrix` (125). §C.9 ships as `JournalEmptyState.tsx`/`.css`.

**Critical cross-check result:** every class in the `.journal-*` namespace was grepped against every legacy shared selector list in `src/App.css`. Zero collisions. `.journal-empty-state` correctly consumes App.css-owned `.paper-stock--graph` as a deliberate, documented reuse, not a collision.

### #35 — conformant; reclose, no code change

`src/components/ui/` ships `Control.css` (`.control` plus five tier modifiers), `Field.css` (`.field`, `__label`, `__control`, `__error`, `__counter`), `Badge.css` (`.badge` plus six modifiers), `AccountStatusPill.css` (`.account-pill` plus three state modifiers).

**Critical cross-check result:** each of `.control`, `.field`, `.badge`, `.account-pill` is defined in exactly one file repo-wide. Zero cascade collisions, and none appears in any App.css legacy list.

**Sub-finding 3a — investigated, not a defect.** `.status-badge` survives at `src/pages/AdminStudentsPage.css:72` with a legacy `border: 1px solid`, and is still rendered at `AdminStudentsPage.tsx:643, 647, 703, 714, 748`. This is **not** a §C.3 violation: §C.3's three account states (Active, Pending first login, Disabled) were correctly migrated to `AccountStatusPill` (imported at `AdminStudentsPage.tsx:36`, rendered at `:458` and `:596`, guarded by `AdminStudentsPage-issue42-screenComposition.test.tsx:276`). The surviving `.status-badge` uses carry different semantics (email confirmed, password-reset-required, enrollment status) outside §C.3's vocabulary. Recorded as verified-not-a-defect so a later pass does not re-open it.

**Sub-finding 3b — cleanup opportunity, not authorized here.** `.register-student-modal` appears in both App.css lists but is defined in no CSS file and rendered in no `.tsx` file. It is dead CSS. Logged as a tracked follow-up only, not remediated by this plan.

### #36 — three confirmed cascade-collision defects

This is the fourth and fifth confirmed instance of the systemic bug pattern previously fixed for `.band-roadmap` (cycle 1) and `.lesson-content-chunk` (cycle 2). Mechanism, independently re-verified: `src/App.css:782-787` applies `border: var(--border-width-strong) solid var(--color-ink-800); box-shadow: var(--shadow-print);` to a comma list of single-class selectors. These tie the components' own single-class rules at specificity (0,0,1,0), and App.css is injected later in `App.tsx`'s module graph — proven by the existing test `src/__tests__/fjdsAuthenticatedScreensRemediation.test.ts:133-140`, which asserts the `WeekDetailPage` import precedes the `./App.css` import. App.css therefore silently wins.

Token values making the drift concrete (`src/tokens/field-workbook.generated.css:38, 39, 56, 58, 127, 131`): `--border-width-rule: 3px` vs. `--border-width-strong: 2px`; `--color-ink-1000: #1a1512` vs. `--color-ink-800: #3d3530`; `--shadow-card: 5px 5px 0 0 #1a1512` vs. `--shadow-print: .3rem .3rem 0rem 0rem #a07e48` (an amber/brass tint).

**Defect 4a (HIGH) — `.week-card`, override variant.** `src/components/WeekCard.css:9-19` declares `border-width: var(--border-width-rule)` (3px), `border-color: var(--color-ink-1000)`, `box-shadow: var(--shadow-card)`. All three are currently overridden to 2px / ink-800 / brass-print. This violates `ADOPTION-PLAN.md` §A.3's non-negotiable "3px rule" and §A.6.

More significantly: `.week-card--current { box-shadow: var(--shadow-brass) }` (`WeekCard.css:117-119`) and `.week-card--locked { border-color: var(--color-ink-700); box-shadow: var(--shadow-muted-card) }` (`WeekCard.css:150-158`) are also single-class selectors and also lose, so §C.4's current-week and locked-week **geometric** state differentiation is currently invisible in the real browser. State icon and word-label colors survive (they are descendant selectors at higher specificity), which is why prior browser validation passed the "icon + word" criterion and this defect went unnoticed. Verified: no other file in the repository declares a competing border/box-shadow on the bare `.week-card` selector, so removal cleanly restores `WeekCard.css`'s own rules.

This is one of the four known-but-unfixed instances tracked against the repository's #66 cascade-collision backlog item. It **is** within #36's own scope (`ADOPTION-PLAN.md` §C.4 = adoption issue 6 = GitHub #36), so it is fixed here rather than deferred further. Fixing it closes the `.week-card` portion of that shared defect family; `.feedback-form`, `.admin-students-roster`, and `.admin-students-detail` remain open under #66 because they belong to sibling screen issues, not to #34-36. This plan describes the relationship as membership in "the same defect family as the repository's tracked #66 backlog item," not as a verbatim, pre-existing 1:1 tracking record — no such record text exists in the repository.

**Defect 4b (MEDIUM) — `.flashcards-viewer`, absence variant.** `src/components/FlashcardsViewer.css:15-20` declares no border and no box-shadow; its entire box treatment currently comes from the buggy App.css rule. Issue #36 explicitly scopes "FlashcardsViewer badge-primitive adoption and geometry consistency."

**Defect 4c (LOW) — `.lesson-content-view`, unintended-imposition variant.** `src/components/LessonContentView.css:47-51` declares only `max-width: var(--measure, 65ch)`. Its own file header (lines 16-24, an issue-#39 D1 design-review correction) documents it as a transparent wrapper carrying no background anywhere in its ancestor chain, with card treatment belonging to the four nested `.lesson-content-chunk` boxes (already correct at `LessonContentView.css:75-99`). App.css is therefore imposing an unintended 2px brass box around the whole lesson, nesting a box around boxes.

## Research evidence and its limits

None. No external or current-facts question arose; every finding above is grounded in local repository source, read and cross-checked during this planning pass.

## Design route and handoff

```
DESIGN_ROUTE
profile: compact
reasons: three bounded cascade-collision removals on existing components; target values already fixed by shipped component CSS and ratified tokens; no new screen, flow, or multi-state component
agents_required: design-generalist, design-reviewer
prototype: forbidden
model_tier: sonnet
existing_system_mode: conform
END_DESIGN_ROUTE
```

`design-generalist` (Sonnet, compact profile, existing-system conform mode) resolved the two genuinely open visual decisions:

**D-A — `.flashcards-viewer`.** Resolved to option (ii): remain a chrome-only tray. `background-color: var(--color-paper-200)` only, no border, no box-shadow, no new CSS required. Rationale: the card object already exists one level deeper — `.flashcards-viewer-card` carries `journal-index-card-trim` (`FlashcardsViewer.tsx:150`), which supplies border and shadow, sanctioned-overridden to `--shadow-brass-press` per the binding comment at `FlashcardsViewer.css:113-120`. Outer is the tray (paper-200), inner is the card face (paper-50), per `FlashcardsViewer.css:1-13`. Boxing the tray would nest a border around an already-bordered card. Removing the buggy box restores the shipped two-layer index-card device; it is a restoration, not a loss.

**D-B — `.lesson-content-view`.** Resolved to option (i): a pure transparent max-width wrapper, no border, no shadow, no background, no new CSS required. Rationale: honors the evidence-backed issue-#39 D1 authorial record and avoids box-in-box nesting in the reading sheet.

**§C.4 confirmation.** Removal alone restores the correct, already-design-reviewed values on `.week-card` and its modifiers. No new CSS is required for `.week-card` either. All three fixes are pure subtraction from `src/App.css:782-787`.

## Design review

`DESIGN_REVIEW_RESULT: PASS` from an independent `design-reviewer`, which re-read every cited file and line against the live repository and confirmed all core claims, including that no other rule intervenes on `.week-card`, and that D-A and D-B are conformant corrections rather than regressions.

Four low-severity advisory findings were returned and are adopted into this plan:

1. **Locked-state contrast disclosure.** Restoring `.week-card--locked`'s `--color-ink-700` border against the locked card's `.paper-stock--graph` background (`#faf8f4`) moves the border contrast from approximately 11.3:1 (current buggy ink-800) to approximately 8.36:1 (restored ink-700). This is a real decrease and is disclosed rather than hidden behind the ink-1000-vs-ink-800 comparison. It remains far above both the 3:1 non-text/UI floor and the ratified 4.5:1 AA text floor, so it is compliant and accepted.
2. **Radius-list ambiguity.** Resolved in favor of not touching `src/App.css:776-781` at all — already reflected in "Scope" above.
3. **#66 phrasing.** Softened to "the same defect family as the repository's tracked #66 backlog item" — already reflected in Defect 4a above.
4. **Test citation precision.** Two test citation ranges in the design packet were loose; the load-bearing assertions are nonetheless inside the cited ranges. Recorded as a documentation-precision item only, not a substantive finding.

**Reviewer's stated limits, recorded verbatim in effect:** the reviewer did not run the test suite or render the app in a browser, so the Browser Validator gate remains required. `.resources-panel` was not assessed by the reviewer because it is out of scope — it belongs to the #37/#43 sibling-screen work, not to #34-36.

## Judge route

`PLAN_DUCK` not run, by deliberate skip. Reason: blast radius is three selector removals plus one test extension, with no data-model, API, auth, or behavior change; the remediation pattern is already twice-established and mechanically test-guarded in this repository (`.band-roadmap` cycle 1, `.lesson-content-chunk` cycle 2). Deterministic failures always dominate any judge finding. This is recorded per `docs/JUDGE-CONTRACT.md` as a deliberate skip with its reason, not a silent omission.

## Ordered work

Owner: T1 engineer, escalating to T2 on two counted gate failures.

1. **Phase 0 — empirical pre-flight (T1, blocking, no edits).** Do not take the cascade-order claim on faith from the code comment. With the dev server already running at `http://localhost:5173`, confirm in a real browser via `getComputedStyle` on a rendered `.week-card` that `border-width` currently computes to 2px and `box-shadow` currently resolves to the brass `--shadow-print` value, not 3px/`--shadow-card`. Capture this as the before-evidence. **If the observed values are already 3px/shadow-card, stop and return `JOB_BLOCKED` with `Plan stale`** — the premise of Phase 1 would be false. This condition is binding and must not be softened or skipped.
2. **Phase 1 — remove the three selectors (T1).** Delete exactly `.week-card`, `.lesson-content-view`, and `.flashcards-viewer` from the selector list at `src/App.css:782-787`, leaving the remaining five selectors and the entire `:776-781` radius-only rule byte-for-byte unchanged. Update the adjacent explanatory comment block (`App.css:764-775`) to record this third remediation cycle in the same voice as cycles 1 and 2.
3. **Phase 2 — extend the regression guard (T1).** Extend `src/__tests__/fjdsAuthenticatedScreensRemediation.test.ts` with three CASCADE-COLLISION REGRESSION GUARD cases, one per selector, reusing the existing `findAppCssBorderShadowCollisions(appCss, className)` helper and asserting an empty result. Add a positive-assertion companion confirming `WeekCard.css` still declares `--border-width-rule`, `--color-ink-1000`, `--shadow-card` on `.week-card`; `--shadow-brass` on `.week-card--current`; and `--color-ink-700` plus `--shadow-muted-card` on `.week-card--locked`.
4. **Phase 3 — full suite (T1).** Run the full test suite. All pre-existing tests must pass unmodified, in particular `BandRoadmap.test.tsx`, `FlashcardsViewer.test.tsx`, `journalDevicesRemovalTest.test.tsx`, `designSystemConsistency.test.ts`, and the existing cycle-1/cycle-2 guards.
5. **Phase 4 — independent Verifier pass (read-only).** Re-run the suite, audit the diff against this plan's scope, and confirm no selector outside the authorized three was removed and that `src/App.css:776-781` is untouched.
6. **Phase 5 — Browser Validator pass**, after Verifier passes, per the brief below.
7. **Phase 6 — log outcomes via `gh` (T1),** per standing directive: comment the evidence on issues #34, #35 (verified-conformant, reclose) and #36 (remediated); update issue #66 to record that the `.week-card` instance is now closed while `.feedback-form`, `.admin-students-roster`, and `.admin-students-detail` remain open.

## Interfaces and data

None. No component API, prop contract, type, route, data model, or database surface change. The change is three CSS selector deletions plus test additions.

## Acceptance and validation

- `.week-card` computed `border-width` is 3px, `border-color` resolves to `#1a1512`, `box-shadow` resolves to `5px 5px 0 0 #1a1512` in a real browser render.
- A current week renders `--shadow-brass`; a locked week renders `--shadow-muted-card` with an ink-700 border; the two are visually distinguishable from each other and from a completed week by geometry, not hue alone.
- The flashcards tray renders flat paper-200 with no border and no shadow, while the flashcard face retains its own border plus brass-press shadow.
- The lesson reading wrapper renders no box, while each of the four `.lesson-content-chunk` boxes retains its 3px ink-1000 border and `--shadow-card`.
- Zero border-radius everywhere (non-negotiable) is preserved.
- Full test suite green; three new regression guards present and passing.
- No native browser dialogs introduced or present on any touched surface.
- Independent Verifier pass, then Browser Validator pass. T1 cannot self-approve.

## Risks and rollback

| ID | Severity | Risk | Mitigation |
|----|----------|------|------------|
| R1 | Medium | Removing a selector from a shared list could strip geometry from a surface that silently depended on it | Mitigated by the design review's per-selector regression assessment (both D-A and D-B confirmed as restorations, not losses) and by the Phase 3 full-suite gate |
| R2 | Low | The locked-state border contrast decrease disclosed above | Accepted, compliant, documented in "Design review" finding 1 |
| R3 | Medium | An unrelated surface in the remaining five-selector list is disturbed by an over-broad edit | Mitigated by Phase 4's explicit byte-level diff audit |
| R4 | Low | The cascade-order premise (App.css wins) is stale or was already fixed elsewhere | Mitigated by the binding Phase 0 empirical pre-flight, which self-blocks the plan if the premise is false |

**Rollback.** Revert the single App.css hunk and the test additions. The change is self-contained, additive-in-tests, and touches no data, no migration, and no user state, so rollback is immediate and total.

## Assumptions and decisions

- **Assumption to be empirically discharged, not assumed on faith:** that App.css currently wins the cascade in the real browser. Phase 0 blocks the plan if this proves false.
- **Decision:** `.week-card` is fixed now rather than deferred to #66, because §C.4 is squarely inside #36's own scope.
- **Decision:** #34 and #35 require no code change and are reclosed on evidence.
- **Approval:** approved via the user's recorded standing forward authorization for this established backlog sequence (`docs/plans/lizbeth-spanish-fjds-issue31-33-revalidation.md` Section 16), applied to this specific plan in this session (2026-09-03) after the orchestrator presented the compact plan summary and no objection was raised. No fresh per-plan "approved" reply was solicited or required under Section 16's terms. This provenance is labeled honestly as an orchestrator-applied inference under standing forward authorization, not a Scribe-verified transcript of a fresh per-document user reply.

## Required approvals

This plan's routing to execution is recorded in "Approval basis" at the top of this document: approved via the user's standing forward authorization, applied to this specific plan, in this session (2026-09-03). That record, not this section, is the operative approval statement, and it covers only the #34/#35/#36 scope defined above — not the remaining #66 instances or issue #67. If the standing forward authorization is later withdrawn or found not to cover this issue, this plan reverts to requiring explicit per-document user approval before further T1/T2 work proceeds.

## Browser UI dialog policy

Required — this is browser-rendered UI. No `alert`, `confirm`, `prompt`, any `window.*` variant, or `beforeunload` may be introduced. A deterministic source scan for these must run over the diff. This plan introduces no dialogs, modals, or new interactive controls, so no new modal keyboard/focus surface is created; the existing `Modal.tsx` focus-trap test files must nonetheless pass unmodified.

## Browser UI validation

**Launch/readiness:** reuse the dev server already running at `http://localhost:5173` per standing directive. Do not start a second server. Never `taskkill`.

**Base URL:** `http://localhost:5173`

**Fixture/reset:** a student session enrolled in a course band containing at least one completed week, one current week, and one locked week simultaneously; a week-detail lesson page rendering all four `.lesson-content-chunk` blocks; a flashcards deck with two or more cards. Do not touch Docker or Supabase to obtain this — use the existing local data.

**Viewport profiles:** 1440px desktop and 390px mobile.

**Journeys:**

1. **Roadmap week list.** Assert 3px ink-1000 borders with `--shadow-card` on the default state, brass shadow on the current week, muted shadow plus ink-700 border on the locked week, and confirm each state still carries its icon and word label.
2. **Week-detail lesson.** Assert no box around the lesson wrapper and an intact 3px card box on each of the four chunks.
3. **Flashcards.** Assert a borderless flat paper-200 tray with the card face retaining its border and brass-press shadow.
4. **Forced-colors emulation on the roadmap.** Assert `ButtonText` borders and no box-shadow on `.week-card` and its modifiers, per `WeekCard.css:189-201`.
5. **A no-native-dialog check** across every journey.

**Visible outcomes:** a before/after screenshot pair for Journey 1 specifically, since the current-vs-locked geometric differentiation is the defect's most user-visible symptom, plus one screenshot per remaining journey at both viewports.

**Known tooling risk, recorded explicitly.** The interactive claude-in-chrome browser tool disconnected mid-session during backlog item 4 and required a fresh-tab retry. The Browser Validator must allow exactly one fresh-tab retry on disconnection before falling back to deterministic source-level and computed-style evidence, matching the fallback pattern already used successfully once this session. A tool disconnection is not a validation failure and must not be reported as one.
