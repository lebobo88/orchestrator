---
name: t1-refactor-safety
description: T1 behavior-preserving refactor playbook. Use when reorganizing, simplifying, or reducing duplication without an approved behavior change.
user-invocable: false
---

# Refactor safety

- State the invariant behavior, compatibility boundary, and non-goals before edits.
- Add/run characterization coverage first; establish a passing baseline and keep it green through each small move.
- Preserve public contracts, error semantics, ordering, side effects, persistence shape, and dependency direction unless the job explicitly changes them.
- Prefer incremental extraction or consolidation over broad rewrites. Stop if the refactor exposes a needed product/architecture decision.
- Compare final behavior, diff, tests, and performance-sensitive paths against the baseline. Report intentional changes as a blocker if they were not authorized.
