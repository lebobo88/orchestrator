# Lizbeth Spanish, Issue #5 Phase 3: owner enforcement controls

Status: Approved. Phase 3 of five. Approval of this document authorizes only this phase; it does not authorize Phase 4 or Phase 5, each of which requires its own plan document and its own explicit approval.

Approved by: rob.hasselbach@gmail.com, 2026-08-30, via direct interactive-session response to the orchestrator. Exact reply: "1. no, as recommended. 2. i don't understand the question. proceed as planned." Mapping: (1) confirms no owner override of the prerequisite gate at approval time, as this plan recommended (see the open question at the end of "Assumptions and decisions"); (2) authorizes proceeding with the plan's existing default treatment of the two minor cosmetic follow-up items (the raw-UUID display at `CourseWorkspacePage.tsx:157`, recorded as an open question marked "Recommended, not required," and the percent-precision rounding limit at risk R22, recorded as "a known limit for engineering to resolve at implementation time"); neither item's existing default treatment is changed by this approval. See the full approval record below.

Plan ID: `lizbeth-spanish-issue5-phase3-owner-enforcement-controls`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: `engineering-fleet`, after explicit user approval of this plan
Roadmap: `docs/plans/lizbeth-spanish-issue5-roadmap.md`
Sibling plans (approved): `docs/plans/lizbeth-spanish-issue5-phase1-entitlement-primitives.md`, `docs/plans/lizbeth-spanish-issue5-phase2-cadence-authoring.md`
Design route for Phase 3: **standard**, re-classified and re-verified rather than carried forward as-is; see the design-route section below for what changed and why.

## Blocking prerequisites

None. No open ship-gate constrains the start of this phase. Phase 3 itself OWNS ship-gate G-ENT-1 and must close it as a mandatory, blocking condition of its own completion; see the dedicated section below. Every phase plan written after the roadmap's G-ENT-1 amendment carries this section per the roadmap's Clause 3, stating either the gates that constrain it or `none`; this phase states `none`.

## Scope increase by explicit user direction

This plan originally recommended deferring prerequisite enforcement (see the superseded recommendation preserved in Assumptions and decisions below). The user reviewed that recommendation and explicitly overturned it, directing:

> "yes we want reprequisite enforcement actually planned and wired up now as part of all of this. don't take shortcuts or get lazy. why wouldn't we do the full entire job?"

This document has been revised under that direction to add a real, tested, derived-not-stored completion semantic and to wire prerequisite enforcement into both live enrollment-grant sites, in this same phase, rather than deferring it. Everything else already in this plan (the G-ENT-1 fix, the reconciliation panel, the hold/release control, the corrected design packet, the eleven reconciliation states, the binding field order, the risk table, and the browser validation section) stands unchanged except where a section below says otherwise. The plan remains Draft and still requires explicit user approval before any engineering writer begins; that approval, once given, still authorizes Phase 3 only.

## Outcome and audience

Give the course owner working surfaces for the enforcement primitives Phase 1 built dark and Phase 2 made meaningful: review and apply retroactive entitlement reconciliation for a published course version, hold or release an individual student's individual lesson, choose a prerequisite course/version from a real picker instead of typing a UUID, and see an honest statement of what the completion-threshold setting does. Additionally, and as a mandatory blocking item rather than an optional improvement, this phase closes ship-gate G-ENT-1 by making `apply_version_migration` safe.

**Scope increase (by explicit user direction, see above).** This phase now also builds a real completion semantic for a course version, gives it a genuine derived (not stored) implementation, gives the course owner a real in-product way to record a student's lesson completion, and wires that semantic into both live enrollment-grant sites so the prerequisite setting genuinely blocks and genuinely permits enrollment rather than remaining an honest but inert disclosure. This closes what was previously the plan's own deferred recommendation.

Audience is the course owner working in the authoring workspace, for every item except the G-ENT-1 fix and the student-callable `record_lesson_completion` RPC. The G-ENT-1 fix has no audience in the ordinary sense: it ships as a correctness fix beneath an existing button, and no owner is asked to do anything differently because of it. `record_lesson_completion` is built this phase as a database primitive with no student-facing surface calling it; that surface belongs to Phase 5, exactly as the roster completion action's owner surface is this phase's actor-facing counterpart.

## Scope and non-goals

**In scope:**

1. The G-ENT-1 fix to `apply_version_migration`: a monotonic guard plus preservation of per-row `manual_release_state`, `completed_at`, and quiz history.
2. The owner-facing reconciliation preview/apply panel.
3. The per-student, per-lesson manual hold/release control, with exactly three states: `automatic`, `released`, `held`.
4. The prerequisite course/version picker, replacing the raw UUID input, with copy disclosing its enforcement status honestly. **(Updated by explicit user direction: the picker now discloses genuine enforcement, not inertness; see item 9 below and the design delta.)**
5. The completion-threshold hint.
6. A copy note on the existing Versions-tab "Apply migration" button, gated on G-ENT-1 shipping.
7. Two new reads (a per-student-per-lesson roster; a cross-course owner-scoped version list) and client-side service wrappers for the Phase 1 RPCs that already have Edge actions but no client bindings.
8. **(Added by explicit user direction.)** A real, derived-not-stored completion semantic for a course version: `course_version_completion_ratio`, `has_completed_course_version`, and `assert_course_prerequisite`, with the course-level version-matching semantics described in the dedicated section below.
9. **(Added by explicit user direction.)** Wiring `assert_course_prerequisite` into both live enrollment-grant sites (`approve_enrollment_request` and `request_cohort_enrollment`), and refactoring `grant_enrollment_entitlements_with_prerequisites` to delegate to the same predicate rather than carrying its own inline check.
10. **(Added by explicit user direction.)** A new student-callable `record_lesson_completion` RPC and a new owner-callable `set_lesson_completion` RPC, plus `recalculate_course_version_completion` to maintain the `student_enrollments.completed_at` cache for workspace-authored enrollments without ever being read by a gate.
11. **(Added by explicit user direction.)** The owner-facing roster completion column and action described in the design delta below, the inverted prerequisite-picker and completion-threshold hint copy, and the new enrollment-blocked alert.
12. Tests for all of the above.

**In scope by explicit user direction, overturning this plan's own prior recommendation to defer:**

- Inventing and shipping a real completion semantic to give `completion_threshold` and the prerequisite gate a genuine consumer. See "The completion semantic" section below for the full definition and reasoning.
- Wiring `grant_enrollment_entitlements_with_prerequisites` into the live enrollment-grant sites, as a refactor into a shared predicate rather than a direct wiring, per finding F6 below.

**Out of scope:**

- Hard re-lock (`revoked`) in any owner-facing form. That is Phase 4, requires its own new design pass per the roadmap, and must not be scope-crept into this phase. No `revoked` option, no fourth badge hue, and no copy implying revoke is permitted this phase.
- The student `/learn` surface (Phase 5), including any UI for the self-enroll (`request_cohort_enrollment`) blocked path; that path ships a message contract only this phase.
- Cadence authoring (Phase 2, shipped).
- An owner override of the prerequisite gate at approval time. Recorded as an open question below, recommended against.
- No commit, push, PR, or deploy.

## Verified repository findings

All findings below were verified directly against the current working tree with Phase 1 and Phase 2 merged.

**G-ENT-1 is live, and sharper than the roadmap states.** `apply_version_migration` now lives at `supabase/migrations/202608300001_issue5_phase2_cadence_sql_core.sql:74-88` (Phase 2 re-created it to route its anchor through `resolve_entitlement_anchor`). Line 80 is still `delete from enrollment_lesson_entitlements where enrollment_id=e.id`, followed by an unguarded reinsert at lines 82-86. Phase 2 fixed the anchor half only, and says so in its own comment at lines 67-73. Two consequences remain exactly as the roadmap describes: no monotonic guard, so it can move `unlock_at` later for an already-visible row; and the delete destroys `manual_release_state` and `completed_at` outright.

This sharpens a claim the roadmap does not make precisely enough to act on: this function is not merely latent behind an unused code path. It is reachable from a live owner-facing button today. The Versions tab's "Apply migration" (`src/pages/CourseWorkspacePage.tsx:240`) calls `applyMigration` (`src/services/courseAuthoring.ts:38`), which calls the Edge action `apply_migration` (`supabase/functions/course-authoring/index.ts:323-325`), which calls the RPC. An owner can fire this today, right now, with no dependency on anything this phase builds. It remains unobservable to students only because no student surface reads entitlements yet (the roadmap's own reframing finding), not because nothing calls it. State this correction prominently: it strengthens rather than weakens the case for fixing it in this phase, since the defect is one owner click away from firing, not a theoretical future risk.

**Every Phase 1 RPC already has an Edge action but no client wrapper.** `supabase/functions/course-authoring/index.ts` lines 344-370 already wire `set_lesson_access_state`, `preview_reconciliation`, `apply_reconciliation`, `get_progress_evidence`, and `grant_entitlements_with_prerequisites`. But `src/services/courseAuthoring.ts:6-7` declares `type CourseAction` and `export type ReadAction` as closed string unions that include none of these names, and no exported wrapper calls them. The client work for these five is additive union entries plus wrappers, not new Edge endpoints. This materially reduces this phase's backend surface: an implementer should not rebuild what already exists.

**No per-student-per-lesson roster read exists anywhere.** Verified absent from the Edge function's entire action list. A partial roster source does exist and is already wired: `list_migration_enrollments` (`supabase/migrations/202608280003_issue5_course_authoring.sql:385-398`) returns per-enrollment `id`, `user_id`, `student_display_name` (coalesced from user metadata `full_name`, then email, then the literal `'Student'`), `enrollment_date`, `status`, `version_migrated_at`, `version_migrated_from`, scoped to one course version with owner authorization, limit capped at 200. It is exposed to the client as `listMigrationEnrollments(versionId)` (`courseAuthoring.ts:29`) and already used by the Versions tab. It returns no entitlement rows, so a second, per-lesson read is genuinely required for the roster control in this phase.

**The Students tab is a stub.** `src/pages/CourseWorkspacePage.tsx:157` renders only a cohort count, an enrollment-request list displaying the raw `request.user_id` UUID, and `<CohortForm>`. There is no student roster, no student names, no per-lesson structure. The manual hold/release control is therefore a new surface, not an addition to an existing one.

**`set_lesson_access_state` refuses rows that do not exist.** `supabase/migrations/202608290001_issue5_phase1_entitlements.sql:83-85` raises `entitlement not found`. Entitlements materialize only for published versions. "No entitlement row yet" is therefore a real, common, non-actionable roster state, not an edge case.

**The `released` → `automatic` transition never re-locks, permanently.** `set_lesson_access_state` sets `unlock_at = now()` for `released` (lines 92-94) and leaves `unlock_at` untouched for `automatic` and `held` (lines 95-98). Reverting to `automatic` therefore leaves `unlock_at` at the past `now()` value from the earlier Released action. And `apply_enrollment_reconciliation`'s monotonic guard (`202608290001...sql:365-370`, restated `202608300001...sql:268-273`) applies `least(old.unlock_at, computed)` once `old.unlock_at <= now()`, so reconciliation can never move it back later either. This is correct and intentional behavior, the monotonic guarantee working as designed, but it is owner-visible and counterintuitive, and the design requires it be disclosed in product copy. It is given its own named finding here for exactly that reason.

**The prerequisite setting is inert as shipped, and the true root gap is deeper than first stated (F1, corrected).** Two separate facts. First: `grant_enrollment_entitlements_with_prerequisites` (`202608300001...sql:312-368`) is called by nothing. Both real enrollment-grant sites call plain `materialize_enrollment_entitlements` instead: `approve_enrollment_request:388` and `request_cohort_enrollment:416`, and that function performs no course-level prerequisite check. Second, and decisive: the prerequisite check inside `grant_enrollment_entitlements_with_prerequisites` (lines 331-340) gates on `student_enrollments.completed_at is not null` for the prerequisite version. Nothing in production code writes that column at all, for any enrollment, workspace-authored or otherwise: it is written only by tests and by `supabase/seed.sql`. The plan's earlier statement that a legacy `band_id`-scoped path sets it for band enrollments still holds as a separate, correct observation (see F3 below), but does not change the finding: for a workspace-authored enrollment there is no writer of any kind. So even if the function were wired in today, a prerequisite would create a gate no student could pass by any in-product action. Both facts must be stated plainly in this plan and disclosed in the UI, and this phase's added scope exists to close them for real rather than by honest disclosure.

**F2. A second, previously unrecorded instance of the same defect, already shipped and dormant.** The LESSON-level prerequisite gate reads the same unwritten column. `202608300001_issue5_phase2_cadence_sql_core.sql:357-361` (and identically `202608290001_issue5_phase1_entitlements.sql:487-491`) gates a lesson's entitlement on `prior.completed_at is not null` for `cvl.prerequisite_lesson_revision_id`. The moment this phase gives `enrollment_lesson_entitlements.completed_at` a writer, this shipped-but-dormant gate begins firing for the first time in production. This is a real behavior change this phase causes, not merely a bug fix; it did not appear anywhere in the plan before this revision and must be tested explicitly (acceptance item 11 below).

**F3. A complete, well-designed precedent for deriving enrollment completion from per-lesson completion already exists, on the legacy band path.** `public.recalculate_progress_completion` (`202608270001_issue2_progress_dashboard.sql:87-101`) counts completed lessons against total lessons, requires `total_count > 0`, stamps `student_enrollments.completed_at`, and uses the `student_enrollments.auto_completed_from_progress` boolean (added at `202608270001...:16-17`) so it never clobbers a legacy or manually-set completion date and can cleanly un-complete a student it previously auto-completed. `record_lesson_progress` (`202608270001...:47-81`) is its writer and calls it at line 76. This phase follows this precedent for the workspace-authored path rather than inventing a new shape.

**F4. That legacy path cannot serve workspace-authored courses.** Both `record_lesson_progress` and `recalculate_progress_completion` are band-scoped: they key on `public.lessons.band_id = e.band_id` (lines 64, 93-95). Workspace-authored enrollments are keyed on `course_version_id`, with lessons reached through `course_version_lessons.lesson_revision_id`. A workspace-authored enrollment therefore has no reachable completion write path of any kind today, confirming F1's severity.

**F5. `courses.completion_threshold` is a fraction with no consumer, and this phase gives it its first one.** `numeric(5,4) check (completion_threshold is null or completion_threshold between 0 and 1)` (`202608280003_issue5_course_authoring.sql:42`), nullable, unread anywhere in the codebase until this phase's added scope.

**F6. BLOCKER not identified by this plan's original out-of-scope note: `grant_enrollment_entitlements_with_prerequisites` cannot simply be wired into both grant sites as-is.** Its signature is owner-shaped: it hard-fails `not authorized` unless `crs.owner_id = p_owner_id` (`202608300001...:326-329`). `request_cohort_enrollment` (`202608300001...:392-420`) is student-initiated; `auth.uid()` is the student and no owner id is in scope there. Naively calling the existing function from that site is impossible, not merely inadvisable. This is why the added work is a refactor into a shared predicate (`assert_course_prerequisite`, described below), not a wiring task, and why the plan's prior framing of this as a simple "wiring" deferral understated the real work involved.

**F7. Both grant sites create the enrollment row before materializing entitlements, in one transaction.** `approve_enrollment_request` calls plain `materialize_enrollment_entitlements` at line 388, `request_cohort_enrollment` at line 416; neither performs any prerequisite check today. Both are single transactions, so a raised exception rolls the whole thing back atomically. The added gate must still run before any insert in each function, so a block is clean and does no wasted work rather than relying on the rollback alone.

**`courses.manual_release` is a third inert setting, distinct from `manual_release_state`.** The checkbox at `CourseWorkspacePage.tsx:236`, labelled "Require manual lesson release," is written by `update_course_settings` and read back only for display; nothing reads it to gate anything. It is a different thing from the per-entitlement `manual_release_state` enum this phase surfaces. Two settings with nearly identical names, one inert. Record it plainly so an owner does not conflate them.

**`completion_threshold` is read by nothing.** Stored and echoed at `CourseWorkspacePage.tsx:214,236`; no consumer anywhere in the codebase.

**Six preview buckets, and one field that does not exist.** The shipped `preview_enrollment_reconciliation` returns `{scope, computed_at, preview_token, totals, changes, warnings}`. The six `changes` buckets are `unlocking_now`, `still_locked_earlier`, `still_locked_later`, `newly_eligible_locked`, `excluded_manual_override`, `already_visible_unaffected`. There is no `affected_students_sample` field, despite the Phase 1 plan's interface section and the older design packet both specifying one. `warnings` is hardcoded `'[]'::jsonb` at `202608290001...sql:283` and `202608300001...sql:194` and is written by nothing. Apply failures carry `lesson_revision_id`, not `lesson_title`. These three contract corrections are recorded explicitly against the Phase 1 plan's stated contract, because a reader comparing documents needs to see the difference acknowledged rather than silently absorbed.

## The completion semantic (added by explicit user direction)

This is the core decision behind the scope increase, and it is a real product decision, not a wiring detail. It exists because the user rejected deferring it.

**Definition.** A student has completed a course version when the share of that version's published lessons they have marked complete meets that course's completion threshold. Formally:

```
count(entitlement rows for this enrollment whose completed_at is not null)
  / count(published lessons in that course version)
  >= coalesce(courses.completion_threshold, 1.0)
```

A version with zero published lessons is never complete, following F3's `total_count > 0` precedent exactly. Without this guard, an empty course would silently satisfy every prerequisite that names it.

**Default semantics.** A `NULL` threshold means 1.0, i.e. every published lesson must be complete. This deliberately matches the existing band-path behavior (`done_count = total_count`), so the default introduces no new behavior for existing courses, while finally giving `completion_threshold` its first genuine consumer and closing roadmap decision D2 for that setting for real, rather than by honest disclosure of inertness as the prior draft of this plan proposed.

**Derived, not stored. This is the load-bearing decision.** The authoritative answer at prerequisite-check time is computed live, every time. `student_enrollments.completed_at` is maintained only as a cache for the legacy surfaces that already read it; no prerequisite gate may ever read it. State this as a binding invariant, not a preference. The reasoning:

- **Denominator instability.** The denominator, "published lessons in the course version," changes whenever the owner publishes a new version or runs `apply_version_migration`. A stamp computed against an old denominator goes stale silently and invisibly. Live derivation is always correct against the current version.
- **The threshold itself is owner-editable at any time**, through `update_course_settings` (`202608300001...:487`). Raising it from 0.8 to 1.0 instantly invalidates every previously stored stamp. Recomputing every stored stamp on a settings change is a fan-out write this codebase has no precedent for and this plan does not want to introduce; deriving costs nothing extra and is always current.
- **Failure-mode asymmetry, which is exactly the harm the user's direction names.** A stale-generous stamp lets an unqualified student through. A stale-missing stamp permanently locks out a student who genuinely earned access. Live derivation has neither failure mode, by construction, because there is no stamp to go stale.
- **Cost is trivially affordable exactly where it is needed.** The check runs once per enrollment grant attempt, not per page load, and is two small aggregates over `enrollment_lesson_entitlements`, already keyed on `(enrollment_id, lesson_revision_id)`.

**Why the cache is still maintained, even though no gate reads it.** `student_enrollments.completed_at` is already read by `src/lib/weekUnlock.ts:39,64,88`, `src/lib/storageSigning.ts:44`, the RLS policies described in `SECURITY_FIXES_VERIFICATION.md:152-174`, and the admin dashboards. Leaving it permanently null for every workspace-authored enrollment would be a silent, cross-surface inconsistency those surfaces would otherwise have to individually work around. `recalculate_course_version_completion` maintains it, mirroring F3's precedent exactly, including the `auto_completed_from_progress` guard so it never overwrites a legacy or manually-set completion date.

**Orthogonality invariant.** Completion (`completed_at`) and visibility (`unlock_at` / `manual_release_state`) are independent facts about a lesson entitlement. Completion must never be modeled as a fourth value of the three-state manual-release enum; the manual-release control's three states are unchanged by this addition.

**Version-matching semantics.** `courses.prerequisite_version_id` names one specific version of the prerequisite course. Strict equality against that exact version would mean a student who completed v1 of the prerequisite course could never satisfy a prerequisite that names v2, and every republish of the prerequisite course would silently and permanently lock out everyone who already completed the earlier version. That is precisely the permanent-lockout harm the design review flagged and the user's direction warned against generally. Required semantics instead: resolve `prerequisite_version_id` to its owning `course_id`, then check whether the student has any active enrollment on any version of that course which meets the threshold, computing each such enrollment's ratio against its own version's published lesson set and comparing against the prerequisite course's current `completion_threshold`. This is course-level tolerance with version-accurate ratio math: the course being named is what matters, but each enrollment's completion is always evaluated against its own version's real lesson count, never a mismatched one. This must be explicitly tested with a republish scenario (acceptance item 6 below).

## Ship-gate G-ENT-1: apply_version_migration safety (mandatory, blocking, owned by this phase)

This gate is defined by the roadmap (`docs/plans/lizbeth-spanish-issue5-roadmap.md`, lines 40-73) and assigned to Phase 3 in the roadmap's Clause 1. It is reproduced here faithfully, as an Acceptance-section item rather than a risk-table row, per that clause's own requirement.

**The defect.** `apply_version_migration` unconditionally deletes every `enrollment_lesson_entitlements` row for the migrated enrollment and reinserts from scratch. Two distinct defects follow. First, no monotonic guard: it can move `unlock_at` later for a row a student could already see, re-locking content, which is exactly the hazard Phase 1's reconciliation was built to prevent by construction, in a path Phase 1 deliberately did not touch. Second, manual-state destruction: because it deletes rather than updates, it discards every `manual_release_state`, silently resetting a deliberate `released`, `held`, or `revoked` back to `automatic`, and it discards `completed_at`. Phase 1's plan states explicitly that revocation controls access and never history; this path violates that guarantee.

**Why fixing it here, now, is correct rather than deferrable.** Phase 2 made `unlock_offset_days` real, which armed the defect for the first time. This phase's local finding above sharpens the roadmap's framing further: the function is reachable from a live owner button today, not merely latent. The window in which this must be fixed is exactly this phase.

**The one part already handled.** Phase 2 routed this function's anchor through the shared `resolve_entitlement_anchor` helper, so it already computes the correct clock for both unlock models. That fixes which anchor it reads. It does nothing about the monotonic guard or the manual-state destruction, which are the two defects this gate covers and which this phase must fix.

**The fix, as ordered work.** Rewrite `apply_version_migration` so it no longer achieves its result by deleting and recreating rows. It must preserve each row's `manual_release_state`, `completed_at`, and all quiz history, and must never move `unlock_at` later for a row whose `unlock_at` is already in the past. Reuse Phase 1's established guard shape, `unlock_at = case when old.unlock_at <= now() then least(old.unlock_at, new_computed) else new_computed end`, rather than inventing a second formulation. Rows for lessons absent from the target version must still be removed; the prohibition is on the unguarded blanket delete-and-reinsert, not on all deletion. It must remain a structurally separate function from the bulk reconciliation path, per Phase 1's R3 mitigation.

**Acceptance evidence, reproduced faithfully from the roadmap, all mandatory, all database-level, and written as tests rather than prose claims.** See the Acceptance and validation section below for the five required assertions and the honest limit that accompanies them.

## Design route

**Standard, re-classified and re-verified rather than carried forward.** The roadmap stated Phase 3's design was "complete and passed, carried forward from the prior plan's reviewed packet." That claim was tested rather than trusted, and it did not survive intact: the re-verification found material drift, listed below. `design-director` led with `ux-architect` and `visual-system-designer`; `motion-designer` and `asset-art-director` were correctly skipped, since this work introduces no motion and no new imagery. `design-reviewer` returned an evidence-backed `NEEDS_REVISION` with nine findings, two of HIGH severity; the director revised once; the reviewer independently re-verified the two elaborated remediations against source and returned `PASS` with one required implementation-time correction.

### Design handoff (standard, passed)

**Drift found against the carried-forward packet, stated plainly rather than silently absorbed:**

- The old packet's manual-release control had four states including `revoked`. Cut to three; `revoked` is Phase 4's.
- The old packet specified `affected_students_sample` and a failure-row `lesson_title`; neither exists in the shipped contract. Withdrawn.
- The old packet listed twelve reconciliation states, one driven by `warnings[]`. That state is unreachable, since `warnings` is hardcoded empty with no writer. Corrected to **eleven** states, with `warnings[]` recorded as a reserved-but-currently-unreachable backend seam.
- The old packet mandated `.demo-button.caution` for visibility-reducing transitions. Rejected: that class lives only in `AdminStudentModals.css`, which this page does not import, and its `:hover` falls back to an undeclared `warning-700`. Use `.demo-button.primary`/`.demo-button.secondary` instead. This rejection is static analysis only, not confirmed against a real build's CSS chunking; that limit is stated below and should be confirmed at implementation time.
- The old packet's invariant "preserve four-hue separation for the owner-facing badge states" is explicitly retired, superseded by a zero-color-valence, text-only, three-state presentation; it has no referent once `revoked` is out of scope.
- The old packet's entire cadence section is superseded by what Phase 2 actually shipped (the two-tier control, `.tier2-cadence-region`, `ModeSwitchModal`, `.schedule-severity-error`/`.schedule-severity-advisory`).
- Entirely new since the packet: the cohort-scheduled second unlock model, the `manual_release` inertness disclosure, the apply-migration note, and the whole G-ENT-1 gate.

**The eleven reconciliation states:** idle; preview loading (`role="status"`); preview error (`.schedule-severity-error`, `role="alert"`, retry); preview populated with all-zero buckets (identical markup and tone to populated-nonzero, never styled as empty); preview populated non-zero; apply disabled; apply in-flight; apply success (`failed === 0`); apply partial-failure (status summary plus a separate `role="alert"` failures list); apply total-failure; stale-token-rejected (same class as total-failure, distinct copy, since it requires a fresh preview, not a retry).

The panel nests inside the existing published-version read-only Settings branch (`CourseWorkspacePage.tsx:69`) as an `<h3>`; it is never rendered for a draft, because entitlements exist only for published versions. Six buckets carry zero color valence: identical text treatment, hierarchy from bold label to count to descriptive sentence, no per-bucket tint or border. Apply is confirmed through the app-owned `Modal`, with `suppressDismiss={false}`, never `.destructive-warning`, and the modal summarizes totals plus the excluded-by-override count. Copy must name the course's actual anchor model, each student's own enrollment date, or the cohort's start date, rather than a singular "the unlock date." Returning to the tab resets to idle; the preview token is session-only.

**The manual hold/release control.** A new `<div className="workspace-panel"><h2>Student roster</h2>` sibling after the existing Students-tab panel, which is left untouched. Student-first: a collapsed list of enrolled students, each an `aria-expanded` toggle at a 44px target, lazily revealing a `role="region"` per-lesson list. A `<select>` per lesson with exactly three options, matching this file's pervasive select idiom rather than introducing a radiogroup. A fourth, non-actionable cell state for "no entitlement row yet": `<select disabled>` plus a visible DOM explanation, never tooltip-only and never styled as an error.

Required disclosures, all binding:

- The Released modal states, at the moment of the decision, both that the lesson becomes visible immediately and that this cannot be undone by any later action including switching back to Automatic.
- The Automatic option, **when selected on a row whose `unlock_at` is already in the past**, see the required correction below, positively discloses that the lesson stays unlocked and will not re-lock.
- Copy states that a manual override affects only this one student, never the shared cohort anchor for other students in a cohort-scheduled course.

Held and Automatic-from-never-released are fully reversible and get no modal, only an immediate inline `role="status"` confirmation. Phase 4 extends the same `<select>` with a fourth option without relocating the control.

**Required implementation-time correction, from the reviewer's final PASS.** The Automatic-transition disclosure was originally specified as conditioned on the row being "previously Released." That predicate is not computable from the data the roster read exposes: `manual_release_state` and `unlock_at` cannot distinguish a row forced to `now()` by a past Released action from a row whose ordinary schedule has simply elapsed. Implement the observable predicate instead: disclose when Automatic is selected on a row whose `unlock_at` is already in the past. This needs no new data and no new read. Carry this into implementation as a binding requirement, not a footnote, because dropping it silently recreates exactly the gap the review caught.

**The prerequisite picker.** Replaces the raw UUID `<input>` at `CourseWorkspacePage.tsx:236` with a `<fieldset>` mirroring the existing "Preview lessons" fieldset pattern. Two stacked selects, Course (the owner's other courses, excluding the current course, with a "None" option) then Version (disabled until a course is chosen, labelled `v{version_no} · {status}`, deliberately not filtered to published-only, since nothing in `update_course_settings` restricts it). Six states: loading; populated/none; populated/valid; unresolvable saved value (`.schedule-severity-error` alert, with the raw ID de-emphasized rather than hidden, selects defaulting to None); load-error/degraded (`.schedule-severity-advisory`, and a transient failure must never null an existing saved value); course-changed/version-reset-pending. A static field hint discloses both inertness facts recorded in the findings above.

**Field order is binding, and the reason is non-obvious.** `src/pages/CourseSettingsFix.css` (imported at `CourseWorkspacePage.tsx:12`) contains `.settings-grid fieldset+label{...}`, with an input rule setting `height:20px;max-height:20px`. It matches nothing today because the existing "Preview lessons" fieldset is the grid's last child. Inserting the prerequisite fieldset before the `manual_release` checkbox `<label>` would make it match for the first time, and `.checkbox-label input{width:auto!important;min-height:20px!important}` shields width but not height or max-height, so the checkbox would be visually distorted. Required order: `manual_release` checkbox label, then the prerequisite fieldset, then the completion-threshold fieldset, then the existing "Preview lessons" fieldset last, so no `<label>` is ever an immediate sibling of a `<fieldset>` in `.settings-grid`. The reviewer independently reconstructed the full child sequence and confirmed the reorder introduces no new adjacency.

**Completion-threshold hint.** A `<fieldset>` wrapping the unchanged input, plus `<p id="completion-threshold-hint" className="field-hint">`, with `aria-describedby` on the input. One static state, stating plainly that the value is saved and nothing in the product reads or enforces it.

**Apply-migration note.** A `<p className="authoring-note" id="apply-migration-note">` before the existing Versions-tab button, reusing `.authoring-note` verbatim (already used at line 125), with `aria-describedby` on the button, stating that a migration preserves each student's manual hold/release state. It must ship only together with the G-ENT-1 fix; rendering it earlier would be a false claim. No new confirmation gate is added to the button; whether it should ever gain one is recorded as an open question, not decided here.

**Visual system.** Extend the existing "Field Workbook" system with no new hex or spacing literal. Verified contrast, cited separately rather than conflated: `.schedule-severity-error` is ink-800 on paper-200, 10.10:1; `.schedule-severity-advisory` is ink-800 on paper-100, approximately 11.3:1; field hints are ink-700 on paper-100, 8.37:1; `.demo-button.secondary` text is ink-900 on paper-100, 14.43:1. All AAA. The `brass-600`/`paper-50` primary-button pairing is reused verbatim from the shipped Issue-21 fix and was not independently re-verified in this pass; flag it as an explicitly unverified limit below.

New class hooks: a roster panel scope, `.roster-lesson-row`, and a field-hint pattern. The disabled-select dimming rule must be scoped as `.roster-lesson-row select:disabled{opacity:.6}`, never a bare unscoped `select:disabled`, since this codebase uses global non-module CSS.

### Design delta for prerequisite enforcement (added by explicit user direction)

`design-route` remains **standard**. This is a delta over the packet already passed above, at lines covering the prerequisite picker and completion-threshold hint; everything there stands unless listed here. `design-director` led with `ux-architect` and `visual-system-designer`; `motion-designer` and `asset-art-director` were again correctly skipped. `design-reviewer` returned `NEEDS_REVISION` with one CRITICAL finding and four lesser findings; the director revised once; the reviewer independently re-verified the revision and returned `PASS`, with two limits carried forward and recorded in the visual notes below.

**A. Prerequisite picker hint copy inverts.** The plan's prior disclosure of inertness (originally at the picker's field hint, and originally cited by R6) is now false and is replaced. The six picker states and the binding field order established above are unchanged. New populated/valid copy:

> "Enforced: a student cannot be enrolled in this course, or granted its lesson entitlements, until they complete {courseTitle} v{version_no}, checked live each time enrollment is attempted. \"Complete\" means reaching {courseTitle}'s own completion threshold — the live share of {courseTitle}'s own published lessons marked complete — which is set on {courseTitle}'s own Settings tab, not here. Record a student's completion of {courseTitle} from that course's Student roster; doing so genuinely raises this ratio and can satisfy the requirement immediately."

The reviewer specifically confirmed the which-course disambiguation in this copy is precise and must be preserved verbatim. The unresolvable-saved-value state now states that no requirement is currently enforced; the load-error state states that any saved requirement remains enforced.

**B. Completion-threshold hint copy inverts.** Base copy states the value is the share of this course's published lessons a student must complete for this course to count as complete when another course names it as a prerequisite, checked live against the current published-lesson count, and that changing it immediately changes the next check for every enrolled student, with nothing cached. The input is presented as a whole percent, 0-100, against the underlying `0..1` stored column. Four states:

- Populated: plain percent value.
- Blank/unset: renders empty, never a fabricated default; appends "Blank means all lessons are required (100%)."
- Literal 0, distinct from blank: `.schedule-severity-advisory`, `role="status"`: "Entering 0 means a student is considered complete as soon as they enroll, before finishing any lesson."
- Out-of-range/non-numeric: Save blocked; `.schedule-severity-error`, `role="alert"`, id `completion-threshold-error` added to the input's `aria-describedby`: "Enter a whole percent from 0 to 100, or leave blank for 100%."

**Required save-path fix, verified against source.** `src/pages/CourseWorkspacePage.tsx:236` currently performs an unconditional `Number(threshold)/100`, which turns a blank field into `0`. Replace it with a blank-vs-numeric branch: an empty or whitespace-only field saves `NULL`, never `0` and never a fabricated default. This is acceptance item 15 below and risk R21.

**C. New roster completion column and action.** Extends the roster panel established above. A separate `<button>` beside the existing three-state `<select>`, two independent controls in one row, never a fourth select option. Four button states:

- **Completable:** `aria-pressed="false"`, "Mark complete."
- **Completed:** `aria-pressed="true"`, "Completed · Clear," opens the app-owned `Modal`.
- **Held-blocked (new):** an entitlement row exists, `manual_release_state = 'held'`, not yet completed. The completion button is disabled with its own distinct visible explanation: "This lesson is currently held from {studentName}, so it can't be marked complete until its access is changed to Automatic or Released." The `<select>` stays enabled, so the owner can unblock from the same row. This is a correctness requirement, not cosmetic: permitting completion here would let an owner satisfy another course's now-real prerequisite gate for a student who never actually saw the lesson.
- **No-entitlement-row:** both controls disabled, one shared explanation, unchanged from the existing packet.

**State-priority rule:** Completed always wins over Held-blocked, so a lesson completed before being held later stays clearable. Marking complete takes no modal, only an inline `role="status"` confirmation. Clearing requires the app-owned `Modal` (the `ModeSwitchModal` pattern, `triggerElement` set), disclosing that clearing may drop the student below the threshold and affect their qualification wherever another course names this one as a prerequisite, and that quiz attempt history is unaffected. Cancel is `.demo-button.secondary`, Confirm is `.demo-button.primary`; processing and error-on-clear sub-states are required.

**Per-student summary**, visible at the collapsed row header without expanding, using `{thresholdLabel}` which renders "{N}%" for a configured threshold and "100% (default — no threshold set)" for `NULL` — a configured value of exactly 1.0 (100%) takes the configured branch, not the default branch:

- Meets threshold: "{studentName} — {completed} of {published} lessons complete · Meets this course's threshold ({thresholdLabel})."
- Below threshold: "{studentName} — {completed} of {published} lessons complete · Needs {thresholdLabel} to meet this course's threshold."
- Zero published lessons: "{studentName} — This version has no published lessons yet; completion cannot be evaluated."

**Denominator-risk disclosure**, conditional, shown only when the student has at least one held-and-not-completed lesson: `role="status"`, `.schedule-severity-advisory`: "{heldCount} lesson(s) currently held and not completed. A held lesson still counts toward the total, so it can prevent {studentName} from reaching this course's threshold even if every other lesson is complete."

**D. New enrollment-blocked alert**, in the existing `{message}` slot at `src/pages/CourseWorkspacePage.tsx:157`. On a prerequisite block, `role="alert"`, `.schedule-severity-error`:

> "{studentDisplayName} cannot be enrolled yet: they haven't completed the prerequisite, {prerequisiteCourseTitle} v{version_no}. They have completed {numerator} of {denominator} published lessons ({actualPercent}%); {requiredPercent}% is required."

Built from `assert_course_prerequisite`'s structured error payload (see the SQL core work below), never substring-matched from free text. The student display name resolves via the same coalesce pattern `listMigrationEnrollments` already uses (full name, then email, then the literal `'Student'`), never the raw UUID. Every other approval failure keeps today's plain `role="status"` treatment; the new alert styling is reserved for the prerequisite block specifically. The request row stays pending and Approve stays enabled as its own retry, so the owner can re-approve once the student has completed enough of the prerequisite. The self-enroll path (`request_cohort_enrollment`) is student-initiated and ships no Phase 3 UI at all; this phase gives it a message contract only, and its UI belongs to Phase 5.

**Visual notes, all verified.** No new hex or spacing literal. New hooks: `.field-hint` (confirmed to have no prior definition anywhere in the repository despite being named in the existing packet), `.prerequisite-hint-region`, `.roster-panel`, `.roster-lesson-row` (grid `1fr auto`, stacking to one column at the existing 700px breakpoint with the button full-width), `.roster-complete-button`, `.roster-student-toggle`, `.roster-completion-summary`.

`.roster-complete-button` must combine with `.demo-button` and must never also carry `.primary` or `.secondary`. Its full class list is `demo-button roster-complete-button`, plus `.completed` when applicable, because `.workspace-panel .demo-button.primary:disabled{opacity:.7}` at specificity (0,4,0) would otherwise beat the intended `.roster-lesson-row button.roster-complete-button:disabled{opacity:.6}` at (0,3,1). The `.completed` variant uses `background: var(--color-paper-200)` with `box-shadow:none` and never a hue change, since terracotta already carries error meaning on this page. Held-blocked and no-entitlement-row deliberately share one disabled treatment (`opacity:.6`) and are distinguished only by their accessible names and separate explanations, never by different visual weight.

Contrast: ink-900 `#2a2420` on paper-200 `#f0ebe2` recomputed at 12.88:1 (AAA).

Correction to record from this review pass: `.modal-confirmation-content` does have a rule after all — `src/components/AdminStudentModals.css:1-5` defines `display:flex; flex-direction:column; gap:1rem`, and `CourseWorkspacePage.tsx:200` already depends on it, so the error-on-clear paragraph inherits that gap and needs no new CSS.

Two limits carried forward from this delta review, in addition to the limits already recorded elsewhere in this plan: the same unverified-build-chunking limit the existing packet already applies to `.demo-button.caution` applies here too, since `CourseWorkspacePage.tsx` imports only `CourseWorkspace.css` and `CourseSettingsFix.css` (verified); and this delta's contrast and specificity analysis is source-level only, not confirmed against a live build.

## Ordered work

TDD is mandatory throughout: no production code before a failing test exists for it. This engagement's pattern has found real bugs invisible to unit tests in every phase so far, so live browser verification is mandatory, not optional, for the UI-bearing steps.

1. **RED evidence, before any fix.** `npx supabase start`; `npx supabase db reset`. Demonstrate G-ENT-1 concretely: seed a published version and an enrollment, set one row's `manual_release_state` to `held` and another to `released`, set `completed_at` on one, then call `apply_version_migration` to a version with larger offsets and capture that the manual states were reset to `automatic`, `completed_at` was destroyed, and `unlock_at` moved later on an already-visible row. Capture this as evidence before writing the fix.
2. **RED evidence for the completion semantic (added by explicit user direction), alongside step 1.** Demonstrate concretely, before any fix, that a workspace-authored enrollment has no reachable completion path today (F1, F4), and that both the course-level prerequisite gate and the lesson-level prerequisite gate (F2) are unsatisfiable as shipped.
3. **Failing tests first**, for every acceptance guarantee below, including the five mandatory G-ENT-1 database-level tests, the sixteen completion-semantic acceptance items, and the component-level tests.
4. **The G-ENT-1 fix.** Rewrite `apply_version_migration` per the gate section above.
5. **The two new reads**: a per-student-per-lesson entitlement roster returning `manual_release_state` and `unlock_at`, with an explicit sentinel distinguishing "no entitlement row yet" from all three real states; and a cross-course, owner-scoped version listing for the prerequisite picker. Expose both as Edge actions following the existing owner-authorization pattern.
6. **The completion-semantic SQL core (added by explicit user direction), sequenced alongside steps 4-5 and owned by the same anticipated T2.**
   - `public.course_version_completion_ratio(p_enrollment_id uuid) returns numeric`: the ratio defined in "The completion semantic" above, well-defined and never satisfying a threshold for the zero-lesson case.
   - `public.has_completed_course_version(p_user_id uuid, p_course_version_id uuid) returns boolean`: the derived predicate with the course-level version-matching semantics above, plus a legacy allowance for an enrollment carrying a non-auto `completed_at <= now()` from the pre-existing band path.
   - `public.assert_course_prerequisite(p_user_id uuid, p_target_course_version_id uuid)`: raises a structured error carrying prerequisite course title, version_no, numerator, denominator, and required threshold, as a stable SQLSTATE plus a JSON detail payload, so the client never substring-matches free text.
   - Refactor `grant_enrollment_entitlements_with_prerequisites` to delete its inline `se.completed_at is not null` check (`202608300001...:331-340`) and delegate to `assert_course_prerequisite`, so there is exactly one definition of the rule across all three callers.
   - Wire `assert_course_prerequisite` into `approve_enrollment_request` and `request_cohort_enrollment`, before any insert in each, per F7. Deliberately do not put the gate inside `materialize_enrollment_entitlements` itself: that function is a shared chokepoint, and gating it there would make any future re-materialization or repair call start blocking existing enrollments. This is a deliberate decision, recorded with its reason, not an oversight.
   - `public.record_lesson_completion(p_enrollment_id uuid, p_lesson_revision_id uuid)`: a new student-callable RPC, kept structurally separate from the band-scoped `record_lesson_progress` rather than overloading it, on the same reasoning as Phase 1's R3 (the legacy path is security-sensitive, feeding RLS and signed-URL access, and must not be entangled with new logic). It must authenticate the caller as the enrolled student on an active enrollment; refuse a lesson the student cannot currently see (`manual_release_state <> 'held'` and (`manual_release_state = 'released'` or `unlock_at <= now()`)), since without this a student could complete a locked course instantly and satisfy any prerequisite; set `completed_at = coalesce(completed_at, now())`, monotonic, never un-completing; then call the recalculation below. No student surface calls this until Phase 5.
   - `public.set_lesson_completion(p_enrollment_id uuid, p_lesson_revision_id uuid, p_completed boolean, p_owner_id uuid)`: the owner-side record/clear action backing the roster control, owner-authorized on the existing `list_migration_enrollments` pattern. Unlike the student path, this one may clear. This is what makes completion reachable by a real in-product actor in this phase, rather than only at Phase 5.
   - `public.recalculate_course_version_completion(p_enrollment_id uuid)`: mirrors F3's precedent including the `auto_completed_from_progress` guard; called after every completion write on both paths.
   - Two new owner reads for the roster's completion column and per-student ratio summary, folded into step 5's read work.
7. **Client service layer.** Extend the `CourseAction`/`ReadAction` unions in `src/services/courseAuthoring.ts` and add wrappers for the already-wired Edge actions (`set_lesson_access_state`, `preview_reconciliation`, `apply_reconciliation`, `get_progress_evidence`) plus the reads from steps 5 and 6.
8. **The reconciliation panel**, all eleven states.
9. **The student roster and manual hold/release control**, three states plus the non-actionable no-entitlement state, with every required disclosure including the corrected `unlock_at`-in-the-past predicate, plus **(added by explicit user direction)** the new roster completion column and action (four button states, the per-student summary, and the conditional denominator-risk disclosure) from the design delta above.
10. **The prerequisite picker**, six states, in the required field order, with **(added by explicit user direction)** the inverted enforced-state copy from the design delta above.
11. **The completion-threshold hint (inverted copy, added by explicit user direction, including the required blank-vs-zero save-path fix) and the `manual_release` inertness disclosure (unchanged).**
12. **(Added by explicit user direction.)** The new enrollment-blocked alert in the request-list `{message}` slot, built from `assert_course_prerequisite`'s structured payload.
13. **The apply-migration note**, gated on step 4 being complete.
14. **Full suite after `npx supabase db reset`. Verifier pass. Browser Validator pass.**

**Ownership.** T1 for the client, UI, and copy steps (7-13). Anticipate T2 for steps 4-6, the correctness-sensitive SQL core. The scope increase has grown the SQL core materially, so T2 ownership for those steps is now a stronger expectation than in the original draft of this plan; this remains an expectation, matching Phase 1's and Phase 2's framing, and not a failure condition if T1 proves capable.

## Interfaces and data

- New migration following the Phase 1/Phase 2 naming pattern: the rewritten `apply_version_migration`, plus the two new read functions.
- No schema change is anticipated for the G-ENT-1 fix or the roster/prerequisite-picker reads. `manual_release_state`, `unlock_at`, `completed_at`, and `cohort_id` all already exist.
- Backward compatibility: the rewritten `apply_version_migration` keeps its exact signature `(p_enrollment_id uuid, p_target_version uuid) returns integer` and its existing Edge action `apply_migration`, so the Versions-tab caller is unchanged. Its return value's meaning may shift from "rows inserted" to "rows affected"; if so, this must be stated explicitly in the migration's comment and in the handoff to Verifier.
- Contract corrections to record against the Phase 1 plan's stated interface: no `affected_students_sample`; `warnings` is hardcoded empty with no writer; apply failures carry `lesson_revision_id` rather than `lesson_title`, so any lesson title shown in a failure list must be resolved client-side.
- `courses.prerequisite_version_id`, `courses.completion_threshold`, and `courses.manual_release` are all unchanged in storage; only their UI presentation, and, by explicit user direction, their real enforcement, change in this phase.
- **(Added by explicit user direction.)** New functions: `public.course_version_completion_ratio(p_enrollment_id uuid) returns numeric`; `public.has_completed_course_version(p_user_id uuid, p_course_version_id uuid) returns boolean`; `public.assert_course_prerequisite(p_user_id uuid, p_target_course_version_id uuid)` (void, raises a structured error on failure); `public.record_lesson_completion(p_enrollment_id uuid, p_lesson_revision_id uuid)` (student-callable); `public.set_lesson_completion(p_enrollment_id uuid, p_lesson_revision_id uuid, p_completed boolean, p_owner_id uuid)` (owner-callable); `public.recalculate_course_version_completion(p_enrollment_id uuid)`. `assert_course_prerequisite`'s error payload is an interface contract in its own right: a stable SQLSTATE plus a JSON detail payload carrying course title, version_no, numerator, denominator, and required threshold. The client must consume it structurally and must never substring-match free text.
- **(Added by explicit user direction.)** `grant_enrollment_entitlements_with_prerequisites` (`202608300001...:312-368`) is refactored, not left as-is: its inline `se.completed_at is not null` check (lines 331-340) is deleted and replaced with a call to `assert_course_prerequisite`, so the rule has exactly one definition shared by all three callers (`grant_enrollment_entitlements_with_prerequisites`, `approve_enrollment_request`, `request_cohort_enrollment`).
- **(Added by explicit user direction.)** No gate anywhere in this phase reads `student_enrollments.completed_at`. That column remains a cache only, maintained by `recalculate_course_version_completion` for the surfaces listed in "The completion semantic" above.

## Acceptance and validation

All items below are mandatory unless stated otherwise.

**Ship-gate G-ENT-1, reproduced faithfully from the roadmap, in this phase's own Acceptance section rather than its risk table, per the roadmap's Clause 1.** Phase 3 cannot be marked complete and its Verifier pass cannot be claimed until all five of the following are produced as tests rather than prose claims:

1. A student holding an entitlement whose `unlock_at` is already in the past, migrated to a version whose `unlock_offset_days` for that lesson is larger, retains a visible row: the migration must not move `unlock_at` later for an already-visible row. Assert by querying as the student database role so RLS is genuinely exercised, never by a service_role read that would pass even if the policy were broken.
2. A row in each of `released`, `held`, and `revoked` retains its exact `manual_release_state` across a migration. All three states, individually asserted. Note for the record: `revoked` is asserted here at the database level even though no `revoked` UI ships this phase. That is deliberate and is not scope creep; the gate covers the migration path's preservation behavior for all four states, and Phase 4 depends on it.
3. `completed_at` and every `quiz_attempts` row for the migrated student and lesson survive the migration unchanged.
4. A source-level assertion that `apply_version_migration`'s body contains no unguarded `delete from enrollment_lesson_entitlements`. State the intent in words as well, so a future author who restructures the function cannot satisfy a literal grep while reintroducing the behavior: the requirement is that migration preserves per-row manual state and never reduces visibility, by whatever mechanism.
5. A regression assertion that the bulk reconciliation path and the migration path remain structurally separate functions, consistent with Phase 1's R3 mitigation, so this fix does not merge them.

**Honest limit, reproduced from the roadmap alongside these:** these assertions prove the migration path is safe at the database level, which, per the roadmap's reframing finding, is not the same as a student having experienced it, and cannot be until Phase 5 ships. Phase 5 re-validates it through a real student session.

**Other acceptance, all mandatory:**

- The reconciliation preview's six bucket counts match the changes a subsequent apply actually makes.
- Applying with a stale `preview_token` is rejected and surfaced as the stale-token state, not silently applied and not presented as a generic error.
- Reconciliation applied from the panel never modifies a row whose `manual_release_state` is `held`, `released`, or `revoked`.
- Setting a lesson to `released` through the UI makes it visible under the student-read policies; setting it to `held` makes it invisible. Assert both by querying as the student database role, not by a service_role read.
- Selecting `automatic` on a row whose `unlock_at` is already in the past produces the permanent-unlock disclosure. Assert the disclosure renders, and assert at the database level that the row does not re-lock.
- The roster renders the "no entitlement row yet" state as disabled and non-actionable with a visible explanation, and no request is sent for it.
- The panel is absent for a draft version and present for a published one.
- The prerequisite picker resolves a saved value to a real course and version, and renders the unresolvable state without nulling the stored value; a transient load failure renders the advisory state and also does not null it.
- The `.settings-grid` field order is as specified, and the `manual_release` checkbox renders undistorted at 20×20px.
- `aria-describedby` is present and correct on the completion-threshold input and the apply-migration button, verified through the accessibility tree rather than visually.
- `src/__tests__/nativeDialogPolicy.test.ts` passes, and the deterministic no-native-dialog source scan finds zero matches in the changed files.
- Full suite passes after `npx supabase db reset`.
- Verifier pass, then Browser Validator pass. Unit tests alone are explicitly insufficient, in the same register Phase 2 used for this statement.

**Completion-semantic acceptance (added by explicit user direction; all mandatory).** The user's bar is that the completion signal itself is provably correct, tested through a real completion scenario and not merely as gating logic in isolation. Written as tests, not prose:

1. **End-to-end negative:** a student who has not met the prerequisite course's threshold genuinely cannot be enrolled and genuinely receives no entitlement rows in the gated course, asserted through both `approve_enrollment_request` and `request_cohort_enrollment`, and asserted by querying as the student database role so RLS is genuinely exercised, never a service_role read.
2. **End-to-end positive:** the same student, after completing enough lessons of the prerequisite to meet its threshold, genuinely can be enrolled and genuinely receives entitlement rows. Drive the completion through the real RPC, not direct table writes.
3. **Threshold boundary:** with `completion_threshold = 0.8` and five published lessons, three complete fails and four complete passes. Assert the exact boundary.
4. **Null threshold** defaults to requiring every published lesson.
5. **Zero-lesson version** is never complete and never satisfies a prerequisite.
6. **Republish tolerance:** a student who completed an earlier version of the prerequisite course still satisfies a prerequisite naming a later version of that same course. This is the permanent-lockout regression test.
7. **Live re-evaluation:** raising `completion_threshold` after a student qualified causes the next check to fail, proving derivation rather than caching. Also assert the containment boundary: already-granted entitlements are not retracted, because the gate runs only at grant time.
8. **Held lesson** cannot be marked complete through the owner action; and a held-and-not-completed lesson still counts in the denominator, so it can cap the achievable ratio. Assert both.
9. **Student path refuses an invisible lesson:** `record_lesson_completion` fails for a lesson that is held or whose `unlock_at` is in the future.
10. **Monotonicity:** the student path never un-completes; only the owner path can clear.
11. **F2 regression:** the lesson-level `prerequisite_lesson_revision_id` gate begins firing once completion has a writer. Assert a lesson with an uncompleted lesson-prerequisite is withheld and is granted after that prerequisite lesson is completed. This behavior is new to this phase and must not surprise anyone downstream.
12. **Structured error:** the block surfaces as a parseable structured payload carrying course title, version_no, numerator, denominator, and threshold, asserted structurally, never by substring match.
13. **Cache consistency:** `student_enrollments.completed_at` is maintained for workspace-authored enrollments and never clobbers a legacy or manually-set completion date, per the `auto_completed_from_progress` guard.
14. **No gate reads the cache:** a source-level assertion that no prerequisite path reads `student_enrollments.completed_at` directly, with the intent stated in words as well, so a future author cannot satisfy a literal grep while reintroducing the coupling.
15. The blank completion-threshold field saves `NULL` and never `0`.
16. Existing acceptance items above remain unchanged, plus `src/__tests__/nativeDialogPolicy.test.ts` and the deterministic no-native-dialog scan cover every file changed by this addition too.

## Risks and rollback

| ID | Severity | Risk | Mitigation |
|----|----------|------|------------|
| R1 | Critical | The G-ENT-1 rewrite reintroduces the delete-and-reinsert shape under a different form, satisfying the literal grep while destroying manual state | Mitigated by the worded intent in acceptance item 4 plus the three behavioral preservation tests (items 1-3) |
| R2 | Critical | An implementer merges the migration path into the reconciliation path while fixing it, since both now need the same guard, directly contradicting Phase 1's R3 | Mitigated by acceptance item 5 |
| R3 | High | The guard is evaluated against a stale in-memory value rather than the live on-disk row, reopening the race Phase 1's R2 closed | Mitigate the same way Phase 1 did: evaluate against the row at update time |
| R4 | High | `revoked` leaks into the owner UI as an option, a badge hue, or copy, stealing Phase 4's scope and shipping a destructive control without its own design pass and approval | Mitigated by the three-option invariant plus a test asserting the select renders exactly three options |
| R5 | High | The permanent-unlock disclosure is dropped because the "previously Released" predicate is not computable, exactly as the reviewer caught | Mitigated by the corrected `unlock_at`-in-the-past predicate being binding in this plan and covered by acceptance |
| R6 | Medium | *(Retired as originally written.)* The prerequisite picker no longer makes an inert setting look functional, because, by explicit user direction, the setting is now genuinely enforced. The residual risk is the inverse: the enforced-state copy must accurately explain how completion is recorded, or an owner cannot act on a block. Mitigated by the design delta's copy in section A above and by acceptance item 12's structured-error requirement. |
| R7 | Medium | The new prerequisite fieldset triggers `CourseSettingsFix.css`'s `fieldset+label` rule and distorts the checkbox | Mitigated by the binding field order and its acceptance check |
| R8 | Medium | An unscoped `select:disabled` rule dims disabled selects across the app | Mitigated by the required scoping to `.roster-lesson-row select:disabled` |
| R9 | Medium | Reconciliation copy assumes the rolling model and misleads a cohort-scheduled course's owner | Mitigated by the anchor-naming copy requirement |
| R10 | Medium | The roster read is unbounded and degrades on a large cohort | `list_migration_enrollments` caps at 200 as precedent; pagination is permitted variation |
| R11 | Low | The apply-migration note ships before the G-ENT-1 fix and states something false | Mitigated by the explicit ordering requirement (step 10 gated on step 3) |
| R12 | Low | A stale local database produces false results | Mandatory `npx supabase db reset` before every validation pass |
| R13 | Critical | Enforcement is wired while completion remains unreachable in practice, permanently blocking enrollment on any course with a prerequisite | Mitigated by shipping the owner-side roster completion action in this same phase, so completion is reachable by a real in-product actor without waiting for Phase 5, and by acceptance items 1-2 and browser journey 2, which validate the printed recovery path end to end |
| R14 | Critical | Version-strict prerequisite matching permanently locks out students who completed an earlier version of the prerequisite course | Mitigated by the course-level version-matching semantics and acceptance item 6 |
| R15 | High | A stored completion stamp goes stale against a changed denominator or threshold, either locking out an earned student or admitting an unqualified one | Mitigated by construction: the gate derives live and no gate may read the cache; acceptance items 7 and 14 |
| R16 | High | The newly-live lesson-level prerequisite gate (F2) surprises the team as an unexplained regression, since nothing currently documents that it was dormant only for want of a writer | Mitigated by recording it as a known, intended consequence and by acceptance item 11 |
| R17 | High | A student marks a locked or held lesson complete and instantly satisfies a prerequisite | Mitigated by the visibility precondition in `record_lesson_completion` and acceptance item 9 |
| R18 | Medium | An owner holds a lesson and silently makes a course uncompletable, blocking a downstream prerequisite with no visible cause | Mitigated by the conditional denominator-risk advisory and acceptance item 8 |
| R19 | Medium | Raising a threshold retroactively un-qualifies students | Contained because the gate runs only at grant time and already-granted entitlements are never retracted; disclosed in the threshold hint copy and asserted by acceptance item 7 |
| R20 | Medium | The gate is placed inside the shared `materialize_enrollment_entitlements` chokepoint and starts blocking legitimate re-materialization or repair of existing enrollments | Mitigated by the deliberate decision to wire the predicate at the two grant sites only, recorded with its reason |
| R21 | Medium | The blank completion-threshold field saves 0 through the existing unconditional `Number(threshold)/100`, silently making every student instantly complete | Mitigated by the required save-path branch and acceptance item 15 |
| R22 | Low | Percent precision narrows on save, since `numeric(5,4)` holds more precision than a whole-percent field round-trips (a stored 0.8333 displays as 83% and an untouched save would narrow it to 0.83) | Recorded as a known limit for engineering to resolve at implementation time |

**Rollback.** The G-ENT-1 fix is a function-body replacement; reverting the migration restores the prior body exactly, with no data migration, though reverting deliberately restores a known-defective function and should not be done casually. The two new reads are additive. Every UI change is confined to the authoring workspace and reverts cleanly; no student-facing behavior exists to regress. **(Added by explicit user direction.)** The completion-semantic functions (`course_version_completion_ratio`, `has_completed_course_version`, `assert_course_prerequisite`, `record_lesson_completion`, `set_lesson_completion`, `recalculate_course_version_completion`) are additive new functions with no schema change; reverting them restores the prior inert-but-honest state, at the cost of re-permitting any enrollment already blocked by the gate during the time it was live. The `grant_enrollment_entitlements_with_prerequisites` refactor and the two grant-site wiring changes are function-body replacements with no data migration and revert the same way as the G-ENT-1 fix.

## Assumptions and decisions

**Safe assumptions:**

- The current course excludes itself from its own prerequisite dropdown. Nothing forbids self-reference, but excluding it is a safe default.
- Component tests can exercise the new panels in the existing Vitest setup, as the sibling phases' tests do.
- The roster read can reuse `list_migration_enrollments`' owner-authorization pattern.

**Explicitly unverified limits, stated rather than buried:**

- The `WeekCard` `aria-expanded`/`role="region"` disclosure precedent was never independently re-verified across the two design passes in this phase.
- The `.demo-button.caution` rejection is import-graph static analysis, not confirmed against a real build's CSS chunking; an implementer should confirm at implementation time.
- The `brass-600`/`paper-50` primary-button contrast pairing was reused verbatim rather than recomputed in this pass.

**Superseded recommendation, preserved for the record, and the user's decision that overturned it.** This section originally asked the user to confirm intent at approval; the user has now done so, and overturned the recommendation below. The prior text is kept verbatim, because the reasoning it contains, that nothing sets completion, is exactly the gap this phase's added scope now closes, not because it is still the plan's position:

> Prerequisite enforcement is surfaced but deliberately not activated this phase. The picker ships, replacing the UUID input, with an honest disclosure that the setting is not currently enforced. Wiring `grant_enrollment_entitlements_with_prerequisites` into the two live grant sites is deliberately not done, for a specific verified reason rather than as deferral by default: the function gates on `student_enrollments.completed_at`, which nothing in the product ever sets for a workspace-authored enrollment, so activating it would convert an inert setting into a gate that silently and permanently blocks every enrollment on a course that uses it. Making it genuinely work requires first deciding what "completing a course version" means and building something that sets that field, which is a real piece of product design, not a wiring task, and larger than this phase. This follows the same honest-disclosure precedent the programme already set for `completion_threshold`, and is consistent with the roadmap's decision D2 "fold in" (all four settings are addressed in this programme; addressing one honestly as unenforced is still addressing it).
>
> Recommended: proceed with the plan as written. The alternative, if the user wants prerequisite enforcement to actually work now, is to scope a course-completion semantic as its own work item, which would grow this phase materially. Flag that the user may direct otherwise at approval.

**The user's direction, verbatim:**

> "yes we want reprequisite enforcement actually planned and wired up now as part of all of this. don't take shortcuts or get lazy. why wouldn't we do the full entire job?"

**Why the prior recommendation's premise no longer applies.** The recommendation above was correct as far as it went: activating the gate against an unwritten column would have permanently blocked every enrollment on a course with a prerequisite. That premise, that nothing sets completion, is precisely what this phase's added scope now fixes: "The completion semantic" section above defines the semantic, `record_lesson_completion` and `set_lesson_completion` give it real writers, and `assert_course_prerequisite` is wired into both live grant sites only after those writers exist. The scope is larger than the original draft of this phase, exactly as the recommendation warned it would be if the user chose this path; the user has reviewed that tradeoff and directed the phase to absorb it rather than defer it.

**Open questions recorded but not blocking:**

- Whether `affected_students_sample` and failure-row lesson titles should be added to the backend contracts. Recommended, not required.
- Whether the prerequisite picker should filter to published-only versions.
- Whether the Versions-tab "Apply migration" button should ever gain its own confirmation gate.
- Whether the roster needs search/filter at scale.
- Whether `warnings[]` should ever be populated, which would restore a twelfth reconciliation state.
- **(Added by explicit user direction.)** Whether an owner should be able to override the prerequisite gate at approval time with an explicit confirmation. Recommended not to add: it would change `approve_enrollment_request`'s signature, and the owner already has a first-class escape hatch in the roster completion action, which is also the more honest option because it records the completion actually being claimed rather than bypassing the check. The alternative is recorded here so the user can direct otherwise.
- **(Added by explicit user direction.)** Whether the adjacent raw-UUID display in the enrollment-request list at `CourseWorkspacePage.tsx:157` should be fixed in the same change as the new blocked-alert message. Recommended, not required.
- **(Added by explicit user direction.)** Two pre-existing token gaps, out of scope but worth raising: `--font-size-label` and `--color-ink-600` are referenced by `src/pages/CourseWorkspace.css` (lines 1, 5) but are absent from `src/tokens/field-workbook.generated.css`.
- **(Added by explicit user direction.)** Carried design limits: `.modal-confirmation-content`'s cross-file CSS reachability is verified at source level only, not against a live build's chunking; and disabled controls sit outside the Tab order, a pre-existing codebase-wide limitation rather than anything new here.

## Browser UI dialog policy

Required and binding. `alert`, `confirm`, `prompt`, all their `window.*` forms, and `beforeunload` prompts are prohibited. Every acknowledgement and confirmation is the app-owned `src/components/Modal.tsx`, verified to have a real Tab-cycling focus trap, Escape handling, and focus restoration to the trigger, or inline `role="status"`/`role="alert"` messaging. Both new modals (reconciliation apply, and the Released transition) use `suppressDismiss={false}` and must not use `.destructive-warning`, which is reserved for the hard-delete/wipe-save tier. Enforced by `src/__tests__/nativeDialogPolicy.test.ts` plus a deterministic source scan of the changed files.

## Browser UI validation

This section is complete and defers nothing to the writer's completion claim.

- **Launch and readiness:** `npx supabase start`, then `npx supabase db reset`, then `npm run dev`. Capture the actual printed Vite URL; observed in the 5173-5178 range and never hardcoded.
- **Base URL:** the captured Vite dev URL. Relevant routes are the course workspace's Settings, Students, and Versions tabs.
- **Credentials:** owner account `owner@test.local` / `password`, per `supabase/seed.sql:78`.
- **Fixture and reset:** `npx supabase db reset` before each pass.
  - Fixture A: a published course version with 3+ lessons and 2+ enrolled students, with rows seeded across `automatic`, `released`, and `held`, at least one `completed_at` set, and at least one lesson with no entitlement row.
  - Fixture B: a draft version, to confirm the reconciliation panel is absent.
  - Fixture C: a cohort-scheduled course with two students in one cohort enrolled on different dates, for the anchor-naming copy and the per-student scope disclosure.
  - Fixture D: a course whose saved `prerequisite_version_id` is a UUID that resolves to nothing, for the unresolvable state.
  - Fixture E **(added by explicit user direction):** two courses under one owner, course B naming a published version of course A as its prerequisite, with one student who has completed enough of A to qualify and one who has not, plus a pending enrollment request on B for each.
  - Fixture F **(added by explicit user direction):** a prerequisite course with a held-and-not-completed lesson, for the denominator-risk advisory.
  - Fixture G **(added by explicit user direction):** a prerequisite course republished to a later version after a student completed the earlier one, for journey 6 below.
- **Journeys:**
  1. Reconciliation panel: confirm absent on Fixture B, present on Fixture A nested under the published-settings panel. Preview through loading to populated. Confirm all six buckets are distinguishable by text alone under a grayscale or forced-colors rendering. Apply through the app-owned modal. Confirm the inline result renders outside the modal. Reload and confirm reset to idle. Force a stale token and confirm the distinct stale-token state rather than a generic error.
  2. Roster: expand a student by keyboard. Confirm the no-entitlement cell is disabled with visible explanation. Set a future-dated lesson to Released and confirm the modal discloses both immediate visibility and the permanent consequence. Confirm inline success. Set the same row to Automatic and confirm the permanent-unlock disclosure appears. Set another to Held and confirm no modal and an immediate inline confirmation. On Fixture C, confirm the per-student scope copy and confirm the second student in the cohort is unaffected.
  3. Prerequisite picker: confirm the field order, confirm the `manual_release` checkbox renders undistorted, select a course and version, save, reload, confirm persistence. Open Fixture D and confirm the unresolvable alert with the raw ID de-emphasized and the stored value not nulled. Confirm the picker now shows the enforced-state copy from design delta section A, not the retired inertness disclosure.
  4. Confirm the completion-threshold hint and its `aria-describedby` through the accessibility tree.
  5. Confirm the `manual_release` hint states both the naming distinction and the inertness. (`manual_release` itself remains genuinely inert this phase; only the prerequisite setting's enforcement status changed.)
  6. Confirm the apply-migration note renders only after the G-ENT-1 fix is in the tested build.
  7. Run the no-native-dialog scan across the changed files and confirm zero matches.
  8. Keyboard and focus pass: tab through the roster toggle, the per-lesson selects, and both modals. Confirm the focus trap, that Escape closes both, and that focus returns to the triggering element.
  9. **(Added by explicit user direction.)** On Fixture E, approve the unqualified student on course B and confirm the specific blocked alert renders with real course title, version, and ratio, that the request stays pending, and that Approve remains clickable as its own retry.
  10. **(Added by explicit user direction.)** Follow the printed recovery path exactly as an owner would: go to course A's roster, mark the missing lessons complete, return to course B, re-approve, and confirm it now succeeds. This journey is the single most important one in the added scope, because it validates that the instructions the product prints to the owner actually work.
  11. **(Added by explicit user direction.)** On Fixture E, approve the already-qualified student and confirm it succeeds first time.
  12. **(Added by explicit user direction.)** On Fixture F, confirm the held-blocked completion button is disabled with its own distinct explanation while the select stays enabled, then change access off held and confirm the button becomes enabled.
  13. **(Added by explicit user direction.)** On Fixture F, confirm the denominator-risk advisory appears only when a held-and-not-completed lesson exists and disappears once resolved.
  14. **(Added by explicit user direction.)** On Fixture G, confirm republish tolerance end to end: the student who completed the earlier version still satisfies the prerequisite naming the later version.
  15. **(Added by explicit user direction.)** Confirm the threshold label reads "100% (default — no threshold set)" for a null threshold and a plain percent for a configured one, including a configured value of exactly 100%.
  16. **(Added by explicit user direction.)** Confirm blank-vs-zero completion-threshold save behavior through a full save-reload cycle.
  17. **(Added by explicit user direction.)** Confirm a non-prerequisite approval failure still renders as plain `role="status"`, so the new alert treatment is genuinely reserved for the prerequisite gate.
- **Viewport profiles:** default desktop, and the existing `max-width:700px` mobile breakpoint. At both, confirm the new fieldsets and the roster reflow to a single column under the existing rules with no new breakpoint, and that every new control, including the new roster completion button, keeps a 44px touch target.
- **Visible outcomes:** the six buckets read by text and weight alone with no color cue; the three roster states read from select text alone; the no-entitlement cell reads calm and inactive rather than alarming; the unresolvable-prerequisite state reads at alert severity and the load-error state at advisory severity, visibly distinct; the focus ring on every new control is the existing 3px terracotta-600 ring at 2px offset, unchanged; **(added by explicit user direction)** the new prerequisite-blocked alert is visibly distinct in treatment from the plain status text used for every other message in that same slot; and the held-blocked and no-entitlement-row roster buttons are deliberately identical in visual weight and distinguishable only through the accessibility tree, which must be confirmed by inspecting the accessibility tree and not visually.
- **Coverage boundary, stated explicitly:** the five G-ENT-1 assertions are not browser-testable and are gated by the database-level tests in Acceptance instead. Browser validation and database evidence are both required; neither substitutes for the other. The same boundary applies to the completion-semantic threshold-boundary, republish-tolerance, and live-re-evaluation assertions (acceptance items 3, 6, and 7): they are proven at the database level and exercised end to end in browser journeys 9-14, but the arithmetic itself is not re-derived in the browser.

## Judge route

`PLAN_DUCK` eligibility is the orchestrator's call after this draft exists, under `docs/JUDGE-CONTRACT.md`. Pending, not asserted here.

## Approval

Explicit user approval of this document is required before any engineering writer begins. Approval of this document authorizes Phase 3 only and does not authorize Phase 4 or Phase 5, each of which requires its own plan document and its own explicit approval.

### Approval record

**Approved.** Approved by rob.hasselbach@gmail.com on 2026-08-30, given directly to the orchestrator in the live interactive session (not relayed through a teammate or subagent).

**Exact user reply:** "1. no, as recommended. 2. i don't understand the question. proceed as planned."

**What was presented to the user before this reply:**

1. Whether an owner should be able to override the prerequisite gate at approval time. The plan recommended NO (see "Open questions recorded but not blocking" above).
2. Two minor cosmetic follow-up items, presented as low priority, asking for the user's preference: the raw-UUID display in the enrollment-request list, and the percent-precision rounding behavior on save.

**How the reply maps to plan disposition:**

1. Confirmed NO owner override of the prerequisite gate, as recommended. `approve_enrollment_request`'s signature is not changed to add a bypass; the roster completion action remains the sole recorded escape hatch. No change to the plan text.
2. The user stated they did not understand the specific cosmetic-items question, and directed the orchestrator to "proceed as planned." This is treated as authorization to proceed with the plan's existing default handling of both items as already written, without alteration:
   - The raw-UUID display fix remains an open question marked "Recommended, not required" (see "Open questions recorded but not blocking" above); it is not added to this phase's mandatory scope by this approval.
   - The percent-precision rounding behavior remains risk R22, "Recorded as a known limit for engineering to resolve at implementation time" (see the risk table above); it is not elevated to a blocking acceptance item by this approval.

**Scope this approval authorizes.** The full Phase 3 plan as it now stands, including both the original owner-enforcement-controls scope (the G-ENT-1 fix, the reconciliation panel, the hold/release control, and the completion-threshold hint) and the full prerequisite-enforcement expansion added by the user's earlier explicit direction (the derived, not-stored completion semantic; the shared `assert_course_prerequisite` predicate; and its wiring into both live enrollment-grant call sites, `approve_enrollment_request` and `request_cohort_enrollment`). This approval authorizes Phase 3 only; it does not authorize Phase 4 or Phase 5.
