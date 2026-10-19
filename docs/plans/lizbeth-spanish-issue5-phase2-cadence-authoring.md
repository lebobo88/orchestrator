# Lizbeth Spanish, Issue #5 Phase 2: cadence authoring

Status: Approved. Phase 2 of five. Approval of this document authorizes only this phase. The roadmap's five-phase breakdown was accepted on 2026-08-29, but that acceptance authorized Phase 1 only; Phases 3, 4, and 5 each still require their own plan and their own approval.

Approval record: given by the user directly to the orchestrator across multiple live-session exchanges on 2026-08-30. See the approval-record section at the end of this document for the full record and the exact statements relied on.

Plan ID: `lizbeth-spanish-issue5-phase2-cadence-authoring`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: `engineering-fleet`, after explicit user approval of this plan
Roadmap: `docs/plans/lizbeth-spanish-issue5-roadmap.md`
Sibling plan (Phase 1, approved): `docs/plans/lizbeth-spanish-issue5-phase1-entitlement-primitives.md`
Design route for Phase 2: **standard** (escalated from compact in this revision; see the design-route section below for why).

## The correction that drives this revision

Give this the same prominence the roadmap gives its own reframing finding, because the first draft of this plan got something wrong and a reader comparing drafts needs to see it corrected rather than silently edited.

The first draft concluded that an absolute calendar date "cannot be expressed as a per-student relative offset" and, on that basis, was going to delete the "Custom schedule" capability and replace it with a notice. That framing was wrong in an important way. It is true that absolute dates cannot work under the self-paced enrollment model, where each student's clock starts on their own enrollment date. But that is not the only course model this product needs. A real scheduled class, an owner running an actual cohort with a fixed start date, where every enrolled student is on the same calendar schedule regardless of when they individually signed up, is a legitimate and different unlock model. The existing "Custom schedule" textarea was pointed at the right feature; it was simply never wired to anything that could use it correctly. The first draft was about to quietly kill a real, wanted capability by mistaking "not yet built" for "cannot work."

The decision now is to build it properly rather than remove it. This plan delivers **two coexisting unlock models**, not a replacement of one by the other.

The decisive enabling fact, verified: `enrollment_lesson_entitlements.unlock_at` (migration `202608280003_issue5_course_authoring.sql:189`) is already an absolute `timestamptz`. The entitlement layer has always stored an absolute instant. `unlock_offset_days` is merely one way to compute that instant, not the storage model. A second unlock model needs no change to the entitlements table, its RLS policies, the student read path, or Phase 1's monotonic guard, only a second way to resolve the anchor the offset is added to.

## Outcome and audience

Make the existing "Release cadence" course setting real, and extend it to cover both ways an owner actually runs a course. Today an owner can select `self_paced`, `daily`, `weekly`, or `custom` in the authoring workspace, but every lesson is written with a hardcoded `unlock_offset_days: 0` regardless of that choice, and the `custom` option's own textarea asks for calendar dates that the data model cannot use. This phase makes cadence produce a genuine per-student `unlock_offset_days` value on each lesson, under either of two unlock models: rolling enrollment (relative to each student's own enrollment date) and scheduled class (relative to a cohort's fixed start date, identical for every student in it). Audience is the course owner working in the authoring workspace. This is the literal ask in issue #5, now correctly scoped to include the scheduled-class case the first draft was about to discard.

## The two models, and how they coexist

**Model A, rolling enrollment (relative):** `unlock_at = student_enrollments.enrollment_date + unlock_offset_days`. Each student's schedule starts when they enroll. Cadences: `self_paced` (all offsets 0), `daily` (offset = position - 1), `weekly` (offset = (position - 1) * 7), and `custom` (owner-authored per-lesson offsets). `weekly` has direct repository precedent at `scripts/provision-lessons.ts:791` (`unlock_offset_days: (entry.weekNumber - 1) * 7`) and `supabase/migrations/202607170001_init_schema.sql:107-109`. `daily` has no precedent in the repository; it is recorded as consistent with the weekly precedent but not independently evidenced.

**Model B, scheduled class (absolute, cohort-anchored):** `unlock_at = cohorts.starts_at + unlock_offset_days`. Every student in the cohort unlocks lesson N at the identical calendar instant, no matter when they signed up. New `release_cadence` literal value: `cohort_scheduled`.

The two models share the same `unlock_offset_days` column on `course_version_lessons` and differ only in which anchor the offset is added to. That is the whole architecture, and it is why this is an extension of the existing data model rather than a parallel system built beside it.

## Scope and non-goals

**In scope:** the release-cadence authoring path, now covering both unlock models.

- The client `saveDraft` payload (`src/services/courseAuthoring.ts:48`).
- The `save_outline` RPC.
- The `update_course_settings` RPC's derived-offset recompute.
- The Settings two-tier cadence control (enrollment model, then pace or scheduled-class redirect).
- The Outline per-lesson unlock row: derived note or offset input, covering all five cadence values, plus the inline computed calendar date for `cohort_scheduled`.
- A new nullable `student_enrollments.cohort_id` column, set at the two enrollment-grant sites that already have the cohort in scope.
- A new shared SQL helper, `resolve_entitlement_anchor`, and the rewiring of the five existing sites that currently inline the enrollment-date-anchor computation (see the scope-expansion section below; this is a required, not optional, part of making `cohort_scheduled` safe to ship).
- `CohortForm`: start/end date fields, timezone disclosure, and a schedule preview.
- Mode-switch confirmation via the existing `Modal.tsx`.
- Tests for all of the above.

**Out of scope:**

- The reconciliation preview/apply panel, per-student hold/release, the prerequisite picker, and the completion-threshold hint. All Phase 3.
- Hard re-lock UI. Phase 4.
- The student `/learn` surface. Phase 5.
- Any change to `approve_enrollment_request` or `request_cohort_enrollment` beyond setting the new `cohort_id` column at their existing grant sites; their control flow, authorization, and every other behavior are unchanged.
- Any change to the legacy `bands`/`lessons`/`weekUnlock` student path, or to the separate legacy-band enrollment path at `supabase/functions/admin-student-operations/index.ts:484-495` (see the scoping caveat below).
- No commit, push, PR, or deploy.

This revision withdraws one claim the first draft made in this section: it previously stated `materialize_enrollment_entitlements` and `apply_version_migration` are untouched by this phase. That is no longer true and is corrected in full in the scope-expansion section below; both functions' anchor computation is rewired through the new shared helper in this phase, because the alternative is a `cohort_scheduled` course that computes wrong unlock times from its very first enrollment.

## Verified repository findings

All findings below were re-verified during this planning pass, against the current working tree with Phase 1 merged. Findings carried from the first draft are kept; new findings from this revision are marked as such.

**Root cause, re-verified and still accurate:**

- `src/services/courseAuthoring.ts:48` — `saveDraft` builds the `save_outline` payload and writes the literal `unlock_offset_days: 0` for every lesson. This is the single line that defeats the entire cadence setting. Confirmed still present after Phase 1.
- `src/services/courseAuthoring.ts:35` — `mapLesson(...)` accepts an `unlockOffsetDays` argument and calls a separate `map_lesson` action, but is NOT called anywhere in `CourseWorkspacePage.tsx`. It is a decoy path: the natural wrong thing for an implementer to reach for, exactly as Phase 1 recorded `materialize_enrollment_entitlements` as its own decoy for reconciliation work.

**Where the cadence UI actually lives and what it produces:**

- `src/pages/CourseWorkspacePage.tsx`, `function Settings` (~line 54): the "Release cadence" control, saved by its own "Save settings" button via `updateCourse` -> `update_course` action -> `update_course_settings`, which persists `courses.release_cadence` and (today) `courses.custom_schedule`.
- `src/pages/CourseWorkspacePage.tsx`, `function Outline` (~line 31): the per-lesson list. Saved by a separate "Save draft" button in the page header (line 24 and 26) via `saveDraft`.
- The setting and the lessons it governs live in two different tabs behind two different save buttons with no shared state. That structural split is the reason the value never reached the data.
- `Settings` is conditionally rendered as `{active === 'settings' && <Settings .../>}` and holds `cadence` in purely local state initialized from the `course` prop. Switching tabs unmounts it and silently discards every unsaved Settings edit. `blocks`, by contrast, is lifted to the parent and has IndexedDB recovery via `saveRecovery`/`loadRecovery`. This asymmetry is a pre-existing defect, not one this phase introduces, but this phase's workflow walks straight into it.

**The `custom` cadence's textarea asked for the wrong shape of value under the rolling model, but the underlying need is real (revised finding):**

- `course_version_lessons.unlock_offset_days` is declared at `supabase/migrations/202608280003_issue5_course_authoring.sql:79` as `integer not null default 0 check (unlock_offset_days >= 0)`, a relative number of days added to an anchor instant.
- Under Model A (rolling), that anchor is each student's own enrollment date, so an absolute calendar date cannot be expressed there; every student enrolls on a different day.
- Under Model B (scheduled class), the anchor is a single shared cohort start date, so the same integer-offset column, added to that one anchor, produces a genuine shared calendar date for every student in the cohort. The textarea's intent (real dates) is preserved; its implementation (literal per-lesson dates typed as JSON) is replaced by an authored offset plus a computed, displayed date, as detailed in the design handoff below.

**Server-side facts that determine the architecture:**

- `save_outline` (`supabase/migrations/202608280003_issue5_course_authoring.sql:295-311`) is `security definer`, requires `v.status = 'draft'` (line 300, raises `not authorized` otherwise), deletes every `course_version_lessons` row for the version (line 301) and reinserts them, taking `unlock_offset_days` from `coalesce((item->>'unlock_offset_days')::integer,0)`, trusting the client unconditionally. It also creates brand-new `lesson_revisions` rows with new UUIDs on every single save (line 305).
- Its authorization check at line 300 already joins `courses c on c.id = v.course_id`, so `courses.release_cadence` (column declared at line 38) is directly reachable from inside the function. No schema change and no new relationship is needed to derive server-side.
- `update_course_settings` (lines 344-381) already reaches into the draft version and rewrites `course_version_lessons.is_preview` across it (lines 371-379), resolving the draft via `select v.id into draft_id from course_versions v where v.course_id=p_course_id and v.status='draft'`. A derived-offset rewrite in the same place is an established in-pattern write, not a new class of operation.
- Entitlements are materialized only for published versions: `materialize_enrollment_entitlements` (lines 235-249) filters on `cv.status='published'`. `enrollment_lesson_entitlements.unlock_at` is a snapshot computed once at materialization time, not a live join against `course_version_lessons`.
- `finalize_publish_job` (lines 267-280) does not re-materialize entitlements for existing enrollments. Publishing a version does not touch anyone's access.

**New in this revision: the anchor computation is duplicated inline in five places, verified:**

- `materialize_enrollment_entitlements`, `202608280003_issue5_course_authoring.sql:242-243`.
- `apply_version_migration`, same file, lines 260-261.
- `preview_enrollment_reconciliation`, `202608290001_issue5_phase1_entitlements.sql:196-251` (across six bucket queries).
- `apply_enrollment_reconciliation`, same file, lines 330-370.
- `grant_enrollment_entitlements_with_prerequisites`, same file, lines 481-483.

`materialize_enrollment_entitlements` is already live and wired at both enrollment-creation sites today: `approve_enrollment_request:416` (`perform materialize_enrollment_entitlements(e.id);`) and `request_cohort_enrollment:472`. Because of this, the anchor branch for `cohort_scheduled` cannot be deferred to a later phase; it must ship in the same change that makes `cohort_scheduled` persistable, or the feature computes wrong unlock times from the first enrollment onward.

Three of the five sites (`preview_enrollment_reconciliation`, `apply_enrollment_reconciliation`, `grant_enrollment_entitlements_with_prerequisites`) are Phase 1 functions that currently ship dark. If any of them is wired to an owner action in Phase 3 without the anchor branch, reconciliation would silently overwrite correctly cohort-anchored `unlock_at` values with enrollment-date-anchored ones for every `automatic` row, actively corrupting a scheduled class's schedule. This is a cross-phase consistency hazard surfaced during this revision's design pass.

**New in this revision: cohort scheduling infrastructure exists but is unused.** `cohorts.starts_at` and `ends_at` already exist in the schema (lines 114-115) and are currently never populated: `CohortForm` (`CourseWorkspacePage.tsx:52`) calls `createCohort(courseId, name, mode)` and never passes the dates, even though `createCohort` (`src/services/courseAuthoring.ts:39`) already accepts them. Cohorts bind to a course VERSION, not a course: `getCourse` sets `id: version.id` (`courseAuthoring.ts:45`), so the id passed to `createCohort` is the version id. `cohorts.course_version_id` has no uniqueness constraint (schema lines 109-119 declare only `unique(owner_id, name)`), so a version can legitimately have more than one cohort with different start dates. `list_cohorts` (`supabase/functions/course-authoring/index.ts:134`) selects `id,name,course_version_id,enrollment_mode,starts_at,ends_at,created_at` filtered only by `.eq('owner_id', ...)` with no server-side version filter; Outline filters client-side to `course_version_id === course.id`, so no new backend endpoint is required for the per-lesson computed-date display.

**New in this revision: `release_cadence` has no default and is NULL for most existing courses.** `courses.release_cadence` has no column default (schema line 38 is bare `release_cadence text,`), and neither `create_course_with_version` (lines 313-321) nor the legacy-band backfill (lines 207-210) ever sets it, so it is NULL for every newly created course and for the entire legacy catalog until an owner saves Settings once. The current UI only defaults it in local component state (`CourseWorkspacePage.tsx:54`), which is why this was not previously visible as a defect. This matters directly to the new two-tier control's derivation, detailed in the design handoff below.

**New in this revision: a third, unrelated enrollment path exists and must not be assumed populated.** `supabase/functions/admin-student-operations/index.ts:484-495` is a pre-existing `student_enrollments` insert path (the legacy band "assign" action) with no `course_version_id`, no cohort context, and no call to `materialize_enrollment_entitlements`. It is out of scope and unaffected by cadence mode. Neither `cohort_id` nor `course_version_id` can be assumed populated on every active `student_enrollments` row.

**Research evidence:** none. This phase is grounded entirely in local repository evidence; no external or current-facts question was material.

## Critical cross-check against Phase 1

This section is deliberately prominent, because it is the question this plan was specifically asked to think through, and the answer is counterintuitive, with one part of the answer now partially revised by this scope expansion.

**The question:** now that Phase 1's reconciliation exists, and now that this phase creates real non-zero offsets for the first time, does saving new cadence values on an already-enrolled course need to trigger, or offer to trigger, a reconciliation preview/apply for existing enrollments?

**The answer is still no, and it is still no by construction, not by choice.** The chain of four verified facts:

1. `save_outline` cannot run against anything but a draft (line 300 raises otherwise), and `update_course_settings` only writes offsets into the draft version.
2. Entitlements only exist for published versions (`cv.status='published'`, line 245).
3. A published version's outline and settings are read-only in the UI, and `clone_course_version` (line 330) forbids a second concurrent draft, so a published version's offsets are frozen once published.
4. `finalize_publish_job` does not re-materialize entitlements, and `unlock_at` is a stored snapshot rather than a live join, so even publishing a newly-cadenced version changes nothing for anyone already enrolled.

Therefore cadence authoring in this phase genuinely cannot reach any existing student's entitlement state through the outline/settings save path. There is nothing to reconcile there, no "these changes will affect N existing students" confirmation to show, and no reconciliation trigger to wire from Settings or Outline.

**But** — recorded just as prominently, because it is a real hazard this phase touches, partially fixes, and does not fully close:

Making offsets real converts `apply_version_migration` (`supabase/migrations/202608280003_issue5_course_authoring.sql:252-265`) from harmless into genuinely dangerous. That function does `delete from enrollment_lesson_entitlements where enrollment_id=e.id` and then reinserts. It has no monotonic guard, and because it deletes the rows outright it also destroys every `manual_release_state`, silently resetting a student's `released`, `held`, or `revoked` state to `automatic`. Today this is inert because every offset is 0.

**This revision changes what is true about that risk, but only partially.** Because the scope expansion routes `apply_version_migration` through the new shared `resolve_entitlement_anchor` helper (see below), its anchor computation becomes correct for both models in this phase. That is a real fix, not a narrated one. But `apply_version_migration` still has no monotonic guard and still unconditionally deletes and reinserts every entitlement row, so it still can re-lock a lesson a student can already see and still wipes `manual_release_state` on every call. Only the anchor half of the hazard is fixed here; the guard-and-preserve half is not. That half remains a required Phase 3 input, exactly as the first draft stated: Phase 3 must route version migration through Phase 1's guarded reconciliation path, or must add the monotonic guard and manual-state preservation to `apply_version_migration` directly.

Mitigating fact, consistent with the roadmap's reframing finding: no student can observe any of this until Phase 5, so the unguarded-delete half of the hazard is latent, not live. But it becomes live at Phase 5, and it must not be allowed to arrive there unfixed. See risk R1 below, and see ship-gate **G-ENT-1** in `docs/plans/lizbeth-spanish-issue5-roadmap.md`, which converts this from a risk-table intention into a mandatory, owned, Phase-3-Acceptance-level prerequisite that hard-blocks Phase 5's completion until satisfied.

## Architectural decision, with its cost stated honestly

The design fleet considered two ways to build Model B and chose cohort-anchored offsets over literal per-lesson calendar dates stored on `course_version_lessons`. The design reviewer independently verified the reasoning. Both the choice and the rejected alternative are recorded here.

**Chosen:** per-lesson values stay integer day offsets; the only new literal-date input in the entire feature is `cohorts.starts_at`/`ends_at`, one date per cohort rather than one date per lesson per course. An owner re-runs the same curriculum across sections and semesters. Storing literal dates on `course_version_lessons` means every cohort on that published version shares the same dates, so a second section would need a cloned draft version merely to shift a calendar, and `clone_course_version` (line 330) forbids a second concurrent draft, making it structurally awkward to prepare next term while this term is still running. Cohort-anchored offsets let one published version serve many cohorts, each with its own start date and zero re-authoring.

**The cost, stated plainly rather than buried:** with a shared version, per-cohort schedule irregularities cannot be expressed. Cohort A cannot skip a holiday week that cohort B observes. And the owner authors an integer offset rather than typing a literal date directly. The design mitigates the second point with an inline computed calendar date on each lesson row (detailed below), so the owner authors against a real, visible date even though the stored value is an offset.

**This is the one point in this revision where the user should confirm the plan matches their intent.** The user asked for real calendar dates; this design delivers them as computed and displayed against an authored offset, not as a directly typed date field. If that does not match the intent, the rejected alternative (literal per-lesson dates on `course_version_lessons`) remains available but reopens the per-cohort re-authoring cost described above.

## Critical scope expansion: revising the first draft's scope-lock

The first draft asserted, in both its Scope and Acceptance sections, that `materialize_enrollment_entitlements`, `apply_version_migration`, `approve_enrollment_request`, and `request_cohort_enrollment` stay unmodified, and it included a source-level check asserting exactly that. **That assertion is now wrong and is withdrawn.** It is stated here explicitly, rather than silently edited, because a reader comparing drafts needs to see that this changed and why.

The reason: a `cohort_scheduled` course would compute wrong unlock times from its very first enrollment if the anchor branch is not present in `materialize_enrollment_entitlements`, since that function is already live and wired at both grant sites today (`approve_enrollment_request:416`, `request_cohort_enrollment:472`). The anchor branch cannot be deferred to Phase 3; it must ship in the same change that makes `cohort_scheduled` persistable, or the feature is broken on arrival.

**Binding engineering invariant, the most prominent invariant in this plan:** introduce one shared SQL helper, `resolve_entitlement_anchor(p_enrollment_id, p_course_version_id) returns timestamptz`, declared `language sql stable`, which resolves the enrollment date for rolling cadences and the cohort's `starts_at` for `cohort_scheduled`. No function may inline `enrollment_date + make_interval(...)` (or an equivalent anchor computation) anywhere else. All five sites listed in the findings above route through it, including `apply_version_migration`. Folding `apply_version_migration` in is safe and creates no interaction with Phase 1's monotonic guard, because `apply_version_migration` has no monotonic guard at all; it unconditionally deletes and reinserts, making the anchor fix orthogonal to, not entangled with, its separate unguarded-delete defect. Leaving `apply_version_migration` out of the helper's coverage would directly contradict the invariant's own wording.

**Implementation conditions, requirements rather than suggestions:**

- For the two `INSERT ... SELECT` sites (`materialize_enrollment_entitlements`, `grant_enrollment_entitlements_with_prerequisites`), hoist the helper via `WITH anchor AS (SELECT resolve_entitlement_anchor(e.id, e.course_version_id) AS ts) ... CROSS JOIN anchor` so it runs once per enrollment rather than once per lesson row.
- For `preview_enrollment_reconciliation`, hoist once into a single `WITH anchors AS (...)` CTE joined into all six bucket queries, rather than invoking it up to six times per entitlement row.
- For `apply_enrollment_reconciliation`'s per-row loop and its `ON CONFLICT DO UPDATE`, a per-row call is acceptable: the loop already does per-row audit-trail work, so this is not a new performance class, and a `stable` helper evaluates against the same statement snapshot as `excluded.*`.

**Required data-model addition:** a nullable `student_enrollments.cohort_id`, set at the two grant sites that already have the cohort row in scope, `approve_enrollment_request` (lines 403-418, variable `c`) and `request_cohort_enrollment` (lines 448-476, variable `c`). This is required because `materialize_enrollment_entitlements` receives only an enrollment id and has no cohort context today. The rejected alternative, resolving the cohort by joining `cohort_memberships` at materialization time, is ambiguous when a student belongs to two cohorts on the same version, and is rejected for that reason.

**Scoping caveat**, stated explicitly so a future implementer does not over-assume: the legacy band "assign" path at `supabase/functions/admin-student-operations/index.ts:484-495` is out of scope and unaffected by cadence mode, as noted in the findings above. Neither `cohort_id` nor `course_version_id` can be assumed populated on every active enrollment row.

This expansion also partially resolves the critical risk the first draft raised about `apply_version_migration`; see the cross-check section above for exactly which half is fixed and which is not.

## Design route

**Standard, escalated from compact in this revision.** The escalation and its reason are recorded rather than silently applied: a genuinely new second unlock model, a new multi-state authoring component, a changed owner mental model for the cadence control, and a new cohort-binding flow are not a bounded brownfield edit, which is what justified compact in the first draft. `design-director` led with `ux-architect` and `visual-system-designer`; `motion-designer` and `asset-art-director` were correctly skipped, since this work introduces no motion and no new imagery. `design-reviewer` returned an evidence-backed NEEDS_REVISION, the director revised once, and the reviewer passed the revision.

### Design handoff (standard, passed)

**Cadence information architecture.** Replace the single "Release cadence" select with two nested selects inside the existing `.settings-grid` (no radio buttons; there is no radio precedent anywhere in this form).

- Tier 1, "Enrollment model": "Rolling enrollment (relative to each student)" and "Scheduled class (fixed dates for everyone)".
- Tier 2 under Rolling is the existing four-option pace select verbatim.
- Tier 2 under Scheduled is a static redirect line pointing the owner to Outline for per-lesson offsets and Students for the cohort start date, not a select.

**Tier 1 is derived, not stored, and the derivation has a specific correctness requirement.** Because `courses.release_cadence` is NULL for every newly created course and the entire legacy catalog (see findings above), the derivation must null-coalesce to rolling:

```js
const ROLLING_CADENCES = ['self_paced', 'daily', 'weekly', 'custom'];
const model = (!release_cadence || ROLLING_CADENCES.includes(release_cadence))
  ? 'rolling'
  : 'scheduled';
```

A naive membership test alone would render every never-configured and legacy course as a scheduled class, which is inverted and wrong. Do not add a column default: the corrected derivation is required regardless, since a forward-only default cannot fix already-NULL rows, and the column has no CHECK constraint, so a default would add no validation guarantee. The design reviewer confirmed declining the default is sound.

No migration of stored cadence values is needed; `release_cadence` is unconstrained text, existing values keep their exact meanings, and only the fifth literal `cohort_scheduled` is added.

**Tier 2 accessibility.** Wrap the Tier 2 region in `aria-live="polite" aria-atomic="true"` (class `.tier2-cadence-region`) rather than moving focus, because moving focus off an actively-operated select is more disorienting for a same-panel inline swap and is consistent with WCAG 3.2.2 and this codebase's existing announce-without-moving-focus pattern at `CourseWorkspacePage.tsx:26`. Do not also put `role="status"` on the inner redirect `<p>`; `role="status"` carries an implicit polite live region, and nesting them is a documented duplicate-announcement pitfall.

**Per-lesson authoring.** Offsets are authored in the Outline tab for both authored modes (`custom` under rolling, and `cohort_scheduled`), consistent with the relative model's existing placement, in one coherent row per `authoring-block` placed after "Lesson type": a read-only `<p>` for derived cadences, an `<input type="number" min="0" step="1">` for authored ones. Only label and helper copy differ across the five cadence values, so this does not become two unrelated UIs. A bulk-fill affordance ("start at N, step N, Apply to all", producing `start + step × (position−1)`) keeps a 26-lesson course humane. Everything routes through the existing "Save draft" button; no new save path.

**Inline computed calendar date**, scoped only to the `cohort_scheduled` row, not the rolling `custom` row, which stays enrollment-anchored. Persistent helper copy under the input in all states: "Days after the cohort's start date." Three states:

- No cohort exists yet, or every cohort on this version has a null `starts_at`: "No cohort start date yet, add one in the Students tab to preview this lesson's release date." Neutral informational text, not the advisory severity treatment; this is a normal authoring-order state, not a validation warning about owner input.
- Exactly one cohort with a start date, or several sharing an identical one: "→ Unlocks {formattedDate}", computed as `starts_at + unlock_offset_days`, formatted with `Intl.DateTimeFormat` `{month:'short',day:'numeric',year:'numeric'}` in the owner's local zone, updating live as the offset changes. Client-side display only.
- Two or more cohorts with genuinely different start dates: "→ Unlocks {earliest}–{latest}, varies by cohort", plus a line naming the cohort count and pointing at the Students tab. It must never collapse to a single fabricated date, never average, and never silently privilege one cohort. This is a real case, not hypothetical, given `cohorts.course_version_id` has no uniqueness constraint.

`aria-describedby="lesson-{n}-offset-helper lesson-{n}-offset-computed"` on the offset input.

**Timezone**, stated explicitly rather than left implicit. The owner sees a native date picker plus an inline disclosure of the browser-detected `Intl.DateTimeFormat().resolvedOptions().timeZone`. `cohorts.starts_at` stores midnight of the chosen date in that detected zone, converted to UTC. `unlock_at = starts_at + offset_days`. Every student in a cohort unlocks at the same absolute instant, and the copy must not imply per-student midnight.

**Cohort binding flow.** `CohortForm` gains a required "Class starts" `<input type="date">` and an optional "Class ends", with the timezone disclosure line. It then shows a read-only per-cohort "Schedule preview" listing `{position}. {title} — unlocks {date}` with a persistent caption stating the draft-safety guarantee. That caption's three claims were all independently verified true and may be asserted to the owner: entitlements materialize only for published versions (line 245), `unlock_at` is a stored snapshot rather than a live join, and `finalize_publish_job` (lines 267-280) never touches `enrollment_lesson_entitlements`. Cohort creation is not gated by `course.status`, so a second cohort can be created against an already-published version with zero re-authoring.

**Mode switching, with app-owned confirmation.** Reuse the existing `src/components/Modal.tsx`, verified to be app-owned with a real Tab-cycling focus trap, Escape handling, and focus restoration to the trigger. Two cases:

- Case A, authored to derived, is destructive: "Switch schedule mode?", warns that N lessons' authored values will be overwritten, buttons "Cancel" and "Switch and overwrite".
- Case B, authored to authored (`custom` ↔ `cohort_scheduled`), is a non-destructive re-anchor: the numbers carry over but change meaning, so it needs distinct, lower-risk copy and a plain "Cancel"/"Switch" pair.

Switching from a derived mode with nothing authored needs no confirmation in either direction. Severity is handled as a body-content class rather than adding a severity prop to `Modal.tsx`'s shared API.

**Validation.** Blocking (`role="alert"`): missing, negative, or non-integer offset; missing cohort start date. Advisory (`role="status"`): non-monotonic offsets across positions; a past cohort start date. Never silently coerce a value.

**Visual system.** Extend the existing "Field Workbook" system verbatim; no new hex, px, or spacing literal, every value resolving to an existing token. Severity is conveyed icon-free by border hue, border width, background, and ARIA role together, so it survives forced-colors and grayscale and is never color-alone: blocking is a 4px `--color-terracotta-600` left border on `--color-paper-200`; advisory is a 3px `--color-brass-600` left border on `--color-paper-100` with `--color-ink-800` text, as a narrowly scoped new class rather than a blanket `[role=status]` selector, so existing "Saving…"/"Draft saved." copy is not restyled.

New class hooks: `.enrollment-model-note`, `.tier2-cadence-region`, `.lesson-unlock-row`, `.bulk-fill-control`, `.cohort-form`, `.timezone-disclosure`, `.schedule-preview` and `.schedule-preview-caption`, `.schedule-severity-error`, `.schedule-severity-advisory`, `.modal-actions`.

All token and contrast claims were independently recomputed and confirmed: `--color-brass-600` #866843, `--color-terracotta-600` #a85e4a, `--color-ink-700` #504940, `--color-ink-800` #3d3530, `--color-paper-100` #faf8f4, `--color-paper-200` #f0ebe2; ink-700 on paper-100/200 8.36:1 and 7.47:1, ink-800 on paper-100 11.32:1, terracotta-600 on paper-100/200 4.54:1 and 4.05:1, brass-600 on paper-100/200 4.86:1 and 4.34:1, all passing the 4.5:1 text and 3:1 non-text thresholds.

Two corrections to record, both verified: the 3px terracotta focus ring is not global; `App.css` defines a global 2px blue `:focus` via `--color-focus-ring`, while the terracotta 3px `:focus-visible` is scoped to `.course-workspace` (`CourseWorkspace.css:3`) and wins by specificity for all descendants including the inline non-portaled Modal. And `--color-ink-600`/`--color-ink-500` are never declared anywhere in the codebase, a pre-existing latent bug in unrelated rules that this work must not propagate. Add an invariant: never add a selector at or above `.course-workspace button:focus-visible` specificity that changes outline color or width.

**Legacy `custom_schedule` data.** The first draft's "can't convert, here's a notice" answer is retained, but now for a specific verified reason rather than a general claim, and the reason is stronger than previously stated: `save_outline` (lines 295-311) deletes and recreates every `lesson_revisions` row with a fresh UUID on every single outline save, so any course saved even once since the legacy JSON was written has orphaned `lessonId` references with no reliable match. Show a `role="status"` notice explaining this in plain language and print the stored `{lessonId, releaseAt}` pairs as inert manual-reference text so nothing is silently lost. Do not auto-migrate, do not delete the column, do not attempt conversion.

**Do not restyle** `.authoring-block`, `.settings-grid`, `demo-button`, or `checkbox-label`. Do not add a third save affordance beyond "Save settings" and "Save draft". Preserve the two-tab, two-save-button architecture; do not merge them.

**States, all required:** default, dirty/unsaved, saving, saved, validation error (blocking and advisory, distinct), published-version read-only (both existing "Published outline" and "Published settings" panels stay exactly as they are and continue to suppress all per-lesson detail, preserved behavior, not a gap), empty outline (zero lessons, nothing to derive), and the three inline computed-date states for `cohort_scheduled` described above.

**Permitted variation:** Outline may compute a same-tick local echo of the derived rolling-model offset for perceived responsiveness, provided it is documented in code as display-only and is never sent back to `save_outline` for the derived cadences. Secondary copy may be tightened for length provided it never implies a calendar date for the rolling model and always names the correct anchor (enrollment date or cohort start date) for the model in effect. The pending-cadence fix (lift vs. recovery) is an implementation choice. CSS class names may be adjusted to fit project lint conventions.

## Ordered work

1. **RED evidence first.** `npx supabase start`; `npx supabase db reset`. Reproduce the hardcoded-zero defect exactly as the first draft specified. Additionally demonstrate that no path exists today to give two students in one cohort the same calendar unlock date.
2. **Failing tests first**, for every acceptance guarantee below, SQL-level and component-level. Mandatory TDD; no production code before a failing test exists for it.
3. `student_enrollments.cohort_id` (nullable), set at the two grant sites.
4. `resolve_entitlement_anchor` shared helper.
5. Route all five inline anchor-computation sites through the helper, with the CTE hoisting specified above.
6. `save_outline` server-side derivation for the rolling derived cadences (`self_paced`/`daily`/`weekly`); client value honored only for the two authored modes (`custom`, `cohort_scheduled`).
7. `update_course_settings` recompute of the draft's offsets on cadence change.
8. Client `saveDraft` (`src/services/courseAuthoring.ts:48`): stop writing the hardcoded 0; add `unlockOffsetDays?: number` to the client block model in `src/lib/courseAuthoring.ts` and populate it from `course_version_lessons.unlock_offset_days` in `getCourse`.
9. Settings: two-tier cadence control, live region, legacy notice; remove the JSON textarea and its parse/error handling.
10. Outline: the unified unlock row, offset input, bulk fill, inline computed date with all three states, validation, ARIA wiring.
11. `CohortForm`: start/end dates, timezone disclosure, schedule preview.
12. Mode-switch confirmations via the existing Modal.
13. Close the pending-cadence unmount gap (lift to parent, or extend the existing `saveRecovery`/`loadRecovery`), softening the loss-warning copy once state is genuinely preserved, as the first draft specified.
14. Full suite after `npx supabase db reset`. Verifier pass. Browser Validator pass.

**Ownership.** T1 for the client and UI steps (1-2, 8-13). Anticipate T2 for steps 3-7, the SQL core: the shared helper, five call-site rewrites, and the two derivation changes are the correctness-sensitive heart of this phase. This is stated as an expectation, matching Phase 1's framing, not as a failure condition.

## Interfaces and data

- New migration: `student_enrollments.cohort_id uuid null references cohorts(id)`; `resolve_entitlement_anchor(p_enrollment_id uuid, p_course_version_id uuid) returns timestamptz language sql stable`; the five call-site rewrites listed above; the `save_outline` and `update_course_settings` derivation changes. Follows the Phase 1 migration's naming pattern.
- `save_outline`'s payload contract is unchanged in shape; its interpretation changes: `unlock_offset_days` becomes advisory for the three derived cadences (`self_paced`, `daily`, `weekly`) and authoritative only for the two authored modes (`custom`, `cohort_scheduled`). This is documented plainly so a future reader does not assume the client still controls it for derived cadences.
- `courses.custom_schedule` is no longer written by this UI. The column and any existing values are left in place untouched, shown only as inert reference text per the legacy notice above.
- `courses.release_cadence` gains one new valid literal, `cohort_scheduled`, alongside the existing four. No column constraint currently enforces the allowed set (verified: none exists), so no CHECK-constraint migration is required, but the client and server derivation logic must recognize the fifth value everywhere `release_cadence` is branched on.
- Backward compatibility: existing published versions and existing entitlements for enrollments already materialized under the rolling model are untouched by the anchor-helper rewiring, since the helper reproduces the prior rolling computation exactly for any enrollment with a null `cohort_id`.

## Acceptance and validation (all mandatory)

Carried forward from the first draft, unchanged:

- Setting `weekly` and saving produces `unlock_offset_days` of 0, 7, 14, … in position order on the draft's `course_version_lessons`. Assert against the database, not the UI.
- Setting `daily` produces 0, 1, 2, … in position order.
- Setting `self_paced` produces 0 for every lesson.
- Setting `custom` persists the exact per-lesson integers the owner authored, unchanged.
- A client that sends a wrong `unlock_offset_days` under a derived cadence is overridden by the server, not obeyed. Assert this directly by calling the `save_outline` RPC with a deliberately wrong value.
- Saving only settings (never touching the Outline tab) updates the draft's offsets.
- `save_outline` still refuses a non-draft version.
- No change to any `enrollment_lesson_entitlements` row results from any settings-save or outline-save operation in this phase for an existing published enrollment. Assert as a before/after comparison across a settings save and an outline save on a course that has an enrolled student on a published version.
- Client validation rejects a negative, blank, or non-integer custom or cohort-scheduled offset and does not coerce it.
- `src/__tests__/nativeDialogPolicy.test.ts` passes; the deterministic no-native-dialog source scan finds zero matches in the changed files.
- Full suite passes after `npx supabase db reset`.

**Removed in this revision:** the prior source-level check asserting `materialize_enrollment_entitlements`, `apply_version_migration`, `approve_enrollment_request`, and `request_cohort_enrollment` stay unmodified. That check is now false, per the scope-expansion section above, and is replaced by the anchor proofs below.

**Added in this revision:**

- Source-level: `enrollment_date` combined with `make_interval` appears only inside `resolve_entitlement_anchor`'s body. Use a whitespace-tolerant pattern such as `enrollment_date\s*\+\s*make_interval`, since `apply_version_migration:261` writes it without spaces around the operators while every other site uses the spaced form; a literal spaced-string grep would silently miss it. All five sites named in the findings above must be in scope of this check.
- Functional: a `cohort_scheduled` enrollment's `unlock_at` is cohort-anchored, not enrollment-date-anchored. Prove it with two students in one cohort enrolled on different dates receiving identical `unlock_at` values. This is the single assertion that proves the user's actual requirement.
- Non-drift: `preview_enrollment_reconciliation` reports zero drift for a correctly cohort-anchored row, and applying reconciliation to a cohort-anchored row does not move its `unlock_at` away from the cohort-anchored value. Preview and apply are separate SQL bodies, so both are asserted.
- Regression: a rolling-model enrollment's computed `unlock_at` is unchanged by the helper refactor, compared against the pre-refactor computation.
- The corrected Tier-1 derivation renders a NULL-`release_cadence` course as Rolling, not Scheduled.

**Verification bar, unchanged from the first draft:** Verifier pass, then Browser Validator pass. Unit tests alone are explicitly insufficient here; this programme has repeatedly found real bugs that unit tests missed, and the entire defect being fixed is a value that looked correct in the UI while never reaching the database. Live browser verification is mandatory, not optional.

## Risks and rollback

| ID | Severity | Risk | Mitigation |
|----|----------|------|------------|
| R1 | Critical | `apply_version_migration` is now anchor-correct for both models via the shared helper, but still has no monotonic guard and still unconditionally deletes and reinserts, wiping `manual_release_state` and able to re-lock a visible lesson. Only the anchor half of this risk is fixed in this phase | Tracked as ship-gate **G-ENT-1** in `docs/plans/lizbeth-spanish-issue5-roadmap.md`, owned by Phase 3, with mandatory Acceptance-level evidence and a hard block on Phase 5's Verifier/Browser Validator claims, not merely a risk-table intention; latent until Phase 5 because no student surface reads entitlements yet; the anchor half is proven fixed by the source-level and non-drift acceptance checks above |
| R2 | High | An implementer wires the offset through `mapLesson`/`map_lesson` (`courseAuthoring.ts:35`) instead of `saveDraft`/`save_outline`. That path is never called by this UI, so the change would appear complete and do nothing | Named as a prohibited path; the acceptance tests assert against the database after a real "Save draft," not against the client payload |
| R3 | High | Derivation is implemented client-side only, so derived cadences display a value the server never stores | Server-side derivation is a binding invariant; the acceptance test that sends a deliberately wrong client value proves the server overrides it |
| R4 | High | Reconciliation corrupts a scheduled class if any of the three dark Phase 1 functions is wired into an owner action in Phase 3 without the anchor branch | Mitigated by the shared helper shipping now, in this phase, plus the source-level proof that no inline anchor computation remains outside it |
| R5 | Medium | The whitespace-variant anchor computation at `apply_version_migration:261` is missed by a naive grep, leaving a sixth uncovered site undetected | Mitigated by the required whitespace-tolerant pattern in the source-level acceptance check |
| R6 | Medium | Per-row helper invocation in `preview_enrollment_reconciliation`'s six-bucket query causes a performance regression | Mitigated by the required CTE hoisting specified in the scope-expansion section |
| R7 | Medium | A student belonging to two cohorts on the same version makes the anchor ambiguous | Mitigated by the explicit `cohort_id` column set at grant time, rather than an ambiguous `cohort_memberships` join at materialization time |
| R8 | Medium | Timezone conversion produces an off-by-one day at the owner's local midnight boundary | Mitigated by the explicit timezone disclosure in the UI and by an acceptance assertion on the stored UTC instant |
| R9 | Medium | `save_outline` deletes and recreates `lesson_revisions` with fresh UUIDs on every save (line 305), so any client state keyed on a revision id goes stale after a save; the custom and cohort-scheduled offset values must survive a save/reload round trip | Acceptance requires a reload-and-recheck after saving authored offsets |
| R10 | Medium | Switching cadence away from an authored mode overwrites the owner's authored per-lesson values with derived ones, losing work | Mitigated by the Case A confirmation modal ("Switch and overwrite") in front of every destructive switch |
| R11 | Medium | The pending unsaved cadence selection is silently discarded on tab switch | Ordered-work step 13 closes it at the architecture level rather than warning about it |
| R12 | Low | An owner with an existing absolute-date `custom_schedule` expects it to keep working | The explicit legacy notice, printing the stored pairs as inert reference text; no silent conversion is attempted, because none is possible |
| R13 | Low | A stale local database produces false results | Mandatory `npx supabase db reset` before every validation pass |

**Rollback.** The client changes (Settings, Outline, `saveDraft`) are confined to the draft-authoring path and revert cleanly to the hardcoded 0 and the old textarea. The SQL changes are less trivially reversible than the first draft's, because the shared helper now sits inside five function bodies rather than being additive-only; reverting the migration restores all five previous function bodies exactly, and no data migration is required since no published version or existing entitlement row is altered by anything in this phase. The new `cohort_id` column can be dropped without data loss, since nothing outside this phase's own code reads it yet.

## Assumptions and decisions

**Safe assumptions:**

- `course.release_cadence` and `course.status` are already present on the `course` object in `CourseWorkspacePage` state and can be threaded into `Outline` as a prop with no data-fetch change.
- Component-level tests can exercise the Outline, Settings, and `CohortForm` panels in the existing Vitest setup used by the repository's other component tests.

**D1, resolved by the user in this revision:** build the cohort-scheduled capability properly rather than removing it, on the stated reasoning that if the owner starts an actual scheduled class, all students should be on the same schedule. This plan implements that as Model B above.

**D2, approved as recommended:** non-monotonic offsets warn but do not block, since a deliberate non-monotonic release order is a legitimate if unusual authoring choice.

**D3, approved as recommended:** switching away from an authored mode overwrites the authored values, now with the Case A confirmation modal in front of the destructive switch, rather than a silent overwrite.

**Formerly open items, now resolved by direct user approval on 2026-08-30** (see the approval-record section at the end of this document for the exact statements relied on):

- Whether the inline computed-date approach (an authored offset plus a computed, displayed date) satisfies the "real calendar dates" intent, versus the rejected alternative of literal per-lesson dates. Resolved: yes, as recommended, confirmed by the user in direct response to the orchestrator quoting this exact tradeoff.
- `cohorts.ends_at` semantics. Resolved as recommended: informational only in this phase, since no function consumes it yet.
- Whether bulk-fill should also be offered for the rolling `custom` mode, not only `cohort_scheduled`. Resolved as recommended: yes, for consistency between the two authored modes.
- Whether a past cohort start date should block rather than advise. Resolved as recommended: advise, since a mid-term backdate (for example, re-registering an existing class into the system) is a legitimate use.

## Browser UI dialog policy

Required and binding. `alert`, `confirm`, `prompt`, all their `window.*` forms, and `beforeunload` prompts are prohibited. All acknowledgement and validation is app-owned inline `role="status"`/`role="alert"` messaging, including both mode-switch confirmation cases, which use the existing app-owned `Modal.tsx` rather than `window.confirm`. Enforced by `src/__tests__/nativeDialogPolicy.test.ts` plus a deterministic source scan of the changed files.

## Browser UI validation

This section is complete and does not defer anything to the writer's completion claim.

- **Launch and readiness:** `npx supabase start`, then `npx supabase db reset`, then `npm run dev`. Capture the actual printed Vite URL; it has been observed in the 5173-5178 range and must never be hardcoded.
- **Base URL:** the captured Vite dev URL. Relevant routes are `/admin/courses/{courseId}/outline`, `/admin/courses/{courseId}/settings`, and the Students tab that hosts `CohortForm`.
- **Credentials:** the owner account `owner@test.local` / `password`, per `supabase/seed.sql:78`.
- **Fixture and reset:** `npx supabase db reset` before each pass.
  - Fixture A: a draft course with at least 3 lessons and `release_cadence: 'self_paced'`.
  - Fixture B: a course with `release_cadence: 'custom'` and a non-empty legacy `custom_schedule`, for the legacy-notice check.
  - Fixture C: a published version, for the read-only check.
  - Fixture D (new): a course with `release_cadence = NULL`, for the Tier-1 derivation check.
  - Fixture E (new): a course with `release_cadence: 'cohort_scheduled'` and no cohort yet, for the three inline computed-date states as cohorts are added and edited.
- **Journeys:**
  1. Cycle the Tier 1/Tier 2 cadence controls through all five pace/model combinations and confirm the JSON textarea is gone and the correct redirect or pace options render.
  2. Save settings with `weekly` and then, without saving the outline, navigate to Outline and confirm every lesson already shows "Unlocks {N} days after the student enrolls." with N = (position-1)*7. This is the core structural fix and must work with no outline save.
  3. Select a cadence, do not save, switch to Outline and back, and confirm the pending selection survived.
  4. Save with `custom` and confirm each lesson shows the editable offset input pre-populated.
  5. Enter a negative or blank offset and attempt to save, confirming the per-field alert, `aria-invalid`, and the page-level count message.
  6. Fix it, save, confirm "Draft saved." and then reload and confirm the offsets actually persisted.
  7. Open Fixture B and confirm the legacy notice renders, prints the stored pairs as inert text, and does not block saving.
  8. Open Fixture C and confirm the published read-only panels are unchanged with no new controls.
  9. Keyboard-only pass: tab to the "Lesson type" select and confirm the unlock note is announced via `aria-describedby`.
  10. Run the no-native-dialog scan against the changed files and confirm zero matches.
  11. (New) Open Fixture D and confirm Settings renders Rolling with a sane pace default, not the scheduled redirect.
  12. (New) On Fixture E, add a cohort with no start date and confirm the neutral "no cohort start date yet" state; add a start date and confirm the computed date updates live; add a second cohort with a different start date and confirm the "varies by cohort" state, never a fabricated single date.
  13. (New) On an already-published Fixture E-derived version, create a second cohort with an independent start date and confirm its schedule preview is correct with zero re-authoring of the outline.
  14. (New) Trigger both mode-switch modal cases (Case A destructive, Case B re-anchor) and confirm Cancel, Escape, and backdrop dismissal all work and restore focus to the trigger.
  15. (New) With assistive-technology tooling or an accessibility-tree inspector, confirm switching Tier 1 produces exactly one live-region announcement, not zero and not duplicated.
- **Viewport profiles:** default desktop, plus the existing `max-width:700px` mobile breakpoint. At both, confirm the new rows span full width and every new input keeps its 44px touch target.
- **Visible outcomes:** no calendar date appears anywhere under the rolling model; a real, correct calendar date appears for `cohort_scheduled` lessons once a cohort start date exists; offsets are correct in Outline immediately after a settings-only save; the pending cadence survives a tab round trip; `aria-describedby` and `aria-invalid` are on the correct elements; and the persisted database values match what the UI displayed.
- **Explicit note on coverage boundaries:** the shared-helper invariant (that no function outside `resolve_entitlement_anchor` inlines the anchor computation) is not browser-testable and is gated by the SQL-level source and functional proofs in Acceptance instead. Browser validation and SQL evidence are both required for this phase; neither substitutes for the other.

## Judge route

`PLAN_DUCK` eligibility is the orchestrator's call after this draft exists, under `docs/JUDGE-CONTRACT.md`. Pending, not yet asserted.

## Approval

Explicit user approval of this document is required before any engineering writer begins. Approval of this document authorizes Phase 2 only and does not authorize Phase 3, 4, or 5.

Decision status, restated where a reader deciding on approval will actually see it. All points below are resolved; none remain open.

- **D1** (cohort-scheduled capability): resolved by direct user statement, build it properly as a second unlock model rather than removing it, on the reasoning that if the owner starts an actual scheduled class, all students should be on the same schedule. This document implements that decision as Model B.
- **D2** (non-decreasing custom offsets): approved as recommended, warn but do not block.
- **D3** (switching away from an authored mode): approved as recommended, overwrite authored values, behind the Case A confirmation modal.
- The four smaller items previously listed as open in "Assumptions and decisions" above (the computed-date approach against the "real calendar dates" intent, `cohorts.ends_at` semantics, bulk-fill for rolling `custom`, and past-start-date block-vs-advise) are all resolved as recommended, including the computed-date point, which the user confirmed directly after the orchestrator restated the exact tradeoff against the rejected literal-per-lesson-dates alternative.

### Approval record

Approved by: the user (rob.hasselbach@gmail.com).
Date: 2026-08-30.
Method: direct interactive-session responses to the orchestrator, across multiple live exchanges, not relayed through a planning teammate.
Scope of approval: authorizes Phase 2 only, per the status header above. Phases 3, 4, and 5 each still require their own plan and their own approval.

Record of the exchanges relied on:

1. D1: the user was asked whether to build the cohort-scheduled capability properly or remove it. Exact reply: "d1, yes it can work properly because if the owner starts an actual fucking scheduled class all students should be on the same schedule. let's make it work as intended." This directed the genuine cohort-anchored, absolute-date unlock model built in this document as Model B.
2. D2 and D3: exact reply, "d2: as recommended. d3: yes as recommended." D2 is non-monotonic offsets warning but not blocking; D3 is overwriting authored values on a mode switch away from an authored cadence, behind the Case A confirmation modal.
3. The three smaller sub-decisions (`cohorts.ends_at` semantics, bulk-fill scope, past-start-date handling) were presented together with their recommendations, and the user's exact reply was "approve all 3."
4. The remaining point, the computed-date approach against the "real calendar dates" intent: the orchestrator quoted the plan's own tradeoff directly to the user, asking whether an authored offset plus a computed, displayed date (Model B as specified in this document) satisfies their intent, versus literal per-lesson calendar dates typed directly (the rejected alternative, described in the architectural-decision section above). The user's exact reply, "as recommended," confirmed the offset-plus-computed-date approach as specified in this document, not the literal-per-lesson-dates alternative.
