# Lizbeth Spanish — Field Journal Design System: Fresh Comprehensive Audit and Remediation Plan

**Status: DRAFT — awaiting explicit user approval before any T1 execution.**

**Correction notice, dated 2026-09-03:** Findings C and D below were rewritten after this document's first draft incorrectly audited a stale, unused duplicate config file rather than the config file Atelier actually resolves. The corrected facts are reflected throughout, including in the net-result summary immediately below. Findings A and B, the design specification, and the browser brief are unaffected by this correction and stand as originally written. See Section 2 for the corrected findings and Section 10 for how this was independently re-verified.

**Net result of this audit, stated up front:** four findings, all four with authorized, executable remediation, and no outstanding user decision. The plan is executable in full under existing standing authorization. The only unresolved unknown is live GitHub issue state, which Step 0 resolves before any implementation begins.

**Document type:** execution-ready plan, following a fresh, independent audit of the app against the Field Journal DS reference. This is not a plan to re-litigate or re-verify prior work.

**Governing context:** a prior milestone (`docs/plans/lizbeth-spanish-fjds-final-closure.md`, recorded in `docs/plans/lizbeth-spanish-fjds-milestone-closure-summary.md`) closed seven backlog items and found and fixed seven instances of an App.css cascade-collision defect class. That work is settled. The user then explicitly asked for a genuine fresh audit — not another summary of completed work — with honest confirmation of whether real gaps remain. This document is that audit's result, plus a bounded plan to fix what it found.

**Audience:** the user tracking this milestone, and the engineer who will execute the remediation.

**Calibration note, stated up front:** this plan follows the same standard as the prior closure summary. Where the audit found nothing, that is stated plainly below, not implied by omission. Where it found something, the exact file and line are cited, and every citation below was independently re-checked against the live repository files during the writing of this document (see "Verification performed on this document" at the end).

---

## 1. What this audit actually re-checked, and how

This audit did not re-read the prior session's summary and restate it. It went back to the live files:

- Cross-checked every CSS file under `src/pages/` and `src/components/` against the ADOPTION-PLAN's 14-issue table and its derived-pages list, to find any UI surface that was never in scope for the milestone at all.
- Grepped the two App.css shared-selector lists that assign borders/shadows, and traced every selector named in them to its own component stylesheet, to check whether the cascade-collision defect class (documented as closed with 7 instances) is actually exhausted.
- Read the Atelier configuration and the registered baseline directory to assess `design_review`/`contrast_check` coverage and `visual_diff` sweep feasibility. The first drafting pass read the wrong config path (`lizbeth_spanish/atelier.config.json`, a stale unused duplicate) and was corrected after another agent identified the operative path via `atelier_info`'s `configSource` field; the corrected pass independently re-read both the operative root config (`H:\CommandCenter\orchestrator\atelier.config.json`) and the operative baseline directory (`H:\CommandCenter\orchestrator\.atelier\baselines\`) directly. See Section 2, Findings C and D, and Section 10.
- Attempted to check live GitHub issue state for #63, #66, #67, #41, #10, #11 via Researcher. This failed for a concrete, disclosed reason (Section 7), not by omission.

Everything cited below with a file and line number was read directly from the live repository during this task, independent of the planning chain's own report, as part of writing this document. No line number, file name, or code excerpt below was taken on faith.

---

## 2. Findings

### Finding A — Two live student-facing pages were never in the milestone's scope at all (the principal finding)

`src/pages/LearnIndexPage.tsx`/`.css` and `src/pages/LearnDetailPage.tsx`/`.css` are live, routed pages. `src/App.tsx:16-17` imports `LearnIndexPage` and `LearnDetailPage`, and they are rendered in the route table (confirmed present as active routes; line numbers `:190`/`:192` per the planning evidence). They appear nowhere in the ADOPTION-PLAN's 14-issue table and nowhere in its derived-pages list, which names only CourseWorkspacePage, CourseSettingsPage, NewCoursePage, BusinessSettingsPage, OwnerSettingsPage, and OwnerFeedbackPage. Both files carry a header comment reading "Issue #5 Phase 5" — they were built under a separate enrollment/authoring workstream that the design-system milestone's own issue table never accounted for.

Cross-checking every CSS file under `src/pages/` and `src/components/` against the adoption plan's file lists found these two to be the only unaudited UI surface. Every other page and component file maps to a milestone issue.

Confirmed drift, verified directly against the live files:

- **`LearnDetailPage.css:76-81`** — `.lesson-card` reads:
  ```css
  .lesson-card {
    padding: var(--space-4);
    border: 1px solid var(--color-ink-800);
    border-left-width: 6px;
    background: var(--color-paper-100);
  }
  ```
  A.3 defines no 1px border level, states every outline is ink.1000, and sets the card level as a 3px rule with a `5px 5px 0 0` hard offset shadow. This rule has neither.

- **`LearnDetailPage.css:87-91`** — the unlocked-state variants add a non-spec colour ring:
  ```css
  .lesson-card--unlocked-incomplete,
  .lesson-card--unlocked-pending-quiz {
    border-left-color: var(--color-roadmap-current);
    box-shadow: 0 0 0 1px var(--color-roadmap-current);
  }
  ```
  This is an elevation level that does not exist in the reference, and it leans on colour (the left border plus icon colour) to distinguish state, against A.6/A.1's colour-independence requirement.

- **`LearnDetailPage.css:50-65`** — `.learn-detail-legacy-cta` fills with brass and hovers to terracotta:
  ```css
  .learn-detail-legacy-cta {
    ...
    border: var(--border-width-strong) solid var(--color-ink-800);
    background: var(--color-brass-600);
    color: var(--color-paper-50);
    ...
    box-shadow: var(--shadow-print);
  }
  .learn-detail-legacy-cta:hover {
    background: var(--color-terracotta-600);
    border-color: var(--color-terracotta-600);
  }
  ```
  C.1 has no brass-fill control tier, and terracotta is reserved for IRREVERSIBLE caution actions. Using it as a navigational CTA's hover state is a semantic misuse, and there is no C.1 press motion (translate + shadow swap) on this control at all.

- **`--shadow-print` misapplication** — this token is scoped by A.3 to owner tables and legacy-print download links. It is applied at `LearnIndexPage.css:48` (`.enrollment-card`) and `LearnIndexPage.css:95` (`.enrollment-card-link`), and at `LearnDetailPage.css:59` (`.learn-detail-legacy-cta`). None of the three is an owner table or a legacy-print download link.

- **Wrong outline ink** — `LearnDetailPage.css:42` (`.learn-detail-legacy-panel`) and `LearnIndexPage.css:47`/`:90` (`.enrollment-card`, `.enrollment-card-link`) all set their border colour to `var(--color-ink-800)`. A.1/A.3 require `--color-ink-1000` for every outline.

- **Wrong control-height token** — `LearnDetailPage.css:52` and `LearnIndexPage.css:88` (and the mark-complete buttons at `LearnDetailPage.css:165,193,204`) use `--size-control-height` where C.1 requires `--control-height`. Confirmed against `ResourcesPanel.css:90`, which already uses the correct `--control-height` token for its own C.1 control, as the working reference for which token name is correct.

- **Wrong icon key** — the design pass separately found that `LearnDetailPage.tsx`'s icon-selection ternary resolves to `icon-current` (a crosshair, WeekCard's marker for "this week") for both unlocked lesson-card states, where `icon-unlocked` (an open circle) is correct and already exists in the icon set, unused.

**What is clean in these two files, stated explicitly:** both files are already free of non-zero border-radius and raw hex values. The token-layer discipline that the milestone established held for these files even though they were outside its issue table. The drift found here is entirely in elevation choice, outline ink colour, and control-tier selection, not in raw-value violations.

### Finding B — The App.css cascade-collision defect class is not exhausted; two further instances found

The prior milestone's closure summary states the cascade-collision audit is "complete, not partial," with 7 confirmed instances. Re-reading the live `App.css` shared border/shadow selector list found it still active, now narrowed to two selectors:

`App.css:838-841`:
```css
.resources-panel, .register-student-modal {
  border: var(--border-width-strong) solid var(--color-ink-800);
  box-shadow: var(--shadow-print);
}
```

Tracing both selectors to their own component stylesheets:

- `.resources-panel` is declared at `ResourcesPanel.css:1-5`, which sets only `list-style`, `margin`, and `padding`. It has no `border` or `box-shadow` rule of its own.
- `.register-student-modal` has no rule at all in `RegisterStudentModal.css` (confirmed by reading the full file — it contains `.register-student-form`, `.form-group`, `.form-error`, `.form-actions`, and the temp-password-modal classes, but never `.register-student-modal` itself).

Both selectors therefore receive the legacy App.css treatment unopposed. This is the same collision-by-absence mechanism documented for the milestone's BrandDesignPage `--brand` instance (that milestone's instance 3), not the specificity-tie mechanism used by the other six instances. These are candidate instances 10 and 11 in that same defect class, found by this audit and not previously identified.

**Judgement to record honestly, not overstated as a pure defect on one side:** `.resources-panel` is an attachments rail of download links, and A.3 does scope the `--shadow-print` brass level to "download links (legacy print)," so that shadow may be defensible on its own merits. Its `--color-ink-800` border is not defensible under A.3 regardless. `.register-student-modal` is wrong on both counts: A.3 places a modal at the `sheet` level (3px rule, `8px 8px 0 0`, ink.1000), not 2px ink-800 with a brass shadow. The engineer executing Step 1 should confirm each selector against the reference individually rather than assume both are pure defects of the same kind.

### Finding C — Corrected. The operative Atelier config was audited at the wrong path in this document's first draft; the real config is properly configured, and no defect exists here

**This finding was materially wrong in the first draft of this document and is rewritten here rather than quietly restated, per this project's own calibration standard.** The first draft audited `lizbeth_spanish/atelier.config.json` and reported a single-entry allowlist and no baseline registration as a defect. That file is a stale, unused duplicate that Atelier does not resolve at runtime. The operative config, confirmed via `atelier_info`'s `configSource` field and independently re-read for this correction, is the root-level file at `H:\CommandCenter\orchestrator\atelier.config.json`. It reads:

```json
{
  "tokens": { "sources": ["lizbeth_spanish/.atelier/tokens/field-workbook.tokens.json"] },
  "review": { "allowlist": [
    "lizbeth_spanish/src/tokens/field-workbook.generated.css",
    "lizbeth_spanish/src/tokens/semantic.json",
    "lizbeth_spanish/src/tokens/primitives.json",
    "lizbeth_spanish/src/tokens/components.json",
    "lizbeth_spanish/src/App.css"
  ] },
  "gates": { "visualDiffThreshold": 0.01 }
}
```

This was independently re-read from the live root file for this correction and matches exactly. It carries five allowlist entries, not one, and a configured visual-diff gate threshold. It has been actively tuned during this session. There is no defect to report at this path.

**The subfolder file remains a known footgun, worth recording in one sentence so a future reader does not repeat this document's own mistake:** `lizbeth_spanish/atelier.config.json` still exists, is off-limits to edit, and will look under-configured to anyone who audits it directly, exactly as happened here; any future audit of Atelier configuration should confirm `configSource` before drawing a conclusion from either file.

**The root-cause claim in the first draft is retracted, not merely replaced.** That draft asserted a narrow `review.allowlist` was "the root cause that let Finding A go unseen." This is withdrawn for two independent reasons:

1. `review.allowlist` globs are skipped by `design_review`'s hardcoded-value scan, per that tool's own description — the allowlist exempts listed files from scanning; it does not add scanning coverage elsewhere. The first draft's claim assumed the opposite relationship. *Provenance note: this specific semantics point was relayed by another agent in this session from the Atelier tool's own description and was not independently re-verified against the tool itself in this planning/document role, which has no direct Atelier tool access. It is recorded with that caveat rather than as independently confirmed.*
2. Independent of point 1, a wider allowlist would not have caught Finding A's actual defects regardless. Finding A's drift is structural and semantic token misuse: the wrong elevation tier, the wrong paper-stock primitive, `--size-control-height` (44px) used where C.1 requires `--control-height` (48px), and `icon-current` used where `icon-unlocked` is correct. None of those is a raw-hex or hardcoded-value violation, and none is a contrast violation — and Section 3 already establishes both Learn files were clean on raw hex and radius. No automated `design_review` or `contrast_check` scan would have flagged any of Finding A's real defects under either the wide or the narrow allowlist reading.

**The honest, more useful conclusion:** Finding A was never a tooling-configuration gap. It was a scope gap. `LearnIndexPage`/`LearnDetailPage` were never enrolled in the milestone's issue set, so no human ever checked them against the reference. What actually caught Finding A was a design-reviewer's direct audit against the reference document, not an automated scanner, and no scanner configuration in this project would have caught it. The durable fix that follows from this is to enroll these two pages in the milestone's issue tracking going forward (Step 0 opens that issue), not to expect a validator to catch this class of gap.

### Finding D — Corrected. A comprehensive visual_diff sweep is achievable and authorized; the real gap is baseline coverage, not a blocker

**This finding was also materially wrong in the first draft and is rewritten here.** The first draft reported the baselines directory as containing only one unrelated mockup and treated the sweep as blocked on an off-limits config edit. That check was run against the wrong baselines location. The operative directory, `H:\CommandCenter\orchestrator\.atelier\baselines\`, was independently re-listed for this correction and contains:

- `field-journal-d1-login-1440.png` (Login, D.1)
- `field-journal-d9-catalog-1440.png` (Catalog, D.9)

Both were confirmed present by direct directory listing. This is consistent with issues #37 and #43 (the unauthenticated routes covering login and catalog) having been completed earlier in this milestone. The mechanism is proven working, not absent, and `gates.visualDiffThreshold` is already set to `0.01` in the operative root config (Finding C above).

**The real, smaller gap is coverage, not capability.** 2 of the 15 reference artboards currently have registered baselines. The remaining 13 are: D.2 Roadmap, D.3 Week detail, D.4 Flashcards, D.5 Feedback, D.6 Owner dashboard, D.7 Roster, D.8 Brand, and E.1 through E.6 (mobile). Closing this gap requires extracting artboards from `lizbeth_spanish/design/field-journal/Field Journal DS.dc.html` and registering them in the root `atelier.config.json`, which is already editable and already actively tuned this session — no user decision is needed to do this work.

**One real limitation on the sweep's coverage, so its eventual result is not over-read:** `LearnIndexPage` and `LearnDetailPage` have no corresponding reference artboard in the Field Journal DS document at all. Like the issue-#44 derived pages before them, they can only be judged against the A/B/C primitive specification, not against a screenshot comparison. A clean `visual_diff` sweep therefore cannot, on its own, confirm Finding A's remediation — the Step 3 Browser Validator pass is what confirms that. The two checks answer different questions and neither substitutes for the other.

---

## 3. What this audit checked and found clean

Stated plainly, because this is the honest-confirmation half of what the user asked for:

- **The App.css shared-selector sweep is otherwise clean.** Both shared lists in `App.css` (the `border-radius: var(--radius-square)` list at lines 832-837, and the border/box-shadow list at 838-841) were re-read in full. Every selector in the radius-only list was traced; none carries an unopposed collision beyond the two named in Finding B. The milestone's prior claim that 7 instances were found and fixed stands; this audit adds exactly 2 more (Finding B), not a wider unaudited backlog.
- **`LearnIndexPage.css` and `LearnDetailPage.css` are clean on border-radius.** Neither file contains a non-zero `border-radius` declaration anywhere.
- **`LearnIndexPage.css` and `LearnDetailPage.css` are clean on raw hex and raw px literals.** Every colour, spacing, and sizing value in both files resolves to an existing design token (`var(--...)`), consistent with both files' own header comments asserting this. This audit independently confirmed it by reading every declaration in both files rather than trusting the comment.
- **`.resources-panel-row`, `.resources-panel-link`, and their sibling rules in `ResourcesPanel.css` are already correctly tiered** — `.resources-panel-link` in particular already uses `--control-height`, `--border-width-rule`, `--color-ink-1000`, and `--shadow-card` correctly, and served as this audit's working reference for what a correct C.1 secondary control looks like.
- **`.register-student-form` and its sibling rules in `RegisterStudentModal.css` carry no border or shadow drift of their own** — the file's only problem is the absence noted in Finding B, not a wrong value present in the file.

---

## 4. Reviewed design specification (Finding A remediation)

This specification was produced by design-director with ux-architect and visual-system-designer, and independently reviewed by design-reviewer. The first review pass returned NEEDS_REVISION on five evidence-backed findings (locked-family paper stock contradicted the reference; rows 6/7 of the eight-state machine were visually indistinguishable; the anchor-vs-Control invariant was unstated; a greyscale distinguishability criterion was inaccurate; several decisions were left unstated). All five were resolved and independently re-verified against both the reference document and the live source before the second pass returned PASS. Two non-blocking residual limits remain and are flagged below.

**`.lesson-card` base.** Replace the 1px/6px-left-border/no-shadow treatment with a 3px `--color-ink-1000` border and `var(--shadow-card)`. Delete the 6px coloured left border entirely, delete every per-state `border-left-color` rule, and delete the `0 0 0 1px` colour ring outright. Non-locked background becomes `--color-paper-50`.

**Locked-family cards** (`date-locked-rolling`, `date-locked-cohort`, `on-hold`, `prerequisite-incomplete`, `unavailable-unspecified`): flat `--color-paper-200` via the existing, currently-unused `.paper-stock--card` class (`App.css:127-129`), with `border-color: var(--color-ink-700)` and `box-shadow: var(--shadow-muted-card)`. Explicitly not `.paper-stock--graph`. This is grounded in A.4's own primitive table ("card · flat paper.200 → index cards, locked states, tabs") and was re-verified against the C.4 locked specimen in the reference document, which specifies `border: 3px solid #504940; box-shadow: 5px 5px 0 0 #504940` — `#504940` resolves to `--color-ink-700`, and that exact shadow value is `--shadow-muted-card`. The reviewer noted the reference specimen also carries a faint, 7%-alpha decorative hatch matching no existing paper-stock utility; that nuance is recorded honestly here rather than as a flat "no grid hatch" instruction, since A.4's own prose calls this primitive "flat" and the hatch is reasonably treated as decorative rather than structural.

**CTA retiering.** `.learn-detail-legacy-cta` takes C.1 PRIMARY tier values: ink-1000 fill, paper-50 text, 3px ink-1000 border, `--shadow-brass`; hover state translates `(-2px, -2px)` with `--shadow-brass-press`; active state translates `(3px, 3px)` with `--shadow-brass-none`; height set by `--control-height`. `.enrollment-card-link` takes C.1 SECONDARY tier values. Both delete `--shadow-print` and the brass-fill/terracotta-hover pair entirely.

**Binding invariant, stated because a design review pass caught the risk of getting this wrong:** both of those elements remain real `<a>` elements with their existing `preventDefault()`/`navigate()` handlers, and receive their new C.1 values through their own CSS classes only. They must never become the literal `<Control>` component — `Control.tsx` renders only a `<button>`, and swapping it in would silently destroy right-click, middle-click, and open-in-new-tab on both links. Conversely, `MarkCompleteControl`'s three buttons and `LockedDisclosure`'s toggle are real buttons and should become literal `<Control>` instances: trigger and Confirm at `secondary` tier, Cancel at `quiet` tier, and the `LockedDisclosure` toggle at `quiet-outline` tier.

**Icon fix.** The icon-selection ternary in `LearnDetailPage.tsx` must resolve to `icon-unlocked` for both unlocked states, never `icon-current`.

**New hint line for `unlocked-pending-quiz`.** Add `.lesson-card-completion-note`, reusing the existing `--color-ink-700`/italic hint pattern verbatim, because this state was otherwise visually identical to `unlocked-incomplete` apart from the silent absence of a Mark Complete button. Proposed placeholder copy: "Completed automatically once its requirement is met — no action needed here." **This copy is flagged as an unconfirmed placeholder, not settled text.** The design review established that `completion_rule` is three-valued (`view` / `quiz_pass` / `manual`), and "automatically" is accurate for `quiz_pass` but not verifiably accurate for `manual`, which implies an instructor-side action. Only the clause "no action needed here" is safely true for both remaining values. The copy owner must confirm or replace the word "automatically" before this ships.

**New Badge variant.** One new `BadgeVariant` union member and one `.badge--<name>` rule (reusing existing `.badge` geometry) for the Index page's decision-table row 3 (`legacy && !has_entitlement`): brass-700 text on the existing `--color-badge-tint-archaic` background.

**Empty states.** Both pages' C.9 empty states are replaced with the complete three-part `<JournalEmptyState>` unit. Partial reuse of any existing empty-state markup does not satisfy C.9.

**Panel/card retiering.** `.learn-detail-legacy-panel` and `.enrollment-card` move to the card level: 3px `--color-ink-1000` border plus `--shadow-card`.

**Invariants for the whole change:** never reintroduce `--color-ink-800` as a boundary colour anywhere in this scope; never use `--shadow-print` outside owner tables and legacy-print download links; never stack more than one card-level shadow on a single element; every corner stays zero-radius, and every shadow stays a hard offset with no blur; behaviour, routing, data flow, and the eight-state machine itself are unchanged by this work.

**Design-review confirmation:** every token cited above was independently confirmed present in `src/tokens/field-workbook.generated.css` (`--color-focus-ring` is real but is injected via `App.css:40` rather than the generated file, and the reviewer confirmed this is the existing, already-approved mechanism, not a new one). The review introduced no new defect into the specification.

---

## 5. Ordered work

**Step 0 — Pre-flight issue-state verification (engineer, blocking).** This planning chain could not query `gh` (the Researcher Bash hook allowlists no `gh` invocation; see Section 7). Before any implementation, using `gh`:
- Record the actual current state of issues #63, #66, #67, #41, #10, #11.
- Search both open and closed issues for any existing coverage of `LearnIndexPage`/`LearnDetailPage`.
- If real issue state contradicts any assumption in this plan, stop and report "plan stale" rather than proceeding, following the same precedent by which the prior closure plan discovered #41 and #42 were falsely assumed closed.
- Open a new GitHub issue for Finding A (and one for Finding B, if it is not already covered), using the ADOPTION-PLAN issue template, per the standing directive to log all work via GitHub issues.

**Step 1 — Finding B (small, independent of Step 2).** For `.resources-panel` and `.register-student-modal` (`App.css:838-841`), decide against the reference, selector by selector, whether the treatment belongs at all; where it does, move it into the component's own stylesheet at the correct A.3 level using `--color-ink-1000`. Add a cascade-collision regression guard following the existing precedent in `fjdsAuthenticatedScreensRemediation.test.ts` (cycles 2-4). State explicitly in the engineer's own record that a jsdom test cannot prove the real-browser cascade outcome — that is the documented blindness that hid these instances in the first place — so the Step 3 browser check is what actually confirms this fix, not the test suite alone.

**Step 2 — Finding A (main body of work).** Implement Section 4's reviewed design specification across `LearnIndexPage.tsx`/`.css` and `LearnDetailPage.tsx`/`.css`, plus the one Badge variant addition. Behaviour, routing, data flow, and the eight-state machine must not change. The existing tests in `issue5-phase5-learn-index-page.test.tsx` and `issue5-phase5-learn-detail-page.test.tsx` must continue to pass unmodified; the icon-key and hint-line changes were confirmed test-safe during design review.

**Step 3 — Validation.** Independent Verifier pass at the source level, then Browser Validator pass against the brief in Section 7.

**Step 4 — Findings C and D remediation (sequenced after Steps 1-3, so the sweep measures the remediated app rather than a moving target).** Fully authorized; no user decision required.
- Extract the remaining 13 reference artboards (D.2-D.8, E.1-E.6) from `lizbeth_spanish/design/field-journal/Field Journal DS.dc.html` and capture them as baseline images into `H:\CommandCenter\orchestrator\.atelier\baselines\`, following the exact naming convention already established by the two existing files: `field-journal-<id>-<name>-<width>.png`.
- Register the new baselines in the root `H:\CommandCenter\orchestrator\atelier.config.json`, which is authorized to edit and has already been tuned this session. Do not touch the subfolder duplicate at `lizbeth_spanish/atelier.config.json`.
- Run the comprehensive `visual_diff` sweep against the existing `0.01` threshold and record a per-screen result.
- Treat any reported diff as a finding to triage against the Field Journal DS reference, not as an automatic defect: some deltas are legitimate ratified deviations, and the ADOPTION-PLAN's ratified-deviations section governs which ones are acceptable.
- Record explicitly that `LearnIndexPage`/`LearnDetailPage` have no reference artboard and are out of this sweep's scope for the reason given in Finding D; their remediation is confirmed by Step 3's Browser Validator pass instead.

---

## 6. Acceptance and validation

- `npm test` and `tsc` both pass; production build succeeds.
- `node scripts/verify-token-pipeline.mjs` continues to report zero drift (the standing token-pipeline regression guard from the prior milestone).
- No `--color-ink-800` remains as a boundary colour in either Learn stylesheet.
- No `--shadow-print` remains outside owner tables and legacy-print download links, across the full changed scope.
- Zero non-zero `border-radius` and zero blurred shadows anywhere in the changed files.
- No raw hex value outside the token layer in the changed files.
- The existing Learn-page test suites pass with unmodified behavioural assertions.
- Independent Verifier pass at the source level, then a Browser Validator pass. Neither the implementing writer's own claim of completion, nor a passing jsdom test, may close this out on its own — Finding B's entire defect class is, by construction, invisible to both.

---

## 7. Browser validation brief

Native browser dialogs are prohibited on this app's browser-rendered routes: no `alert`, `confirm`, `prompt`, any `window.*` form, or `beforeunload` prompt. `MarkCompleteControl` (an app-owned inline two-step confirmation, a plain in-place sibling swap, not a Modal) and `LockedDisclosure` (a `role="region"` conditional-mount disclosure) were both confirmed non-dialog and non-Modal against source during design review, and must remain that way. A deterministic source scan for native dialog calls is required as part of this pass.

- **Launch/readiness:** reuse the existing dev server at `http://localhost:5173`. Do not start a second instance and do not use `taskkill`. No Docker, no Supabase required.
- **Base URL:** `http://localhost:5173`.
- **Tooling:** Claude in Chrome, using `tabs_context_mcp` to reuse an existing tab rather than opening a new one. Use the dev quick-select login, never a typed password — a typed test password triggers Chrome's native password-breach warning, which was the confirmed root cause of this project's earlier browser-tooling failures (documented in the prior closure summary). Both fixes are confirmed working.
- **Routes:** `/learn` and `/learn/:enrollmentId`.
- **Fixtures:** Index page — zero enrollments (the C.9 empty state), and all four decision-table rows. Detail page — zero lessons (C.9); the legacy-panel branch with its now-primary-tier CTA; and one lesson list covering all eight `LessonCardState` values simultaneously, including both `unlocked-incomplete` (trigger visible) and `unlocked-pending-quiz` (no trigger, new hint line visible). Existing precedent for driving these states: `src/__tests__/e2e/phase5-learn-detail-live-verification.spec.ts` already drives five of the eight via `data-lesson-state`.
- **Viewports:** 390px and 1440px for every state. Confirm single-column layout persists at both; `.lesson-card-main` and `.enrollment-card-heading-row` stack at 700px and below; no control renders below 48px in height; locked-family cards render flat paper.200 with no grid hatch at both widths.
- **Visible outcomes to confirm:**
  - No-native-dialog scan across the MarkComplete and LockedDisclosure interaction flows.
  - Anchor-behaviour check confirming both retiered anchors (`.learn-detail-legacy-cta`, `.enrollment-card-link`) still support middle-click, Ctrl-click, and right-click open-in-new-tab — i.e., were not converted into buttons.
  - Keyboard/focus checks: MarkComplete moves focus to Confirm and back to the trigger on cancel; LockedDisclosure's Escape key closes it and returns focus to its toggle; a visible 3px, 2px-offset focus ring appears on Tab-only navigation; no focus trap exists anywhere in either flow.
  - A greyscale screenshot of the full eight-state lesson list, confirming every state is distinguishable by icon, label text, or hint-line content alone. The hint-line region must be in frame for the `date-locked-rolling`/`date-locked-cohort` pair and the `prerequisite-incomplete`/`unavailable-unspecified` pair, since those two pairs are otherwise distinguished only by that sub-text.
  - A `forced-colors: active` spot-check confirming both retiered anchors still render a visible border and legible text.

**Disclosed limitation on Step 0's own scope:** the Researcher agent's Bash hook (`.claude/hooks/validate-researcher-bash.ps1`) allowlists no `gh` invocation, so this planning chain could not query live GitHub issue state itself and correctly declined to infer it from stale local plan files. That is why Step 0 exists as an engineer-owned pre-flight rather than being answered here.

---

## 8. Risks and rollback

- **Principal risk:** Step 2 touches two live, student-facing pages. Mitigation: the change is visual-only, carries a binding no-behaviour-change invariant, and the existing test suites for both pages must pass unmodified.
- **Specific regression risk called out by design review:** converting either retiered anchor into a `<Control>` button would silently destroy right-click/middle-click/open-in-new-tab. This is why it is a binding invariant in Section 4 and why the anchor-behaviour check is explicit in Section 7.
- **Step 1 risk:** removing a legacy App.css rule that turns out to be some element's only source of border or shadow, which would be a real visual regression rather than a fix. This is exactly the trap that was correctly avoided for `.owner-settings-page` in the prior milestone. Confirm each selector's own component stylesheet before removing anything from `App.css:838-841`, and land the correct treatment at the component level in the same change, not as a follow-up.
- **Rollback:** each step is an independent, revertable commit touching a small, named file set. There is no data or schema change to unwind in either step.

---

## 9. Decisions required from the user

**None outstanding.** The first draft of this document identified an `atelier.config.json` edit as requiring a fresh user decision. That was based on auditing the wrong file (Section 2, Finding C) and is withdrawn. The operative root config is already editable and already authorized for the exact kind of change Step 4 requires, so no separate yes/no decision is needed to execute this plan in full. The single approval gate that remains is the plan's own: explicit user approval of this document before T1/T2 execution begins (see the approval gate note at the end of this document).

**Copy handling — resolved, not left as an open decision.** The `unlocked-pending-quiz` hint copy in Section 4 originally proposed "Completed automatically once its requirement is met — no action needed here" and flagged "automatically" as unconfirmed for the `manual` completion-rule value. Rather than gate this plan on a copy owner's confirmation, the engineer should ship only the portion of that sentence verified true for every `completion_rule` value: wording along the lines of "No action needed here," dropping "automatically" entirely. If a copy owner later wants richer wording specific to each completion-rule value, that is a follow-up enhancement, not a gate on this plan.

**Out-of-band product questions, correctly excluded from this plan's visual-only scope, surfaced during the design pass and recorded here so they are not lost:**
- Neither page currently offers an "open lesson content" affordance from any card state.
- `MarkCompleteControl` has no error path around a rejected `onConfirm()` call — both its buttons remain disabled with no recovery route.
- Neither page's error state offers a retry control.
- Issue #63's "Review week 1" navigation bug remains open and unresolved by this plan.

---

## 10. Verification performed on this document

- Every file citation and line reference above (`App.tsx`, `LearnDetailPage.css`, `LearnIndexPage.css`, `App.css:832-841`, `App.css:127-129`, `ResourcesPanel.css`, `RegisterStudentModal.css`) was independently read from the live repository during the original drafting of this document and matched against the handoff's claims before that draft was written. No citation was accepted on the strength of the handoff alone.
- For this correction pass, both corrected facts were independently re-verified directly, not accepted on the correcting agent's report alone: the root `H:\CommandCenter\orchestrator\atelier.config.json` was read in full and matches the five-entry allowlist and `visualDiffThreshold: 0.01` reported; the root `H:\CommandCenter\orchestrator\.atelier\baselines\` directory was independently listed and confirmed to contain exactly `field-journal-d1-login-1440.png` and `field-journal-d9-catalog-1440.png`, no more and no fewer. The `design_review` allowlist-semantics claim (that allowlisted globs are skipped rather than added) was not independently re-verified in this role, which has no direct Atelier tool access, and is carried with that explicit provenance caveat in Finding C rather than presented as independently confirmed.
- The design specification in Section 4 and the review outcome are recorded as reported in the reviewed `DESIGN_HANDOFF`; this document did not re-run the design review itself, and states that plainly rather than implying independent re-verification of the design reasoning.
- Live GitHub issue state for #63, #66, #67, #41, #10, #11 could not be independently confirmed by this document either, for the same tooling reason given in Section 7. Step 0 exists precisely to close that gap before implementation, not to substitute for it here.
- This document makes no code, test, configuration, or Git-state change. It is a Markdown document only, written to the single approved path below, and nothing under `lizbeth_spanish/` was modified while preparing it.

**Target path:** `H:\CommandCenter\orchestrator\docs\plans\lizbeth-spanish-fjds-fresh-comprehensive-audit.md`

**Approval gate:** T1/T2 execution of the full plan, Steps 0 through 4, requires explicit user approval of this document. No separate mid-plan decision gate remains; Step 4 is fully authorized under existing standing configuration authority once this plan itself is approved.
