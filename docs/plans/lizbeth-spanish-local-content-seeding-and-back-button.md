# Lizbeth Spanish: Local Content Seeding, Full-Access Test Student, and Back-to-Roadmap Styling

## Status

**Approved — 2026-07-21.** The user has explicitly approved this plan as-is, with no revisions requested. This approval covers the three in-scope items (durable full-catalog content seeding, the durable full-access test student plus flashcards-format fix, and the CSS-only "Back to roadmap" styling fix) exactly as scoped in "Scope and non-goals" below. Approval of this plan does not authorize any commit, push, pull request, deploy, or hosted/Netlify/Supabase promotion; those remain subject to the separate explicit go-ahead required in "Non-goals."

## Outcome and audience

**Audience:** the course owner (Lizbeth), who approves this plan before any engineering begins.

**Outcome:** an executable plan delivering three independently verifiable local/dev work items in the `lizbeth_spanish` app:

1. Durable full-catalog content seeding, so a plain `supabase db reset` alone yields all real authored curriculum for all 3 bands x 26 weeks (no manual script run required afterward).
2. A durable full-access test student that genuinely sees all bands/weeks, verified through the app's own access logic (RLS + roadmap computation), plus a fix to the provisioned-flashcards format so flashcards render as interactive cards instead of a plain download.
3. A CSS-only fix that brings the student "Back to roadmap" control in line with the Field Workbook design system, browser-validated.

Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (local/dev only). This plan does not touch the orchestrator root.

## Scope and non-goals

### In scope

- **Item 1 - Durable full-catalog seeding (Decision D1 = Option B):** make the full authored curriculum durable across `supabase db reset`, not merely runnable on demand. All 78 lesson rows carry real authored titles (sourced from each `curriculum/lessons/<band>-week-NN/README.md`), and each of the 74 non-fixture weeks (Beginner 5-26, Intermediate 1-26, Advanced 1-26) gets its resource rows (PDF handout, instructor PPTX, weekly-review recap, flashcards) pointing at durable storage-seed files.
- **Item 2 - Durable full-access test student (Decision D3 = Option A) + flashcards format fix (Decision D2):** add a durable full-access fixture account with ACTIVE enrollments in all three real bands, aged so all 26 weeks unlock; and correct the flashcards ingestion/format mismatch so provisioned flashcards for weeks 5-26/Intermediate/Advanced render as real interactive flashcards, not a plain download.
- **Item 3 - Back-to-roadmap styling:** a CSS-only fix bringing `.week-detail-back-link` in line with the design system, browser-validated.

### Non-goals

- No production data, no hosted/deployed Supabase project, no Netlify/hosted promotion, and no hosted secrets. Local Supabase (`127.0.0.1`) only.
- No commit, push, PR, deploy, or any promotion step without a SEPARATE explicit user go-ahead. (A push occurred in a separate, concurrent job for unrelated prior work; that approval does not extend to this plan.)
- No change to the RLS entitlement policies, the admin user-management feature, or the auth model. Those shipped and were verified/browser-validated in the prior increment; see `docs/plans/lizbeth-spanish-admin-user-management.md` and `docs/plans/lizbeth-spanish-browser-verification-closeout.md`.
- Do NOT restyle or touch the admin "Back to roster" control (`.detail-back-link`) or `.demo-button*`. **Observation, out of scope:** `.detail-back-link` in `src/pages/AdminStudentsPage.css` uses off-system `--color-primary-600/700` blue fallbacks — a separate latent inconsistency, deliberately not conflated with this fix.
- No new design primitives, fonts, radius tiers, or JSX changes for Item 3.

## Repository findings and evidence references

All findings below are Planner's read-only repository observations (no external research was used; `research_evidence: none` — this is local-only work).

### Content seeding (Items 1 and 2)

- `supabase/seed.sql` is an intentionally lightweight local fixture (documented in `README.md` "Local Supabase Setup and Content Provisioning" and `DEPLOYMENT_NOTES.md"). It deletes and recreates bands/lessons/resources/enrollments; creates 4 real bands (Beginner, Intermediate, Advanced, and the fixture "Advanced Immersion (Unpublished)" empty-state band); creates 7 synthetic auth users (`student1-6@test.local`, UUIDs ending `...001`-`...006`; `student7` pending `...007`; `owner@test.local` `...099` with `raw_app_meta_data role=owner`); creates lesson rows for all 26x3 weeks but with GENERIC titles for everything except Beginner weeks 1-4 (which have real titles); and attaches resource rows ONLY for Beginner weeks 1-4. Empty-state fixtures: `student5` has zero enrollments; `student6` is enrolled only in "Advanced Immersion (Unpublished)" (no lessons, so it exercises the empty state).
- The full authored curriculum EXISTS in `curriculum/lessons/` for ALL 78 weeks (`beginner`/`intermediate`/`advanced`-week-01..26). Each folder has a `README.md` (title header `# <Band>, Week N: <Title>`), `vocabulary-list.md`, `phrases-and-qa.md`, `practice-activity.md`, `weekly-review-recap.md`, `flashcards.md`, plus binary assets (instructor `.pptx`, student-handout `.pdf`; intermediate/advanced also `.docx`; Beginner week 1 has images).
- An ingestion tool already exists: `scripts/provision-lessons.ts` (run via `npx tsx scripts/provision-lessons.ts`). It scans `curriculum/lessons`, extracts real titles from each README, upserts lessons keyed by `(band_id, week_number)`, replaces each lesson's resource rows, copies per-week files into `supabase/storage-seed/lesson-assets/<band>/week-NN/`, and uploads them to the local `lesson-assets` bucket. It deliberately SKIPS Beginner weeks 1-4 (preserving the fixtures) and refuses to run against fixture identifiers or hosted targets; it is LOCAL-only (`127.0.0.1`) with a hosted-safety preflight and postrun guard.
- **Root cause that the content "was never loaded":** the script's database writes (lesson titles, resource rows) are NOT captured in `seed.sql`, so `supabase db reset` (or any fresh seed/migration apply) reverts them to `seed.sql`'s lightweight baseline, WHILE the storage-seed files ARE durable (repopulated on reset from `supabase/storage-seed` via `config.toml`'s `[storage.buckets.lesson-assets] objects_path`). Observable state today: real files sit in storage-seed for beginner/intermediate/advanced (confirmed present through `advanced/week-26`), but the database has resource rows only for Beginner 1-4, so the app treats weeks 5-26/Intermediate/Advanced as unreachable. This is documented in `DEPLOYMENT_NOTES.md` under "Data Provisioning Order (CRITICAL — never reset after provisioning)".
- **Durability lever:** `supabase/config.toml`'s `[db.seed] sql_paths` currently equals `["./seed.sql"]` and accepts an ORDERED LIST of seed files. Lessons are uniquely keyed on `(band_id, week_number)` (migration `202607170001_init_schema.sql`; the script upserts `onConflict 'band_id,week_number'`); resources have a unique `(storage_bucket, storage_path)` constraint (migration `202607170006`).
- **Flashcards format mismatch (Decision D2):** `src/components/ResourcesPanel.tsx` fetches a flashcards resource's signed URL and runs `src/lib/flashcardsFormat.ts`'s `parseFlashcardsYaml` over the response text. That parser targets a NARROW record shape (`- id: N` then 2-space `group/front/back/register/dialect/badges/note` fields). The Beginner 1-4 fixtures point at pure `flashcards.yaml` files (records only). But `scripts/provision-lessons.ts` creates flashcards resources pointing at `flashcards.md`, which is a FULL markdown document (a human-readable table plus a fenced ```yaml "Machine-readable card data" block). The parser tolerates extra lines by ignoring non-matching ones, so it may extract the embedded block, but this is fragile and undocumented, and inconsistent with the tested `.yaml` fixture convention. The reliable, consistent fix is to standardize provisioned flashcards on the same pure-`.yaml` record format the renderer and fixtures use.
- **RLS unlock:** resource visibility gates on `enrollment_date + lessons.unlock_offset_days` (`(week-1)*7`) AND (per the prior increment, migration `202607200002`) enrollment `status='active'` AND account active. To unlock all 26 weeks, an `enrollment_date` at least ~175 days old (week 26 offset = 175) or a completed enrollment suffices.
- **Student3 fact:** seed `student3@test.local` (`...003`) is enrolled only in Beginner (completed) plus Intermediate (fresh, 5 days), NOT Advanced, and the Intermediate enrollment unlocks only early weeks. `student3` does NOT have full access to all bands/weeks. Admin-UI-created runtime accounts/enrollments do not survive `db reset`. A durable full-access tester must therefore live in `seed.sql` (Decision D3 = Option A).
- **Tests coupled to the lightweight seed** (D1 risk surface): `src/__tests__/rlsIntegration.test.ts`, `storageIntegration.test.ts`, `rlsPolicies.test.ts`, and empty-state coverage (RoadmapPage/BandRoadmap empty states, App tests, ResourcesPanel). The native-dialog scan `src/__tests__/nativeDialogPolicy.test.ts` and the heading-clearance test `src/__tests__/HeadingAccessibilityButtonClearance.test.ts` are also part of the suite.
- **Tooling:** `package.json` scripts `dev` (vite, port 5173 per `vite.config.ts`), `build` (`tsc && vite build`), `test` (vitest), `lint`, `type-check`. Playwright is present; `playwright.config.ts`'s `baseURL` is `process.env.E2E_BASE_URL || 'http://localhost:5173'`, matching vite's `5173`. **RESOLVED, 2026-07-25:** the previously noted 5176/5173 mismatch is stale; direct observation of the current file confirms no reconciliation is needed.

### Back-to-roadmap button (Item 3)

- Rendered in `src/App.tsx` lines 104-110: `<button type="button" className="week-detail-back-link" onClick={() => navigate('/roadmap')}>&larr; Back to roadmap</button>`, shown above `<WeekDetailPage>` on a week-detail route; it is the literal first child of `.app-main` on that route.
- The class `week-detail-back-link` has NO CSS rule anywhere (`src/pages/WeekDetailPage.css` defines other `.week-detail-*` classes but not this one), so it renders with browser-default button appearance. This missing rule is the entire defect.
- **Design tokens available:** `src/App.css`'s `:root` (`--color-ink-700` `#504940`, `--color-ink-900` `#2a2420`, `--color-accent-primary`, `--color-surface-reading-default` `#fdfcf9` body background, `--space-*`, `--font-family-body`, `--typography-fontSize-*`, `--a11y-trigger-footprint`, `--text-size-multiplier`, `--color-focus-ring`); `src/tokens/{primitives,semantic,components}.json`. A global focus ring exists at `src/App.css` lines 122-131 (`button:focus, ... { outline: 2px solid var(--color-focus-ring); outline-offset: 2px; }`). The <=640px "Aa" accessibility-trigger clearance invariant ("J-001") lives in the existing `@media (max-width: 640px)` block (`.app-main h1 { padding-right: calc(var(--a11y-trigger-footprint) + var(--space-2)); }`), covered by `src/__tests__/HeadingAccessibilityButtonClearance.test.ts`.

## Design route

**Profile:** Compact.

**Reasons:** a single bounded brownfield styling fix bringing one existing, unstyled control in line with the established Field Workbook system; no new screen, flow, or component.

**Agents required:** design-generalist + design-reviewer.

**Prototype:** forbidden.

**Model tier:** Sonnet.

**Existing-system mode:** extend (add a missing token-based rule consistent with existing patterns).

## Reviewed design handoff (engineering-binding)

- **Semantic role:** a tertiary "back" text-link affordance (borderless, no background, underlined ink text) — NOT a `.demo-button`. Reuse existing Field Workbook tokens only; do NOT copy the admin sibling's off-system `--color-primary-600/700`.
- **Base rule** — add exactly one scoped rule for `.week-detail-back-link` (placed in `src/pages/WeekDetailPage.css` or `src/App.css`) with these token-based declarations:

  ```css
  .week-detail-back-link {
    display: inline-block;
    margin: 0 0 var(--space-4) 0; /* --space-3 or --space-6 also acceptable; must stay a --space-* token */
    padding: 0;
    border: none;
    background: none;
    color: var(--color-ink-700);
    font-family: var(--font-family-body);
    font-size: calc(var(--typography-fontSize-base) * var(--text-size-multiplier)); /* required multiplier form — matches every other font-size rule in the repo */
    font-weight: 400; /* may be omitted; inherited body weight is also 400 */
    text-decoration: underline; /* or text-decoration-line: underline; text-underline-offset: 2px; */
    cursor: pointer;
  }
  ```

- **Hover:** `.week-detail-back-link:hover { color: var(--color-ink-900); }`
- **Active:** `.week-detail-back-link:active { color: var(--color-ink-900); }`
- **Focus:** no new rule — the real `<button>` inherits the visible global focus ring (`src/App.css` lines 122-131).
- **Small-viewport clearance (required):** inside the EXISTING `@media (max-width: 640px)` block in `src/App.css`, add:

  ```css
  .week-detail-back-link {
    padding-right: calc(var(--a11y-trigger-footprint) + var(--space-2));
  }
  ```

  This mirrors `.app-main h1` and reuses only existing tokens. Because this button is `.app-main`'s first child on the week-detail route, this prevents the fixed top-right "Aa" trigger from obscuring its text or focus ring when scrolled to top (WCAG 2.4.11).
- **Engineering invariants:** CSS-only (no JSX/className/label/handler/position change); do not modify `.demo-button*`, the admin `.detail-back-link`, the existing `.app-*h1` clearance rules, or `HeadingAccessibilityButtonClearance.test.ts`; introduce no new hex/token/font/radius tier; keep the base rule scoped to `.week-detail-back-link` only; the <=640px declaration must live in the existing media block.
- **Contrast:** `--color-ink-700` on the body background measures approximately 8.6:1 (AA pass, independently confirmed by the reviewer); the affordance is not color-only (arrow glyph plus underline).

**Design review result:** PASS (Compact). The independent design-reviewer verified the root cause, token claims, focus rule, and contrast in round 1 and approved the <=640px clearance. Its single round-2 finding — that the font-size declaration must use the repo-universal `--text-size-multiplier` form — was adjudicated and approved by the user and is folded into the binding declarations above. No open design decisions remain.

## Judge route

`PLAN_DUCK` eligible as advisory only, under `docs/JUDGE-CONTRACT.md` (medium-risk local change). No judge result blocks completion; deterministic checks (the test suite, database queries, Verifier, Browser Validator) dominate.

## Ordered work (each item independently acceptance-checked)

### Item 1 — Durable full-catalog seeding (Decision D1 = Option B)

1a. Introduce a durable seed of the full authored catalog so `supabase db reset` alone yields all real content. Recommended approach (engineering may choose an equivalent that meets the invariants below): add a generated, committed SQL seed file (for example `supabase/seeds/full-catalog.sql`) produced from the curriculum manifest — reusing `scripts/provision-lessons.ts`'s scan/title-extraction logic, either via a generator that emits SQL or an adaptation of the existing script — and register it AFTER `./seed.sql` in `config.toml`'s `[db.seed] sql_paths`. It must:
   - Upsert real titles for all 78 lessons (`ON CONFLICT (band_id, week_number) DO UPDATE`).
   - Insert resource rows for the 74 non-fixture weeks (Beginner 5-26, Intermediate 1-26, Advanced 1-26).
   - SKIP Beginner weeks 1-4 entirely (leave their fixture lessons/resources untouched).
   - NEVER add lessons to the "Advanced Immersion (Unpublished)" empty-state band.
   - Be conflict-safe and idempotent.

1b. Ensure `supabase/storage-seed/lesson-assets` contains the durable per-week files the resource rows reference for every seeded week (already present for beginner/intermediate/advanced through week-26; regenerate or complete as needed, including the standardized flashcards format from Item 2 / Decision D2).

1c. Keep `scripts/provision-lessons.ts` as the HOSTED provisioning tool and/or the generator source; update its `FIXTURE_IDENTIFIERS` to include the new full-access account (Item 2) so its production guard still rejects it.

**Acceptance check:** after a clean `supabase db reset` (no manual script run), query the local database and confirm:
- (a) each real band has 26 lessons with REAL authored titles (not the generic "Week N: <Band> Lesson" placeholders) for the provisioned weeks;
- (b) resource rows now exist for previously empty weeks/bands (for example Intermediate week 1, Advanced week 26) — total resources approximately >= 234;
- (c) the "Advanced Immersion (Unpublished)" band still has 0 lessons;
- (d) Beginner weeks 1-4 fixture lessons/resources are unchanged.

Provide the SQL queries and their outputs as evidence.

### Item 2 — Full-access test student (Decision D3 = Option A) + flashcards fix (Decision D2)

2a. Add a durable full-access fixture account to `seed.sql`, following the EXACT existing `auth.users` seed pattern (all NOT-NULL token columns set to `''`, `email_confirmed_at` set, `aud`/`role` `'authenticated'`, `last_sign_in_at` set as an established account). Recommended: a new account `fullaccess@test.local`, UUID `00000000-0000-0000-0000-000000000008` (next after `student7`'s `...007`) — chosen over extending `student3` so that student3's existing fixture scenarios (completed Beginner + fresh Intermediate) remain undisturbed given Item 1's now more invasive seed rework. Give it ACTIVE enrollments (`status='active'`) in all THREE real bands with `enrollment_date` approximately `now() - interval '200 days'` (>= 175 days) so all 26 weeks unlock in each band.

2b. Flashcards format fix (Decision D2): standardize provisioned flashcards so the renderer shows interactive cards. Recommended: the ingestion/generation step produces a pure `flashcards.yaml` (the narrow record shape `parseFlashcardsYaml` expects, matching the Beginner 1-4 fixtures) for every non-fixture week — extracted from each `flashcards.md`'s fenced "Machine-readable card data" block — writes it into storage-seed, and points the flashcards resource row at the `.yaml` file. An alternative is permitted if it meets the acceptance check (for example, making the renderer robustly extract the fenced block directly), but the `.yaml` approach is preferred because it keeps the renderer and existing tests unchanged.

**Acceptance check:** verify EFFECTIVE access via the app's own logic (RLS + `computeWeekRoadmap`), not just enrollment-table rows: signed in as `fullaccess@test.local`, all three bands appear with all 26 weeks unlocked and resources retrievable via genuine signed URLs. Explicitly record that seed `student3` does NOT have full access (documented, so the "no new user needed" branch is correctly rejected). For flashcards (Decision D2): for a provisioned week (for example Intermediate week 1), the flashcards resource loads and `FlashcardsViewer` renders the correct interactive cards (not a plain download), browser-validated; add or adjust a unit test for the standardized flashcards format.

### Item 3 — Back-to-roadmap CSS fix

Implement exactly the reviewed design handoff above (CSS-only; no JSX/className/label/handler/position change).

**Acceptance check:** `src/__tests__/nativeDialogPolicy.test.ts` returns zero matches; the styled control matches the reviewed spec (underlined ink-700 text, ink-900 hover/active, visible inherited focus ring, <=640px unobscured by the "Aa" trigger at 375px/320px scrolled to top); before/after screenshots.

### Final steps (apply after Items 1-3)

- Update `README.md` and `DEPLOYMENT_NOTES.md` to describe the NEW durable-seed model: a plain local `supabase db reset` now yields the full catalog; the reset-then-provision ordering caveat now applies to HOSTED targets only, not routine local dev.
- Independent Verifier pass.
- Then Browser Validator pass.

**Regression check (Decision D1 risk mitigation — mandatory across all items):** full `npm test` passes, specifically confirming `src/__tests__/rlsIntegration.test.ts`, `storageIntegration.test.ts`, `rlsPolicies.test.ts`, the empty-state tests, `HeadingAccessibilityButtonClearance.test.ts`, and `nativeDialogPolicy.test.ts` still pass after the seed rework. If any fixture assumption genuinely changes (for example, a roster-count assertion due to the new account), adjust that fixture/assertion AS PART OF THIS PLAN's implementation and document it. `tsc && vite build`, `npm run type-check`, and `npm run lint` must all be clean.

**Gates:** independent Verifier pass THEN Browser Validator pass, required before any completion claim. Deterministic checks dominate any advisory judge signal.

## Interfaces and data

- `config.toml`'s `[db.seed] sql_paths` becomes an ordered list loading `./seed.sql` then the durable catalog seed.
- New durable catalog SQL: lessons upserted on `(band_id, week_number)`; resources inserted respecting the unique `(storage_bucket, storage_path)` constraint; per-week `storage_path` = `"<band-lower>/week-NN/<file>"`.
- New seed account `fullaccess@test.local` (`...008`) plus three active `student_enrollments` rows (`status='active'`), one per real band, each aged >= 175 days.
- Flashcards resources reference a pure `.yaml` record file per the standardized format.
- Compatibility preserved: Beginner 1-4 fixtures, the empty-state band, the `student5` zero-enrollment fixture, the `student6` empty-band fixture, and all RLS policies remain unchanged.

## Browser UI dialog policy

The "Back to roadmap" control is navigation-only (calls `navigate('/roadmap')`); no native `alert`/`confirm`/`prompt`/`window.*`/`beforeunload` anywhere in this work. This is enforced by `src/__tests__/nativeDialogPolicy.test.ts` (a deterministic whole-`src` scan that automatically covers changed files), plus manual keyboard/focus verification during browser validation. This policy is a hard boundary: no browser-rendered UI change in this plan may introduce a native dialog of any kind.

## Browser-validation brief

- **Launch/readiness:** `npx supabase start` (or `supabase db reset` to apply migrations, `seed.sql`, and the durable catalog seed — the storage bucket auto-populates from storage-seed per `config.toml`), then `npm run dev`.
- **Base URL:** the local dev origin, `http://localhost:5173`. **RESOLVED, 2026-07-25:** `vite.config.ts` (5173) and `playwright.config.ts`'s `baseURL` already match; the previously noted `5176` figure was stale and no reconciliation is needed. Routes: `/roadmap` and `/roadmap/:enrollmentId/week/:weekNumber`.
- **Fixture/reset:** `supabase db reset`; sign in as `fullaccess@test.local` (password `password`, per the seed convention).
- **Journeys:**
  - *(Item 3)* Open a week-detail view (for example Intermediate week 1). Confirm the "Back to roadmap" control renders as a styled underlined ink text-link (no default button chrome), matches the design system, click returns to `/roadmap`, keyboard focus shows the 2px ring, Enter and Space both activate it, hover darkens ink-700 to ink-900, and at 375px/320px scrolled to top it is not obscured by the fixed "Aa" trigger. Compare against the admin "Back to roster" control as a consistent back-affordance class (visual comparison only; do not restyle it).
  - *(Items 1 and 2)* As `fullaccess@test.local`, open previously empty weeks (for example Intermediate week 10, Advanced week 20) and confirm the resources panel shows real PDF/PPTX/weekly-review/flashcards with working signed URLs, and the flashcards viewer shows interactive cards. Confirm all three bands show all 26 weeks unlocked.
- **Viewport profiles:** desktop >= 1024px, tablet ~768px, mobile ~375px (and 320px specifically for the back-link clearance check).
- **Visible outcomes:** before/after screenshots of the back-link; screenshots of a now-populated week's resources and the flashcards viewer; confirmation that no native dialogs appear at any point.

## Risks and rollback

**Risk tier:** Medium (local/dev only; no production or RLS-policy change; but the seed rework couples to existing RLS/empty-state test fixtures, and Item 3 is a browser-rendered change).

- **R1 (flagged under Decision D1):** the durable full-catalog seed rework could break tests/fixtures that assume the lightweight seed (`rlsIntegration`/`storageIntegration`/`rlsPolicies`, empty-state, roster count). **Mitigation:** preserve Beginner 1-4 fixtures, the empty-state band, and the `student5`/`student6` fixtures exactly; run the full test suite after the change and require the named tests to pass; adjust only genuinely changed fixtures within this plan, documented. **Rollback:** revert `config.toml`'s `sql_paths` to `["./seed.sql"]` and remove the catalog seed file to restore the prior lightweight baseline (storage-seed files are inert without matching resource rows).
- **R2:** the flashcards format fix could regress Beginner 1-4 (which already use `.yaml`). **Mitigation:** leave Beginner 1-4 untouched; add a test for the standardized format; browser-validate one provisioned week.
- **R3:** the new full-access account could perturb admin-roster or auth tests. **Mitigation:** follow the exact seed `auth.users` column pattern; run the full suite; adjust count assertions if any are affected.
- **R4:** Item 3 could introduce accessibility regressions (focus obscured at a small viewport, or text that does not resize). **Mitigation:** the <=640px clearance rule, the multiplier font-size form, retaining the global focus ring, the `nativeDialogPolicy` and `HeadingAccessibilityButtonClearance` tests, and Browser Validator coverage.
- **R5:** a base-URL mismatch between vite (`5173`) and Playwright was flagged as a risk in the prior draft of this plan. **RESOLVED, 2026-07-25:** direct observation of `playwright.config.ts` shows `baseURL: process.env.E2E_BASE_URL || 'http://localhost:5173'`, matching vite's `5173` exactly; the `5176` figure does not appear in the file and this risk did not materialize.

**Stale-plan trigger:** if `seed.sql`'s structure, the RLS policies, the lessons/resources schema or unique keys, `config.toml`'s seed mechanism, the flashcards renderer/parser, or the back-link markup change materially before or during implementation, the writer returns `JOB_BLOCKED "Plan stale"` for replanning or reapproval rather than proceeding on stale assumptions.

## Resolved decisions

- **D1 = Option B:** durable full-catalog seeding, so `supabase db reset` alone yields all content, WITH the R1 fixture-compatibility risk and mitigation documented above.
- **D2:** fix the flashcards format now so provisioned flashcards render as interactive cards; not deferred.
- **D3 = Option A:** a durable full-access fixture in `seed.sql`. Planner's explicit choice, stated here, is a NEW account `fullaccess@test.local` (`...008`) rather than extending `student3`, to avoid disturbing student3's existing fixture scenarios given D1's now more invasive seed rework.
- **D-DESIGN:** apply the `--text-size-multiplier` font-size remediation identified in the design review's second round; folded into the binding design handoff above (design review result: PASS).

## Safe assumptions

Engineering may proceed on the following unless the user changes them: the recommended durable-seed mechanism (a generated, committed catalog SQL file registered in `sql_paths`) and the recommended flashcards `.yaml` standardization are engineering-level implementation choices; any equivalent that meets the stated invariants and acceptance checks is acceptable. The full-access account's `enrollment_date` of approximately 200 days and `status='active'` are treated as reasonable defaults consistent with the >= 175-day unlock requirement.

## Approvals required

- Explicit user approval of THIS plan before any engineering work begins.
- A SEPARATE, explicit user go-ahead before any commit, push, PR, or deploy step, regardless of any approval granted for unrelated concurrent work.

## Engineering mode and downstream owner

**Engineering mode:** standard.

**Team authorization:** not applicable.

**Downstream owner:** `engineering-fleet`, after explicit user approval of this plan.
