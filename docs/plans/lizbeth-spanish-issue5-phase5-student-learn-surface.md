# Lizbeth Spanish, Issue #5 Phase 5: student `/learn` surface

Status: **Approved.** Phase 5 of five. Approval of this document authorizes only this phase. See "Approval record" below for the exact exchange.

Plan ID: `lizbeth-spanish-issue5-phase5-student-learn-surface`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: `engineering-fleet`, after explicit user approval of this plan
Roadmap: `docs/plans/lizbeth-spanish-issue5-roadmap.md`
Sibling plans (approved): `docs/plans/lizbeth-spanish-issue5-phase1-entitlement-primitives.md`, `docs/plans/lizbeth-spanish-issue5-phase2-cadence-authoring.md`, `docs/plans/lizbeth-spanish-issue5-phase3-owner-enforcement-controls.md`
Sibling plan (status not verified by this document): Phase 4 (hard re-lock / revoke owner controls). This plan assumes Phase 4's `revoked` state and its Phase-1 setter exist in the schema (they do, verified below), but does not assume Phase 4's owner-facing UI has shipped or been approved. Nothing in this plan depends on Phase 4's UI.
Design route for Phase 5: **standard**, re-verified against the built entitlement semantics rather than carried forward as-is; see the design-route section below for what changed and why.

## Blocking prerequisites

Per the roadmap's ship-gate G-ENT-1, Clause 2 ("that phase's plan must open with a 'Blocking prerequisites' section naming G-ENT-1"), this section opens the plan as required.

- **G-ENT-1 (`apply_version_migration` safety) is the binding gate on this phase.** Neither the Verifier pass nor the Browser Validator pass for Phase 5 may be claimed while G-ENT-1 is unsatisfied. This is a hard stop on completion, not an advisory, per the roadmap's Clause 2.
- **This plan re-verified G-ENT-1 at plan time rather than trusting the historical record, and found it genuinely intact.** Evidence: `supabase/migrations/202608300002_issue5_phase3_enforcement_sql_core.sql:57-116` replaces the destroy-and-recreate body with a guarded upsert. It performs targeted deletion only of lessons absent from the target version (lines 80-86), uses `on conflict ... do update` preserving every row's `manual_release_state`, `completed_at`, and `granted_at` by construction (lines 100-112), carries an explicit manual-override branch, and reuses Phase 1's monotonic guard verbatim (`when unlock_at <= now() then least(unlock_at, excluded.unlock_at)`). A repository-wide grep confirms `apply_version_migration` is defined only once, in `202608280003`, referenced in `202608300001`, and last redefined in `202608300002`; the Phase 4 migration `202608310001` does not touch it, so no later change has reopened the defect. All five mandatory G-ENT-1 acceptance assertions exist as live database-level tests in `src/__tests__/issue5-phase3-sql-core.test.ts:204-337` (labelled G-ENT-1.1 through G-ENT-1.5, plus a supporting absent-lesson case), including the student-role RLS assertion and the structural-separation assertion the roadmap requires.
- **Phase 5's own obligation is therefore not to re-fix the gate, but to re-run those five assertions as its first ordered step (Step 1 below), and to re-validate the gate through a real student session.** Per the roadmap's reframing finding, a database-level pass proves the backend is correct but does not prove a student experienced anything; that proof is the one thing Phases 1-4 could never produce, and it is this phase's defining acceptance check (see "Acceptance and validation" below).
- No other open ship-gate is recorded against this phase. This is the complete blocking-prerequisites statement for Phase 5, satisfying the roadmap's Clause 3 requirement that every phase plan state its gates or `none`.

## Outcome and audience

An enrolled student can, for the first time in this product, see and act on the entitlement system built across Phases 1-4. Two new routes, `/learn` (an index of the student's enrolled courses) and `/learn/:enrollmentId` (a per-course lesson roster), show per-lesson unlock status honouring the real `unlock_at`, the rolling-vs-cohort anchor, held/revoked state, and prerequisite gating, and let the student mark a lesson complete.

Audience is the enrolled student, primarily. Secondarily, the course owner, who finally gets end-to-end confirmation that Phases 1-4 work as designed, since nothing before this phase could demonstrate that a real student session reflects an entitlement setting.

## Scope and non-goals

**In scope:**

1. A new `security definer` student-read RPC (or small set of RPCs) granted to `authenticated`, returning the per-lesson and per-course fields defined in "Interfaces and data" below, subject to the binding leak prohibition in that section.
2. The `/learn` index route: loading, error, empty-zero, and populated page states; an `.enrollment-card` per enrollment; a materialization badge for the legacy-unmaterialized case; and correct link targets to each enrollment's detail route.
3. The `/learn/:enrollmentId` detail route: loading, generic fail-closed error, `empty-legacy-unmaterialized`, `empty-zero-published-lessons`, and populated states, gated by the four-row legacy/materialization decision table specified below; the eight `.lesson-card` states; the inline Mark-as-complete two-step control; the disclosure pattern for locked-family explanation; and the cohort-not-started banner.
4. Two new route matchers in `src/hooks/useRoute.ts`, a new `App.tsx` dispatch branch, a nav link, and a new client data-access module in `src/services/` following `roadmapData.ts`'s anon-key/RLS-respecting convention.
5. Tests for all of the above, including database-role-scoped RLS assertions, leak-prohibition assertions, and component/accessibility tests.
6. Re-running the five G-ENT-1 database-level assertions as Step 1, and the real-student-session re-validation of G-ENT-1 as part of Step 7.

**Out of scope, deliberately:**

- Any modification to `RoadmapPage`, `WeekDetailPage`, `src/services/roadmapData.ts`, or `src/lib/weekUnlock.ts`. The legacy path is not touched, not deprecated, and not removed. See "The coexist-vs-replace answer" below for why.
- A full quiz-taking UI. `completion_rule` values other than `'view'` (namely `quiz_pass` and `manual`) get an honest forward-compatible fallback card only; no quiz interface is built this phase.
- A one-time backfill-materialization job for legacy-backfilled enrollments. Recorded as a user decision below, not built here.
- Any change to `record_lesson_completion`'s signature or behavior; it is consumed as-is.
- Any change to `get_lesson_progress_evidence` or `course_version_completion_ratio`; both are owner-only (`service_role`-granted) and this phase does not touch, expose, or build on them. See "Interfaces and data" for the explicit correction of a likely misreading here.
- A production data audit of how many real students are enrolled on the legacy band path. Not determinable read-only; see the finding below. Coexistence is chosen precisely so this audit is not a precondition.
- No commit, push, PR, or deploy.

## Verified repository findings

### The coexist-vs-replace answer

This is the plan's central architectural finding, stated prominently because it determines nearly every other decision in this document.

**The legacy path must coexist with the new `/learn` surface. `/learn` is strictly additive.** `RoadmapPage`, `WeekDetailPage`, `src/services/roadmapData.ts`, and `src/lib/weekUnlock.ts` are not modified, not deprecated, and not removed by Phase 5. The grounds are specific and verified:

- The two systems are already partially unified at the data layer, which is easy to miss on a first read. `202608280003_issue5_course_authoring.sql:203-232` projected the entire legacy catalog into the new model at migration time: a published `v1` `course_version` per band, one `lesson_revision` per legacy `lesson` (carrying `legacy_lesson_id` and a `legacy_assets` pointer), and `course_version_lessons` rows carrying the real `week_number` and `unlock_offset_days`. Line 212 then backfilled `course_version_id` onto every pre-existing `student_enrollments` row. A legacy enrollment therefore already has a course version in the new model.
- **But that backfill never materialized entitlements.** `materialize_enrollment_entitlements` is called only from the grant, migration, publish, and reconciliation sites; no migration calls it for the backfilled rows. A pre-existing legacy enrollment therefore has zero `enrollment_lesson_entitlements` rows today, and would render as an empty course on `/learn` without the dedicated empty-state handling specified below.
- **Legacy lesson content is not present in the new model at all.** `lesson_revisions.content` for a legacy-projected row is only a JSON pointer to `resources` rows in the legacy Storage path, gated by the legacy week-unlock RLS policies, not by the entitlement tables `/learn` reads.
- **Whether real, non-fixture students are currently enrolled on the legacy path in production could not be determined from a read-only repository inspection, and this plan states that limit rather than guessing.** What is determinable: `202607250001_seed_canonical_bands.sql` seeds the Beginner/Intermediate/Advanced bands as a migration, so they are production-canonical rather than a local test fixture; `supabase/seed.sql:103-270` additionally seeds many local test-fixture enrollments against them, which are local-only and do not resolve the production question.
- Given that ambiguity, coexistence is the only safe answer under either possible production state. Replacement would require a production data audit that is explicitly out of this phase's scope.

### The new student read path is mandatory, not optional

- `202608280003:531` revokes all table-level privileges on the entitlement tables from `anon` and `authenticated`; line 536 then re-grants `SELECT` to `authenticated` on `course_versions`, `lesson_revisions`, `course_version_lessons`, `enrollment_lesson_entitlements`, and others, but **not** on `course_assets`, which retains zero table-level privilege for `authenticated`.
- Even with those grants in place, row-level security makes a locked-state card unrenderable by a direct client query. Policy `entitlements_own` (`202608280003:527`) filters to rows where `unlock_at <= now() and manual_release_state not in ('held','revoked')`, and `course_version_lessons_student_read` (`202608280003:522`) requires a matching visible entitlement row to exist before any row is returned at all.
- A lesson whose prerequisite is unmet gets no entitlement row whatsoever (`202608280003:241-247`, `202608300002:88-99`), so it is invisible through every ordinary table read, not merely locked-looking.
- **Conclusion: a locked, held, revoked, or prerequisite-gated lesson cannot be shown to a student through a direct RLS-scoped table read, because RLS is designed to hide exactly those rows.** Phase 5 must add a new `security definer` student read RPC granted to `authenticated`, building its roster from a `course_version_lessons` LEFT JOIN `enrollment_lesson_entitlements`, so a locked lesson still produces a roster row (with no entitlement fields populated) rather than disappearing. There is a live precedent for this join shape in the codebase: `202608310001_issue5_phase4_revoked_roster_advisory.sql:76-89`, an owner-facing analogue. This is a mandatory architectural requirement of the phase, not an engineering-discretion choice.

### Functions Phase 5 consumes, and functions it must not consume

- **`record_lesson_completion(uuid, uuid)`** — the student write path, already granted to `authenticated` (`202608300002:373-406`). It re-checks visibility server-side, refuses a locked lesson, is monotonic (only ever sets `completed_at`, never clears it), and calls `recalculate_course_version_completion`. Phase 5 consumes it as-is, with no signature change.
- **`resolve_entitlement_anchor`** (`202608300001`) — the rolling-vs-cohort unlock anchor. The student surface must reflect both models; see the two date-locked card variants in the design specification below.
- **`get_lesson_progress_evidence`** (`202608290001:508-568`) — takes `p_owner_id` and is granted to `service_role` only. **This is an owner read.** Recorded here as an explicit correction of a plausible misreading: it is not available to the student surface, and no student-facing view may be built on it, directly or through a wrapper.
- **`course_version_completion_ratio`** (`202608300002:137-159`) — also `service_role`-only, and returns `NULL` rather than `0` for a zero-lesson version. The new student RPC must compute course progress itself, independently, rather than calling this function or exposing it.
- **`courses.legacy_band_id`** (`202608280003:26`) — the direct schema signal for whether a course is a legacy projection. `course_is_legacy` in the new RPC's output is derived from `legacy_band_id is not null`.

## The student read RPC's field contract and leak prohibition

This section is carried forward from the handoff as a binding interface requirement, stated here in prose ahead of the ordered work, because it governs both the SQL-core step and the leak-prohibition tests that gate it.

**Per-lesson fields the RPC must return:** position, title, `has_entitlement`, `unlock_at`, the anchor kind (rolling vs. cohort) and the cohort start date where applicable, `manual_release_state`, `completion_rule`, `completed_at`, and the resolvable prerequisite lesson's title where a prerequisite exists and can be resolved.

**Per-course fields the RPC must return:** course title, `course_is_legacy` (from `courses.legacy_band_id is not null`), `has_any_entitlement_row`, and self-computed completed/total lesson counts.

**Binding leak prohibition.** For any locked-family lesson (a lesson in any of the states `date-locked-rolling`, `date-locked-cohort`, `on-hold`, `prerequisite-incomplete`, or `unavailable-unspecified`, defined in the design specification below), the RPC must never return `lesson_revisions.content`, any `course_assets` row or path, any signed URL, or any `assessment_answer_keys` contents. This is the phase's defining risk (see R1 below): `course_assets` has no table-level grant for `authenticated` at all, so this `security definer` RPC is the only possible leak vector for that table, and its own return-shape discipline is the sole enforcement mechanism.

**Non-delegation prohibition.** The RPC must not delegate to `materialize_enrollment_entitlements`, `apply_enrollment_reconciliation`, or `apply_version_migration`. It is a pure read and must never write entitlement state, preserving Phase 1's R3 structural-separation guarantee (bulk reconciliation, targeted migration, and now student reads, are three structurally separate paths, none of which may absorb another).

## Design route

**Standard, re-verified against the built entitlement semantics rather than carried forward as-is.** The roadmap flagged this explicitly: Phase 5's design was "drafted within the already-passed Standard packet ... but should be reconfirmed against the built entitlement semantics before it builds, since Phases 1-4 may surface details ... the original draft did not have in hand." That caution was justified. `design-director` (Sonnet 5) re-verified the previously-passed Standard packet in `docs/plans/lizbeth-spanish-issue5-release-cadence-enforcement.md:133-200` and produced real revision, not a rubber stamp; the drift found is as substantial as the drift Phase 3 found in its own carried-forward packet.

### Drift ledger against the original packet

1. **`revoked` was missing from the original five states.** Resolved: `held` and `revoked` render as one merged "Paused by your instructor" card state on the student surface. The RPC may distinguish them internally, but the client must not. Correction to the roadmap's own framing while reconciling this: the `revoked` state and its setter shipped in **Phase 1** (`202608290001:43,586-587`), not Phase 4 as might be assumed; Phase 4 added only an owner-facing *read* of it. This plan corrects the record rather than repeating the assumption.
2. **`prerequisite-incomplete` was unrenderable as originally written**, because no entitlement row exists for a prerequisite-gated lesson under a direct table read. Resolved by the mandatory LEFT JOIN roster described above.
3. **The original packet assumed a student read path that does not exist.** Resolved by the mandatory new RPC and the explicit field contract above.
4. **Cohort-scheduled unlock timing was entirely absent from the original packet.** Resolved with two date-locked card variants, `date-locked-rolling` and `date-locked-cohort`, plus a page-level cohort-not-started banner.
5. **The packet had a `completed` state but no completion affordance.** Resolved with an explicit Mark-as-complete control for `completion_rule='view'` (the only value any production authoring path currently produces) and an honest forward-compatible fallback card for `quiz_pass`/`manual`. A full quiz-taking UI is a named non-goal, not a deferred detail.
6. **`get_lesson_progress_evidence` correctly excluded** as owner-only; confirmed again in this plan's own findings above.
7. **`course_version_completion_ratio` is real but also owner-only**; the RPC self-computes rather than calling it.
8. **Legacy coexistence was treated as background, not a design requirement, in the original packet.** Resolved with a distinct, honest empty state (`empty-legacy-unmaterialized`) and permanent cross-linking to `/roadmap`, never framed as "no access."

### Independent design review

The independent Design Reviewer returned `NEEDS_REVISION` on the first pass, with one HIGH-severity finding: gating the legacy empty state on `has_any_entitlement_row` alone would falsely tell a **non-legacy** student their lessons were "still available on your Roadmap" if an author ever chained every lesson in a course to a prerequisite, which nothing in the schema or authoring path prevents. The single permitted revision resolved this with the four-row decision table below, gated primarily on `course_is_legacy` (from `courses.legacy_band_id is not null`), with `has_any_entitlement_row` demoted to a secondary signal that is never sufficient alone.

The reviewer's second pass returned **PASS**, with one residual, non-blocking note recorded here rather than dropped: the revision's citation of `release-cadence-enforcement.md:146` as grounding for omitting a confirmation Modal on Mark-as-complete overstates that source, which actually places all four of its transitions behind a Modal and distinguishes only button styling by risk tier. The reviewer confirmed the no-Modal decision itself remains independently defensible on a different, correctly-cited precedent: `AdminStudentModals.tsx:74-78`'s J-004 pattern, where re-enabling a student (also an additive, access-restoring action) deliberately has no confirmation modal. This plan records the citation overstatement honestly rather than smoothing it into a clean justification.

### Design specification

**Routes.** `/learn` (index of the student's enrolled courses) and `/learn/:enrollmentId` (per-course lesson roster). No per-lesson sub-route; lessons render and complete inline on the detail page. `useRoute.ts` has no existing `/learn` collision, verified.

**Eight `.lesson-card` states**, each with its data precondition:

| # | State | Precondition |
|---|-------|---------------|
| 1 | `date-locked-rolling` | Entitlement exists, `unlock_at` in the future, rolling anchor |
| 2 | `date-locked-cohort` | Entitlement exists, `unlock_at` in the future, cohort anchor |
| 3 | `on-hold` | `manual_release_state` is `held` or `revoked` (merged) |
| 4 | `prerequisite-incomplete` | No entitlement row, prerequisite lesson resolvable by title |
| 5 | `unavailable-unspecified` | No entitlement row, prerequisite lesson not resolvable |
| 6 | `unlocked-incomplete` | Visible, `completion_rule='view'`, not yet completed; carries Mark-as-complete |
| 7 | `unlocked-pending-quiz` | Visible, `completion_rule` is `quiz_pass` or `manual`; no action rendered |
| 8 | `completed` | `completed_at` is set |

States 1-5 (the "locked family") share one hue (`color.roadmap.locked`, ink.700) and one icon (`icon-lock`), and are differentiated by text only, not color or icon. States 6-7 use `icon-current`; state 8 uses `icon-check`. This exhausts the closed three-glyph set already defined in `src/components/icons.tsx`; no new icon is introduced.

**Page states, `/learn`:** loading; error (copy must not imply zero enrollments, since an error and a genuine empty state are different facts); empty-zero; populated.

**Page states, `/learn/:enrollmentId`:** loading; a generic fail-closed error that deliberately never distinguishes "not yours" from "doesn't exist," to avoid leaking enrollment-ID validity to an unauthorized caller; `empty-legacy-unmaterialized` (with a "Go to Roadmap" primary button, linking to `/roadmap`); `empty-zero-published-lessons` (visually distinct from the legacy empty state, with no button, since the absence of a button is itself the differentiator); populated.

**The four-row page-state decision table** (the reviewer's required revision):

| `course_is_legacy` | `has_any_entitlement_row` | Rendered state |
|---|---|---|
| true | false | Legacy panel (`empty-legacy-unmaterialized`) + "Go to Roadmap" CTA |
| true | true | Ordinary roster |
| false | false | Ordinary roster, with per-lesson locked cards; **never** the legacy panel |
| false | true | Ordinary roster |

`empty-zero-published-lessons` (course version has zero published lessons, M=0) takes precedence over all four rows above; it is checked first.

**Progress copy** reads "N of M lessons complete." M=0 always routes to `empty-zero-published-lessons`; it must never render a false "0 of 0 complete" or a false 0% alongside a populated-looking page.

**Accessibility.** `h1`/`h2` heading structure on the index; `h1`/`h2`/`h3` on the detail page; no heading level is skipped on either. Exactly one interactive stop per lesson card; a disabled/unavailable action is omitted from the DOM rather than rendered disabled, matching `WeekCard`'s existing precedent. The disclosure used for locked-state explanation replicates `WeekCard`'s pattern exactly: `aria-expanded`/`aria-controls`/`role="region"`, the panel immediately after its toggle in DOM order, no focus move on open, and Escape closes the panel and returns focus to the toggle (`WeekCard.tsx:34-40`). Mark-as-complete swaps its trigger for an inline Confirm/Cancel pair and moves focus to Confirm on activation; Cancel restores the original trigger, refocuses it, and sends no request. One `aria-live="polite"` region announces success only, never on page load and never on Cancel. All interactive targets are at least 44x44px. `.learn-page` carries its own focus-visible rule, replicating `CourseWorkspace.css:3` verbatim (3px `--color-terracotta-600`, 2px offset), rather than falling back to the unscoped global 2px ring.

**Responsive behavior.** The index is single-column at all widths; its progress summary stacks below the title at or below 700px and inlines beside it above 700px. The detail page is single-column at all widths and deliberately never becomes a grid, because card order mirrors the real unlock sequence and a grid would obscure that ordering. Content is constrained to `measure.reading` (65ch). The existing 700px breakpoint is reused; no new breakpoint is introduced.

**Visual system.** Zero new primitives or semantic tokens. Two defects from a prior packet are re-confirmed as still-real and must not be reintroduced: `--color-ink-600` does not exist (ink is defined only at 700/800/900), and `error-700` does not exist (`error.50` is `#fef2f2`, not `#fff5f5`). No `error.*` token is used anywhere on this surface. `brass-500` and `terracotta-500` must never appear as light-surface text or button fills. Primary buttons reuse `WeekCard.css`'s already-AA-verified `brass.600`-on-`paper.50` fill with a `terracotta.600` hover state. `brass.500` appears only as a border accent and an `aria-hidden` icon, never as status text.

**No motion. No new imagery or icons.**

**Grandfathered lessons** (lessons whose `unlock_at` reconciliation moved earlier under the monotonic guard) render with zero distinguishing markup; they are carried forward unchanged and are visually identical to any other unlocked lesson.

**Binding engineering invariant: no threshold value is ever shown to a student.** The numeric `completion_threshold` value, whether rendered as a fraction, a percentage, or any other rendering of the underlying comparison, must not appear anywhere on `/learn` or `/learn/:enrollmentId`, in any state. Permitted student-facing progress language is limited to: "N of M lessons complete" (the student's own progress count, not the threshold); "You've completed this course"; and, optionally, the plain-language qualifier "(course requirements met)," which is not threshold math and remains permitted. This is a narrowing within the design's already-permitted range (the design specification above never required showing a threshold value) and therefore needs no further design review.

## Ordered work

TDD is mandatory throughout, matching every prior phase in this programme: no production code before a failing test exists for it. This is the largest single phase in the programme, so it follows the SQL-core-then-UI split Phases 2 and 3 both used, with Step 1 inserted ahead of that split as the gate re-verification the roadmap requires.

1. **G-ENT-1 re-verification (T1).** Run `npx supabase start`, then `npx supabase db reset`, then the five G-ENT-1 assertions in `src/__tests__/issue5-phase3-sql-core.test.ts:204-337`. All five must pass before any Phase 5 production code is written. A failure here halts Phase 5 outright; it is not worked around, patched inline, or deferred to a later step.
2. **SQL core: the student read RPC(s), failing tests first (T2 expected, given the security surface).** Author the RPC(s) with their grants and revokes, per the field contract and leak prohibition above. Tests must assert, as the **student database role** wherever RLS is implicated:
   - each of the eight lesson-card-state preconditions produces its expected row shape;
   - the leak prohibition holds for every locked-family state (no `content`, no `course_assets` row or path, no signed URL, no `assessment_answer_keys` contents);
   - a student cannot read another student's enrollment through this RPC;
   - `course_is_legacy` and `has_any_entitlement_row` are returned correctly for all four rows of the decision table;
   - the M=0 (zero published lessons) case.
3. **SQL core: the completion read path, failing tests first (T2 expected).** Tests proving `record_lesson_completion` refuses a locked, held, and revoked lesson when called with the student surface's exact call shape, remains monotonic (never un-completes), and correctly updates the derived course progress the new RPC subsequently reads.
4. **Client data-access module and routing (T1).** New route matchers in `src/hooks/useRoute.ts`, a new `App.tsx` dispatch branch, a nav link, and a typed service module in `src/services/` following `roadmapData.ts`'s anon-key/RLS-respecting convention, with no service-role bypass anywhere in the client. Tests first.
5. **`/learn` index page (T1).** All four page states, the `.enrollment-card`, the materialization badge (shown only when `course_is_legacy=true AND has_any_entitlement_row=false`), and the correct link target and label per enrollment. Tests first.
6. **`/learn/:enrollmentId` detail page (T1, T2 escalation anticipated).** All five page states under the four-row decision table, the eight `.lesson-card` states, the disclosure with its Escape behavior, the Mark-as-complete two-step control with its focus handoff, the `aria-live` region, the cohort-not-started banner, and the `.learn-page` CSS scope including its own focus-visible rule. Tests first.
7. **Validation.** Deterministic no-native-dialog source scan across every touched file; full suite run after `npx supabase db reset`; independent Verifier pass; Browser Validator pass. Neither the Verifier pass nor the Browser Validator pass may be claimed while G-ENT-1 is unsatisfied, per the Blocking prerequisites section above.

**Ownership.** T1 for the client, routing, and both page-level UI steps (4-6), with T2 escalation anticipated on Steps 2, 3, and 6 given the security and scope surface involved, matching the framing Phase 3 used for its own SQL core. Anticipating a T2 escalation on those steps is not in itself a gate failure; it reflects the security sensitivity of a `security definer` read path and the largest single UI surface in the programme, not a quality problem with T1's ordinary work.

## Interfaces and data

- **New:** one or more `security definer` student read RPC(s), granted to `authenticated`, with the field contract and leak prohibition specified above.
- **Consumed unchanged:** `record_lesson_completion(uuid, uuid)`, with no signature change.
- **Not consumed, by design:** `get_lesson_progress_evidence` (owner-only, `service_role`); `course_version_completion_ratio` (owner-only, `service_role`; the new RPC self-computes course progress rather than calling it, and does not expose it).
- **New client module** in `src/services/`, following `roadmapData.ts`'s anon-key/RLS-respecting convention, with no service-role bypass.
- **New route matchers** in `src/hooks/useRoute.ts` for `/learn` and `/learn/:enrollmentId`; a new `App.tsx` dispatch branch; a nav link.
- **No change to any existing function signature.** No change to the legacy student path (`RoadmapPage`, `WeekDetailPage`, `roadmapData.ts`, `weekUnlock.ts`).
- **Backward compatibility:** the legacy `/roadmap` surface behaves identically after Phase 5 as before it. This is testable directly and is included in acceptance below.

## Acceptance and validation

- The five G-ENT-1 assertions pass on a freshly reset database, **re-run rather than assumed**, as Step 1.
- Every RLS-implicated assertion in this phase queries as the **student** database role. A `service_role` read that would pass even with a broken policy is never acceptable evidence for this phase, per the roadmap's own reframing finding.
- All eight `.lesson-card` states render with their specified copy and are distinguishable by text alone with color removed (verified under a grayscale or forced-colors rendering).
- The `empty-legacy-unmaterialized` panel appears only for a legacy-and-unmaterialized enrollment, and never for a non-legacy fully-chained fixture (the case the design reviewer's HIGH finding specifically named).
- The two empty-state panels (`empty-legacy-unmaterialized` and `empty-zero-published-lessons`) are visibly distinct from each other.
- The `aria-live` region announces exactly once per successful Mark-as-complete confirm, and never on page load and never on Cancel.
- Escape closes an open lesson-card disclosure and returns focus to its toggle.
- `.learn-page`'s focus ring is the 3px terracotta ring, not the global 2px ring.
- The deterministic source scan finds no `alert`, `confirm`, `prompt`, any `window.*` variant, or `beforeunload` in any file touched by this phase.
- The full test suite passes after `npx supabase db reset`.
- Independent Verifier pass, then Browser Validator pass, neither claimed while G-ENT-1 is unsatisfied.
- The legacy `/roadmap` surface's existing test coverage passes unchanged, confirming backward compatibility.
- No `completion_threshold` value, in any rendering (fraction, percentage, or the underlying comparison), appears anywhere on `/learn` or `/learn/:enrollmentId`. Confirmed both at the source level (no component references the raw column or a derived percent/fraction of it in rendered output) and at the browser level (visual inspection of every page state on both routes).
- **The phase's defining acceptance check, and the reason this phase exists:** a real signed-in student session observably sees the effect of an entitlement setting for the first time in this product. Concretely: an owner holds a lesson, and the student's `/learn` view changes accordingly, from visible to the merged "Paused by your instructor" state, in a real browser session against a real database. Nothing in Phases 1-4 could demonstrate this, by the roadmap's own reframing finding; this check is what closes that gap.

## Risks and rollback

| ID | Severity | Risk | Mitigation |
|----|----------|------|------------|
| R1 | Critical | A locked lesson's content or asset path leaks through the new RPC. The RPC is `security definer` and therefore bypasses the RLS that has protected this data until now; this is the phase's defining risk. | The binding leak prohibition above; per-state leak assertions in Step 2; `course_assets` has no `authenticated` grant at all, so the RPC is the only possible leak vector, and it is reviewed as such. |
| R2 | Critical | The entitlement re-lock hazard, latent through Phases 1-4, goes live the moment this surface ships, since a real student page now reads entitlements for the first time. | G-ENT-1 re-verification as Step 1, plus real-student re-validation in Step 7. |
| R3 | Medium | A student holding both a legacy and a new enrollment is confused about which surface is authoritative. | The design's permanent cross-linking, the distinct legacy panel, and a dedicated dual-enrollment browser journey. |
| R4 | Medium | Legacy-backfilled enrollments render as empty courses with no explanation. | The honest `empty-legacy-unmaterialized` panel, which never states "no access." |
| R5 | Medium | The new RPC accidentally writes entitlement state, or is drawn into the reconciliation/migration chokepoints, undoing Phase 1's R3 structural-separation guarantee. | The binding non-delegation prohibition above, plus a structural regression assertion mirroring G-ENT-1's own structural-separation test. |
| R6 | Medium | The merged `on-hold` state (held + revoked) reads to a student as a system error rather than a deliberate instructor action. | Explicit disclosure copy naming the instructor; the merge itself is flagged as a user decision below rather than treated as settled. |
| R7 | Low | The detail page's generic fail-closed error frustrates a student who has a genuinely broken link, since the error deliberately does not say why. | Accepted deliberately: not leaking enrollment-ID validity to an unauthorized caller outweighs the diagnostic benefit to a student with a broken link. |
| R8 | Low | A stale local database yields false test results. | Mandatory `npx supabase db reset` before every validation pass. |

**Rollback.** Phase 5 is additive. Reverting the client changes (the new routes, the nav link, the new service module) and dropping the new RPC(s) restores the exact pre-Phase-5 state, because no existing function signature, RLS policy, or legacy code path is modified by this phase. Entitlement data itself is untouched by this phase's read path, since the RPC is read-only by the binding non-delegation prohibition above; only `record_lesson_completion`, an existing and unchanged function, ever writes as a result of this surface, and it already existed before this phase.

## Assumptions and decisions

**Safe assumptions:**

- `/roadmap` supports a generic root-level link target usable from the new legacy empty-state CTA.
- An existing lesson-content viewer exists elsewhere in the product for opening a lesson's body once unlocked; this phase specifies only the gating card, not that viewer, and does not build or modify it.
- `completion_rule` is `'view'` for every lesson any current production authoring path produces, with `quiz_pass`/`manual` handled only by the forward-compatible fallback card described above.

**Explicitly recorded as not determinable read-only:** how many real, non-fixture students are enrolled on the legacy band path in production. Coexistence is chosen precisely because it is the safe answer under either possible state of that fact.

**Planning defaults (not user decisions).** The three items below were open questions in an earlier draft of this plan. They are now settled as planning defaults, each carrying the following attribution and no other: *set as a planning default on the orchestrator's direction; not a recorded user reply. Like every other element of this plan, it is subject to the explicit user approval this document still requires.*

1. **`held` and `revoked` remain merged as one calm student-facing "Paused by your instructor" state.** Rationale: this avoids implying wrongdoing or alarming a student over an internal admin-state distinction, which the server continues to track precisely even though the UI does not surface it. This confirms the design as already reviewed and passed; nothing about the design or its engineering invariant (the RPC may distinguish the two states internally, the client presentation must not) changes.
2. **`completion_threshold` values are never shown to students.** Rationale: the numeric threshold is owner configuration, not student-facing information. Students see their own progress and completion status in plain terms only, per the binding engineering invariant and acceptance check recorded in the design specification and acceptance sections above.
3. **The one-time backfill-materialization job for legacy-backfilled enrollments remains deferred and out of Phase 5 scope**, as a deliberate deferral rather than an open question. The plan's existing honest-absence handling, the `empty-legacy-unmaterialized` panel that never says "no access," already covers it. Risk R4 stands exactly as written.

**Required implementation-time corrections, non-blocking but required before ship:**

- A fresh contrast check for the Cancel-button and link-text `ink.900`-on-card-background pairing, which was not independently measured against this exact surface during design review.
- Literal copy for both page `h1` titles, the materialization badge, and the two banner bodies, which the design deliberately did not invent and which an implementer or the owner must supply before ship.

## Browser UI dialog policy

Required and binding. Native `alert`, `confirm`, `prompt`, all their `window.*` forms, and `beforeunload` prompts are prohibited across every file this phase touches. This surface uses no Modal at all: the Mark-as-complete confirmation is an inline two-step Confirm/Cancel control with the focus handoff specified in the design section above, and locked-state explanation uses the inline `WeekCard` disclosure pattern, not a Modal. A deterministic no-native-dialog scan across every touched file is mandatory and is part of Step 7. Because no Modal is used anywhere on this surface, the usual Modal keyboard/focus verification is replaced by verification of the inline two-step focus handoff (trigger to Confirm, Cancel back to trigger) and of the disclosure's `aria-expanded`/`aria-controls`/Escape correctness.

## Browser UI validation

- **Launch and readiness:** `npx supabase start`, then `npx supabase db reset`, then `npm run dev`. Capture the actual printed Vite dev URL rather than hardcoding a port.
- **Base URL:** the captured Vite dev URL. Routes under test: `/learn` and `/learn/:enrollmentId`.
- **Fixture and reset:** `npx supabase db reset` before each pass, with the following seeded fixtures:
  - a student with zero enrollments;
  - a student with a real materialized enrollment mixing completed, unlocked, and date-locked-rolling lessons;
  - a student with a legacy-backfilled enrollment (`course_version_id` set, zero entitlement rows, course has `legacy_band_id` set);
  - a student with a cohort-scheduled enrollment whose cohort `starts_at` is in the future;
  - an enrollment containing a held lesson, and a separate enrollment containing a revoked lesson;
  - an enrollment containing a lesson gated behind an incomplete prerequisite;
  - a student holding both a legacy enrollment and a real materialized enrollment simultaneously, on two separate rows;
  - a published course version with zero published lessons;
  - a non-legacy course whose version has every lesson chained to a prerequisite, so `has_any_entitlement_row=false` while `course_is_legacy=false` (the case the reviewer's HIGH finding named).
- **Journeys:** all nine design journeys implied by the states above, end to end, including both the confirm and the cancel path of Mark-as-complete, the live-region announcement (exactly once, on confirm only), and the disclosure's Escape behavior. Explicitly include, as its own journey, an owner holding a lesson through the Phase 3/Phase 4 owner controls and then observing the change reflected in a real student `/learn` session, since this is the phase's defining acceptance check.
- **Viewport profiles:** mobile at or below 700px, and desktop. Both routes, at both profiles.
- **Visible outcomes:** as listed in "Acceptance and validation" above.
- **Coverage boundary, stated explicitly:** the five G-ENT-1 database-level assertions are not browser-testable and are gated by the database-level tests re-run in Step 1 instead. Browser validation and database evidence are both required for this phase's completion; neither substitutes for the other.

## Judge route

`PLAN_DUCK` eligibility is the orchestrator's call after this draft exists, under `docs/JUDGE-CONTRACT.md`. Pending, not asserted here.

## Approval

Explicit user approval of this document is required before any engineering writer begins. Approval of this document authorizes Phase 5 only.

### Approval record

**Approved.** Approved by rob.hasselbach@gmail.com on 2026-08-31, given directly to the orchestrator in the live interactive session (not relayed through a teammate or subagent).

**First exchange, standing authorization statement (exact user reply):**

> "i'm ready for you to stop fucking asking me and just keep going as planned like i asked you to do until it's all finished."

**What was presented to the user before this reply:** the orchestrator had been checking in for approval at each plan/phase boundary across the Lizbeth Spanish Issue #5 workstream. This reply told the orchestrator to stop requesting per-step approval and continue executing the already-agreed work through to completion.

**Second exchange, directly responsive to a request for approval of this specific plan (exact user reply):**

> "didn't i tell you to stop asking me for approval? i told you to keep going until all the gh issues are finished."

**What was presented to the user before this reply:** after the first exchange, the orchestrator still asked the user for explicit approval of this Phase 5 plan document specifically, before dispatching an engineering writer against it. The user's reply above was given in direct response to that specific approval request, not volunteered independently or inherited from an unrelated earlier context.

**How the reply maps to plan disposition:** the user was asked, in this instance, to approve this document, and the user's answer to that question was to reiterate the standing instruction to proceed without further approval check-ins until all open GitHub issues are finished. Because the second reply is a direct answer to an explicit, plan-specific approval request rather than an unprompted general statement, the orchestrator treats it as genuine, deliberate approval of this specific plan document, not merely an inherited blanket instruction being applied retroactively. The practical effect the user directed is the same either way: the orchestrator is authorized to proceed with this plan, and with subsequent plans in the same workstream, without pausing again for individual approval, unless a future plan changes scope, safety posture, target repository, or acceptance criteria in a way that would itself warrant a question under this project's operating contract.

**Scope of this approval:** authorizes Phase 5 only, per the "Approval" section above. It does not itself approve any later Phase 5 plan revision that changes scope, safety posture, target repository, or acceptance criteria; such a change would still warrant a question to the user under this project's operating contract.
