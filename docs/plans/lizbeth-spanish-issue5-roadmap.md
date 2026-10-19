# Lizbeth Spanish, Issue #5: phased delivery roadmap

Status: Five-phase breakdown accepted as the working plan. Phase 1 is approved to begin implementation. Phases 2-5 remain pending their own individual approval as each prior phase's results are reviewed.

Approval record: the five-phase breakdown was presented to the user as "Approve Phase 1 to start?" and the user (rob.hasselbach@gmail.com) replied "approve" directly to the orchestrator in the live interactive session on 2026-08-29. That reply authorizes Phase 1 only. It accepts the overall five-phase breakdown as the working sequencing plan, but each of Phases 2 through 5 still requires its own plan document and its own explicit future approval before any engineering writer begins that phase's work. See `docs/plans/lizbeth-spanish-issue5-phase1-entitlement-primitives.md` for Phase 1's own approval record.

Plan ID: `lizbeth-spanish-issue5-roadmap`
Route: engineering (umbrella; not itself an execution plan)
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Downstream owner: none directly. Each phase's own plan document is the downstream owner's actual authorization

This document supersedes the single-plan structure of `docs/plans/lizbeth-spanish-issue5-release-cadence-enforcement.md`. That prior plan combined settings enforcement, retroactive reconciliation, owner controls, and a new student surface into one four-batch build. This roadmap splits that same scope into five sequenced phases, each with its own plan document, its own explicit user approval, and its own verification gate. This document is the umbrella record: it holds the settled cross-phase decisions, the phase breakdown with its dependency reasoning, and one reframing finding that changes how "validated" should be read at every phase before Phase 5. It grants no authority by itself and authorizes no engineering work. Only an approved phase plan does that, and only for its own phase.

## Settled decisions

These decisions were resolved by the user in the prior single-plan draft and carry forward unchanged. They are recorded here as the scope frame for all five phases, not reopened by this roadmap.

**D1: the settings-enforcement interpretation of issue #5 is correct for now.** No cross-course shared content library is built by this programme. "Curating all content for everyone" continues to be served by the existing per-course `visibility: catalog` plus per-lesson `is_preview` plus the public catalog page. A genuine cross-course shared content library remains a separate, explicitly scoped build if the owner ever wants one.

**D2: fold in.** `manual_release`, `completion_threshold`, and `prerequisite_version_id` are the same class of bug as `release_cadence`: each has a UI control and a database column, but no code path reads it to change student-visible behavior. All four are fixed together across this programme rather than tracked as separate follow-up work.

**D3: retroactive.** Existing enrollments' entitlements are reconciled against newly enforced settings, not left forward-only. This is the decision that makes Phase 1's safety work load-bearing: retroactive recomputation against a table with no permanence guarantee is capable of hiding content a student can already see, and Phase 1 exists to prevent that by construction.

**D4: hard re-lock is in scope, as a deliberate, explicitly-triggered, separately-confirmed owner action.** The prior plan treated a harder re-lock (one that actually removes already-granted access) as an unresolved open question, deferred to a future separate request. That question is now resolved: it is in scope for this programme, as Phase 4. It is an ADDITIONAL opt-in capability, not a relaxation of the automatic reconciliation safety guarantee. The monotonic guarantee (never move `unlock_at` later for an already-visible row under automatic reconciliation) stays fully intact. Hard re-lock is a separate, single-row, owner-confirmed write path that the bulk reconciliation path must never be able to reach.

## Reframing finding

Record this prominently. It changes how each phase can be validated, and it corrects a claim in the prior single-plan draft that was stated more strongly than the evidence supports.

**The entitlement system gates nothing a student can currently see.** Verified: a repository-wide grep of `src/` for `enrollment_lesson_entitlements|lesson_revisions|course_version_lessons` returns only `src/services/courseAuthoring.ts` (the owner authoring service) and its test files. `App.tsx` confirms students are served by `RoadmapPage`/`WeekDetailPage`, which read the legacy `bands`/`lessons`/`student_lesson_progress` tables and compute unlocking directly from `lessons.unlock_offset_days` via `src/lib/weekUnlock.ts`. Workspace-authored courses (the entire data model this programme enforces settings against) have no student-facing surface at all today.

Three consequences follow from this, and all three matter to how each phase gate should be read:

1. **The re-lock hazard is real but currently latent, not live.** The prior plan's safety analysis (the monotonic guard, the automatic-only filter) is correct and remains binding. But the RLS policies it protects against are not reachable by any student today, because no student-facing page queries the entitlement tables. The hazard becomes live the instant the student surface ships, which is Phase 5.
2. **Phases 1 through 4 cannot be validated by observing student-visible behavior.** There is no student page to observe. Each of those phases must be validated by direct database and API assertions instead: querying as the student database role to genuinely exercise RLS, not by reading rows as service_role and inferring the policy would have applied.
3. **True end-to-end confirmation, where a real student session actually sees the effect of a setting, only arrives at Phase 5.** Do not treat a Phase 1-4 database-level pass as equivalent to an end-to-end proof; it is not, until Phase 5 ships.

**Correction to the prior plan's phrasing.** The prior single-plan draft stated that this work "changes live student access state." That was imprecise. More precisely: this work changes entitlement state that will gate student access once Phase 5 ships. Today, changing that state changes nothing a student can see, because nothing reads it on their behalf. Being accurate about this distinction matters for judging what "validated" means at each phase gate: a Phase 1-4 pass proves the backend is correct, not that a student experienced anything.

## Ship-gate G-ENT-1: apply_version_migration safety (hard blocking prerequisite)

This defect has so far been recorded only as a risk-table row with an intention to fix it "before Phase 5." A risk row is not a gate: it can be read, agreed with, and silently skipped, and nothing in the process would stop a later phase from shipping without it. This section converts that intention into a named, enforceable prerequisite with a concrete acceptance check and an owning phase.

**The defect, with verified evidence.** `apply_version_migration` (`supabase/migrations/202608280003_issue5_course_authoring.sql:252-265`) unconditionally runs `delete from enrollment_lesson_entitlements where enrollment_id=e.id` and then reinserts every row from `e.enrollment_date + make_interval(days => cvl.unlock_offset_days)`. Two distinct defects follow, and both must be fixed for the gate to be satisfied:

1. **No monotonic guard.** It can move `unlock_at` later for a row a student could already see, re-locking content. This is the exact hazard Phase 1's reconciliation was built to prevent by construction, sitting in a path Phase 1 deliberately did not change.
2. **Manual state destruction.** Because it deletes the rows outright rather than updating them, it discards every `manual_release_state`, silently resetting a deliberate `released`, `held`, or `revoked` back to `automatic`. It also discards `completed_at`. Phase 1's plan states explicitly that revocation controls access and never history; this path violates that guarantee.

**Why it is currently latent rather than live, and why that is not a reason to defer it further.** Every `unlock_offset_days` is 0 today, so the reinserted rows unlock immediately and nothing can be hidden. Phase 2 makes offsets real, which arms the defect. No student can observe it until Phase 5 ships a student-facing surface that reads entitlements. So the window between Phase 2 and Phase 5 is precisely the interval in which this must be fixed, and it is also precisely the interval in which it is easiest to forget, because nothing visibly breaks.

**The one part already handled**, so the gate is not overstated: Phase 2 routes this function's anchor through the shared `resolve_entitlement_anchor` helper, so it computes the correct anchor for both unlock models. That fixes which clock it reads. It does nothing about the monotonic guard or the manual-state destruction, which are the two defects this gate covers.

**Owning phase: Phase 3.** Phase 3 is already building the owner-facing reconciliation preview/apply surface on top of Phase 1's guarded semantics, so it is the phase that already has the guard logic, the audit trail, and the confirmation patterns in hand. Fixing it there costs the least and concentrates the entitlement-safety semantics in one place instead of scattering them. Assigning it to Phase 3 also removes the failure mode this gate exists to prevent: an undated fix floating across three phase boundaries with no owner.

**The gate, in three binding clauses:**

**Clause 1, on Phase 3.** Phase 3's plan document must carry G-ENT-1 in its own Acceptance section as a mandatory item, not in its risk table. Phase 3 cannot be marked complete, and its Verifier pass cannot be claimed, until the acceptance evidence below is produced. If Phase 3's scope is later renegotiated so that this fix moves elsewhere, the gate moves with it explicitly and is re-recorded in the new owning phase's plan; it is never simply dropped.

**Clause 2, on Phase 5 and on any phase that first creates a live student-facing entitlement path.** That phase's plan must open with a "Blocking prerequisites" section naming G-ENT-1 and stating that neither its Verifier pass nor its Browser Validator pass may be claimed while G-ENT-1 is unsatisfied. This is a hard stop on completion, not an advisory. If Phase 5 is reached and G-ENT-1 is still open, the correct action is to stop and satisfy the gate, not to ship and file follow-up work.

**Clause 3, on the plan template for every subsequent phase.** Every phase plan written after this amendment carries a "Blocking prerequisites" section, listing either the open gates that constrain it or an explicit `none`. An absent section is itself a defect in the plan. This exists so the gate is impossible to lose by omission: a future author has to affirmatively write `none` rather than simply not think about it.

**Acceptance evidence for G-ENT-1, all mandatory, all database-level, and all written as tests rather than prose claims:**

- A student holding an entitlement whose `unlock_at` is already in the past, migrated to a version whose `unlock_offset_days` for that lesson is larger, retains a visible row: the migration must not move `unlock_at` later for an already-visible row. Assert by querying as the student database role so RLS is genuinely exercised, never by a service_role read that would pass even if the policy were broken. This is the same standard Phase 1's acceptance already sets.
- A row in each of `released`, `held`, and `revoked` retains its exact `manual_release_state` across a migration. All three states, individually asserted.
- `completed_at` and every `quiz_attempts` row for the migrated student and lesson survive the migration unchanged.
- A source-level assertion that `apply_version_migration`'s body contains no unguarded `delete from enrollment_lesson_entitlements`, that is, the function no longer achieves its result by destroying and recreating rows. The intent is stated in words too, so a future author who restructures the function cannot satisfy the literal grep while reintroducing the behavior: the requirement is that migration preserves per-row manual state and never reduces visibility, by whatever mechanism.
- A regression assertion that the bulk reconciliation path and the migration path remain structurally separate functions, consistent with Phase 1's R3 mitigation, so this fix does not merge them.

**Honest limit**, in the register the roadmap already uses for its reframing finding: these assertions prove the migration path is safe at the database level. Per the roadmap's own reframing finding, that is not the same as a student having experienced it, and it cannot be until Phase 5 ships. The gate is the correct and sufficient bar for the phase that fixes it, and Phase 5 additionally re-validates it through a real student session.

This amendment tightens the enforcement of an already-accepted mitigation and does not change any phase's scope. It does not require a new approval cycle. It was raised because an automated review flagged that the mitigation lacked an enforcement mechanism, and the user directed that it be made a hard gate.

## Phase breakdown with dependency reasoning

**Phase 1: backend entitlement, safety, and audit primitives.**
No user-visible change; ships dark. Contains the reconciliation function with the monotonic guard, the lesson-access setter (including hard re-lock), prerequisite enforcement, and a working audit trail. Rationale for going first: it is the highest-risk, safety-critical layer; every later phase depends on its semantics; and it is fully testable at the SQL layer in isolation. Settling the access semantics before any UI consumes them avoids rework in three later phases. Plan document: `docs/plans/lizbeth-spanish-issue5-phase1-entitlement-primitives.md` (Document 2 below; approved).

**Phase 2: cadence authoring (the literal issue #5 ask).**
Makes `unlock_offset_days` real in the Outline/Settings authoring surface: the client stops hardcoding `unlock_offset_days: 0` and threads the cadence-derived per-lesson value through `saveDraft` to `save_outline`. Depends on Phase 1 only loosely: it is client-and-`save_outline` work that is revert-safe and touches no live access state. Sequenced second because until offsets are real, Phase 1's reconciliation has nothing meaningful to recompute: every offset is currently 0, so reconciliation is a no-op against real data until this phase ships. Design is already done and passed for this phase (carried forward from the prior plan's design review).

**Phase 3: owner enforcement controls.**
The reconciliation preview/apply panel, per-student manual hold/release, the prerequisite picker, and the completion-threshold hint. Depends on Phase 1's RPCs (reconciliation, the roster reads) and Phase 2's real offsets (a reconciliation preview is meaningless against all-zero offsets).

**Phase 4: hard re-lock (revoke access).**
Deliberately its own phase, not folded into Phase 3, because it is the only genuinely destructive-to-access action in this programme. It warrants its own design pass, its own confirmation tier, and its own approval gate, separate from the additive/release-leaning controls in Phase 3. Depends on Phase 1's setter (the `revoked` state and its audit entry) and Phase 1's audit trail (a re-lock without a working audit trail is not credible as a deliberate, explainable owner action).

**Phase 5: student `/learn` surface.**
The largest single workstream and the only phase that makes any of the preceding work observable to a student. Sequenced last so entitlement semantics are fully settled before a consumer is built on them: building the student surface before Phase 1-4 stabilize the access model would risk building against semantics that still change. Honest tradeoff: sequencing it last means Phases 1-4 accumulate behavior that is correct but unobserved by any real student session, which is exactly why each of those phases carries mandatory database-level acceptance evidence rather than a browser claim, as described in the reframing finding above. Phase 5 is also the phase bound by ship-gate G-ENT-1 above: it cannot claim its Verifier or Browser Validator pass while G-ENT-1 is unsatisfied.

## Verification and design status per phase

Each phase requires its own plan document, its own explicit user approval, and its own Verifier pass. Phases 2 through 5 additionally require a Browser Validator pass, because each introduces or changes a browser-rendered surface. Phase 1 has no browser surface at all. Say this plainly rather than letting the absence look like a skipped gate: Phase 1's completion evidence is database-level assertions plus a Verifier pass, which is the correct and sufficient gate for a phase that ships nothing to a browser.

See ship-gate G-ENT-1 above for a mandatory, phase-specific completion prerequisite that sits alongside this general verification structure: it binds Phase 3's Acceptance section and Phase 5's Verifier/Browser Validator claims, and every phase plan written after this amendment must carry a "Blocking prerequisites" section naming it or stating `none`.

Design status differs per phase:

- **Phase 2:** design complete and passed (Compact route, carried forward unchanged from the prior plan's reviewed packet).
- **Phase 3:** design complete and passed (Standard route, carried forward from the prior plan's reviewed packet covering the reconciliation panel, manual-release control, and prerequisite picker).
- **Phase 4:** requires a NEW design pass before it can build. Hard re-lock's owner-facing UI (the revoke control, its confirmation tier, and its warning copy) is not yet designed; the prior plan's design packet covered only the `held`/`released` states, not `revoked`. Phase 4 depends on Phase 1's setter and audit trail, and separately on Phase 3 having satisfied ship-gate G-ENT-1 above, since Phase 4's revoke action shares entitlement-safety semantics with the migration path that gate closes.
- **Phase 5:** design is drafted within the already-passed Standard packet (the `/learn` surface and its five `.lesson-card` states), but should be reconfirmed against the built entitlement semantics before it builds, since Phases 1-4 may surface details (for example, the progress-evidence limits recorded in Phase 1) that the original draft did not have in hand.

## What this document does not do

This roadmap records decisions and sequencing. It does not itself authorize engineering work for any phase. Phase 1's execution plan (Document 2, listed above) has received explicit user approval and is authorized to begin. Phases 2 through 5 each require their own plan document, written and approved separately, before any engineering writer begins that phase's work.
