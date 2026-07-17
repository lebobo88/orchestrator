---
name: t2-escalation
description: Preserve evidence and ownership when T2 takes over an unresolved T1 engineering job.
user-invocable: false
---

# T2 escalation

1. Do not edit until a valid `ENGINEERING_ESCALATION_PACKET` confirms the former writer released ownership, or a direct T2 `ENGINEERING_JOB` confirms T2 ownership.
2. Reproduce the gate failure before changing code; preserve working T1 changes and focused tests when still valid.
3. Keep the approved plan and non-goals fixed. Return a blocker instead of silently redesigning or adding dependencies.
4. Carry all normal TDD, quality-review, documentation-handoff, verifier, and browser-validator requirements forward.
5. If bounded remediation would actually require a material portion of the already approved plan, return `RESCOPE_REQUIRED` with the remaining scope, retained work, gate evidence, an unchanged-plan confirmation, and a stable scope fingerprint. Do not treat it as a remediation cycle.
6. On `assignment_kind: full-build-continuation`, audit the plan and current state first, then implement the remaining approved scope sequentially as T2. Preserve all normal TDD, quality-review, verifier, browser-validator, and judge gates.
7. Count only completed remediation cycles rejected by an independent gate. At the T2 limit, return the evidence-backed user-review/replanning blocker. A repeated identical scope fingerprint, stale plan, changed acceptance criterion, or missing prerequisite is blocked rather than re-dispatched.
