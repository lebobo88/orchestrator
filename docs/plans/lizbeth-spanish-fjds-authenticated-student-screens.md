# Lizbeth Spanish — Field Journal Design System: Authenticated Student Screens Remediation and Validation (#38, #39, #40)

**Status:** APPROVED under forward authorization. See Section 18 for the full approval record.

**Plan ID:** `lizbeth-spanish-fjds-authenticated-student-screens`

**Backlog position and a corrected premise.** This is backlog item 3 of the roadmap in `docs/plans/lizbeth-spanish-fjds-token-pipeline-reconciliation.md`. Items 1 (#61 pipeline reconciliation) and 2 (#31/#32/#33 re-validation) are both complete and closed. The backlog described item 3 as an authenticated-route visual VALIDATION sweep. Planning found that premise is wrong in a material way and this plan states so plainly: design analysis surfaced **seven confirmed conformance defects** against the reference in screens the coverage map already records as "validated." Every one is token-clean CSS — correct custom properties, every radius resolving to `var(--radius-square)` — which is exactly why the static token checks that passed previously could not see them. This backlog item is therefore **remediation plus validation, not re-confirmation**. The prior "validated" status in `H:\CommandCenter\orchestrator\docs\plans\lizbeth-spanish-design-reference-coverage-map.md` (rows for #38, #39, #40) should be read as token-layer validation only.

**Target repository:** `H:\CommandCenter\orchestrator\lizbeth_spanish` (separate git repo; GitHub remote `lebobo88/lizbeth-spanish`).

---

## 1. Outcome and audience

The three authenticated student-facing Field Journal DS screens — GitHub issues **#38** (Roadmap, reference artboards D.2 + E.2), **#39** (Week detail: reading sheet + attachments rail, D.3 + E.3), and **#40** (Flashcards, D.4 + E.4) — are brought into confirmed conformance with the authored reference and validated as rendered, against a real logged-in browser session, now that the token pipeline underneath them is proven correct.

**Audience:** the T1/T2 engineer executing this plan, the Verifier and Browser Validator who independently gate it, and the user tracking Field Journal DS completion across #31-#44.

---

## 2. Scope and non-goals

### In scope

1. Remediate defects 1-6 of the seven confirmed conformance defects listed in Section 4, all token-only fixes. Defect 7 (Roadmap jump-list rail/tab-bar) is flagged, not remediated, per Decision (b).
2. Run a real authenticated Browser Validator pass over both viewports covering the journeys in Section 13.
3. Open and close one GitHub tracking issue per the standing convention.

### Right-sizing rationale

#41 (Feedback) and #42 (Owner dashboard/Roster) were deliberately excluded and follow as a **separate plan**. They need an owner session and a different journey, and with seven defects surfaced in the first three screens, folding all five into one unit would exceed reviewable scope. The original `PLAN_JOB` explicitly permitted this split.

### Non-goals

- No work on #41/#42.
- No work on #37/#43 (backlog item 4) or #34/#35/#36 (backlog item 5) or #44 (backlog item 6).
- No backlog closure (backlog item 7).
- No new token name, palette entry, type size, radius, shadow, or motion value.
- No adoption of the four C.5 pastel chunk fills (see Decision (a), Section 11).
- No building of the reference's D.2 rail or E.2 bottom tab bar (see Decision (b), Section 11).
- No change to `lizbeth_spanish\atelier.config.json`. Only the root `H:\CommandCenter\orchestrator\atelier.config.json` is ever editable.
- No Docker, Supabase, dev-server, or seed-data change, and no reseeding.
- No `taskkill` at any point (documented history of collateral damage in this environment).
- No re-litigation of the ratified 26px margin hand or the WCAG AA 4.5:1 contrast gate.

---

## 3. Evidence method and a stated limit

All findings below were confirmed by direct file evidence against current repository contents, independently confirmed by design review. `gh` was not available on the planning tool surface, so the live bodies of #38, #39, and #40 were not re-fetched during planning; `ADOPTION-PLAN.md` plus the per-issue plan documents were used as the specification of record instead, consistent with the same limit recorded in the sibling #31-33 re-validation plan. Ordered-work Step 0 requires the executing engineer to fetch and re-check the live issue bodies before any edit is made, specifically to mitigate this limit.

---

## 4. Repository findings — the seven confirmed conformance defects

All seven are token-clean CSS: correct custom properties, correct radius resolution, and therefore invisible to the static token checks that previously passed. Each was independently confirmed by design review against current file contents.

**Defect 1 — C.5 chunk geometry.** `src/components/LessonContentView.css:75-90`. `.lesson-content-chunk` uses `border-left: 4px solid var(--color-ink-700)` (wrong width, wrong side, wrong color) and **no** `box-shadow` at all. The reference (`design/field-journal/Field Journal DS.dc.html` lines 477-499 for the C.5 specimen and 820-840 for the D.3 live screen) shows every chunk box with an identical 3px solid `#1a1512` border on **all four sides** plus a `5px 5px 0 0 #1a1512` hard shadow — A.3's `card` rule (`ADOPTION-PLAN.md:70`) verbatim.

Fix: `.lesson-content-chunk { border: var(--border-width-rule) solid var(--color-ink-1000); box-shadow: var(--shadow-card); }`, removing the four per-type `border-left` overrides at lines 111-113 (`--rule`), 115-117 (`--example`), 172-174 (`--translation`), 188-190 (`--dialect`).

**Critical exclusion — do not touch.** `.lesson-content-chunk--ruled` at lines 176-186 (`border-bottom: 2px dashed var(--color-rule-tint-slate)` plus its repeating-line background) is a **correct, artboard-matching ruled writing area** under the translation task, confirmed against `Field Journal DS.dc.html:490,833`. It is unrelated to this defect and must NOT be touched, removed, or altered. An earlier draft of this fix cited the wrong ranges and would have deleted it; design review caught that.

**Defect 2 — most severe site: ResourcesPanel bypasses the shared Control component.** `src/components/ResourcesPanel.css:76-94`, lines 84 and 113. `.resources-panel-action`/`.resources-panel-link` (2px `brass-600`) and `.resources-panel-retry` (2px `ink-700`) bypass the shared `Control` component entirely, violating C.1 (`ADOPTION-PLAN.md:121,239-241`) on four axes at once: 2px not 3px, tinted not rule-black, no `box-shadow` at all, 44px not 48px min-height. A real shared `src/components/ui/Control.tsx`/`Control.css` exists that these bypass.

The prescribed fix is **hybrid**, not a single blanket substitution, because `src/components/ResourcesPanel.tsx` renders three distinct elements that are not the same kind of element:

- Line 83: `<button type="button" onClick={handleFetch} className="resources-panel-action">` — a real button.
- Line 110: `<button type="button" onClick={handleFetch} className="resources-panel-retry">` — a real button.
- Lines 95-102: `<a href={state.url} target="_blank" rel="noopener noreferrer" className="resources-panel-link">` — an anchor, not a button.

`src/components/ui/Control.tsx:46-58` renders a `<button>` element only and accepts no `href`, so the anchor cannot become a `<Control>` without destroying its link semantics (new-tab navigation to a signed URL). Prescribed approach:

- Convert the two real buttons (TSX lines 83-85 and 110-112) to the shared component: `<Control tier="secondary" onClick={handleFetch}>{actionLabel}</Control>` and `<Control tier="secondary" onClick={handleFetch}>Retry</Control>`, importing `Control` from `./ui/Control`. Tier is `secondary`, not `primary`, because C.1 permits exactly one Primary per view and the attachments rail renders one action button per resource row; `secondary` is also the documented default tier (`Control.tsx:47`).
- For the anchor, keep the `<a>` and bring `.resources-panel-link` to C.1 geometry in CSS, matching `.control--secondary` (`Control.css:9-24,50-55`): `min-height: var(--control-height)`, `border-width: var(--border-width-rule)`, `border-color: var(--color-ink-1000)`, `border-radius: var(--radius-square)`, `background: var(--color-paper-100)`, `color: var(--color-ink-1000)`, `box-shadow: var(--shadow-card)`.
- Delete the now-unused `.resources-panel-action` and `.resources-panel-retry` rules at `ResourcesPanel.css:76-100` and `106-126`, and remove `.resources-panel-action`/`.resources-panel-link` from the shared selector list at lines 76-77 and the hover rule at 96-100, leaving `.resources-panel-link` with its own complete rule. Keep the existing `:visited` colour rule (line 102-104) valid against the new paper-fill treatment: `color` must become `var(--color-ink-1000)`, not `var(--color-paper-50)`, or the visited link will render paper-on-paper and become invisible. This visited-colour correction is a required part of the fix, not optional cleanup.
- The declarations being replaced are: 2px `var(--color-brass-600)` border with `brass-600` background and `paper-50` text at lines 84-87, 2px `var(--color-ink-700)` border at line 113, `min-height: 44px` at lines 82 and 111, and no `box-shadow` on any of the three. The existing comment at `ResourcesPanel.css:66-75` documents the current treatment as a deliberate earlier "J-004 fix," so an engineer will encounter a rationale comment that this plan supersedes; that comment block must be updated or removed rather than left contradicting the new code.

**Defect 3 — ResourcesPanel row border.** `src/components/ResourcesPanel.css:12-20`. `.resources-panel-row` uses `border: 1px solid var(--color-paper-200)`. A.3 (`ADOPTION-PLAN.md:69`) assigns list rows to `rule.thin` = 2px `ink.1000`. Off-scale width and wrong color. Fix: `border: var(--border-width-thin) solid var(--color-ink-1000)`; `--border-width-thin: 2px` already exists at `field-workbook.generated.css:40`, so this mints nothing new.

**Defect 4 — Flashcards nav button border.** `src/components/FlashcardsViewer.css:263-280`, border at line 270. `.flashcards-viewer-nav-button` uses 2px where C.1 mandates 3px. Color, `shadow.card`, and 48px height are already correct; single-property fix.

Exact before/after, at `src/components/FlashcardsViewer.css:270`:

- Before: `border: 2px solid var(--color-ink-1000);`
- After: `border: var(--border-width-rule) solid var(--color-ink-1000);`

This is the only change to that rule. Verified already correct and NOT to be touched in the same block: `min-height: var(--control-height, 48px)` (line 268), `border-radius: var(--radius-square)` (271), `box-shadow: var(--shadow-card)` (274), and the focus ring at lines 282-285.

**Defect 5 — BandRoadmap sheet border color.** `src/components/BandRoadmap.css:1-12`. `.band-roadmap` self-identifies in its own comment as implementing A.3's `sheet` rule and has the correct 3px width and `shadow.sheet`, but borders `var(--color-ink-800)` instead of `ink.1000`. A.3 mandates rule-black for every outline, no exceptions. One-line token fix, visible on every band section of the Roadmap screen at both viewports.

Exact before/after, at `src/components/BandRoadmap.css:7`:

- Before: `border: var(--border-width-rule) solid var(--color-ink-800);`
- After: `border: var(--border-width-rule) solid var(--color-ink-1000);`

Only the colour token changes; width is already correct and `box-shadow: var(--shadow-sheet)` (line 11) is correct and untouched. `.band-roadmap h2` at line 15 also uses `var(--color-ink-800)`, on a `border-bottom` with `--border-width-strong`; that is a different element and a different rule role, is NOT part of this defect, and must be left alone.

**Defect 6 — dead code cleanup.** `src/pages/WeekDetailPage.css:241-260`. Three consecutive rule blocks are dead code and must all be removed: `.week-detail-resources` (241-245), `.week-detail-resources li` (247-254), and `.week-detail-resource-type` (256-260). `week-detail-resource` appears at exactly three locations in the entire `src` tree, all three of them these CSS selectors, with zero consumers in any TSX file and zero references in any test. `ResourcesPanel` renders its own markup and is unaffected. In-scope cleanup, not a rendered defect; it has no visible outcome by definition, so it is verified by source scan and non-regression rather than by appearance (see journey check 2.14, Section 14).

**Defect 7 — Roadmap jump-list is a flagged deviation, not remediated under this plan.** `src/pages/RoadmapPage.css:50-52`. The Roadmap jump-list ships a single wrapping flex chip row where the reference specifies a dedicated 60px desktop vertical rail with `writing-mode: vertical-rl` band tabs (D.2, `Field Journal DS.dc.html:645,754-758`, `grid-template-columns: minmax(0,1fr) 60px`) and a 3-column 56px bottom tab bar (E.2, lines 1374-1378). The in-code comment states this was "deliberately declined." See Decision (b), Section 11.

Per Decision (b) this is explicitly not remediation work. It appears in exactly three places in this plan and nowhere else: (1) here, marked flagged-not-remediated; (2) Decision (b), Section 11; (3) Ordered-work Step 1, as required content of the GitHub tracking issue body. It does not appear as an Ordered-work build step, does not appear in the Section 10 acceptance checklist as something to remediate, and is not a Browser Validator pass/fail item — journey check 1.6 (Section 14) stays informational-only and records the observed chip-row treatment without a verdict.

### Adjudicated as NOT defects

Record so they are not re-raised: `src/pages/WeekDetailPage.css:195,202,214`'s `border-left: 4px solid` on the locked/not-available/not-authored banners are legitimate non-rule structural elements outside A.3's named scale, using tokens only with correctly square radius; the reference D.3 artboard defines no treatment for these edge states, so they are legitimately derived from A+B+C primitives per ADOPTION-PLAN issue #14's rule.

---

## 5. What static inspection cannot see

These are the reasons the browser pass is mandatory rather than a formality:

1. Cascade/specificity collisions silently overriding a correct token rule; this codebase has two documented precedents (the target-line line-height override, the week-card-state-label font-size fix).
2. The separate runtime token-injection pipeline: six `--typography-role-target-line-*`/`--typography-role-label-fontFamily` values are injected at runtime by `main.tsx`'s `generateCSSVariables()`, not sourced from the Atelier CSS file, so a silent injection failure diverges from the static file with nothing to grep.
3. `--text-size-multiplier`/`--line-height` compounding with fixed-px values (32px lead lines, 48px control height, 55-57px margin rule).
4. Focus-ring clipping by `overflow: hidden` ancestors (`.week-card`, `.flashcards-viewer-progress-bar`).
5. Reduced motion collapsing to a genuine instant state versus a residual opacity-only flash.
6. Real content-length integration drift — `LessonContentView.css` documents a confirmed sub-pixel drift between the ruled 32px background and running-text line-height.
7. Real seeded-data correctness of the C.4 locked-state absolute date and relative distance, including TODAY/1 DAY/N DAYS boundaries.
8. Keyboard/ARIA logic: SegmentLedger's roving tabindex, WeekCard's locked-disclosure Escape/refocus, FlashcardsViewer's flip live-region re-announcement, the page-turn's forward-navigation-only gating.
9. Order/position of the four C.5 chunks at both viewports under flex/grid reflow.

---

## 6. Research evidence

None. No external or current-fact question was material; all findings are local repository file evidence.

---

## 7. Design route and review history

```
DESIGN_ROUTE
profile: compact
reasons: The Field Journal DS is already fully authored; no new design language is introduced. But the work adjudicates genuine reference-conformance questions on rendered user-visible surfaces and changes shipped CSS, so `none` would have been dishonest.
agents_required: design-generalist, design-reviewer
prototype: forbidden
model_tier: sonnet
existing_system_mode: preserve
END_DESIGN_ROUTE
```

**Design review: PASSED** (`DESIGN_REVIEW_RESULT: PASS`), third and final round. Recorded honestly:

- Round 1 returned NEEDS_REVISION on four findings; the original design agent was resumed once and revised.
- Round 2 returned NEEDS_REVISION on two NEW high-severity defects introduced by that revision (the wrong C.5 line ranges that would have deleted `.lesson-content-chunk--ruled`, and two states wrongly marked unreachable). Because the design contract permits only one revision, this was returned to the user as `PLAN_BLOCKED`; the user authorized one closing mechanical revision round, which was applied and passed.
- The review's own stated limit: it verified the underlying repository facts independently but did not re-diff the final document's prose formatting.

---

## 8. Ordered work

Owner: **T1**, escalating to **T2** on two counted gate failures per step.

**Step 0 — Pre-flight.** Run `gh issue view 38`, `39`, `40 --repo lebobo88/lizbeth-spanish` and confirm each live body matches the scope recorded here. `gh` was not available on the planning tool surface, so the live issue bodies were not re-fetched during planning — `ADOPTION-PLAN.md` plus the per-issue plan documents were the specification of record. If any live body materially differs, stop and return `JOB_BLOCKED: Plan stale`.

**Step 1 — Open the tracking issue.** Open one GitHub tracking issue in `lebobo88/lizbeth-spanish` against milestone `Field Journal DS`, plain descriptive title with no "#N:" prefix, labelled at minimum `area:design-system` and `area:accessibility`. Body references this plan's path, states it is backlog item 3 covering #38/#39/#40, and **must** include the Decision (b) jump-list deviation flag with its artboard citations (Section 11).

**Step 2 — Fix defect 1** (C.5 chunk geometry), honoring the `.lesson-content-chunk--ruled` exclusion exactly.

**Step 3 — Fix defects 2, 3, 4, 5** (the ResourcesPanel buttons and row, the Flashcards nav button, the BandRoadmap sheet border).

**Step 4 — Remove the dead `.week-detail-resources`, `.week-detail-resources li`, and `.week-detail-resource-type` rules** at `WeekDetailPage.css:241-260` (defect 6).

**Step 5 — Run the full deterministic gate.** `npm run lint`, `tsc`, `npm test`, and the no-native-dialog source scan (`src/__tests__/nativeDialogPolicy.test.ts`).

**Step 6 — Independent Verifier pass.**

**Step 7 — Browser Validator pass** per Section 13. Required — this is rendered authenticated UI.

**Step 8 — Comment and close.** Comment the remediation and browser evidence onto #38, #39, and #40, and close them plus the Step 1 tracking issue via `gh issue close`, **only after** both Step 6 and Step 7 pass. Each closing comment must state that validation covered the rendered student screens at 1440 and 390 and must **not** imply sign-off on #41/#42 or any other backlog item. Issue creation and closing are tracking actions under the standing directive; they grant no commit, push, PR, or deploy authority.

---

## 9. Interfaces and data

No API, schema, or data-model change. The only interface is the CSS custom-property surface consumed across `src/**/*.css`. Every fix re-points an existing declaration at an existing token; no property is added, removed, or renamed.

**Backward-compatibility requirement:** every custom property currently consumed anywhere in `src/` must still resolve.

---

## 10. Acceptance and validation

- Defects 1-6 remediated with token-only changes and no new token value introduced. Defect 7 remains flagged, not remediated, per Decision (b); it is not a build step and not a pass/fail acceptance item here.
- `.lesson-content-chunk--ruled` byte-unchanged.
- `git diff` shows no change to `src/tokens/field-workbook.generated.css`, `.atelier/tokens/field-workbook.tokens.json`, or `lizbeth_spanish\atelier.config.json`.
- Lint, tsc, and full test suite green.
- No-native-dialog scan passes.
- Independent Verifier pass.
- Browser Validator pass over every journey in Section 13 at both viewports.
- Tracking issue and #38/#39/#40 commented and closed only after both gates (Steps 6 and 7).

---

## 11. Decisions recorded

Both decisions below are attributed to the **orchestrator's default recommendation**, explicitly **not** a design-review finding, and both are easy to reverse with explicit user direction later.

**Decision (a) — C.5 chunk tinting: do NOT adopt the four pastel chunk fills.** There is a genuine self-contradiction in the reference: `ADOPTION-PLAN.md:131-132,270-274` says chunks are told apart "by number and position, never by tint," while the artboard itself differentiates them by a distinct pastel background per type — `#fef5e7` (01 RULE BOX), `#eef5f0` (02 EXAMPLE), `#eef3f4` (03 TRANSLATION TASK), `#fffbf8` (04 DIALECT NOTE). Design review independently confirmed all four already exist as `--color-badge-tint-archaic`/`-inclusive`/`-dialect`/`-disabled` at `field-workbook.generated.css:43-47`, so adoption would mint no new value — but those token **names** do not line up semantically with the chunk types they would be reused for, so any future adoption must alias them under new semantic names rather than referencing the badge-tint names directly in chunk CSS. This plan follows the written rule over the artboard. The C.5 border/shadow geometry fix (defect 1) is **unaffected** and remains in scope regardless of how this is later decided.

**Decision (b) — Roadmap jump-list rail/tab-bar: do not build it.** The `RoadmapPage.css:50-52` "deliberately declined" comment is treated as **not yet product-confirmed**. Building the D.2 rail or E.2 bottom tab bar is explicitly out of scope as new engineering work here. But the deviation must be flagged visibly — in this plan **and** in the GitHub tracking issue — with the artboard citations, so a future session can make an informed product call rather than it remaining a silent, undocumented deviation.

---

## 12. Judge route

Eligible for `PLAN_DUCK` before approval and `CODE_REVIEW` on the remediation diff per `docs/JUDGE-CONTRACT.md`.

- Risk: medium.
- Rubric: reference-conformance fidelity of each of the six remediated fixes (defects 1-6) against `ADOPTION-PLAN.md` §A.3/C.1/C.5 and the cited artboard lines, the `.lesson-content-chunk--ruled` exclusion, and no new token value introduced. Defect 7 is judged only on whether it remains correctly flagged (not remediated) per Decision (b).
- Deterministic results always dominate.
- `VISUAL_REVIEW` is eligible here, since unlike backlog items 1 and 2 this item genuinely produces screenshots.

**PLAN_DUCK checkpoint result, recorded.** A `PLAN_DUCK` checkpoint ran in shadow mode (advisory) against this plan and returned REVISE with two major findings: J-001 (remediation specs for defects 2, 4, 5, 6, and 7 were insufficiently concrete or internally inconsistent) and J-002 (browser-validation coverage gaps for defect 6's dead-code removal, the retry/error state in journey 2.9, and the absence of an explicit defect-to-coverage matrix). This revision resolves both J-001 and J-002; see the updated Section 4 defect entries and Section 14's journey check 2.14, retry procedure, and defect-to-coverage matrix.

---

## 13. Browser UI dialog policy

Required and applicable. No native `alert`, `confirm`, `prompt`, their `window.*` forms, or `beforeunload` prompts anywhere in this browser-rendered React UI. Acknowledgement and confirmation use an app-owned accessible modal; inline validation where it better serves the user. The deterministic scan `src/__tests__/nativeDialogPolicy.test.ts` is a required gate at Ordered-work Step 5, and journey check 3.10 below re-confirms it live.

---

## 14. Browser UI validation

**REQUIRED.** Reproduce all of the following faithfully.

**Launch/readiness:** the Vite dev server is **already running** at `http://localhost:5173/` and must be reused as-is. Never run `taskkill` or otherwise kill the process. Restart only if genuinely down, via `npm run dev`.

**Base URL:** `http://localhost:5173/`

**Fixture/reset:** existing seeded accounts via the app's normal login flow. No Docker/Supabase change and no reseeding authorized.

**Tooling constraint:** authenticated routes **must** use the `claude-in-chrome`-backed `browser-validator` performing a real login. Atelier's `screenshot`/`baseline_update` tools run an isolated unauthenticated Playwright session and cannot reach these routes at all.

**Viewport profiles:** desktop 1440x900, mobile 390x844 (matching the reference's D @1440 and E @390 artboards).

### State-to-account table

Derived from `supabase/seed.sql`; password is `password` for every account.

- **Roadmap loading:** any account, transient.
- **Roadmap error (network failure):** not reachable via seed data, requires a forced offline/network block in devtools — **not independently verified**, spot-check live before treating as closed.
- **Roadmap empty (no enrollments):** `student5@test.local` (`seed.sql:250-251`).
- **Roadmap ready, 0-week empty state:** `student6@test.local`, "Advanced Immersion (Empty Fixture)" band (`seed.sql:256-262`).
- **Roadmap ready with a real near-term locked date:** `student4@test.local`, Beginner enrolled 5 days ago (`seed.sql:242-248`) — week 1 accessible, week 2+ locked; `seed.sql`'s own comment designates this the canonical locked-access fixture, so use it rather than student1 for the C.4 locked-date check.
- **Roadmap ready, completed + current:** `student1@test.local`, Beginner enrolled 21 days ago (`seed.sql:177-185`).
- **Roadmap multi-band jump-list:** `student2@test.local` (`seed.sql:191-217`), `student3@test.local` (`seed.sql:220-236`), or `fullaccess@test.local` (`seed.sql:264-271`, a no-locked-cards variant).
- **Week detail available/content success**, the only path reaching a real four-chunk and segment-ledger render: recommended `student1@test.local`, Beginner weeks 1-4 — `seed.sql:301-324` seeds `lesson_content` only for Beginner weeks <=4; student2's and student3's Beginner enrollments also reach weeks 1-4 and are equally valid, student1 is simplest.
- **Week detail locked:** `student4@test.local`, Beginner week 2+.
- **Week detail not-available:** `student1@test.local`, navigate to `/roadmap/<enrollmentId>/week/27` or any out-of-range week or garbage id — `WeekDetailPage.tsx:193-204` sets `kind:'not-available'` when the enrollment or matching lesson is not found, and all bands seed exactly 26 weeks (`seed.sql:121-161`); this is a manual-URL check, not normal navigation.
- **Week detail empty (unlocked, nothing published):** `student3@test.local`, Beginner week 5, or any Intermediate/Advanced week for student2/fullaccess — `WeekDetailPage.tsx:210-249` sets `kind:'empty'` when a week is unlocked but has zero resources, and resources are seeded only for Beginner weeks 1-4.
- **Week detail content not-authored:** not reachable, every seeded week's resources include lesson_content atomically.
- **Week detail content fetch-error/retrying:** not reachable via fixtures, requires a forced network failure.
- **Flashcards populated:** any unlocked Beginner week <=4, student1 weeks 1-4 recommended or student4 week 1.
- **Flashcards empty:** not confirmed reachable, the seeded `flashcards.yaml` is likely non-empty and shared (`seed.sql:290-294`) — **not independently verified**, spot-check live before treating as closed.

### Journeys and visible outcomes

At **both** viewports.

**1. Roadmap**

1.1 Eyebrow "Contents" plus display h1 render; grid is 4-up >=900px, 2-up 641-899px, 1-up <=640px, fail on a wrong column count.
1.2 All four C.4 states present, each with icon AND word, and the locked state showing a REAL absolute date and real relative distance computed live (for example `OPENS 03 SEP 2026 · IN 4 DAYS`) — any placeholder or static date is a fail.
1.3 The week number is visibly the single largest element on every card, in Fraunces weight.
1.4 Pixel-sample `.band-roadmap`'s border color — fail if it reads ink.800 `#3d3530` rather than ink.1000 `#1a1512`.
1.5 Zero corner rounding and hard-offset-only shadows everywhere, no blur.
1.6 The multi-band jump-list renders as a wrapping chip row — INFORMATIONAL only per Decision (b), not a fail; activating a chip moves focus/scroll without mutating the URL hash.
1.7 Full keyboard pass; the locked card's "Why locked?" opens inline and closes on Escape with focus returned; no native dialog.

**2. Week detail**

2.1 Page-turn plays exactly once on a real forward click, never on back/forward/refresh.
2.2 Under `prefers-reduced-motion: reduce` it collapses instantly with no visible rotation and no lingering low-opacity frame.
2.3 Two-column >=900px, block flow <=899px, identical DOM/tab order at both.
2.4 The ruled reading surface shows 32px lead lines and a 55-57px margin rule behind real lesson content.
2.5 C.5 fixed order and identity `01 · RULE BOX`, `02 · EXAMPLE`, `03 · TRANSLATION TASK`, `04 · DIALECT NOTE`, each with its numbered mono tab top-left, at both viewports.
2.6 C.5 geometry, deterministic pass/fail: every chunk box shows a 3px solid ink.1000 border on all four sides plus a `5px 5px 0 0` ink.1000 hard shadow; any left-only accent border of any width or color is a fail. The `--ruled` dashed divider is correct and explicitly excluded from this check.
2.7 Chunk fill color recorded as INFORMATIONAL only per Decision (a); a uniform tint is expected.
2.8 C.6 segment ledger: fixed three-segment 30/10/20 rhythm with literal real minute labels set in type, plus full roving-tabindex keyboard behavior.
2.9 Pixel-sample `.resources-panel-row` (fail on a pale 1px line instead of a 2px rule-black border) and the resources action/retry/nav buttons (fail if thin or tinted rather than a 3px rule-black outline with a visible hard shadow, or under 48px tall). This check must exercise all three states of the ResourcesPanel action, since the action control is visible in the `idle` state, the link only after a successful fetch (`ready`), and the retry control only in the forced `error` state.

Concrete, deterministic procedure to reach the retry/error state (verified mechanics from `ResourcesPanel.tsx:32-66`): `handleFetch` sets `{kind:'error'}` when `getSignedResourceUrl` fails or, for a flashcards resource, when the follow-up `fetch(result.url)` is not `ok` or throws. Sign in as `student1@test.local` at a Beginner week 1-4; open Chrome DevTools and add a network request-blocking rule (or toggle Offline) covering the Supabase storage-signing request; click the resource row's action control; the row must render the inline `.resources-panel-error` block with `role="status"` and the Retry control, and must NOT produce any native dialog. Reset for re-running: remove the blocking rule or go back online and click Retry, which re-invokes the same `handleFetch` and must recover to the `ready`/`ready-flashcards` state. This is a client-side DevTools manipulation only, requires no Supabase, seed, or server change, and is fully reversible. This error state also validates the browser-dialog invariant, since the code path's documented contract (`ResourcesPanel.tsx:119-127`) is that a denied request shows an inline retry state and never a native dialog.
2.10 Mark-complete produces inline `aria-live` text and a single-fire Stamp, never a modal.
2.11 The locked banner (student4) has zero radius, token colors only, and real date/distance text.
2.12 Not-available, reached via `/roadmap/<enrollmentId>/week/27`, shows an inline status message and no dead end.
2.13 Empty (student3 week 5) shows an inline "no resources published" message.
2.14 Defect 6 (dead CSS removal) has no rendered outcome by definition, so it is verified two ways rather than by appearance: (a) a deterministic source scan after the change — grepping `week-detail-resource` across `src` must return ZERO matches; and (b) a non-regression check that the Week detail attachments rail still renders normally for `student1@test.local` at a Beginner week 1-4, at both viewports, confirming nothing depended on the removed rules.

**3. Flashcards**

3.1 Real deck content only, no lorem.
3.2 Decorative offset deck rects are `aria-hidden` and non-interactive.
3.3 Flip via click and Space animates `rotateY` over 320ms and updates the live region correctly, verified via the accessibility tree.
3.4 A same-face double-flip still re-announces.
3.5 Under reduced motion the flip snaps instantly with no interpolation frame and no opacity dip.
3.6 Progress shows real zero-padded `Card 0N / 0M` text BESIDE the fill bar, never instead of it.
3.7 Pixel-sample the nav-button border — fail if it reads 2px rather than the mandated 3px; confirm 48px min-height and a distinct disabled treatment at deck ends.
3.8 Full keyboard pass with an unclipped 3px ink.slate focus ring at 2px offset.
3.9 Zero radius and hard-offset shadow on card and nav buttons.
3.10 No native `alert`/`confirm`/`prompt`/`beforeunload` anywhere, by source scan plus live interaction.

**Also run** `mcp__atelier__contrast_check`, `design_review`, and `a11y_audit` against the three pages, with the pre-accepted brass.600/terracotta.600 APCA Lc-75 shortfall understood as **not** a failure.

### Defect-to-coverage matrix

One row per defect, so no defect is silently uncovered. Every row runs at **both** 1440x900 and 390x844.

| Defect | Surface | Account / route | Journey check | Verdict type |
|---|---|---|---|---|
| 1 — C.5 chunk geometry | `LessonContentView.css` | student1@test.local, Beginner week 1-4 | 2.6 | Deterministic pass/fail |
| 2 — ResourcesPanel action/link/retry controls | `ResourcesPanel.tsx`/`.css` | student1@test.local, Beginner week 1-4; the retry variant additionally requires the DevTools block procedure in 2.9 | 2.9 | Deterministic pass/fail (all three sub-states: `idle` action, `ready` link, `error` retry) |
| 3 — `.resources-panel-row` border | `ResourcesPanel.css` | student1@test.local, Beginner week 1-4 | 2.9 | Deterministic pass/fail |
| 4 — Flashcards nav button border | `FlashcardsViewer.css` | student1@test.local, Beginner week 1-4, via the "View flashcards" action | 3.7 | Deterministic pass/fail |
| 5 — `.band-roadmap` border colour | `BandRoadmap.css` | any roadmap-bearing account, student1@test.local simplest | 1.4 | Deterministic pass/fail |
| 6 — dead CSS removal | `WeekDetailPage.css` | student1@test.local, Beginner week 1-4 | 2.14 | Verified by source scan plus non-regression, NOT by appearance |
| 7 — Roadmap jump-list rail/tab-bar | `RoadmapPage.css` | not remediated under this plan per Decision (b) | 1.6 | Informational only; the Browser Validator records the observed treatment and does NOT pass or fail it |

The Browser Validator does not need to verify the following as pass/fail: Defect 7 (informational only, per Decision (b)), and Defect 6's rendered appearance (verified by source scan and non-regression instead, per journey check 2.14). "Roadmap error (network failure)" and "Flashcards empty" remain not independently verified and must be spot-checked live before being treated as closed, unchanged from the State-to-account table above.

---

## 15. Risks and rollback

**Overall risk: medium.** The changes are small and token-only, but they touch shared rendered surfaces on the primary student journey.

- **Highest risk:** the C.5 fix deleting `.lesson-content-chunk--ruled` if an engineer works from line numbers rather than selector names. Mitigated by the explicit exclusion repeated in three places (Section 4, Section 8 Step 2, this section).
- **Second risk:** changing `.resources-panel-*` buttons to full C.1 geometry (3px rule plus hard shadow, 48px) alters the attachments rail's visual weight and may reflow the rail at 390px. The browser pass must confirm no overflow or clipping.
- **Third risk:** closing #38/#39/#40 could imply broader sign-off than occurred. Each closing comment must scope itself per Ordered-work Step 8.
- **Rollback:** revert the CSS commit. No migration, no schema, no persisted state, and issue closure is reversible by reopening.

---

## 16. Assumptions and decisions

**Assumptions:**

- Verified at Step 0 rather than trusted: `ADOPTION-PLAN.md` plus the per-issue plan documents are the specification of record for #38/#39/#40, because `gh` was not on the planning tool surface.
- Whether Beginner weeks 1-3 render as `completed` rather than merely unlocked for `student1@test.local` depends on `lesson_progress` rows not traced during planning; verify live.
- App-level navigation, header/nav chrome, and auth gating are outside the files in scope and assumed functioning.

**Stated evidence limits to carry forward:**

- "Roadmap error (network failure)" and "Flashcards empty" were not independently verified as unreachable and must be spot-checked live by the Browser Validator before being treated as closed.

**Decisions:** see Section 11, Decisions (a) and (b).

---

## 17. Engineering mode and ownership

- **Engineering mode:** standard.
- **Team authorization:** not applicable.
- **Downstream owner:** `engineering-fleet` (T1 primary, T2 on two counted gate failures, then Verifier, then Browser Validator).

---

## 18. Approval gate

**Approval record.**

- Approved via: the standing forward authorization granted in Section 16 of `docs/plans/lizbeth-spanish-fjds-issue31-33-revalidation.md`.
- Verbatim reply that granted the authorization (from that session): "approve. continue autonomously moving forward."
- What that authorization covers: it explicitly extends to backlog items 3-7 of the roadmap in `docs/plans/lizbeth-spanish-fjds-token-pipeline-reconciliation.md`. This plan is backlog item 3, so it falls within that grant.
- How it was applied here: the orchestrator presented this plan's compact summary to the user before execution — seven confirmed conformance defects found across the Roadmap, Week-detail, and Flashcards screens, most severe being the ResourcesPanel buttons bypassing the shared `Control` component (Defect 2, Section 4); two orchestrator-default decisions flagged for possible user override (Decisions (a) and (b), Section 11); two design-review rounds plus one Codex `PLAN_DUCK` revision round completed before presentation. No user objection followed that presentation, so execution may proceed under the terms of the standing grant.
- Classification: **approval by standing forward authorization, not a fresh individual reply.** This is the documented exception the user explicitly granted in the source plan's Section 16, not an inference drawn from the general standing session `/goal`. The source plan's Section 16 itself distinguishes this forward-authorization path from an ordinary direct approval, and this record follows that same distinction rather than blurring it.
- When: this session (2026-09-02).

**Judge checkpoint recorded as part of this approval.** A `PLAN_DUCK` checkpoint ran in shadow mode (advisory, per `docs/JUDGE-CONTRACT.md`) against this plan and returned **REVISE**, citing J-001 (insufficiently concrete or internally inconsistent remediation specs for defects 2, 4, 5, 6, and 7) and J-002 (browser-validation coverage gaps for defect 6's dead-code removal, the retry/error state in journey 2.9, and the absence of an explicit defect-to-coverage matrix). One revision round was applied, resolving both findings (see Section 4's updated defect entries, Section 12's recorded checkpoint result, and Section 14's journey check 2.14, retry procedure, and defect-to-coverage matrix), and the revised plan re-passed.

**What this authorization does and does not waive.** It waives only the requirement to wait for a separate affirmative "approved" reply after the plan summary is presented. It does **not** waive presenting this plan to the user in summary form before execution begins (that presentation has now occurred), and it does not waive any other gate: the Verifier pass, the Browser Validator pass, judge checkpoints, or the standing prohibitions on unrequested commit, push, PR, or deploy actions.

During this plan's own design stage, the user made a direct decision: they selected option A (authorize one closing mechanical design-revision round) and left the two product questions to the orchestrator's proposed defaults, which are recorded as Decisions (a) and (b) in Section 11.

T1/T2 execution may proceed per Section 17's downstream ownership, subject to the ordered-work sequencing in Section 8, including the required Verifier pass and Browser Validator pass before any issue close.
