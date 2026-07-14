---
name: scribe-specification-and-planning
description: Write plans, requirements, instructions, ADRs, and decision records that preserve authority, scope, assumptions, and acceptance checks.
user-invocable: false
---

# Specifications and plans

Use with `scribe-core` for plans, instructions, requirements, ADRs, and decision records. For a non-basic task, consume Planner's direct `PLANNING_HANDOFF` and write the exact approved `docs/plans/<slug>.md` target.

1. State the outcome, intended audience, in-scope work, exclusions, dependencies, acceptance checks, and explicit approvals.
2. Record decisions as decisions; do not disguise an assumption or recommendation as settled fact.
3. Keep implementation sequencing actionable without inventing file-level changes absent evidence.
4. Surface material risks, unknowns, and handoff owners where they change execution.
5. For persisted plans, include draft/approved status, evidence references, ordered work, validation, rollback/containment, browser UI dialog policy where applicable, and the explicit user-approval gate before T1 execution. Never approve a plan without the lead's explicit user-approval relay.
