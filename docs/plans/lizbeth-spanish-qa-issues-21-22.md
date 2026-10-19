# Lizbeth Spanish — QA Issues #21 and #22

Status: Approved

Approved by: rob.hasselbach@gmail.com, 2026-08-29, via direct interactive-session response to the orchestrator. Exact reply: "yes proceed as planned. for 22 b" — mapping: (1) Part A (#21) approved as-is; (2) Part B (#22) option (b) selected (rename the fixture band).

Plan ID: `lizbeth-spanish-qa-issues-21-22`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: `engineering-fleet` (for #21 and #22, after explicit user approval of this plan)

This plan covers two independent GitHub QA issues. **Issue #21 (LS-QA-010)** has a confirmed root cause, a reviewed design remedy, and an authorized, bounded build plan below. **Issue #22 (LS-QA-011)** was evidence-gathered in the original draft; the user has since reviewed that evidence and selected option (b) (fixture band rename), so Part B below is now an execution-ready work plan. Both parts remain gated on the explicit user approval recorded in the status header above; this draft does not itself constitute that approval.

---

## Part A — Issue #21 (LS-QA-010): "Create course" button illegible

### Outcome and audience

Make the "Create course" primary submit button on `/admin/courses/new` visibly legible and WCAG 2.2 AA compliant across its default, hover, focus, and disabled states, with mandatory browser validation confirming the fix. Audience: the user approving this plan, the T1 engineer executing it, the independent verifier, and the browser validator.

### Scope and non-goals

**In scope:**
- The CSS cascade fix for the "Create course" button on `/admin/courses/new` (`src/pages/NewCoursePage.tsx`).
- The same-root-cause fix to "Request enrollment" on the public catalog page (`src/pages/PublicCatalogPage.tsx:39`), since it shares the identical defect and is fixed as a side effect of the same rule.
- A new deterministic source-level regression test guarding the fix.
- Mandatory browser validation of both buttons across three viewports and all interactive states.

**Non-goals (explicitly excluded from this plan):**
- No fix for issue #22. #22 requires a user defect/not-a-defect decision before any implementation is scoped (see Part B).
- The pre-existing, app-wide `.demo-button.primary:hover` WCAG failure at `src/App.css:426-430` (uses `--color-accent-secondary`, approximately 2.97:1 against paper-50, failing AA) is out of scope. This plan recommends filing a separate follow-up issue for it; the fix below deliberately avoids reusing that failing token.
- No refactor of the shared `.workspace-panel` button rule at `src/pages/CourseWorkspace.css:4` (or its `:hover`/`:disabled` companions).
- No CSS import reordering.
- No token-value changes, no new design tokens, no DTCG source changes.
- No new dependency, component library, or CSS-in-JS introduction.
- No label or content changes to either button.
- No changes to `seed.sql`, the course/band backfill migration, or the fixture band name (those belong entirely to the #22 decision, if any).

### Repository findings (root cause, confirmed)

The prior remediation batch's failure pattern (a stylesheet never imported, causing undefined CSS custom properties to silently fall back) does **not** apply here. Both stylesheets load, and every referenced token is defined. The actual defect is a CSS cascade collision between two equal-specificity rules:

1. `src/pages/NewCoursePage.tsx:4` renders `<button className="demo-button primary" disabled={saving}>{saving ? 'Creating…' : 'Create course'}</button>` inside `<form className="workspace-panel">`.
2. `src/App.css:420-424` defines the intended treatment:
   ```css
   .demo-button.primary {
     background-color: var(--color-brass-600);
     color: var(--color-paper-50);
     border-color: var(--color-ink-800);
   }
   ```
   Specificity: (0,2,0).
3. `src/pages/CourseWorkspace.css:4` defines a broad descendant rule that also matches this button:
   ```css
   .workspace-panel > button:not(.text-button), .workspace-panel .demo-button {
     margin-top: var(--space-3);
     min-height: 44px;
     padding: 10px 16px;
     border: 2px solid var(--color-ink-800);
     font-weight: 700;
     background: var(--color-paper-100);
     box-shadow: 2px 2px 0 var(--color-ink-800);
   }
   ```
   Specificity: (0,2,0), equal to rule 2.
4. The shared rule (3) sets `background` but not `color`. The rendered result is background `var(--color-paper-100)` = `#faf8f4` (rgb(250,248,244)) with the surviving `color: var(--color-paper-50)` = `#fdfcf9` (rgb(253,252,249)) from rule (2) — an exact match for the QA sweep's measured 1.03:1 contrast ratio / APCA Lc 0.
5. Token definitions confirming these hex values: `src/App.css:19` (`--color-paper-50: #fdfcf9`), `src/App.css:20` (`--color-paper-100: #faf8f4`), `src/App.css:28` (`--color-brass-600: #866843`). All are defined; none fall back to an undefined default.
6. **Which of the two equal-specificity rules wins the source-order tiebreak was not empirically confirmed** during planning. The QA sweep's measured 1.03:1 is the authoritative evidence that the paper-100 background wins at runtime. **The fix must not depend on CSS import order and must not attempt a fix by reordering imports.** Step 1 below captures the true cascade origin as observed evidence to close this open question with fact rather than inference.
7. Additional affected surface: `src/pages/PublicCatalogPage.tsx:39` ("Request enrollment", `demo-button primary`) sits inside `<div className="workspace-panel">` at line 33 and has the identical defect. It will be fixed as a beneficial side effect of the same additive rule; this plan requires it be validated too.
8. Confirmed unaffected exemplars of the correct treatment (do not need fixing, useful as visual reference): `src/pages/AdminStudentsPage.tsx:412` ("Add Student", outside `.workspace-panel`); `src/pages/OwnerSettingsPage.tsx:289` with `src/pages/OwnerSettingsPage.css:73-99` ("Save business settings" — a distinct `owner-settings-save-button` component, not `.demo-button` at all).
9. `src/pages/CourseWorkspacePage.tsx:26`'s "Save draft" primary button is inside `.workspace-heading`, not `.workspace-panel`, so it is unaffected by this defect and must show no visual change from this fix.

### Design route and reviewed handoff

**Design route:** compact. Reason: a bounded brownfield fix to one existing button treatment inside an already-shipped token system, with no new screen, flow, or component — a single-surface CSS cascade defect with an accessibility consequence. Agents: `design-generalist`, `design-reviewer`. Prototype: forbidden. Model tier: Sonnet. Existing-system mode: preserve.

**Selected direction:** restore the established Field Workbook primary-button language (square radius, 2px ink-800 border, `--shadow-print`, brass-600 fill, paper-50 label) that already ships correctly on "Add Student". This is a defect fix, not a new design.

**Chosen remedy:** an additive, higher-specificity scoped rule appended to `src/pages/CourseWorkspace.css`. Two alternatives were considered and rejected:
- Narrowing the broad `.workspace-panel` descendant selector was rejected because that selector list is shared by three separate declarations (base, `:hover`, `:disabled`) and editing it risks accidentally excluding unintended elements.
- The additive approach has the smallest diff and smallest regression surface, so it was selected.

**Exact rules to append to `src/pages/CourseWorkspace.css`:**
```css
.workspace-panel .demo-button.primary {
  background-color: var(--color-brass-600);
  color: var(--color-paper-50);
  border-color: var(--color-ink-800);
  box-shadow: var(--shadow-print);
}

.workspace-panel .demo-button.primary:hover {
  background-color: var(--color-terracotta-600);
}

.workspace-panel .demo-button.primary:disabled {
  opacity: .7;
}
```

**Specificity:** (0,3,0) for the base rule; (0,4,0) for `:hover`/`:disabled`. This beats both existing (0,2,0) rules on specificity alone, independent of source order. The `:hover` rule also outranks `src/App.css:432`'s (0,3,0) `.demo-button.primary:active` rule, which sets no `background` of its own, so the active state correctly inherits the hover fill.

**Contrast (independently reproduced by the design reviewer using the WCAG relative-luminance formula from sRGB hex values):**
- Default: brass-600 `#866843` on paper-50 `#fdfcf9` = 5.02:1 — PASS AA (4.5:1 floor).
- Hover: terracotta-600 `#a85e4a` on paper-50 = 4.69:1 — PASS AA.
- Focus-visible outline: terracotta-600 against the panel's paper-100 background = 4.54:1 — passes the 3:1 non-text floor.
- The label is 1rem/700 (`--font-size-control` / `--font-weight-label`), below WCAG's 18.66px-bold large-text threshold, so the stricter 4.5:1 normal-text floor applies throughout, not the 3:1 large-text floor.

Hover deliberately uses `--color-terracotta-600`, **not** the global `--color-accent-secondary` (terracotta-500, `#d97a5c`), which is only 2.97:1 against paper-50 and fails AA. This matches the `OwnerSettingsPage` precedent and is why the pre-existing app-wide hover failure at `App.css:426-430` is explicitly out of scope rather than reused.

**Disabled state:** the shared `.workspace-panel .demo-button:disabled { opacity: .5 }` rule yields roughly 2.03:1 while "Creating…" is shown. WCAG 2.2 SC 1.4.3 and 1.4.11 formally exempt disabled controls from contrast minimums, so this is not a conformance failure, but it reads as visually broken rather than intentionally disabled. The scoped `:disabled { opacity: .7 }` override (roughly 2.83:1) is recommended and matches the precedent at `src/pages/OwnerSettingsPage.css:98`. **Engineering discretion:** staying at `.5` is also acceptable and equally conformant; the engineer may choose either without further design review, though the `.7` value is the reviewed recommendation.

**Non-color affordance:** `--shadow-print` (the deeper `.3rem .3rem 0` stamped shadow) restores a depth cue distinguishing the primary action from the flat `2px 2px 0` shadow the panel rule gives secondary and neutral buttons — a shape signal independent of color.

**Tokens:** no new tokens and no DTCG source changes. Every value referenced is an existing primitive from `src/App.css:17-37` / `src/tokens/field-workbook.generated.css`.

**Engineering invariants (must be preserved verbatim by the implementing engineer):**
- Do not modify `.workspace-panel > button:not(.text-button), .workspace-panel .demo-button` (`CourseWorkspace.css:4`) or its `:hover`/`:disabled` companions. That is the deliberate neutral treatment for `.demo-button.secondary` and plain panel buttons and must render exactly as today: paper-100 fill, ink text, flat 2px shadow, `.5` disabled opacity.
- Additive overrides only.
- Do not reorder CSS imports.
- No label or content change.
- No new dependency, CSS-in-JS, component library, or token.

### Design review result

**PASS** (`design-reviewer`, independent, Sonnet, second pass). The first pass returned `NEEDS_REVISION` on one medium-severity evidence finding: the original handoff had asserted an unverified CSS load-order mechanism as fact. The single permitted revision reworded the root-cause explanation to state only the verified equal-specificity collision, explicitly labeled the true injection order as unverified, added the order-independence invariant, and added the DevTools cascade-origin evidence-capture step (Step 1 below). Re-review returned PASS.

The reviewer independently reproduced all four contrast ratios, audited specificity across the whole of `App.css` (confirming line 563's later `.demo-button.primary` rule touches only `border-color` and does not affect this analysis), confirmed the `PublicCatalogPage` blast radius, and confirmed the regression-safety invariant. One residual low-severity advisory wording note remains and requires no further revision. The reviewer did not execute the application; the true CSS injection order remains empirically unconfirmed until Step 1's observed-evidence capture (the remedy does not depend on it).

### Judge route

`PLAN_DUCK` eligible at the orchestrator's discretion after this draft is written. Risk is low and the change is a three-rule CSS addition, so a judge checkpoint is optional here, not required. Any judge finding is advisory; deterministic failures (failing tests, unmet acceptance checks) always dominate an advisory judge finding regardless of judge disposition.

### Ordered work

**Step 0 — Environment bring-up (blocking, precedes everything).** Owner: T1.
- `cd H:\CommandCenter\orchestrator\lizbeth_spanish`.
- Confirm Docker is running.
- `npx supabase start`.
- Ensure `.env.local` carries `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` matching the emitted values, and never a `VITE_`-prefixed service-role key.
- `npx supabase db reset`.
- `npm run dev` and capture the actual printed URL. Vite defaults to 5173, but this project has been observed on 5174; the range 5173-5178 is expected. Capture the real value; never hardcode.
- Assert `VITE_SUPABASE_URL` points at `127.0.0.1` before any journey.
- Baseline: `npm test -- --run nativeDialogPolicy` must pass. Record `npm run type-check` and `npm run lint` output as the pre-existing baseline. Pre-existing failures are recorded, not fixed.

**Step 1 — Reproduce #21 before any edit.** Owner: T1. Depends on Step 0.
- Sign in as `owner@test.local` / `password` (seeded at `supabase/seed.sql:78` with `raw_app_meta_data` role `owner`).
- Navigate to `/admin/courses/new`. Capture a screenshot of the invisible "Create course" button, and record its computed `background-color` and `color` plus the DevTools cascade origin of the winning `background` declaration. This both confirms the defect and closes the unverified load-order question with observed evidence.
- Also visit the public catalog and record the same for "Request enrollment" (`PublicCatalogPage.tsx:39`).

**Step 2 — Failing test first.** Owner: T1. Depends on Step 1.
- Add a test asserting the corrected treatment before making the production edit.
- Because jsdom does not compute cascaded stylesheet colors, do **not** write a test asserting a rendered `rgb()` value in jsdom — that would repeat the exact unit-test-only false-confidence pattern this project has already been burned by.
- Instead, write a deterministic source-level assertion (in the spirit of the existing `nativeDialogPolicy` scan) over `src/pages/CourseWorkspace.css`, that fails today and passes after the fix: the file must contain a `.workspace-panel .demo-button.primary` rule setting `background-color` to `var(--color-brass-600)` and `color` to `var(--color-paper-50)`, and must still contain the untouched shared `.workspace-panel .demo-button` rule.
- This test is a guardrail against silent regression, **not** evidence that the button renders correctly. Only Step 5's browser validation establishes that.

**Step 3 — Apply the fix.** Owner: T1. Depends on Step 2.
- Append exactly the three rules from the "Chosen remedy" section above to `src/pages/CourseWorkspace.css`.
- Change no other file. Do not modify the existing shared selector list. Do not reorder imports.

**Step 4 — Independent verifier pass.** Owner: `verifier`. Depends on Step 3.
- Re-run the checks from Steps 0-2.
- Audit the diff against the approved scope.
- Confirm the engineering invariants held: shared rule untouched, no import reordering, no token changes, single-file diff (plus the one new test file).

**Step 5 — Mandatory browser validation.** Owner: `browser-validator`. Depends on Step 4.
- This gate is not optional and not substitutable by unit tests or a clean console. See the "Browser UI validation" section below. No completion may be claimed without it.

**Step 6 — Return #22 to the user.** Owner: orchestrator. Independent of Steps 0-5, and not gated on them.
- Relay the #22 evidence chain and the three options from Part B; obtain the user's defect/not-a-defect decision.
- If and only if the user selects option (b) or (c) in Part B, a new plan is required. This plan does not authorize any #22 implementation.

### Interfaces and data

None. `src/pages/CourseWorkspace.css` is the only production file changed for #21. No API, schema, migration, or contract change; no compatibility concern.

### Acceptance and validation

- Step 2's failing source-level test precedes the Step 3 production edit (TDD-first).
- `npm test -- --run nativeDialogPolicy` passes at the start and end. Zero native `alert`/`confirm`/`prompt`/`window.*` variants/`beforeunload` introduced.
- `npm run type-check` and `npm run lint` show no new failures against the Step 0 baseline; pre-existing failures are recorded, not fixed.
- The full existing test suite shows no new failures.
- The diff is confined to `src/pages/CourseWorkspace.css` plus the one new test file.
- Independent Verifier pass required (Step 4).
- Browser Validator PASS required (Step 5). A passing unit test, a clean console, or a passing type-check is never completion evidence for this issue. Every visual claim requires a rendered screenshot or an observed visible state change. This project has repeatedly had unit-test-only claims miss real, user-visible bugs; that is the specific reason this gate is mandatory and non-negotiable here.
- #21 is re-tested against its own filed reproduction steps from a clean `npx supabase db reset`.

### Risks and rollback

| ID | Severity | Risk | Mitigation |
|----|----------|------|------------|
| R1 | Medium | The additive rule accidentally restyles `.demo-button.secondary` or plain `.workspace-panel` buttons | The selector requires `.primary`; Step 5's journey 6 explicitly regression-tests secondary and neutral panel buttons on `CourseWorkspacePage` and `PublicCatalogPage` |
| R2 | Low | A future contributor "fixes" a cascade issue by reordering CSS imports, silently reverting this behavior | The order-independence invariant is stated in this plan; the Step 2 source-level test guards the rule's presence; Step 1 captures the true cascade origin as recorded evidence |
| R3 | Low | The `opacity: .7` disabled tweak is perceived as an unrequested scope addition | It is explicitly optional and left to engineering discretion; the design review confirms `.5` is equally conformant since disabled controls are contrast-exempt |
| R4 | Low | `PublicCatalogPage`'s "Request enrollment" changes appearance without having been named in the filed issue | Called out here as a confirmed same-root-cause fix, validated in Step 5, and disclosed in this plan rather than shipped silently |
| R5 | Medium | The out-of-scope global hover AA failure (`App.css:426-430`) is mistaken for part of this fix, or silently expanded into it | Named as an explicit non-goal above with a recommended separate follow-up issue |
| R6 | Medium | #22 is implemented without the user's decision on record | Resolved: the user selected option (b) in the live session; Part B's corrected scope enumeration makes the full edit surface visible before implementation |
| R7 | Medium | Renaming the guard's expected value regresses production fixture-contamination detection for the legacy name | Registry and check retain both names (safety requirement 1); a new test asserts legacy-name detection still works |
| R8 | Medium | A stale local database yields 5 bands and a failing count assertion | Mandatory `npx supabase db reset` before validation (safety requirement 2); documented as the expected first diagnosis if the count-4 assertion fails |
| R9 | Low | `seed.sql:259`'s name lookup is missed, silently detaching student6's enrollment and breaking the SPOT-03 empty-state fixture | Lines 63/111/254/259 changed atomically in B3; B8 verifies student6's empty-state journey end to end |

**Rollback for #21:** revert the single CSS file (and the new test file) — a three-rule additive change with no data, schema, or API effect.

### Assumptions and decisions

**Safe assumptions:**
- `owner@test.local` / `password` remains the seeded owner account (`supabase/seed.sql:78`).
- The dev server prints a URL in the 5173-5178 range.
- The button's font stays 1rem/700, so the 4.5:1 normal-text floor applies.

**Resolved decision:**
- The #22 defect/not-a-defect call is resolved. The user reviewed the evidence chain in Part B and selected option (b) (fixture band rename). Part B above is the resulting execution-ready work plan.

**Decisions still requiring the user:**
1. Whether to file a separate follow-up issue for the global `.demo-button.primary:hover` AA failure (R5, out of scope here).
2. Optional: `.7` vs `.5` disabled opacity for the #21 fix. Otherwise left to engineering discretion.

This plan grants no authority by itself. Explicit user approval of this document (recorded against the status header above) is required before any engineering writer begins work on either Part A or Part B.

### Browser UI dialog policy

Required and applicable. This is browser-rendered React UI. Native `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload` prompts are prohibited. Any acknowledgement or confirmation must use an app-owned accessible modal; validation must be inline. The existing deterministic scan `npm test -- --run nativeDialogPolicy` must pass before and after. This fix introduces no dialog; the invariant must simply not be violated.

### Browser UI validation

Required and mandatory. This is the completion gate for #21, not a formality.

- **Launch/readiness:** `cd H:\CommandCenter\orchestrator\lizbeth_spanish`; Docker running; `npx supabase start`; `npx supabase db reset`; `npm run dev`; wait for Vite's printed ready URL.
- **Base URL:** the actual printed dev-server URL, expected in the `http://localhost:5173`-`5178` range. Capture it; never hardcode.
- **Fixture/reset:** clean `npx supabase db reset` before the journeys. Test account: `owner@test.local` / `password` (owner role, `supabase/seed.sql:78`).
- **Viewport profiles:** 320px, 768px, 1440px.
- **Journeys and visible outcomes:**
  1. Sign in as owner, navigate to `/admin/courses/new`. "Create course" is immediately visible with the brass-600 fill and paper-50 label at all three viewports. Screenshot each.
  2. Leave the form empty and attempt submit (native `required` blocks it). The button remains legible in its default state.
  3. Fill "Course name", hover the button. Background shifts to the terracotta-600 hover fill; the label stays legible.
  4. Tab-focus the button by keyboard. The 3px terracotta-600 focus-visible outline (2px offset) renders clearly at all three viewports. No native browser dialog appears at any point.
  5. Submit with valid input. The disabled "Creating…" state is visibly distinguishable, not flat or invisible. Then confirm either navigation to `/admin/courses/{id}/outline` on success, or the inline `role="alert"` error on failure.
  6. Regression check: no visual change to `.demo-button.secondary` or plain `.workspace-panel` buttons on `CourseWorkspacePage` and `PublicCatalogPage`. They retain paper-100 fill, ink text, the flat 2px shadow, and `.5` disabled opacity exactly as before. Screenshot before/after.
  7. Confirm `PublicCatalogPage`'s "Request enrollment" primary button (inside `.workspace-panel`) is now also legible and AA-compliant.
  8. Evidence capture: with DevTools open, record the computed-style / cascade-origin panel for the "Create course" button's winning `background-color` declaration, closing out the unverified CSS injection-order question with observed fact.
- **Pass condition:** readable button text in every state at every viewport tested; no invisible-button regression; no change to secondary or neutral panel buttons; no native dialog; cascade-origin evidence captured. A clean console is never pass evidence.

---

## Part B — Issue #22 (LS-QA-011): fixture band rename (option (b) selected by the user)

### Decision

The user reviewed the evidence chain below and selected **option (b)**. The status-pill badge itself is not a defect: it faithfully reports `course_versions.status = 'published'`, a value written unconditionally by the backfill migration for every band. The defect is presentational only: the fixture band's own name contains the word "(Unpublished)", which visually collides with the green "published" badge during local QA and reads as a status contradiction even though it is not one.

The remedy is a rename of the fixture band, applied consistently everywhere the literal string is treated as a functional identifier, with two deliberate, evidence-based exclusions (historical records) and one deliberate retention (a legacy contamination-detection entry).

**Option (c) — changing the backfill migration's unconditional `published` status for a zero-lesson band's `course_versions` row — remains explicitly out of scope.** It is a data-model change with its own blast radius (the `student_enrollments.course_version_id` backfill at migration line 212 depends on `status = 'published'`) and would require its own separate plan if the user chooses to pursue it later.

### Evidence chain

1. `supabase/seed.sql:103-112` inserts four rows into `public.bands`. The fourth is literally named `'Advanced Immersion (Unpublished)'` with description `'Test fixture: announced band with no published lessons yet (SPOT-03 empty-state fixture).'` The `(Unpublished)` string is part of the **band name**, deliberately authored as descriptive fixture prose. `seed.sql:62-68` and `:107-110` document it as the SPOT-03 empty-state fixture, deliberately given zero lessons so `BandRoadmap`'s "no weeks published yet" empty state is reachable via a real sign-in by `student6@test.local` (`seed.sql:254-260`).
2. `supabase/migrations/202608280003_issue5_course_authoring.sql:207-210` backfills a `public.courses` row from every band, using `b.name` as the course `title`. The fixture band therefore becomes a course titled "Advanced Immersion (Unpublished)". The same migration's repair function at lines 561-574 does the same on re-run.
3. That same migration, at lines 204-206 and again at 572-574, unconditionally inserts a `course_versions` row with `status = 'published'` for every band, with no check for whether the band has any lessons.
4. `supabase/functions/course-authoring/index.ts:83-93` (`list_courses`) computes each summary's `status` as `v?.status === 'published' ? 'published' : 'draft'`, reading the latest `course_versions` row.
5. `src/pages/CourseSettingsPage.tsx:8` renders `<span className={`status-pill ${c.status}`}>{c.status}</span>`; `src/pages/CourseWorkspace.css:1` styles `.status-pill.published { color: #226b45 }` (the green badge).

**Evidence-based read:** the badge is technically correct. It faithfully reports `course_versions.status = 'published'`, which the backfill migration genuinely assigned. The word "(Unpublished)" in the title is unrelated fixture prose in the band name, not a status field. This is primarily a naming coincidence at the display layer, not a status/badge mismatch bug in the badge-rendering logic.

However, one arguable latent defect sits underneath: the backfill marks every projected v1 as `published` regardless of whether the band has any lessons, so a zero-lesson band is presented as a published course. Containment already exists: `scripts/provision-lessons.ts:166` and `:1399-1405` hard-block this fixture band from any production target as "FIXTURE DATA CONTAMINATION", and `docs/cutover-evidence/G9a-content-completeness-*.md` records zero such rows. `README.md:170,178` confirms `seed.sql` is local-fixture-only and never production data. The observed condition is therefore reachable only on a local `supabase db reset` and cannot reach production.

### Rename target and rationale

`Advanced Immersion (Unpublished)` becomes `Advanced Immersion (Empty Fixture)`. This keeps the "fixture" signal that the contamination guard and `README.md` rely on, drops the "Unpublished" word that collides with the published status badge, and stays descriptive of the SPOT-03 zero-lesson empty-state purpose.

### Corrected scope enumeration (supersedes the earlier draft's estimate)

The earlier draft of this plan estimated the rename's blast radius at "six test files and two [cutover-evidence] documents." An independent full-repository literal-string search for `Advanced Immersion (Unpublished)`, run while resolving this section, found **21 occurrences across 9 files** (not the 20 occurrences across 9 files reported when this section was requested; the requester's own itemized test-file list totaled 7 occurrences, not 6, and this table reproduces that corrected count). The table below is the authoritative, line-verified enumeration and supersedes both prior estimates.

**Edit — source of truth (2 files, 9 occurrences):**

| File | Line | Occurrence kind | Action |
|------|------|------------------|--------|
| `supabase/seed.sql` | 63 | Explanatory comment | Edit |
| `supabase/seed.sql` | 111 | `public.bands` insert value (functional) | Edit |
| `supabase/seed.sql` | 254 | Explanatory comment | Edit |
| `supabase/seed.sql` | 259 | `where name = '...'` lookup attaching student6's enrollment (functional; must change atomically with line 111 or the enrollment silently attaches to nothing) | Edit |
| `scripts/provision-lessons.ts` | 16 | Doc comment | Edit |
| `scripts/provision-lessons.ts` | 166 | `band_name` entry in the fixture-identifier registry (functional; retain legacy name alongside — see safety requirement 1 below) | Edit (add, do not replace) |
| `scripts/provision-lessons.ts` | 1399 | Inline comment | Edit |
| `scripts/provision-lessons.ts` | 1402 | `bandNames.includes(...)` contamination check (functional; must flag either name — see safety requirement 1) | Edit (add, do not replace) |
| `scripts/provision-lessons.ts` | 1405 | Contamination error message text | Edit |

**Edit — tests (3 files, 7 occurrences):**

| File | Line | Occurrence kind | Action |
|------|------|------------------|--------|
| `src/__tests__/durableFullCatalogSeeding.test.ts` | 102 | Test title | Edit |
| `src/__tests__/durableFullCatalogSeeding.test.ts` | 103 | `.eq('name', '...')` query (functional) | Edit |
| `src/__tests__/provision-lessons.test.ts` | 75 | `FIXTURE_IDENTIFIERS` array entry (functional; `containsFixtureIdentifier` at lines 82-84 does exact substring matching; retain legacy string alongside — see safety requirement 1) | Edit (add, do not replace) |
| `src/__tests__/provision-lessons.test.ts` | 167 | Assertion string (`'should detect fixture band name'` test) | Edit |
| `src/__tests__/provision-lessons.test.ts` | 209 | Fixture object (`'should reject a manifest containing fixture band names'` test) | Edit |
| `src/__tests__/rlsIntegration.test.ts` | 143 | Trailing comment on `expect(count).toBe(4)` | Edit (cosmetic, for consistency) |
| `src/__tests__/rlsIntegration.test.ts` | 784 | `console.log` text | Edit (cosmetic, for consistency) |

**Edit — documentation (1 file, 2 occurrences):**

| File | Line | Occurrence kind | Action |
|------|------|------------------|--------|
| `README.md` | 170 | Seed fixture baseline description | Edit |
| `README.md` | 178 | Seed fixture baseline description | Edit |

**Do not edit — deliberate exclusions (3 files, 3 occurrences):**

| File | Line | Reason |
|------|------|--------|
| `docs/cutover-evidence/G9a-content-completeness-20260726T021053Z.md` | 29 | Timestamped historical evidence record of a completed production-readiness verification run. It correctly records what was true at that moment; editing it would falsify an evidence artifact. This reverses the earlier draft's enumeration, which had listed this file as an in-scope edit. If the discrepancy needs acknowledging, a future evidence run records the new name; this historical file stays untouched. |
| `docs/cutover-evidence/G9a-content-completeness-20260726T022915Z.md` | 50 | Same reason as above. |
| `supabase/migrations/202607250001_seed_canonical_bands.sql` | 3 | Comment inside an already-applied migration. Applied migrations are treated as immutable; the comment is non-functional and describes historical intent. |

### Mandatory safety requirements

**Safety requirement 1 — the production-contamination guard must not regress.** `scripts/provision-lessons.ts:166` is the registry entry the production guard (`scripts/provision-lessons.ts:1399-1407`) uses to detect fixture data by band name. If the old name is simply replaced with the new one, a production database that already contains a row named `Advanced Immersion (Unpublished)` would no longer be detected as contamination. The registry must therefore list **both** names: retain the existing entry `{ type: 'band_name', value: 'Advanced Immersion (Unpublished)', description: 'Legacy fixture band name, retained for contamination detection' }` (description updated) and add a new entry `{ type: 'band_name', value: 'Advanced Immersion (Empty Fixture)', description: 'Fixture band for empty-state testing' }`. The `bandNames.includes(...)` check at line 1402 must be updated to flag either name (for example, `bandNames.includes('Advanced Immersion (Unpublished)') || bandNames.includes('Advanced Immersion (Empty Fixture)')`). Correspondingly, `src/__tests__/provision-lessons.test.ts:75`'s `FIXTURE_IDENTIFIERS` array must retain both strings, and a new test case must assert that the legacy name is still detected as contamination via `containsFixtureIdentifier`.

**Safety requirement 2 — a clean database reset is mandatory, not optional.** `supabase/seed.sql:112` uses `on conflict (name) do nothing`, and `public.bands.name` is unique. On a developer's existing local database that is not reset, the renamed insert at line 111 creates a **fifth** band rather than renaming the fourth, because the old row (still named `Advanced Immersion (Unpublished)`) is untouched by `on conflict do nothing` and the new row inserts alongside it. `src/__tests__/rlsIntegration.test.ts:143` asserts `expect(count).toBe(4)` and would fail under that condition. Every validation run for Part B must therefore begin with a full `npx supabase db reset`, and if the count-4 assertion fails, a stale local database is the expected first diagnosis, not a code defect.

### Ordered work

Owner for B1-B6: T1. Sequenced after Part A's work and dependent on Part A's Step 0 environment bring-up (same `npx supabase start` / `.env.local` / dev-server session; Step 0 is not repeated).

- **B1.** Update `scripts/provision-lessons.ts`: add the new `band_name` entry, retain the legacy entry (updated description), and update the `bandNames.includes(...)` check at line 1402 to flag either name. Update the doc/inline comments at lines 16 and 1399, and the error message text at line 1405.
- **B2.** Update `src/__tests__/provision-lessons.test.ts`: retain the legacy string in `FIXTURE_IDENTIFIERS` (line 75), add the new string, update the assertion at line 167 and the fixture object at line 209 as needed for the new name, and add a new test case asserting the legacy name is still detected as fixture contamination. This new test should fail before B1 and pass after; the engineer may write it first if preferred, consistent with the project's TDD-first rule. It is sequenced after B1 here only because both items touch the same guard pair.
- **B3.** Update `supabase/seed.sql` lines 63, 111, 254, and 259 together as one atomic edit. Do not change line 111 without also changing line 259, or student6's enrollment silently attaches to nothing.
- **B4.** Update `src/__tests__/durableFullCatalogSeeding.test.ts` (lines 102-103) and `src/__tests__/rlsIntegration.test.ts` (lines 143, 784).
- **B5.** Update `README.md` lines 170 and 178.
- **B6.** Run `npx supabase db reset`, then run the full test suite.
- **B7.** Owner: `verifier`. Independent verifier pass covering the diff and confirming the three deliberate exclusions (the two cutover-evidence files and the applied-migration comment) were left untouched.
- **B8.** Owner: `browser-validator`. Browser validation for Part B, mandatory:
  - Sign in as `owner@test.local` / `password`, open the admin course library, and confirm by screenshot that the card now reads "Advanced Immersion (Empty Fixture)" with no "(Unpublished)" text colliding with its green published badge.
  - Sign in as `student6@test.local` / `password` and confirm the band roadmap still shows "No weeks published yet," proving the renamed band kept its enrollment via the updated `seed.sql:259` lookup.

### Acceptance criteria

- Zero occurrences of the literal `Advanced Immersion (Unpublished)` remain in `supabase/seed.sql`, `src/__tests__/durableFullCatalogSeeding.test.ts`, `src/__tests__/rlsIntegration.test.ts`, and `README.md`.
- The string intentionally **remains** in `scripts/provision-lessons.ts` and `src/__tests__/provision-lessons.test.ts` as the retained legacy contamination-detection entry, and in the two cutover-evidence files and the applied migration comment as deliberate exclusions. A blanket "zero occurrences repo-wide" check would be wrong and must not be used as an acceptance test.
- `rlsIntegration.test.ts` still asserts exactly 4 bands after a clean reset.
- `durableFullCatalogSeeding.test.ts` still finds the renamed band and still asserts it has zero lessons.
- A new test asserts the legacy name is still detected as fixture contamination.
- Full suite green; `npm run type-check` and `npm run lint` show no new failures against the Step 0 baseline; `npm test -- --run nativeDialogPolicy` still passes.
- Browser validation B8 passes with screenshots. Unit tests alone are not completion evidence.

### What happens next

This plan authorizes both Part A and Part B once the user gives explicit approval of this document (status header above). No engineering writer may begin either part before that approval is recorded. Part A and Part B may proceed independently once approved; neither blocks the other.
