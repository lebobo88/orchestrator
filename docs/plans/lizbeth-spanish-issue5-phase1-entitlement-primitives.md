# Lizbeth Spanish, Issue #5 Phase 1: entitlement, safety, and audit primitives

Status: Approved. Phase 1 of five. Approval of this document authorizes only this phase; it does not authorize Phase 2, 3, 4, or 5, each of which requires its own plan document and its own explicit approval.

Approved by: rob.hasselbach@gmail.com, 2026-08-29, direct interactive-session response to the orchestrator, exact reply "approve", answering the orchestrator's prior message presenting the five-phase breakdown and asking "Approve Phase 1 to start?"

Plan ID: `lizbeth-spanish-issue5-phase1-entitlement-primitives`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: `engineering-fleet` (after explicit user approval of this plan)
Roadmap: `docs/plans/lizbeth-spanish-issue5-roadmap.md`
Design route for Phase 1: none. This phase has no user-visible surface. Phase 4, which depends on this phase's setter and audit trail, requires a new design pass before it can build; that pass is not part of this phase.

## Outcome

Establish correct, safe, auditable backend semantics for course-setting enforcement, with no user-visible change. Every object added in this phase ships dark: it exists in the database and is reachable through the Edge function's authorization layer, but nothing in the existing product calls it automatically. Completion is proven entirely by database-level evidence, not by any browser-observed behavior, because none exists yet for this phase: see the roadmap's reframing finding for why that is the correct bar here rather than a lighter one.

## Scope

**In scope:**

1. A NEW reconciliation function, distinct from and never delegating to or aliasing `materialize_enrollment_entitlements`. It updates only rows where `manual_release_state = 'automatic'`, and applies the monotonic forward-only guard:
   ```sql
   unlock_at = case
     when old.unlock_at <= now() then least(old.unlock_at, new_computed)
     else new_computed
   end
   ```
2. A preview counterpart returning the six change buckets and a `preview_token`; apply must present the token and reject a stale one.
3. A lesson-access setter RPC covering all four `manual_release_state` values (`automatic`, `released`, `held`, `revoked`), including hard re-lock (`revoked`).
4. Prerequisite enforcement at enrollment. `courses.prerequisite_version_id` is validated for existence on save today (inside `update_course_settings`) but never enforced when a new enrollment is granted.
5. A working audit trail. See the audit finding below: this is a new requirement discovered during this phase's planning, not a carry-forward item.
6. A progress-evidence read that Phase 4's warning UI will consume, with an honest limit recorded (see below).
7. SQL-level tests for every guarantee listed in Acceptance.

**Scope (out):**

- All UI. No React changes in this phase.
- `/learn` or any other student-facing surface (Phase 5).
- The reconciliation function is added but is never invoked automatically by any existing code path in this phase. It becomes reachable from an owner UI only in Phase 3.
- Cadence authoring (`unlock_offset_days` becoming real) is Phase 2. This phase's reconciliation logic is correct and testable against synthetic offsets regardless of whether Phase 2 has shipped yet, but has nothing meaningful to recompute against real authored courses until Phase 2 lands.
- Hard re-lock's owner-facing UI, confirmation tier, and warning copy are Phase 4. This phase builds only the backend setter and audit semantics that Phase 4's UI will call.

## Verified repository findings

- `materialize_enrollment_entitlements` (`supabase/migrations/202608280003_issue5_course_authoring.sql:235-249`) upserts with `on conflict (enrollment_id,lesson_revision_id) do update set unlock_at=excluded.unlock_at`, with no guard and no state filter. Its own comment calls it "idempotent and safe for concurrent callers," which makes it the function an implementer would naturally reach for: reusing it here would reintroduce the exact re-lock hazard this phase exists to prevent. It is called today only from `approve_enrollment_request` (line 416) and `request_cohort_enrollment` (line 472), both first-time-grant paths, and this phase does not change either call site.
- All five student-read RLS policies (`course_versions_student_read`, `lesson_revisions_student_read`, `course_version_lessons_student_read`, `course_assets_student_read`, `entitlements_own`; lines 520-527) gate on `unlock_at <= now()` AND `manual_release_state not in ('held','revoked')`, with no permanence clause and no special case letting `'released'` bypass `unlock_at`.
- No RPC anywhere currently sets `manual_release_state` away from `'automatic'`. The only occurrences of that column in the repository are the column definition (line 191), the RLS policies (520-527), and the quiz-lock check (line 496), verified by direct grep and read of the migration file.
- `update_course_settings` (lines 344-381) writes only to `courses` and, conditionally, to `course_version_lessons.is_preview`. It never touches `enrollment_lesson_entitlements`. Settings saves are genuinely inert today, which is what makes a separate, previewable reconciliation step both possible and necessary: settings changes and entitlement changes are two different actions with two different blast radii, and this phase keeps them that way.
- `src/lib/weekUnlock.ts` documents the product invariant in its own file header: "Previously unlocked weeks remain permanently accessible." This phase's monotonic guard exists to preserve that invariant once the new entitlement path becomes load-bearing.

## Audit finding

Give this its own section because it is new since the prior plan and it blocks a credible hard re-lock. The activity/audit trail is currently non-functional, in two compounding ways, plus a third finding that makes the first two moot in practice.

1. `record_activity_event` (migration lines 289-293) derives both `actor_id` and `owner_id` from `auth.uid()`. It is granted to `service_role` only (line 539). The Edge function authenticates with a service-role client, under which `auth.uid()` is NULL. Any event written through this function as currently defined would record a null actor and a null owner.
2. `list_activity` (`supabase/functions/course-authoring/index.ts:155-156`) reads `activity_events` filtered by `.eq('owner_id', data.user.id)`. Null-owner rows, even if they existed, would never appear in the feed.
3. Decisively: a grep of `supabase/functions/course-authoring/index.ts` confirms the Edge function never calls `record_activity_event` at all, under any action. The workspace Activity tab therefore reads a table that nothing populates and is permanently empty today.

**Required fix in this phase.** Introduce an audit writer that takes the actor and owner as explicit parameters, rather than relying on `auth.uid()` under a service-role client. Record every entitlement-access mutation through it: reconciliation apply, and each lesson-access state-change call from the setter RPC. Each entry captures the previous state, the new state, the actor, the enrollment, and the lesson. This must exist and be proven working before Phase 4 can credibly claim hard re-lock has an audit trail: Phase 4 depends on this being real, not narrated.

## Hard re-lock design decisions (backend semantics only; the UI is Phase 4)

- **`held` vs `revoked`.** The database does not distinguish their effect: both are excluded identically by the student-read policies (`manual_release_state not in ('held','revoked')`). `held` means temporarily withheld and expected to resume; `revoked` means access deliberately taken away. The distinction exists for the owner's understanding and for the audit trail, not for RLS. Do not build any logic that treats them differently at the database level; any such difference belongs in Phase 4's UI copy only.
- **No data destruction.** Hard re-lock never destroys student data. `quiz_attempts` rows and `enrollment_lesson_entitlements.completed_at` are always preserved by the setter RPC regardless of the target state. Revocation controls access, not history. This resolves the open question the prior plan carried about whether revoking clears completion or quiz history: it does not, and the setter must not.
- **Guard exemption.** Hard re-lock is exempt from the monotonic guard, because it is a single-row, explicitly-confirmed owner action rather than a bulk recompute. This exemption is precisely why it needs its own confirmation tier and its own audit entry in Phase 4, and precisely why the bulk reconciliation path must never be able to reach it: the setter RPC and the reconciliation function must remain structurally separate, not a shared code path with a state check.
- **`released` sets `unlock_at = now()`.** The `released` transition must set `unlock_at = now()` in the same mutation as the setter call. Without this, per the RLS finding above, releasing a future-dated lesson silently does nothing: the student-read policy still checks `unlock_at <= now()` independently of `manual_release_state`. This transition is also exempt from the monotonic guard, and is safe by construction: setting `unlock_at = now()` at write time can only grant or preserve visibility, never remove it, because "now" at the instant of the write is never later than itself.
- **Progress-evidence read, with an honest limit.** Phase 1 must expose, per (enrollment, lesson_revision): whether `completed_at` is set, and the count of `quiz_attempts`. State the limit plainly: there is no reliable "student opened but did not complete" signal for workspace-authored courses, because `student_lesson_progress.lesson_id` references the legacy `public.lessons` table, while `save_outline` creates `lesson_revisions` rows with no `legacy_lesson_id` populated (only the backfill path populates that column, for lessons copied from the legacy table). Workspace-authored lessons therefore have no `student_lesson_progress` rows at all, ever. Phase 4's warning copy must be able to say "this student has completed this lesson" or "this student has N quiz attempts on this lesson," and must not claim to know whether a student merely viewed it without completing it. This phase's read must not imply data it cannot supply; do not backfill a fabricated "viewed" signal.

## Ordered work

1. **RED evidence.** `npx supabase start`; `npx supabase db reset`. Seed an enrollment. Confirm `materialize_enrollment_entitlements` moves `unlock_at` later when offsets increase (demonstrating the hazard this phase closes), and confirm `activity_events` is empty and unwritten after normal workspace actions (demonstrating the audit finding above). Capture both as evidence before any fix.
2. **Failing SQL-level tests first**, for every guarantee in the Acceptance list below.
3. **Audit writer.** Add the function that takes actor and owner as explicit parameters; wire it into the setter and reconciliation-apply code paths built in steps 4 and 6.
4. **Lesson-access setter.** Covers `automatic`/`released`/`held`/`revoked`, with the `released` → `unlock_at = now()` behavior, preservation of `completed_at` and `quiz_attempts`, and an audit entry on every transition.
5. **Reconciliation preview.** Returns the six buckets and a `preview_token`.
6. **Reconciliation apply.** Automatic-only filter, the monotonic guard evaluated against the live on-disk row at `ON CONFLICT DO UPDATE` time, token validation, and an audit entry.
7. **Prerequisite enforcement at enrollment.** Applied only at new-entitlement-grant time; existing enrollments are not retroactively revoked by this step (see Risks).
8. **Progress-evidence read.**
9. **Edge function exposure.** New actions in `supabase/functions/course-authoring/index.ts`, with owner authorization matching the existing pattern for owner-scoped actions.
10. **Full suite after `npx supabase db reset`; Verifier pass.**

**Ownership.** T1 for steps 1-3. Anticipate T2 for steps 4-7, the concurrency- and correctness-sensitive core (the monotonic guard, the token contract, and the setter's guard exemptions). This is stated as an expectation, not a failure condition, matching the same anticipated-escalation framing used in the sibling QA and release-cadence plans for comparably sensitive work.

## Acceptance (all database-level; all mandatory)

- Reconciliation run twice in immediate succession against an already-unlocked automatic row never moves its `unlock_at` later.
- Reconciliation never modifies any row whose `manual_release_state` is `held`, `released`, or `revoked`.
- Reconciliation with a stale `preview_token` is rejected, not silently applied.
- The six preview bucket counts match the changes a subsequent apply actually makes.
- A lesson set to `released` with a future-dated `unlock_at` becomes visible under the student-read policies: assert this by querying as the student database role, not by reading the row as service_role and inferring the policy would have applied.
- A lesson set to `held` or `revoked` becomes invisible under the same policies, asserted the same way.
- Revoking preserves `completed_at` and every `quiz_attempts` row for that student and lesson.
- A prerequisite-gated enrollment does not receive entitlements until the prerequisite is satisfied.
- Every access mutation (setter transition, reconciliation apply) writes an `activity_events` row with a non-null `actor_id` and a non-null `owner_id`, and that row is returned by the `list_activity` query path.
- `materialize_enrollment_entitlements` is not called by, and does not appear in, the reconciliation code path: assert this as a source-level check (grep or static analysis of the migration/function body), not only behaviorally.
- Full suite passes after `npx supabase db reset`.

Because this phase has no UI, there is no Browser Validator gate. This makes the database-level evidence above the sole completion proof for this phase, not a lighter bar than a UI-bearing phase's: every assertion about student visibility must be made through the student database role so RLS is genuinely exercised, never bypassed by a service-role read that would pass even if the policy were broken.

## Risks and rollback

| ID | Severity | Risk | Mitigation |
|----|----------|------|------------|
| R1 | Critical | An implementer reuses or aliases `materialize_enrollment_entitlements` for reconciliation, reintroducing the re-lock hazard | Named as a prohibited implementation path; enforced by the source-level check in Acceptance asserting the two functions are distinct and the new function never delegates to the old one |
| R2 | High | The monotonic guard is evaluated against a cached preview value rather than the live on-disk row, reopening the preview/apply race | Ordered-work step 6 requires the guard be evaluated against the row at `ON CONFLICT DO UPDATE` time; this is stated as a binding requirement, not an implementation preference |
| R3 | Medium | Hard re-lock's guard exemption is over-applied to the bulk reconciliation path | Mitigated by keeping the setter and reconciliation as structurally separate functions, plus an Acceptance test running the bulk path against `held`/`released`/`revoked` rows and confirming none are touched |
| R4 | Medium | An audit entry is written with a null actor under the service-role client, recreating the existing bug described in the audit finding | Mitigated by the explicit-parameter requirement on the audit writer, plus the non-null `actor_id`/`owner_id` assertion in Acceptance |
| R5 | Medium | Prerequisite enforcement accidentally strands existing enrollments that predate the prerequisite requirement | Mitigated by applying enforcement only at new-entitlement-grant time (step 7); this phase never retroactively revokes an existing enrollment for a prerequisite reason |
| R6 | Low | A stale local database produces confusing or false-failing test results | Mandatory `npx supabase db reset` before every validation pass |
| R7 | Low | A reviewer or future contributor mistakes the absence of a Browser Validator gate for a skipped verification step | Stated explicitly in this plan and in the roadmap: no browser surface exists in this phase, so database-level evidence plus Verifier is the correct and complete gate, not a reduced one |

**Rollback.** Every object added in this phase is additive and is not wired to any automatic caller in the existing product. Leaving the new functions and reads built but unused is itself a safe rollback state. Dropping them restores current behavior exactly, with no data migration required, because nothing in this phase changes an existing call site's behavior.

## Interfaces and data

- New database functions: reconciliation preview, reconciliation apply, the lesson-access setter, the audit writer, prerequisite enforcement at enrollment, and the progress-evidence read.
- Preview response contract (carried forward unchanged from the prior single-plan draft's reviewed shape):
  ```
  {
    scope: { course_id, version_id, version_label },
    computed_at,
    preview_token,
    totals: { enrollments_evaluated, entitlements_evaluated },
    changes: {
      unlocking_now, still_locked_earlier, still_locked_later,
      newly_eligible_locked, excluded_manual_override, already_visible_unaffected
    },
    affected_students_sample: [
      { enrollment_id, student_display_name, lesson_title, change_kind }
    ], // capped at ~10
    warnings: []
  }
  ```
- Apply response contract: `{ applied, failed, failures: [{ enrollment_id, lesson_title, reason }] }`, with either a retry-failed-subset path or a safe idempotent full-rerun path, at engineering discretion.
- All new functions are exposed through the Edge function as new actions, following the existing owner-authorization pattern. No existing action's behavior changes in this phase.
- No schema migration is strictly required for the guard logic itself, but the `preview_token` mechanism likely needs a small persisted or derived value (for example, a hash of the scope plus a timestamp); exact mechanism is engineering discretion, consistent with the permitted-variation note in the sibling plan.

## Assumptions and decisions

**Safe assumptions:**

- This phase's SQL-level tests can exercise the student-read RLS policies by connecting as the student role (or issuing queries under a JWT scoped to a test student), consistent with how `rlsIntegration.test.ts` already tests other policies in this repository.
- The `preview_token` mechanism does not need to survive a server restart; it only needs to detect staleness within a single owner session.

**Resolved decisions:** D1-D4, recorded in the roadmap (`docs/plans/lizbeth-spanish-issue5-roadmap.md`), apply to this phase without modification.

**No open decisions remain for this phase.** The audit finding and the progress-evidence limit are stated as requirements and honest limits above, not as open questions requiring further user input before this phase can proceed.

Explicit user approval of this document, recorded against the status header and approval record above, has been received and authorizes engineering writer work on this phase. That approval does not authorize Phase 2, 3, 4, or 5.

## browser_ui_validation

Not applicable for this phase. No browser-rendered surface changes in Phase 1; every object added ships dark and is reachable only through direct RPC/Edge-function calls made by tests, never through any page a user opens. This is stated explicitly, with the reason, rather than left as an empty section, so its absence is not mistaken for an overlooked gate.

Phases 2 through 5 each carry the full browser validation brief, including: launch via `npx supabase start`, `npx supabase db reset`, `npm run dev`, capturing the actual printed Vite URL (observed in the 5173-5178 range; never hardcoded); the owner account `owner@test.local` / `password` per `supabase/seed.sql:78`; and the no-native-dialog policy (`alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload` prompts are prohibited everywhere in this programme, per every phase's own plan).
